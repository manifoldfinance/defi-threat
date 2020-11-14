/**
 * Source Code first verified at https://etherscan.io on Thursday, May 2, 2019
 (UTC) */

pragma solidity ^ 0.5 .1;

contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns(uint c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint a, uint b) public pure returns(uint c) {
        require(b <= a);
        c = a - b;
    }

    function safeMul(uint a, uint b) public pure returns(uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function safeDiv(uint a, uint b) public pure returns(uint c) {
        require(b > 0);
        c = a / b;
    }
}

contract ERC223ReceivingContract {
    /**
     * @dev Standard ERC223 function that will handle incoming token transfers.
     *
     * @param _from  Token sender address.
     * @param _value Amount of tokens.
     * @param _data  Transaction metadata.
     */
    function tokenFallback(address _from, uint _value, bytes memory _data) public returns(bool);
}

contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract STORH is SafeMath, Owned {

    event Transfer(address indexed _from, address indexed _to, uint256 _value, bytes _data);
    event MultiERC20Transfer(
        address indexed _from,
        address _to,
        uint _amount
    );

    mapping(address => uint) balances;
    mapping(address => bool) public verified;

    string public name = "Storh";
    string public symbol = "STORH";
    uint8 public decimals = 4;
    uint public totalSupply;
    uint public startTime;

    modifier isVerified(address reciever) {
        require(verified[msg.sender]);
        require(verified[reciever]);
        _;
    }

    modifier hasMinBalance(uint value) {
        if (now < (startTime + 365 days) && msg.sender == owner) {
            require(balances[owner] >= ((totalSupply * 5) / 100) + value);
        }
        _;
    }

    constructor() public {
        balances[msg.sender] = 1200000000000;
        totalSupply = balances[msg.sender];
        verified[msg.sender] = true;
        startTime = now;
    }

    function verifyAccount(address account) public onlyOwner {
        verified[account] = true;
    }

    function setStartTime(uint _startTime) public {
        startTime = _startTime;
    }

    function multiERC20Transfer(
        address[] memory _addresses,
        uint[] memory _amounts
    ) public {
        for (uint i = 0; i < _addresses.length; i++) {
            transfer(_addresses[i], _amounts[i]);
            emit MultiERC20Transfer(
                msg.sender,
                _addresses[i],
                _amounts[i]
            );
        }
    }

    function transfer(address _to, uint _value, bytes memory _data) public isVerified(_to) hasMinBalance(_value) {
        // backwards compatibility
        uint codeLength;

        assembly {
            codeLength: = extcodesize(_to)
        }

        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        if (codeLength > 0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            if (!receiver.tokenFallback(msg.sender, _value, _data)) revert();
        }
        emit Transfer(msg.sender, _to, _value, _data);
    }

    function transfer(address _to, uint _value) public isVerified(_to) hasMinBalance(_value) {
        uint codeLength;
        bytes memory empty;

        assembly {
            codeLength: = extcodesize(_to)
        }

        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        if (codeLength > 0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            if (!receiver.tokenFallback(msg.sender, _value, empty)) revert();
        }
        emit Transfer(msg.sender, _to, _value, empty);
    }


    function balanceOf(address _owner) view public returns(uint balance) {
        return balances[_owner];
    }

    function close() public onlyOwner {
        selfdestruct(address(uint160(owner)));
    }
}