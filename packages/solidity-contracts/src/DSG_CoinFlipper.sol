/**
 * Source Code first verified at https://etherscan.io on Friday, April 5, 2019
 (UTC) */

pragma solidity ^0.4.25;

interface DSG {
    function gamingDividendsReception() payable external;
}

contract DSG_CoinFlipper{
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
        uint8 coin;
        uint256 bet;
    }
    
    modifier onlyOwners() {
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
            emit Result(msg.sender, 0, 1200, 0, jackpotBalance, 0, usersBets[msg.sender].bet);
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
    function play(uint8 coin) public payable checkBlockNumber{
        uint256 bet = msg.value;
        require(getContractBalance() > bet.add(bet).add(jackpotBalance), "Not enough ETH in contract");
        require(bet >= minBet && bet <= maxBet, "Amount should be within range");
        require(usersBets[msg.sender].bet == 0, "You have already bet");
        require(coin == 0 || coin == 1, "Coin side is incorrect");
        require(paused == false, "Game was stopped");
        usersBets[msg.sender].bet = bet;
        usersBets[msg.sender].blockNumber = block.number;
        usersBets[msg.sender].coin = coin;
        totalTurnover = totalTurnover.add(bet);
        totalPlayed = totalPlayed.add(1);
        emit PlaceBet(msg.sender, bet, coin, now);
    }
    function result() public checkBlockNumber{
        require(blockhash(usersBets[msg.sender].blockNumber) != 0, "Your time to determine the result has come out or not yet come");
        uint256 bet = usersBets[msg.sender].bet;
        uint8   coin = usersBets[msg.sender].coin;
        uint256 totalWinAmount;
        uint256 winRate    = getWinningRate(bet);
        uint256 r = _random(1200);
        if(((r > 0 && r < 200) || (r > 400 && r < 600) || (r > 800 && r < 1000)) && coin == 1){
            totalWinAmount = totalWinAmount.add(bet.mul(winRate).div(100));
            jackpotBalance = jackpotBalance.add(bet.div(1000));
        }
        if(((r > 200 && r < 400) || (r > 600 && r < 800) || (r > 1000 && r < 1200)) && coin == 0){
            totalWinAmount = totalWinAmount.add(bet.mul(winRate).div(100));
            jackpotBalance = jackpotBalance.add(bet.div(1000));
        }
        if(bet >= minBetForJackpot && r == 0 && jackpotBalance > 0){
            totalWinAmount = totalWinAmount.add(jackpotBalance).add(bet);
            delete jackpotBalance;
        }
        if(totalWinAmount > 0){
            msg.sender.transfer(totalWinAmount);
            totalWinnings = totalWinnings.add(totalWinAmount);
        }
        delete usersBets[msg.sender];
        emit Result(msg.sender, coin, r, totalWinAmount, jackpotBalance, winRate, bet);
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
    function getWinningRate(uint256 eth) public view returns(uint8){
        uint256 x = maxBet.sub(minBet).div(4);
        if(eth >= minBet && eth <= minBet.add(x)){
            return 194;
        }
        else if(eth >= minBet.add(x.mul(1)) && eth <= minBet.add(x.mul(2))){
            return 195;
        }
        else if(eth >= minBet.add(x.mul(2)) && eth <= minBet.add(x.mul(3))){
            return 196;
        }
        else if(eth >= minBet.add(x.mul(3)) && eth <= minBet.add(x.mul(4))){
            return 197;
        }
        else{
            return 194;
        }
    }
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
    function _random(uint256 max) private view returns(uint256){
        bytes32 hash = blockhash(usersBets[msg.sender].blockNumber);
        return uint256(keccak256(abi.encode(hash, msg.sender))) % max;
    }
    function deposit() public payable onlyOwners{
        ownerDeposit = ownerDeposit.add(msg.value);
        jackpotBalance = jackpotBalance.add(msg.value.div(100));
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
    function transferOwnership(address newOwnerAddress, uint8 k) public onlyOwners {
        candidates[k] = newOwnerAddress;
    }
    function confirmOwner(uint8 k) public {
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
        uint256 coin,
        uint256 timestamp
    );
    event Result(
        address indexed player,
        uint256 indexed coin,
        uint256 indexed random,
        uint256 totalWinAmount,
        uint256 jackpotBalance,
        uint256 winRate,
        uint256 bet
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