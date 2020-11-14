/**
 * Source Code first verified at https://etherscan.io on Friday, April 5, 2019
 (UTC) */

pragma solidity ^0.4.25;

interface DSG {
    function gamingDividendsReception() payable external;
}

contract DSG_Dice{
    using SafeMath for uint256;
    
    address constant public DSG_ADDRESS = 0x696826C18A6Bc9Be4BBfe3c3A6BB9f5a69388687;
    uint256 public totalDividends;
    uint256 public totalWinnings;
    uint256 public totalTurnover;
    uint256 public totalPlayed;
    uint256 public maxBet;
    uint256 public minBet;
    uint256 public minContractBalance;
    uint256 public minBetForJackpot;
    uint256 public jackpotBalance;
    uint256 public nextPayout;
    uint256 public ownerDeposit;
    address[2] public owners;
    address[2] public candidates;
    bool public paused;
    
    mapping (address => Bet) private usersBets;
    
    struct Bet {
        uint blockNumber;
        uint bet;
        bool[6] dice;
    }
    
    modifier onlyOwners(){
        require(msg.sender == owners[0] || msg.sender == owners[1]);
        _;
    }
    modifier onlyUsers(){
        require(tx.origin == msg.sender);
        _;
    }
    modifier checkBlockNumber(){
        uint256 blockNumber = usersBets[msg.sender].blockNumber;
        if(block.number.sub(blockNumber) >= 250 && blockNumber > 0){
            emit Result(msg.sender, 601, 0, jackpotBalance, usersBets[msg.sender].bet, usersBets[msg.sender].dice, 0);
            delete usersBets[msg.sender];
        }
        else{
            _;
        }
    }
    constructor(address secondOwner) public payable{
        owners[0]   = msg.sender;
        owners[1]   = secondOwner;
        ownerDeposit   = msg.value;
        jackpotBalance = jackpotBalance.add(ownerDeposit.div(1000));
    }
    function play(bool dice1, bool dice2, bool dice3, bool dice4, bool dice5, bool dice6) public payable checkBlockNumber onlyUsers{
        uint256 bet = msg.value;
        require(checkSolvency(bet), "Not enough ETH in contract");
        require(paused == false, "Game was stopped");
        require(bet >= minBet && bet <= maxBet, "Amount should be within range");
        require(usersBets[msg.sender].bet == 0, "You have already bet");
        bool[6] memory dice = [dice1, dice2, dice3, dice4, dice5, dice6];
        usersBets[msg.sender].bet = bet;
        usersBets[msg.sender].blockNumber = block.number;
        usersBets[msg.sender].dice = dice;
        totalTurnover = totalTurnover.add(bet);
        totalPlayed = totalPlayed.add(1);
        emit PlaceBet(msg.sender, bet, dice, now);
    }
    function result() public checkBlockNumber onlyUsers{
        require(blockhash(usersBets[msg.sender].blockNumber) != 0, "Your time to determine the result has come out or not yet come");
        uint256 r = _random(601);
        bool[6] memory dice = usersBets[msg.sender].dice;
        uint256 bet = usersBets[msg.sender].bet;
        uint256 rate = getXRate(dice);
        uint256 totalWinAmount;
        if(getDice(r) == 1 && dice[0] == true){
            totalWinAmount = totalWinAmount.add(bet.mul(rate).div(100));
		}
		else if(getDice(r) == 2 && dice[1] == true){
		    totalWinAmount = totalWinAmount.add(bet.mul(rate).div(100));
		}
		else if(getDice(r) == 3 && dice[2] == true){
		    totalWinAmount = totalWinAmount.add(bet.mul(rate).div(100));
		}
		else if(getDice(r) == 4 && dice[3] == true){
		    totalWinAmount = totalWinAmount.add(bet.mul(rate).div(100));
		}
		else if(getDice(r) == 5 && dice[4] == true){
		    totalWinAmount = totalWinAmount.add(bet.mul(rate).div(100));
		}
		else if(getDice(r) == 6 && dice[5] == true){
		    totalWinAmount = totalWinAmount.add(bet.mul(rate).div(100));
		}
		if(bet >= minBetForJackpot && r == 0 && jackpotBalance > 0){
		    totalWinAmount = totalWinAmount.add(jackpotBalance);
		    emit Jackpot(msg.sender, jackpotBalance, now);
            delete jackpotBalance;
		}
		if(totalWinAmount > 0){
		    msg.sender.transfer(totalWinAmount);
	    	totalWinnings = totalWinnings.add(totalWinAmount);
		}
        jackpotBalance = jackpotBalance.add(bet.div(1000));
		delete usersBets[msg.sender];
		emit Result(msg.sender, r, totalWinAmount, jackpotBalance, bet, dice, rate);
    }
    function getXRate(bool[6] dice) public pure returns(uint){
        uint sum;
        for(uint i = 0; i < dice.length; i++){
            if(dice[i] == true) sum = sum.add(1);
        }
		if(sum == 1) return 580;
		if(sum == 2) return 290;
		if(sum == 3) return 195;
		if(sum == 4) return 147;
		if(sum == 5) return 117;
	}
    function getDice(uint r) private pure returns (uint){
		if((r > 0 && r <= 50) || (r > 300 && r <= 350)){
			return 1;
		}
		else if((r > 50 && r <= 100) || (r > 500 && r <= 550)){
			return 2;
		}
		else if((r > 100 && r <= 150) || (r > 450 && r <= 500)){
			return 3;
		}
		else if((r > 150 && r <= 200) || (r > 400 && r <= 450)){
			return 4;
		}
		else if((r > 200 && r <= 250) || (r > 350 && r <= 400)){
			return 5;
		}
		else if((r > 250 && r <= 300) || (r > 550 && r <= 600)){
			return 6;
		}
	}
    function checkSolvency(uint bet) view public returns(bool){
        if(getContractBalance() > bet.add(bet.mul(500).div(100)).add(jackpotBalance)) return true;
        else return false;
    }
    function sendDividends() public {
        require(getContractBalance() > minContractBalance && now > nextPayout, "You cannot send dividends");
        DSG DSG0 = DSG(DSG_ADDRESS);
        uint256 balance = getContractBalance();
        uint256 dividends  = balance.sub(minContractBalance);
        nextPayout = now.add(7 days);
        totalDividends = totalDividends.add(dividends);
        DSG0.gamingDividendsReception.value(dividends)();
        emit Dividends(balance, dividends, now);
    }
     function getContractBalance() public view returns (uint256){
        return address(this).balance;
    }
    function _random(uint256 max) private view returns(uint256){
        bytes32 hash = blockhash(usersBets[msg.sender].blockNumber);
        return uint256(keccak256(abi.encode(hash, msg.sender))) % max;
    }
    function deposit() public payable onlyOwners{
        ownerDeposit = ownerDeposit.add(msg.value);
    }
    function sendOwnerDeposit(address recipient) public onlyOwners{
        require(paused == true, 'Game was not stopped');
        uint256 contractBalance = getContractBalance();
        if(contractBalance >= ownerDeposit){
            recipient.transfer(ownerDeposit);
        }
        else{
            recipient.transfer(contractBalance);
        }
        delete jackpotBalance;
        delete ownerDeposit;
    }
    function pauseGame(bool option) public onlyOwners{
        paused = option;
    }
    function setMinBet(uint256 eth) public onlyOwners{
        minBet = eth;
    }
    function setMaxBet(uint256 eth) public onlyOwners{
        maxBet = eth;
    }
    function setMinBetForJackpot(uint256 eth) public onlyOwners{
        minBetForJackpot = eth;
    }
    function setMinContractBalance(uint256 eth) public onlyOwners{
        minContractBalance = eth;
    }
    function transferOwnership(address newOwnerAddress, uint8 k) public onlyOwners{
        candidates[k] = newOwnerAddress;
    }
    function confirmOwner(uint8 k) public{
        require(msg.sender == candidates[k]);
        owners[k] = candidates[k];
    }
    event Dividends(
        uint256 balance,
        uint256 dividends,
        uint256 timestamp
    );
    event Jackpot(
        address indexed player,
        uint256 jackpot,
        uint256 timestamp
    );
    event PlaceBet(
        address indexed player,
        uint256 bet,
        bool[6] dice,
        uint256 timestamp
    );
    event Result(
        address indexed player,
        uint256 indexed random,
        uint256 totalWinAmount,
        uint256 jackpotBalance,
        uint256 bet,
        bool[6] dice,
        uint256 winRate
    );
}
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {  return 0; }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}