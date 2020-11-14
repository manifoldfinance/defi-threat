pragma solidity ^0.5.7;

import {Authorizable} from "./Authorizable.sol";
import {ERC20SafeTransfer} from "./ERC20SafeTransfer.sol";
import {IERC20} from "./IERC20.sol";
import {LibMath} from "./LibMath.sol";
import {ReentrancyGuard} from "./ReentrancyGuard.sol";
import {IBank} from "./IBank.sol";

// Simple WETH interface to wrap and unwarp ETH.
interface IWETH {
    function balanceOf(address owner) external view returns (uint256);
    function deposit() external payable;
    function withdraw(uint256 amount) external;
}

/// A bank locks ETH and ERC20 tokens. It doesn't contain any exchange logics that helps upgrade the exchange contract.
/// Users have complete control over their assets. Only user trusted contracts are able to access the assets.
/// Address 0x0 is used to represent ETH.
contract ERC20Bank is IBank, Authorizable, ReentrancyGuard, LibMath {

    mapping(address => bool) public wethAddresses;
    mapping(address => mapping(address => uint256)) public deposits;

    event SetWETH(address addr, bool autoWrap);
    event Deposit(address token, address user, uint256 amount, uint256 balance);
    event Withdraw(address token, address user, uint256 amount, uint256 balance);

    function() external payable {}

    /// Sets WETH address to support auto wrap/unwrap ETH feature. ETH is required to test auto wrap/unwrap.
    /// @param addr WETH token address.
    /// @param autoWrap Whether the address supports auto wrap/unwrap.
    function setWETH(address addr, bool autoWrap) external onlyOwner payable {
        if (autoWrap) {
            uint256 testETH = msg.value;
            require(testETH > 0, "TEST_ETH_REQUIRED");
            uint256 beforeWrap = IWETH(addr).balanceOf(address(this));
            IWETH(addr).deposit.value(testETH)();
            require(IWETH(addr).balanceOf(address(this)) - beforeWrap == testETH, "FAILED_WRAP_TEST");
            uint256 beforeUnwrap = address(this).balance;
            IWETH(addr).withdraw(testETH);
            require(address(this).balance - beforeUnwrap == testETH, "FAILED_UNWRAP_TEST");
            require(msg.sender.send(testETH), "FAILED_REFUND_TEST_ETH");
        }
        wethAddresses[addr] = autoWrap;
        emit SetWETH(addr, autoWrap);
    }

    /// Checks whether the user has enough deposit.
    /// @param token Token address.
    /// @param user User address.
    /// @param amount Token amount.
    /// @return Whether the user has enough deposit.
    function hasDeposit(address token, address user, uint256 amount, bytes memory) public view returns (bool) {
        if (wethAddresses[token]) {
            return amount <= deposits[address(0)][user];
        }
        return amount <= deposits[token][user];
    }

    /// Checks token balance available to use (including user deposit amount + user approved allowance amount).
    /// @param token Token address.
    /// @param user User address.
    /// @return Token amount available.
    function getAvailable(address token, address user, bytes calldata) external view returns (uint256) {
        if (token == address(0)) {
            return deposits[address(0)][user];
        }
        uint256 allowance = min(
            IERC20(token).allowance(user, address(this)),
            IERC20(token).balanceOf(user)
        );
        return add(allowance, balanceOf(token, user));
    }

    /// Gets balance of user's deposit.
    /// @param token Token address.
    /// @param user User address.
    /// @return Token deposit amount.
    function balanceOf(address token, address user) public view returns (uint256) {
        if (wethAddresses[token]) {
            return deposits[address(0)][user];
        }
        return deposits[token][user];
    }

    /// Deposits token from user wallet to bank.
    /// @param token Token address.
    /// @param user User address (allows third-party give tokens to any users).
    /// @param amount Token amount.
    function deposit(address token, address user, uint256 amount, bytes calldata) external nonReentrant payable {
        if (token == address(0)) {
            require(amount == msg.value, "UNMATCHED_DEPOSIT_AMOUNT");
            deposits[address(0)][user] = add(deposits[address(0)][user], msg.value);
            emit Deposit(address(0), user, msg.value, deposits[address(0)][user]);
        } else {
            // Token should be approved in order to transfer
            require(ERC20SafeTransfer.safeTransferFrom(token, msg.sender, address(this), amount), "FAILED_DEPOSIT_TOKEN");
            if (wethAddresses[token]) {
                // Auto unwrap to ETH
                IWETH(token).withdraw(amount);
                deposits[address(0)][user] = add(deposits[address(0)][user], amount);
            } else {
                deposits[token][user] = add(deposits[token][user], amount);
            }
            emit Deposit(token, user, amount, deposits[token][user]);
        }
    }

    /// Withdraws token from bank to user wallet.
    /// @param token Token address.
    /// @param amount Token amount.
    function withdraw(address token, uint256 amount, bytes calldata) external nonReentrant {
        require(hasDeposit(token, msg.sender, amount, ""), "FAILED_WITHDRAW_INSUFFICIENT_DEPOSIT");
        if (token == address(0)) {
            deposits[address(0)][msg.sender] = sub(deposits[address(0)][msg.sender], amount);
            require(msg.sender.send(amount), "FAILED_WITHDRAW_SENDING_ETH");
            emit Withdraw(address(0), msg.sender, amount, deposits[address(0)][msg.sender]);
        } else {
            if (wethAddresses[token]) {
                // Auto wrap to WETH
                IWETH(token).deposit.value(amount)();
                deposits[address(0)][msg.sender] = sub(deposits[address(0)][msg.sender], amount);
            } else {
                deposits[token][msg.sender] = sub(deposits[token][msg.sender], amount);
            }
            require(ERC20SafeTransfer.safeTransfer(token, msg.sender, amount), "FAILED_WITHDRAW_SENDING_TOKEN");
            emit Withdraw(token, msg.sender, amount, deposits[token][msg.sender]);
        }
    }

    /// Transfers token from one address to another address.
    /// Only caller who are double-approved by both bank owner and token owner can invoke this function.
    /// @param token Token address.
    /// @param from The current token owner address.
    /// @param to The new token owner address.
    /// @param amount Token amount.
    /// @param fromDeposit True if use fund from bank deposit. False if use fund from user wallet.
    /// @param toDeposit True if deposit fund to bank deposit. False if send fund to user wallet.
    function transferFrom(
        address token,
        address from,
        address to,
        uint256 amount,
        bytes calldata,
        bool fromDeposit,
        bool toDeposit
    )
    external
    onlyAuthorized
    onlyUserApproved(from)
    nonReentrant
    {
        if (amount == 0 || from == to) {
            return;
        }
        if (fromDeposit) {
            require(hasDeposit(token, from, amount, ""));
            address actualToken = token;
            if (toDeposit) {
                // Deposit to deposit
                if (wethAddresses[token]) {
                    actualToken = address(0);
                }
                deposits[actualToken][from] = sub(deposits[actualToken][from], amount);
                deposits[actualToken][to] = add(deposits[actualToken][to], amount);
            } else {
                // Deposit to wallet
                if (token == address(0)) {
                    deposits[actualToken][from] = sub(deposits[actualToken][from], amount);
                    require(address(uint160(to)).send(amount), "FAILED_TRANSFER_FROM_DEPOSIT_TO_WALLET");
                } else {
                    if (wethAddresses[token]) {
                        // Auto wrap to WETH
                        IWETH(token).deposit.value(amount)();
                        actualToken = address(0);
                    }
                    deposits[actualToken][from] = sub(deposits[actualToken][from], amount);
                    require(ERC20SafeTransfer.safeTransfer(token, to, amount), "FAILED_TRANSFER_FROM_DEPOSIT_TO_WALLET");
                }
            }
        } else {
            if (toDeposit) {
                // Wallet to deposit
                require(ERC20SafeTransfer.safeTransferFrom(token, from, address(this), amount), "FAILED_TRANSFER_FROM_WALLET_TO_DEPOSIT");
                deposits[token][to] = add(deposits[token][to], amount);
            } else {
                // Wallet to wallet
                require(ERC20SafeTransfer.safeTransferFrom(token, from, to, amount), "FAILED_TRANSFER_FROM_WALLET_TO_WALLET");
            }
        }
    }
}
