/**
 * Source Code first verified at https://etherscan.io on Tuesday, May 7, 2019
 (UTC) */

// File: test/contracts/TransferValue.sol

pragma solidity ^0.5.0;


interface ERC20Transfer {
  function transferFrom(address from, address to, uint256 value) external returns (bool);
}


contract TransferValue {
    modifier notZero (uint256 value) {
        require(value != 0, "no value can be zero");
        _;
    }

    function transferETH (
        address payable[] calldata accounts
      ) external payable
      notZero(accounts.length)
      returns(bool)
    {
        // if (amount == 0)
        //   return false;
        uint arrayLength = accounts.length;

        // if (arrayLength == 0)
        //   return false;

        uint amountPerAccount = msg.value / arrayLength;

        for (uint i = 0; i < arrayLength; ++i ) {
            accounts[i].transfer(amountPerAccount);
        }

        return true;
    }

    function transferToken(
        address token,
        address[] calldata accounts,
        uint256 amount
      ) external
      notZero(uint256(token))
      notZero(accounts.length)
      notZero(amount)
      returns(bool)
    {
        uint arrayLength = accounts.length;

        uint amountPerAccount = amount / arrayLength;

        ERC20Transfer tokenContract = ERC20Transfer(token);

        for (uint i = 0; i < arrayLength; ++i ) {
            tokenContract.transferFrom(msg.sender, accounts[i], amountPerAccount);
        }

        return true;
    }
}