/**
 * Source Code first verified at https://etherscan.io on Saturday, April 13, 2019
 (UTC) */

pragma solidity ^0.4.25;

interface DSG {
    function gamingDividendsReception() payable external;
}

contract DSG_Turntable{
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
        uint256 blockNumber;
        uint256 bet;
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
            emit Result(msg.sender, 1000, 0, jackpotBalance, usersBets[msg.sender].bet, 0);
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
    function play() public payable checkBlockNumber onlyUsers{
        uint256 bet = msg.value;
        require(checkSolvency(bet), "Not enough ETH in contract");
        require(paused == false, "Game was stopped");
        require(bet >= minBet && bet <= maxBet, "Amount should be within range");
        require(usersBets[msg.sender].bet == 0, "You have already bet");
        usersBets[msg.sender].bet = bet;
        usersBets[msg.sender].blockNumber = block.number;
        totalTurnover = totalTurnover.add(bet);
        totalPlayed = totalPlayed.add(1);
        emit PlaceBet(msg.sender, bet, now);
    }
    function result() public checkBlockNumber onlyUsers{
        require(blockhash(usersBets[msg.sender].blockNumber) != 0, "Your time to determine the result has come out or not yet come");
        uint256 bet = usersBets[msg.sender].bet;
        uint256 totalWinAmount;
        uint256 r = _random(1000);
        uint256 winRate = 0;
        if(_winChanceJ(r, bet)){
		    winRate = 1000;
            totalWinAmount = totalWinAmount.add(jackpotBalance).add(bet);
            emit Jackpot(msg.sender, jackpotBalance, now);
            delete jackpotBalance;
		}
		if(_winChance1x(r)){
		    winRate = 100;
		    totalWinAmount = totalWinAmount.add(bet);
		}
		if(_winChance1_5x(r)){
		    winRate = 150;
		    totalWinAmount = totalWinAmount.add(bet.mul(winRate).div(100));
		}
		if(_winChance2x(r)){
		    winRate = 200;
		    totalWinAmount = totalWinAmount.add(bet.mul(winRate).div(100));
		}
		if(_winChance2_5x(r)){
		    winRate = 250;
		    totalWinAmount = totalWinAmount.add(bet.mul(winRate).div(100));
		}
		if(_winChance3x(r)){
		    winRate = 300;
		    totalWinAmount = totalWinAmount.add(bet.mul(winRate).div(100));
		}
		if(_winChance5x(r)){
		    winRate = 500;
		    totalWinAmount = totalWinAmount.add(bet.mul(winRate).div(100));
		}
		if(totalWinAmount > 0){
            msg.sender.transfer(totalWinAmount);
            totalWinnings = totalWinnings.add(totalWinAmount);
        }
        jackpotBalance = jackpotBalance.add(bet.div(1000));
        delete usersBets[msg.sender];
        emit Result(msg.sender, r, totalWinAmount, jackpotBalance, bet, winRate);
    }
    function _winChanceJ(uint r, uint bet) private view returns(bool){
		if(bet >= minBetForJackpot && r == 999 && jackpotBalance > 0) return true;
		else return false;
	}
    function _winChance5x(uint r) private pure returns(bool){
		if(r == 12 || r == 22 || r == 32 || r == 42 || r == 52) return true;
		else return false;
	}
	function _winChance3x(uint r) private pure returns(bool){
		if( (r >= 80 && r < 83)   ||
			(r >= 180 && r < 183) ||
			(r >= 280 && r < 283) ||
			(r >= 380 && r < 383) ||
			(r >= 480 && r < 483) ||
			(r >= 580 && r < 583) ||
			(r >= 680 && r < 683) ||
			(r >= 780 && r < 783))
		return true;
		else return false;
	}
	function _winChance2_5x(uint r) private pure returns(bool){
		if( (r >= 75 && r < 80)   ||
			(r >= 175 && r < 180) ||
			(r >= 275 && r < 280) ||
			(r >= 375 && r < 380) ||
			(r >= 475 && r < 480) ||
			(r >= 575 && r < 580) ||
			(r >= 675 && r < 680) ||
			(r >= 775 && r < 780))
	    return true;
		else return false;
	}
	function _winChance2x(uint r) private pure returns(bool){
		if((r >= 50 && r < 75) || (r >= 350 && r < 375) || (r >= 650 && r < 675) || (r >= 950 && r < 975)) return true;
		else return false;
	}
	function _winChance1_5x(uint r) private pure returns(bool){
		if((r >= 25 && r < 50) || (r >= 125 && r < 150)) return true;
		else if((r >= 425 && r < 450) || (r >= 525 && r < 550)) return true;
		else if((r >= 625 && r < 650) || (r >= 725 && r < 750)) return true;
		else return false;
	}
	function _winChance1x(uint r) private pure returns(bool){
		if((r >= 0 && r < 25) || (r >= 100 && r < 125)) return true;
		else if((r >= 400 && r < 425) || (r >= 500 && r < 525)) return true;
		else if((r >= 600 && r < 625) || (r >= 700 && r < 725)) return true;
		else return false;
	}
    function checkSolvency(uint bet) view public returns(bool){
        if(getContractBalance() > bet.mul(500).div(100).add(jackpotBalance)) return true;
        else return false;
    }
    function sendDividends() public {
        require(getContractBalance() > minContractBalance && now > nextPayout, "You cannot send dividends");
        DSG DSG0 = DSG(DSG_ADDRESS);
        uint256 balance = getContractBalance();
        uint256 dividends = balance.sub(minContractBalance);
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
        uint256 timestamp
    );
    event Result(
        address indexed player,
        uint256 indexed random,
        uint256 totalWinAmount,
        uint256 jackpotBalance,
        uint256 bet,
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