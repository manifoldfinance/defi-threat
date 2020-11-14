/**
 * Source Code first verified at https://etherscan.io on Monday, March 25, 2019
 (UTC) */

pragma solidity ^0.5.0;

contract A {
    B public myB = new B();
}

contract B {
    function getBlock() public view returns (uint256) {
        return block.timestamp;
    }
}