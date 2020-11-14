/**
 * Source Code first verified at https://etherscan.io on Thursday, March 21, 2019
 (UTC) */

pragma solidity 0.5.6;

contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "");
        owner = newOwner;
    }

}


// Developer @gogol
// Design @chechenets
// Architect @tugush

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, ""); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "");

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "");
        return a % b;
    }
}


// Developer @gogol
// Design @chechenets
// Architect @tugush

contract iBaseGame {
    function getPeriod() public view returns (uint);
    function startGame(uint _startPeriod) public payable;
    function setTicketPrice(uint _ticketPrice) public;
}


contract Management is Ownable {
    using SafeMath for uint;

    uint constant public BET_PRICE = 10000000000000000;                     //0.01 eth in wei
    uint constant public HOURLY_GAME_SHARE = 30;                         //30% to hourly game
    uint constant public DAILY_GAME_SHARE = 10;                          //10% to daily game
    uint constant public WEEKLY_GAME_SHARE = 5;                          //5% to weekly game
    uint constant public MONTHLY_GAME_SHARE = 5;                         //5% to monthly game
    uint constant public YEARLY_GAME_SHARE = 5;                          //5% to yearly game
    uint constant public JACKPOT_GAME_SHARE = 10;                        //10% to jackpot game
    uint constant public SUPER_JACKPOT_GAME_SHARE = 15;                  //15% to superJackpot game
    uint constant public SHARE_DENOMINATOR = 100;                           //denominator for share
    uint constant public ORACLIZE_TIMEOUT = 86400;
    uint constant public N_Y = 1514764800;                                  // 01.01.2018 00:00:00 Monday


    iBaseGame public hourlyGame;
    iBaseGame public dailyGame;
    iBaseGame public weeklyGame;
    iBaseGame public monthlyGame;
    iBaseGame public yearlyGame;
    iBaseGame public jackPot;
    iBaseGame public superJackPot;

//    //uint public start = 1546300800; // 01.01.2019 00:00:00
//    uint public start = now;

    constructor (
        address _hourlyGame,
        address _dailyGame,
        address _weeklyGame,
        address _monthlyGame,
        address _yearlyGame,
        address _jackPot,
        address _superJackPot
    )
        public
    {
        require(_hourlyGame != address(0), "");
        require(_dailyGame != address(0), "");
        require(_weeklyGame != address(0), "");
        require(_monthlyGame != address(0), "");
        require(_yearlyGame != address(0), "");
        require(_jackPot != address(0), "");
        require(_superJackPot != address(0), "");

        hourlyGame = iBaseGame(_hourlyGame);
        dailyGame = iBaseGame(_dailyGame);
        weeklyGame = iBaseGame(_weeklyGame);
        monthlyGame = iBaseGame(_monthlyGame);
        yearlyGame = iBaseGame(_yearlyGame);
        jackPot = iBaseGame(_jackPot);
        superJackPot = iBaseGame(_superJackPot);
    }

    function startGames() public payable onlyOwner {

        hourlyGame.setTicketPrice(BET_PRICE.mul(HOURLY_GAME_SHARE).div(SHARE_DENOMINATOR));
        dailyGame.setTicketPrice(BET_PRICE.mul(DAILY_GAME_SHARE).div(SHARE_DENOMINATOR));
        weeklyGame.setTicketPrice(BET_PRICE.mul(WEEKLY_GAME_SHARE).div(SHARE_DENOMINATOR));
        monthlyGame.setTicketPrice(BET_PRICE.mul(MONTHLY_GAME_SHARE).div(SHARE_DENOMINATOR));
        yearlyGame.setTicketPrice(BET_PRICE.mul(YEARLY_GAME_SHARE).div(SHARE_DENOMINATOR));
        jackPot.setTicketPrice(BET_PRICE.mul(JACKPOT_GAME_SHARE).div(SHARE_DENOMINATOR));
        superJackPot.setTicketPrice(BET_PRICE.mul(SUPER_JACKPOT_GAME_SHARE).div(SHARE_DENOMINATOR));

        uint hourlyPeriod = hourlyGame.getPeriod();
        uint dailyPeriod = dailyGame.getPeriod();
        uint weeklyPeriod = weeklyGame.getPeriod();
        uint monthlyPeriod = monthlyGame.getPeriod();
        uint yearlyPeriod = yearlyGame.getPeriod();

        hourlyGame.startGame.value(msg.value/7)(hourlyPeriod.sub((now.sub(N_Y)) % hourlyPeriod));
        dailyGame.startGame.value(msg.value/7)(dailyPeriod.sub((now.sub(N_Y)) % dailyPeriod));
        weeklyGame.startGame.value(msg.value/7)(weeklyPeriod.sub((now.sub(N_Y)) % weeklyPeriod));
        monthlyGame.startGame.value(msg.value/7)(monthlyPeriod.sub((now.sub(N_Y)) % monthlyPeriod));
        yearlyGame.startGame.value(msg.value/7)(yearlyPeriod.sub((now.sub(N_Y)) % yearlyPeriod));
        jackPot.startGame.value(msg.value/7)(ORACLIZE_TIMEOUT);
        superJackPot.startGame.value(msg.value/7)(ORACLIZE_TIMEOUT);
    }
}


// Developer @gogol
// Design @chechenets
// Architect @tugush