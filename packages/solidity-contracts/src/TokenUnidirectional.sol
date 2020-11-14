/**
 * Source Code first verified at https://etherscan.io on Thursday, May 2, 2019
 (UTC) */

pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title Eliptic curve signature operations
 *
 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
 *
 * TODO Remove this library once solidity supports passing a signature to ecrecover.
 * See https://github.com/ethereum/solidity/issues/864
 *
 */

library ECRecovery {

  /**
   * @dev Recover signer address from a message by using their signature
   * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
   * @param sig bytes signature, the signature is generated using web3.eth.sign()
   */
  function recover(bytes32 hash, bytes sig)
    internal
    pure
    returns (address)
  {
    bytes32 r;
    bytes32 s;
    uint8 v;

    // Check the signature length
    if (sig.length != 65) {
      return (address(0));
    }

    // Divide the signature in r, s and v variables
    // ecrecover takes the signature parameters, and the only way to get them
    // currently is to use assembly.
    // solium-disable-next-line security/no-inline-assembly
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
      // solium-disable-next-line arg-overflow
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
    return keccak256(
      "\x19Ethereum Signed Message:\n32",
      hash
    );
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

/// @title Unidirectional payment channels contract for ERC20 tokens.
contract TokenUnidirectional {
    using SafeMath for uint256;

    struct PaymentChannel {
        address sender;
        address receiver;
        uint256 value; // Total amount of money deposited to the channel.

        uint256 settlingPeriod; // How many blocks to wait for the receiver to claim her funds, after sender starts settling.
        uint256 settlingUntil; // Starting with this block number, anyone can settle the channel.
        address tokenContract; // Address of ERC20 token contract.
    }

    mapping (bytes32 => PaymentChannel) public channels;

    event DidOpen(bytes32 indexed channelId, address indexed sender, address indexed receiver, uint256 value, address tokenContract);
    event DidDeposit(bytes32 indexed channelId, uint256 deposit);
    event DidClaim(bytes32 indexed channelId);
    event DidStartSettling(bytes32 indexed channelId);
    event DidSettle(bytes32 indexed channelId);

    /*** ACTIONS AND CONSTRAINTS ***/

    /// @notice Open a new channel between `msg.sender` and `receiver`, and do an initial deposit to the channel.
    /// @param channelId Unique identifier of the channel to be created.
    /// @param receiver Receiver of the funds, counter-party of `msg.sender`.
    /// @param settlingPeriod Number of blocks to wait for receiver to `claim` her funds after the sender starts settling period (see `startSettling`).
    /// After that period is over anyone could call `settle`, and move all the channel funds to the sender.
    /// @param tokenContract Address of ERC20 token contract.
    /// @param value Initial channel amount.
    /// @dev Before opening a channel, the sender should `approve` spending the token by TokenUnidirectional contract.
    function open(bytes32 channelId, address receiver, uint256 settlingPeriod, address tokenContract, uint256 value) public {
        require(isAbsent(channelId), "Channel with the same id is present");

        StandardToken token = StandardToken(tokenContract);
        require(token.transferFrom(msg.sender, address(this), value), "Unable to transfer token to the contract");

        channels[channelId] = PaymentChannel({
            sender: msg.sender,
            receiver: receiver,
            value: value,
            settlingPeriod: settlingPeriod,
            settlingUntil: 0,
            tokenContract: tokenContract
        });

        emit DidOpen(channelId, msg.sender, receiver, value, tokenContract);
    }

    /// @notice Ensure `origin` address can deposit funds into the channel identified by `channelId`.
    /// @dev Constraint `deposit` call.
    /// @param channelId Identifier of the channel.
    /// @param origin Caller of `deposit` function.
    function canDeposit(bytes32 channelId, address origin) public view returns(bool) {
        PaymentChannel storage channel = channels[channelId];
        bool isSender = channel.sender == origin;
        return isOpen(channelId) && isSender;
    }

    /// @notice Add more funds to the contract.
    /// @param channelId Identifier of the channel.
    /// @param value Amount to be deposited.
    function deposit(bytes32 channelId, uint256 value) public {
        require(canDeposit(channelId, msg.sender), "canDeposit returned false");

        PaymentChannel storage channel = channels[channelId];
        StandardToken token = StandardToken(channel.tokenContract);
        require(token.transferFrom(msg.sender, address(this), value), "Unable to transfer token to the contract");
        channel.value = channel.value.add(value);

        emit DidDeposit(channelId, value);
    }

    /// @notice Ensure `origin` address can start settling the channel identified by `channelId`.
    /// @dev Constraint `startSettling` call.
    /// @param channelId Identifier of the channel.
    /// @param origin Caller of `startSettling` function.
    function canStartSettling(bytes32 channelId, address origin) public view returns(bool) {
        PaymentChannel storage channel = channels[channelId];
        bool isSender = channel.sender == origin;
        return isOpen(channelId) && isSender;
    }

    /// @notice Sender initiates settling of the contract.
    /// @dev Actually set `settlingUntil` field of the PaymentChannel structure.
    /// @param channelId Identifier of the channel.
    function startSettling(bytes32 channelId) public {
        require(canStartSettling(channelId, msg.sender), "canStartSettling returned false");

        PaymentChannel storage channel = channels[channelId];
        channel.settlingUntil = block.number.add(channel.settlingPeriod);

        emit DidStartSettling(channelId);
    }

    /// @notice Ensure one can settle the channel identified by `channelId`.
    /// @dev Check if settling period is over by comparing `settlingUntil` to a current block number.
    /// @param channelId Identifier of the channel.
    function canSettle(bytes32 channelId) public view returns(bool) {
        PaymentChannel storage channel = channels[channelId];
        bool isWaitingOver = block.number >= channel.settlingUntil;
        return isSettling(channelId) && isWaitingOver;
    }

    /// @notice Move the money to sender, and close the channel.
    /// After the settling period is over, and receiver has not claimed the funds, anyone could call that.
    /// @param channelId Identifier of the channel.
    function settle(bytes32 channelId) public {
        require(canSettle(channelId), "canSettle returned false");

        PaymentChannel storage channel = channels[channelId];
        StandardToken token = StandardToken(channel.tokenContract);

        require(token.transfer(channel.sender, channel.value), "Unable to transfer token to channel sender");

        delete channels[channelId];
        emit DidSettle(channelId);
    }

    /// @notice Ensure `origin` address can claim `payment` amount on channel identified by `channelId`.
    /// @dev Check if `signature` is made by sender part of the channel, and is for payment promise (see `paymentDigest`).
    /// @param channelId Identifier of the channel.
    /// @param payment Amount claimed.
    /// @param origin Caller of `claim` function.
    /// @param signature Signature for the payment promise.
    function canClaim(bytes32 channelId, uint256 payment, address origin, bytes signature) public view returns(bool) {
        PaymentChannel storage channel = channels[channelId];
        bool isReceiver = origin == channel.receiver;
        bytes32 hash = recoveryPaymentDigest(channelId, payment, channel.tokenContract);
        bool isSigned = channel.sender == ECRecovery.recover(hash, signature);

        return isReceiver && isSigned;
    }

    /// @notice Claim the funds, and close the channel.
    /// @dev Can be claimed by channel receiver only. Guarded by `canClaim`.
    /// @param channelId Identifier of the channel.
    /// @param payment Amount claimed.
    /// @param signature Signature for the payment promise.
    function claim(bytes32 channelId, uint256 payment, bytes signature) public {
        require(canClaim(channelId, payment, msg.sender, signature), "canClaim returned false");

        PaymentChannel storage channel = channels[channelId];
        StandardToken token = StandardToken(channel.tokenContract);

        if (payment >= channel.value) {
            require(token.transfer(channel.receiver, channel.value), "Unable to transfer token to channel receiver");
        } else {
            require(token.transfer(channel.receiver, payment), "Unable to transfer token to channel receiver");
            uint256 change = channel.value.sub(payment);
            require(token.transfer(channel.sender, change), "Unable to transfer token to channel sender");
        }

        delete channels[channelId];

        emit DidClaim(channelId);
    }

    /*** CHANNEL STATE ***/

    /// @notice Check if the channel is not present.
    /// @param channelId Identifier of the channel.
    function isAbsent(bytes32 channelId) public view returns(bool) {
        PaymentChannel storage channel = channels[channelId];
        return channel.sender == 0;
    }

    /// @notice Check if the channel is present: in open or settling state.
    /// @param channelId Identifier of the channel.
    function isPresent(bytes32 channelId) public view returns(bool) {
        return !isAbsent(channelId);
    }

    /// @notice Check if the channel is in settling state: waits till the settling period is over.
    /// @dev It is settling, if `settlingUntil` is set to non-zero.
    /// @param channelId Identifier of the channel.
    function isSettling(bytes32 channelId) public view returns(bool) {
        PaymentChannel storage channel = channels[channelId];
        return channel.settlingUntil != 0;
    }

    /// @notice Check if the channel is open: present and not settling.
    /// @param channelId Identifier of the channel.
    function isOpen(bytes32 channelId) public view returns(bool) {
        return isPresent(channelId) && !isSettling(channelId);
    }

    /*** PAYMENT DIGEST ***/

    /// @return Hash of the payment promise to sign.
    /// @param channelId Identifier of the channel.
    /// @param payment Amount to send, and to claim later.
    /// @param tokenContract Address of ERC20 token contract.
    function paymentDigest(bytes32 channelId, uint256 payment, address tokenContract) public view returns(bytes32) {
        return keccak256(abi.encodePacked(address(this), channelId, payment, tokenContract));
    }

    /// @return Actually signed hash of the payment promise, considering "Ethereum Signed Message" prefix.
    /// @param channelId Identifier of the channel.
    /// @param payment Amount to send, and to claim later.
    function recoveryPaymentDigest(bytes32 channelId, uint256 payment, address tokenContract) internal view returns(bytes32) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        return keccak256(abi.encodePacked(prefix, paymentDigest(channelId, payment, tokenContract)));
    }
}