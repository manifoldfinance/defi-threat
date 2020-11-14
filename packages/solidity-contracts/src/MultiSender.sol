/**
 * Source Code first verified at https://etherscan.io on Wednesday, April 24, 2019
 (UTC) */

pragma solidity ^0.5.7;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
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

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Ownable {
	address public owner;
	address public newOwner;

	event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

	constructor() public {
		owner = msg.sender;
		newOwner = address(0);
	}

	modifier onlyOwner() {
		require(msg.sender == owner, "msg.sender == owner");
		_;
	}

	function transferOwnership(address _newOwner) public onlyOwner {
		require(address(0) != _newOwner, "address(0) != _newOwner");
		newOwner = _newOwner;
	}

	function acceptOwnership() public {
		require(msg.sender == newOwner, "msg.sender == newOwner");
		emit OwnershipTransferred(owner, msg.sender);
		owner = msg.sender;
		newOwner = address(0);
	}
}

contract Authorizable is Ownable {
    mapping(address => bool) public authorized;
  
    event AuthorizationSet(address indexed addressAuthorized, bool indexed authorization);

    constructor() public {
        authorized[msg.sender] = true;
    }

    modifier onlyAuthorized() {
        require(authorized[msg.sender], "authorized[msg.sender]");
        _;
    }

    function setAuthorized(address addressAuthorized, bool authorization) onlyOwner public {
        emit AuthorizationSet(addressAuthorized, authorization);
        authorized[addressAuthorized] = authorization;
    }
  
}
 
contract tokenInterface {
    function transfer(address _to, uint256 _value) public returns (bool);
}

contract MultiSender is Authorizable {
	tokenInterface public tokenContract;
	
	constructor(address _tokenAddress) public {
	    tokenContract = tokenInterface(_tokenAddress);
	}
	
	function updateTokenContract(address _tokenAddress) public onlyAuthorized {
        tokenContract = tokenInterface(_tokenAddress);
    }
	
    function multiSend(address[] memory _dests, uint256[] memory _values) public onlyAuthorized returns(uint256) {
        require(_dests.length == _values.length, "_dests.length == _values.length");
        uint256 i = 0;
        while (i < _dests.length) {
           tokenContract.transfer(_dests[i], _values[i]);
           i += 1;
        }
        return(i);
    }
	
	function withdrawTokens(address to, uint256 value) public onlyAuthorized returns (bool) {
        return tokenContract.transfer(to, value);
    }
    
    function withdrawEther() public onlyAuthorized returns (bool) {
        msg.sender.transfer(address(this).balance);
        return true;
    }
}