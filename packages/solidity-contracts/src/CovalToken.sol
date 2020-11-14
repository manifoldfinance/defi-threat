pragma solidity 0.4.24;

//import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";

import "./ERC20Mintable.sol";

contract CovalToken is ERC20Mintable {
    string public name = "Circuits of Value ETH";
    string public symbol = "CovalERC20";
    uint8 public decimals = 18;
}