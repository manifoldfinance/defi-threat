/**
 * Source Code first verified at https://etherscan.io on Thursday, March 21, 2019
 (UTC) */

pragma solidity ^0.5.1;

contract CommunityChest {
    
    address owner;
    
    event Deposit(uint256 value);
    event Transfer(address to, uint256 value);
    
    constructor () public {
        owner = msg.sender;
    }
    
    function send(address payable to, uint256 value) public onlyOwner {
        to.transfer(value);
        emit Transfer(to, value);
    }

    function () payable external {
        emit Deposit(msg.value);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}