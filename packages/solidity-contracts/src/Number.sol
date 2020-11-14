/**
 * Source Code first verified at https://etherscan.io on Sunday, May 5, 2019
 (UTC) */

pragma solidity 0.5.7;


contract Number {

  mapping(address => uint) public numberForAddress;

  function setNumber(uint number) external {
    numberForAddress[msg.sender] = number;
  }

}