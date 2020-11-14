/**
 * Source Code first verified at https://etherscan.io on Thursday, March 21, 2019
 (UTC) */

pragma solidity 0.4.25;

/*
 * 0xBtcnnRoll.
 */

contract BTCNNInterface {
  function getFrontEndTokenBalanceOf(address who) public view returns(uint);

  function transfer(address _to, uint _value) public returns(bool);

  function approve(address spender, uint tokens) public returns(bool);
}

contract BtcnnRoll {
  using SafeMath
  for uint;

  // Makes sure that player profit can't exceed a maximum amount,
  //  that the bet size is valid, and the playerNumber is in range.
  modifier betIsValid(uint _betSize, uint _playerNumber) {
    require(calculateProfit(_betSize, _playerNumber) < maxProfit &&
      _betSize >= minBet &&
      _playerNumber > minNumber &&
      _playerNumber < maxNumber);
    _;
  }

  // Requires game to be currently active
  modifier gameIsActive {
    require(gamePaused == false);
    _;
  }

  // Requires msg.sender to be owner
  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  // Constants
  uint constant private MAX_INT = 2 ** 256 - 1;
  uint constant public maxProfitDivisor = 1000000;
  uint constant public maxNumber = 99;
  uint constant public minNumber = 2;
  uint constant public houseEdgeDivisor = 1000;

  // Configurables
  bool public gamePaused;

  address public owner;
  address public BTCNNBankroll;
  address public BTCNNTKNADDR;

  BTCNNInterface public BTCNNTKN;

  uint public contractBalance;
  uint public houseEdge;
  uint public maxProfit;
  uint public maxProfitAsPercentOfHouse;
  uint public minBet = 0;

  // Trackers
  uint public totalBets;
  uint public totalBTCNNWagered;

  // Events

  // Logs bets + output to web3 for precise 'payout on win' field in UI
  event LogBet(address sender, uint value, uint rollUnder);

  // Outputs to web3 UI on bet result
  // Status: 0=lose, 1=win, 2=win + failed send, 3=refund, 4=refund + failed send
  event LogResult(address indexed player, uint result, uint rollUnder, uint profit, uint tokensBetted, bool won);

  // Logs owner transfers
  event LogOwnerTransfer(address indexed SentToAddress, uint indexed AmountTransferred);

  // Logs changes in maximum profit
  event MaxProfitChanged(uint _oldMaxProfit, uint _newMaxProfit);

  // Logs current contract balance
  event CurrentContractBalance(uint _tokens);

  constructor(address btcnntknaddr, address btcnnbankrolladdr) public {
    // Owner is deployer
    owner = msg.sender;

    // Initialize the BTCNN contract and bankroll interfaces
    BTCNNTKN = BTCNNInterface(btcnntknaddr);
    BTCNNTKNADDR = btcnntknaddr;

    // Set the bankroll
    BTCNNBankroll = btcnnbankrolladdr;

    // Init 990 = 99% (1% houseEdge)
    houseEdge = 990;

    // The maximum profit from each bet is 10% of the contract balance.
    ownerSetMaxProfitAsPercentOfHouse(10000);

    // Init min bet (1 BTCNN)
    ownerSetMinBet(1e18);

    // Allow 'unlimited' token transfer by the bankroll
    BTCNNTKN.approve(btcnnbankrolladdr, MAX_INT);
  }

  function () public {
    revert();
  }

  // Returns a random number using a specified block number
  // Always use a FUTURE block number.
  function maxRandom(uint blockn, address entropy) public view returns(uint256 randomNumber) {
    return uint256(keccak256(
      abi.encodePacked(
        blockhash(blockn),
        entropy)
    ));
  }

  // Random helper
  function random(uint256 upper, uint256 blockn, address entropy) internal view returns(uint256 randomNumber) {
    return maxRandom(blockn, entropy) % upper;
  }

  // Calculate the maximum potential profit
  function calculateProfit(uint _initBet, uint _roll)
  private
  view
  returns(uint) {
    return ((((_initBet * (100 - (_roll.sub(1)))) / (_roll.sub(1)) + _initBet)) * houseEdge / houseEdgeDivisor) - _initBet;
  }

  // I present a struct which takes only 20k gas
  struct playerRoll {
    uint200 tokenValue; // Token value in uint
    uint48 blockn; // Block number 48 bits
    uint8 rollUnder; // Roll under 8 bits
  }

  // Mapping because a player can do one roll at a time
  mapping(address => playerRoll) public playerRolls;

  function _playerRollDice(uint _rollUnder, TKN _tkn) private
  gameIsActive
  betIsValid(_tkn.value, _rollUnder) {
    require(_tkn.value < ((2 ** 200) - 1)); // Smaller than the storage of 1 uint200;
    require(block.number < ((2 ** 48) - 1)); // Current block number smaller than storage of 1 uint48

    // Note that msg.sender is the Token Contract Address
    // and "_from" is the sender of the tokens

    // Check that this is a BTCNN token transfer
    require(_btcnnToken(msg.sender));

    playerRoll memory roll = playerRolls[_tkn.sender];

    // Cannot bet twice in one block
    require(block.number != roll.blockn);

    // If there exists a roll, finish it
    if (roll.blockn != 0) {
      _finishBet(false, _tkn.sender);
    }

    // Set struct block number, token value, and rollUnder values
    roll.blockn = uint48(block.number);
    roll.tokenValue = uint200(_tkn.value);
    roll.rollUnder = uint8(_rollUnder);

    // Store the roll struct - 20k gas.
    playerRolls[_tkn.sender] = roll;

    // Provides accurate numbers for web3 and allows for manual refunds
    emit LogBet(_tkn.sender, _tkn.value, _rollUnder);

    // Increment total number of bets
    totalBets += 1;

    // Total wagered
    totalBTCNNWagered += _tkn.value;
  }

  // Finished the current bet of a player, if they have one
  function finishBet() public
  gameIsActive
  returns(uint) {
    return _finishBet(true, msg.sender);
  }

  /*
   * Pay winner, update contract balance
   * to calculate new max bet, and send reward.
   */
  function _finishBet(bool delete_it, address target) private returns(uint) {
    playerRoll memory roll = playerRolls[target];
    require(roll.tokenValue > 0); // No re-entracy
    require(roll.blockn != block.number);
    // If the block is more than 255 blocks old, we can't get the result
    // Also, if the result has already happened, fail as well
    uint result;
    if (block.number - roll.blockn > 255) {
      result = 1000; // Cant win
    } else {
      // Grab the result - random based ONLY on a past block (future when submitted)
      result = random(99, roll.blockn, target) + 1;
    }

    uint rollUnder = roll.rollUnder;

    if (result < rollUnder) {
      // Player has won!

      // Safely map player profit
      uint profit = calculateProfit(roll.tokenValue, rollUnder);

      if (profit > maxProfit) {
        profit = maxProfit;
      }

      // Safely reduce contract balance by player profit
      contractBalance = contractBalance.sub(profit);

      emit LogResult(target, result, rollUnder, profit, roll.tokenValue, true);

      // Update maximum profit
      setMaxProfit();


      // Prevent re-entracy memes
      playerRolls[target] = playerRoll(uint200(0), uint48(0), uint8(0));


      // Transfer profit plus original bet
      BTCNNTKN.transfer(target, profit + roll.tokenValue);

      return result;

    } else {
      /*
       * Player has lost
       * Update contract balance to calculate new max bet
       */
      emit LogResult(target, result, rollUnder, profit, roll.tokenValue, false);

      /*
       *  Safely adjust contractBalance
       *  SetMaxProfit
       */
      contractBalance = contractBalance.add(roll.tokenValue);

      playerRolls[target] = playerRoll(uint200(0), uint48(0), uint8(0));
      // No need to actually delete player roll here since player ALWAYS loses
      // Saves gas on next buy

      // Update maximum profit
      setMaxProfit();

      return result;
    }
  }

  // TKN struct
  struct TKN {
    address sender;
    uint value;
  }

  // Token fallback to bet or deposit from bankroll
  function tokenFallback(address _from, uint _value, bytes _data) public returns(bool) {
    require(msg.sender == BTCNNTKNADDR);
    if (_from == BTCNNBankroll) {
      // Update the contract balance
      contractBalance = contractBalance.add(_value);

      // Update the maximum profit
      uint oldMaxProfit = maxProfit;
      setMaxProfit();

      emit MaxProfitChanged(oldMaxProfit, maxProfit);
      return true;

    } else {
      TKN memory _tkn;
      _tkn.sender = _from;
      _tkn.value = _value;
      uint8 chosenNumber = uint8(_data[0]);
      _playerRollDice(chosenNumber, _tkn);
    }

    return true;
  }

  /*
   * Sets max profit
   */
  function setMaxProfit() internal {
    emit CurrentContractBalance(contractBalance);
    maxProfit = (contractBalance * maxProfitAsPercentOfHouse) / maxProfitDivisor;
  }

  // Only owner adjust contract balance variable (only used for max profit calc)
  function ownerUpdateContractBalance(uint newContractBalance) public
  onlyOwner {
    contractBalance = newContractBalance;
  }

  // Only owner address can set maxProfitAsPercentOfHouse
  function ownerSetMaxProfitAsPercentOfHouse(uint newMaxProfitAsPercent) public
  onlyOwner {
    // Restricts each bet to a maximum profit of 20% contractBalance
    require(newMaxProfitAsPercent <= 200000);
    maxProfitAsPercentOfHouse = newMaxProfitAsPercent;
    setMaxProfit();
  }

  // Only owner address can set minBet
  function ownerSetMinBet(uint newMinimumBet) public
  onlyOwner {
    minBet = newMinimumBet;
  }

  // Only owner address can transfer BTCNN
  function ownerTransferBTCNN(address sendTo, uint amount) public
  onlyOwner {
    // Safely update contract balance when sending out funds
    contractBalance = contractBalance.sub(amount);

    // update max profit
    setMaxProfit();
    require(BTCNNTKN.transfer(sendTo, amount));
    emit LogOwnerTransfer(sendTo, amount);
  }

  // Only owner address can set emergency pause #1
  function ownerPauseGame(bool newStatus) public
  onlyOwner {
    gamePaused = newStatus;
  }

  // Only owner address can set bankroll address
  function ownerSetBankroll(address newBankroll) public
  onlyOwner {
    BTCNNTKN.approve(BTCNNBankroll, 0);
    BTCNNBankroll = newBankroll;
    BTCNNTKN.approve(newBankroll, MAX_INT);
  }

  // Only owner address can set owner address
  function ownerChangeOwner(address newOwner) public
  onlyOwner {
    owner = newOwner;
  }

  // Only owner address can selfdestruct - emergency
  function ownerkill() public
  onlyOwner {
    BTCNNTKN.transfer(owner, contractBalance);
    selfdestruct(owner);
  }

  function dumpdivs() public {

    BTCNNTKN.transfer(BTCNNBankroll, BTCNNTKN.getFrontEndTokenBalanceOf(this));
  }

  function _btcnnToken(address _tokenContract) private view returns(bool) {
    return _tokenContract == BTCNNTKNADDR;
    // Is this the BTCNN token contract?
  }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
   * @dev Multiplies two numbers, throws on overflow.
   */
  function mul(uint a, uint b) internal pure returns(uint) {
    if (a == 0) {
      return 0;
    }
    uint c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
   * @dev Integer division of two numbers, truncating the quotient.
   */
  function div(uint a, uint b) internal pure returns(uint) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
   * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
   */
  function sub(uint a, uint b) internal pure returns(uint) {
    assert(b <= a);
    return a - b;
  }

  /**
   * @dev Adds two numbers, throws on overflow.
   */
  function add(uint a, uint b) internal pure returns(uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }
}