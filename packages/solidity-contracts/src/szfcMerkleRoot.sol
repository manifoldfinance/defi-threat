/**
 * Source Code first verified at https://etherscan.io on Wednesday, March 20, 2019
 (UTC) */

pragma solidity ^0.5.2;

contract szfcMerkleRoot {

    uint64 oneHour= 3600000;

    address owner;

    mapping(bytes32 => uint64) hash2timestamp;

    mapping(uint64=> bytes32[]) public timestamp2hashes;  //date -> merkle root hash

    constructor() public {

        owner = msg.sender;

    }

    function push(uint64 _timestamp, bytes32 _root) external{

        require(msg.sender == owner);

        require(checkTime(_timestamp));
        require(hash2timestamp[_root] == 0);

        //归结
        uint64 hour_point = _timestamp - _timestamp % oneHour;

        hash2timestamp[_root] = _timestamp;

        bytes32[] storage hashes = timestamp2hashes[hour_point];

        hashes.push(_root);


    }




    function getAllHashes(uint64 _timestamp) external view returns(bytes32[] memory){

        uint64 hour_point = _timestamp - _timestamp % oneHour;

        bytes32[] storage hashes = timestamp2hashes[hour_point];

        return hashes;

    }


    function getLastHash(uint64 _timestamp) public view returns(bytes32){

        uint64 hour_point = _timestamp - _timestamp % oneHour;

        bytes32[] storage hashes = timestamp2hashes[hour_point];

        if( hashes.length > 0 ) {
            return hashes[hashes.length-1];
        }

        return 0x00;

    }


    function getTimestamp(bytes32 _root) external view returns(uint64){

        return hash2timestamp[_root];

    }


    function getOwner() external view returns(address){

        return owner;

    }


    function checkTime(uint64 _timestamp) private view returns (bool) {

        return ( _timestamp < now * 1000 );
    }



}