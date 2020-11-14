/**
 * Source Code first verified at https://etherscan.io on Wednesday, May 1, 2019
 (UTC) */

pragma solidity 0.5.1;

/**
* @title Forceth
* @notice A tool to send ether to a contract irrespective of its default payable function
**/
contract Forceth {
  function sendTo(address payable destination) public payable {
    (new Depositor).value(msg.value)(destination);
  }
}

contract Depositor {
  constructor(address payable destination) public payable {
    selfdestruct(destination);
  }
}