/**
 * Source Code first verified at https://etherscan.io on Saturday, April 13, 2019
 (UTC) */

// File: contracts/TestContract.sol

pragma solidity >=0.4.21 <0.6.0;

contract TestContract {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }
}