/**
 * Source Code first verified at https://etherscan.io on Wednesday, April 17, 2019
 (UTC) */

pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {

  using SafeMath for uint256;

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
    // safeApprove should only be called when setting an initial allowance, 
    // or when resetting it to zero. To increase and decrease it, use 
    // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
    require((value == 0) || (token.allowance(msg.sender, spender) == 0));
    require(token.approve(spender, value));
  }

  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    uint256 newAllowance = token.allowance(address(this), spender).add(value);
    require(token.approve(spender, newAllowance));
  }

  function safeDecreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    uint256 newAllowance = token.allowance(address(this), spender).sub(value);
    require(token.approve(spender, newAllowance));
  }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

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
  constructor() internal {
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
    require(isOwner());
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
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

// File: openzeppelin-solidity/contracts/access/Roles.sol

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
    require(!has(role, account));

    role.bearer[account] = true;
  }

  /**
   * @dev remove an account's access to this role
   */
  function remove(Role storage role, address account) internal {
    require(account != address(0));
    require(has(role, account));

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

// File: contracts/access/RBACManager.sol

contract RBACManager is Ownable {
  using Roles for Roles.Role;

  event ManagerAdded(address indexed account);
  event ManagerRemoved(address indexed account);

  Roles.Role private managers;

  modifier onlyOwnerOrManager() {
    require(
      msg.sender == owner() || isManager(msg.sender),
      "unauthorized"
    );
    _;
  }

  constructor() public {
    addManager(msg.sender);
  }

  function isManager(address account) public view returns (bool) {
    return managers.has(account);
  }

  function addManager(address account) public onlyOwner {
    managers.add(account);
    emit ManagerAdded(account);
  }

  function removeManager(address account) public onlyOwner {
    managers.remove(account);
    emit ManagerRemoved(account);
  }
}

// File: contracts/CharityProject.sol

contract CharityProject is RBACManager {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  modifier canWithdraw() {
    require(
      _canWithdrawBeforeEnd || _closingTime == 0 || block.timestamp > _closingTime, // solium-disable-line security/no-block-members
      "can't withdraw");
    _;
  }

  uint256 private _feeInMillis;
  uint256 private _withdrawnTokens;
  uint256 private _withdrawnFees;
  uint256 private _maxGoal;
  uint256 private _openingTime;
  uint256 private _closingTime;
  address private _wallet;
  IERC20 private _token;
  bool private _canWithdrawBeforeEnd;

  constructor (
    uint256 feeInMillis,
    uint256 maxGoal,
    uint256 openingTime,
    uint256 closingTime,
    address wallet,
    IERC20 token,
    bool canWithdrawBeforeEnd,
    address additionalManager
  ) public {
    require(wallet != address(0), "wallet can't be zero");
    require(token != address(0), "token can't be zero");
    require(
      closingTime == 0 || closingTime >= openingTime,
      "wrong value for closingTime"
    );

    _feeInMillis = feeInMillis;
    _maxGoal = maxGoal;
    _openingTime = openingTime;
    _closingTime = closingTime;
    _wallet = wallet;
    _token = token;
    _canWithdrawBeforeEnd = canWithdrawBeforeEnd;

    if (_wallet != owner()) {
      addManager(_wallet);
    }

    // solium-disable-next-line max-len
    if (additionalManager != address(0) && additionalManager != owner() && additionalManager != _wallet) {
      addManager(additionalManager);
    }
  }

  // -----------------------------------------
  // GETTERS
  // -----------------------------------------

  function feeInMillis() public view returns(uint256) {
    return _feeInMillis;
  }

  function withdrawnTokens() public view returns(uint256) {
    return _withdrawnTokens;
  }

  function withdrawnFees() public view returns(uint256) {
    return _withdrawnFees;
  }

  function maxGoal() public view returns(uint256) {
    return _maxGoal;
  }

  function openingTime() public view returns(uint256) {
    return _openingTime;
  }

  function closingTime() public view returns(uint256) {
    return _closingTime;
  }

  function wallet() public view returns(address) {
    return _wallet;
  }

  function token() public view returns(IERC20) {
    return _token;
  }

  function canWithdrawBeforeEnd() public view returns(bool) {
    return _canWithdrawBeforeEnd;
  }

  // -----------------------------------------
  // SETTERS
  // -----------------------------------------

  function setMaxGoal(uint256 newMaxGoal) public onlyOwner {
    _maxGoal = newMaxGoal;
  }

  function setTimes(
    uint256 newOpeningTime,
    uint256 newClosingTime
  )
  public
  onlyOwner
  {
    require(
      newClosingTime == 0 || newClosingTime >= newOpeningTime,
      "wrong value for closingTime"
    );

    _openingTime = newOpeningTime;
    _closingTime = newClosingTime;
  }

  function setCanWithdrawBeforeEnd(
    bool newCanWithdrawBeforeEnd
  )
  public
  onlyOwner
  {
    _canWithdrawBeforeEnd = newCanWithdrawBeforeEnd;
  }

  // -----------------------------------------
  // CHECKS
  // -----------------------------------------

  function totalRaised() public view returns (uint256) {
    uint256 raised = _token.balanceOf(this);
    return raised.add(_withdrawnTokens).add(_withdrawnFees);
  }

  function totalFee() public view returns (uint256) {
    return totalRaised().mul(_feeInMillis).div(1000);
  }

  function hasStarted() public view returns (bool) {
    // solium-disable-next-line security/no-block-members
    return _openingTime == 0 ? true : block.timestamp > _openingTime;
  }

  function hasClosed() public view returns (bool) {
    // solium-disable-next-line security/no-block-members
    return _closingTime == 0 ? false : block.timestamp > _closingTime;
  }

  function maxGoalReached() public view returns (bool) {
    return totalRaised() >= _maxGoal;
  }

  // -----------------------------------------
  // ACTIONS
  // -----------------------------------------

  function withdrawTokens(
    address to,
    uint256 value
  )
  public
  onlyOwnerOrManager
  canWithdraw
  {
    uint256 expectedTotalWithdraw = _withdrawnTokens.add(value);
    require(
      expectedTotalWithdraw <= totalRaised().sub(totalFee()),
      "can't withdraw more than available token"
    );
    _withdrawnTokens = expectedTotalWithdraw;
    _token.safeTransfer(to, value);
  }

  function withdrawFees(
    address to,
    uint256 value
  )
  public
  onlyOwner
  canWithdraw
  {
    uint256 expectedTotalWithdraw = _withdrawnFees.add(value);
    require(
      expectedTotalWithdraw <= totalFee(),
      "can't withdraw more than available fee"
    );
    _withdrawnFees = expectedTotalWithdraw;
    _token.safeTransfer(to, value);
  }

  function recoverERC20(
    address tokenAddress,
    address receiverAddress,
    uint256 amount
  )
  public
  onlyOwnerOrManager
  {
    require(
      tokenAddress != address(_token),
      "to transfer project's funds use withdrawTokens"
    );
    IERC20(tokenAddress).safeTransfer(receiverAddress, amount);
  }
}