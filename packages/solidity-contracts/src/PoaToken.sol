/**
 * Source Code first verified at https://etherscan.io on Monday, April 8, 2019
 (UTC) */

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

pragma solidity ^0.4.24;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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

// File: openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol

pragma solidity ^0.4.24;




/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.4.24;



/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol

pragma solidity ^0.4.24;




/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
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
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.4.24;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: contracts/PoaProxyCommon.sol

pragma solidity 0.4.24;


/**
  @title PoaProxyCommon acts as a convention between:
  - PoaCommon (and its inheritants: PoaToken & PoaCrowdsale)
  - PoaProxy

  It dictates where to read and write storage
*/
contract PoaProxyCommon {
  /*****************************
  * Start Proxy Common Storage *
  *****************************/

  // PoaTokenMaster logic contract used by proxies
  address public poaTokenMaster;

  // PoaCrowdsaleMaster logic contract used by proxies
  address public poaCrowdsaleMaster;

  // Registry used for getting other contract addresses
  address public registry;

  /***************************
  * End Proxy Common Storage *
  ***************************/


  /*********************************
  * Start Common Utility Functions *
  *********************************/

  /// @notice Gets a given contract address by bytes32 in order to save gas
  function getContractAddress(string _name)
    public
    view
    returns (address _contractAddress)
  {
    bytes4 _signature = bytes4(keccak256("getContractAddress32(bytes32)"));
    bytes32 _name32 = keccak256(abi.encodePacked(_name));

    assembly {
      let _registry := sload(registry_slot) // load registry address from storage
      let _pointer := mload(0x40)          // Set _pointer to free memory pointer
      mstore(_pointer, _signature)         // Store _signature at _pointer
      mstore(add(_pointer, 0x04), _name32) // Store _name32 at _pointer offset by 4 bytes for pre-existing _signature

      // staticcall(g, a, in, insize, out, outsize) => returns 0 on error, 1 on success
      let result := staticcall(
        gas,       // g = gas: whatever was passed already
        _registry, // a = address: address in storage
        _pointer,  // in = mem in  mem[in..(in+insize): set to free memory pointer
        0x24,      // insize = mem insize  mem[in..(in+insize): size of signature (bytes4) + bytes32 = 0x24
        _pointer,  // out = mem out  mem[out..(out+outsize): output assigned to this storage address
        0x20       // outsize = mem outsize  mem[out..(out+outsize): output should be 32byte slot (address size = 0x14 <  slot size 0x20)
      )

      // revert if not successful
      if iszero(result) {
        revert(0, 0)
      }

      _contractAddress := mload(_pointer) // Assign result to return value
      mstore(0x40, add(_pointer, 0x24))   // Advance free memory pointer by largest _pointer size
    }
  }

  /*******************************
  * End Common Utility Functions *
  *******************************/
}

// File: contracts/external/SafeMathPower.sol

pragma solidity ^0.4.24;


/**
  @title SafeMathPower
  @notice This library has been inspired by https://github.com/dapphub/ds-math/tree/49b38937c0c0b8af73b05f767a0af9d5e85a1e6c.
  It uses the same functions but with different visibility modifiers and has had unneeded functions removed.

  @dev This library can be used along side OpenZeppelin's SafeMath in the same manner.
*/
library SafeMathPower {
  uint internal constant RAY = 10 ** 27;

  function add(uint x, uint y) private pure returns (uint z) {
    require((z = x + y) >= x);
  }

  function mul(uint x, uint y) private pure returns (uint z) {
    require(y == 0 || (z = x * y) / y == x);
  }

  function rmul(uint x, uint y) private pure returns (uint z) {
    z = add(mul(x, y), RAY / 2) / RAY;
  }

  // This famous algorithm is called "exponentiation by squaring"
  // and calculates x^n with x as fixed-point and n as regular unsigned.
  //
  // It's O(log n), instead of O(n) for naive repeated multiplication.
  //
  // These facts are why it works:
  //
  //  If n is even, then x^n = (x^2)^(n/2).
  //  If n is odd,  then x^n = x * x^(n-1),
  //   and applying the equation for even x gives
  //    x^n = x * (x^2)^((n-1) / 2).
  //
  //  Also, EVM division is flooring and
  //    floor[(n-1) / 2] = floor[n / 2].
  //
  function rpow(uint x, uint n) internal pure returns (uint z) {
    z = n % 2 != 0 ? x : RAY;

    for (n /= 2; n != 0; n /= 2) {
      x = rmul(x, x);

      if (n % 2 != 0) {
        z = rmul(z, x);
      }
    }
  }
}

// File: contracts/PoaCommon.sol

pragma solidity 0.4.24;





/**
  @title Firstly, PoaCommon acts as a convention between:
  - PoaToken
  - PoaCrowdsale
  to use agreed upon storage for getting & setting
  variables which are used by both contracts.

  Secondly, it has a set of shared functions.

  Thirdly, it inherits from PoaProxyCommon to adhere to the agreed
  upon storage slots for getting & setting PoaProxy related storage.
*/
contract PoaCommon is PoaProxyCommon {
  using SafeMath for uint256;
  using SafeMathPower for uint256;

  // The fee paid to the BBK network per crowdsale investment and per payout
  // NOTE: Tracked in permille (and NOT percent) to reduce dust and
  // inaccuracies caused by integer division
  uint256 public constant feeRateInPermille = 5; // read: 0.5%

  // An enum representing all stages a contract can be in.
  // Different stages enable or restrict certain functionality.
  enum Stages {
    Preview,           // 0
    PreFunding,        // 1
    FiatFunding,       // 2
    EthFunding,        // 3
    FundingSuccessful, // 4
    FundingCancelled,  // 5
    TimedOut,          // 6
    Active,            // 7
    Terminated         // 8
  }

  /***********************
  * Start Common Storage *
  ***********************/

  // Represents current stage
  Stages public stage;

  // Issuer in charge of starting sale, paying fee and handling payouts
  address public issuer;

  // Custodian in charge of taking care of asset and payouts
  address public custodian;

  // IPFS hash storing the proof of custody provided by custodian
  bytes32[2] internal proofOfCustody32_;

  // ERC20 totalSupply
  uint256 internal totalSupply_;

  // Tracks the total amount of tokens sold during the FiatFunding stage
  uint256 public fundedFiatAmountInTokens;

  // Tracks the Fiat investments per user raised during the FiatFunding stage
  mapping(address => uint256) public fundedFiatAmountPerUserInTokens;

  // Tracks the total amount of ETH raised during the EthFunding stage.
  // NOTE: We can't use `address(this).balance` because after activating the
  // POA contract, its balance will become `claimable` by the issuer and can
  // therefore no longer be used to calculate balances.
  uint256 public fundedEthAmountInWei;

  // Tracks the ETH investments per user raised during the EthFunding stage
  mapping(address => uint256) public fundedEthAmountPerUserInWei;

  // Tracks unclaimed payouts per user
  mapping(address => uint256) public unclaimedPayoutTotals;

  // ERC20 paused - Used for enabling/disabling token transfers
  bool public paused;

  // Indicates if poaToken has been initialized
  bool public tokenInitialized;

  // Indicated if the initial fee paid after the crowdsale
  bool public isActivationFeePaid;

  /*********************
  * End Common Storage *
  *********************/

  /**************************
  * Start Crowdsale Storage *
  **************************/

  /*
    Crowdsale storage must be declared in PoaCommon in order to
    avoid storage overwrites by PoaCrowdsale.
  */

  // Bool indicating whether or not crowdsale proxy has been initialized
  bool public crowdsaleInitialized;

  // Used for checking when contract should move from PreFunding to FiatFunding or EthFunding stage
  uint256 public startTimeForFundingPeriod;

  // Maximum duration of fiat funding period in seconds
  uint256 public durationForFiatFundingPeriod;

  // Maximum duration of ETH funding period in seconds
  uint256 public durationForEthFundingPeriod;

  // Maximum duration of activation period in seconds
  uint256 public durationForActivationPeriod;

  // bytes32 representation fiat currency symbol used to get rate
  bytes32 public fiatCurrency32;

  // Amount needed before moving to 'FundingSuccessful', calculated in fiat
  uint256 public fundingGoalInCents;

  // Used for keeping track of actual funded amount in fiat during FiatFunding stage
  uint256 public fundedFiatAmountInCents;

  /************************
  * End Crowdsale Storage *
  ************************/

  /*************************
  * Start Common Modifiers *
  *************************/

  modifier onlyCustodian() {
    require(msg.sender == custodian);
    _;
  }

  modifier onlyIssuer() {
    require(msg.sender == issuer);
    _;
  }

  modifier atStage(Stages _stage) {
    require(stage == _stage);
    _;
  }

  modifier atEitherStage(Stages _stage, Stages _orStage) {
    require(stage == _stage || stage == _orStage);
    _;
  }

  modifier atMaxStage(Stages _stage) {
    require(stage <= _stage);
    _;
  }

  /**
    @notice Check that the most common hashing algo is used (keccak256)
    and that its length is correct. In theory, it could be different.
    But the use of this functionality is limited to "onlyCustodian"
    so this validation should suffice.
  */
  modifier validIpfsHash(bytes32[2] _ipfsHash) {
    bytes memory _ipfsHashBytes = bytes(to64LengthString(_ipfsHash));
    require(_ipfsHashBytes.length == 46);
    require(_ipfsHashBytes[0] == 0x51);
    require(_ipfsHashBytes[1] == 0x6D);
    require(keccak256(abi.encodePacked(_ipfsHashBytes)) != keccak256(abi.encodePacked(proofOfCustody())));
    _;
  }

  /***********************
  * End Common Modifiers *
  ***********************/


  /************************
  * Start Regular Getters *
  ************************/

  /**
    @notice Converts proofOfCustody from bytes32 to string
    @return string
   */
  function proofOfCustody()
    public
    view
    returns (string)
  {
    return to64LengthString(proofOfCustody32_);
  }

  /**********************
  * End Regular Getters *
  **********************/


  /***********************************
  * Start Common Lifecycle Functions *
  ***********************************/

  function enterStage(
    Stages _stage
  )
    internal
  {
    stage = _stage;
    getContractAddress("PoaLogger").call(
      abi.encodeWithSignature("logStage(uint256)", uint256(_stage))
    );
  }

  /*********************************
  * End Common Lifecycle Functions *
  *********************************/


  /*********************************
  * Start Common Utility Functions *
  *********************************/

  /// @notice Utility function calculating the necessary fee for a given amount
  /// @return uint256 Payable fee
  function calculateFee(
    uint256 _value
  )
    public
    pure
    returns (uint256)
  {
    return feeRateInPermille.mul(_value).div(1000);
  }

  /// @notice Pay fee to FeeManager contract
  /// @return true if fee payment succeeded, or false if it failed
  function payFee(
    uint256 _value
  )
    internal
    returns (bool)
  {
    require(
      // NOTE: It's an `internal` call and we know exactly what
      // we're calling so it's safe to ignore this solium warning.
      // solium-disable-next-line security/no-call-value
      getContractAddress("FeeManager")
        .call.value(_value)(abi.encodeWithSignature("payFee()"))
    );
  }

  /// @notice Checks if a given address has invested during the EthFunding stage.
  function isEthInvestor(
    address _buyer
  )
    internal
    view
    returns (bool)
  {
    return fundedEthAmountPerUserInWei[_buyer] > 0;
  }

  /// @notice Checks if a given address has invested during the FiatFunding stage.
  function isFiatInvestor(
    address _buyer
  )
    internal
    view
    returns (bool)
  {
    return fundedFiatAmountPerUserInTokens[_buyer] > 0;
  }

  /// @notice Checks if a given address is whitelisted
  /// @return true if address is whitelisted, false if not
  function isWhitelisted(
    address _address
  )
    public
    view
    returns (bool _isWhitelisted)
  {
    bytes4 _signature = bytes4(keccak256("whitelisted(address)"));
    address _whitelistContract = getContractAddress("Whitelist");

    assembly {
      let _pointer := mload(0x40)  // Set _pointer to free memory pointer
      mstore(_pointer, _signature) // Store _signature at _pointer
      mstore(add(_pointer, 0x04), _address) // Store _address at _pointer. Offset by 4 bytes for previously stored _signature

      // staticcall(g, a, in, insize, out, outsize) => returns 0 on error, 1 on success
      let result := staticcall(
        gas,                // g = gas: whatever was passed already
        _whitelistContract, // a = address: _whitelist address assigned from getContractAddress()
        _pointer,           // in = mem in  mem[in..(in+insize): set to _pointer pointer
        0x24,               // insize = mem insize  mem[in..(in+insize): size of signature (bytes4) + bytes32 = 0x24
        _pointer,           // out = mem out  mem[out..(out+outsize): output assigned to this storage address
        0x20                // outsize = mem outsize  mem[out..(out+outsize): output should be 32byte slot (bool size = 0x01 < slot size 0x20)
      )

      // Revert if not successful
      if iszero(result) {
        revert(0, 0)
      }

      _isWhitelisted := mload(_pointer) // Assign result to returned value
      mstore(0x40, add(_pointer, 0x24)) // Advance free memory pointer by largest _pointer size
    }
  }

  /// @notice Takes a single bytes32 and returns a max 32 char long string
  /// @param _data single bytes32 representation of a string
  function to32LengthString(
    bytes32 _data
  )
    internal
    pure
    returns (string)
  {
    // create a new empty bytes array with same max length as input
    bytes memory _bytesString = new bytes(32);

    // an assembly block is necessary to directly change memory layout
    assembly {
      mstore(add(_bytesString, 0x20), _data)
    }

    // measure string by searching for first occurrance of empty byte
    for (uint256 _bytesCounter = 0; _bytesCounter < 32; _bytesCounter++) {
      if (_bytesString[_bytesCounter] == 0x00) {
        break;
      }
    }

    // directly set the length of bytes array through assembly
    assembly {
      mstore(_bytesString, _bytesCounter)
    }

    // cast bytes array to string
    return string(_bytesString);
  }

  /// @notice Needed for longer strings up to 64 chars long
  /// @param _data 2 length sized array of bytes32
  function to64LengthString(
    bytes32[2] _data
  )
    internal
    pure
    returns (string)
  {
    // create a new empty bytes array with same max length as input
    bytes memory _bytesString = new bytes(64);

    // store both of the 32 byte items packed, leave space for length at first 32 bytes
    assembly {
      mstore(add(_bytesString, 0x20), mload(_data))
      mstore(add(_bytesString, 0x40), mload(add(_data, 0x20)))
    }

    // measure string by searching for first occurrance of empty byte
    for (uint256 _bytesCounter = 0; _bytesCounter < 64; _bytesCounter++) {
      if (_bytesString[_bytesCounter] == 0x00) {
        break;
      }
    }

    // directly set the length of bytes array through assembly
    assembly {
      mstore(_bytesString, _bytesCounter)
    }

    // cast bytes array to string
    return string (_bytesString);
  }

  /*******************************
  * End Common Utility Functions *
  *******************************/
}

// File: contracts/PoaToken.sol

pragma solidity 0.4.24;





/**
  @title This acts as a master copy for use with PoaProxy in conjunction
  with PoaCrowdsale. Storage is assumed to be set on PoaProxy through
  delegatecall in fallback function. This contract handles the
  token/dividends functionality of PoaProxy. Inherited PoaCommon dictates
  common storage slots as well as common functions used by both PoaToken
  and PoaCrowdsale.
*/
contract PoaToken is PoaCommon {
  uint256 public constant tokenVersion = 1;

  /**********************************
  * start poaToken specific storage *
  **********************************/

  // ERC20 name of the token
  bytes32 private name32;
  // ERC20 symbol
  bytes32 private symbol32;
  // ERC0 decimals
  uint8 public constant decimals = 18;
  // the total per token payout rate: accumulates as payouts are received
  uint256 public totalPerTokenPayout;
  // the onwer of the contract
  address public owner;
  // used for deducting already claimed payouts on a per token basis
  mapping(address => uint256) public claimedPerTokenPayouts;
  // used for calculating balanceOf by deducting spent balances
  mapping(address => uint256) public spentBalances;
  // used for calculating balanceOf by adding received balances
  mapping(address => uint256) public receivedBalances;
  // allowance of spender to spend owners tokens
  mapping(address => mapping (address => uint256)) internal allowed;

  /********************************
  * end poaToken specific storage *
  ********************************/

  /************************************
  * start non-centrally logged events *
  ************************************/

  event Pause();
  event Unpause();
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  /**********************************
  * end non-centrally logged events *
  **********************************/

  /******************
  * start modifiers *
  ******************/

  modifier onlyOwner() {
    owner = getContractAddress("PoaManager");
    require(msg.sender == owner);
    _;
  }

  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  modifier whenPaused() {
    require(paused);
    _;
  }

  modifier eitherCustodianOrOwner() {
    owner = getContractAddress("PoaManager");
    require(
      msg.sender == custodian ||
      msg.sender == owner
    );
    _;
  }

  modifier eitherIssuerOrCustodian() {
    require(
      msg.sender == issuer ||
      msg.sender == custodian
    );
    _;
  }

  modifier isTransferWhitelisted(
    address _address
  )
  {
    require(isWhitelisted(_address));
    _;
  }

  /****************
  * end modifiers *
  ****************/

  /**
    @notice Proxied contracts cannot have constructors. This works in place
    of the constructor in order to initialize the contract storage.
  */
  function initializeToken(
    bytes32 _name32, // bytes32 of name string
    bytes32 _symbol32, // bytes32 of symbol string
    address _issuer,
    address _custodian,
    address _registry,
    uint256 _totalSupply // token total supply
  )
    external
    returns (bool)
  {
    // ensure initialize has not been called already
    require(!tokenInitialized);

    // validate and initialize parameters in sequential storage
    setName(_name32);
    setSymbol(_symbol32);
    setIssuerAddress(_issuer);
    setCustodianAddress(_custodian);
    setTotalSupply(_totalSupply);

    owner = getContractAddress("PoaManager");
    registry = _registry;

    paused = true;
    tokenInitialized = true;

    return true;
  }

  /****************************************
  * external setters for `Stages.Preview` *
  *****************************************/

  /**
   * @notice Update name for POA Token
   * @dev Only allowed in `Stages.Preview` by Issuer
   * @param _newName32 The new name
   */
  function updateName(bytes32 _newName32)
    external
    onlyIssuer
    atStage(Stages.Preview)
  {
    setName(_newName32);
  }

  /**
   * @notice Update symbol for POA Token
   * @dev Only allowed in `Stages.Preview` by Issuer
   * @param _newSymbol32 The new symbol
   */
  function updateSymbol(bytes32 _newSymbol32)
    external
    onlyIssuer
    atStage(Stages.Preview)
  {
    setSymbol(_newSymbol32);
  }

  /**
   * @notice Update Issuer address for POA Token
   * @dev Only allowed in `Stages.Preview` by Issuer
   * @param _newIssuer The new Issuer address
   */
  function updateIssuerAddress(address _newIssuer)
    external
    onlyIssuer
    atStage(Stages.Preview)
  {
    setIssuerAddress(_newIssuer);
  }

  /**
   * @notice Update total supply for POA Token
   * @dev Only allowed in `Stages.Preview` by Issuer
   * @param _newTotalSupply The new total supply
   */
  function updateTotalSupply(uint256 _newTotalSupply)
    external
    onlyIssuer
    atStage(Stages.Preview)
  {
    setTotalSupply(_newTotalSupply);
  }

  /********************************************
  * end external setters for `Stages.Preview` *
  *********************************************/

  /*******************************
   * internal validating setters *
   *******************************/

  /**
   * @notice Set name for POA Token
   * @param _newName32 The new name
   */
  function setName(bytes32 _newName32)
    internal
  {
    require(_newName32 != bytes32(0));
    require(_newName32 != name32);

    name32 = _newName32;
  }

  /**
   * @notice Set symbol for POA Token
   * @param _newSymbol32 The new symbol
   */
  function setSymbol(bytes32 _newSymbol32)
    internal
  {
    require(_newSymbol32 != bytes32(0));
    require(_newSymbol32 != symbol32);

    symbol32 = _newSymbol32;
  }

  /**
   * @notice Set Issuer address for POA Token
   * @param _newIssuer The new Issuer address
   */
  function setIssuerAddress(address _newIssuer)
    internal
  {
    require(_newIssuer != address(0));
    require(_newIssuer != issuer);

    issuer = _newIssuer;
  }

  /**
   * @notice Set Custodian address for POA Token
   * @param _newCustodian The new Custodian address
   */
  function setCustodianAddress(address _newCustodian)
    internal
  {
    require(_newCustodian != address(0));
    require(_newCustodian != custodian);

    custodian = _newCustodian;
  }

  /**
   * @notice Set total supply for POA token
   * @dev Assuming 18 decimals, the total supply must
   *      be greather than 1e18
   * @param _newTotalSupply The new total supply
   */
  function setTotalSupply(uint256 _newTotalSupply)
    internal
  {
    require(_newTotalSupply >= 1e18);
    require(fundingGoalInCents < _newTotalSupply);
    require(_newTotalSupply != totalSupply_);

    totalSupply_ = _newTotalSupply;
  }

  /***********************************
   * end internal validating setters *
   ***********************************/

  /****************************
  * start lifecycle functions *
  ****************************/

  /**
   * @notice Change Custodian address for POA Token
   * @dev Only old Custodian is able to change his own
   *      address (`onlyCustodian` modifier)
   * @dev This change is allowed at any stage and is
   *      logged via PoaManager
   * @param _newCustodian The new Custodian address
   * @return true when successful
   */
  function changeCustodianAddress(address _newCustodian)
    external
    onlyCustodian
    returns (bool)
  {
    getContractAddress("PoaLogger").call(
      abi.encodeWithSignature(
        "logCustodianChanged(address,address)",
        custodian,
        _newCustodian
      )
    );

    setCustodianAddress(_newCustodian);

    return true;
  }

  /**
   * @notice Move from `Stages.Preview` to `Stages.PreFunding`
   * @dev After calling this function, the token parameters
   *      become immutable
   * @dev Only allowed in `Stages.Preview` by Issuer
   * @dev We need to revalidate the time-related token parameters here
  */
  function startPreFunding()
    external
    onlyIssuer
    atStage(Stages.Preview)
    returns (bool)
  {
    // check that `startTimeForFundingPeriod` lies in the future
    // solium-disable-next-line security/no-block-members
    require(startTimeForFundingPeriod > block.timestamp);

    // set Stage to PreFunding
    enterStage(Stages.PreFunding);

    return true;
  }

  /**
    @notice Used when asset should no longer be tokenized.
    Allows for winding down via payouts, and freeze trading
  */
  function terminate()
    external
    eitherCustodianOrOwner
    atStage(Stages.Active)
    returns (bool)
  {
    // set Stage to terminated
    enterStage(Stages.Terminated);
    // pause. Cannot be unpaused now that in Stages.Terminated
    paused = true;
    getContractAddress("PoaLogger").call(
      abi.encodeWithSignature("logTerminated()")
    );

    return true;
  }

  /**************************
  * end lifecycle functions *
  **************************/

  /************************
  * start owner functions *
  ************************/

  function pause()
    public
    onlyOwner
    whenNotPaused
  {
    paused = true;
    emit Pause();
  }

  function unpause()
    public
    onlyOwner
    whenPaused
    atStage(Stages.Active)
  {
    paused = false;
    emit Unpause();
  }

  /**********************
  * end owner functions *
  **********************/

  /*************************
  * start getter functions *
  *************************/

  /// @notice returns string coverted from bytes32 representation of name
  function name()
    external
    view
    returns (string)
  {
    return to32LengthString(name32);
  }

  /// @notice returns strig converted from bytes32 representation of symbol
  function symbol()
    external
    view
    returns (string)
  {
    return to32LengthString(symbol32);
  }

  function totalSupply()
    public
    view
    returns (uint256)
  {
    return totalSupply_;
  }

  /***********************
  * end getter functions *
  ***********************/

  /*********************************
  * start payout related functions *
  *********************************/

  /// @notice get current payout for perTokenPayout and unclaimed
  function currentPayout(
    address _address,
    bool _includeUnclaimed
  )
    public
    view
    returns (uint256)
  {
    /**
      @dev Need to check if there have been no payouts, otherwise safe math
      will throw due to dividing by 0.
      The below variable represents the total payout from the per token rate pattern.
      It uses this funky naming pattern in order to differentiate from the unclaimedPayoutTotals
      which means something very different.
    */
    uint256 _totalPerTokenUnclaimedConverted = totalPerTokenPayout == 0
      ? 0
      : balanceOf(_address)
      .mul(totalPerTokenPayout.sub(claimedPerTokenPayouts[_address]))
      .div(1e18);

    /**
      @dev Balances may be bumped into unclaimedPayoutTotals in order to
      maintain balance tracking accross token transfers.
      Per token payout rates are stored * 1e18 in order to be kept accurate
      per token payout is / 1e18 at time of usage for actual Ξ balances
      `unclaimedPayoutTotals` are stored as actual Ξ value no need for rate * balance
    */
    return _includeUnclaimed
      ? _totalPerTokenUnclaimedConverted.add(unclaimedPayoutTotals[_address])
      : _totalPerTokenUnclaimedConverted;
  }

  /// @notice settle up perToken balances and move into unclaimedPayoutTotals in order
  /// to ensure that token transfers will not result in inaccurate balances
  function settleUnclaimedPerTokenPayouts(
    address _from,
    address _to
  )
    internal
    returns (bool)
  {
    // add perToken balance to unclaimedPayoutTotals which will not be affected by transfers
    unclaimedPayoutTotals[_from] = unclaimedPayoutTotals[_from]
      .add(currentPayout(_from, false));
    // max out claimedPerTokenPayouts in order to effectively make perToken balance 0
    claimedPerTokenPayouts[_from] = totalPerTokenPayout;
    // same as above for to
    unclaimedPayoutTotals[_to] = unclaimedPayoutTotals[_to]
      .add(currentPayout(_to, false));
    // same as above for to
    claimedPerTokenPayouts[_to] = totalPerTokenPayout;

    return true;
  }

  /// @notice send Ξ to contract to be claimed by token holders
  function payout()
    external
    payable
    eitherIssuerOrCustodian
    atEitherStage(Stages.Active, Stages.Terminated)
    returns (bool)
  {
    // calculate fee based on feeRateInPermille
    uint256 _fee = calculateFee(msg.value);
    // ensure the value is high enough for a fee to be claimed
    require(_fee > 0);
    // deduct fee from payout
    uint256 _payoutAmount = msg.value.sub(_fee);
    /*
      totalPerTokenPayout is a rate at which to payout based on token balance.
      It is stored as * 1e18 in order to keep accuracy
      It is / 1e18 when used relating to actual Ξ values
    */
    totalPerTokenPayout = totalPerTokenPayout
      .add(_payoutAmount
        .mul(1e18)
        .div(totalSupply_)
      );

    // take remaining dust and send to feeManager rather than leave stuck in
    // contract. should not be more than a few wei
    uint256 _delta = (_payoutAmount.mul(1e18) % totalSupply_).div(1e18);
    // pay fee along with any dust to FeeManager
    payFee(_fee.add(_delta));
    getContractAddress("PoaLogger").call(
      abi.encodeWithSignature(
        "logPayout(uint256)",
        _payoutAmount.sub(_delta)
      )
    );

    return true;
  }

  /// @notice claim total eth claimable for sender based on token holdings at time of each payout
  function claim()
    external
    atEitherStage(Stages.Active, Stages.Terminated)
    returns (uint256)
  {
    /*
      pass true to currentPayout in order to get both:
      - perToken payouts
      - unclaimedPayoutTotals
    */
    uint256 _payoutAmount = currentPayout(msg.sender, true);
    // check that there indeed is a pending payout for sender
    require(_payoutAmount > 0);
    // max out per token payout for sender in order to make payouts effectively
    // 0 for sender
    claimedPerTokenPayouts[msg.sender] = totalPerTokenPayout;
    // 0 out unclaimedPayoutTotals for user
    unclaimedPayoutTotals[msg.sender] = 0;
    // transfer Ξ payable amount to sender
    msg.sender.transfer(_payoutAmount);
    getContractAddress("PoaLogger").call(
      abi.encodeWithSignature(
        "logClaim(address,uint256)",
        msg.sender,
        _payoutAmount
      )
    );

    return _payoutAmount;
  }

  /**
   @notice Allow proof-of-custody IPFS hash to be updated.
     This is used for both initial upload as well as changing
     or adding more documents later. The first proof-of-custody
     will be a legal document in which the custodian certifies
     that have received the actual securities that this contract
     tokenizes.
   */
  function updateProofOfCustody(bytes32[2] _ipfsHash)
    external
    onlyCustodian
    validIpfsHash(_ipfsHash)
    returns (bool)
  {
    require(
      stage == Stages.Active || stage == Stages.FundingSuccessful || stage == Stages.Terminated
    );
    proofOfCustody32_ = _ipfsHash;
    getContractAddress("PoaLogger").call(
      abi.encodeWithSignature(
        "logProofOfCustodyUpdated()",
        _ipfsHash
      )
    );

    return true;
  }

  /*******************************
  * end payout related functions *
  *******************************/

  /************************
  * start ERC20 overrides *
  ************************/

  /// @notice used for calculating starting balance once activated
  function startingBalance(address _address)
    public
    view
    returns (uint256)
  {
    if (stage < Stages.Active) {
      return 0;
    }

    if (isFiatInvestor(_address)) { 
      return fundedFiatAmountPerUserInTokens[_address];
    }

    if (isEthInvestor(_address)) {
      return fundedEthAmountPerUserInWei[_address]
        .mul(totalSupply_.sub(fundedFiatAmountInTokens))
        .div(fundedEthAmountInWei);
    }

    return 0;
  }

  /// @notice ERC20 compliant balanceOf: uses NoobCoin pattern: https://github.com/TovarishFin/NoobCoin
  function balanceOf(address _address)
    public
    view
    returns (uint256)
  {
    return startingBalance(_address)
      .add(receivedBalances[_address])
      .sub(spentBalances[_address]);
  }

  /**
    @notice ERC20 compliant transfer:
    - uses NoobCoin pattern combined with settling payout balances: https://github.com/TovarishFin/NoobCoin
  */
  function transfer(
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    isTransferWhitelisted(_to)
    isTransferWhitelisted(msg.sender)
    returns (bool)
  {
    // move perToken payout balance to unclaimedPayoutTotals
    settleUnclaimedPerTokenPayouts(msg.sender, _to);

    require(_to != address(0));
    require(_value <= balanceOf(msg.sender));
    spentBalances[msg.sender] = spentBalances[msg.sender].add(_value);
    receivedBalances[_to] = receivedBalances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);

    return true;
  }

  /**
    @notice ERC20 compliant transferFrom:
    - uses NoobCoin pattern combined with settling payout balances: https://github.com/TovarishFin/NoobCoin
  */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    isTransferWhitelisted(_to)
    isTransferWhitelisted(_from)
    returns (bool)
  {
    // move perToken payout balance to unclaimedPayoutTotals
    settleUnclaimedPerTokenPayouts(_from, _to);

    require(_to != address(0));
    require(_value <= balanceOf(_from));
    require(_value <= allowed[_from][msg.sender]);
    spentBalances[_from] = spentBalances[_from].add(_value);
    receivedBalances[_to] = receivedBalances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);

    return true;
  }

  /**
    @notice ERCO compliant approve
  */
  function approve(
    address _spender,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);

    return true;
  }

  /**
    @notice openZeppelin implementation of increaseApproval
  */
  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;
  }

  /**
    @notice openZeppelin implementation of decreaseApproval
  */
  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;
  }

  /**
  @notice ERC20 compliant allowance
  */
  function allowance(
    address _owner,
    address _spender
  )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /************************
  * start ERC20 overrides *
  ************************/

  /// @notice forward any non-matching function calls to poaCrowdsaleMaster
  function()
    external
    payable
  {
    assembly {
      // load value using *_slot suffix
      let _poaCrowdsaleMaster := sload(poaCrowdsaleMaster_slot)
      // calldatacopy(t, f, s)
      calldatacopy(
        0x0, // t = mem position to
        0x0, // f = mem position from
        calldatasize // s = size bytes
      )

      // delegatecall(g, a, in, insize, out, outsize) => 0 on error 1 on success
      let result := delegatecall(
        gas, // g = gas
        _poaCrowdsaleMaster, // a = address
        0x0, // in = mem in  mem[in..(in+insize)
        calldatasize, // insize = mem insize  mem[in..(in+insize)
        0x0, // out = mem out  mem[out..(out+outsize)
        0 // outsize = mem outsize  mem[out..(out+outsize)
      )

      // check if call was a success and return if no errors & revert if errors
      if iszero(result) {
        revert(0, 0)
      }

      // returndatacopy(t, f, s)
      returndatacopy(
        0x0, // t = mem position to
        0x0,  // f = mem position from
        returndatasize // s = size bytes
      )

      return(
        0x0,
        returndatasize
      )
    }
  }
}