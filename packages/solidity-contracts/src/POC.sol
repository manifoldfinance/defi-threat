/**
 * Source Code first verified at https://etherscan.io on Wednesday, April 17, 2019
 (UTC) */

pragma solidity ^0.4.25;


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
    uint256 c = a / b;
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

contract owned {
    address public owner;
    mapping (address => bool) public owners;
    
    constructor() public {
        owner = msg.sender;
        owners[msg.sender] = true;
    }
    
    modifier zeus {
        require(msg.sender == owner);
        _;
    }

    modifier athena {
        require(owners[msg.sender] == true);
        _;
    }

    function addOwner(address _newOwner) zeus public {
        owners[_newOwner] = true;
    }
    
    function removeOwner(address _oldOwner) zeus public {
        owners[_oldOwner] = false;
    }
    
    function transferOwnership(address newOwner) public zeus {
        owner = newOwner;
        owners[newOwner] = true;
        owners[owner] = false;
    }
}

contract ContractConn {
    function transfer(address _to, uint _value) public;
}

contract POC is owned{
    
    using SafeMath for uint256;
    
    string public name;
    string public symbol;
    uint8 public decimals = 18;  
    uint256 public totalSupply;

    uint256 private constant DAY30 = 2592000;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => uint256) private lockType;
    mapping (address => uint256) private freezeTotal;
    mapping (address => uint256) private freezeBalance;
    mapping (address => uint256) private startReleaseTime;
    mapping (address => uint256) private endLockTime;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    
    constructor() public {
        totalSupply = 200000000 * 10 ** uint256(decimals);  
        balanceOf[msg.sender] = totalSupply;                
        name = "Pacific Ocean Coin";                                   
        symbol = "POC";                               
    }

    
    function _transfer(address _from, address _to, uint _value) internal {
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to].add(_value) > balanceOf[_to]);
		if(freezeBalance[_from] > 0){
			if(now >= endLockTime[_from]){
				delete freezeBalance[_from];
			}else if(now >= startReleaseTime[_from]){
				uint256 locks;
				if(lockType[_from] == 1){
					locks = (now - startReleaseTime[_from]) / DAY30 * 1;
					freezeBalance[_from] = freezeTotal[_from] * (10 - locks) / 10;
				}else if(lockType[_from] == 2){
					locks = (now - startReleaseTime[_from]) / DAY30 * 20;
					freezeBalance[_from] = freezeTotal[_from] * (100 - locks) / 100;
				}
			}
			require(_value <= balanceOf[_from] - freezeBalance[_from]);
		}
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public returns (bool){
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_value <= allowance[_from][msg.sender]);     
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        require(balanceOf[msg.sender] >= _value);
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender,_spender,_value);
        return true;
    }
    
    function lock (uint256 _type, address _to, uint256 _value) public athena {
        require(lockType[_to] == 0, "Each address can only be locked once and only accepts one lock mode.");
        lockType[_to] = _type;
        freezeTotal[_to] = _value;
        if (_type == 1) {
            startReleaseTime[_to] = DAY30 * 5 + now;
            freezeBalance[_to] = freezeTotal[_to].mul(10).div(10);
            endLockTime[_to] =  DAY30 * 10 + startReleaseTime[_to];
        } else if (_type == 2) {
            startReleaseTime[_to] = DAY30 * 11 + now;
            freezeBalance[_to] = freezeTotal[_to].mul(100).div(100);
            endLockTime[_to] =  DAY30 * 5 + startReleaseTime[_to];
        }
        _transfer(msg.sender, _to, _value);
    }
    
    function extract(address _tokenAddr,address _to,uint256 _value) public athena{
       ContractConn conn = ContractConn(_tokenAddr);
       conn.transfer(_to,_value);
    }
  
    function extractEth(uint256 _value) athena public{
       msg.sender.transfer(_value);
    }
 
}