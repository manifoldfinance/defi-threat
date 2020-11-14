/**
 * Source Code first verified at https://etherscan.io on Thursday, April 25, 2019
 (UTC) */

pragma solidity 0.4.25;

contract Game20A {
    using SafeMath for uint;
    uint public betFirstMin = 5 ether / 100;
    uint public betFirstMax = 1 ether / 10;
    uint public bet = betFirstMin;
    uint public currentMinBet = betFirstMin;
    uint public percentRaise = 20;
    address private admin = 0xAF53747Ce9cd5132c52Ab9e9D11259875935C55A;
    address public player = admin;
    uint public compensation;
    bool public first = true;
    uint public time = 0;
    uint public waitTime = 24 hours;

    event Withdrawal(address player, uint time, uint value, uint bet);
    event Bet(address player, uint time, uint bet);
    event newCircle(address player, uint time, uint compensation);

    function firstBet() private {
        require(msg.value >= betFirstMin && msg.value <= betFirstMax, 'Wrong ETH value');

        compensation = compensation.add(msg.value);

        player = msg.sender;
        time = now;
        bet = msg.value;
        currentMinBet = bet.mul(percentRaise).div(100).add(bet);

        first = false;

        emit Bet(player, time, bet);
    }

    function usualBet() private {
        require(msg.value >= currentMinBet, 'Wrong ETH value');

        uint profit = msg.value.sub(bet);

        player.transfer(profit.mul(10).div(20).add(bet));
        emit Withdrawal(player, now, profit.mul(10).div(20).add(bet), bet);
        admin.transfer(profit.mul(1).div(20));
        compensation = compensation.add(profit.mul(9).div(20));

        player = msg.sender;
        time = now;
        bet = msg.value;
        currentMinBet = bet.mul(percentRaise).div(100).add(bet);

        emit Bet(player, time, bet);
    }

    function lastBet() private {
        emit newCircle(player, time, bet);

        if (msg.value >= betFirstMin && msg.value <= betFirstMax) {
            player.transfer(address(this).balance.sub(msg.value));
            emit Withdrawal(player, now, address(this).balance.sub(msg.value), bet);

            compensation = 0;

            firstBet();
        } else {
            msg.sender.transfer(msg.value);
            player.transfer(address(this).balance);
            emit Withdrawal(player, now, address(this).balance, bet);

            compensation = 0;
            player = admin;
            bet = betFirstMin;
            currentMinBet = bet;
            time = 0;
            first = true;
        }

    }

    function() external payable {
        if (first == true) {
            firstBet();
        } else {
            now >= time + waitTime ? lastBet() : usualBet();
        }
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
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