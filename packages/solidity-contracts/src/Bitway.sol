/**
 * Source Code first verified at https://etherscan.io on Wednesday, May 1, 2019
 (UTC) */

pragma solidity ^0.5.0;

// --------------------------------------------------------------
// Name     : Bitway
// Symbol   : WAY
// Supply   : 21,000,000.000000000000000000
// Decimals : 18
// --------------------------------------------------------------

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

contract ERC20 {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Owned {
    address public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract Bitway is ERC20, Owned {
    using SafeMath for uint;

    string public  name;
    string public symbol;
    uint public decimals;
    uint _totalSupply;
    uint _maxSupply;
    bool public completed;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    modifier validDestination( address to ) {
    require(to != address(0x0));
    require(to != address(this) );
    _;
    }

    constructor() public {
        name = "Bitway";
        symbol = "WAY";
        decimals = 18;
        _totalSupply = 0;
        _maxSupply = 21000000 * 10**uint(decimals);
        completed = false;
    }

    function mint(uint tokens) public onlyOwner {
        require(!completed);
        balances[msg.sender] = balances[msg.sender].add(tokens);
        _totalSupply = _totalSupply.add(tokens);
        emit Transfer(address(0), msg.sender, tokens);
        if (_totalSupply >= _maxSupply)
        completed = true;
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function maxSupply() public view returns (uint) {
        return _maxSupply;
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public validDestination(to) returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public validDestination(to) returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function () external payable {
        revert();
    }

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}