/**
 * Source Code first verified at https://etherscan.io on Wednesday, May 8, 2019
 (UTC) */

pragma solidity ^0.5.0;

contract SuperToken {
    
    event Transfer(address indexed from, address indexed to, uint tokens);

    mapping(address => uint256) private balances;
    
    uint256 private _totalSupply;
    uint256 private _rate= 0.006 ether;


    function name() public pure returns (string memory) { return "SuperToken"; }
    function symbol() public pure returns (string memory) { return "STK"; }
    function decimals() public pure returns (uint8) { return 18; }
    function totalSupply() public view returns (uint256) { return _totalSupply; }
    function balanceOf(address _owner) public view returns (uint256) { return balances[_owner];}
    
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require (balances[msg.sender] >= _value) ;
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
   
    function mint(uint256 amount) payable public {
        require(msg.value >= _rate*amount ) ; 
        _totalSupply += amount;
        balances[msg.sender] += amount;
    }  
    
    function burn(uint256 amount) public returns (bool success) {
        require (balances[msg.sender] >= amount) ;
        balances[msg.sender] -=amount;
        _totalSupply -= amount;
        return true;
    }  


}