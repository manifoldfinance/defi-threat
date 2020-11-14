/**
 * Source Code first verified at https://etherscan.io on Monday, April 8, 2019
 (UTC) */

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

// File: contracts/PoaCrowdsale.sol

pragma solidity 0.4.24;



/* solium-disable security/no-block-members */

/**
  @title This contract acts as a master copy for use with PoaProxy in conjunction
  with PoaToken. Storage is assumed to be set on PoaProxy through
  delegatecall in fallback function. This contract handles the
  crowdsale functionality of PoaProxy. Inherited PoaCommon dictates
  common storage slots as well as common functions used by both PoaToken
  and PoaCrowdsale.
*/
contract PoaCrowdsale is PoaCommon {

  uint256 public constant crowdsaleVersion = 1;

  // Number of digits included during the percent calculation
  uint256 public constant precisionOfPercentCalc = 18;

  event Unpause();

  /******************
  * start modifiers *
  ******************/

  /// @notice Ensure that the contract has not timed out
  modifier checkTimeout() {
    uint256 fundingDeadline = startTimeForFundingPeriod
      .add(durationForFiatFundingPeriod)
      .add(durationForEthFundingPeriod);
    uint256 activationDeadline = fundingDeadline.add(durationForActivationPeriod);

    if (
      (stage <= Stages.EthFunding && block.timestamp >= fundingDeadline) ||
      (stage == Stages.FundingSuccessful && block.timestamp >= activationDeadline)
    ) {
      enterStage(Stages.TimedOut);
    }

    _;
  }

  /// @notice Ensure that a buyer is whitelisted before buying
  modifier isAddressWhitelisted(address _address) {
    require(isWhitelisted(_address));
    _;
  }

  /****************
  * end modifiers *
  ****************/

  /**
    @notice Proxied contracts cannot have constructors. This works in place
    of the constructor in order to initialize the contract storage.

    @param _fiatCurrency32 bytes32 of fiat currency string
    @param _startTimeForFundingPeriod beginning of the sale as UNIX timestamp
    @param _durationForFiatFundingPeriod duration of the fiat sale
    @param _durationForEthFundingPeriod duration of the ETH sale
    @param _durationForActivationPeriod timeframe for the custodian to activate the token
    @param _fundingGoalInCents funding goal in fiat cents (e.g. a €10,000 funding goal would be '1000000')
  */
  function initializeCrowdsale(
    bytes32 _fiatCurrency32,
    uint256 _startTimeForFundingPeriod,
    uint256 _durationForFiatFundingPeriod,
    uint256 _durationForEthFundingPeriod,
    uint256 _durationForActivationPeriod,
    uint256 _fundingGoalInCents
  )
    external
    returns (bool)
  {
    // ensure that token has already been initialized
    require(tokenInitialized);
    // ensure that crowdsale has not already been initialized
    require(!crowdsaleInitialized);

    // validate and initialize parameters in sequential storage
    setFiatCurrency(_fiatCurrency32);
    setStartTimeForFundingPeriod(_startTimeForFundingPeriod);
    setDurationForActivationPeriod(_durationForActivationPeriod);
    setFundingGoalInCents(_fundingGoalInCents);

    // By checking that both durations are not 0, we can skip the setters
    // if the respective duration is 0. Since the setter functions are
    // validating, this avoids a special case where setting
    // `_durationForFiatFundingPeriod` fails in case its value is 0, because
    // `durationForEthFundingPeriod` is already 0.
    require(_durationForFiatFundingPeriod + _durationForEthFundingPeriod > 0);
    if (_durationForFiatFundingPeriod > 0) {
      setDurationForFiatFundingPeriod(_durationForFiatFundingPeriod);
    }
    if (_durationForEthFundingPeriod > 0) {
      setDurationForEthFundingPeriod(_durationForEthFundingPeriod);
    }

    // set crowdsaleInitialized to true so cannot be initialized again
    crowdsaleInitialized = true;

    return true;
  }

  /*****************************************
   * external setters for `Stages.Preview` *
   *****************************************/

  /**
   * @notice Update fiat currency
   * @dev Only allowed in `Stages.Preview` by Issuer
   * @param _newFiatCurrency32 The new fiat currency
   *        in symbol notation (e.g. EUR, GBP, USD, etc.)
   */
  function updateFiatCurrency(bytes32 _newFiatCurrency32)
    external
    onlyIssuer
    atStage(Stages.Preview)
  {
    setFiatCurrency(_newFiatCurrency32);
  }

  /**
   * @notice Update funding goal in cents
   * @dev Only allowed in `Stages.Preview` stage by Issuer
   * @param _newFundingGoalInCents The new funding goal in
   *        cents
   */
  function updateFundingGoalInCents(uint256 _newFundingGoalInCents)
    external
    onlyIssuer
    atStage(Stages.Preview)
  {
    setFundingGoalInCents(_newFundingGoalInCents);
  }

  /**
   * @notice Update start time for funding period
   * @dev Only allowed in `Stages.Preview` stage by Issuer
   * @param _newStartTimeForFundingPeriod The new start
   *        time for funding period as UNIX timestamp in seconds
   */
  function updateStartTimeForFundingPeriod(uint256 _newStartTimeForFundingPeriod)
    external
    onlyIssuer
    atStage(Stages.Preview)
  {
    setStartTimeForFundingPeriod(_newStartTimeForFundingPeriod);
  }

  /**
   * @notice Update duration for fiat funding period
   * @dev Only allowed in `Stages.Preview` stage by Issuer
   * @param _newDurationForFiatFundingPeriod The new duration
   *        for fiat funding period as seconds
   */
  function updateDurationForFiatFundingPeriod(uint256 _newDurationForFiatFundingPeriod)
    external
    onlyIssuer
    atStage(Stages.Preview)
  {
    setDurationForFiatFundingPeriod(_newDurationForFiatFundingPeriod);
  }

  /**
   * @notice Update duration for ETH funding period
   * @dev Only allowed in `Stages.Preview` stage by Issuer
   * @param _newDurationForEthFundingPeriod The new duration
   *        for ETH funding period as seconds
   */
  function updateDurationForEthFundingPeriod(uint256 _newDurationForEthFundingPeriod)
    external
    onlyIssuer
    atStage(Stages.Preview)
  {
    setDurationForEthFundingPeriod(_newDurationForEthFundingPeriod);
  }

  /**
   * @notice Update duration for activation period
   * @dev Only allowed in `Stages.Preview` stage by Issuer
   * @param _newDurationForActivationPeriod The new duration
   *        for ETH funding period in seconds
   */
  function updateDurationForActivationPeriod(uint256 _newDurationForActivationPeriod)
    external
    onlyIssuer
    atStage(Stages.Preview)
  {
    setDurationForActivationPeriod(_newDurationForActivationPeriod);
  }

  /*********************************************
   * end external setters for `Stages.Preview` *
   *********************************************/

  /*******************************
   * internal validating setters *
   *******************************/

  /**
   * @notice Set fiat currency
   * @param _newFiatCurrency32 The new fiat currency
   *        in symbol notation (e.g. EUR, GBP, USD, etc.)
   */
  function setFiatCurrency(bytes32 _newFiatCurrency32)
    internal
  {
    require(_newFiatCurrency32 != bytes32(0));
    require(_newFiatCurrency32 != fiatCurrency32);

    fiatCurrency32 = _newFiatCurrency32;

    // For any fiat currency, we require its fiat rate to be already initialized
    require(getFiatRate() > 0);
  }

  /**
   * @notice Set funding goal in cents
   * @dev Funding goal represents a fiat amount in cent
   *      notation. E.g., `140123` represents 1401.23
   * @param _newFundingGoalInCents The new funding goal in
   *        cents
   */
  function setFundingGoalInCents(uint256 _newFundingGoalInCents)
    internal
  {
    require(_newFundingGoalInCents < totalSupply_);
    require(_newFundingGoalInCents != fundingGoalInCents);
    require(_newFundingGoalInCents > 0);

    fundingGoalInCents = _newFundingGoalInCents;
  }

  /**
   * @notice Set start time for funding period
   * @dev start time must be future time
   * @param _newStartTimeForFundingPeriod The new start
   *        time for funding period as UNIX timestamp in seconds
   */
  function setStartTimeForFundingPeriod(uint256 _newStartTimeForFundingPeriod)
    internal
  {
    require(_newStartTimeForFundingPeriod > block.timestamp);
    require(_newStartTimeForFundingPeriod != startTimeForFundingPeriod);

    startTimeForFundingPeriod = _newStartTimeForFundingPeriod;
  }

  /**
   * @notice Set duration for fiat funding period
   * @dev Duration must be either 0 (skips fiat funding) or at least 3 days,
   *      which corresponds to the approx. processing time of a wire transfer
   * @param _newDurationForFiatFundingPeriod The new duration
   *        for fiat funding period as seconds
   */
  function setDurationForFiatFundingPeriod(uint256 _newDurationForFiatFundingPeriod)
    internal
  {
    // Check if `_newDurationForFiatFundingPeriod` is at least 3 days. If set
    // to 0 (skip fiat funding), the duration for ETH funding must be non-zero.
    require(
      _newDurationForFiatFundingPeriod >= (3 days) ||
      (
        _newDurationForFiatFundingPeriod == 0 &&
        durationForEthFundingPeriod != 0
      )
    );
    require(_newDurationForFiatFundingPeriod != durationForFiatFundingPeriod);

    durationForFiatFundingPeriod = _newDurationForFiatFundingPeriod;
  }

  /**
   * @notice Set duration for ETH funding period
   * @dev Duration must be 0 (skips ETH funding) or at least 1 day
   * @param _newDurationForEthFundingPeriod The new duration
   *        for ETH funding period as seconds
   */
  function setDurationForEthFundingPeriod(uint256 _newDurationForEthFundingPeriod)
    internal
  {
    // Check if `_newDurationForEthFundingPeriod` is at least 1 day. If set
    // to 0 (skip ETH funding), the duration for fiat funding must be non-zero.
    require(
      _newDurationForEthFundingPeriod >= (1 days) ||
      (
        _newDurationForEthFundingPeriod == 0 &&
        durationForFiatFundingPeriod != 0
      )
    );
    require(_newDurationForEthFundingPeriod != durationForEthFundingPeriod);

    durationForEthFundingPeriod = _newDurationForEthFundingPeriod;
  }

  /**
   * @notice Set duration for activation period
   * @dev Duration must be longer than 1 week
   * @param _newDurationForActivationPeriod The new duration
   *        for ETH funding period in seconds
   */
  function setDurationForActivationPeriod(uint256 _newDurationForActivationPeriod)
    internal
  {
    // Check if `_newDurationForActivationPeriod` is at least 1 week.
    require(_newDurationForActivationPeriod >= (1 weeks));
    require(_newDurationForActivationPeriod != durationForActivationPeriod);

    durationForActivationPeriod = _newDurationForActivationPeriod;
  }

  /***********************************
   * end internal validating setters *
   ***********************************/

  /****************************
  * start lifecycle functions *
  ****************************/

  /// @notice Used for moving contract into `Stages.FiatFunding` where fiat purchases can be made
  function startFiatSale()
    external
    atStage(Stages.PreFunding)
    returns (bool)
  {
    // To save gas, create copies in memory to not have to read these
    // variables from storage twice
    uint256 _startTimeForFundingPeriod = startTimeForFundingPeriod;
    uint256 _durationForFiatFundingPeriod = durationForFiatFundingPeriod;

    // Check if fiat funding is intended
    require(_durationForFiatFundingPeriod > 0);

    // Check if funding period has started
    require(_startTimeForFundingPeriod <= block.timestamp);

    // Check if fiat funding period has not ended yet
    require(block.timestamp < _startTimeForFundingPeriod + _durationForFiatFundingPeriod);

    enterStage(Stages.FiatFunding);

    return true;
  }

  /// @notice Used for starting ETH sale as long as `startTimeForFundingPeriod` +
  // `durationForFiatFundingPeriod` has passed.
  function startEthSale()
    external
    atEitherStage(Stages.PreFunding, Stages.FiatFunding)
    returns (bool)
  {
    // To save gas, create copies in memory to not have to read these
    // variables from storage twice
    uint256 _startTimeForEthFundingPeriod = startTimeForFundingPeriod + durationForFiatFundingPeriod;
    uint256 _durationForEthFundingPeriod = durationForEthFundingPeriod;

    // Check if ETH funding is intended
    require(_durationForEthFundingPeriod > 0);

    // Check if ETH funding period is reached. If `durationForFiatFundingPeriod`
    // is 0, the ETH funding period can start as soon as `startTimeForFundingPeriod`
    // is reached.
    require(_startTimeForEthFundingPeriod <= block.timestamp);

    // Check if ETH funding period has not ended yet
    require(block.timestamp < _startTimeForEthFundingPeriod + _durationForEthFundingPeriod);

    enterStage(Stages.EthFunding);

    return true;
  }

  /// @notice Used for the calculation of token amount to be given to FIAT investor
  function calculateTokenAmountForAmountInCents(uint256 _amountInCents)
    public
    view
    returns (uint256)
  {
    //_percentOfFundingGoal multipled by precisionOfPercentCalc to get a more accurate result
    uint256 _percentOfFundingGoal = percent(
      _amountInCents,
      fundingGoalInCents,
      precisionOfPercentCalc
    );

    return totalSupply_
      .mul(_percentOfFundingGoal)
      .div(10 ** precisionOfPercentCalc);
  }

  /**
    @notice Used for fiat investments during 'FiatFunding' stage.
    All fiat balances are updated manually by the custodian.
   */
  function buyWithFiat(
    address _fiatInvestor,
    uint256 _amountInCents
  )
    external
    atStage(Stages.FiatFunding)
    isAddressWhitelisted(_fiatInvestor)
    onlyCustodian
    returns (bool)
  {
    require(_amountInCents > 0);

    fundedFiatAmountInCents = fundedFiatAmountInCents.add(_amountInCents);

    // Do not allow investments that exceed the funding goal
    require(fundedFiatAmountInCents <= fundingGoalInCents);

    // Update total funded fiat amount in tokens
    uint256 _tokenAmount = calculateTokenAmountForAmountInCents(_amountInCents);
    fundedFiatAmountInTokens = fundedFiatAmountInTokens.add(_tokenAmount);

    // Update balance of fiat investor
    fundedFiatAmountPerUserInTokens[_fiatInvestor] = fundedFiatAmountPerUserInTokens[_fiatInvestor]
      .add(_tokenAmount);

    // If we reached the funding goal, enter stage `FundingSuccessful`
    if (fundedFiatAmountInCents == fundingGoalInCents) {
      enterStage(Stages.FundingSuccessful);
    }

    return true;
  }

  function removeFiat(
    address _fiatInvestor,
    uint256 _amountInCents
  )
    external
    atStage(Stages.FiatFunding)
    onlyCustodian
    returns (bool)
  {
    require(_amountInCents > 0);

    uint256 _tokenAmount = calculateTokenAmountForAmountInCents(_amountInCents);

    // Update total funded fiat amounts
    fundedFiatAmountInCents = fundedFiatAmountInCents.sub(_amountInCents);
    fundedFiatAmountInTokens = fundedFiatAmountInTokens.sub(_tokenAmount);

    // Update individual balance of fiat investor
    fundedFiatAmountPerUserInTokens[_fiatInvestor] = fundedFiatAmountPerUserInTokens[_fiatInvestor].sub(_tokenAmount);

    return true;
  }

  /// @notice Used for funding through ETH during the 'EthFunding' stage
  function buyWithEth()
    external
    payable
    checkTimeout
    atStage(Stages.EthFunding)
    isAddressWhitelisted(msg.sender)
    returns (bool)
  {
    // prevent FiatFunding addresses from contributing to ETH funding to keep total supply correct
    require(!isFiatInvestor(msg.sender));

    /**
     * In case ETH went up in value against fiat since the last buyWithEth(), we
     * might have reached our funding goal already without considering `msg.value`.
     * If so, move to stage `FundingSuccessful` and fully refund `msg.value`.
     **/
    if (isFundingGoalReached(0)) {
      enterStage(Stages.FundingSuccessful);

      if (msg.value > 0) {
        msg.sender.transfer(msg.value);
      }

      return false;
    }

    /**
     * If this `buyWithEth()` hits the funding goal, we refund all wei that exceed
     * the goal and keep only the missing `_fundAmount` inside the contract. Otherwise,
     * the `_fundAmount` will be equal to `msg.value`.
     **/
    (uint256 _fundAmount, uint256 _refundAmount) = calculateFundingAmount(msg.value);
    if (isFundingGoalReached(msg.value)) {
      enterStage(Stages.FundingSuccessful);

      if (_refundAmount > 0) {
        msg.sender.transfer(_refundAmount);
      }
    }

    /**
     * Track investment amount per user. In case of non-successful funding,
     * an invenstor needs to be able to reclaim their funds.
     **/
    fundedEthAmountPerUserInWei[msg.sender] = fundedEthAmountPerUserInWei[msg.sender]
      .add(_fundAmount);
    fundedEthAmountInWei = fundedEthAmountInWei.add(_fundAmount);

    getContractAddress("PoaLogger").call(
      abi.encodeWithSignature("logBuy(address,uint256)", msg.sender, _fundAmount)
    );

    return true;
  }

  function calculateFundingAmount(uint256 _fullAmount)
    internal
    view
    returns (uint256, uint256)
  {
    if (isFundingGoalReached(_fullAmount)) {
      // Calculate Wei amount that exceeds funding goal
      uint256 _refundAmount = fiatCentsToWei(fundedFiatAmountInCents)
        .add(fundedEthAmountInWei)
        .add(_fullAmount)
        .sub(fiatCentsToWei(fundingGoalInCents));

      return (_fullAmount.sub(_refundAmount), _refundAmount);
    }

    return (_fullAmount, 0);
  }

  /// @notice Check if `fundingGoalInCents` is reached while allowing 1c tolerance
  function isFundingGoalReached(uint256 _withWeiAmount)
    public
    view
    returns (bool)
  {
    return fundingGoalInCents <=
      weiToFiatCents(
        fundedEthAmountInWei.add(_withWeiAmount)
      ).add(fundedFiatAmountInCents).add(1);
  }

  /// @notice Returns the total amount of fee needed for activation
  function calculateTotalFee()
    public
    view
    atStage(Stages.FundingSuccessful)
    returns (uint256)
  {
    uint256 _fundedFiatAmountInWei = fiatCentsToWei(fundedFiatAmountInCents);
    uint256 _fiatFee = calculateFee(_fundedFiatAmountInWei);
    uint256 _ethFee = calculateFee(fundedEthAmountInWei);

    return _fiatFee.add(_ethFee);
  }

  /**
   @notice Used for paying the activation fee.
   It is public because we want to enable any party to pay the fee.
   We need this flexibility because there are multiple scenarios:
     • Crypto-savvy issuers could pay the fee in ETH directly into the contract
     • Non-crypto-savvy issuers could pay the fee in Fiat to the custodian and
       the custodian pays the fee in ETH into the contract on their behalf
     • Non-crypto-savvy issuer AND custodian could ask Brickblock to help, pay the fee
       in Fiat to us, and we would then pay the fee in ETH into the contract for them
   */
  function payActivationFee()
    public
    payable
    atStage(Stages.FundingSuccessful)
    returns (bool)
  {
    // Prevent paying more than once
    require(isActivationFeePaid == false);

    // Calculate the percentage of the actual fee that was paid
    uint256 paidAmountToCalculatedFeeRatio = percent(msg.value, calculateTotalFee(), precisionOfPercentCalc);

    /*
     * Due to constant ETH <> Fiat price fluctuations, there can be small
     * deviations between the total fee that must be paid, which is denominated
     * in Fiat cents, and the actual fee that has been paid into the function,
     * which is denominated in Wei.
     *
     * We allow the difference between totalFee and actualFee to be up to 0.5%
     * For example, if the totalFee to be paid would be €1000 and the actual fee
     * that was paid in Wei is only worth €996 at the time of checking, we would
     * still accept it. €994.99 would throw because it's a deviation of more than 0.5%.
     */
    require(paidAmountToCalculatedFeeRatio > 1e18 - 5e15);
    require(paidAmountToCalculatedFeeRatio < 1e18 + 5e15);

    // Send fee to `FeeManager` where it gets converted into ACT and distributed to lockedBbk holders
    payFee(msg.value);

    // Set flag to true so this function can't be called in the future anymore
    isActivationFeePaid = true;

    return true;
  }

  /**
    @notice Activate token. This has the following effects:
      • Contract's ETH balance will become claimable by the issuer
      • Token will become tradable (via ERC20's unpause() function)
  */
  function activate()
    external
    checkTimeout
    onlyCustodian
    atStage(Stages.FundingSuccessful)
    returns (bool)
  {
    // activation fee must be paid before activating
    require(isActivationFeePaid);

    /*
     * A proof-of-custody document must be provided before activating.
     * This document will show investors that the custodian is in
     * posession of the actual asset/equity/shares being tokenized.
     */
    require(bytes(proofOfCustody()).length != 0);

    /*
     * Move token to the "Active" stage which will enable investors
     * to see their token balances via the `startingBalance()` function
     */
    enterStage(Stages.Active);

    /*
     * Make raised ETH funds, which is the balance of this contract,
     * claimable by the issuer via the claim() function.
     */
    unclaimedPayoutTotals[issuer] = unclaimedPayoutTotals[issuer]
      .add(address(this).balance);

    // Allow trading of tokens
    paused = false;
    emit Unpause();

    return true;
  }

  /**
   @notice Used for manually moving into the `TimedOut` in case no one has bought any tokens.
   If no `buyWithFiat()` or `buyWithEth()` occurs before the funding deadline, the token would
   be stuck in either the `FiatFunding` or `EthFunding` stage.
   Additionally, it can be used when the custodian hasn't called `activate()` before the
   `activationDeadline` or when no investor has called `reclaim()` after a timeout.
  */
  function manualCheckForTimeout()
    external
    atMaxStage(Stages.FundingSuccessful)
    checkTimeout
    returns (bool)
  {
    if (stage != Stages.TimedOut) {
      revert();
    }

    return true;
  }

  /**
   * @notice In case the funding goal is reached without an explicit buy,
   * most likely due to ETH appreciating in value over fiat, then this public
   * function can be manually called to tip the contract over into the
   * `FundingSuccessful` stage
   */
  function manualCheckForFundingSuccessful()
    public
    atStage(Stages.EthFunding)
    returns (bool)
  {
    if (isFundingGoalReached(0)) {
      enterStage(Stages.FundingSuccessful);
      return true;
    }

    return false;
  }

  /// @notice Users can reclaim their invested ETH if the funding goal was not met within the funding deadline
  function reclaim()
    external
    checkTimeout
    atStage(Stages.TimedOut)
    returns (bool)
  {
    require(!isFiatInvestor(msg.sender));
    totalSupply_ = 0;
    uint256 _refundAmount = fundedEthAmountPerUserInWei[msg.sender];
    fundedEthAmountPerUserInWei[msg.sender] = 0;
    require(_refundAmount > 0);
    fundedEthAmountInWei = fundedEthAmountInWei.sub(_refundAmount);
    msg.sender.transfer(_refundAmount);
    getContractAddress("PoaLogger").call(
      abi.encodeWithSignature(
        "logReClaim(address,uint256)",
        msg.sender,
        _refundAmount
      )
    );

    return true;
  }

  /**
    @notice When something goes wrong during the "PreFunding" or "FiatFunding"
    stages, this is an escape hatch to cancel the funding process.
    If the contract hits the "EthFunding" stage, this can no longer be used.

    This is a nuclear option and should only be used under exceptional
    circumstances, for example:
    - Asset gets damaged due to natural catastrophe
    - Legal issue arises with the asset
    - Issuer gets blacklisted during the funding phase
      due to fraudulent behavior
   */
  function cancelFunding()
    external
    onlyCustodian
    atMaxStage(Stages.FiatFunding)
    returns (bool)
  {
    enterStage(Stages.FundingCancelled);

    return true;
  }

  /**************************
  * end lifecycle functions *
  **************************/

  /**************************
  * start utility functions *
  **************************/

  /// @notice Convert to accurate percent using desired level of precision
  function percent(
    uint256 _numerator,
    uint256 _denominator,
    uint256 _precision
  )
    public
    pure
    returns (uint256)
  {
    // caution, check safe-to-multiply here
    uint256 _safeNumerator = _numerator.mul(uint256(10e27).rpow(_precision.add(1)));
    // with rounding of last digit
    uint256 _quotient = _safeNumerator.div(_denominator).add(5).div(10e27);
    return (_quotient);
  }

  /// @notice gas saving call to get fiat rate without interface
  function getFiatRate()
    public
    view
    returns (uint256 _fiatRate)
  {
    bytes4 _sig = bytes4(keccak256("getRate32(bytes32)"));
    address _exchangeRates = getContractAddress("ExchangeRates");
    bytes32 _fiatCurrency = keccak256(abi.encodePacked(fiatCurrency()));

    assembly {
      let _call := mload(0x40) // set _call to free memory pointer
      mstore(_call, _sig) // store _sig at _call pointer
      mstore(add(_call, 0x04), _fiatCurrency) // store _fiatCurrency at _call offset by 4 bytes for pre-existing _sig

      // staticcall(g, a, in, insize, out, outsize) => 0 on error 1 on success
      let success := staticcall(
        gas,             // g = gas: whatever was passed already
        _exchangeRates,  // a = address: address from getContractAddress
        _call,           // in = mem in  mem[in..(in+insize): set to free memory pointer
        0x24,            // insize = mem insize  mem[in..(in+insize): size of sig (bytes4) + bytes32 = 0x24
        _call,           // out = mem out  mem[out..(out+outsize): output assigned to this storage address
        0x20             // outsize = mem outsize  mem[out..(out+outsize): output should be 32byte slot (uint256 size = 0x20 = slot size 0x20)
      )

      // revert if not successful
      if iszero(success) {
        revert(0, 0)
      }

      _fiatRate := mload(_call) // assign result to return value
      mstore(0x40, add(_call, 0x24)) // advance free memory pointer by largest _call size
    }
  }

  /// @notice Returns fiat value in cents of given wei amount
  function weiToFiatCents(uint256 _wei)
    public
    view
    returns (uint256)
  {
    // get eth to fiat rate in cents from ExchangeRates
    return _wei.mul(getFiatRate()).div(1e18);
  }

  /// @notice Returns wei value from fiat cents
  function fiatCentsToWei(uint256 _cents)
    public
    view
    returns (uint256)
  {
    return _cents.mul(1e18).div(getFiatRate());
  }

  /// @notice Get funded ETH amount in cents
  function fundedEthAmountInCents()
    external
    view
    returns (uint256)
  {
    return weiToFiatCents(fundedEthAmountInWei);
  }

  /// @notice Get fundingGoal in wei
  function fundingGoalInWei()
    external
    view
    returns (uint256)
  {
    return fiatCentsToWei(fundingGoalInCents);
  }

  /************************
  * end utility functions *
  ************************/

  /************************
  * start regular getters *
  ************************/

  /// @notice Return converted string from bytes32 fiatCurrency32
  function fiatCurrency()
    public
    view
    returns (string)
  {
    return to32LengthString(fiatCurrency32);
  }

  /**********************
  * end regular getters *
  **********************/
}