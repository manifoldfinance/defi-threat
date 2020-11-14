/**
 * Source Code first verified at https://etherscan.io on Wednesday, March 20, 2019
 (UTC) */

pragma solidity ^0.5.0;

contract CryptoTycoonsVIPLib{
    
    address payable public owner;
    
    // Accumulated jackpot fund.
    uint128 public jackpotSize;
    uint128 public rankingRewardSize;
    
    mapping (address => uint) userExpPool;
    mapping (address => bool) public callerMap;

    event RankingRewardPayment(address indexed beneficiary, uint amount);

    modifier onlyOwner {
        require(msg.sender == owner, "OnlyOwner methods called by non-owner.");
        _;
    }

    modifier onlyCaller {
        bool isCaller = callerMap[msg.sender];
        require(isCaller, "onlyCaller methods called by non-caller.");
        _;
    }

    constructor() public{
        owner = msg.sender;
        callerMap[owner] = true;
    }

    // Fallback function deliberately left empty. It's primary use case
    // is to top up the bank roll.
    function () external payable {
    }

    function kill() external onlyOwner {
        selfdestruct(owner);
    }

    function addCaller(address caller) public onlyOwner{
        bool isCaller = callerMap[caller];
        if (isCaller == false){
            callerMap[caller] = true;
        }
    }

    function deleteCaller(address caller) external onlyOwner {
        bool isCaller = callerMap[caller];
        if (isCaller == true) {
            callerMap[caller] = false;
        }
    }

    function addUserExp(address addr, uint256 amount) public onlyCaller{
        uint exp = userExpPool[addr];
        exp = exp + amount;
        userExpPool[addr] = exp;
    }

    function getUserExp(address addr) public view returns(uint256 exp){
        return userExpPool[addr];
    }

    function getVIPLevel(address user) public view returns (uint256 level) {
        uint exp = userExpPool[user];

        if(exp >= 25 ether && exp < 125 ether){
            level = 1;
        } else if(exp >= 125 ether && exp < 250 ether){
            level = 2;
        } else if(exp >= 250 ether && exp < 1250 ether){
            level = 3;
        } else if(exp >= 1250 ether && exp < 2500 ether){
            level = 4;
        } else if(exp >= 2500 ether && exp < 12500 ether){
            level = 5;
        } else if(exp >= 12500 ether && exp < 25000 ether){
            level = 6;
        } else if(exp >= 25000 ether && exp < 125000 ether){
            level = 7;
        } else if(exp >= 125000 ether && exp < 250000 ether){
            level = 8;
        } else if(exp >= 250000 ether && exp < 1250000 ether){
            level = 9;
        } else if(exp >= 1250000 ether){
            level = 10;
        } else{
            level = 0;
        }

        return level;
    }

    function getVIPBounusRate(address user) public view returns (uint256 rate){
        uint level = getVIPLevel(user);
        return level;
    }

    // This function is used to bump up the jackpot fund. Cannot be used to lower it.
    function increaseJackpot(uint increaseAmount) external onlyCaller {
        require (increaseAmount <= address(this).balance, "Increase amount larger than balance.");
        require (jackpotSize + increaseAmount <= address(this).balance, "Not enough funds.");
        jackpotSize += uint128(increaseAmount);
    }

    function payJackpotReward(address payable to) external onlyCaller{
        to.transfer(jackpotSize);
        jackpotSize = 0;
    }

    function getJackpotSize() external view returns (uint256){
        return jackpotSize;
    }

    function increaseRankingReward(uint amount) public onlyCaller{
        require (amount <= address(this).balance, "Increase amount larger than balance.");
        require (rankingRewardSize + amount <= address(this).balance, "Not enough funds.");
        rankingRewardSize += uint128(amount);
    }

    function payRankingReward(address payable to) external onlyCaller {
        uint128 prize = rankingRewardSize / 2;
        rankingRewardSize = rankingRewardSize - prize;
        if(to.send(prize)){
            emit RankingRewardPayment(to, prize);
        }
    }

    function getRankingRewardSize() external view returns (uint128){
        return rankingRewardSize;
    }
}
contract CryptoTycoonsConstants{
    /// *** Constants section

    // Each bet is deducted 1% in favour of the house, but no less than some minimum.
    // The lower bound is dictated by gas costs of the settleBet transaction, providing
    // headroom for up to 10 Gwei prices.
    uint constant HOUSE_EDGE_PERCENT = 1;
    uint constant RANK_FUNDS_PERCENT = 7;
    uint constant INVITER_BENEFIT_PERCENT = 7;
    uint constant HOUSE_EDGE_MINIMUM_AMOUNT = 0.0004 ether;

    // Bets lower than this amount do not participate in jackpot rolls (and are
    // not deducted JACKPOT_FEE).
    uint constant MIN_JACKPOT_BET = 0.1 ether;

    // Chance to win jackpot (currently 0.1%) and fee deducted into jackpot fund.
    uint constant JACKPOT_MODULO = 1000;
    uint constant JACKPOT_FEE = 0.001 ether;

    // There is minimum and maximum bets.
    uint constant MIN_BET = 0.01 ether;
    uint constant MAX_AMOUNT = 10 ether;

    // Standard contract ownership transfer.
    address payable public owner;
    address payable private nextOwner;

    // Croupier account.
    mapping (address => bool ) croupierMap;

    // Adjustable max bet profit. Used to cap bets against dynamic odds.
    uint public maxProfit;

    address payable public VIPLibraryAddress;

    // The address corresponding to a private key used to sign placeBet commits.
    address public secretSigner;

    // Events that are issued to make statistic recovery easier.
    event FailedPayment(address indexed beneficiary, uint amount);
    event VIPPayback(address indexed beneficiary, uint amount);
    event WithdrawFunds(address indexed beneficiary, uint amount);

    constructor (uint _maxProfit) public {
        owner = msg.sender;
        secretSigner = owner;
        maxProfit = _maxProfit;
        croupierMap[owner] = true;
    }

    // Standard modifier on methods invokable only by contract owner.
    modifier onlyOwner {
        require (msg.sender == owner, "OnlyOwner methods called by non-owner.");
        _;
    }

    // Standard modifier on methods invokable only by contract owner.
    modifier onlyCroupier {
        bool isCroupier = croupierMap[msg.sender];
        require(isCroupier, "OnlyCroupier methods called by non-croupier.");
        _;
    }


    // Fallback function deliberately left empty. It's primary use case
    // is to top up the bank roll.
    function () external payable {

    }

    // Standard contract ownership transfer implementation,
    function approveNextOwner(address payable _nextOwner) external onlyOwner {
        require (_nextOwner != owner, "Cannot approve current owner.");
        nextOwner = _nextOwner;
    }

    function acceptNextOwner() external {
        require (msg.sender == nextOwner, "Can only accept preapproved new owner.");
        owner = nextOwner;
    }

    // See comment for "secretSigner" variable.
    function setSecretSigner(address newSecretSigner) external onlyOwner {
        secretSigner = newSecretSigner;
    }

    function getSecretSigner() external onlyOwner view returns(address){
        return secretSigner;
    }

    function addCroupier(address newCroupier) external onlyOwner {
        bool isCroupier = croupierMap[newCroupier];
        if (isCroupier == false) {
            croupierMap[newCroupier] = true;
        }
    }
    
    function deleteCroupier(address newCroupier) external onlyOwner {
        bool isCroupier = croupierMap[newCroupier];
        if (isCroupier == true) {
            croupierMap[newCroupier] = false;
        }
    }

    function setVIPLibraryAddress(address payable addr) external onlyOwner{
        VIPLibraryAddress = addr;
    }

    // Change max bet reward. Setting this to zero effectively disables betting.
    function setMaxProfit(uint _maxProfit) public onlyOwner {
        require (_maxProfit < MAX_AMOUNT, "maxProfit should be a sane number.");
        maxProfit = _maxProfit;
    }
    
    // Funds withdrawal to cover costs of AceDice operation.
    function withdrawFunds(address payable beneficiary, uint withdrawAmount) external onlyOwner {
        require (withdrawAmount <= address(this).balance, "Increase amount larger than balance.");
        if (beneficiary.send(withdrawAmount)){
            emit WithdrawFunds(beneficiary, withdrawAmount);
        }
    }

    function kill() external onlyOwner {
        // require (lockedInBets == 0, "All bets should be processed (settled or refunded) before self-destruct.");
        selfdestruct(owner);
    }

    function thisBalance() public view returns(uint) {
        return address(this).balance;
    }

    function payTodayReward(address payable to) external onlyOwner {
        CryptoTycoonsVIPLib vipLib = CryptoTycoonsVIPLib(VIPLibraryAddress);
        vipLib.payRankingReward(to);
    }

    function getRankingRewardSize() external view returns (uint128) {
        CryptoTycoonsVIPLib vipLib = CryptoTycoonsVIPLib(VIPLibraryAddress);
        return vipLib.getRankingRewardSize();
    }
        
    function handleVIPPaybackAndExp(CryptoTycoonsVIPLib vipLib, address payable gambler, uint amount) internal returns(uint vipPayback) {
        // CryptoTycoonsVIPLib vipLib = CryptoTycoonsVIPLib(VIPLibraryAddress);
        vipLib.addUserExp(gambler, amount);

        uint rate = vipLib.getVIPBounusRate(gambler);

        if (rate <= 0)
            return 0;

        vipPayback = amount * rate / 10000;
        if(vipPayback > 0){
            emit VIPPayback(gambler, vipPayback);
        }
    }

    function increaseRankingFund(CryptoTycoonsVIPLib vipLib, uint amount) internal{
        uint rankingFunds = uint128(amount * HOUSE_EDGE_PERCENT / 100 * RANK_FUNDS_PERCENT /100);
        // uint128 rankingRewardFee = uint128(amount * HOUSE_EDGE_PERCENT / 100 * 9 /100);
        VIPLibraryAddress.transfer(rankingFunds);
        vipLib.increaseRankingReward(rankingFunds);
    }

    function getMyAccuAmount() external view returns (uint){
        CryptoTycoonsVIPLib vipLib = CryptoTycoonsVIPLib(VIPLibraryAddress);
        return vipLib.getUserExp(msg.sender);
    }

    function getJackpotSize() external view returns (uint){
        CryptoTycoonsVIPLib vipLib = CryptoTycoonsVIPLib(VIPLibraryAddress);
        return vipLib.getJackpotSize();
    }
   
    function verifyCommit(uint commit, uint8 v, bytes32 r, bytes32 s) internal view {
        // Check that commit is valid - it has not expired and its signature is valid.
        // require (block.number <= commitLastBlock, "Commit has expired.");
        //bytes32 signatureHash = keccak256(abi.encodePacked(commitLastBlock, commit));
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes memory message = abi.encodePacked(commit);
        bytes32 messageHash = keccak256(abi.encodePacked(prefix, keccak256(message)));
        require (secretSigner == ecrecover(messageHash, v, r, s), "ECDSA signature is not valid.");
    }

    function calcHouseEdge(uint amount) public pure returns (uint houseEdge) {
        // 0.02
        houseEdge = amount * HOUSE_EDGE_PERCENT / 100;
        if (houseEdge < HOUSE_EDGE_MINIMUM_AMOUNT) {
            houseEdge = HOUSE_EDGE_MINIMUM_AMOUNT;
        }
    }

    function calcJackpotFee(uint amount) internal pure returns (uint jackpotFee) {
        // 0.001
        if (amount >= MIN_JACKPOT_BET) {
            jackpotFee = JACKPOT_FEE;
        }
    }

    function calcRankFundsFee(uint amount) internal pure returns (uint rankFundsFee) {
        // 0.01 * 0.07
        rankFundsFee = amount * RANK_FUNDS_PERCENT / 10000;
    }

    function calcInviterBenefit(uint amount) internal pure returns (uint invitationFee) {
        // 0.01 * 0.07
        invitationFee = amount * INVITER_BENEFIT_PERCENT / 10000;
    }

    function processBet(
        uint betMask, uint reveal, 
        uint8 v, bytes32 r, bytes32 s, address payable inviter) 
    external payable;
}
contract CardRPS is CryptoTycoonsConstants(10 ether)  {

    event FailedPayment(address indexed beneficiary, uint amount);
    event Payment(address indexed beneficiary, uint amount, uint playerNum1, uint playerNum2, uint npcNum1, uint npcNum2, uint betAmount, uint rouletteIndex);
    event JackpotPayment(address indexed beneficiary, uint amount, uint playerNum1, uint playerNum2, uint npcNum1, uint npcNum2, uint betAmount);
    
    struct RandomNumber{
        uint8 playerNum1;
        uint8 playerNum2;
        uint8 npcNum1;
        uint8 npcNum2;
        uint8 rouletteIndex;
    }

    function processBet(
        uint betMask, uint reveal, 
        uint8 v, bytes32 r, bytes32 s, address payable inviter) 
        external payable {

        address payable gambler = msg.sender;

        // Validate input data ranges.
        uint amount = msg.value;
        // require (modulo > 1 && modulo <= MAX_MODULO, "Modulo should be within range.");
        require (amount >= MIN_BET && amount <= MAX_AMOUNT, "Amount should be within range.");

        if (inviter != address(0)){
            require(gambler != inviter, "cannot invite myself");
        }
        uint commit = uint(keccak256(abi.encodePacked(reveal)));
        verifyCommit(commit, v, r, s);


        bytes32 entropy = keccak256(abi.encodePacked(reveal, blockhash(block.number)));

        processReward(gambler, amount, entropy, inviter);
    }

    function processReward(
        address payable gambler, uint amount, 
        bytes32 entropy, address payable inviter) internal{

        CryptoTycoonsVIPLib vipLib = CryptoTycoonsVIPLib(VIPLibraryAddress);
        // 1. increate vip exp
        uint _vipPayback = handleVIPPaybackAndExp(vipLib, msg.sender, amount);

        // The RNG - combine "reveal" and blockhash of placeBet using Keccak256. Miners
        // are not aware of "reveal" and cannot deduce it from "commit" (as Keccak256
        // preimage is intractable), and house is unable to alter the "reveal" after
        // placeBet have been mined (as Keccak256 collision finding is also intractable).
        uint seed = uint(entropy);
        // Do a roll by taking a modulo of entropy. Compute winning amount.

        RandomNumber memory randomNumber = RandomNumber(0, 0, 0, 0, 0);
        // uint mask = 2 ** 8;
        randomNumber.playerNum1 = uint8(seed % 3);
        seed = seed / 2 ** 8;
        
        randomNumber.playerNum2 = uint8(seed % 3);        
        seed = seed / 2 ** 8;

        randomNumber.npcNum1 = uint8(seed % 3);
        seed = seed / 2 ** 8;

        randomNumber.npcNum2 = uint8(seed % 3);
        seed = seed / 2 ** 8;

        randomNumber.rouletteIndex = uint8(seed % 12);
        seed = seed / 2 ** 8;

        uint jackpotFee = amount >= MIN_JACKPOT_BET ? JACKPOT_FEE : 0;

        uint houseEdge = amount * HOUSE_EDGE_PERCENT / 100;

        if (houseEdge < HOUSE_EDGE_MINIMUM_AMOUNT) {
            houseEdge = HOUSE_EDGE_MINIMUM_AMOUNT;
        }

        handleJackpotReward(vipLib, randomNumber, entropy, gambler, jackpotFee, amount);

        if(inviter != address(0)){
            // pay 10% of house edge to inviter
            inviter.transfer(amount * HOUSE_EDGE_PERCENT / 100 * 7 /100);
        }

        
        payBettingReward(gambler, randomNumber, amount, houseEdge, jackpotFee, _vipPayback);


        increaseRankingFund(vipLib, amount);
    }

    function handleJackpotReward(
        CryptoTycoonsVIPLib vipLib, 
        RandomNumber memory randomNumber, 
        bytes32 entropy,
        address payable gambler, uint jackpotFee, uint amount) private {

        uint jackpotWin = 0;
        // Roll for a jackpot (if eligible).
        if (amount >= MIN_JACKPOT_BET) {
                        
            VIPLibraryAddress.transfer(jackpotFee);
            vipLib.increaseJackpot(jackpotFee);

            // The second modulo, statistically independent from the "main" dice roll.
            // Effectively you are playing two games at once!
            // uint jackpotRng = (uint(entropy) / modulo) % JACKPOT_MODULO;

            // Bingo!
            if ((uint(entropy) / 100) % JACKPOT_MODULO == 0) {
                jackpotWin = vipLib.getJackpotSize();
                vipLib.payJackpotReward(gambler);
            }
        }
        
        // Log jackpot win.
        if (jackpotWin > 0) {
            emit JackpotPayment(gambler, 
                    jackpotWin, 
                    randomNumber.playerNum1, 
                    randomNumber.playerNum2, 
                    randomNumber.npcNum1, 
                    randomNumber.npcNum2, 
                    amount);
        }
    }

    function payBettingReward(
        address payable gambler, 
        RandomNumber memory randomNumber, 
        uint amount, uint houseEdge, uint jackpotFee,
        uint vipPayback) private {
        uint8 winValue = calculateWinValue(randomNumber); // 0 -> draw, 1 -> user win, 2 -> npc win

        uint winAmount = 0;

        if (winValue == 0) {
            // draw
            winAmount = amount - houseEdge - jackpotFee;
        } else if (winValue == 1) {
            // user win
            winAmount = (amount - houseEdge - jackpotFee) 
                            * getRouletteRate(randomNumber.rouletteIndex) / 10;
        } else {

        }

        winAmount += vipPayback;
        if(winAmount > 0){
            if (gambler.send(winAmount)) {
                emit Payment(gambler, winAmount, 
                    randomNumber.playerNum1, 
                    randomNumber.playerNum2, 
                    randomNumber.npcNum1, 
                    randomNumber.npcNum2,
                    amount, randomNumber.rouletteIndex);
            } else {
                emit FailedPayment(gambler, amount);
            }
        }else{
            emit Payment(gambler, winAmount, 
                randomNumber.playerNum1, 
                randomNumber.playerNum2, 
                randomNumber.npcNum1, 
                randomNumber.npcNum2,
                amount, randomNumber.rouletteIndex);
        }
        
        // Send the funds to gambler.
        // sendFunds(gambler, winAmount == 0 ? 1 wei : winAmount, winAmount, 
        //             randomNumber.playerNum1, 
        //             randomNumber.playerNum2, 
        //             randomNumber.npcNum1, 
        //             randomNumber.npcNum2, 
        //             amount,
        //             randomNumber.rouletteIndex);
    }

    function calculateWinValue(RandomNumber memory randomNumber) private pure returns (uint8){
        uint8 playerNum1 = randomNumber.playerNum1;
        uint8 playerNum2 = randomNumber.playerNum2;
        uint8 npcNum1 = randomNumber.npcNum1;
        uint8 npcNum2 = randomNumber.npcNum2;

        uint8 winValue = 0;
        if (playerNum1 == npcNum1){ // num 0 -> scissors, 1 -> rock, 2 -> papper
            if (playerNum2 == npcNum2){
                winValue = 0;
            } else if(playerNum2 == 0 && npcNum2 == 2){
                winValue = 1; // user win
            } else if(playerNum2 == 1 && npcNum2 == 0){
                winValue = 1; // user win
            } else if(playerNum2 == 2 && npcNum2 == 1){
                winValue = 1; // user win
            } else{
                winValue = 2; // npc win
            }
        } else if(playerNum1 == 0 && npcNum1 == 2){
            winValue = 1; // user win
        } else if(playerNum1 == 1 && npcNum1 == 0){
            winValue = 1; // user win
        } else if(playerNum1 == 2 && npcNum1 == 1){
            winValue = 1; // user win
        } else{
            winValue = 2; // npc win
        } 
        return winValue;
    }

    function getRouletteRate(uint index) private pure returns (uint8){
        uint8 rate = 11;
        if (index == 0){
            rate = 50;
        } else if(index== 1){
            rate = 11;
        } else if(index== 2){
            rate = 20;
        } else if(index== 3){
            rate = 15;
        } else if(index== 4){
            rate = 20;
        } else if(index== 5){
            rate = 11;
        } else if(index== 6){
            rate = 20;
        } else if(index== 7){
            rate = 15;
        } else if(index== 8){
            rate = 20;
        } else if(index== 9){
            rate = 11;
        } else if(index== 10){
            rate = 20;
        } else if(index== 11){
            rate = 15;
        }
        return rate;
    }
}