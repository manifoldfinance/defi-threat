/**
 * Source Code first verified at https://etherscan.io on Saturday, March 23, 2019
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
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.4.24;



/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol

pragma solidity ^0.4.24;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(
    ERC20Basic _token,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transfer(_to, _value));
  }

  function safeTransferFrom(
    ERC20 _token,
    address _from,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transferFrom(_from, _to, _value));
  }

  function safeApprove(
    ERC20 _token,
    address _spender,
    uint256 _value
  )
    internal
  {
    require(_token.approve(_spender, _value));
  }
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
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
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

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

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
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

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
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

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
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

// File: contracts/Burnable.sol

pragma solidity ^0.4.24;


/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract Burnable is StandardToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }

}

// File: contracts/Ownable.sol

pragma solidity ^0.4.24;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable is Burnable {

  address public owner;
  address public ownerCandidate;

  /**
   * @dev Fired whenever ownership is successfully transferred.
   */
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
   * @dev Allows the current owner to transfer control of the contract to a new owner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a new owner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    ownerCandidate = _newOwner;
  }

  /**
   * @dev New ownerschip Confirmation.
   */
  function acceptOwnership() public {
    _acceptOwnership();
  }

  /**
   * @dev New ownerschip confirmation internal.
   */
  function _acceptOwnership() internal {
    require(msg.sender == ownerCandidate);
    emit OwnershipTransferred(owner, ownerCandidate);
    owner = ownerCandidate;
    ownerCandidate = address(0);
  }

  /**
   * @dev Transfers the current balance to the owner and terminates the contract.
   * In case stuff goes bad.
   */
  function destroy() public onlyOwner {
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) public onlyOwner {
    selfdestruct(_recipient);
  }

}

// File: contracts/Administrable.sol

pragma solidity ^0.4.24;



/**
 * @title Ownable
 * @dev The authentication manager details user accounts that have access to certain priviledges.
 */
contract Administrable is Ownable {

  using SafeERC20 for ERC20Basic;
  
  /**
   * @dev Map addresses to admins.
   */
  mapping (address => bool) admins;

  /**
   * @dev All admins that have ever existed.
   */
  address[] adminAudit;

  /**
   * @dev Globally enable or disable admin access.
   */
  bool allowAdmins = true;

   /**
   * @dev Fired whenever an admin is added to the contract.
   */
  event AdminAdded(address addedBy, address admin);

  /**
   * @dev Fired whenever an admin is removed from the contracts.
   */
  event AdminRemoved(address removedBy, address admin);

  /**
   * @dev Throws if called by any account other than the active admin or owner.
   */
  modifier onlyAdmin {
    require(isCurrentAciveAdmin(msg.sender));
    _;
  }

  /**
   * @dev Turn on admin role
   */
  function enableAdmins() public onlyOwner {
    require(allowAdmins == false);
    allowAdmins = true;
  }

  /**
   * @dev Turn off admin role
   */
  function disableAdmins() public onlyOwner {
    require(allowAdmins);
    allowAdmins = false;
  }

  /**
   * @dev Gets whether or not the specified address is currently an admin.
   */
  function isCurrentAdmin(address _address) public view returns (bool) {
    if(_address == owner)
      return true;
    else
      return admins[_address];
  }

  /**
   * @dev Gets whether or not the specified address is currently an active admin.
   */
  function isCurrentAciveAdmin(address _address) public view returns (bool) {
    if(_address == owner)
      return true;
    else
      return allowAdmins && admins[_address];
  }

  /**
   * @dev Gets whether or not the specified address has ever been an admin.
   */
  function isCurrentOrPastAdmin(address _address) public view returns (bool) {
    for (uint256 i = 0; i < adminAudit.length; i++)
      if (adminAudit[i] == _address)
        return true;
    return false;
  }

  /**
   * @dev Adds a user to our list of admins.
   */
  function addAdmin(address _address) public onlyOwner {
    require(admins[_address] == false);
    admins[_address] = true;
    emit AdminAdded(msg.sender, _address);
    adminAudit.length++;
    adminAudit[adminAudit.length - 1] = _address;
  }

  /**
   * @dev Removes a user from our list of admins but keeps them in the history.
   */
  function removeAdmin(address _address) public onlyOwner {
    require(_address != msg.sender);
    require(admins[_address]);
    admins[_address] = false;
    emit AdminRemoved(msg.sender, _address);
  }

  /**
   * @dev Reclaim all ERC20Basic compatible tokens
   * @param _token ERC20Basic The address of the token contract
   */
  function reclaimToken(ERC20Basic _token) external onlyAdmin {
    uint256 balance = _token.balanceOf(this);
    _token.safeTransfer(msg.sender, balance);
  }

}

// File: contracts/Pausable.sol

pragma solidity ^0.4.24;


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Administrable {
  event Pause();
  event Unpause();

  bool public paused = false;

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyAdmin whenNotPaused {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyAdmin whenPaused {
    paused = false;
    emit Unpause();
  }

}

// File: contracts/Rento.sol

pragma solidity ^0.4.24;


contract Rento is Pausable {

  using SafeMath for uint256;

  string public name = "Rento";
  string public symbol = "RTO";
  uint8 public decimals = 8;

  /**
   * @dev representing 1.0.
   */
  uint256 public constant UNIT      = 100000000;

  uint256 constant INITIAL_SUPPLY   = 600000000 * UNIT;

  uint256 constant SALE_SUPPLY      = 264000000 * UNIT;
  uint256 internal SALE_SENT        = 0;

  uint256 constant OWNER_SUPPLY     = 305000000 * UNIT;
  uint256 internal OWNER_SENT       = 0;

  uint256 constant BOUNTY_SUPPLY    = 6000000 * UNIT;
  uint256 internal BOUNTY_SENT      = 0;

  uint256 constant ADVISORS_SUPPLY  = 25000000 * UNIT;
  uint256 internal ADVISORS_SENT    = 0;

  struct Stage {
     uint8 cents;
     uint256 limit;
  } 

  Stage[] stages;

  /**
   * @dev Stages prices in cents
   */
  mapping(uint => uint256) rates;

  constructor() public {
    totalSupply_ = INITIAL_SUPPLY;
    stages.push(Stage( 2, 0));
    stages.push(Stage( 6, 26400000 * UNIT));
    stages.push(Stage( 6, 52800000 * UNIT));
    stages.push(Stage(12, 158400000 * UNIT));
    stages.push(Stage(12, SALE_SUPPLY));
  }


  /**
   * @dev Sell tokens to address based on USD cents value.
   * @param _to Buyer address.
   * @param _value USC cents value.
   */
  function sellWithCents(address _to, uint256 _value) public
    onlyAdmin whenNotPaused
    returns (bool success) {
      return _sellWithCents(_to, _value);
  }

  /**
   * @dev Sell tokens to address array based on USD cents array values.
   */
  function sellWithCentsArray(address[] _dests, uint256[] _values) public
    onlyAdmin whenNotPaused
    returns (bool success) {
      require(_dests.length == _values.length);
      for (uint32 i = 0; i < _dests.length; i++)
        if(!_sellWithCents(_dests[i], _values[i])) {
          revert();
          return false;
        }
      return true;
  }

  /**
   * @dev Sell tokens to address based on USD cents value.
   * @param _to Buyer address.
   * @param _value USC cents value.
   */
  function _sellWithCents(address _to, uint256 _value) internal
    onlyAdmin whenNotPaused
    returns (bool) {
      require(_to != address(0) && _value > 0);
      uint256 tokens_left = 0;
      uint256 tokens_right = 0;
      uint256 price_left = 0;
      uint256 price_right = 0;
      uint256 tokens;
      uint256 i_r = 0;
      uint256 i = 0;
      while (i < stages.length) {
        if(SALE_SENT >= stages[i].limit) {
          if(i == stages.length-1) {
            i_r = i;
          } else {
            i_r = i + 1;
          }
          price_left = uint(stages[i].cents);
          price_right = uint(stages[i_r].cents);
        }
        i += 1;
      }
      if(price_left <= 0) {
        revert();
        return false;
      }
      tokens_left = _value.mul(UNIT).div(price_left);
      if(SALE_SENT.add(tokens_left) <= stages[i_r].limit) {
        tokens = tokens_left;
      } else {
        tokens_left = stages[i_r].limit.sub(SALE_SENT);
        tokens_right = UNIT.mul(_value.sub((tokens_left.mul(price_left)).div(UNIT))).div(price_right);
      }
      tokens = tokens_left.add(tokens_right);
      if(SALE_SENT.add(tokens) > SALE_SUPPLY) {
        revert();
        return false;
      }
      balances[_to] = balances[_to].add(tokens);
      SALE_SENT = SALE_SENT.add(tokens);
      emit Transfer(this, _to, tokens);
      return true;
  }

  /**
   * @dev Transfer tokens from contract directy to address.
   * @param _to Buyer address.
   * @param _value Tokens value.
   */
  function sellDirect(address _to, uint256 _value) public
    onlyAdmin whenNotPaused
      returns (bool success) {
        require(_to != address(0) && _value > 0 && SALE_SENT.add(_value) <= SALE_SUPPLY);
        balances[_to] = balances[_to].add(_value);
        SALE_SENT = SALE_SENT.add(_value);
        emit Transfer(this, _to, _value);
        return true;
  }

  /**
   * @dev Sell tokens to address array based on USD cents array values.
   */
  function sellDirectArray(address[] _dests, uint256[] _values) public
    onlyAdmin whenNotPaused returns (bool success) {
      require(_dests.length == _values.length);
      for (uint32 i = 0; i < _dests.length; i++) {
         if(_values[i] <= 0 || !sellDirect(_dests[i], _values[i])) {
            revert();
            return false;
         }
      }
      return true;
  }


  /**
   * @dev Transfer tokens from contract directy to owner.
   * @param _value Tokens value.
   */
  function transferOwnerTokens(uint256 _value) public
    onlyAdmin whenNotPaused returns (bool success) {
      require(_value > 0 && OWNER_SENT.add(_value) <= OWNER_SUPPLY);
      balances[owner] = balances[owner].add(_value);
      OWNER_SENT = OWNER_SENT.add(_value);
      emit Transfer(this, owner, _value);
      return true;
  }

  /**
   * @dev Transfer Bounty Tokens from contract.
   * @param _to Bounty recipient address.
   * @param _value Tokens value.
   */
  function transferBountyTokens(address _to, uint256 _value) public
    onlyAdmin whenNotPaused returns (bool success) {
      require(_to != address(0) && _value > 0 && BOUNTY_SENT.add(_value) <= BOUNTY_SUPPLY);
      balances[_to] = balances[_to].add(_value);
      BOUNTY_SENT = BOUNTY_SENT.add(_value);
      emit Transfer(this, _to, _value);
      return true;
  }

  /**
   * @dev Transfer Bounty Tokens from contract to multiple recipients ant once.
   * @param _to Bounty recipient addresses.
   * @param _values Tokens values.
   */
  function transferBountyTokensArray(address[] _to, uint256[] _values) public
    onlyAdmin whenNotPaused returns (bool success) {
      require(_to.length == _values.length);
      for (uint32 i = 0; i < _to.length; i++)
        if(!transferBountyTokens(_to[i], _values[i])) {
          revert();
          return false;
        }
      return true;
  }
    
  /**
   * @dev Transfer Advisors Tokens from contract.
   * @param _to Advisors recipient address.
   * @param _value Tokens value.
   */
  function transferAdvisorsTokens(address _to, uint256 _value) public
    onlyAdmin whenNotPaused returns (bool success) {
      require(_to != address(0) && _value > 0 && ADVISORS_SENT.add(_value) <= ADVISORS_SUPPLY);
      balances[_to] = balances[_to].add(_value);
      ADVISORS_SENT = ADVISORS_SENT.add(_value);
      emit Transfer(this, _to, _value);
      return true;
  }
    
  /**
   * @dev Transfer Advisors Tokens from contract for multiple advisors.
   * @param _to Advisors recipient addresses.
   * @param _values Tokens valuees.
   */
  function transferAdvisorsTokensArray(address[] _to, uint256[] _values) public
    onlyAdmin whenNotPaused returns (bool success) {
      require(_to.length == _values.length);
      for (uint32 i = 0; i < _to.length; i++)
        if(!transferAdvisorsTokens(_to[i], _values[i])) {
          revert();
          return false;
        }
      return true;
  }

  /**
   * @dev Current Sale states methods.
   */
  function soldTokensSent() external view returns (uint256) {
    return SALE_SENT;
  }
  function soldTokensAvailable() external view returns (uint256) {
    return SALE_SUPPLY.sub(SALE_SENT);
  }

  function ownerTokensSent() external view returns (uint256) {
    return OWNER_SENT;
  }
  function ownerTokensAvailable() external view returns (uint256) {
    return OWNER_SUPPLY.sub(OWNER_SENT);
  }

  function bountyTokensSent() external view returns (uint256) {
    return BOUNTY_SENT;
  }
  function bountyTokensAvailable() external view returns (uint256) {
    return BOUNTY_SUPPLY.sub(BOUNTY_SENT);
  }

  function advisorsTokensSent() external view returns (uint256) {
    return ADVISORS_SENT;
  }
  function advisorsTokensAvailable() external view returns (uint256) {
    return ADVISORS_SUPPLY.sub(ADVISORS_SENT);
  }

  /**
   * @dev Transfer tokens from msg.sender account directy to address array with values array.
   * param _dests  recipients.
   * @param _values Tokens values.
   */
  function transferArray(address[] _dests, uint256[] _values) public returns (bool success) {
      require(_dests.length == _values.length);
      for (uint32 i = 0; i < _dests.length; i++) {
        if(_values[i] > balances[msg.sender] || msg.sender == _dests[i] || _dests[i] == address(0)) {
          revert();
          return false;
        }
        balances[msg.sender] = balances[msg.sender].sub(_values[i]);
        balances[_dests[i]] = balances[_dests[i]].add(_values[i]);
        emit Transfer(msg.sender, _dests[i], _values[i]);
      }
      return true;
  }

}