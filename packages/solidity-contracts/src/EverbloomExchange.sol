/**
 * Source Code first verified at https://etherscan.io on Friday, May 3, 2019
 (UTC) */

// File: contracts/lib/LibBytes.sol

pragma solidity ^0.5.7;

// Modified from 0x LibBytes
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
library LibBytes {

    using LibBytes for bytes;

    /// @dev Gets the memory address for the contents of a byte array.
    /// @param input Byte array to lookup.
    /// @return memoryAddress Memory address of the contents of the byte array.
    function contentAddress(bytes memory input)
    internal
    pure
    returns (uint256 memoryAddress)
    {
        assembly {
            memoryAddress := add(input, 32)
        }
        return memoryAddress;
    }

    /// @dev Copies `length` bytes from memory location `source` to `dest`.
    /// @param dest memory address to copy bytes to.
    /// @param source memory address to copy bytes from.
    /// @param length number of bytes to copy.
    function memCopy(
        uint256 dest,
        uint256 source,
        uint256 length
    )
    internal
    pure
    {
        if (length < 32) {
            // Handle a partial word by reading destination and masking
            // off the bits we are interested in.
            // This correctly handles overlap, zero lengths and source == dest
            assembly {
                let mask := sub(exp(256, sub(32, length)), 1)
                let s := and(mload(source), not(mask))
                let d := and(mload(dest), mask)
                mstore(dest, or(s, d))
            }
        } else {
            // Skip the O(length) loop when source == dest.
            if (source == dest) {
                return;
            }

            // For large copies we copy whole words at a time. The final
            // word is aligned to the end of the range (instead of after the
            // previous) to handle partial words. So a copy will look like this:
            //
            //  ####
            //      ####
            //          ####
            //            ####
            //
            // We handle overlap in the source and destination range by
            // changing the copying direction. This prevents us from
            // overwriting parts of source that we still need to copy.
            //
            // This correctly handles source == dest
            //
            if (source > dest) {
                assembly {
                // We subtract 32 from `sEnd` and `dEnd` because it
                // is easier to compare with in the loop, and these
                // are also the addresses we need for copying the
                // last bytes.
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                // Remember the last 32 bytes of source
                // This needs to be done here and not after the loop
                // because we may have overwritten the last bytes in
                // source already due to overlap.
                    let last := mload(sEnd)

                // Copy whole words front to back
                // Note: the first check is always true,
                // this could have been a do-while loop.
                // solhint-disable-next-line no-empty-blocks
                    for {} lt(source, sEnd) {} {
                        mstore(dest, mload(source))
                        source := add(source, 32)
                        dest := add(dest, 32)
                    }

                // Write the last 32 bytes
                    mstore(dEnd, last)
                }
            } else {
                assembly {
                // We subtract 32 from `sEnd` and `dEnd` because those
                // are the starting points when copying a word at the end.
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                // Remember the first 32 bytes of source
                // This needs to be done here and not after the loop
                // because we may have overwritten the first bytes in
                // source already due to overlap.
                    let first := mload(source)

                // Copy whole words back to front
                // We use a signed comparisson here to allow dEnd to become
                // negative (happens when source and dest < 32). Valid
                // addresses in local memory will never be larger than
                // 2**255, so they can be safely re-interpreted as signed.
                // Note: the first check is always true,
                // this could have been a do-while loop.
                // solhint-disable-next-line no-empty-blocks
                    for {} slt(dest, dEnd) {} {
                        mstore(dEnd, mload(sEnd))
                        sEnd := sub(sEnd, 32)
                        dEnd := sub(dEnd, 32)
                    }

                // Write the first 32 bytes
                    mstore(dest, first)
                }
            }
        }
    }

    /// @dev Returns a slices from a byte array.
    /// @param b The byte array to take a slice from.
    /// @param from The starting index for the slice (inclusive).
    /// @param to The final index for the slice (exclusive).
    /// @return result The slice containing bytes at indices [from, to)
    function slice(
        bytes memory b,
        uint256 from,
        uint256 to
    )
    internal
    pure
    returns (bytes memory result)
    {
        if (from > to || to > b.length) {
            return "";
        }

        // Create a new bytes structure and copy contents
        result = new bytes(to - from);
        memCopy(
            result.contentAddress(),
            b.contentAddress() + from,
            result.length
        );
        return result;
    }

    /// @dev Reads an address from a position in a byte array.
    /// @param b Byte array containing an address.
    /// @param index Index in byte array of address.
    /// @return address from byte array.
    function readAddress(
        bytes memory b,
        uint256 index
    )
    internal
    pure
    returns (address result)
    {
        require(
            b.length >= index + 20,  // 20 is length of address
            "GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED"
        );

        // Add offset to index:
        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)
        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)
        index += 20;

        // Read address from array memory
        assembly {
        // 1. Add index to address of bytes array
        // 2. Load 32-byte word from memory
        // 3. Apply 20-byte mask to obtain address
            result := and(mload(add(b, index)), 0xffffffffffffffffffffffffffffffffffffffff)
        }
        return result;
    }

    /// @dev Reads a bytes32 value from a position in a byte array.
    /// @param b Byte array containing a bytes32 value.
    /// @param index Index in byte array of bytes32 value.
    /// @return bytes32 value from byte array.
    function readBytes32(
        bytes memory b,
        uint256 index
    )
    internal
    pure
    returns (bytes32 result)
    {
        require(
            b.length >= index + 32,
            "GREATER_OR_EQUAL_TO_32_LENGTH_REQUIRED"
        );

        // Arrays are prefixed by a 256 bit length parameter
        index += 32;

        // Read the bytes32 from array memory
        assembly {
            result := mload(add(b, index))
        }
        return result;
    }

    /// @dev Reads a uint256 value from a position in a byte array.
    /// @param b Byte array containing a uint256 value.
    /// @param index Index in byte array of uint256 value.
    /// @return uint256 value from byte array.
    function readUint256(
        bytes memory b,
        uint256 index
    )
    internal
    pure
    returns (uint256 result)
    {
        result = uint256(readBytes32(b, index));
        return result;
    }

    /// @dev Reads an unpadded bytes4 value from a position in a byte array.
    /// @param b Byte array containing a bytes4 value.
    /// @param index Index in byte array of bytes4 value.
    /// @return bytes4 value from byte array.
    function readBytes4(
        bytes memory b,
        uint256 index
    )
    internal
    pure
    returns (bytes4 result)
    {
        require(
            b.length >= index + 4,
            "GREATER_OR_EQUAL_TO_4_LENGTH_REQUIRED"
        );

        // Arrays are prefixed by a 32 byte length field
        index += 32;

        // Read the bytes4 from array memory
        assembly {
            result := mload(add(b, index))
        // Solidity does not require us to clean the trailing bytes.
        // We do it anyway
            result := and(result, 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000)
        }
        return result;
    }
}

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
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a9dbccc4cac6e99b">[email protected]</a>π.com>, Eenae <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="8dece1e8f5e8f4cde0e4f5eff4f9e8fea3e4e2">[email protected]</a>>
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

// File: contracts/Common.sol

pragma solidity ^0.5.7;

contract Common {
    struct Order {
        address maker;
        address taker;
        address makerToken;
        address takerToken;
        address makerTokenBank;
        address takerTokenBank;
        address reseller;
        address verifier;
        uint256 makerAmount;
        uint256 takerAmount;
        uint256 expires;
        uint256 nonce;
        uint256 minimumTakerAmount;
        bytes makerData;
        bytes takerData;
        bytes signature;
    }

    struct OrderInfo {
        uint8 orderStatus;
        bytes32 orderHash;
        uint256 filledTakerAmount;
    }

    struct FillResults {
        uint256 makerFilledAmount;
        uint256 makerFeeExchange;
        uint256 makerFeeReseller;
        uint256 takerFilledAmount;
        uint256 takerFeeExchange;
        uint256 takerFeeReseller;
    }

    struct MatchedFillResults {
        FillResults left;
        FillResults right;
        uint256 spreadAmount;
    }
}

// File: contracts/verifier/Verifier.sol

pragma solidity ^0.5.7;


/// An abstract Contract of Verifier.
contract Verifier is Common {

    /// Verifies trade for KYC purposes.
    /// @param order Order object.
    /// @param takerAmountToFill Desired amount of takerToken to sell.
    /// @param taker Taker address.
    /// @return Whether the trade is valid.
    function verify(
        Order memory order,
        uint256 takerAmountToFill,
        address taker
    )
    public
    view
    returns (bool);

    /// Verifies user address for KYC purposes.
    /// @param user User address.
    /// @return Whether the user address is valid.
    function verifyUser(address user)
    external
    view
    returns (bool);
}

// File: contracts/EverbloomExchange.sol

pragma solidity ^0.5.7;
pragma experimental ABIEncoderV2;








/// Everbloom core exchange contract.
contract EverbloomExchange is Ownable, ReentrancyGuard, LibMath {

    using LibBytes for bytes;

    // All fees cannot beyond this percentage.
    uint256 public constant MAX_FEE_PERCENTAGE = 0.005 * 10 ** 18; // 0.5%

    // Exchange fee account.
    address public feeAccount;

    // Exchange fee schedule.
    // fees[reseller][0] is maker fee charged by exchange.
    // fees[reseller][1] is maker fee charged by reseller.
    // fees[reseller][2] is taker fee charged by exchange.
    // fees[reseller][3] is taker fee charged by reseller.
    // fees[0][0] is default maker fee charged by exchange if no reseller.
    // fees[0][1] is always 0 if no reseller.
    // fees[0][2] is default taker fee charged by exchange if no reseller.
    // fees[0][3] is always 0 if no reseller.
    mapping(address => uint256[4]) public fees;

    // Mapping of order filled amounts.
    // filled[orderHash] = filledAmount
    mapping(bytes32 => uint256) filled;

    // Mapping of cancelled orders.
    // cancelled[orderHash] = isCancelled
    mapping(bytes32 => bool) cancelled;

    // Mapping of different types of whitelists.
    // whitelists[whitelistType][address] = isAllowed
    mapping(uint8 => mapping(address => bool)) whitelists;

    enum WhitelistType {
        BANK,
        FEE_EXEMPT_BANK, // No percentage fees for non-dividable tokens.
        RESELLER,
        VERIFIER
    }

    enum OrderStatus {
        INVALID,
        INVALID_SIGNATURE,
        INVALID_MAKER_AMOUNT,
        INVALID_TAKER_AMOUNT,
        FILLABLE,
        EXPIRED,
        FULLY_FILLED,
        CANCELLED
    }

    event SetFeeAccount(address feeAccount);
    event SetFee(address reseller, uint256 makerFee, uint256 takerFee);
    event SetWhitelist(uint8 wlType, address addr, bool allowed);
    event CancelOrder(
        bytes32 indexed orderHash,
        address indexed maker,
        address makerToken,
        address takerToken,
        address indexed reseller,
        uint256 makerAmount,
        uint256 takerAmount,
        bytes makerData,
        bytes takerData
    );
    event FillOrder(
        bytes32 indexed orderHash,
        address indexed maker,
        address taker,
        address makerToken,
        address takerToken,
        address indexed reseller,
        uint256 makerFilledAmount,
        uint256 makerFeeExchange,
        uint256 makerFeeReseller,
        uint256 takerFilledAmount,
        uint256 takerFeeExchange,
        uint256 takerFeeReseller,
        bytes makerData,
        bytes takerData
    );

    /// Sets fee account. Only contract owner can call this function.
    /// @param _feeAccount Fee account address.
    function setFeeAccount(
        address _feeAccount
    )
    public
    onlyOwner
    {
        feeAccount = _feeAccount;
        emit SetFeeAccount(_feeAccount);
    }

    /// Sets fee schedule. Only contract owner can call this function.
    /// Each fee is a fraction of 1 ETH in wei.
    /// @param reseller Reseller address.
    /// @param _fees Array of four fees: makerFeeExchange, makerFeeReseller, takerFeeExchange, takerFeeReseller.
    function setFee(
        address reseller,
        uint256[4] calldata _fees
    )
    external
    onlyOwner
    {
        if (reseller == address(0)) {
            // If reseller is not set, reseller fee should not be set.
            require(_fees[1] == 0 && _fees[3] == 0, "INVALID_NULL_RESELLER_FEE");
        }
        uint256 makerFee = add(_fees[0], _fees[1]);
        uint256 takerFee = add(_fees[2], _fees[3]);
        // Total fees of an order should not beyond MAX_FEE_PERCENTAGE.
        require(add(makerFee, takerFee) <= MAX_FEE_PERCENTAGE, "FEE_TOO_HIGH");
        fees[reseller] = _fees;
        emit SetFee(reseller, makerFee, takerFee);
    }

    /// Sets address whitelist. Only contract owner can call this function.
    /// @param wlType Whitelist type (defined in enum WhitelistType, e.g. BANK).
    /// @param addr An address (e.g. a trusted bank address).
    /// @param allowed Whether the address is trusted.
    function setWhitelist(
        WhitelistType wlType,
        address addr,
        bool allowed
    )
    external
    onlyOwner
    {
        whitelists[uint8(wlType)][addr] = allowed;
        emit SetWhitelist(uint8(wlType), addr, allowed);
    }

    /// Cancels an order. Only order maker can call this function.
    /// @param order Order object.
    function cancelOrder(
        Common.Order memory order
    )
    public
    nonReentrant
    {
        cancelOrderInternal(order);
    }

    /// Cancels multiple orders by batch. Only order maker can call this function.
    /// @param orderList Array of order objects.
    function cancelOrders(
        Common.Order[] memory orderList
    )
    public
    nonReentrant
    {
        for (uint256 i = 0; i < orderList.length; i++) {
            cancelOrderInternal(orderList[i]);
        }
    }

    /// Fills an order.
    /// @param order Order object.
    /// @param takerAmountToFill Desired amount of takerToken to sell.
    /// @param allowInsufficient Whether insufficient order remaining is allowed to fill.
    /// @return results Amounts filled and fees paid by maker and taker.
    function fillOrder(
        Common.Order memory order,
        uint256 takerAmountToFill,
        bool allowInsufficient
    )
    public
    nonReentrant
    returns (Common.FillResults memory results)
    {
        results = fillOrderInternal(
            order,
            takerAmountToFill,
            allowInsufficient
        );
        return results;
    }

    /// Fills an order without throwing an exception.
    /// @param order Order object.
    /// @param takerAmountToFill Desired amount of takerToken to sell.
    /// @param allowInsufficient Whether insufficient order remaining is allowed to fill.
    /// @return results Amounts filled and fees paid by maker and taker.
    function fillOrderNoThrow(
        Common.Order memory order,
        uint256 takerAmountToFill,
        bool allowInsufficient
    )
    public
    returns (Common.FillResults memory results)
    {
        bytes memory callData = abi.encodeWithSelector(
            this.fillOrder.selector,
            order,
            takerAmountToFill,
            allowInsufficient
        );
        assembly {
            // Use raw assembly call to fill order and avoid EVM reverts.
            let success := delegatecall(
                gas,                // forward all gas.
                address,            // call address of this contract.
                add(callData, 32),  // pointer to start of input (skip array length in first 32 bytes).
                mload(callData),    // length of input.
                callData,           // write output over input.
                192                 // output size is 192 bytes.
            )
            // Copy output data.
            if success {
                mstore(results, mload(callData))
                mstore(add(results, 32), mload(add(callData, 32)))
                mstore(add(results, 64), mload(add(callData, 64)))
                mstore(add(results, 96), mload(add(callData, 96)))
                mstore(add(results, 128), mload(add(callData, 128)))
                mstore(add(results, 160), mload(add(callData, 160)))
            }
        }
        return results;
    }

    /// Fills multiple orders by batch.
    /// @param orderList Array of order objects.
    /// @param takerAmountToFillList Array of desired amounts of takerToken to sell.
    /// @param allowInsufficientList Array of booleans that whether insufficient order remaining is allowed to fill.
    function fillOrders(
        Common.Order[] memory orderList,
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

    /// Fills multiple orders by batch without throwing an exception.
    /// @param orderList Array of order objects.
    /// @param takerAmountToFillList Array of desired amounts of takerToken to sell.
    /// @param allowInsufficientList Array of booleans that whether insufficient order remaining is allowed to fill.
    function fillOrdersNoThrow(
        Common.Order[] memory orderList,
        uint256[] memory takerAmountToFillList,
        bool[] memory allowInsufficientList
    )
    public
    nonReentrant
    {
        for (uint256 i = 0; i < orderList.length; i++) {
            fillOrderNoThrow(
                orderList[i],
                takerAmountToFillList[i],
                allowInsufficientList[i]
            );
        }
    }

    /// Match two complementary orders that have a profitable spread.
    /// NOTE: (leftOrder.makerAmount / leftOrder.takerAmount) should be always greater than or equal to
    /// (rightOrder.takerAmount / rightOrder.makerAmount).
    /// @param leftOrder First order object to match.
    /// @param rightOrder Second order object to match.
    /// @param spreadReceiver Address to receive a profitable spread.
    /// @param results Fill results of matched orders and spread amount.
    function matchOrders(
        Common.Order memory leftOrder,
        Common.Order memory rightOrder,
        address spreadReceiver
    )
    public
    nonReentrant
    returns (Common.MatchedFillResults memory results)
    {
        // Matching orders pre-check.
        require(
            leftOrder.makerToken == rightOrder.takerToken &&
            leftOrder.takerToken == rightOrder.makerToken &&
            mul(leftOrder.makerAmount, rightOrder.makerAmount) >= mul(leftOrder.takerAmount, rightOrder.takerAmount),
            "UNMATCHED_ORDERS"
        );
        Common.OrderInfo memory leftOrderInfo = getOrderInfo(leftOrder);
        Common.OrderInfo memory rightOrderInfo = getOrderInfo(rightOrder);
        results = calculateMatchedFillResults(
            leftOrder,
            rightOrder,
            leftOrderInfo.filledTakerAmount,
            rightOrderInfo.filledTakerAmount
        );
        assertFillableOrder(
            leftOrder,
            leftOrderInfo,
            msg.sender,
            results.left.takerFilledAmount
        );
        assertFillableOrder(
            rightOrder,
            rightOrderInfo,
            msg.sender,
            results.right.takerFilledAmount
        );
        settleMatchedOrders(leftOrder, rightOrder, results, spreadReceiver);
        filled[leftOrderInfo.orderHash] = add(leftOrderInfo.filledTakerAmount, results.left.takerFilledAmount);
        filled[rightOrderInfo.orderHash] = add(rightOrderInfo.filledTakerAmount, results.right.takerFilledAmount);
        emitFillOrderEvent(leftOrderInfo.orderHash, leftOrder, results.left);
        emitFillOrderEvent(rightOrderInfo.orderHash, rightOrder, results.right);
        return results;
    }

    /// Given a list of orders, fill them in sequence until total taker amount is reached.
    /// NOTE: All orders should be in the same token pair.
    /// @param orderList Array of order objects.
    /// @param totalTakerAmountToFill Stop filling when the total taker amount is reached.
    /// @return totalFillResults Total amounts filled and fees paid by maker and taker.
    function marketTakerOrders(
        Common.Order[] memory orderList,
        uint256 totalTakerAmountToFill
    )
    public
    returns (Common.FillResults memory totalFillResults)
    {
        for (uint256 i = 0; i < orderList.length; i++) {
            Common.FillResults memory singleFillResults = fillOrderNoThrow(
                orderList[i],
                sub(totalTakerAmountToFill, totalFillResults.takerFilledAmount),
                true
            );
            addFillResults(totalFillResults, singleFillResults);
            if (totalFillResults.takerFilledAmount >= totalTakerAmountToFill) {
                break;
            }
        }
        return totalFillResults;
    }

    /// Given a list of orders, fill them in sequence until total maker amount is reached.
    /// NOTE: All orders should be in the same token pair.
    /// @param orderList Array of order objects.
    /// @param totalMakerAmountToFill Stop filling when the total maker amount is reached.
    /// @return totalFillResults Total amounts filled and fees paid by maker and taker.
    function marketMakerOrders(
        Common.Order[] memory orderList,
        uint256 totalMakerAmountToFill
    )
    public
    returns (Common.FillResults memory totalFillResults)
    {
        for (uint256 i = 0; i < orderList.length; i++) {
            Common.FillResults memory singleFillResults = fillOrderNoThrow(
                orderList[i],
                getPartialAmountFloor(
                    orderList[i].takerAmount, orderList[i].makerAmount,
                    sub(totalMakerAmountToFill, totalFillResults.makerFilledAmount)
                ),
                true
            );
            addFillResults(totalFillResults, singleFillResults);
            if (totalFillResults.makerFilledAmount >= totalMakerAmountToFill) {
                break;
            }
        }
        return totalFillResults;
    }

    /// Gets information about an order.
    /// @param order Order object.
    /// @return orderInfo Information about the order status, order hash, and filled amount.
    function getOrderInfo(Common.Order memory order)
    public
    view
    returns (Common.OrderInfo memory orderInfo)
    {
        orderInfo.orderHash = getOrderHash(order);
        orderInfo.filledTakerAmount = filled[orderInfo.orderHash];
        if (
            !whitelists[uint8(WhitelistType.RESELLER)][order.reseller] ||
            !whitelists[uint8(WhitelistType.VERIFIER)][order.verifier] ||
            !whitelists[uint8(WhitelistType.BANK)][order.makerTokenBank] ||
            !whitelists[uint8(WhitelistType.BANK)][order.takerTokenBank]
        ) {
            orderInfo.orderStatus = uint8(OrderStatus.INVALID);
            return orderInfo;
        }

        if (!isValidSignature(orderInfo.orderHash, order.maker, order.signature)) {
            orderInfo.orderStatus = uint8(OrderStatus.INVALID_SIGNATURE);
            return orderInfo;
        }

        if (order.makerAmount == 0) {
            orderInfo.orderStatus = uint8(OrderStatus.INVALID_MAKER_AMOUNT);
            return orderInfo;
        }
        if (order.takerAmount == 0) {
            orderInfo.orderStatus = uint8(OrderStatus.INVALID_TAKER_AMOUNT);
            return orderInfo;
        }
        if (orderInfo.filledTakerAmount >= order.takerAmount) {
            orderInfo.orderStatus = uint8(OrderStatus.FULLY_FILLED);
            return orderInfo;
        }
        // solhint-disable-next-line not-rely-on-time
        if (block.timestamp >= order.expires) {
            orderInfo.orderStatus = uint8(OrderStatus.EXPIRED);
            return orderInfo;
        }
        if (cancelled[orderInfo.orderHash]) {
            orderInfo.orderStatus = uint8(OrderStatus.CANCELLED);
            return orderInfo;
        }
        orderInfo.orderStatus = uint8(OrderStatus.FILLABLE);
        return orderInfo;
    }

    /// Calculates hash of an order.
    /// @param order Order object.
    /// @return Hash of order.
    function getOrderHash(Common.Order memory order)
    public
    view
    returns (bytes32)
    {
        bytes memory part1 = abi.encodePacked(
            address(this),
            order.maker,
            order.taker,
            order.makerToken,
            order.takerToken,
            order.makerTokenBank,
            order.takerTokenBank,
            order.reseller,
            order.verifier
        );
        bytes memory part2 = abi.encodePacked(
            order.makerAmount,
            order.takerAmount,
            order.expires,
            order.nonce,
            order.minimumTakerAmount,
            order.makerData,
            order.takerData
        );
        return keccak256(abi.encodePacked(part1, part2));
    }

    /// Cancels an order.
    /// @param order Order object.
    function cancelOrderInternal(
        Common.Order memory order
    )
    internal
    {
        Common.OrderInfo memory orderInfo = getOrderInfo(order);
        require(orderInfo.orderStatus == uint8(OrderStatus.FILLABLE), "ORDER_UNFILLABLE");
        require(order.maker == msg.sender, "INVALID_MAKER");
        cancelled[orderInfo.orderHash] = true;
        emit CancelOrder(
            orderInfo.orderHash,
            order.maker,
            order.makerToken,
            order.takerToken,
            order.reseller,
            order.makerAmount,
            order.takerAmount,
            order.makerData,
            order.takerData
        );
    }

    /// Fills an order.
    /// @param order Order object.
    /// @param takerAmountToFill Desired amount of takerToken to sell.
    /// @param allowInsufficient Whether insufficient order remaining is allowed to fill.
    /// @return results Amounts filled and fees paid by maker and taker.
    function fillOrderInternal(
        Common.Order memory order,
        uint256 takerAmountToFill,
        bool allowInsufficient
    )
    internal
    returns (Common.FillResults memory results)
    {
        require(takerAmountToFill > 0, "INVALID_TAKER_AMOUNT");
        Common.OrderInfo memory orderInfo = getOrderInfo(order);
        uint256 remainingTakerAmount = sub(order.takerAmount, orderInfo.filledTakerAmount);
        if (allowInsufficient) {
            takerAmountToFill = min(takerAmountToFill, remainingTakerAmount);
        } else {
            require(takerAmountToFill <= remainingTakerAmount, "INSUFFICIENT_ORDER_REMAINING");
        }
        assertFillableOrder(
            order,
            orderInfo,
            msg.sender,
            takerAmountToFill
        );
        results = settleOrder(order, takerAmountToFill);
        filled[orderInfo.orderHash] = add(orderInfo.filledTakerAmount, results.takerFilledAmount);
        emitFillOrderEvent(orderInfo.orderHash, order, results);
        return results;
    }

    /// Emits a FillOrder event.
    /// @param orderHash Hash of order.
    /// @param order Order object.
    /// @param results Order fill results.
    function emitFillOrderEvent(
        bytes32 orderHash,
        Common.Order memory order,
        Common.FillResults memory results
    )
    internal
    {
        emit FillOrder(
            orderHash,
            order.maker,
            msg.sender,
            order.makerToken,
            order.takerToken,
            order.reseller,
            results.makerFilledAmount,
            results.makerFeeExchange,
            results.makerFeeReseller,
            results.takerFilledAmount,
            results.takerFeeExchange,
            results.takerFeeReseller,
            order.makerData,
            order.takerData
        );
    }

    /// Validates context for fillOrder. Succeeds or throws.
    /// @param order Order object to be filled.
    /// @param orderInfo Information about the order status, order hash, and amount already filled of order.
    /// @param taker Address of order taker.
    /// @param takerAmountToFill Desired amount of takerToken to sell.
    function assertFillableOrder(
        Common.Order memory order,
        Common.OrderInfo memory orderInfo,
        address taker,
        uint256 takerAmountToFill
    )
    view
    internal
    {
        // An order can only be filled if its status is FILLABLE.
        require(orderInfo.orderStatus == uint8(OrderStatus.FILLABLE), "ORDER_UNFILLABLE");

        // Validate taker is allowed to fill this order.
        if (order.taker != address(0)) {
            require(order.taker == taker, "INVALID_TAKER");
        }

        // Validate minimum taker amount.
        if (order.minimumTakerAmount > 0) {
            require(takerAmountToFill >= order.minimumTakerAmount, "ORDER_MINIMUM_UNREACHED");
        }

        // Go through Verifier.
        if (order.verifier != address(0)) {
            require(Verifier(order.verifier).verify(order, takerAmountToFill, msg.sender), "FAILED_VALIDATION");
        }
    }

    /// Verifies that an order signature is valid.
    /// @param hash Message hash that is signed.
    /// @param signer Address of signer.
    /// @param signature Order signature.
    /// @return Validity of order signature.
    function isValidSignature(
        bytes32 hash,
        address signer,
        bytes memory signature
    )
    internal
    pure
    returns (bool)
    {
        uint8 v = uint8(signature[0]);
        bytes32 r = signature.readBytes32(1);
        bytes32 s = signature.readBytes32(33);
        return signer == ecrecover(
            keccak256(abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                hash
            )),
            v,
            r,
            s
        );
    }

    /// Adds properties of a single FillResults to total FillResults.
    /// @param totalFillResults Fill results instance that will be added onto.
    /// @param singleFillResults Fill results instance that will be added to totalFillResults.
    function addFillResults(
        Common.FillResults memory totalFillResults,
        Common.FillResults memory singleFillResults
    )
    internal
    pure
    {
        totalFillResults.makerFilledAmount = add(totalFillResults.makerFilledAmount, singleFillResults.makerFilledAmount);
        totalFillResults.makerFeeExchange = add(totalFillResults.makerFeeExchange, singleFillResults.makerFeeExchange);
        totalFillResults.makerFeeReseller = add(totalFillResults.makerFeeReseller, singleFillResults.makerFeeReseller);
        totalFillResults.takerFilledAmount = add(totalFillResults.takerFilledAmount, singleFillResults.takerFilledAmount);
        totalFillResults.takerFeeExchange = add(totalFillResults.takerFeeExchange, singleFillResults.takerFeeExchange);
        totalFillResults.takerFeeReseller = add(totalFillResults.takerFeeReseller, singleFillResults.takerFeeReseller);
    }

    /// Settles an order by swapping funds and paying fees.
    /// @param order Order object.
    /// @param takerAmountToFill Desired amount of takerToken to sell.
    /// @param results Amounts to be filled and fees paid by maker and taker.
    function settleOrder(
        Common.Order memory order,
        uint256 takerAmountToFill
    )
    internal
    returns (Common.FillResults memory results)
    {
        results.takerFilledAmount = takerAmountToFill;
        results.makerFilledAmount = safeGetPartialAmountFloor(order.makerAmount, order.takerAmount, results.takerFilledAmount);
        // Calculate maker fees if makerTokenBank is non-fee-exempt.
        if (!whitelists[uint8(WhitelistType.FEE_EXEMPT_BANK)][order.makerTokenBank]) {
            if (fees[order.reseller][0] > 0) {
                results.makerFeeExchange = mul(results.makerFilledAmount, fees[order.reseller][0]) / (1 ether);
            }
            if (fees[order.reseller][1] > 0) {
                results.makerFeeReseller = mul(results.makerFilledAmount, fees[order.reseller][1]) / (1 ether);
            }
        }
        // Calculate taker fees if takerTokenBank is non-fee-exempt.
        if (!whitelists[uint8(WhitelistType.FEE_EXEMPT_BANK)][order.takerTokenBank]) {
            if (fees[order.reseller][2] > 0) {
                results.takerFeeExchange = mul(results.takerFilledAmount, fees[order.reseller][2]) / (1 ether);
            }
            if (fees[order.reseller][3] > 0) {
                results.takerFeeReseller = mul(results.takerFilledAmount, fees[order.reseller][3]) / (1 ether);
            }
        }
        if (results.makerFeeExchange > 0) {
            // Transfer maker fee to exchange fee account.
            IBank(order.makerTokenBank).transferFrom(
                order.makerToken,
                order.maker,
                feeAccount,
                results.makerFeeExchange,
                order.makerData,
                true,
                false
            );
        }
        if (results.makerFeeReseller > 0) {
            // Transfer maker fee to reseller fee account.
            IBank(order.makerTokenBank).transferFrom(
                order.makerToken,
                order.maker,
                order.reseller,
                results.makerFeeReseller,
                order.makerData,
                true,
                false
            );
        }
        if (results.takerFeeExchange > 0) {
            // Transfer taker fee to exchange fee account.
            IBank(order.takerTokenBank).transferFrom(
                order.takerToken,
                msg.sender,
                feeAccount,
                results.takerFeeExchange,
                order.takerData,
                true,
                false
            );
        }
        if (results.takerFeeReseller > 0) {
            // Transfer taker fee to reseller fee account.
            IBank(order.takerTokenBank).transferFrom(
                order.takerToken,
                msg.sender,
                order.reseller,
                results.takerFeeReseller,
                order.takerData,
                true,
                false
            );
        }
        // Transfer tokens from maker to taker.
        IBank(order.makerTokenBank).transferFrom(
            order.makerToken,
            order.maker,
            msg.sender,
            results.makerFilledAmount,
            order.makerData,
            true,
            true
        );
        // Transfer tokens from taker to maker.
        IBank(order.takerTokenBank).transferFrom(
            order.takerToken,
            msg.sender,
            order.maker,
            results.takerFilledAmount,
            order.takerData,
            true,
            true
        );
    }

    /// Calculates fill amounts for matched orders that have a profitable spread.
    /// NOTE: (leftOrder.makerAmount / leftOrder.takerAmount) should be always greater than or equal to
    /// (rightOrder.takerAmount / rightOrder.makerAmount).
    /// @param leftOrder First order object to match.
    /// @param rightOrder Second order object to match.
    /// @param leftFilledTakerAmount Amount of left order already filled.
    /// @param rightFilledTakerAmount Amount of right order already filled.
    /// @param results Fill results of matched orders and spread amount.
    function calculateMatchedFillResults(
        Common.Order memory leftOrder,
        Common.Order memory rightOrder,
        uint256 leftFilledTakerAmount,
        uint256 rightFilledTakerAmount
    )
    internal
    view
    returns (Common.MatchedFillResults memory results)
    {
        uint256 leftRemainingTakerAmount = sub(leftOrder.takerAmount, leftFilledTakerAmount);
        uint256 leftRemainingMakerAmount = safeGetPartialAmountFloor(
            leftOrder.makerAmount,
            leftOrder.takerAmount,
            leftRemainingTakerAmount
        );
        uint256 rightRemainingTakerAmount = sub(rightOrder.takerAmount, rightFilledTakerAmount);
        uint256 rightRemainingMakerAmount = safeGetPartialAmountFloor(
            rightOrder.makerAmount,
            rightOrder.takerAmount,
            rightRemainingTakerAmount
        );

        if (leftRemainingTakerAmount >= rightRemainingMakerAmount) {
            // Case 1: Right order is fully filled.
            results.right.makerFilledAmount = rightRemainingMakerAmount;
            results.right.takerFilledAmount = rightRemainingTakerAmount;
            results.left.takerFilledAmount = results.right.makerFilledAmount;
            // Round down to ensure the maker's exchange rate does not exceed the price specified by the order.
            // We favor the maker when the exchange rate must be rounded.
            results.left.makerFilledAmount = safeGetPartialAmountFloor(
                leftOrder.makerAmount,
                leftOrder.takerAmount,
                results.left.takerFilledAmount
            );
        } else {
            // Case 2: Left order is fully filled.
            results.left.makerFilledAmount = leftRemainingMakerAmount;
            results.left.takerFilledAmount = leftRemainingTakerAmount;
            results.right.makerFilledAmount = results.left.takerFilledAmount;
            // Round up to ensure the maker's exchange rate does not exceed the price specified by the order.
            // We favor the maker when the exchange rate must be rounded.
            results.right.takerFilledAmount = safeGetPartialAmountCeil(
                rightOrder.takerAmount,
                rightOrder.makerAmount,
                results.right.makerFilledAmount
            );
        }
        results.spreadAmount = sub(
            results.left.makerFilledAmount,
            results.right.takerFilledAmount
        );
        if (!whitelists[uint8(WhitelistType.FEE_EXEMPT_BANK)][leftOrder.makerTokenBank]) {
            if (fees[leftOrder.reseller][0] > 0) {
                results.left.makerFeeExchange = mul(results.left.makerFilledAmount, fees[leftOrder.reseller][0]) / (1 ether);
            }
            if (fees[leftOrder.reseller][1] > 0) {
                results.left.makerFeeReseller = mul(results.left.makerFilledAmount, fees[leftOrder.reseller][1]) / (1 ether);
            }
        }
        if (!whitelists[uint8(WhitelistType.FEE_EXEMPT_BANK)][rightOrder.makerTokenBank]) {
            if (fees[rightOrder.reseller][2] > 0) {
                results.right.makerFeeExchange = mul(results.right.makerFilledAmount, fees[rightOrder.reseller][2]) / (1 ether);
            }
            if (fees[rightOrder.reseller][3] > 0) {
                results.right.makerFeeReseller = mul(results.right.makerFilledAmount, fees[rightOrder.reseller][3]) / (1 ether);
            }
        }
        return results;
    }

    /// Settles matched order by swapping funds, paying fees and transferring spread.
    /// @param leftOrder First matched order object.
    /// @param rightOrder Second matched order object.
    /// @param results Fill results of matched orders and spread amount.
    /// @param spreadReceiver Address to receive a profitable spread.
    function settleMatchedOrders(
        Common.Order memory leftOrder,
        Common.Order memory rightOrder,
        Common.MatchedFillResults memory results,
        address spreadReceiver
    )
    internal
    {
        if (results.left.makerFeeExchange > 0) {
            // Transfer left maker fee to exchange fee account.
            IBank(leftOrder.makerTokenBank).transferFrom(
                leftOrder.makerToken,
                leftOrder.maker,
                feeAccount,
                results.left.makerFeeExchange,
                leftOrder.makerData,
                true,
                false
            );
        }
        if (results.left.makerFeeReseller > 0) {
            // Transfer left maker fee to reseller fee account.
            IBank(leftOrder.makerTokenBank).transferFrom(
                leftOrder.makerToken,
                leftOrder.maker,
                leftOrder.reseller,
                results.left.makerFeeReseller,
                leftOrder.makerData,
                true,
                false
            );
        }
        if (results.right.makerFeeExchange > 0) {
            // Transfer right maker fee to exchange fee account.
            IBank(rightOrder.makerTokenBank).transferFrom(
                rightOrder.makerToken,
                rightOrder.maker,
                feeAccount,
                results.right.makerFeeExchange,
                rightOrder.makerData,
                true,
                false
            );
        }
        if (results.right.makerFeeReseller > 0) {
            // Transfer right maker fee to reseller fee account.
            IBank(rightOrder.makerTokenBank).transferFrom(
                rightOrder.makerToken,
                rightOrder.maker,
                rightOrder.reseller,
                results.right.makerFeeReseller,
                rightOrder.makerData,
                true,
                false
            );
        }
        // Note that there's no taker fees for matched orders.

        // Transfer tokens from left order maker to right order maker.
        IBank(leftOrder.makerTokenBank).transferFrom(
            leftOrder.makerToken,
            leftOrder.maker,
            rightOrder.maker,
            results.right.takerFilledAmount,
            leftOrder.makerData,
            true,
            true
        );
        // Transfer tokens from right order maker to left order maker.
        IBank(rightOrder.makerTokenBank).transferFrom(
            rightOrder.makerToken,
            rightOrder.maker,
            leftOrder.maker,
            results.left.takerFilledAmount,
            rightOrder.makerData,
            true,
            true
        );
        if (results.spreadAmount > 0) {
            // Transfer spread to spread receiver.
            IBank(leftOrder.makerTokenBank).transferFrom(
                leftOrder.makerToken,
                leftOrder.maker,
                spreadReceiver,
                results.spreadAmount,
                leftOrder.makerData,
                true,
                false
            );
        }
    }
}