/**
 * Source Code first verified at https://etherscan.io on Tuesday, April 30, 2019
 (UTC) */

pragma solidity ^0.4.18;


contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}


contract ERC20 {

  function totalSupply() public view returns (uint256);
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);

  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
   // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
    
 
}



contract SafeMath {

  function safeAdd(uint256 x, uint256 y) internal pure returns(uint256) {
    uint256 z = x + y;
    assert((z >= x) && (z >= y));
    return z;
  }

  function safeSubtract(uint256 x, uint256 y) internal pure returns(uint256) {
    assert(x >= y);
    uint256 z = x - y;
    return z;
  }

  function safeMult(uint256 x, uint256 y) internal pure returns(uint256) {
    uint256 z = x * y;
    assert((x == 0)||(z/x == y));
    return z;
  }

  function safeDiv(uint256 x, uint256 y) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 z = x / y;
    return z;
  }
}


contract StandardToken is ERC20, SafeMath {
  /**
  * @dev Fix for the ERC20 short address attack.
   */
  modifier onlyPayloadSize(uint size) {
    require(msg.data.length >= size + 4) ;
    _;
  }

  mapping(address => uint256) balances;
  mapping (address => mapping (address => uint256)) internal allowed;
  
  // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

  function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) public returns (bool){
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = safeSubtract(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    Transfer(msg.sender, _to, _value);
    
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    uint _allowance = allowed[_from][msg.sender];

    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSubtract(balances[_from], _value);
    allowed[_from][msg.sender] = safeSubtract(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint) {
    return allowed[_owner][_spender];
  }

}

contract TokenD is StandardToken {
  string public constant name = "TokenD";
  string public constant symbol = "TD";
  uint256 public constant decimals = 18;
  string public version = "1.0";

  uint256 public total = 100 * (10**7) * 10**decimals;   // total

  function TokenD() public {
    balances[msg.sender] = total * 10/100; //founder
    
    Transfer(0x0, msg.sender, total);
    
	
	
        balances[0x856F376D47eDB14e44932E3102444fa6b0994894] = total * 10 / 100;    //crowd sale
        balances[0xa6bA34fBd8E06044800B98abA83D44c8500cE2B6] = total * 10 / 100;    // promotion
        balances[0x00c73B30d80E9166CFe4C76BC412271D25bEAdC1] = total * 20 / 100;	//corporate
        balances[0x977707E4D52A5A52781aB505A0f33B271E9688F3] = total * 25 / 100;	//Market Making
        balances[0xCda838eef17E80528F2f7c03E5049f71dFc06314] = total * 25 / 100;	//secure token
      
	
	
  }

  function totalSupply() public view returns (uint256) {
    return total;
  }

  function transfer(address _to, uint _value) public returns (bool) {
    return super.transfer(_to,_value);
  }

  function approve(address _spender, uint _value) public returns (bool) {
    return super.approve(_spender,_value);
  }

  function airdropToAddresses(address[] addrs, uint256 amount) public {
    for (uint256 i = 0; i < addrs.length; i++) {
      transfer(addrs[i], amount);
    }
  }
  
   /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        total -= _value;                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }
  
 
  
  /**
     * Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        total -= _value;                              // Update totalSupply
        emit Burn(_from, _value);
        return true;
    }

 
  
  
  
  
}