/**
 * Source Code first verified at https://etherscan.io on Sunday, May 5, 2019
 (UTC) */

pragma solidity 0.4.19;

contract Ownable {
    address public owner;

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
}

contract ContractReceiver {
    function tokenFallback(address _from, uint _value) public pure returns(address) {
       if (_value != 0) return _from;
    }
}

contract SafeMath {
	uint256 constant public MAX_UINT256 =
    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

	function safeAdd(uint256 x, uint256 y) pure internal returns (uint256 z) {
	    if (x > MAX_UINT256 - y) revert();
		return x + y;
	}

	function safeSub(uint256 x, uint256 y) pure internal returns (uint256 z) {
        if (x < y) revert();
        return x - y;
	}

	function safeMul(uint256 x, uint256 y) pure internal returns (uint256 z) {
        if (y == 0) return 0;
        if (x > MAX_UINT256 / y) revert();
        return x * y;
	}
}

contract ValuesShare is SafeMath, Ownable {

    mapping(address => uint) balanceOf;

    string public name = "ValuesShare";
    string public symbol = "VS";
    uint8 public decimals = 18;
    uint256 public totalSupply = 39000000000000000000000000;

    event Transfer(address indexed from, address indexed to, uint value);
    event Burn(address indexed from, uint256 value);

    function ValuesShare() public payable { balanceOf[msg.sender] = totalSupply; }

    function transfer(address _to, uint _value) public returns (bool success) {
        if(isContract(_to)) return transferToContract(_to, _value);
        return transferToAddress(_to, _value);
    }

    function isContract(address _addr) private view returns (bool is_contract) {
        uint length;
        assembly { length := extcodesize(_addr) }
        return (length>0);
    }

    function transferToAddress(address _to, uint _value) private returns (bool success) {
        require(getbalance(msg.sender) >= _value);
        balanceOf[msg.sender] = safeSub(getbalance(msg.sender), _value);
        balanceOf[_to] = safeAdd(getbalance(_to), _value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferToContract(address _to, uint _value) private returns (bool success) {
        require(getbalance(msg.sender) >= _value);
        balanceOf[msg.sender] = safeSub(getbalance(msg.sender), _value);
        balanceOf[_to] = safeAdd(getbalance(_to), _value);
        ContractReceiver receiver = ContractReceiver(_to);
        receiver.tokenFallback(msg.sender, _value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function getbalance(address _ethaddress) public view returns (uint balance) {
        return balanceOf[_ethaddress];
    }
    
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] > _value);
		require(_value >= 0); 
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);
        totalSupply = SafeMath.safeSub(totalSupply,_value); 
        Burn(msg.sender, _value);
        return true;
    }
}