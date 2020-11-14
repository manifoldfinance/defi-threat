/**
 * Source Code first verified at https://etherscan.io on Monday, April 29, 2019
 (UTC) */

pragma solidity ^0.4.24;

contract SafeMath {
    function safeAdd(uint _a, uint _b) public pure returns (uint c) {
        c = _a + _b;
        require(c >= _a);
    }
    function safeSub(uint _a, uint _b) public pure returns (uint c) {
        require(_b <= _a);
        c = _a - _b;
    }
}

contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address _tokenOwner) public view returns (uint balance);
    function allowance(address _tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address _to, uint _tokens) public returns (bool success);
    function approve(address _spender, uint _tokens) public returns (bool success);
    function transferFrom(address _from, address _to, uint _tokens) public returns (bool success);

    event Transfer(address indexed _from, address indexed _to, uint _tokens);
    event Approval(address indexed _tokenOwner, address indexed _spender, uint _tokens);
}

contract ApproveAndCallFallBack {
    function receiveApproval(address _from, uint256 _tokens, address _token, bytes _extraData) public;
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

contract Pausable is Owned {
  event Paused();
  event Unpaused();

  bool public paused = false;

  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  modifier whenPaused() {
    require(paused);
    _;
  }

  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Paused();
  }

  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpaused();
  }
}


contract YaluCoin is ERC20Interface, Pausable, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) internal allowed;

    constructor() public {
        symbol = "YLC";
        name = "YaluCoin";
        decimals = 0;
        _totalSupply = 1000000;
        balances[0x9BE91439A3882dEF9EEfA0e89f790135219e1809] = _totalSupply;
        emit Transfer(address(0), 0x9BE91439A3882dEF9EEfA0e89f790135219e1809, _totalSupply);
    }


    function totalSupply() public view returns (uint) {
        return _totalSupply  - balances[address(0)];
    }

    function balanceOf(address _tokenOwner) public view returns (uint balance) {
        return balances[_tokenOwner];
    }

    function transfer(address _to, uint _tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], _tokens);
        balances[_to] = safeAdd(balances[_to], _tokens);
        emit Transfer(msg.sender, _to, _tokens);
        return true;
    }

    function approve(address _spender, uint _tokens) public whenNotPaused  returns (bool success) {
        allowed[msg.sender][_spender] = _tokens;
        emit Approval(msg.sender, _spender, _tokens);
        return true;
    }

    function transferFrom(address _from, address _to, uint _tokens) public whenNotPaused returns (bool success) {
        balances[_from] = safeSub(balances[_from], _tokens);
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _tokens);
        balances[_to] = safeAdd(balances[_to], _tokens);
        emit Transfer(_from, _to, _tokens);
        return true;
    }

    function allowance(address _tokenOwner, address _spender) public view returns (uint remaining) {
        return allowed[_tokenOwner][_spender];
    }

    function approveAndCall(address _spender, uint _tokens, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _tokens;
        emit Approval(msg.sender, _spender, _tokens);
        ApproveAndCallFallBack(_spender).receiveApproval(msg.sender, _tokens, this, _extraData);
        return true;
    }
}