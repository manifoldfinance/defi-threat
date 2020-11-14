/**
 * Source Code first verified at https://etherscan.io on Friday, May 3, 2019
 (UTC) */

// File: contracts/lib/LibMath.sol

pragma solidity ^0.5.7;

contract LibMath {
    // Copied from openzeppelin Math
    /**
    * @dev Returns the largest of two numbers.
    */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
    * @dev Returns the smallest of two numbers.
    */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
    * @dev Calculates the average of two numbers. Since these are integers,
    * averages of an even and odd number cannot be represented, and will be
    * rounded down.
    */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }

    // Modified from openzeppelin SafeMath
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }

    // Copied from 0x LibMath
    /*
      Copyright 2018 ZeroEx Intl.
      Licensed under the Apache License, Version 2.0 (the "License");
      you may not use this file except in compliance with the License.
      You may obtain a copy of the License at
        http://www.apache.org/licenses/LICENSE-2.0
      Unless required by applicable law or agreed to in writing, software
      distributed under the License is distributed on an "AS IS" BASIS,
      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
      See the License for the specific language governing permissions and
      limitations under the License.
    */
    /// @dev Calculates partial value given a numerator and denominator rounded down.
    ///      Reverts if rounding error is >= 0.1%
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to calculate partial of.
    /// @return Partial value of target rounded down.
    function safeGetPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
    internal
    pure
    returns (uint256 partialAmount)
    {
        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        require(
            !isRoundingErrorFloor(
            numerator,
            denominator,
            target
        ),
            "ROUNDING_ERROR"
        );

        partialAmount = div(
            mul(numerator, target),
            denominator
        );
        return partialAmount;
    }

    /// @dev Calculates partial value given a numerator and denominator rounded down.
    ///      Reverts if rounding error is >= 0.1%
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to calculate partial of.
    /// @return Partial value of target rounded up.
    function safeGetPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
    internal
    pure
    returns (uint256 partialAmount)
    {
        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        require(
            !isRoundingErrorCeil(
            numerator,
            denominator,
            target
        ),
            "ROUNDING_ERROR"
        );

        partialAmount = div(
            add(
                mul(numerator, target),
                sub(denominator, 1)
            ),
            denominator
        );
        return partialAmount;
    }

    /// @dev Calculates partial value given a numerator and denominator rounded down.
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to calculate partial of.
    /// @return Partial value of target rounded down.
    function getPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
    internal
    pure
    returns (uint256 partialAmount)
    {
        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        partialAmount = div(
            mul(numerator, target),
            denominator
        );
        return partialAmount;
    }

    /// @dev Calculates partial value given a numerator and denominator rounded down.
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to calculate partial of.
    /// @return Partial value of target rounded up.
    function getPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
    internal
    pure
    returns (uint256 partialAmount)
    {
        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        partialAmount = div(
            add(
                mul(numerator, target),
                sub(denominator, 1)
            ),
            denominator
        );
        return partialAmount;
    }

    /// @dev Checks if rounding error >= 0.1% when rounding down.
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to multiply with numerator/denominator.
    /// @return Rounding error is present.
    function isRoundingErrorFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
    internal
    pure
    returns (bool isError)
    {
        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        // The absolute rounding error is the difference between the rounded
        // value and the ideal value. The relative rounding error is the
        // absolute rounding error divided by the absolute value of the
        // ideal value. This is undefined when the ideal value is zero.
        //
        // The ideal value is `numerator * target / denominator`.
        // Let's call `numerator * target % denominator` the remainder.
        // The absolute error is `remainder / denominator`.
        //
        // When the ideal value is zero, we require the absolute error to
        // be zero. Fortunately, this is always the case. The ideal value is
        // zero iff `numerator == 0` and/or `target == 0`. In this case the
        // remainder and absolute error are also zero.
        if (target == 0 || numerator == 0) {
            return false;
        }

        // Otherwise, we want the relative rounding error to be strictly
        // less than 0.1%.
        // The relative error is `remainder / (numerator * target)`.
        // We want the relative error less than 1 / 1000:
        //        remainder / (numerator * denominator)  <  1 / 1000
        // or equivalently:
        //        1000 * remainder  <  numerator * target
        // so we have a rounding error iff:
        //        1000 * remainder  >=  numerator * target
        uint256 remainder = mulmod(
            target,
            numerator,
            denominator
        );
        isError = mul(1000, remainder) >= mul(numerator, target);
        return isError;
    }

    /// @dev Checks if rounding error >= 0.1% when rounding up.
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to multiply with numerator/denominator.
    /// @return Rounding error is present.
    function isRoundingErrorCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
    internal
    pure
    returns (bool isError)
    {
        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        // See the comments in `isRoundingError`.
        if (target == 0 || numerator == 0) {
            // When either is zero, the ideal value and rounded value are zero
            // and there is no rounding error. (Although the relative error
            // is undefined.)
            return false;
        }
        // Compute remainder as before
        uint256 remainder = mulmod(
            target,
            numerator,
            denominator
        );
        remainder = sub(denominator, remainder) % denominator;
        isError = mul(1000, remainder) >= mul(numerator, target);
        return isError;
    }
}

// File: contracts/lib/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/lib/ReentrancyGuard.sol

pragma solidity ^0.5.0;

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a2d0c7cfc1cde290">[email protected]</a>π.com>, Eenae <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="fb9a979e839e82bb96928399828f9e88d59294">[email protected]</a>>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }
}

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

// File: contracts/router/IExchangeHandler.sol

pragma solidity ^0.5.7;

/// Interface of exchange handler.
interface IExchangeHandler {

    /// Gets maximum available amount can be spent on order (fee not included).
    /// @param data General order data.
    /// @return availableToFill Amount can be spent on order.
    /// @return feePercentage Fee percentage of order.
    function getAvailableToFill(
        bytes calldata data
    )
    external
    view
    returns (uint256 availableToFill, uint256 feePercentage);

    /// Fills an order on the target exchange.
    /// NOTE: The required funds must be transferred to this contract in the same transaction of calling this function.
    /// @param data General order data.
    /// @param takerAmountToFill Taker token amount to spend on order (fee not included).
    /// @return makerAmountReceived Amount received from trade.
    function fillOrder(
        bytes calldata data,
        uint256 takerAmountToFill
    )
    external
    payable
    returns (uint256 makerAmountReceived);
}

// File: contracts/router/RouterCommon.sol

pragma solidity ^0.5.7;

contract RouterCommon {
    struct GeneralOrder {
        address handler;
        address makerToken;
        address takerToken;
        uint256 makerAmount;
        uint256 takerAmount;
        bytes data;
    }

    struct FillResults {
        uint256 makerAmountReceived;
        uint256 takerAmountSpentOnOrder;
        uint256 takerAmountSpentOnFee;
    }
}

// File: contracts/router/ExchangeRouter.sol

pragma solidity ^0.5.7;
pragma experimental ABIEncoderV2;







// Interface of ERC20 approve function.
interface IERC20 {
    function approve(address spender, uint256 value) external returns (bool);
}

/// Router contract to support orders from different decentralized exchanges.
contract ExchangeRouter is Ownable, ReentrancyGuard, LibMath {

    IBank public bank;
    mapping(address => bool) public handlerWhitelist;

    event Handler(address handler, bool allowed);
    event FillOrder(
        bytes orderData,
        uint256 makerAmountReceived,
        uint256 takerAmountSpentOnOrder,
        uint256 takerAmountSpentOnFee
    );

    constructor(
        address _bank
    )
    public
    {
        bank = IBank(_bank);
    }

    /// Fallback function to receive ETH.
    function() external payable {}

    /// Sets a handler. Only contract owner can call this function.
    /// @param handler Handler address.
    /// @param allowed allowed Whether the handler address is trusted.
    function setHandler(
        address handler,
        bool allowed
    )
    external
    onlyOwner
    {
        handlerWhitelist[handler] = allowed;
        emit Handler(handler, allowed);
    }

    /// Fills an order.
    /// @param order General order object.
    /// @param takerAmountToFill Taker token amount to spend on order.
    /// @param allowInsufficient Whether insufficient order remaining is allowed to fill.
    /// @return results Amounts paid and received.
    function fillOrder(
        RouterCommon.GeneralOrder memory order,
        uint256 takerAmountToFill,
        bool allowInsufficient
    )
    public
    nonReentrant
    returns (RouterCommon.FillResults memory results)
    {
        results = fillOrderInternal(
            order,
                takerAmountToFill,
            allowInsufficient
        );
    }

    /// Fills multiple orders by batch.
    /// @param orderList Array of general order objects.
    /// @param takerAmountToFillList Array of taker token amounts to spend on order.
    /// @param allowInsufficientList Array of booleans that whether insufficient order remaining is allowed to fill.
    function fillOrders(
        RouterCommon.GeneralOrder[] memory orderList,
        uint256[] memory takerAmountToFillList,
        bool[] memory allowInsufficientList
    )
    public
    nonReentrant
    {
        for (uint256 i = 0; i < orderList.length; i++) {
            fillOrderInternal(
                orderList[i],
                takerAmountToFillList[i],
                allowInsufficientList[i]
            );
        }
    }

    /// Given a list of orders, fill them in sequence until total taker amount is reached.
    /// NOTE: All orders should be in the same token pair.
    /// @param orderList Array of general order objects.
    /// @param totalTakerAmountToFill Stop filling when the total taker amount is reached.
    /// @return totalFillResults Total amounts paid and received.
    function marketTakerOrders(
        RouterCommon.GeneralOrder[] memory orderList,
        uint256 totalTakerAmountToFill
    )
    public
    returns (RouterCommon.FillResults memory totalFillResults)
    {
        for (uint256 i = 0; i < orderList.length; i++) {
            RouterCommon.FillResults memory singleFillResults = fillOrderInternal(
                orderList[i],
                sub(totalTakerAmountToFill, totalFillResults.takerAmountSpentOnOrder),
                true
            );
            addFillResults(totalFillResults, singleFillResults);
            if (totalFillResults.takerAmountSpentOnOrder >= totalTakerAmountToFill) {
                break;
            }
        }
        return totalFillResults;
    }

    /// Given a list of orders, fill them in sequence until total maker amount is reached.
    /// NOTE: All orders should be in the same token pair.
    /// @param orderList Array of general order objects.
    /// @param totalMakerAmountToFill Stop filling when the total maker amount is reached.
    /// @return totalFillResults Total amounts paid and received.
    function marketMakerOrders(
        RouterCommon.GeneralOrder[] memory orderList,
        uint256 totalMakerAmountToFill
    )
    public
    returns (RouterCommon.FillResults memory totalFillResults)
    {
        for (uint256 i = 0; i < orderList.length; i++) {
            RouterCommon.FillResults memory singleFillResults = fillOrderInternal(
                orderList[i],
                getPartialAmountFloor(
                    orderList[i].takerAmount,
                    orderList[i].makerAmount,
                    sub(totalMakerAmountToFill, totalFillResults.makerAmountReceived)
                ),
                true
            );
            addFillResults(totalFillResults, singleFillResults);
            if (totalFillResults.makerAmountReceived >= totalMakerAmountToFill) {
                break;
            }
        }
        return totalFillResults;
    }

    /// Fills an order.
    /// @param order General order object.
    /// @param takerAmountToFill Taker token amount to spend on order.
    /// @param allowInsufficient Whether insufficient order remaining is allowed to fill.
    /// @return results Amounts paid and received.
    function fillOrderInternal(
        RouterCommon.GeneralOrder memory order,
        uint256 takerAmountToFill,
        bool allowInsufficient
    )
    internal
    returns (RouterCommon.FillResults memory results)
    {
        // Check if the handler is trusted.
        require(handlerWhitelist[order.handler], "HANDLER_IN_WHITELIST_REQUIRED");
        // Check order's availability.
        (uint256 availableToFill, uint256 feePercentage) = IExchangeHandler(order.handler).getAvailableToFill(order.data);

        if (allowInsufficient) {
            results.takerAmountSpentOnOrder = min(takerAmountToFill, availableToFill);
        } else {
            require(takerAmountToFill <= availableToFill, "INSUFFICIENT_ORDER_REMAINING");
            results.takerAmountSpentOnOrder = takerAmountToFill;
        }
        results.takerAmountSpentOnFee = mul(results.takerAmountSpentOnOrder, feePercentage) / (1 ether);
        if (results.takerAmountSpentOnOrder > 0) {
            // Transfer funds from bank deposit to corresponding handler.
            bank.transferFrom(
                order.takerToken,
                msg.sender,
                order.handler,
                add(results.takerAmountSpentOnOrder, results.takerAmountSpentOnFee),
                "",
                true,
                false
            );
            // Fill the order via handler.
            results.makerAmountReceived = IExchangeHandler(order.handler).fillOrder(
                order.data,
                results.takerAmountSpentOnOrder
            );
            if (results.makerAmountReceived > 0) {
                if (order.makerToken == address(0)) {
                    bank.deposit.value(results.makerAmountReceived)(
                        address(0),
                        msg.sender,
                        results.makerAmountReceived,
                        ""
                    );
                } else {
                    require(IERC20(order.makerToken).approve(address(bank), results.makerAmountReceived));
                    bank.deposit(
                        order.makerToken,
                        msg.sender,
                        results.makerAmountReceived,
                        ""
                    );
                }
            }
            emit FillOrder(
                order.data,
                results.makerAmountReceived,
                results.takerAmountSpentOnOrder,
                results.takerAmountSpentOnFee
            );
        }
    }

    /// @dev Adds properties of a single FillResults to total FillResults.
    /// @param totalFillResults Fill results instance that will be added onto.
    /// @param singleFillResults Fill results instance that will be added to totalFillResults.
    function addFillResults(
        RouterCommon.FillResults memory totalFillResults,
        RouterCommon.FillResults memory singleFillResults
    )
    internal
    pure
    {
        totalFillResults.makerAmountReceived = add(totalFillResults.makerAmountReceived, singleFillResults.makerAmountReceived);
        totalFillResults.takerAmountSpentOnOrder = add(totalFillResults.takerAmountSpentOnOrder, singleFillResults.takerAmountSpentOnOrder);
        totalFillResults.takerAmountSpentOnFee = add(totalFillResults.takerAmountSpentOnFee, singleFillResults.takerAmountSpentOnFee);
    }
}