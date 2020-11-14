/**
 * Source Code first verified at https://etherscan.io on Saturday, May 4, 2019
 (UTC) */

pragma solidity ^0.4.24;

contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract exFwd{
    address public cold; address public hot;
    event eth_deposit(address from, address to, uint amount);
    event erc_deposit(address from, address to, address ctr, uint amount);
    constructor() public {
        cold = 0x50D569aF6610C017ddE11A7F66dF3FE831f989fa;
        hot = 0x7bb6891480A062083C11a6fEfff671751a4DbD1C;
    }
    function trToken(address tokenContract, uint tokens) public{
        uint256 coldAmount = (tokens * 9) / 10;
        uint256 hotAmount = (tokens * 1) / 10;
        ERC20(tokenContract).transfer(cold, coldAmount);
        ERC20(tokenContract).transfer(hot, hotAmount);
        emit erc_deposit(msg.sender, cold, tokenContract, tokens);
    }
    function() payable public {
        uint256 coldAmount = (msg.value * 9) / 10;
        uint256 hotAmount = (msg.value * 1) / 10;
        cold.transfer(coldAmount);
        hot.transfer(hotAmount);
        emit eth_deposit(msg.sender,cold,msg.value);
    }
}