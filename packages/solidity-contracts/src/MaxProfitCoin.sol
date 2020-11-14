/**
 * Source Code first verified at https://etherscan.io on Wednesday, March 20, 2019
 (UTC) */

pragma solidity ^0.5.0;

/*
	Basic ERC-223 declaration
*/
contract ERC223Interface {
	uint256 public totalSupply;
	function transfer(address to, uint256 value) public;
	function transfer(address to, uint256 value, bytes memory data) public;
	event Transfer(address indexed from, address indexed to, uint256 value, bytes data);

	mapping (address => uint256) public balanceOf;
}


/*
	provides the tokenFallback function
	as required in the ERC-223 standard
*/
contract ContractReceiver {

	struct TKN {
		address sender;
		uint value;
		bytes data;
		bytes4 sig;
	}


	function tokenFallback(address _from, uint _value, bytes memory _data) public pure {
		TKN memory tkn;
		tkn.sender = _from;
		tkn.value = _value;
		tkn.data = _data;
		uint32 u = uint32(bytes4(_data[3])) + (uint32(bytes4(_data[2]) << 8)) + (uint32(bytes4(_data[1]) << 16)) + (uint32(bytes4(_data[0])) << 24);
		tkn.sig = bytes4(u);
	}
}


contract owned {
	address public owner;

	constructor() public {
		owner = msg.sender;
	}

	modifier onlyOwner {
		require(msg.sender == owner, "you are not the owner of this token");
		_;
	}

	function transferOwnership(address newOwner) onlyOwner public {
		owner = newOwner;
	}
}






interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; }

contract MaxProfitCoin is owned, ERC223Interface{

	// implementation of addition and 
	// substraction which ensures that 
	// we don't go lower than zero
	// and we don't overflow

	// name of our token
	string public name = "MaxProfitCoin";
	// symbol
	string public symbol = "MPC";
	uint8 public decimals = 18;
	uint256 public totalSupply = 1 * 10**9 * 10 ** uint256(decimals);


	// events emitted by our smart contract
	// self-explanatory
	// for the definition of attributes go to the function definitions
	event Transfer(address indexed from, address indexed to, uint256 value, bytes indexed data);
	event Burn(address indexed from, address indexed to, uint256 value);

	constructor() public{
		// sends all initial coin to the wallet of the creator of the token
		// balanceOf[msg.sender] = totalSupply;	
		balanceOf[address(this)] = totalSupply;
	}

	
	/*
		internal/private function 
		
		contains the logic of actually transfering money from account to account

		attributes:
			_from: address => address of the wallet from which the transfer occurs
			_to: address => address of the wallet to which the tokens will be transfered
			_value: uint => amount of tokens to be transfered 
			_data: bytes => arbitrary data to be transfered with the transaction
							modeled after tx.data
	*/
	function _transfer(address _from, address _to, uint _value, bytes memory _data) private{
        uint codeLength;

        assembly {
            codeLength := extcodesize(_to)
        }
		require(_to != address(0x0), "don't send tokens to 0x0");
		require(balanceOf[_from] >= _value, "not enough money in sender's wallet");
		require(balanceOf[_to] + _value >= balanceOf[_to], "too much money in receiver's wallet");

        balanceOf[_from] = balanceOf[_from] -_value;
        balanceOf[_to] = balanceOf[_to] +_value;

        if(codeLength>0) {
            ContractReceiver receiver = ContractReceiver (_to);
            receiver.tokenFallback(_from, _value, _data);
        }
        emit Transfer(_from, _to, _value, _data);
	
	}


	/*
		public function 
		
		acts as intermediary between outside world and internal _transfer function

		attributes:
			_to: address => address of the wallet to which the tokens will be transfered
			_value: uint => amount of tokens to be transfered 
			_data: bytes => arbitrary data to be transfered with the transaction
							modeled after tx.data
	*/
	function transfer(address _to, uint _value, bytes memory _data)public {
		_transfer(msg.sender, _to, _value, _data);
    }
    

	/*
		public function 
		
		acts as intermediary between outside world and internal _transfer function
		provided for compatibility with ERC-20 standard

		attributes:
			_to: address => address of the wallet to which the tokens will be transfered
			_value: uint => amount of tokens to be transfered 
	*/
    function transfer(address _to, uint _value) public{
		bytes memory empty;
		_transfer(msg.sender, _to, _value, empty);
    }


}