pragma solidity 0.5.0;

import "./SafeMath.sol";
import "./ERC20Pausable.sol";
import "./ERC20Detailed.sol";

contract SlotheeToken is ERC20Pausable, ERC20Detailed {

  constructor() ERC20Detailed("SlotheeToken", "SLO", 18) public {

    // total tokens - 400 000 000 Tokens	  
    _totalSupply = 400000000000000000000000000;

    // Team - 40 000 000 Tokens
    _balances[0xEf73Cf964862231BEf1e57B2F95dA7bd1dafA4Ce] = 40000000000000000000000000;
    // Advisor and Partners - 40 000 000 Tokens
    _balances[0xacAade0E303fE98Bd73bD75daD312d9Bc7bfd695] = 40000000000000000000000000;
    // Bounty and Airdrop - 20 000 000 Tokens
    _balances[0x76439EE8Ec9c5908dbCAA7cdBB4Ef715C9d8b710] = 20000000000000000000000000;
    // Reward - 20 000 000 Tokens
    _balances[0xDD90b2f934D843684647f5e7cDc30b298D3287fF] = 20000000000000000000000000;
    // Holding address - 280 000 000 Tokens
    _balances[0x1B8A6c794ec32fe9DC47bD124ec9c6C83B98c0c9] = 280000000000000000000000000;
    
  }  
}
