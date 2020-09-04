pragma solidity ^0.4.2;

contract SetProvider {
    
    address public setLibAddr;
    address public owner;
    
    function SetProvider() {
        owner = msg.sender;
    }
    
    function updateLibrary(address arg) {
        if (msg.sender==owner)
            setLibAddr = arg;
    }
    
    function getSet() returns (address) {
        return setLibAddr;
    }
}