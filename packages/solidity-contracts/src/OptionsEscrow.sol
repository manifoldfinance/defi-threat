/**
 * Source Code first verified at https://etherscan.io on Thursday, April 4, 2019
 (UTC) */

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

/**
 * @title ERC20
 * @dev ERC20 token interface
 */
 contract ERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
 }

/**
 * @title OptionsEscrow
 * @dev Escrow that holds tokens for a beneficiary with various vesting schedules and strike prices
 * The contract owner may grant options and reclaim tokens from expired options.
 */

contract OptionsEscrow is Ownable {
    using SafeMath for uint;

    struct Option {
        address beneficiary;
        uint tokenAmount;
        uint strikeMultiple;
        uint128 vestUntil;
        uint128 expiration;
    }

    address public token;
    uint public issuedTokens;
    uint64 public optionsCount;
    mapping (address => Option) public grantedOptions;

    event GrantOption(address indexed beneficiary, uint tokenAmount, uint strikeMultiple, uint128 vestUntil, uint128 expiration);
    event ExerciseOption(address indexed beneficiary, uint exercisedAmount, uint strikeMultiple);
    event ReclaimOption(address indexed beneficiary);

    /**
     * @dev Constructor.
     * @param _token The token for which options are being granted.
     */
    constructor(address _token) public {
        /* require(token != address(0)); */

        token = _token;
        issuedTokens = 0;
        optionsCount = 0;
    }

    /**
     * @dev Issue an option for a beneficiary with a custom amount, strike price, and vesting schedule
     *      NOTE: the use of a strike multiple means that the token-to-wei ration must always be positive
     *            this can be worked around be also adding a strikeDenomination
     * @param _beneficiary The recipient of the option,
     * @param _tokenAmount The amount of tokens available to be claimed
     * @param _strikeMultiple The amount of tokens for each wei provided
     * @param _vestUntil The timestamp (epoch in seconds) that the option becomes exercisable
     * @param _expiration The timestamp (epoch in seconds) that the option is no longer exercisable
     */
    function issueOption(address _beneficiary,
                            uint _tokenAmount,
                            uint _strikeMultiple,
                         uint128 _vestUntil,
                         uint128 _expiration) onlyOwner public {
        uint _issuedTokens = issuedTokens.add(_tokenAmount);

        require(_tokenAmount > 0 &&
                _expiration > _vestUntil &&
                _vestUntil > block.timestamp &&
                ERC20(token).balanceOf(this) > _issuedTokens);

        Option memory option = Option(_beneficiary, _tokenAmount, _strikeMultiple, _vestUntil, _expiration);

        grantedOptions[_beneficiary] = option;
        optionsCount++;
        issuedTokens = _issuedTokens;

        emit GrantOption(_beneficiary, _tokenAmount, _strikeMultiple, _vestUntil, _expiration);
    }

    /**
     * @dev Allows the beneficiary to exercise a vested option.
     *      The option can be partially exercised.
     */
    function () public payable {
        Option storage option = grantedOptions[msg.sender];

        require(option.beneficiary == msg.sender &&
                option.vestUntil <= block.timestamp &&
                option.expiration > block.timestamp &&
                option.tokenAmount > 0);

        uint amountExercised = msg.value.mul(option.strikeMultiple);
        if(amountExercised > option.tokenAmount) {
            amountExercised = option.tokenAmount;
        }

        option.tokenAmount = option.tokenAmount.sub(amountExercised);
        issuedTokens = issuedTokens.sub(amountExercised);
        require(ERC20(token).transfer(msg.sender, amountExercised));

        emit ExerciseOption(msg.sender, amountExercised, option.strikeMultiple);
    }

    /**
     * @dev Allows the owner to reclaim tokens from a list of options that have expired
     * @param beneficiaries An array of beneficiary addresses
     */
    function reclaimExpiredOptionTokens(address[] beneficiaries) public onlyOwner returns (uint reclaimedTokenAmount) {
        reclaimedTokenAmount = 0;
        for (uint i=0; i<beneficiaries.length; i++) {
            Option storage option = grantedOptions[beneficiaries[i]];
            if (option.expiration <= block.timestamp) {
                reclaimedTokenAmount = reclaimedTokenAmount.add(option.tokenAmount);
                option.tokenAmount = 0;

                emit ReclaimOption(beneficiaries[i]);
            }
        }
        issuedTokens = issuedTokens.sub(reclaimedTokenAmount);
        require(ERC20(token).transfer(owner, reclaimedTokenAmount));
    }

    /**
     * @dev Allows the owner to reclaim tokens that have not been issued
     */
    function reclaimUnissuedTokens() public onlyOwner returns (uint reclaimedTokenAmount) {
        reclaimedTokenAmount = ERC20(token).balanceOf(this) - issuedTokens;
        require(ERC20(token).transfer(owner, reclaimedTokenAmount));
    }

    /**
     * @dev Allows the owner to withdraw eth from exercised options
     */
    function withdrawEth() public onlyOwner {
        owner.transfer(address(this).balance);
    }

    /**
     * @dev Constant getter to see details of an option
     * @param _beneficiary The address of beneficiary
     */
    function getOption(address _beneficiary) public constant returns(address beneficiary,
                                                          uint tokenAmount,
                                                          uint strikeMultiple,
                                                          uint128 vestUntil,
                                                          uint128 expiration) {
        Option memory option = grantedOptions[_beneficiary];
        beneficiary = option.beneficiary;
        tokenAmount = option.tokenAmount;
        strikeMultiple = option.strikeMultiple;
        vestUntil = option.vestUntil;
        expiration = option.expiration;
    }
}