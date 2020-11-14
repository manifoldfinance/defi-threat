/**
 * Source Code first verified at https://etherscan.io on Monday, April 8, 2019
 (UTC) */

pragma solidity >=0.4.0;

contract ProofOfExistence {

    uint topHash;
    address owner;

    constructor() public {
       owner = msg.sender;
    }

    function publishTopHash(uint _topHash) public {
        if (owner == msg.sender) {
            topHash = _topHash;
        }
    }

    function get() public view returns (uint) {
        return topHash;
    }
}