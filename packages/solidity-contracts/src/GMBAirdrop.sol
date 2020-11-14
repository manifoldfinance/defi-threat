/**
 * Source Code first verified at https://etherscan.io on Friday, April 26, 2019
 (UTC) */

pragma solidity ^0.4.11;

// This is a contract for GMB AirDrops

contract Ownable {
  address public owner;

  constructor () internal {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    if (msg.sender != owner) {
      revert();
    }
    _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }
}

contract ERC20Basic {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function transfer(address to, uint value);
  event Transfer(address indexed from, address indexed to, uint value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint);
  function transferFrom(address from, address to, uint value);
  function approve(address spender, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

contract GMBAirdrop is Ownable {

    function multisend(address[] to, uint256[] value) onlyOwner returns (uint256) {

        address tokenAddr = 0x30093D157DcA641A2906E08F734a930991b77330;
        uint256 i = 0;
        while (i < to.length) {
           ERC20(tokenAddr).transfer(to[i], value[i] * ( 10 ** 18 ));
           i++;
        }
        return(i);
    }
}