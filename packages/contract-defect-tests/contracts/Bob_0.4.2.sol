pragma solidity ^0.4.2;

// Set interface
library Set {
  
    struct Data { mapping(uint => bool) flags; }

    function insert(Data storage self, uint value) returns (bool);
    function remove(Data storage self, uint value) returns (bool);
    function contains(Data storage self, uint value) returns (bool);
    function version() returns (uint);
}

// SetProvider interface
contract SetProvider { 
    function getSet() returns (Set);
}

contract Bob { 
    address public providerAddr;
    uint8 public result;
    
    function setResult(uint8 res){ result = res; } 
    function setProvider(address arg) { providerAddr = arg; }
    
    function getVersion() returns (uint) {
        address setAddr = SetProvider(providerAddr).getSet();
        bool res = setAddr.delegatecall.gas(55555)(
                   bytes4(sha3("version()")));

        return result; 
    }
}