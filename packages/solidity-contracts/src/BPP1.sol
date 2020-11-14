/**
 * Source Code first verified at https://etherscan.io on Wednesday, May 1, 2019
 (UTC) */

pragma solidity ^0.5.0;

contract BPP1{
    string private _name = "Bitcoin Payment Performance";
    string private _symbol = "BPP";
    uint8 private _decimals = 6;
    uint256 private _totalSupply = 10 * (10 ** uint256(_decimals));
    mapping(address=>uint256) private _balances;
    mapping(address=>mapping(address=>uint256)) private _allowances;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    constructor() public{
        _balances[msg.sender] = _totalSupply;
    }

    function name() public view returns (string memory name){
        name = _name;
    }

    function symbol() public view returns (string memory symbol){
        symbol = _symbol;
    }

    function decimals() public view returns (uint8 decimals){
        decimals = _decimals;
    }

    function totalSupply() public view returns (uint256 totalSupply){
        totalSupply = _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance){
        balance = _balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success){
        require(_balances[msg.sender] >= _value);
        _balances[msg.sender] -= _value;
        _balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        success = true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        require(_balances[_from] >= _value);
        require(_allowances[_from][msg.sender] >= _value);
        _balances[_from] -= _value;
        _allowances[_from][msg.sender] -= _value;
        _balances[_to] += _value;
        emit Transfer(_from, _to, _value);
        success = true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success){
        _allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        success = true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining){
        remaining = _allowances[_owner][_spender];
    }
}