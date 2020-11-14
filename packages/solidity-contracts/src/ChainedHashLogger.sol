/**
 * Source Code first verified at https://etherscan.io on Monday, April 1, 2019
 (UTC) */

pragma solidity ^0.4.13;

contract ChainedHashLogger{

    address public owner;
    bytes32 public name;      

    mapping(address=>bool) public delegatinglist;

    modifier onlyAuthorized(){
        require(isdelegatinglisted(msg.sender));
        _;
    }

    event blockHash(bytes32 _indexName, bytes32 _proofOfPerfBlockHash, bytes32 _previousTransactionHash);
    event Authorized(address authorized, uint timestamp);
    event Revoked(address authorized, uint timestamp);
 
    constructor(bytes32 _name) public{
        owner = msg.sender;
        delegatinglist[owner] = true;
        name = _name;
    }

    function authorize(address authorized) public onlyAuthorized {
        delegatinglist[authorized] = true;
        emit Authorized(authorized, now);
    }

    // also if not in the list..
    function revoke(address authorized) public onlyAuthorized {
        delegatinglist[authorized] = false;
        emit Revoked(authorized, now);
    }

    function authorizeMany(address[50] authorized) public onlyAuthorized {
        for(uint i = 0; i < authorized.length; i++) {
            authorize(authorized[i]);
        }
    }

    function isdelegatinglisted(address authorized) public view returns(bool) {
      return delegatinglist[authorized];
    }

    function hashDataBlock(string jsonBlock) public pure returns(bytes32) {
      return(sha256(abi.encodePacked(jsonBlock)));
    }

    function obfuscatedHashDataBlock(bytes32 jsonBlockHash,bytes16 secret) public pure returns(bytes32) {
      return(sha256(abi.encodePacked(jsonBlockHash,secret)));
    }

    function addChainedHash(bytes32 _indexName, bytes32 _proofOfPerfBlockHash, bytes32 _previousTransactionHash) public onlyAuthorized {
        emit blockHash(_indexName, _proofOfPerfBlockHash, _previousTransactionHash);
    }

}