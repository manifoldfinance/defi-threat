pragma solidity ^0.4.18;

import "./ERC223.sol";

contract GoodGamePlatform is ERC223Token, Owned {
  string public name = "GoodGamePlatform";
  string public symbol = "GGP";
  uint public decimals = 18;
  uint public totalSupply = 1000000000 * 10**uint(decimals);

  function GoodGamePlatform() {
    balances[owner] = totalSupply;
    emit Transfer(address(0), owner, totalSupply);
  }
}