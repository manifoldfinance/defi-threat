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

contract Manageable is Ownable {
    mapping(address => bool) public listOfManagers;

    modifier onlyManager() {
        require(listOfManagers[msg.sender], "");
        _;
    }

    function addManager(address _manager) public onlyOwner returns (bool success) {
        if (!listOfManagers[_manager]) {
            require(_manager != address(0), "");
            listOfManagers[_manager] = true;
            success = true;
        }
    }

    function removeManager(address _manager) public onlyOwner returns (bool success) {
        if (listOfManagers[_manager]) {
            listOfManagers[_manager] = false;
            success = true;
        }
    }

    function getInfo(address _manager) public view returns (bool) {
        return listOfManagers[_manager];
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

contract iRNG {
    function update(uint roundNumber, uint additionalNonce, uint period) public payable;
}


contract BaseGame is Manageable {
    using SafeMath for uint;

    enum RoundState {NOT_STARTED, ACCEPT_FUNDS, WAIT_RESULT, SUCCESS, REFUND}

    struct Round {
        RoundState state;
        uint ticketsCount;
        uint participantCount;
        TicketsInterval[] tickets;
        address[] participants;
        uint random;
        uint nonce; //xored participants addresses
        uint startRoundTime;
        uint[] winningTickets;
        address[] winners;
        uint roundFunds;
        mapping(address => uint) winnersFunds;
        mapping(address => uint) participantFunds;
        mapping(address => bool) sendGain;
    }

    struct TicketsInterval {
        address participant;
        uint firstTicket;
        uint lastTicket;
    }

    uint constant public NUMBER_OF_WINNERS = 10;
    uint constant public SHARE_DENOMINATOR = 10000;
    uint constant public ORACLIZE_TIMEOUT = 86400;  // one day
    uint[] public shareOfWinners = [5000, 2500, 1250, 620, 320, 160, 80, 40, 20, 10];
    address payable public organiser;
    uint constant public ORGANISER_PERCENT = 20;
    uint constant public ROUND_FUND_PERCENT = 80;

    uint public period;
    address public hourlyGame;
    address public management;
    address payable public rng;

    mapping (uint => Round) public rounds;

    uint public ticketPrice;
    uint public currentRound;

    event GameStarted(uint start);
    event RoundStateChanged(uint currentRound, RoundState state);
    event ParticipantAdded(uint round, address participant, uint ticketsCount, uint funds);
    event RoundProcecced(uint round, address[] winners, uint[] winningTickets, uint roundFunds);
    event RefundIsSuccess(uint round, address participant, uint funds);
    event RefundIsFailed(uint round, address participant);
    event Withdraw(address participant, uint funds, uint fromRound, uint toRound);
    event TicketPriceChanged(uint price);

    modifier onlyRng {
        require(msg.sender == address(rng), "");
        _;
    }

    modifier onlyGameContract {
        require(msg.sender == address(hourlyGame) || msg.sender == management, "");
        _;
    }

    constructor (address payable _rng, uint _period) public {
        require(_rng != address(0), "");
        require(_period >= 60, "");

        rng = _rng;
        period = _period;
    }

    function setContracts(address payable _rng, address _hourlyGame, address _management) public onlyOwner {
        require(_rng != address(0), "");
        require(_hourlyGame != address(0), "");
        require(_management != address(0), "");

        rng = _rng;
        hourlyGame = _hourlyGame;
        management = _management;
    }

    function startGame(uint _startPeriod) public payable onlyGameContract {
        currentRound = 1;
        uint time = getCurrentTime().add(_startPeriod).sub(period);
        rounds[currentRound].startRoundTime = time;
        rounds[currentRound].state = RoundState.ACCEPT_FUNDS;

        iRNG(rng).update.value(msg.value)(currentRound, 0, _startPeriod);

        emit GameStarted(time);
    }

    function buyTickets(address _participant) public payable onlyGameContract {
        uint funds = msg.value;

        updateRoundTimeAndState();
        addParticipant(_participant, funds.div(ticketPrice));
        updateRoundFundsAndParticipants(_participant, funds);

        if (getCurrentTime() > rounds[currentRound].startRoundTime.add(period) &&
            rounds[currentRound].participantCount >= 10
        ) {
            _restartGame();
        }
    }

    function buyBonusTickets(address _participant, uint _ticketsCount) public payable onlyGameContract {
        updateRoundTimeAndState();
        addParticipant(_participant, _ticketsCount);
        updateRoundFundsAndParticipants(_participant, uint(0));

        if (getCurrentTime() > rounds[currentRound].startRoundTime.add(period) &&
            rounds[currentRound].participantCount >= 10
        ) {
            _restartGame();
        }
    }

    function processRound(uint _round, uint _randomNumber) public payable onlyRng returns (bool) {
        if (rounds[_round].winners.length != 0) {
            return true;
        }

        if (checkRoundState(_round) == RoundState.REFUND) {
            return true;
        }

        if (rounds[_round].participantCount < 10) {
            rounds[_round].state = RoundState.ACCEPT_FUNDS;
            emit RoundStateChanged(_round, rounds[_round].state);
            return true;
        }

        rounds[_round].random = _randomNumber;
        findWinTickets(_round);
        findWinners(_round);
        rounds[_round].state = RoundState.SUCCESS;
        emit RoundStateChanged(_round, rounds[_round].state);

        if (rounds[_round.add(1)].state == RoundState.NOT_STARTED) {
            currentRound = _round.add(1);
            rounds[currentRound].state = RoundState.ACCEPT_FUNDS;
            emit RoundStateChanged(currentRound, rounds[currentRound].state);
        }

        emit RoundProcecced(_round, rounds[_round].winners, rounds[_round].winningTickets, rounds[_round].roundFunds);
        getRandomNumber(_round + 1, rounds[_round].nonce);
        return true;
    }

    function restartGame() public payable onlyOwner {
        _restartGame();
    }

    function getRandomNumber(uint _round, uint _nonce) public payable onlyRng {
        iRNG(rng).update(_round, _nonce, period);
    }

    function setTicketPrice(uint _ticketPrice) public onlyGameContract {
        require(_ticketPrice > 0, "");

        emit TicketPriceChanged(_ticketPrice);
        ticketPrice = _ticketPrice;
    }

    function findWinTickets(uint _round) public {
        uint[10] memory winners = _findWinTickets(rounds[_round].random, rounds[_round].ticketsCount);

        for (uint i = 0; i < 10; i++) {
            rounds[_round].winningTickets.push(winners[i]);
        }
    }

    function _findWinTickets(uint _random, uint _ticketsNum) public pure returns (uint[10] memory) {
        uint random = _random;//uint(keccak256(abi.encodePacked(_random)));
        uint winnersNum = 10;

        uint[10] memory winTickets;
        uint shift = uint(256).div(winnersNum);

        for (uint i = 0; i < 10; i++) {
            winTickets[i] =
            uint(keccak256(abi.encodePacked(((random << (i.mul(shift))) >> (shift.mul(winnersNum.sub(1)).add(6)))))).mod(_ticketsNum);
        }

        return winTickets;
    }

    function refund(uint _round) public {
        if (checkRoundState(_round) == RoundState.REFUND
        && rounds[_round].participantFunds[msg.sender] > 0
        ) {
            uint amount = rounds[_round].participantFunds[msg.sender];
            rounds[_round].participantFunds[msg.sender] = 0;
            address(msg.sender).transfer(amount);
            emit RefundIsSuccess(_round, msg.sender, amount);
        } else {
            emit RefundIsFailed(_round, msg.sender);
        }
    }

    function checkRoundState(uint _round) public returns (RoundState) {
        if (rounds[_round].state == RoundState.WAIT_RESULT
        && getCurrentTime() > rounds[_round].startRoundTime.add(ORACLIZE_TIMEOUT)
        ) {
            rounds[_round].state = RoundState.REFUND;
            emit RoundStateChanged(_round, rounds[_round].state);
        }
        return rounds[_round].state;
    }

    function setOrganiser(address payable _organiser) public onlyOwner {
        require(_organiser != address(0), "");

        organiser = _organiser;
    }

   function getGain(uint _fromRound, uint _toRound) public {
        _transferGain(msg.sender, _fromRound, _toRound);
    }

    function sendGain(address payable _participant, uint _fromRound, uint _toRound) public onlyManager {
        _transferGain(_participant, _fromRound, _toRound);
    }

    function getTicketsCount(uint _round) public view returns (uint) {
        return rounds[_round].ticketsCount;
    }

    function getTicketPrice() public view returns (uint) {
        return ticketPrice;
    }

    function getCurrentTime() public view returns (uint) {
        return now;
    }

    function getPeriod() public view returns (uint) {
        return period;
    }

    function getRoundWinners(uint _round) public view returns (address[] memory) {
        return rounds[_round].winners;
    }

    function getRoundWinningTickets(uint _round) public view returns (uint[] memory) {
        return rounds[_round].winningTickets;
    }

    function getRoundParticipants(uint _round) public view returns (address[] memory) {
        return rounds[_round].participants;
    }

    function getWinningFunds(uint _round, address _winner) public view returns  (uint) {
        return rounds[_round].winnersFunds[_winner];
    }

    function getRoundFunds(uint _round) public view returns (uint) {
        return rounds[_round].roundFunds;
    }

    function getParticipantFunds(uint _round, address _participant) public view returns (uint) {
        return rounds[_round].participantFunds[_participant];
    }

    function getCurrentRound() public view returns (uint) {
        return currentRound;
    }

    function getRoundStartTime(uint _round) public view returns (uint) {
        return rounds[_round].startRoundTime;
    }

    function _restartGame() internal {
        uint _now = getCurrentTime().sub(rounds[1].startRoundTime);
        rounds[currentRound].startRoundTime = getCurrentTime().sub(_now.mod(period));
        rounds[currentRound].state = RoundState.ACCEPT_FUNDS;
        emit RoundStateChanged(currentRound, rounds[currentRound].state);
        iRNG(rng).update(currentRound, 0, period.sub(_now.mod(period)));
    }

    function _transferGain(address payable _participant, uint _fromRound, uint _toRound) internal {
        require(_fromRound <= _toRound, "");
        require(_participant != address(0), "");

        uint funds;

        for (uint i = _fromRound; i <= _toRound; i++) {

            if (rounds[i].state == RoundState.SUCCESS
            && rounds[i].sendGain[_participant] == false) {

                rounds[i].sendGain[_participant] = true;
                funds = funds.add(getWinningFunds(i, _participant));
            }
        }

        require(funds > 0, "");
        _participant.transfer(funds);
        emit Withdraw(_participant, funds, _fromRound, _toRound);

    }

    // find participant who has winning ticket
    // to start: _begin is 0, _end is last index in ticketsInterval array
    function getWinner(
        uint _round,
        uint _beginInterval,
        uint _endInterval,
        uint _winningTicket
    )
        internal
        returns (address)
    {
        if (_beginInterval == _endInterval) {
            return rounds[_round].tickets[_beginInterval].participant;
        }

        uint len = _endInterval.add(1).sub(_beginInterval);
        uint mid = _beginInterval.add((len.div(2))).sub(1);
        TicketsInterval memory interval = rounds[_round].tickets[mid];

        if (_winningTicket < interval.firstTicket) {
            return getWinner(_round, _beginInterval, mid, _winningTicket);
        } else if (_winningTicket > interval.lastTicket) {
            return getWinner(_round, mid.add(1), _endInterval, _winningTicket);
        } else {
            return interval.participant;
        }
    }

    function addParticipant(address _participant, uint _ticketsCount) internal {
        rounds[currentRound].participants.push(_participant);
        uint currTicketsCount = rounds[currentRound].ticketsCount;
        rounds[currentRound].ticketsCount = currTicketsCount.add(_ticketsCount);
        rounds[currentRound].tickets.push(TicketsInterval(
                _participant,
                currTicketsCount,
                rounds[currentRound].ticketsCount.sub(1))
        );
        rounds[currentRound].nonce = rounds[currentRound].nonce + uint(keccak256(abi.encodePacked(_participant)));
        emit ParticipantAdded(currentRound, _participant, _ticketsCount, _ticketsCount.mul(ticketPrice));
    }

    function updateRoundTimeAndState() internal {
        if (getCurrentTime() > rounds[currentRound].startRoundTime.add(period)
            && rounds[currentRound].participantCount >= 10
        ) {
            rounds[currentRound].state = RoundState.WAIT_RESULT;
            emit RoundStateChanged(currentRound, rounds[currentRound].state);
            currentRound = currentRound.add(1);
            rounds[currentRound].startRoundTime = rounds[currentRound-1].startRoundTime.add(period);
            rounds[currentRound].state = RoundState.ACCEPT_FUNDS;
            emit RoundStateChanged(currentRound, rounds[currentRound].state);
        }
    }

    function updateRoundFundsAndParticipants(address _participant, uint _funds) internal {

        if (rounds[currentRound].participantFunds[_participant] == 0) {
            rounds[currentRound].participantCount = rounds[currentRound].participantCount.add(1);
        }

        rounds[currentRound].participantFunds[_participant] =
        rounds[currentRound].participantFunds[_participant].add(_funds);

        rounds[currentRound].roundFunds =
        rounds[currentRound].roundFunds.add(_funds);
    }

    function findWinners(uint _round) internal {
        address winner;
        uint fundsToWinner;
        for (uint i = 0; i < NUMBER_OF_WINNERS; i++) {
            winner = getWinner(
                _round,
                0,
                (rounds[_round].tickets.length).sub(1),
                rounds[_round].winningTickets[i]
            );

            rounds[_round].winners.push(winner);
            fundsToWinner = rounds[_round].roundFunds.mul(shareOfWinners[i]).div(SHARE_DENOMINATOR);
            rounds[_round].winnersFunds[winner] = rounds[_round].winnersFunds[winner].add(fundsToWinner);
        }
    }


}


// Developer @gogol
// Design @chechenets
// Architect @tugush


contract iBaseGame {
    function getPeriod() public view returns (uint);
    function buyTickets(address _participant) public payable;
    function startGame(uint _startPeriod) public payable;
    function setTicketPrice(uint _ticketPrice) public;
    function buyBonusTickets(address _participant, uint _ticketsCount) public;
}

contract iJackPotChecker {
    function getPrice() public view returns (uint);
}


contract HourlyGame is BaseGame {
    address payable public checker;
    uint public serviceMinBalance = 1 ether;

    uint public BET_PRICE;

    uint constant public HOURLY_GAME_SHARE = 30;                       //30% to hourly game
    uint constant public DAILY_GAME_SHARE = 10;                        //10% to daily game
    uint constant public WEEKLY_GAME_SHARE = 5;                        //5% to weekly game
    uint constant public MONTHLY_GAME_SHARE = 5;                       //5% to monthly game
    uint constant public YEARLY_GAME_SHARE = 5;                        //5% to yearly game
    uint constant public JACKPOT_GAME_SHARE = 10;                 //10% to jackpot game
    uint constant public SUPER_JACKPOT_GAME_SHARE = 15;                 //15% to superJackpot game
    uint constant public GAME_ORGANISER_SHARE = 20;                    //20% to game organiser
    uint constant public SHARE_DENOMINATOR = 100;                        //denominator for share

    bool public paused;

    address public dailyGame;
    address public weeklyGame;
    address public monthlyGame;
    address public yearlyGame;
    address public jackPot;
    address public superJackPot;

    event TransferFunds(address to, uint funds);

    constructor (
        address payable _rng,
        uint _period,
        address _dailyGame,
        address _weeklyGame,
        address _monthlyGame,
        address _yearlyGame,
        address _jackPot,
        address _superJackPot
    )
        public
        BaseGame(_rng, _period)
    {
        require(_dailyGame != address(0), "");
        require(_weeklyGame != address(0), "");
        require(_monthlyGame != address(0), "");
        require(_yearlyGame != address(0), "");
        require(_jackPot != address(0), "");
        require(_superJackPot != address(0), "");

        dailyGame = _dailyGame;
        weeklyGame = _weeklyGame;
        monthlyGame = _monthlyGame;
        yearlyGame = _yearlyGame;
        jackPot = _jackPot;
        superJackPot = _superJackPot;
    }

    function () external payable {
        buyTickets(msg.sender);
    }

    function buyTickets(address _participant) public payable {
        require(!paused, "");
        require(msg.value > 0, "");

        uint ETHinUSD = iJackPotChecker(checker).getPrice();
        BET_PRICE = uint(100).mul(10**18).div(ETHinUSD);    // BET_PRICE is $1 in wei

        uint funds = msg.value;
        uint extraFunds = funds.mod(BET_PRICE);

        if (extraFunds > 0) {
            organiser.transfer(extraFunds);
            emit TransferFunds(organiser, extraFunds);
            funds = funds.sub(extraFunds);
        }

        uint fundsToOrginiser = funds.mul(GAME_ORGANISER_SHARE).div(SHARE_DENOMINATOR);

        fundsToOrginiser = transferToServices(rng, fundsToOrginiser, serviceMinBalance);
        fundsToOrginiser = transferToServices(checker, fundsToOrginiser, serviceMinBalance);

        if (fundsToOrginiser > 0) {
            organiser.transfer(fundsToOrginiser);
            emit TransferFunds(organiser, fundsToOrginiser);
        }

        updateRoundTimeAndState();
        addParticipant(_participant, funds.div(BET_PRICE));
        updateRoundFundsAndParticipants(_participant, funds.mul(HOURLY_GAME_SHARE).div(SHARE_DENOMINATOR));

        if (getCurrentTime() > rounds[currentRound].startRoundTime.add(period)
            && rounds[currentRound].participantCount >= 10
        ) {
            _restartGame();
        }

        iBaseGame(dailyGame).buyTickets.value(funds.mul(DAILY_GAME_SHARE).div(SHARE_DENOMINATOR))(_participant);
        iBaseGame(weeklyGame).buyTickets.value(funds.mul(WEEKLY_GAME_SHARE).div(SHARE_DENOMINATOR))(_participant);
        iBaseGame(monthlyGame).buyTickets.value(funds.mul(MONTHLY_GAME_SHARE).div(SHARE_DENOMINATOR))(_participant);
        iBaseGame(yearlyGame).buyTickets.value(funds.mul(YEARLY_GAME_SHARE).div(SHARE_DENOMINATOR))(_participant);
        iBaseGame(jackPot).buyTickets.value(funds.mul(JACKPOT_GAME_SHARE).div(SHARE_DENOMINATOR))(_participant);
        iBaseGame(superJackPot).buyTickets.value(funds.mul(SUPER_JACKPOT_GAME_SHARE).div(SHARE_DENOMINATOR))(_participant);

    }

    function buyBonusTickets(
        address _participant,
        uint _hourlyTicketsCount,
        uint _dailyTicketsCount,
        uint _weeklyTicketsCount,
        uint _monthlyTicketsCount,
        uint _yearlyTicketsCount,
        uint _jackPotTicketsCount,
        uint _superJackPotTicketsCount
    )
        public
        payable
        onlyManager
    {
        require(!paused, "");

        updateRoundTimeAndState();
        addParticipant(_participant, _hourlyTicketsCount);
        updateRoundFundsAndParticipants(_participant, uint(0));

        if (getCurrentTime() > rounds[currentRound].startRoundTime.add(period)
            && rounds[currentRound].participantCount >= 10
        ) {
            _restartGame();
        }

        iBaseGame(dailyGame).buyBonusTickets(_participant, _dailyTicketsCount);
        iBaseGame(weeklyGame).buyBonusTickets(_participant, _weeklyTicketsCount);
        iBaseGame(monthlyGame).buyBonusTickets(_participant, _monthlyTicketsCount);
        iBaseGame(yearlyGame).buyBonusTickets(_participant, _yearlyTicketsCount);
        iBaseGame(jackPot).buyBonusTickets(_participant, _jackPotTicketsCount);
        iBaseGame(superJackPot).buyBonusTickets(_participant, _superJackPotTicketsCount);
    }

    function setChecker(address payable _checker) public onlyOwner {
        require(_checker != address(0), "");

        checker = _checker;
    }

    function setMinBalance(uint _minBalance) public onlyOwner {
        require(_minBalance >= 1 ether, "");

        serviceMinBalance = _minBalance;
    }

    function pause(bool _paused) public onlyOwner {
        paused = _paused;
    }

    function transferToServices(address payable _service, uint _funds, uint _minBalance) internal returns (uint) {
        uint result = _funds;
        if (_service.balance < _minBalance) {
            uint lack = _minBalance.sub(_service.balance);
            if (_funds > lack) {
                _service.transfer(lack);
                emit TransferFunds(_service, lack);
                result = result.sub(lack);
            } else {
                _service.transfer(_funds);
                emit TransferFunds(_service, _funds);
                result = uint(0);
            }
        }
        return result;
    }
}


// Developer @gogol
// Design @chechenets
// Architect @tugush