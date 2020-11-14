/**
 * Source Code first verified at https://etherscan.io on Monday, May 6, 2019
 (UTC) */

pragma solidity ^0.4.25;

/**
 * 
 * Proxy to delegate OMG token for WWG (token was missing ERC20 returns)
 * 
 * https://ethergoo.io
 * 
 */

interface ERC20 {
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    function transfer(address to, uint tokens) external returns (bool success);
    function totalSupply() external constant returns (uint);
    function balanceOf(address tokenOwner) external constant returns (uint balance);
}

contract WWGProxyOMG is ERC20 {
    
    address constant clans = address(0xE97b5Fd7056d38c85C5F6924461F7055588A53D9);
    OMG constant omg = OMG(0xd26114cd6EE289AccF82350c8d8487fedB8A0C07);
    
    address owner;
    
    constructor() public {
        owner = msg.sender;
    }
    
    function transfer(address to, uint value) external returns (bool success) {
        require(msg.sender == clans || msg.sender == owner);
        omg.transfer(to, value);
        return true;
    }
    
    function transferFrom(address, address to, uint value) external returns (bool success) {
        require(msg.sender == clans || msg.sender == owner);
        omg.transferFrom(this, to, value);
        return true;
    }
    
    function totalSupply() external constant returns (uint) {
        return omg.totalSupply();
    }
    
    function balanceOf(address) external constant returns (uint balance) {
        return omg.balanceOf(this);
    }
    
}


contract OMG { 
    function transfer(address to, uint value);
    function transferFrom(address from, address to, uint value);
    uint public totalSupply;
    function balanceOf(address who) constant returns (uint);
}