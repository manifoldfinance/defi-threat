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
contract HalfRoulette is CryptoTycoonsConstants(10 ether) {

    uint constant BASE_WIN_RATE = 100000;

    event Payment(address indexed gambler, uint amount, uint8 betMask, uint8 l, uint8 r, uint betAmount);
    event JackpotPayment(address indexed gambler, uint amount); 

    function processBet(
        uint betMask, uint reveal, 
        uint8 v, bytes32 r, bytes32 s, address payable inviter) 
        external payable {

        address payable gambler = msg.sender;

        // amount checked
        uint amount = msg.value;
        // require (modulo > 1 && modulo <= MAX_MODULO, "Modulo should be within range.");
        require (amount >= MIN_BET && amount <= MAX_AMOUNT, "Amount should be within range.");
        // allow bet check
        verifyBetMask(betMask);
        if (inviter != address(0)){
            require(gambler != inviter, "cannot invite myself");
        }

        uint commit = uint(keccak256(abi.encodePacked(reveal)));
        verifyCommit(commit, v, r, s);

        // house balance check
        uint winAmount = getWinAmount(betMask, amount);
        require(winAmount <= amount + maxProfit, "maxProfit limit violation.");
        require(winAmount <= address(this).balance, "Cannot afford to lose this bet.");

        // The RNG - combine "reveal" and blockhash of placeBet using Keccak256. Miners
        // are not aware of "reveal" and cannot deduce it from "commit" (as Keccak256
        // preimage is intractable), and house is unable to alter the "reveal" after
        // placeBet have been mined (as Keccak256 collision finding is also intractable).
        bytes32 entropy = keccak256(abi.encodePacked(reveal, blockhash(block.number)));

        
        uint payout = 0;
        payout += transferVIPContractFee(gambler, inviter, amount);
        // 5. roulette betting reward
        payout += processRoulette(gambler, betMask, entropy, amount);
        gambler.transfer(payout);
        // 7. jacpoet reward
        processJackpot(gambler, entropy, amount);
    }

    function transferVIPContractFee(
        address payable gambler, address payable inviter, uint amount) 
            internal returns(uint vipPayback) {
        uint jackpotFee = calcJackpotFee(amount);
        uint rankFundFee = calcRankFundsFee(amount);

        // 1. increate vip exp
        CryptoTycoonsVIPLib vipLib = CryptoTycoonsVIPLib(VIPLibraryAddress);
        vipPayback = handleVIPPaybackAndExp(vipLib, gambler, amount);

        // 2. process today's ranking fee
        VIPLibraryAddress.transfer(rankFundFee + jackpotFee);
        vipLib.increaseRankingReward(rankFundFee);
        if (jackpotFee > 0) {
            vipLib.increaseJackpot(jackpotFee);
        }

        // 4. inviter profit
        if(inviter != address(0)){
            // pay 7% of house edge to inviter
            inviter.transfer(amount * HOUSE_EDGE_PERCENT / 100 * 7 /100);
        }
    }


    function processJackpot(address payable gambler, bytes32 entropy, uint amount) internal returns (uint benefitAmount) {
        if (isJackpot(entropy, amount)) {
            CryptoTycoonsVIPLib vipLib = CryptoTycoonsVIPLib(VIPLibraryAddress);
            uint jackpotSize = vipLib.getJackpotSize();
            vipLib.payJackpotReward(gambler);
            benefitAmount = jackpotSize;
            emit JackpotPayment(gambler, benefitAmount);
        }
    }

    function processRoulette(address gambler, uint betMask, bytes32 entropy, uint amount) internal returns (uint benefitAmount) {
        uint winAmount = getWinAmount(betMask, amount);

        (bool isWin, uint l, uint r) = calcBetResult(betMask, entropy);
        benefitAmount = isWin ? winAmount : 0;

        emit Payment(gambler, benefitAmount, uint8(betMask), uint8(l), uint8(r), amount);
    }

    function verifyBetMask(uint betMask) public pure {
        bool verify;
        assembly {
            switch betMask
            case 1 /* ODD */{verify := 1}
            case 2 /* EVEN */{verify := 1}
            case 4 /* LEFT */{verify := 1}
            case 8 /* RIGHT */{verify := 1}
            case 5 /* ODD | LEFT */{verify := 1}
            case 9 /* ODD | RIGHT */{verify := 1}
            case 6 /* EVEN | LEFT */{verify := 1}
            case 10 /* EVEN | RIGHT */{verify := 1}
            case 16 /* EQUAL */{verify := 1}
        }
        require(verify, "invalid betMask");
    }

    function getWinRate(uint betMask) public pure returns (uint rate) {
        // assembly 안에서는 constant 사용 불가
        uint ODD_EVEN_RATE = 50000;
        uint LEFT_RIGHT_RATE = 45833;
        uint MIX_ODD_RATE = 25000;
        uint MIX_EVEN_RATE = 20833;
        uint EQUAL_RATE = 8333;
        assembly {
            switch betMask
            case 1 /* ODD */{rate := ODD_EVEN_RATE}
            case 2 /* EVEN */{rate := ODD_EVEN_RATE}
            case 4 /* LEFT */{rate := LEFT_RIGHT_RATE}
            case 8 /* RIGHT */{rate := LEFT_RIGHT_RATE}
            case 5 /* ODD | LEFT */{rate := MIX_ODD_RATE}
            case 9 /* ODD | RIGHT */{rate := MIX_ODD_RATE}
            case 6 /* EVEN | LEFT */{rate := MIX_EVEN_RATE}
            case 10 /* EVEN | RIGHT */{rate := MIX_EVEN_RATE}
            case 16 /* EQUAL */{rate := EQUAL_RATE}
        }
    }

    function getWinAmount(uint betMask, uint amount) public pure returns (uint) {
        uint houseEdge = calcHouseEdge(amount);
        uint jackpotFee = calcJackpotFee(amount);
        uint betAmount = amount - houseEdge - jackpotFee;
        uint rate = getWinRate(betMask);
        return betAmount * BASE_WIN_RATE / rate;
    }

    function calcBetResult(uint betMask, bytes32 entropy) public pure returns (bool isWin, uint l, uint r)  {
        uint v = uint(entropy);
        l = (v % 12) + 1;
        r = ((v >> 4) % 12) + 1;
        uint mask = getResultMask(l, r);
        isWin = (betMask & mask) == betMask;
    }

    function getResultMask(uint l, uint r) public pure returns (uint mask) {
        uint v1 = (l + r) % 2;
        if (v1 == 0) {
            mask = mask | 2;
        } else {
            mask = mask | 1;
        }
        if (l == r) {
            mask = mask | 16;
        } else if (l > r) {
            mask = mask | 4;
        } else {
            mask = mask | 8;
        }
        return mask;
    }

    function isJackpot(bytes32 entropy, uint amount) public pure returns (bool jackpot) {
        return amount >= MIN_JACKPOT_BET && (uint(entropy) % 1000) == 0;
    }
}