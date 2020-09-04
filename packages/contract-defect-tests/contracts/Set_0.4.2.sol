pragma solidity ^0.4.2;

contract Set {
    uint8 public result;
    function setResult(uint8 res){result = res; } 
    function version(){  this.setResult(3);  }
}