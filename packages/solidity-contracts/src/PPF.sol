/**
 * Source Code first verified at https://etherscan.io on Thursday, April 25, 2019
 (UTC) */

// File: contracts/IFeed.sol

pragma solidity ^0.4.18;

interface IFeed {
    function get(address base, address quote) external view returns (uint128 xrt, uint64 when);
}

// File: contracts/open-zeppelin/ECRecovery.sol

pragma solidity 0.4.24;

// Using ECRecovery from <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="ed829d8883c097889d9d88818483ad8c89dcdfded5dcd8d9d48ed98edddadcdc8edf8bdededcdd88d48b8fdc8bdbd889d8dc8edfd4d48e">[email protected]</a> + added personalRecover function
// See https://github.com/OpenZeppelin/openzeppelin-solidity/blob/ad12381549c4c0711c2f3310e9fb1f65d51c299c/contracts/ECRecovery.sol

library ECRecovery {
  /**
   * @dev Recover signer address from a personal signed message by using his signature
   * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
   * @param sig bytes signature, the signature is generated using web3.personal.sign()
   */
  function personalRecover(bytes32 hash, bytes sig) internal pure returns (address) {
    return recover(toEthSignedMessageHash(hash), sig);
  }

  /**
   * @dev Recover signer address from a message by using his signature
   * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
   * @param sig bytes signature, the signature is generated using web3.eth.sign()
   */
  function recover(bytes32 hash, bytes sig) internal pure returns (address) {
    bytes32 r;
    bytes32 s;
    uint8 v;

    //Check the signature length
    if (sig.length != 65) {
      return (address(0));
    }

    // Divide the signature in r, s and v variables
    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := byte(0, mload(add(sig, 96)))
    }

    // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
    if (v < 27) {
      v += 27;
    }

    // If the version is correct return the signer address
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      return ecrecover(hash, v, r, s);
    }
  }

  /**
   * toEthSignedMessageHash
   * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:"
   * @dev and hash the result
   */
  function toEthSignedMessageHash(bytes32 hash)
    internal
    pure
    returns (bytes32)
  {
    // 32 is the length in bytes of hash,
    // enforced by the type signature above
    return keccak256(abi.encodePacked(
      "\x19Ethereum Signed Message:\n32",
      hash
    ));
  }
}

// File: @aragon/os/contracts/common/Uint256Helpers.sol

pragma solidity ^0.4.24;


library Uint256Helpers {
    uint256 private constant MAX_UINT64 = uint64(-1);

    string private constant ERROR_NUMBER_TOO_BIG = "UINT64_NUMBER_TOO_BIG";

    function toUint64(uint256 a) internal pure returns (uint64) {
        require(a <= MAX_UINT64, ERROR_NUMBER_TOO_BIG);
        return uint64(a);
    }
}

// File: @aragon/os/contracts/common/TimeHelpers.sol

/*
 * SPDX-License-Identitifer:    MIT
 */

pragma solidity ^0.4.24;



contract TimeHelpers {
    using Uint256Helpers for uint256;

    /**
    * @dev Returns the current block number.
    *      Using a function rather than `block.number` allows us to easily mock the block number in
    *      tests.
    */
    function getBlockNumber() internal view returns (uint256) {
        return block.number;
    }

    /**
    * @dev Returns the current block number, converted to uint64.
    *      Using a function rather than `block.number` allows us to easily mock the block number in
    *      tests.
    */
    function getBlockNumber64() internal view returns (uint64) {
        return getBlockNumber().toUint64();
    }

    /**
    * @dev Returns the current timestamp.
    *      Using a function rather than `block.timestamp` allows us to easily mock it in
    *      tests.
    */
    function getTimestamp() internal view returns (uint256) {
        return block.timestamp; // solium-disable-line security/no-block-members
    }

    /**
    * @dev Returns the current timestamp, converted to uint64.
    *      Using a function rather than `block.timestamp` allows us to easily mock it in
    *      tests.
    */
    function getTimestamp64() internal view returns (uint64) {
        return getTimestamp().toUint64();
    }
}

// File: contracts/PPF.sol

pragma solidity 0.4.24;





contract PPF is IFeed, TimeHelpers {
    using ECRecovery for bytes32;

    uint256 constant public ONE = 10 ** 18; // 10^18 is considered 1 in the price feed to allow for decimal calculations
    bytes32 constant public PPF_v1_ID = 0x33a8ba7202230fa1cee2aac7bac322939edc7ba0a48b0989335a5f87a5770369; // keccak256("PPF-v1");

    string private constant ERROR_BAD_SIGNATURE = "PPF_BAD_SIGNATURE";
    string private constant ERROR_BAD_RATE_TIMESTAMP = "PPF_BAD_RATE_TIMESTAMP";
    string private constant ERROR_INVALID_RATE_VALUE = "PPF_INVALID_RATE_VALUE";
    string private constant ERROR_EQUAL_BASE_QUOTE_ADDRESSES = "PPF_EQUAL_BASE_QUOTE_ADDRESSES";
    string private constant ERROR_BASE_ADDRESSES_LENGTH_ZERO = "PPF_BASE_ADDRESSES_LEN_ZERO";
    string private constant ERROR_QUOTE_ADDRESSES_LENGTH_MISMATCH = "PPF_QUOTE_ADDRESSES_LEN_MISMATCH";
    string private constant ERROR_RATE_VALUES_LENGTH_MISMATCH = "PPF_RATE_VALUES_LEN_MISMATCH";
    string private constant ERROR_RATE_TIMESTAMPS_LENGTH_MISMATCH = "PPF_RATE_TIMESTAMPS_LEN_MISMATCH";
    string private constant ERROR_SIGNATURES_LENGTH_MISMATCH = "PPF_SIGNATURES_LEN_MISMATCH";
    string private constant ERROR_CAN_NOT_SET_OPERATOR = "PPF_CAN_NOT_SET_OPERATOR";
    string private constant ERROR_CAN_NOT_SET_OPERATOR_OWNER = "PPF_CAN_NOT_SET_OPERATOR_OWNER";
    string private constant ERROR_OPERATOR_ADDRESS_ZERO = "PPF_OPERATOR_ADDRESS_ZERO";
    string private constant ERROR_OPERATOR_OWNER_ADDRESS_ZERO = "PPF_OPERATOR_OWNER_ADDRESS_ZERO";

    struct Price {
        uint128 xrt;
        uint64 when;
    }

    mapping (bytes32 => Price) internal feed;
    address public operator;
    address public operatorOwner;

    event SetRate(address indexed base, address indexed quote, uint256 xrt, uint64 when);
    event SetOperator(address indexed operator);
    event SetOperatorOwner(address indexed operatorOwner);

    /**
    * @param _operator Public key allowed to sign messages to update the pricefeed
    * @param _operatorOwner Address of an account that can change the operator
    */
    constructor (address _operator, address _operatorOwner) public {
        _setOperator(_operator);
        _setOperatorOwner(_operatorOwner);
    }

    /**
    * @notice Update the price for the `base + ':' + quote` feed with an exchange rate of `xrt / ONE` for time `when`
    * @dev If the number representation of base is lower than the one for quote, and update is cheaper, as less manipulation is required.
    * @param base Address for the base token in the feed
    * @param quote Address for the quote token the base is denominated in
    * @param xrt Exchange rate for base denominated in quote. 10^18 is considered 1 to allow for decimal calculations
    * @param when Timestamp for the exchange rate value
    * @param sig Signature payload (EIP191) from operator, concatenated [  r  ][  s  ][v]. See setHash function for the hash calculation.
    */
    function update(address base, address quote, uint128 xrt, uint64 when, bytes sig) public {
        bytes32 pair = pairId(base, quote);

        // Ensure it is more recent than the current value (implicit check for > 0) and not a future date
        require(when > feed[pair].when && when <= getTimestamp(), ERROR_BAD_RATE_TIMESTAMP);
        require(xrt > 0, ERROR_INVALID_RATE_VALUE); // Make sure xrt is not 0, as the math would break (Dividing by 0 sucks big time)
        require(base != quote, ERROR_EQUAL_BASE_QUOTE_ADDRESSES); // Assumption that currency units are fungible and xrt should always be 1

        bytes32 h = setHash(base, quote, xrt, when);
        require(h.personalRecover(sig) == operator, ERROR_BAD_SIGNATURE); // Make sure the update was signed by the operator

        feed[pair] = Price(pairXRT(base, quote, xrt), when);

        emit SetRate(base, quote, xrt, when);
    }

    /**
    * @notice Update the price for many pairs
    * @dev If the number representation of bases is lower than the one for quotes, and update is cheaper, as less manipulation is required.
    * @param bases Array of addresses for the base tokens in the feed
    * @param quotes Array of addresses for the quote tokens bases are denominated in
    * @param xrts Array of the exchange rates for bases denominated in quotes. 10^18 is considered 1 to allow for decimal calculations
    * @param whens Array of timestamps for the exchange rate value
    * @param sigs Bytes array with the ordered concatenated signatures for the updates
    */
    function updateMany(address[] bases, address[] quotes, uint128[] xrts, uint64[] whens, bytes sigs) public {
        require(bases.length != 0, ERROR_BASE_ADDRESSES_LENGTH_ZERO);
        require(bases.length == quotes.length, ERROR_QUOTE_ADDRESSES_LENGTH_MISMATCH);
        require(bases.length == xrts.length, ERROR_RATE_VALUES_LENGTH_MISMATCH);
        require(bases.length == whens.length, ERROR_RATE_TIMESTAMPS_LENGTH_MISMATCH);
        require(bases.length == sigs.length / 65, ERROR_SIGNATURES_LENGTH_MISMATCH);
        require(sigs.length % 65 == 0, ERROR_SIGNATURES_LENGTH_MISMATCH);

        for (uint256 i = 0; i < bases.length; i++) {
            // Extract the signature for the update from the concatenated sigs
            bytes memory sig = new bytes(65);
            uint256 needle = 32 + 65 * i; // where to start copying from sigs
            assembly {
                // copy 32 bytes at a time and just the last byte at the end
                mstore(add(sig, 0x20), mload(add(sigs, needle)))
                mstore(add(sig, 0x40), mload(add(sigs, add(needle, 0x20))))
                // we have to mload the last 32 bytes of the sig, and mstore8 just gets the LSB for the word
                mstore8(add(sig, 0x60), mload(add(sigs, add(needle, 0x21))))
            }

            update(bases[i], quotes[i], xrts[i], whens[i], sig);
        }
    }

    /**
    * @param base Address for the base token in the feed
    * @param quote Address for the quote token the base is denominated in
    * @return XRT for base:quote and the timestamp when it was updated
    */
    function get(address base, address quote) public view returns (uint128, uint64) {
        if (base == quote) {
            return (uint128(ONE), getTimestamp64());
        }

        Price storage price = feed[pairId(base, quote)];

        // if never set, return 0.
        if (price.when == 0) {
            return (0, 0);
        }

        return (pairXRT(base, quote, price.xrt), price.when);
    }

    /**
    * @notice Set operator public key to `_operator`
    * @param _operator Public key allowed to sign messages to update the pricefeed
    */
    function setOperator(address _operator) external {
        // Allow the current operator to change the operator to avoid having to hassle the
        // operatorOwner in cases where a node just wants to rotate its public key
        require(msg.sender == operator || msg.sender == operatorOwner, ERROR_CAN_NOT_SET_OPERATOR);
        _setOperator(_operator);
    }

    /**
    * @notice Set operator owner to `_operatorOwner`
    * @param _operatorOwner Address of an account that can change the operator
    */
    function setOperatorOwner(address _operatorOwner) external {
        require(msg.sender == operatorOwner, ERROR_CAN_NOT_SET_OPERATOR_OWNER);
        _setOperatorOwner(_operatorOwner);
    }

    function _setOperator(address _operator) internal {
        require(_operator != address(0), ERROR_OPERATOR_ADDRESS_ZERO);
        operator = _operator;
        emit SetOperator(_operator);
    }

    function _setOperatorOwner(address _operatorOwner) internal {
        require(_operatorOwner != address(0), ERROR_OPERATOR_OWNER_ADDRESS_ZERO);
        operatorOwner = _operatorOwner;
        emit SetOperatorOwner(_operatorOwner);
    }

    /**
    * @dev pairId returns a unique id for each pair, regardless of the order of base and quote
    */
    function pairId(address base, address quote) internal pure returns (bytes32) {
        bool pairOrdered = isPairOrdered(base, quote);
        address orderedBase = pairOrdered ? base : quote;
        address orderedQuote = pairOrdered ? quote : base;

        return keccak256(abi.encodePacked(orderedBase, orderedQuote));
    }

    /**
    * @dev Compute xrt depending on base and quote order.
    */
    function pairXRT(address base, address quote, uint128 xrt) internal pure returns (uint128) {
        bool pairOrdered = isPairOrdered(base, quote);

        return pairOrdered ? xrt : uint128((ONE**2 / uint256(xrt))); // If pair is not ordered, return the inverse
    }

    function setHash(address base, address quote, uint128 xrt, uint64 when) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(PPF_v1_ID, base, quote, xrt, when));
    }

    function isPairOrdered(address base, address quote) private pure returns (bool) {
        return base < quote;
    }
}