/**
 * Source Code first verified at https://etherscan.io on Friday, April 19, 2019
 (UTC) */

pragma solidity 0.5.7;

contract Simple
{
    address public owner;

    constructor (address ownerAddress) public
    {
        owner = ownerAddress;
    }
}