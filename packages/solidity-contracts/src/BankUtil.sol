/**
 * Source Code first verified at https://etherscan.io on Friday, May 3, 2019
 (UTC) */

// File: contracts/bank/IBank.sol

pragma solidity ^0.5.7;

/// Bank Interface.
interface IBank {

    /// Modifies authorization of an address. Only contract owner can call this function.
    /// @param target Address to authorize / deauthorize.
    /// @param allowed Whether the target address is authorized.
    function authorize(address target, bool allowed) external;

    /// Modifies user approvals of an address.
    /// @param target Address to approve / unapprove.
    /// @param allowed Whether the target address is user approved.
    function userApprove(address target, bool allowed) external;

    /// Batch modifies user approvals.
    /// @param targetList Array of addresses to approve / unapprove.
    /// @param allowedList Array of booleans indicating whether the target address is user approved.
    function batchUserApprove(address[] calldata targetList, bool[] calldata allowedList) external;

    /// Gets all authorized addresses.
    /// @return Array of authorized addresses.
    function getAuthorizedAddresses() external view returns (address[] memory);

    /// Gets all user approved addresses.
    /// @return Array of user approved addresses.
    function getUserApprovedAddresses() external view returns (address[] memory);

    /// Checks whether the user has enough deposit.
    /// @param token Token address.
    /// @param user User address.
    /// @param amount Token amount.
    /// @param data Additional token data (e.g. tokenId for ERC721).
    /// @return Whether the user has enough deposit.
    function hasDeposit(address token, address user, uint256 amount, bytes calldata data) external view returns (bool);

    /// Checks token balance available to use (including user deposit amount + user approved allowance amount).
    /// @param token Token address.
    /// @param user User address.
    /// @param data Additional token data (e.g. tokenId for ERC721).
    /// @return Token amount available.
    function getAvailable(address token, address user, bytes calldata data) external view returns (uint256);

    /// Gets balance of user's deposit.
    /// @param token Token address.
    /// @param user User address.
    /// @return Token deposit amount.
    function balanceOf(address token, address user) external view returns (uint256);

    /// Deposits token from user wallet to bank.
    /// @param token Token address.
    /// @param user User address (allows third-party give tokens to any users).
    /// @param amount Token amount.
    /// @param data Additional token data (e.g. tokenId for ERC721).
    function deposit(address token, address user, uint256 amount, bytes calldata data) external payable;

    /// Withdraws token from bank to user wallet.
    /// @param token Token address.
    /// @param amount Token amount.
    /// @param data Additional token data (e.g. tokenId for ERC721).
    function withdraw(address token, uint256 amount, bytes calldata data) external;

    /// Transfers token from one address to another address.
    /// Only caller who are double-approved by both bank owner and token owner can invoke this function.
    /// @param token Token address.
    /// @param from The current token owner address.
    /// @param to The new token owner address.
    /// @param amount Token amount.
    /// @param data Additional token data (e.g. tokenId for ERC721).
    /// @param fromDeposit True if use fund from bank deposit. False if use fund from user wallet.
    /// @param toDeposit True if deposit fund to bank deposit. False if send fund to user wallet.
    function transferFrom(
        address token,
        address from,
        address to,
        uint256 amount,
        bytes calldata data,
        bool fromDeposit,
        bool toDeposit
    )
    external;
}

// File: contracts/bank/BankUtil.sol

pragma solidity ^0.5.7;


/// Bank utility tools to query values by batch. (DeltaBalances alternative)
contract BankUtil {

    /// Gets multiple token deposit balances in a single request.
    /// @param bankAddr Bank address.
    /// @param user User address.
    /// @param tokens Array of token addresses.
    /// @return balances Array of token deposit balances.
    function depositedBalances(address bankAddr, address user, address[] calldata tokens) external view returns (uint[] memory balances) {
        balances = new uint[](tokens.length);
        IBank bank = IBank(bankAddr);
        for (uint i = 0; i < tokens.length; i++) {
            balances[i] = bank.balanceOf(tokens[i], user);
        }
        return balances;
    }
}