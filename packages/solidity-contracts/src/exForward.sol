/**
 * Source Code first verified at https://etherscan.io on Monday, April 29, 2019
 (UTC) */

pragma solidity ^0.4.20;

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

contract exForward{
    address public owner;
    event change_owner(string newOwner, address indexed toOwner);
    event eth_deposit(address sender, uint amount);
    event erc_deposit(address from, address ctr, address to, uint amount);
    constructor() public {
        owner = msg.sender;
    }
    modifier isOwner{
        require(owner == msg.sender);
        _;
    }
    function trToken(address tokenContract, uint tokens) public{
        ERC20(tokenContract).transferFrom(msg.sender, owner, tokens);
        emit erc_deposit(msg.sender, tokenContract, owner, tokens);
    }
    function changeOwner(address to_owner) public isOwner returns (bool success){
        owner = to_owner;
        emit change_owner("OwnerChanged",to_owner);
        return true;
    }
    function() payable public {
        owner.transfer(msg.value);
        emit eth_deposit(msg.sender,msg.value);
    }
}