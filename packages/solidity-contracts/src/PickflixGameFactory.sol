/**
 * Source Code first verified at https://etherscan.io on Thursday, May 9, 2019
 (UTC) */

pragma solidity ^0.4.24;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
  external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
  external returns (bool);

  function transferFrom(address from, address to, uint256 value)
  external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

interface IPickFlixToken {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
  external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
  external returns (bool);

  function transferFrom(address from, address to, uint256 value)
  external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );

  function closeNow() public;
  function kill() public;
  function rate() public view returns(uint256);
}


pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
   * @dev Multiplies two numbers, reverts on overflow.
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
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
   * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;
    return c;
  }

  /**
   * @dev Adds two numbers, reverts on overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }

  /**
   * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
   * reverts when dividing by zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}


pragma solidity ^0.4.24;



/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev Gets the balance of the specified address.
   * @param owner The address to query the balance of.
   * @return An uint256 representing the amount owned by the passed address.
   */
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
      address owner,
      address spender
      )
    public
    view
    returns (uint256)
    {
      return _allowed[owner][spender];
    }

  /**
   * @dev Transfer token for a specified address
   * @param to The address to transfer to.
   * @param value The amount to be transferred.
   */
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   */
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

  _allowed[msg.sender][spender] = value;
  emit Approval(msg.sender, spender, value);
  return true;
}

/**
 * @dev Transfer tokens from one address to another
 * @param from address The address which you want to send tokens from
 * @param to address The address which you want to transfer to
 * @param value uint256 the amount of tokens to be transferred
 */
function transferFrom(
    address from,
    address to,
    uint256 value
    )
  public
returns (bool)
{
  require(value <= _allowed[from][msg.sender]);

_allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
_transfer(from, to, value);
return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
function increaseAllowance(
    address spender,
    uint256 addedValue
    )
  public
returns (bool)
{
  require(spender != address(0));

  _allowed[msg.sender][spender] = (
    _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
function decreaseAllowance(
    address spender,
    uint256 subtractedValue
    )
  public
returns (bool)
{
  require(spender != address(0));

  _allowed[msg.sender][spender] = (
    _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
  * @dev Transfer token for a specified addresses
  * @param from The address to transfer from.
    * @param to The address to transfer to.
      * @param value The amount to be transferred.
      */
  function _transfer(address from, address to, uint256 value) internal {
    require(value <= _balances[from]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

  /**
  * @dev Internal function that mints an amount of the token and assigns it to
  * an account. This encapsulates the modification of balances such that the
  * proper events are emitted.
    * @param account The account that will receive the created tokens.
    * @param value The amount that will be created.
    */
  function _mint(address account, uint256 value) internal {
    require(account != 0);
    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

  /**
  * @dev Internal function that burns an amount of the token of a given
  * account.
    * @param account The account whose tokens will be burnt.
    * @param value The amount that will be burnt.
    */
  function _burn(address account, uint256 value) internal {
    require(account != 0);
    require(value <= _balances[account]);

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

  /**
  * @dev Internal function that burns an amount of the token of a given
  * account, deducting from the sender's allowance for said account. Uses the
  * internal burn function.
  * @param account The account whose tokens will be burnt.
    * @param value The amount that will be burnt.
    */
  function _burnFrom(address account, uint256 value) internal {
    require(value <= _allowed[account][msg.sender]);

    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      value);
      _burn(account, value);
  }
}


pragma solidity ^0.4.24;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an account access to this role
   */
  function add(Role storage role, address account) internal {
    require(account != address(0));
    role.bearer[account] = true;
  }

  /**
   * @dev remove an account's access to this role
   */
  function remove(Role storage role, address account) internal {
    require(account != address(0));
    role.bearer[account] = false;
  }

  /**
   * @dev check if an account has this role
   * @return bool
   */
  function has(Role storage role, address account)
  internal
  view
  returns (bool)
  {
    require(account != address(0));
    return role.bearer[account];
  }
}


pragma solidity ^0.4.24;


contract MinterRole {
  using Roles for Roles.Role;

  event MinterAdded(address indexed account);
  event MinterRemoved(address indexed account);

  Roles.Role private minters;

  constructor(address minter) public {
    if(minter == 0x0) {
      _addMinter(msg.sender);
    } else {
      _addMinter(minter);
    }
  }

  modifier onlyMinter() {
    require(isMinter(msg.sender), "Only minter can do this");
    _;
  }

  function isMinter(address account) public view returns (bool) {
    return minters.has(account);
  }

  function addMinter(address account) public onlyMinter {
    _addMinter(account);
  }

  function renounceMinter() public {
    _removeMinter(msg.sender);
  }

  function _addMinter(address account) internal {
    minters.add(account);
    emit MinterAdded(account);
  }

  function _removeMinter(address account) internal {
    minters.remove(account);
    emit MinterRemoved(account);
  }
}


pragma solidity ^0.4.24;



/**
 * @title ERC20Mintable
 * @dev ERC20 minting logic
 */
contract ERC20Mintable is ERC20, MinterRole {
  /**
   * @dev Function to mint tokens
   * @param to The address that will receive the minted tokens.
   * @param value The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address to,
    uint256 value
  )
  public
  onlyMinter
  returns (bool)
  {
    _mint(to, value);
    return true;
  }
}


pragma solidity ^0.4.24;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  )
  internal
  {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  )
  internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  )
  internal
  {
    require(token.approve(spender, value));
  }
}


pragma solidity ^0.4.24;




/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale,
 * allowing players to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conform
 * the base architecture for crowdsales. They are *not* intended to be modified / overridden.
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override
 * the methods to add functionality. Consider using 'super' where appropriate to concatenate
 * behavior.
 */
contract Crowdsale {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  // The token being sold
  IERC20 private _token;

  // Address where funds are collected
  address private _wallet;

  // How many token units a buyer gets per wei.
  // The rate is the conversion between wei and the smallest and indivisible token unit.
  // So, if you are using a rate of 1 with a ERC20Detailed token with 3 decimals called TOK
  // 1 wei will give you 1 unit, or 0.001 TOK.
  uint256 private _rate;

  // Amount of wei raised
  uint256 private _weiRaised;

  /**
  * Event for token purchase logging
  * @param purchaser who paid for the tokens
  * @param beneficiary who got the tokens
  * @param value weis paid for purchase
  * @param amount amount of tokens purchased
   */
  event TokensPurchased(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );

  /**
   * @param rate Number of token units a buyer gets per wei
   * @dev The rate is the conversion between wei and the smallest and indivisible
   * token unit. So, if you are using a rate of 1 with a ERC20Detailed token
   * with 3 decimals called TOK, 1 wei will give you 1 unit, or 0.001 TOK.
   * @param wallet Address where collected funds will be forwarded to
   * @param token Address of the token being sold
   */
  constructor(uint256 rate, address wallet, IERC20 token) public {
    require(rate > 0);
    require(wallet != address(0));
    require(token != address(0));

    _rate = rate;
    _wallet = wallet;
    _token = token;
  }

  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */
  function () external payable {
    buyTokens(msg.sender);
  }

  /**
   * @return the token being sold.
   */
  function token() public view returns(IERC20) {
    return _token;
  }

  /**
   * @return the address where funds are collected.
   */
  function wallet() public view returns(address) {
    return _wallet;
  }

  /**
   * @return the number of token units a buyer gets per wei.
   */
  function rate() public view returns(uint256) {
    return _rate;
  }

  /**
   * @return the mount of wei raised.
   */
  function weiRaised() public view returns (uint256) {
    return _weiRaised;
  }

  /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   * @param beneficiary Address performing the token purchase
   */
  function buyTokens(address beneficiary) public payable {

    uint256 weiAmount = msg.value;
    _preValidatePurchase(beneficiary, weiAmount);

    // calculate token amount to be created
    uint256 tokens = _getTokenAmount(weiAmount);

    // update state
    _weiRaised = _weiRaised.add(weiAmount);

    _processPurchase(beneficiary, tokens);
    emit TokensPurchased(
      msg.sender,
      beneficiary,
      weiAmount,
      tokens
    );

    _updatePurchasingState(beneficiary, weiAmount);

    _forwardFunds();
    _postValidatePurchase(beneficiary, weiAmount);
  }

  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------

  /**
   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use `super` in contracts that inherit from Crowdsale to extend their validations.
   * Example from CappedCrowdsale.sol's _preValidatePurchase method:
   *   super._preValidatePurchase(beneficiary, weiAmount);
   *   require(weiRaised().add(weiAmount) <= cap);
   * @param beneficiary Address performing the token purchase
   * @param weiAmount Value in wei involved in the purchase
   */
  function _preValidatePurchase(
    address beneficiary,
    uint256 weiAmount
  )
  internal
  {
    require(beneficiary != address(0));
    require(weiAmount != 0);
  }

  /**
  * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
  * @param beneficiary Address performing the token purchase
  * @param weiAmount Value in wei involved in the purchase
  */
  function _postValidatePurchase(
    address beneficiary,
    uint256 weiAmount
  )
  internal
  {
    // optional override
  }

  /**
  * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
  * @param beneficiary Address performing the token purchase
  * @param tokenAmount Number of tokens to be emitted
  */
  function _deliverTokens(
    address beneficiary,
    uint256 tokenAmount
  )
  internal
  {
    _token.safeTransfer(beneficiary, tokenAmount);
  }

  /**
  * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
  * @param beneficiary Address receiving the tokens
  * @param tokenAmount Number of tokens to be purchased
  */
  function _processPurchase(
    address beneficiary,
    uint256 tokenAmount
  )
  internal
  {
    _deliverTokens(beneficiary, tokenAmount);
  }

  /**
  * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
  * @param beneficiary Address receiving the tokens
  * @param weiAmount Value in wei involved in the purchase
   */
  function _updatePurchasingState(
    address beneficiary,
    uint256 weiAmount
  )
  internal
  {
    // optional override
  }

  /**
  * @dev Override to extend the way in which ether is converted to tokens.
  * @param weiAmount Value in wei to be converted into tokens
  * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 weiAmount)
  internal view returns (uint256)
  {
    return weiAmount.mul(_rate);
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds() internal {
    _wallet.transfer(msg.value);
  }
}


pragma solidity ^0.4.24;



/**
 * @title TimedCrowdsale
 * @dev Crowdsale accepting contributions only within a time frame.
 */
contract TimedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 private _openingTime;
  uint256 internal _closingTime;

  /**
   * @dev Reverts if not in crowdsale time range.
   */
  modifier onlyWhileOpen {
    require(isOpen(), "Crowdsale is no longer open");
    _;
  }

  /**
   * @dev Constructor, takes crowdsale opening and closing times.
   * @param openingTime Crowdsale opening time
   * @param closingTime Crowdsale closing time
   */
  constructor(uint256 openingTime, uint256 closingTime) public {
    // solium-disable-next-line security/no-block-members
    require(openingTime >= block.timestamp, "The Crowdsale must not start in the past");
    require(closingTime >= openingTime, "The Crowdsale must end in the future");

    _openingTime = openingTime;
    _closingTime = closingTime;
  }

  /**
   * @return the crowdsale opening time.
   */
  function openingTime() public view returns(uint256) {
    return _openingTime;
  }

  /**
   * @return the crowdsale closing time.
   */
  function closingTime() public view returns(uint256) {
    return _closingTime;
  }

  /**
   * @return true if the crowdsale is open, false otherwise.
   */
  function isOpen() public view returns (bool) {
    // solium-disable-next-line security/no-block-members
    return block.timestamp >= _openingTime && block.timestamp <= _closingTime;
  }

  /**
   * @dev Checks whether the period in which the crowdsale is open has already elapsed.
   * @return Whether crowdsale period has elapsed
   */
  function hasClosed() public view returns (bool) {
    // solium-disable-next-line security/no-block-members
    return block.timestamp > _closingTime;
  }

  /**
   * @dev Extend parent behavior requiring to be within contributing period
   * @param beneficiary Token purchaser
   * @param weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(
    address beneficiary,
    uint256 weiAmount
  )
  internal
  onlyWhileOpen
  {
    super._preValidatePurchase(beneficiary, weiAmount);
  }

}


pragma solidity ^0.4.24;


/**
 * @title TimedCrowdsale
 * @dev Crowdsale accepting contributions only within a time frame.
 */
contract DeadlineCrowdsale is TimedCrowdsale {
  constructor(uint256 closingTime) public TimedCrowdsale(block.timestamp, closingTime) { }
}


pragma solidity ^0.4.24;



/**
 * @title MintedCrowdsale
 * @dev Extension of Crowdsale contract whose tokens are minted in each purchase.
 * Token ownership should be transferred to MintedCrowdsale for minting.
 */
contract MintedCrowdsale is Crowdsale {

  /**
   * @dev Overrides delivery by minting tokens upon purchase.
   * @param beneficiary Token purchaser
   * @param tokenAmount Number of tokens to be minted
   */
  function _deliverTokens(
    address beneficiary,
    uint256 tokenAmount
  )
  internal
  {
    // Potentially dangerous assumption about the type of the token.
    require(
      ERC20Mintable(address(token())).mint(beneficiary, tokenAmount));
  }
}


pragma solidity ^0.4.23;





contract PickFlixToken is ERC20Mintable, DeadlineCrowdsale, MintedCrowdsale {

  string public name = "";
  string public symbol = "";
  string public externalID = "";
  uint public decimals = 18;

  constructor(string _name, string _symbol, uint256 _rate, address _wallet, uint _closeDate, string _externalID)
  public
  Crowdsale(_rate, _wallet, this)
  ERC20Mintable()
  MinterRole(this)
  DeadlineCrowdsale(_closeDate)  {
    externalID = _externalID;
    name = _name;
    symbol = _symbol;
  }

  function closeNow() public {
    require(msg.sender == wallet(), "Must be the creator to close this token");
    _closingTime = block.timestamp - 1;
  }

  function kill() public {
    require(msg.sender == wallet(), "Must be the creator to kill this token");
    require(balanceOf(wallet()) >=  0, "Must have no tokens, or the creator owns all the tokens");
    selfdestruct(wallet());
  }
}


pragma solidity ^0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
  * @return the address of the owner.
  */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
  * @dev Throws if called by any account other than the owner.
  */
  modifier onlyOwner() {
    require(isOwner(), "Must be owner");
    _;
  }

  /**
  * @return true if `msg.sender` is the owner of the contract.
  */
  function isOwner() public view returns(bool) {
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
    require(newOwner != address(0), "Must provide a valid owner address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}


pragma solidity ^0.4.23;




contract PickflixGameMaster is Ownable {
  // this library helps protect against overflows for large integers
  using SafeMath for uint256;

  // fires off events for receiving and sending Ether
  event Sent(address indexed payee, uint256 amount, uint256 balance);
  event Received(address indexed payer, uint256 amount, uint256 balance);

  string public gameName;
  uint public openDate;
  uint public closeDate;
  bool public gameDone;
  
  // create a mapping for box office totals for particular movies
  // address is the token contract address
  mapping (address => uint256) public boxOfficeTotals;

  // let's make a Movie struct to make all of this code cleaner
  struct Movie {
    uint256 boxOfficeTotal;
    uint256 totalPlayerRewards;
    bool accepted;
  }
  // map token addresses to Movie structs
  mapping (address => Movie) public movies;

  // count the total number of tokens issued
  uint256 public tokensIssued = 0; // this number will change

  // more global variables, for calculating payouts and game results
  uint256 public oracleFee = 0;
  uint256 public oracleFeePercent = 0;
  uint256 public totalPlayerRewards = 0;
  uint256 public totalBoxOffice = 0;


  // owner is set to original message sender during contract migration
  constructor(string _gameName, uint _closeDate, uint _oracleFeePercent) Ownable() public {
    gameName = _gameName;
    closeDate = _closeDate;
    openDate = block.timestamp;
    gameDone = false;
    oracleFeePercent = _oracleFeePercent;
  }

  /**
    * calculate a percentage with parts per notation.
    * the value returned will be in terms of 10e precision
  */
  function percent(uint numerator, uint denominator, uint precision) private pure returns(uint quotient) {
    // caution, keep this a private function so the numbers are safe
    uint _numerator = (numerator * 10 ** (precision+1));
    // with rounding of last digit
    uint _quotient = ((_numerator / denominator)) / 10;
    return ( _quotient);
  }

  /**
  * @dev wallet can receive funds.
  */
  function () public payable {
    emit Received(msg.sender, msg.value, address(this).balance);
  }

  /**
  * @dev wallet can send funds
  */
  function sendTo(address _payee, uint256 _amount) private {
    require(_payee != 0 && _payee != address(this), "Burning tokens and self transfer not allowed");
    require(_amount > 0, "Must transfer greater than zero");
    _payee.transfer(_amount);
    emit Sent(_payee, _amount, address(this).balance);
  }

  /**
  * @dev function to see the balance of Ether in the wallet
  */
  function balanceOf() public view returns (uint256) {
    return address(this).balance;
  }

  /**
  * @dev function for the player to cash in tokens
  */
  function redeemTokens(address _player, address _tokenAddress) public returns (bool success) {
    require(acceptedToken(_tokenAddress), "Token must be a registered token");
    require(block.timestamp >= closeDate, "Game must be closed");
    require(gameDone == true, "Can't redeem tokens until results have been uploaded");
    // instantiate a token contract instance from the deployed address
    IPickFlixToken _token = IPickFlixToken(_tokenAddress);
    // check token allowance player has given to GameMaster contract
    uint256 _allowedValue = _token.allowance(_player, address(this));
    // transfer tokens to GameMaster
    _token.transferFrom(_player, address(this), _allowedValue);
    // check balance of tokens actually transfered
    uint256 _transferedTokens = _allowedValue;
    // calculate the percentage of the total token supply represented by the transfered tokens
    uint256 _playerPercentage = percent(_transferedTokens, _token.totalSupply(), 4);
    // calculate the particular player's rewards, as a percentage of total player rewards for the movie
    uint256 _playerRewards = movies[_tokenAddress].totalPlayerRewards.mul(_playerPercentage).div(10**4);
    // pay out ETH to the player
    sendTo(_player, _playerRewards);
    // return that the function succeeded
    return true;
  }

  // checks if a token is an accepted game token
  function acceptedToken(address _tokenAddress) public view returns (bool) {
    return movies[_tokenAddress].accepted;
  }

  /**
  * @dev functions to calculate game results and payouts
  */
  function calculateTokensIssued(address _tokenAddress) private view returns (uint256) {
    IPickFlixToken _token = IPickFlixToken(_tokenAddress);
    return _token.totalSupply();
  }

  function closeToken(address _tokenAddress) private {
    IPickFlixToken _token = IPickFlixToken(_tokenAddress);
    _token.closeNow();
  }

  function calculateTokenRate(address _tokenAddress) private view returns (uint256) {
    IPickFlixToken _token = IPickFlixToken(_tokenAddress);
    return _token.rate();
  }

  // "15" in this function means 15%. Change that number to raise or lower
  // the oracle fee.
  function calculateOracleFee() private view returns (uint256) {
    return balanceOf().mul(oracleFeePercent).div(100);
  }

  // this calculates how much Ether is available for player rewards
  function calculateTotalPlayerRewards() private view returns (uint256) {
    return balanceOf().sub(oracleFee);
  }

  // this calculates the total box office earnings of all movies in USD
  function calculateTotalBoxOffice(uint256[] _boxOfficeTotals) private pure returns (uint256) {
    uint256 _totalBoxOffice = 0;
    for (uint256 i = 0; i < _boxOfficeTotals.length; i++) {
      _totalBoxOffice = _totalBoxOffice.add(_boxOfficeTotals[i]);
    }
    return _totalBoxOffice;
  }

  // this calculates how much Ether to reward for each game token
  function calculateTotalPlayerRewardsPerMovie(uint256 _boxOfficeTotal) public view returns (uint256) {
    // 234 means 23.4%, using parts-per notation with three decimals of precision
    uint256 _boxOfficePercentage = percent(_boxOfficeTotal, totalBoxOffice, 4);
    // calculate the Ether rewards available for each movie
    uint256 _rewards = totalPlayerRewards.mul(_boxOfficePercentage).div(10**4);
    return _rewards;
  }

  function calculateRewardPerToken(uint256 _boxOfficeTotal, address tokenAddress) public view returns (uint256) {
    IPickFlixToken token = IPickFlixToken(tokenAddress);
    uint256 _playerBalance = token.balanceOf(msg.sender);
    uint256 _playerPercentage = percent(_playerBalance, token.totalSupply(), 4);
    // calculate the particular player's rewards, as a percentage of total player rewards for the movie
    uint256 _playerRewards = movies[tokenAddress].totalPlayerRewards.mul(_playerPercentage).div(10**4);
    return _playerRewards;
  }

  /**
  * @dev add box office results and token addresses for the movies, and calculate game results
  */
  function calculateGameResults(address[] _tokenAddresses, uint256[] _boxOfficeTotals) public onlyOwner {
    // check that there are as many box office totals as token addresses
    require(_tokenAddresses.length == _boxOfficeTotals.length, "Must have box office results per token");
    // calculate Oracle Fee and amount of Ether available for player rewards
    require(gameDone == false, "Can only submit results once");
    require(block.timestamp >= closeDate, "Game must have ended before results can be entered");
    oracleFee = calculateOracleFee();
    totalPlayerRewards = calculateTotalPlayerRewards();
    totalBoxOffice = calculateTotalBoxOffice(_boxOfficeTotals);

    // create Movies (see: Movie struct) and calculate player rewards
    for (uint256 i = 0; i < _tokenAddresses.length; i++) {
      tokensIssued = tokensIssued.add(calculateTokensIssued(_tokenAddresses[i]));
      movies[_tokenAddresses[i]] = Movie(_boxOfficeTotals[i], calculateTotalPlayerRewardsPerMovie(_boxOfficeTotals[i]), true);
    }

    // The owner will be the Factory that deploys this contract.
    owner().transfer(oracleFee);
    gameDone = true;
  }

  /**
   * @dev add box office results and token addresses for the movies, and calculate game results
   */
  function abortGame(address[] _tokenAddresses) public onlyOwner {
    // calculate Oracle Fee and amount of Ether available for player rewards
    require(gameDone == false, "Can only submit results once");
    oracleFee = 0;
    totalPlayerRewards = calculateTotalPlayerRewards();
    closeDate = block.timestamp;

    for (uint256 i = 0; i < _tokenAddresses.length; i++) {
      uint tokenSupply = calculateTokensIssued(_tokenAddresses[i]);
      tokensIssued = tokensIssued.add(tokenSupply);
      closeToken(_tokenAddresses[i]);
    }
    totalBoxOffice = tokensIssued;

    // create Movies (see: Movie struct) and calculate player rewards
    for (i = 0; i < _tokenAddresses.length; i++) {
      tokenSupply = calculateTokensIssued(_tokenAddresses[i]);
      movies[_tokenAddresses[i]] = Movie(tokenSupply, calculateTotalPlayerRewardsPerMovie(tokenSupply), true);
    }

    gameDone = true;
  }

  function killGame(address[] _tokenAddresses) public onlyOwner {
    for (uint i = 0; i < _tokenAddresses.length; i++) {
      IPickFlixToken token = IPickFlixToken(_tokenAddresses[i]);
      require(token.balanceOf(this) == token.totalSupply());
      token.kill();
    }
    selfdestruct(owner());
  }
}


pragma solidity ^0.4.23;



//The contract in charge of creating games
contract PickflixGameFactory {

  struct Game {
    string gameName;
    address gameMaster;
    uint openDate;
    uint closeDate;
  }

  // The list of all games this factory has created
  Game[] public games;

  // Each game master has a list of tokens
  mapping(address => address[]) public gameTokens;

  // The owner of the factory, i.e. GoBlock
  address public owner;

  // The address which will receive the oracle fee
  address public oracleFeeReceiver;

  // An event emitted when the oracle fee is received
  event OraclePayoutReceived(uint value);

  constructor() public {
    owner = msg.sender;
    oracleFeeReceiver = msg.sender;
  }

  function () public payable {
    emit OraclePayoutReceived(msg.value);
  }

  // Throw an error if the sender is not the owner
  modifier onlyOwner {
    require(msg.sender == owner, "Only owner can execute this");
    _;
  }

  // Create a new game master and add it to the factories game list
  function createGame(string gameName, uint closeDate, uint oracleFeePercent) public onlyOwner returns (address){
    address gameMaster = new PickflixGameMaster(gameName, closeDate, oracleFeePercent);
    games.push(Game({
      gameName: gameName,
      gameMaster: gameMaster,
      openDate: block.timestamp,
      closeDate: closeDate
    }));
    return gameMaster;
  }

  // Create a token and associate it with a game
  function createTokenForGame(uint gameIndex, string tokenName, string tokenSymbol, uint rate, string externalID) public onlyOwner returns (address) {
    Game storage game = games[gameIndex];
    address token = new PickFlixToken(tokenName, tokenSymbol, rate, game.gameMaster, game.closeDate, externalID);
    gameTokens[game.gameMaster].push(token);
    return token;
  }

  // Upload the results for a game
  function closeGame(uint gameIndex, address[] _tokenAddresses, uint256[] _boxOfficeTotals) public onlyOwner {
    PickflixGameMaster(games[gameIndex].gameMaster).calculateGameResults(_tokenAddresses, _boxOfficeTotals);
  }

  // Cancel a game and refund participants
  function abortGame(uint gameIndex) public onlyOwner {
    address gameMaster = games[gameIndex].gameMaster;
    PickflixGameMaster(gameMaster).abortGame(gameTokens[gameMaster]);
  }

  // Delete a game from the factory
  function killGame(uint gameIndex) public onlyOwner {
    address gameMaster = games[gameIndex].gameMaster;
    PickflixGameMaster(gameMaster).killGame(gameTokens[gameMaster]);
    games[gameIndex] = games[games.length-1];
    delete games[games.length-1];
    games.length--;
  }

  // Change the owner address
  function setOwner(address newOwner) public onlyOwner {
    owner = newOwner;
  }

  // Change the address that receives the oracle fee
  function setOracleFeeReceiver(address newReceiver) public onlyOwner {
    oracleFeeReceiver = newReceiver;
  }

  // Send the ether to the oracle fee receiver
  function sendOraclePayout() public {
    oracleFeeReceiver.transfer(address(this).balance);
  }
}