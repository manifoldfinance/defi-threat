/**
 * Source Code first verified at https://etherscan.io on Thursday, April 25, 2019
 (UTC) */

pragma solidity^0.5.1;

contract OneTimesBondContract {
  // This is a single use bond contract that allows owner issue locked funds
  bool public has_initialized = false;
  address public creator = msg.sender;
  uint256 public expires_on;
  uint256 public cur_bond_val;
  address public bond_owner;

  modifier onlyOwner {
    require(msg.sender == bond_owner);
    _;
  }

  modifier onlyCreator {
    require(msg.sender == creator);
    _;
  }

  modifier unInitialized {
    require(has_initialized == false);
    _;
  }

  constructor(address _for) public{
      bond_owner = _for;
  }


  function initializeBond(uint256 _expires_on) payable public unInitialized onlyCreator {
    expires_on = _expires_on;
    cur_bond_val = msg.value;
    has_initialized = true;
  }

  function redeemBond() onlyCreator public {
    if (block.timestamp < expires_on) {
      msg.sender.transfer(cur_bond_val);
    }
  }

  function liquidateBond() onlyOwner payable public {
      if (block.timestamp >= expires_on) {
        msg.sender.transfer(cur_bond_val);
      }
  }

  function() external{
    revert();
  }

}