/**
 * Source Code first verified at https://etherscan.io on Wednesday, March 27, 2019
 (UTC) */

pragma solidity 0.4.21;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @dev The "SCHTSub" contract is the interface declaration of a Sub-Contract that is paired with this current instance of the Master Contract.
 */
contract SCHTSub {
  function changeStage(uint256 stageCapValue) public;
  function transfer(address _to, uint256 _value, address origin) public returns (bool);
  function transferFromTo(address _from, address _to, uint256 _value, address origin) public returns (bool);
  function transferFrom(address _from, address _to, uint256 _value, address origin) public returns (bool);
  function approve(address _spender, uint256 _value, address origin) public returns (bool);
  function increaseApproval(address _spender, uint256 _addedValue, address origin) public returns (bool);
  function decreaseApproval(address _spender, uint256 _subtractedValue, address origin) public returns (bool);
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public ctOwner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == ctOwner);
    _;
  }

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
   */
  function Ownable() public {
    ctOwner = msg.sender;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(ctOwner, newOwner);
    ctOwner = newOwner;
  }
}

contract SubRule is Ownable {
  address public subContractAddr;

  function setSubContractAddr(address _newSubAddr) public onlyOwner {
    subContractAddr = _newSubAddr;
  }

  /**
   * @dev Throws if called by any contract other than the Sub-Contract address that has been set.
   */
  modifier onlySubContract() {
    require(msg.sender == subContractAddr);
    _;
  }
}

/**
 * @title Destructible
 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.
 */
contract Destructible is SubRule {

  function Destructible() public payable { }

  /**
   * @dev Transfers the current balance to the owner and terminates the contract.
   */
  function destroy() onlyOwner public {
    selfdestruct(ctOwner);
  }

  /**
   * @dev Transfers the current balance to the _recipient address and terminates the contract.
   */
  function destroyAndSend(address _recipient) onlyOwner public {
    selfdestruct(_recipient);
  }
}

/**
 * @title Capable
 * @dev The Capable contract has a cap value for each stage of the token Sale, Only set/reset by owner.
 */
contract Capable is Destructible {
  using SafeMath for uint256;
  uint256 saleStage;
  uint256 currentStageSpent;
  uint256 currentStageCap;

  event StageChanged(uint256 indexed previousStage, uint256 indexed newStage);

  function getCurrentStage() public view returns (uint256) {
    return saleStage;
  }

  function getCurrentStageSpent() public view returns (uint256) {
    return currentStageSpent;
  }

  function getCurrentRemainingCap() public view returns (uint256) {
    return currentStageCap.sub(currentStageSpent);
  }

  function getCurrentCap() public view returns (uint256) {
    return currentStageCap;
  }

  function setCurrentStageSpent(uint256 _value) public onlySubContract {
    currentStageSpent = _value;
  }

  function setCurrentCap(uint256 _value) public onlySubContract {
    currentStageCap = _value;
  }

  function incrementStage() public onlySubContract {
    saleStage = saleStage+1;
  }

  function changeStage(uint256 stageCapValue) public onlyOwner returns (bool){
    SCHTSub sc = SCHTSub(subContractAddr);
    sc.changeStage(stageCapValue);
    emit StageChanged(saleStage-1, saleStage);
    return true;
  }
}

/**
 * @title ERC20Basic interface
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function transferFromTo(address from, address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title BasicToken
 */
contract BasicToken is ERC20Basic, Capable {
  mapping(address => uint256) balances;
  mapping(address => address) addrIndex;

  uint256 totalSupply_;
  uint256 totalSpent_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

   /**
  * @dev total number of tokens spent in sale stages
  */
  function getTotalSpent() public view returns (uint256) {
    return totalSpent_;
  }


  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    SCHTSub sc = SCHTSub(subContractAddr);
    bool result = sc.transfer(_to, _value, msg.sender);
    emit Transfer(msg.sender, _to, _value);
    return result;
  }

  /**
  * @dev transfer token for a specified address
  * @param _from The address to transfer from.
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transferFromTo(address _from, address _to, uint256 _value) public returns (bool) {
    SCHTSub sc = SCHTSub(subContractAddr);
    bool result = sc.transferFromTo(_from, _to, _value, msg.sender);
    emit Transfer(_from, _to, _value);
    return result;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

  function setBalanceForAddr( address _addr, uint256 _value) public onlySubContract {
    balances[_addr] = _value;
  }

   function setTotalSpent(uint256 _value) public onlySubContract {
    totalSpent_=_value;
  }

  function addAddrToIndex(address _addr) public onlySubContract {
    if(!isAddrExists(_addr)){
      addrIndex[_addr] = _addr;
    }
  }

  function isAddrExists(address _addr) public view returns (bool) {
    return (_addr == addrIndex[_addr]);
  }
}

/**
 * @title BurnableToken
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public onlyOwner {
    require(_value <= balances[msg.sender]);
    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(burner, _value);
    emit Transfer(burner, address(0), _value);
  }
}

/**
 * @title ERC20 interface
 */
contract ERC20 is ERC20Basic {
  event Approval(address indexed owner, address indexed spender, uint256 value);
  function approve(address spender, uint256 value) public returns (bool);
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
}

/**
 * @title Standard ERC20 token
 * @dev Implementation of the basic standard token.
 */
contract StandardToken is ERC20, BurnableToken {

  mapping (address => mapping (address => uint256)) internal allowed;

  function approve(address _spender, uint256 _value) public returns (bool) {
    SCHTSub sc = SCHTSub(subContractAddr);
    bool result = sc.approve(_spender,_value, msg.sender);
    emit Approval(msg.sender, _spender, _value);
    return result;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    SCHTSub sc = SCHTSub(subContractAddr);
    bool result = sc.transferFrom(_from, _to, _value, msg.sender);
    emit Transfer(_from, _to, _value);
    return result;
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

  function setAllowance(address _owner, address _spender, uint256 _value) public onlySubContract returns (bool) {
    allowed[_owner][_spender] = _value;
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
  function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
    SCHTSub sc = SCHTSub(subContractAddr);
    bool result = sc.increaseApproval(_spender,_addedValue, msg.sender);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return result;
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
  function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
    SCHTSub sc = SCHTSub(subContractAddr);
    bool result = sc.decreaseApproval(_spender,_subtractedValue,msg.sender);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return result;
  }
}

/**
 * @title SCHToken
 * All tokens are pre-assigned to the creator.
 */

contract SCHToken is StandardToken {

  string public constant name = "SCHToken";
  string public constant symbol = "SCHT";
  uint8 public constant decimals = 18;

  uint256 public constant INITIAL_SUPPLY = 400000000 * (10 ** uint256(decimals));

  /**
   * @dev Constructor that gives msg.sender all of existing tokens
   * Defines stages and Stage Caps.
   */
  function SCHToken() public {
    totalSupply_ = INITIAL_SUPPLY;
    totalSpent_ = 0;
    balances[msg.sender] = INITIAL_SUPPLY;
    emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);

    saleStage = 0;
    currentStageSpent = 0;
    currentStageCap = 0;
  }
}