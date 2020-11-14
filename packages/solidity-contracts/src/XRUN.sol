/**
 * Source Code first verified at https://etherscan.io on Friday, May 10, 2019
 (UTC) */

pragma solidity ^0.4.24;

contract owned {

	address public owner;

	constructor() public {

		owner = msg.sender;
	}

	modifier onlyOwner {

		require(msg.sender == owner);
		_;
	}

	function transferOwnership(address newOwner) onlyOwner public {

		owner = newOwner;
	}
}

interface tokenRecipient {

	function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external;
}

contract TokenERC20 {

	string public name;
	string public symbol;
	uint8 public decimals = 18;
	uint256 public totalSupply;

	mapping (address => uint256) public balanceOf;
	mapping (address => mapping (address => uint256)) public allowance;

	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
	event Burn(address indexed from, uint256 value);

	constructor(
		uint256 initialSupply,
		string memory tokenName,
		string memory tokenSymbol
	) public {
		totalSupply = initialSupply * 10 ** uint256(decimals);
		balanceOf[msg.sender] = totalSupply;
		name = tokenName;
		symbol = tokenSymbol;
	}

	function _transfer(address _from, address _to, uint _value) internal {

		require(_to != address(0x0));
		require(balanceOf[_from] >= _value);
		require(balanceOf[_to] + _value > balanceOf[_to]);

		uint previousBalances = balanceOf[_from] + balanceOf[_to];
		balanceOf[_from] -= _value;
		balanceOf[_to] += _value;

		emit Transfer(_from, _to, _value);
		assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
	}

	function transfer(address _to, uint256 _value) public returns (bool success) {

		_transfer(msg.sender, _to, _value);

		return true;
	}

	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

		require(_value <= allowance[_from][msg.sender]);

		allowance[_from][msg.sender] -= _value;

		_transfer(_from, _to, _value);

		return true;
	}

	function approve(address _spender, uint256 _value) public returns (bool success) {

		allowance[msg.sender][_spender] = _value;

		emit Approval(msg.sender, _spender, _value);

		return true;
	}

	function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) public returns (bool success) {

		tokenRecipient spender = tokenRecipient(_spender);

		if (approve(_spender, _value)) {
			spender.receiveApproval(msg.sender, _value, address(this), _extraData);

			return true;
		}
	}

	function burn(uint256 _value) public returns (bool success) {

		require(balanceOf[msg.sender] >= _value);

		balanceOf[msg.sender] -= _value;
		totalSupply -= _value;

		emit Burn(msg.sender, _value);
		return true;
	}

	function burnFrom(address _from, uint256 _value) public returns (bool success) {

		require(balanceOf[_from] >= _value);
		require(_value <= allowance[_from][msg.sender]);

		balanceOf[_from] -= _value;
		allowance[_from][msg.sender] -= _value;
		totalSupply -= _value;

		emit Burn(_from, _value);
		return true;
	}
}

contract XRUN is owned, TokenERC20 {

	uint256 public sellPrice;
	uint256 public buyPrice;

	mapping (address => bool) public frozenAccount;
	mapping (address => uint256) public limitAccount;

    event MultiFrozenFunds(address[] target, bool freeze);

	constructor(
		uint256 initialSupply,
		string memory tokenName,
		string memory tokenSymbol
	) TokenERC20(initialSupply, tokenName, tokenSymbol) public {}

	function _transfer(address _from, address _to, uint _value) internal {

		require(_to != address(0x0));
		require(balanceOf[_from] >= _value);
		require(balanceOf[_to] + _value >= balanceOf[_to]);
		
		if ( frozenAccount[_from] ) {
			require(limitAccount[_from] >= _value);
		}

		balanceOf[_from] -= _value;
		balanceOf[_to] += _value;

		if ( frozenAccount[_from] ) {
			limitAccount[_from] -= _value;
		}

		emit Transfer(_from, _to, _value);
	}

	function mintToken(address target, uint256 mintedAmount) onlyOwner public {

		balanceOf[target] += mintedAmount;
		totalSupply += mintedAmount;

		emit Transfer(address(0), address(this), mintedAmount);
		emit Transfer(address(this), target, mintedAmount);
	}

    function multiSend(address[] _to, uint[] values) onlyOwner public {

        for ( uint j=0; j<_to.length; j++ ) {

			address to = _to[j];
			uint value = values[j];

            balanceOf[msg.sender] -= value;
			balanceOf[to] += value;
        }
    }

    function multiFrozen(address[] target, bool freeze) onlyOwner public {

		for ( uint i=0; i<target.length; i++ ) {
			frozenAccount[target[i]] = freeze;
		}

        emit MultiFrozenFunds(target, freeze);
    }

	function multiLimit(address[] target, uint256[] limitBalance) onlyOwner public {
		
		for ( uint i=0; i<target.length; i++ ) {
			limitAccount[target[i]] = limitBalance[i];
		}
	}

	function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {

		sellPrice = newSellPrice;
		buyPrice = newBuyPrice;
	}

	function buy() payable public {

		uint amount = msg.value / buyPrice;

		_transfer(address(this), msg.sender, amount);
	}

	function sell(uint256 amount) public {

		address myAddress = address(this);

		require(myAddress.balance >= amount * sellPrice);

		_transfer(msg.sender, address(this), amount);

		msg.sender.transfer(amount * sellPrice);
	}
}