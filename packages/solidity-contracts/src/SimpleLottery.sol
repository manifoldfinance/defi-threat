/**
 * Source Code first verified at https://etherscan.io on Sunday, May 5, 2019
 (UTC) */

// File: contracts/ownership/Ownable.sol

pragma solidity ^0.4.24;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: contracts/math/SafeMath.sol

pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts/token/ERC20Cutted.sol

pragma solidity ^0.4.24;

contract ERC20Cutted {

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

}

// File: contracts/SimpleLottery.sol

pragma solidity ^0.4.24;





contract SimpleLottery is Ownable {

    event TicketPurchased(uint lotIndex, uint ticketNumber, address player, uint ticketPrice);

    event TicketWon(uint lotIndex, uint ticketNumber, address player, uint win);

    using SafeMath for uint;

    uint public percentRate = 100;

    uint public ticketPrice = 500000000000000000;

    uint public feePercent = 10;

    uint public playersLimit = 10;

    uint public ticketsPerPlayerLimit = 2;

    address public feeWallet = 0xEA15Adb66DC92a4BbCcC8Bf32fd25E2e86a2A770;

    uint curLotIndex = 0;

    struct Lottery {
        uint summaryInvested;
        uint rewardBase;
        uint ticketsCount;
        uint playersCount;
        address winner;
        mapping(address => uint) ticketsCounts;
        mapping(uint => address) tickets;
        mapping(address => uint) invested;
        address[] players;
    }

    Lottery[] public lots;

    modifier notContract(address to) {
        uint codeLength;
        assembly {
            codeLength := extcodesize(to)
        }
        require(codeLength == 0, "Contracts not supported!");
        _;
    }

    function setTicketsPerPlayerLimit(uint newTicketsPerPlayerLimit) public onlyOwner {
        ticketsPerPlayerLimit = newTicketsPerPlayerLimit;
    }

    function setFeeWallet(address newFeeWallet) public onlyOwner {
        feeWallet = newFeeWallet;
    }

    function setTicketPrice(uint newTicketPrice) public onlyOwner {
        ticketPrice = newTicketPrice;
    }

    function setFeePercent(uint newFeePercent) public onlyOwner {
        feePercent = newFeePercent;
    }

    function setPlayesrLimit(uint newPlayersLimit) public onlyOwner {
        playersLimit = newPlayersLimit;
    }

    function() public payable notContract(msg.sender) {
        require(msg.value >= ticketPrice, "Not enough funds to buy ticket!");

        if (lots.length == 0) {
            lots.length = 1;
        }

        Lottery storage lot = lots[curLotIndex];

        uint numTicketsToBuy = msg.value.div(ticketPrice);

        if (numTicketsToBuy > ticketsPerPlayerLimit) {
            numTicketsToBuy = ticketsPerPlayerLimit;
        }

        uint toInvest = ticketPrice.mul(numTicketsToBuy);

        if (lot.invested[msg.sender] == 0) {
            lot.players.push(msg.sender);
            lot.playersCount = lot.playersCount.add(1);
        }

        lot.invested[msg.sender] = lot.invested[msg.sender].add(toInvest);

        for (uint i = 0; i < numTicketsToBuy; i++) {
            lot.tickets[lot.ticketsCount] = msg.sender;
            emit TicketPurchased(curLotIndex, lot.ticketsCount, msg.sender, ticketPrice);
            lot.ticketsCount = lot.ticketsCount.add(1);
            lot.ticketsCounts[msg.sender]++;
        }

        lot.summaryInvested = lot.summaryInvested.add(toInvest);

        uint refund = msg.value.sub(toInvest);
        msg.sender.transfer(refund);

        if (lot.playersCount >= playersLimit) {
            uint number = uint(keccak256(abi.encodePacked(block.number))) % lot.ticketsCount;
            address winner = lot.tickets[number];
            lot.winner = winner;
            uint fee = lot.summaryInvested.mul(feePercent).div(percentRate);
            feeWallet.transfer(fee);
            winner.transfer(lot.rewardBase);
            lot.rewardBase = lot.summaryInvested.sub(fee);
            emit TicketWon(curLotIndex, number, lot.winner, lot.rewardBase);
            curLotIndex++;
        }
    }

    function retrieveTokens(address tokenAddr, address to) public onlyOwner {
        ERC20Cutted token = ERC20Cutted(tokenAddr);
        token.transfer(to, token.balanceOf(address(this)));
    }

}