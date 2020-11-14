/**
 * Source Code first verified at https://etherscan.io on Thursday, March 28, 2019
 (UTC) */

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

/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract ERC20Detailed is IERC20 {
  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(string name, string symbol, uint8 decimals) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

  /**
   * @return the name of the token.
   */
  function name() public view returns(string) {
    return _name;
  }

  /**
   * @return the symbol of the token.
   */
  function symbol() public view returns(string) {
    return _symbol;
  }

  /**
   * @return the number of decimals of the token.
   */
  function decimals() public view returns(uint8) {
    return _decimals;
  }
}

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

contract PauserRole {
  using Roles for Roles.Role;

  event PauserAdded(address indexed account);
  event PauserRemoved(address indexed account);

  Roles.Role private pausers;

  constructor() internal {
    _addPauser(msg.sender);
  }

  modifier onlyPauser() {
    require(isPauser(msg.sender));
    _;
  }

  function isPauser(address account) public view returns (bool) {
    return pausers.has(account);
  }

  function addPauser(address account) public onlyPauser {
    _addPauser(account);
  }

  function renouncePauser() public {
    _removePauser(msg.sender);
  }

  function _addPauser(address account) internal {
    pausers.add(account);
    emit PauserAdded(account);
  }

  function _removePauser(address account) internal {
    pausers.remove(account);
    emit PauserRemoved(account);
  }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
  event Paused(address account);
  event Unpaused(address account);

  bool private _paused;

  constructor() internal {
    _paused = false;
  }

  /**
   * @return true if the contract is paused, false otherwise.
   */
  function paused() public view returns(bool) {
    return _paused;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!_paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(_paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyPauser whenNotPaused {
    _paused = true;
    emit Paused(msg.sender);
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyPauser whenPaused {
    _paused = false;
    emit Unpaused(msg.sender);
  }
}

/**
 * @title Pausable token
 * @dev ERC20 modified with pausable transfers.
 **/
contract ERC20Pausable is ERC20, Pausable {

  function transfer(
    address to,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transfer(to, value);
  }

  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transferFrom(from, to, value);
  }

  function approve(
    address spender,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(spender, value);
  }

  function increaseAllowance(
    address spender,
    uint addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.increaseAllowance(spender, addedValue);
  }

  function decreaseAllowance(
    address spender,
    uint subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.decreaseAllowance(spender, subtractedValue);
  }
}

contract SignkeysToken is ERC20Pausable, ERC20Detailed, Ownable {

    uint8 public constant DECIMALS = 18;

    uint256 public constant INITIAL_SUPPLY = 2E9 * (10 ** uint256(DECIMALS));

    /* Address where fees will be transferred */
    address public feeChargingAddress;

    /* Nonces */
    mapping(address => uint256) public nonces;

    function setFeeChargingAddress(address _feeChargingAddress) external onlyOwner {
        feeChargingAddress = _feeChargingAddress;
        emit FeeChargingAddressChanges(_feeChargingAddress);
    }

    /* Fee charging address changed */
    event FeeChargingAddressChanges(address newFeeChargingAddress);

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor() public ERC20Detailed("SignkeysToken", "KEYS", DECIMALS) {
        _mint(owner(), INITIAL_SUPPLY);
    }

    function transferWithSignature(
        address from,
        address to,
        uint256 amount,
        uint256 feeAmount,
        uint256 nonce,
        uint256 expiration,
        uint8 v,
        bytes32 r,
        bytes32 s) public {
        require(expiration >= now, "Signature expired");
        require(feeChargingAddress != 0x0, "Fee charging address must be set");

        address receivedSigner = ecrecover(
            keccak256(
                abi.encodePacked(
                    from, to, amount, feeAmount, nonce, expiration
                )
            ), v, r, s);

        require(nonce > nonces[from], "Wrong nonce");
        nonces[from] = nonce;

        require(receivedSigner == from, "Something wrong with signature");
        _transfer(from, to, amount);
        _transfer(from, feeChargingAddress, feeAmount);
    }

    function approveAndCall(address _spender, uint256 _value, bytes _data) public payable returns (bool success) {
        require(_spender != address(this));
        require(super.approve(_spender, _value));
        require(_spender.call(_data));
        return true;
    }

    function() payable external {
        revert();
    }
}

contract SignkeysBonusProgram is Ownable {
    using SafeMath for uint256;

    /* Token contract */
    SignkeysToken public token;

    /* Crowdsale contract */
    SignkeysCrowdsale public crowdsale;

    /* SignkeysBonusProgramRewards contract to keep bonus state */
    SignkeysBonusProgramRewards public bonusProgramRewards;

    /* Ranges in which we transfer the given amount of tokens as reward. See arrays below.
     For example, if this array is [199, 1000, 10000] and referrerRewards array is [5, 50],
       it considers as follows:
       [0, 199] - 0 tokens
       [200, 1000] - 5 tokens
       [1001, 10000] - 50 tokens,
       > 10000 - 50 tokens
       */
    uint256[] public referralBonusTokensAmountRanges = [199, 1000, 10000, 100000, 1000000, 10000000];

    /* Amount of tokens as bonus for referrer according to referralBonusTokensAmountRanges */
    uint256[] public referrerRewards = [5, 50, 500, 5000, 50000];

    /* Amount of tokens as bonus for buyer according to referralBonusTokensAmountRanges */
    uint256[] public buyerRewards = [5, 50, 500, 5000, 50000];

    /* Purchase amount ranges in cents for any purchase.
     For example, if this array is [2000, 1000000, 10000000] and purchaseRewardsPercents array is [10, 15, 20],
       it considers as follows:
       [2000, 1000000) - 10% of tokens
       [1000000, 10000000) - 15% of tokens
       > 100000000 - 20% tokens
       */
    uint256[] public purchaseAmountRangesInCents = [2000, 1000000, 10000000];

    /* Percetage of reward for any purchase according to purchaseAmountRangesInCents */
    uint256[] public purchaseRewardsPercents = [10, 15, 20];

    event BonusSent(
        address indexed referrerAddress,
        uint256 referrerBonus,
        address indexed buyerAddress,
        uint256 buyerBonus,
        uint256 purchaseBonus,
        uint256 couponBonus
    );

    constructor(address _token, address _bonusProgramRewards) public {
        token = SignkeysToken(_token);
        bonusProgramRewards = SignkeysBonusProgramRewards(_bonusProgramRewards);
    }

    function setCrowdsaleContract(address _crowdsale) public onlyOwner {
        crowdsale = SignkeysCrowdsale(_crowdsale);
    }

    function setBonusProgramRewardsContract(address _bonusProgramRewards) public onlyOwner {
        bonusProgramRewards = SignkeysBonusProgramRewards(_bonusProgramRewards);
    }

    /* Calculate bonus for the given amount of tokens according to referralBonusTokensAmountRanges
    and rewards array which is one of referrerRewards or buyerRewards */
    function calcBonus(uint256 tokensAmount, uint256[] rewards) private view returns (uint256) {
        uint256 multiplier = 10 ** uint256(token.decimals());
        if (tokensAmount <= multiplier.mul(referralBonusTokensAmountRanges[0])) {
            return 0;
        }
        for (uint i = 1; i < referralBonusTokensAmountRanges.length; i++) {
            uint min = referralBonusTokensAmountRanges[i - 1];
            uint max = referralBonusTokensAmountRanges[i];
            if (tokensAmount > min.mul(multiplier) && tokensAmount <= max.mul(multiplier)) {
                return multiplier.mul(rewards[i - 1]);
            }
        }
        if (tokensAmount >= referralBonusTokensAmountRanges[referralBonusTokensAmountRanges.length - 1].mul(multiplier)) {
            return multiplier.mul(rewards[rewards.length - 1]);
        }
    }

    function calcPurchaseBonus(uint256 amountCents, uint256 tokensAmount) private view returns (uint256) {
        if (amountCents < purchaseAmountRangesInCents[0]) {
            return 0;
        }
        for (uint i = 1; i < purchaseAmountRangesInCents.length; i++) {
            if (amountCents >= purchaseAmountRangesInCents[i - 1] && amountCents < purchaseAmountRangesInCents[i]) {
                return tokensAmount.mul(purchaseRewardsPercents[i - 1]).div(100);
            }
        }
        if (amountCents >= purchaseAmountRangesInCents[purchaseAmountRangesInCents.length - 1]) {
            return tokensAmount.mul(purchaseRewardsPercents[purchaseAmountRangesInCents.length - 1]).div(100);
        }
    }

    /* Having referrer, buyer, amount of purchased tokens, value of purchased tokens in cents and coupon campaign id
    this method transfer all the required bonuses to referrer and buyer */
    function sendBonus(address referrer, address buyer, uint256 _tokensAmount, uint256 _valueCents, uint256 _couponCampaignId) external returns (uint256)  {
        require(msg.sender == address(crowdsale), "Bonus may be sent only by crowdsale contract");

        uint256 referrerBonus = 0;
        uint256 buyerBonus = 0;
        uint256 purchaseBonus = 0;
        uint256 couponBonus = 0;

        uint256 referrerBonusAmount = calcBonus(_tokensAmount, referrerRewards);
        uint256 buyerBonusAmount = calcBonus(_tokensAmount, buyerRewards);
        uint256 purchaseBonusAmount = calcPurchaseBonus(_valueCents, _tokensAmount);

        if (referrer != 0x0 && !bonusProgramRewards.areReferralBonusesSent(buyer)) {
            if (referrerBonusAmount > 0 && token.balanceOf(this) > referrerBonusAmount) {
                token.transfer(referrer, referrerBonusAmount);
                bonusProgramRewards.setReferralBonusesSent(buyer, true);
                referrerBonus = referrerBonusAmount;
            }

            if (buyerBonusAmount > 0 && token.balanceOf(this) > buyerBonusAmount) {
                bonusProgramRewards.setReferralBonusesSent(buyer, true);
                buyerBonus = buyerBonusAmount;
            }
        }

        if (token.balanceOf(this) > purchaseBonusAmount.add(buyerBonus)) {
            purchaseBonus = purchaseBonusAmount;
        }

        if (_couponCampaignId > 0 && !bonusProgramRewards.isCouponUsed(buyer, _couponCampaignId)) {
            if (
                token.balanceOf(this) > purchaseBonusAmount
                .add(buyerBonus)
                .add(bonusProgramRewards.getCouponCampaignBonusTokensAmount(_couponCampaignId))
            ) {
                bonusProgramRewards.setCouponUsed(buyer, _couponCampaignId, true);
                couponBonus = bonusProgramRewards.getCouponCampaignBonusTokensAmount(_couponCampaignId);
            }
        }

        if (buyerBonus > 0 || purchaseBonus > 0 || couponBonus > 0) {
            token.transfer(buyer, buyerBonus.add(purchaseBonus).add(couponBonus));
        }

        emit BonusSent(referrer, referrerBonus, buyer, buyerBonus, purchaseBonus, couponBonus);
    }

    function getReferralBonusTokensAmountRanges() public view returns (uint256[]) {
        return referralBonusTokensAmountRanges;
    }

    function getReferrerRewards() public view returns (uint256[]) {
        return referrerRewards;
    }

    function getBuyerRewards() public view returns (uint256[]) {
        return buyerRewards;
    }

    function getPurchaseRewardsPercents() public view returns (uint256[]) {
        return purchaseRewardsPercents;
    }

    function getPurchaseAmountRangesInCents() public view returns (uint256[]) {
        return purchaseAmountRangesInCents;
    }

    function setReferralBonusTokensAmountRanges(uint[] ranges) public onlyOwner {
        referralBonusTokensAmountRanges = ranges;
    }

    function setReferrerRewards(uint[] rewards) public onlyOwner {
        require(rewards.length == referralBonusTokensAmountRanges.length - 1);
        referrerRewards = rewards;
    }

    function setBuyerRewards(uint[] rewards) public onlyOwner {
        require(rewards.length == referralBonusTokensAmountRanges.length - 1);
        buyerRewards = rewards;
    }

    function setPurchaseAmountRangesInCents(uint[] ranges) public onlyOwner {
        purchaseAmountRangesInCents = ranges;
    }

    function setPurchaseRewardsPercents(uint[] rewards) public onlyOwner {
        require(rewards.length == purchaseAmountRangesInCents.length);
        purchaseRewardsPercents = rewards;
    }

    /* Withdraw all tokens from contract for any emergence case */
    function withdrawTokens() external onlyOwner {
        uint256 amount = token.balanceOf(this);
        address tokenOwner = token.owner();
        token.transfer(tokenOwner, amount);
    }
}

contract SignkeysBonusProgramRewards is Ownable {
    using SafeMath for uint256;

    /* Bonus program contract */
    SignkeysBonusProgram public bonusProgram;

    /* How much bonuses to send according for the given coupon campaign */
    mapping(uint256 => uint256) private _couponCampaignBonusTokensAmount;

    /* Check if referrer already got the bonuses from the invited token receiver */
    mapping(address => bool) private _areReferralBonusesSent;

    /* Check if coupon of the given campaign was used by the token receiver */
    mapping(address => mapping(uint256 => bool)) private _isCouponUsed;

    function setBonusProgram(address _bonusProgram) public onlyOwner {
        bonusProgram = SignkeysBonusProgram(_bonusProgram);
    }

    modifier onlyBonusProgramContract() {
        require(msg.sender == address(bonusProgram), "Bonus program rewards state may be changed only by bonus program contract");
        _;
    }

    function addCouponCampaignBonusTokensAmount(uint256 _couponCampaignId, uint256 amountOfBonuses) public onlyOwner {
        _couponCampaignBonusTokensAmount[_couponCampaignId] = amountOfBonuses;
    }

    function getCouponCampaignBonusTokensAmount(uint256 _couponCampaignId) public view returns (uint256)  {
        return _couponCampaignBonusTokensAmount[_couponCampaignId];
    }

    function isCouponUsed(address buyer, uint256 couponCampaignId) public view returns (bool)  {
        return _isCouponUsed[buyer][couponCampaignId];
    }

    function setCouponUsed(address buyer, uint256 couponCampaignId, bool isUsed) public onlyBonusProgramContract {
        _isCouponUsed[buyer][couponCampaignId] = isUsed;
    }

    function areReferralBonusesSent(address buyer) public view returns (bool)  {
        return _areReferralBonusesSent[buyer];
    }

    function setReferralBonusesSent(address buyer, bool areBonusesSent) public onlyBonusProgramContract {
        _areReferralBonusesSent[buyer] = areBonusesSent;
    }
}

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e99b8c848a86a9db">[email protected]</a>π.com>, Eenae <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="03626f667b667a436e6a7b617a7766702d6a6c">[email protected]</a>>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

  /// @dev counter to allow mutex lock with only one SSTORE operation
  uint256 private _guardCounter;

  constructor() internal {
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

contract SignkeysCrowdsale is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    uint256 public constant INITIAL_TOKEN_PRICE_CENTS = 10;

    /* Token contract */
    SignkeysToken public signkeysToken;

    /* Bonus program contract*/
    SignkeysBonusProgram public signkeysBonusProgram;

    /* signer address, can be set by owner only */
    address public signer;

    /* ETH funds will be transferred to this address */
    address public wallet;

    /* Role that provide tokens calling sendTokens method */
    address public administrator;

    /* Current token price in cents */
    uint256 public tokenPriceCents;

    /* Buyer bought the amount of tokens with tokenPrice */
    event BuyTokens(
        address indexed buyer,
        address indexed tokenReceiver,
        uint256 tokenPrice,
        uint256 amount
    );

    /* Admin sent the amount of tokens to the tokenReceiver */
    event SendTokens(
        address indexed tokenReceiver,
        uint256 amount
    );

    /* Wallet changed */
    event WalletChanged(address newWallet);

    /* Administrator changed */
    event AdministratorChanged(address newAdministrator);

    /* Signer changed */
    event CrowdsaleSignerChanged(address newSigner);

    /* Token price changed */
    event TokenPriceChanged(uint256 oldPrice, uint256 newPrice);

    constructor(
        address _token,
        address _bonusProgram,
        address _wallet,
        address _signer
    ) public {
        require(_token != 0x0, "Token contract for crowdsale must be set");
        require(_bonusProgram != 0x0, "Referrer smart contract for crowdsale must be set");

        require(_wallet != 0x0, "Wallet for fund transferring must be set");
        require(_signer != 0x0, "Signer must be set");

        signkeysToken = SignkeysToken(_token);
        signkeysBonusProgram = SignkeysBonusProgram(_bonusProgram);

        signer = _signer;
        wallet = _wallet;

        tokenPriceCents = INITIAL_TOKEN_PRICE_CENTS;
    }

    function setSignerAddress(address _signer) external onlyOwner {
        signer = _signer;
        emit CrowdsaleSignerChanged(_signer);
    }

    function setWalletAddress(address _wallet) external onlyOwner {
        wallet = _wallet;
        emit WalletChanged(_wallet);
    }

    function setAdministratorAddress(address _administrator) external onlyOwner {
        administrator = _administrator;
        emit AdministratorChanged(_administrator);
    }

    function setBonusProgram(address _bonusProgram) external onlyOwner {
        signkeysBonusProgram = SignkeysBonusProgram(_bonusProgram);
    }

    function setTokenPriceCents(uint256 _tokenPriceCents) external onlyOwner {
        emit TokenPriceChanged(tokenPriceCents, _tokenPriceCents);
        tokenPriceCents = _tokenPriceCents;
    }

    /**
     * @dev Make an investment.
     *
     * @param _tokenReceiver address where the tokens need to be transfered
     * @param _referrer address of user that invited _tokenReceiver for this purchase
     * @param _tokenPrice price per one token including decimals
     * @param _minWei minimal amount of wei buyer should invest
     * @param _expiration expiration on token
     */
    function buyTokens(
        address _tokenReceiver,
        address _referrer,
        uint256 _couponCampaignId, // starts with 1 if there is some, 0 means no coupon
        uint256 _tokenPrice,
        uint256 _minWei,
        uint256 _expiration,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) payable external nonReentrant {
        require(_expiration >= now, "Signature expired");
        require(_tokenReceiver != 0x0, "Token receiver must be provided");
        require(_minWei > 0, "Minimal amount to purchase must be greater than 0");

        require(wallet != 0x0, "Wallet must be set");
        require(msg.value >= _minWei, "Purchased amount is less than min amount to invest");

        address receivedSigner = ecrecover(
            keccak256(
                abi.encodePacked(
                    _tokenPrice, _minWei, _tokenReceiver, _referrer, _couponCampaignId, _expiration
                )
            ), _v, _r, _s);

        require(receivedSigner == signer, "Something wrong with signature");

        uint256 tokensAmount = msg.value.mul(10 ** uint256(signkeysToken.decimals())).div(_tokenPrice);
        require(signkeysToken.balanceOf(this) >= tokensAmount, "Not enough tokens in sale contract");

        // Pocket the money, or fail the crowdsale if we for some reason cannot send the money to our wallet
        wallet.transfer(msg.value);

        _sendTokens(_tokenReceiver, _referrer, _couponCampaignId, tokensAmount);

        emit BuyTokens(msg.sender, _tokenReceiver, _tokenPrice, tokensAmount);
    }

    function sendTokens(
        address _tokenReceiver,
        address _referrer,
        uint256 _couponCampaignId,
        uint256 tokensAmount
    ) external {
        require(msg.sender == administrator, "sendTokens() method may be called only by administrator ");
        _sendTokens(_tokenReceiver, _referrer, _couponCampaignId, tokensAmount);
        emit SendTokens(_tokenReceiver, tokensAmount);
    }

    function _sendTokens(
        address _tokenReceiver,
        address _referrer,
        uint256 _couponCampaignId,
        uint256 tokensAmount
    ) private {
        signkeysToken.transfer(_tokenReceiver, tokensAmount);

        // send bonuses according to signkeys bonus program
        signkeysBonusProgram.sendBonus(
            _referrer,
            _tokenReceiver,
            tokensAmount,
            (tokensAmount.mul(tokenPriceCents).div(10 ** uint256(signkeysToken.decimals()))),
            _couponCampaignId);
    }


    /**
     * Don't expect to just send in money and get tokens.
     */
    function() payable external {
        revert();
    }

    /* Withdraw all tokens from contract for any emergence case */
    function withdrawTokens() external onlyOwner {
        uint256 amount = signkeysToken.balanceOf(this);
        address tokenOwner = signkeysToken.owner();
        signkeysToken.transfer(tokenOwner, amount);
    }
}