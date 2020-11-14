/**
 * Source Code first verified at https://etherscan.io on Saturday, April 13, 2019
 (UTC) */

pragma solidity 0.4.25;
// ----------------------------------------------------------------------------------------------
// sto token by storeum Limited.
// An ERC20 standard
//
// author: storeum team 
// Contact: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c3b0b6b3b3acb1b783b0b7acb1a6b6aeeda0ac">[email protected]</a>
contract ERC20 {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256 _user);
  function transfer(address to, uint256 value) public returns (bool success);
  function allowance(address owner, address spender) public view returns (uint256 value);
  function transferFrom(address from, address to, uint256 value) public returns (bool success);
  function approve(address spender, uint256 value) public returns (bool success);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
  
  function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal pure  returns (uint256) {
    uint c = a + b;
    assert(c>=a);
    return c;
  }
  function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }
}

contract OnlyOwner {
  address public owner;
  address private controller;
  //log the previous and new controller when event  is fired.
  event SetNewController(address prev_controller, address new_controller);
  /** 
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
    controller = owner;
  }


  /**
   * @dev Throws if called by any account other than the owner. 
   */
  modifier isOwner {
    require(msg.sender == owner);
    _;
  }
  
  /**
   * @dev Throws if called by any account other than the controller. 
   */
  modifier isController {
    require(msg.sender == controller);
    _;
  }
  
  function replaceController(address new_controller) isController public returns(bool){
    require(new_controller != address(0x0));
	controller = new_controller;
    emit SetNewController(msg.sender,controller);
    return true;   
  }

}

contract StandardToken is ERC20{
  using SafeMath for uint256;

    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

  
    function _transfer(address _from, address _to, uint256 _value) internal returns (bool success){
      //prevent sending of tokens from genesis address or to self
      require(_from != address(0) && _from != _to);
      require(_to != address(0));
      //subtract tokens from the sender on transfer
      balances[_from] = balances[_from].safeSub(_value);
      //add tokens to the receiver on reception
      balances[_to] = balances[_to].safeAdd(_value);
      return true;
    }

  function transfer(address _to, uint256 _value) public returns (bool success) 
  { 
    require(_value <= balances[msg.sender]);
      _transfer(msg.sender,_to,_value);
      emit Transfer(msg.sender, _to, _value);
      return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
      uint256 _allowance = allowed[_from][msg.sender];
      //value must be less than allowed value
      require(_value <= _allowance);
      //balance of sender + token value transferred by sender must be greater than balance of sender
      require(balances[_to] + _value > balances[_to]);
      //call transfer function
      _transfer(_from,_to,_value);
      //subtract the amount allowed to the sender 
      allowed[_from][msg.sender] = _allowance.safeSub(_value);
      //trigger Transfer event
      emit Transfer(_from, _to, _value);
      return true;
    }

    function balanceOf(address _owner) public constant returns (uint balance) {
      return balances[_owner];
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
    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender,0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));
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

}

contract STO is StandardToken, OnlyOwner{
	uint256 public constant decimals = 18;
    string public constant name = "storeum";
    string public constant symbol = "STO";
    string public constant version = "1.0";
    uint256 public constant totalSupply =900000*10**18;
    uint256 private approvalCounts =0;
    uint256 private minRequiredApprovals =2;
    address public burnedTokensReceiver;
    
    constructor() public{
        balances[msg.sender] = totalSupply;
        burnedTokensReceiver = 0x0000000000000000000000000000000000000000;
    }

    /**
   * @dev Function to set approval count variable value.
   * @param _value uint The value by which approvalCounts variable will be set.
   */
    function setApprovalCounts(uint _value) public isController {
        approvalCounts = _value;
    }
    
    /**
   * @dev Function to set minimum require approval variable value.
   * @param _value uint The value by which minRequiredApprovals variable will be set.
   * @return true.
   */
    function setMinApprovalCounts(uint _value) public isController returns (bool){
        require(_value > 0);
        minRequiredApprovals = _value;
        return true;
    }
    
    /**
   * @dev Function to get approvalCounts variable value.
   * @return approvalCounts.
   */
    function getApprovalCount() public view isController returns(uint){
        return approvalCounts;
    }
    
     /**
   * @dev Function to get burned Tokens Receiver address.
   * @return burnedTokensReceiver.
   */
    function getBurnedTokensReceiver() public view isController returns(address){
        return burnedTokensReceiver;
    }
    
    
    function controllerApproval(address _from, uint256 _value) public isOwner returns (bool) {
        require(minRequiredApprovals <= approvalCounts);
		require(_value <= balances[_from]);		
        balances[_from] = balances[_from].safeSub(_value);
        balances[burnedTokensReceiver] = balances[burnedTokensReceiver].safeAdd(_value);
        emit Transfer(_from,burnedTokensReceiver, _value);
        return true;
    }
}