/**
 * Source Code first verified at https://etherscan.io on Tuesday, May 7, 2019
 (UTC) */

/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/
pragma solidity 0.5.7;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title Math
 * @dev Assorted math operations
 */

library Math {
  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}

// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/issues/20

contract Token {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) view public returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) view public returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}



/// @title Long-Team Holding Incentive Program
/// @author Daniel Wang - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="096d6867606c6549656666797b60676e27667b6e">[email protected]</a>>, Kongliang Zhong - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="076c6869606b6e666960476b686877756e696029687560">[email protected]</a>>.
/// For more information, please visit https://loopring.org.
contract NewLRCLongTermHoldingContract {
    using SafeMath for uint;
    using Math for uint;

    // During the first 60 days of deployment, this contract opens for deposit of LRC.
    uint public constant DEPOSIT_PERIOD             = 60 days; // = 2 months

    // 18 months after deposit, user can withdrawal all or part of his/her LRC with bonus.
    // The bonus is this contract's initial LRC balance.
    uint public constant WITHDRAWAL_DELAY           = 540 days; // = 1 year and 6 months

    // Send 0.001ETH per 10000 LRC partial withdrawal, or 0 for a once-for-all withdrawal.
    // All ETH will be returned.
    uint public constant WITHDRAWAL_SCALE           = 1E7; // 1ETH for withdrawal of 10,000,000 LRC.

    // Ower can drain all remaining LRC after 3 years.
    uint public constant DRAIN_DELAY                = 1080 days; // = 3 years.

    address public lrcTokenAddress;
    address public owner;

    uint public lrcDeposited        = 0;
    uint public depositStartTime    = 1504076273;
    uint public depositStopTime     = 1509260273;

    struct Record {
        uint lrcAmount;
        uint timestamp;
    }

    mapping (address => Record) public records;

    /*
     * EVENTS
     */

    /// Emitted when program starts.
    event Started(uint _time);

    /// Emitted when all LRC are drained.
    event Drained(uint _lrcAmount);

    /// Emitted for each sucuessful deposit.
    uint public depositId = 0;
    event Deposit(uint _depositId, address indexed _addr, uint _lrcAmount);

    /// Emitted for each sucuessful deposit.
    uint public withdrawId = 0;
    event Withdrawal(uint _withdrawId, address indexed _addr, uint _lrcAmount);

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    /// @dev Initialize the contract
    /// @param _lrcTokenAddress LRC ERC20 token address
    constructor(address _lrcTokenAddress, address _owner) public {
        require(_lrcTokenAddress != address(0));
        require(_owner != address(0));

        lrcTokenAddress = _lrcTokenAddress;
        owner = _owner;
    }

    /*
     * PUBLIC FUNCTIONS
     */

    /* /// @dev start the program. */
    /* function start() public onlyOwner { */
    /*     require(depositStartTime == 0); */

    /*     depositStartTime = now; */
    /*     depositStopTime  = depositStartTime + DEPOSIT_PERIOD; */

    /*     Started(depositStartTime); */
    /* } */


    /// @dev drain LRC.
    function drain() onlyOwner public {
        require(depositStartTime > 0 && now >= depositStartTime + DRAIN_DELAY);

        uint balance = lrcBalance();
        require(balance > 0);

        require(Token(lrcTokenAddress).transfer(owner, balance));

        emit Drained(balance);
    }

    function () payable external {
        require(depositStartTime > 0);

        if (now >= depositStartTime && now <= depositStopTime) {
            depositLRC();
        } else if (now > depositStopTime){
            withdrawLRC();
        } else {
            revert();
        }
    }

    /// @return Current LRC balance.
    function lrcBalance() public view returns (uint) {
        return Token(lrcTokenAddress).balanceOf(address(this));
    }

    function batchAddDepositRecordsByOwner(address[] calldata users, uint[] calldata lrcAmounts, uint[] calldata timestamps) external onlyOwner {
        require(users.length == lrcAmounts.length);
        require(users.length == timestamps.length);
        for (uint i = 0; i < users.length; i++) {
            require(users[i] != address(0));
            require(timestamps[i] >= depositStartTime && timestamps[i] <= depositStopTime);
            Record memory record = Record(lrcAmounts[i], timestamps[i]);
            records[users[i]] = record;

            lrcDeposited += lrcAmounts[i];

            emit Deposit(depositId++, users[i], lrcAmounts[i]);
        }
    }

    /// @dev Deposit LRC.
    function depositLRC() payable public {
        require(depositStartTime > 0, "program not started");
        require(msg.value == 0, "no ether should be sent");
        require(now >= depositStartTime && now <= depositStopTime, "beyond deposit time period");

        Token lrcToken = Token(lrcTokenAddress);
        uint lrcAmount = lrcToken
            .balanceOf(msg.sender)
            .min256(lrcToken.allowance(msg.sender, address(this)));

        require(lrcAmount > 0, "lrc allowance is zero");

        Record memory record = records[msg.sender];
        record.lrcAmount += lrcAmount;
        record.timestamp = now;
        records[msg.sender] = record;

        lrcDeposited += lrcAmount;

        emit Deposit(depositId++, msg.sender, lrcAmount);

        require(lrcToken.transferFrom(msg.sender, address(this), lrcAmount), "lrc transfer failed");
    }

    /// @dev Withdrawal LRC.
    function withdrawLRC() payable public {
        require(depositStartTime > 0);
        require(lrcDeposited > 0);

        Record memory record = records[msg.sender];
        require(now >= record.timestamp + WITHDRAWAL_DELAY);
        require(record.lrcAmount > 0);

        uint lrcWithdrawalBase = record.lrcAmount;
        if (msg.value > 0) {
            lrcWithdrawalBase = lrcWithdrawalBase
                .min256(msg.value.mul(WITHDRAWAL_SCALE));
        }

        uint lrcBonus = getBonus(lrcWithdrawalBase);
        uint balance = lrcBalance();
        uint lrcAmount = balance.min256(lrcWithdrawalBase + lrcBonus);

        lrcDeposited -= lrcWithdrawalBase;
        record.lrcAmount -= lrcWithdrawalBase;

        if (record.lrcAmount == 0) {
            delete records[msg.sender];
        } else {
            records[msg.sender] = record;
        }

        emit Withdrawal(withdrawId++, msg.sender, lrcAmount);

        require(Token(lrcTokenAddress).transfer(msg.sender, lrcAmount));
        if (msg.value > 0) {
            msg.sender.transfer(msg.value);
        }
    }

    function getBonus(uint _lrcWithdrawalBase) view public returns (uint) {
        return internalCalculateBonus(lrcBalance() - lrcDeposited,lrcDeposited, _lrcWithdrawalBase);
    }

    function internalCalculateBonus(uint _totalBonusRemaining, uint _lrcDeposited, uint _lrcWithdrawalBase) internal pure returns (uint) {
        require(_lrcDeposited > 0);
        require(_totalBonusRemaining >= 0);

        // The bonus is non-linear function to incentivize later withdrawal.
        // bonus = _totalBonusRemaining * power(_lrcWithdrawalBase/_lrcDeposited, 1.0625)
        return _totalBonusRemaining
            .mul(_lrcWithdrawalBase.mul(sqrt(sqrt(sqrt(sqrt(_lrcWithdrawalBase))))))
            .div(_lrcDeposited.mul(sqrt(sqrt(sqrt(sqrt(_lrcDeposited))))));
    }

    function sqrt(uint x) internal pure returns (uint) {
        uint y = x;
        while (true) {
            uint z = (y + (x / y)) / 2;
            uint w = (z + (x / z)) / 2;
            if (w == y) {
                if (w < y) return w;
                else return y;
            }
            y = w;
        }
    }
}