/**
 * Source Code first verified at https://etherscan.io on Saturday, April 13, 2019
 (UTC) */

pragma solidity ^0.4.25;


/**
*
* ETH CRYPTOCURRENCY DISTRIBUTION PROJECT
* Web              - https://doether.org

*
*  - GAIN 4% PER 24 HOURS (every 5900 blocks)
*  - Life-long payments
*  - The revolutionary reliability
*  - Minimal contribution 0.01 eth
*  - Currency and payment - ETH
*  - Contribution allocation schemes:
*    -- 85% payments
*    -- 15% Marketing + Operating Expenses
*
*   ---About the Project
*  Blockchain-enabled smart contracts have opened a new era of trustless relationships without
*  intermediaries. This technology opens incredible financial possibilities. Our automated investment
*  distribution model is written into a smart contract, uploaded to the Ethereum blockchain and can be
*  freely accessed online. In order to insure our investors' complete security, full control over the
*  project has been transferred from the organizers to the smart contract: nobody can influence the
*  system's permanent autonomous functioning.
*
* ---How to use:
*  1. Send from ETH wallet to the smart contract address 0x2612e95424E4039cCE9fd0c40e584b52813EFfe3
*     any amount from 0.01 ETH.
*  2. Verify your transaction in the history of your application or etherscan.io, specifying the address
*     of your wallet.
*  3a. Claim your profit by sending 0 ether transaction (every day, every week, i don't care unless you're
*      spending too much on GAS)
*  OR
*  3b. For reinvest, you need to first remove the accumulated percentage of charges (by sending 0 ether
*      transaction), and only after that, deposit the amount that you want to reinvest.
* 
* RECOMMENDED GAS LIMIT: 200000
* RECOMMENDED GAS PRICE: https://ethgasstation.info/
* You can check the payments on the etherscan.io site, in the "Internal Txns" tab of your wallet.
*
* ---It is not allowed to transfer from exchanges, only from your personal ETH wallet, for which you
* have private keys.
*
* Contracts reviewed and approved by pros!
*
* Main contract - DOETHER.
*/
library SafeMath {
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    if (_a == 0) {
      return 0;
    }
    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    return _a / _b;
  }

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

contract DOETHER {
    using SafeMath for uint256;

    address public constant marketingAddress = 0x7DbBD1640A99AD6e7b08660C0D89C55Ec93E0896;

    mapping (address => uint256) deposited;
    mapping (address => uint256) withdrew;
    mapping (address => uint256) refearned;
    mapping (address => uint256) blocklock;

    uint256 public totalDepositedWei = 0;
    uint256 public totalWithdrewWei = 0;

    function() payable external
    {
        uint256 marketingPerc = msg.value.mul(15).div(100);

        marketingAddress.transfer(marketingPerc);
        
        if (deposited[msg.sender] != 0)
        {
            address investor = msg.sender;
            uint256 depositsPercents = deposited[msg.sender].mul(4).div(100).mul(block.number-blocklock[msg.sender]).div(5900);
            investor.transfer(depositsPercents);

            withdrew[msg.sender] += depositsPercents;
            totalWithdrewWei = totalWithdrewWei.add(depositsPercents);
        }

        address referrer = bytesToAddress(msg.data);
        uint256 refPerc = msg.value.mul(4).div(100);
        
        if (referrer > 0x0 && referrer != msg.sender)
        {
            referrer.transfer(refPerc);

            refearned[referrer] += refPerc;
        }

        blocklock[msg.sender] = block.number;
        deposited[msg.sender] += msg.value;

        totalDepositedWei = totalDepositedWei.add(msg.value);
    }

    function userDepositedWei(address _address) public view returns (uint256)
    {
        return deposited[_address];
    }

    function userWithdrewWei(address _address) public view returns (uint256)
    {
        return withdrew[_address];
    }

    function userDividendsWei(address _address) public view returns (uint256)
    {
        return deposited[_address].mul(4).div(100).mul(block.number-blocklock[_address]).div(5900);
    }

    function userReferralsWei(address _address) public view returns (uint256)
    {
        return refearned[_address];
    }

    function bytesToAddress(bytes bys) private pure returns (address addr)
    {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}