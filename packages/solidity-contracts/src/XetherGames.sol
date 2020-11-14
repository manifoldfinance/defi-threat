/**
 * Source Code first verified at https://etherscan.io on Friday, April 5, 2019
 (UTC) */

pragma solidity 0.5.6;

// * xether.io - is a gambling ecosystem, which makes a difference by caring about its users.
// It’s our passion for perfection, as well as finding and creating neat solutions,
// that keeps us driven towards our goals.
//
// * Uses hybrid commit-reveal + block hash random number generation that is immune
//   to tampering by players, house and miners. Apart from being fully transparent,
//   this also allows arbitrarily high bets.


interface xEtherTokensContractInterface {
  function ecosystemDividends() external payable;
}

contract XetherGames {
    uint256 constant HOUSE_EDGE_MINIMUM_AMOUNT = 0.0003 ether;
    uint256 constant MIN_JACKPOT_BET = 0.1 ether;
    uint16 constant JACKPOT_MODULO = 1000;
    uint256 constant JACKPOT_FEE = 0.001 ether;
    uint256 constant MIN_BET = 0.01 ether;
    uint256 constant MAX_AMOUNT = 300000 ether;
    uint8 constant MAX_MODULO = 100;
    uint8 constant MAX_MASK_MODULO = 40;
    uint256 constant MAX_BET_MASK = 2 ** uint256(MAX_MASK_MODULO);
    uint8 constant BET_EXPIRATION_BLOCKS = 250;
    uint256 public DIVIDENDS_LIMIT = 1 ether;
    uint16 constant PERCENTAGES_BASE = 1000;
    address constant DUMMY_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    uint16 public luckyNumber = 777;

    uint8 public DIVIDENDS_PERCENT = 10; // 1% example: 15 will be 1.5%
    uint8 public ADVERTISE_PERCENT = 0; // 0%
    uint8 public HOUSE_EDGE_PERCENT = 10; // 1%

    uint8 constant ROULETTE_ID = 37;
    uint8 constant ROULETTE_STAKES_LIMIT = 36;
    uint8 public rouletteSkipComission = 1;
    uint256 public rouletteTableLimit = 1.8 ether;
    uint8 public ROULETTE_PERCENT = 10;

    uint8 constant PLINKO_BYTES = 16;
    uint256 constant PLINKO_ID = 2 ** uint256(PLINKO_BYTES);
    uint16[17] PLINKO1Ratios = [1000,800,600,300,200,130,100,80,50,80,100,130,200,300,600,800,1000];
    uint16[17] PLINKO2Ratios = [2000,700,500,300,200,110,100,60,100,60,100,110,200,300,500,700,2000];
    uint16[17] PLINKO3Ratios = [5000,800,300,200,140,120,110,100,40,100,110,120,140,200,300,800,5000];
    uint8 public plinkoSkipComission = 2;
    uint8 public PLINKO_PERCENT = HOUSE_EDGE_PERCENT;

    uint16 constant SLOTS_ID = 999;
    uint8 constant SLOTS_COUNT = 5;
    uint16[] SLOTSWinsRatios = [0, 50, 120, 200, 1500];
    uint32[] SLOTSWildRatios = [0, 110, 250, 400, 3000, 10000];

    xEtherTokensContractInterface public xEtherTokensContract;

    address payable public owner;
    address payable private nextOwner;

    uint256 public totalDividends = 0;
    uint256 public totalAdvertise = 0;

    uint256 public maxProfit = 5 ether;
    uint256 public maxProfitPlinko = 10 ether;
    uint256 public maxProfitRoulette = 3.6 ether;

    address public secretSigner;
    address public moderator;
    address public croupier;
    uint128 public jackpotSize;
    uint128 public lockedInBets;

    struct Bet {
        uint256 amount;
        uint128 locked;
        uint32 modulo;
        uint8 rollUnder;
        uint40 placeBlockNumber;
        uint256 clientSeed;
        uint40 mask;
        address payable gambler;
    }

    struct BetRoulette {
      uint256 totalBetAmount;
      uint128 locked;
      mapping (uint8 => uint256) amount;
      mapping (uint8 => uint8) rollUnder;
      uint40 placeBlockNumber;
      uint256 clientSeed;
      mapping (uint8 => uint40) mask;
      address payable gambler;
      uint8 betsCount;
    }

    mapping (uint => Bet) bets;
    mapping (uint => BetRoulette) betsRoulette;
    mapping (address => uint256) public bonusProgrammAccumulated;

    event FailedPayment(address beneficiary, uint commit, uint amount, string paymentType);
    event Payment(address beneficiary, uint commit, uint amount, string paymentType);
    event JackpotPayment(address indexed beneficiary, uint commit, uint amount);

    event PayDividendsSuccess(uint time, uint amount);
    event PayDividendsFailed(uint time, uint amount);

    event Commit(uint commit, uint clietSeed, uint amount);

    constructor () public {
        owner = msg.sender;
        secretSigner = DUMMY_ADDRESS;
        croupier = DUMMY_ADDRESS;
    }

    modifier onlyOwner {
        require (msg.sender == owner, "OnlyOwner methods called by non-owner.");
        _;
    }

    modifier onlyModeration {
        require (msg.sender == owner || msg.sender == moderator, "Moderation methods called by non-moderator.");
        _;
    }

    modifier onlyCroupier {
        require (msg.sender == croupier, "OnlyCroupier methods called by non-croupier.");
        _;
    }

    function approveNextOwner(address payable _nextOwner) external onlyOwner {
        require (_nextOwner != owner, "Cannot approve current owner.");
        nextOwner = _nextOwner;
    }

    function acceptNextOwner() external {
        require (msg.sender == nextOwner, "Can only accept preapproved new owner.");
        owner = nextOwner;
    }

    function () external payable {
    }

    function setNewPercents(
      uint8 newHouseEdgePercent,
      uint8 newDividendsPercent,
      uint8 newAdvertPercent
    ) external onlyOwner {
        // We guarantee that dividends will be minimum 0.5%
        require(newDividendsPercent >= 5);
        // Total percentages not greater then 3%
        require(newHouseEdgePercent + newDividendsPercent + newAdvertPercent <= 30);

        HOUSE_EDGE_PERCENT = newHouseEdgePercent;
        ADVERTISE_PERCENT = newAdvertPercent;
        DIVIDENDS_PERCENT = newDividendsPercent;
    }

    function setNewRoulettePercents(uint8 newRoulettePercent) external onlyModeration {
        require(0 <= newRoulettePercent && newRoulettePercent <= 10);
        ROULETTE_PERCENT = newRoulettePercent;
    }

    function setNewPlinkoPercents(uint8 newPlinkoPercent) external onlyModeration {
        require(0 <= newPlinkoPercent && newPlinkoPercent <= 10);
        PLINKO_PERCENT = newPlinkoPercent;
    }

    function setXEtherContract(address payable xEtherContract) external onlyOwner{
        xEtherTokensContract = xEtherTokensContractInterface(xEtherContract);
    }

    function setAddresses(address newCroupier, address newSecretSigner, address newModerator) external onlyOwner {
        secretSigner = newSecretSigner;
        croupier = newCroupier;
        moderator = newModerator;
    }

    function changeDividendsLimit(uint _newDividendsLimit) public onlyModeration {
        DIVIDENDS_LIMIT = _newDividendsLimit;
    }

    function setMaxProfit(uint _maxProfit) public onlyModeration {
        require (_maxProfit < MAX_AMOUNT, "maxProfit cant be great then top limit.");
        maxProfit = _maxProfit;
    }

    function setMaxProfitPlinko(uint _maxProfitPlinko) public onlyModeration {
        require (_maxProfitPlinko < MAX_AMOUNT, "maxProfitPlinko cant be great then top limit.");
        maxProfitPlinko = _maxProfitPlinko;
    }

    function setMaxProfitRoulette(uint _maxProfitRoulette) public onlyModeration {
        require (_maxProfitRoulette < MAX_AMOUNT, "maxProfitRoulette cant be great then top limit.");
        maxProfitRoulette = _maxProfitRoulette;
    }

    function setRouletteTableLimit(uint _newRouletteTableLimit) public onlyModeration {
        require (_newRouletteTableLimit < MAX_AMOUNT, "roultteTableLimit cant be great then top limit.");
        rouletteTableLimit = _newRouletteTableLimit;
    }

    function setComissionState(uint8 _newRouletteState, uint8 _newPlinkoState) public onlyModeration {
        rouletteSkipComission = _newRouletteState;
        plinkoSkipComission = _newPlinkoState;
    }

    function releaseLockedInBetAmount() external onlyModeration {
        lockedInBets = 0;
    }

    function increaseJackpot(uint increaseAmount) external onlyModeration {
        require (increaseAmount <= address(this).balance, "Increase amount larger than balance.");
        require (jackpotSize + lockedInBets + increaseAmount <= address(this).balance, "Not enough funds.");
        jackpotSize += uint128(increaseAmount);
    }

    function withdrawFunds(address payable beneficiary, uint withdrawAmount) external onlyOwner {
        require (withdrawAmount <= address(this).balance, "Increase amount larger than balance.");
        require (jackpotSize + lockedInBets + withdrawAmount <= address(this).balance, "Not enough funds.");
        sendFunds(beneficiary, withdrawAmount, withdrawAmount, 0, 'withdraw');
    }

    function withdrawAdvertiseFunds(address payable beneficiary, uint withdrawAmount) external onlyOwner {
        require (withdrawAmount <= totalAdvertise, "Increase amount larger than balance.");
        totalAdvertise -= withdrawAmount;
        sendFunds(beneficiary, withdrawAmount, withdrawAmount, 0, 'withdraw');
    }

    function getBonusProgrammLevel(address gambler) public view returns (uint8 discount) {
      uint accumulated = bonusProgrammAccumulated[gambler];
      discount = 0;

      if (accumulated >= 20 ether && accumulated < 100 ether) {
        discount = 1;
      } else if (accumulated >= 100 ether && accumulated < 500 ether) {
        discount = 2;
      } else if (accumulated >= 500 ether && accumulated < 1000 ether) {
        discount = 3;
      } else if (accumulated >= 1000 ether && accumulated < 5000 ether) {
        discount = 4;
      } else if (accumulated >= 5000 ether) {
        discount = 5;
      }
    }

    function kill() external onlyOwner {
        require (lockedInBets == 0, "All bets should be processed (settled or refunded) before self-destruct.");
        selfdestruct(owner);
    }

    function sendDividends() public payable {
        if (address(xEtherTokensContract) != address(0)) {
            uint tmpDividends = totalDividends;
            xEtherTokensContract.ecosystemDividends.value(tmpDividends)();
            totalDividends = 0;

            emit PayDividendsSuccess(now, tmpDividends);
        }
    }

    function placeBet(
        uint betMask,
        uint32 modulo,
        uint commitLastBlock,
        uint commit, uint256 clientSeed,
        bytes32 r, bytes32 s
    ) external payable {
        Bet storage bet = bets[commit];
        require (bet.gambler == address(0), "Bet should be in a 'clean' state.");

        uint amount = msg.value;
        if (modulo > MAX_MODULO) {
            require (modulo == PLINKO_ID || modulo == SLOTS_ID, "Modulo should be within range.");
        } else {
            require (modulo > 1 && modulo <= MAX_MODULO, "Modulo should be within range.");
        }

        require (amount >= MIN_BET && amount <= MAX_AMOUNT, "Amount should be within range.");
        require (betMask > 0 && betMask < MAX_BET_MASK, "Mask should be within range.");
        require (block.number <= commitLastBlock, "Commit has expired.");
        require (
          secretSigner == ecrecover(keccak256(abi.encodePacked(uint40(commitLastBlock), commit)), 27, r, s) ||
          secretSigner == ecrecover(keccak256(abi.encodePacked(uint40(commitLastBlock), commit)), 28, r, s),
          "ECDSA signature is not valid."
        );

        if (totalDividends >= DIVIDENDS_LIMIT) {
          sendDividends();
        }

        uint rollUnder;
        uint mask;

        (mask, rollUnder, bet.locked) = prepareBet(betMask, modulo, amount, commit, clientSeed, msg.sender);

        bet.amount = amount;
        bet.modulo = uint32(modulo);
        bet.rollUnder = uint8(rollUnder);
        bet.placeBlockNumber = uint40(block.number);
        bet.mask = uint40(mask);
        bet.clientSeed = clientSeed;
        bet.gambler = msg.sender;
    }

    function placeBetRoulette(
        uint[] calldata betMask,
        uint[] calldata betAmount,
        uint commitLastBlock,
        uint commit, uint256 clientSeed,
        bytes32 r, bytes32 s
    ) external payable {
        BetRoulette storage betRoulette = betsRoulette[commit];

        require(msg.value <= rouletteTableLimit, "Bets sum must be LTE table limit");
        betRoulette.betsCount = uint8(betMask.length);

        require (betRoulette.gambler == address(0), "Bet should be in a 'clean' state.");
        require (block.number <= commitLastBlock, "Commit has expired.");
        require (
          secretSigner == ecrecover(keccak256(abi.encodePacked(uint40(commitLastBlock), commit)), 27, r, s) ||
          secretSigner == ecrecover(keccak256(abi.encodePacked(uint40(commitLastBlock), commit)), 28, r, s),
          "ECDSA signature is not valid."
        );

        if (totalDividends >= DIVIDENDS_LIMIT) {
          sendDividends();
        }

        (betRoulette.betsCount, betRoulette.locked) = placeBetRouletteProcess(commit, betMask, betAmount);

        lockedInBets += betRoulette.locked;
        require (lockedInBets <= address(this).balance, "Cannot afford to lose this bet.");

        if (rouletteSkipComission != 1) {
          bonusProgrammAccumulated[msg.sender] += msg.value;
        }

        betRoulette.totalBetAmount = msg.value;
        betRoulette.placeBlockNumber = uint40(block.number);
        betRoulette.clientSeed = clientSeed;
        betRoulette.gambler = msg.sender;

        jackpotSize += msg.value >= MIN_JACKPOT_BET ? uint128(JACKPOT_FEE) : 0;

        emit Commit(commit, clientSeed, msg.value);
    }

    function placeBetRouletteProcess (
      uint commit, uint[] memory betMask, uint[] memory betAmount
    ) internal returns (uint8 betsCount, uint128 locked) {
      BetRoulette storage betRoulette = betsRoulette[commit];
      betsCount = 0;
      uint totalBetAmount = 0;
      uint8 addBets = betRoulette.betsCount;
      uint8 tmpBetCount = betRoulette.betsCount - 1;
      uint128 curLocked = 0;
      uint128 tmpLocked = 0;
      bool numIsAlredyLocked = false;
      uint8 bonuses = getBonusProgrammLevel(betRoulette.gambler);

      while (0 <= tmpBetCount) {
        require (betMask[tmpBetCount] > 0 && betMask[tmpBetCount] < MAX_BET_MASK, "Mask should be within range.");

        // Check track sectors bets
        if (betMask[tmpBetCount] == 38721851401) {  // Jeu 0
          require (betAmount[tmpBetCount] >= MIN_BET * 4 && betAmount[tmpBetCount] <= MAX_AMOUNT, "Amount should be within range.");

          totalBetAmount += betAmount[tmpBetCount];
          require (totalBetAmount <= msg.value, "Total bets amount should be LTE amount");

          // 12/15
          (betRoulette.mask[tmpBetCount], betRoulette.rollUnder[tmpBetCount], curLocked) = prepareBetRoulette(36864, betAmount[tmpBetCount] / 4, bonuses);
          betRoulette.amount[tmpBetCount] = betAmount[tmpBetCount] / 4;

          // 35/32
          (betRoulette.mask[addBets], betRoulette.rollUnder[addBets], tmpLocked) = prepareBetRoulette(38654705664, betAmount[tmpBetCount] / 4, bonuses);
          betRoulette.amount[addBets] = betAmount[tmpBetCount] / 4;
          curLocked = (tmpLocked > curLocked) ? tmpLocked : curLocked;

          // 3/0
          addBets += 1;
          (betRoulette.mask[addBets], betRoulette.rollUnder[addBets], tmpLocked) = prepareBetRoulette(9, betAmount[tmpBetCount] / 4, bonuses);
          betRoulette.amount[addBets] = betAmount[tmpBetCount] / 4;
          curLocked = (tmpLocked > curLocked) ? tmpLocked : curLocked;

          // 26
          addBets += 1;
          (betRoulette.mask[addBets], betRoulette.rollUnder[addBets], tmpLocked) = prepareBetRoulette(67108864, betAmount[tmpBetCount] / 4, bonuses);
          betRoulette.amount[addBets] = betAmount[tmpBetCount] / 4;
          curLocked = (tmpLocked > curLocked) ? tmpLocked : curLocked;

          locked += curLocked;

          addBets += 1;
          betsCount += 4;
        } else if (betMask[tmpBetCount] == 39567790237) { // Voisins mask
          require (betAmount[tmpBetCount] >= MIN_BET * 9 && betAmount[tmpBetCount] <= MAX_AMOUNT, "Amount should be within range.");

          totalBetAmount += betAmount[tmpBetCount];
          require (totalBetAmount <= msg.value, "Total bets amount should be LTE amount");

          // 4/7
          (betRoulette.mask[tmpBetCount], betRoulette.rollUnder[tmpBetCount], curLocked) = prepareBetRoulette(
            144, betAmount[tmpBetCount] / 9, bonuses);
          betRoulette.amount[tmpBetCount] = betAmount[tmpBetCount] / 9;

          // 12/15
          (betRoulette.mask[addBets], betRoulette.rollUnder[addBets], tmpLocked) = prepareBetRoulette(
            36864, betAmount[tmpBetCount] / 9, bonuses);
          betRoulette.amount[addBets] = betAmount[tmpBetCount] / 9;
          curLocked = (tmpLocked > curLocked) ? tmpLocked : curLocked;

          // 18/21
          addBets += 1;
          (betRoulette.mask[addBets], betRoulette.rollUnder[addBets], tmpLocked) = prepareBetRoulette(
            2359296, betAmount[tmpBetCount] / 9, bonuses);
          betRoulette.amount[addBets] = betAmount[tmpBetCount] / 9;
          curLocked = (tmpLocked > curLocked) ? tmpLocked : curLocked;

          // 19/22
          addBets += 1;
          (betRoulette.mask[addBets], betRoulette.rollUnder[addBets], tmpLocked) = prepareBetRoulette(
            4718592, betAmount[tmpBetCount] / 9, bonuses);
          betRoulette.amount[addBets] = betAmount[tmpBetCount] / 9;
          curLocked = (tmpLocked > curLocked) ? tmpLocked : curLocked;

          // 35/32
          addBets += 1;
          (betRoulette.mask[addBets], betRoulette.rollUnder[addBets], tmpLocked) = prepareBetRoulette(
            38654705664, betAmount[tmpBetCount] / 9, bonuses);
          betRoulette.amount[addBets] = betAmount[tmpBetCount] / 9;
          curLocked = (tmpLocked > curLocked) ? tmpLocked : curLocked;

          // 25/26/28/29 (x2)
          addBets += 1;
          (betRoulette.mask[addBets], betRoulette.rollUnder[addBets], tmpLocked) = prepareBetRoulette(
            905969664, betAmount[tmpBetCount] * 2 / 9, bonuses);
          betRoulette.amount[addBets] = betAmount[tmpBetCount] * 2 / 9;
          curLocked = (tmpLocked > curLocked) ? tmpLocked : curLocked;

          // 0/2/3 (x2)
          addBets += 1;
          (betRoulette.mask[addBets], betRoulette.rollUnder[addBets], tmpLocked) = prepareBetRoulette(
            13, betAmount[tmpBetCount] * 2 / 9, bonuses);
          betRoulette.amount[addBets] = betAmount[tmpBetCount] * 2 / 9;
          curLocked = (tmpLocked > curLocked) ? tmpLocked : curLocked;

          locked += curLocked;

          addBets += 1;
          betsCount += 7;
        } else if (betMask[tmpBetCount] == 19328549442) { // Orphelins mask
          require (betAmount[tmpBetCount] >= MIN_BET * 5 && betAmount[tmpBetCount] <= MAX_AMOUNT, "Amount should be within range.");

          totalBetAmount += betAmount[tmpBetCount];
          require (totalBetAmount <= msg.value, "Total bets amount should be LTE amount");

          // 14/17
          (betRoulette.mask[addBets], betRoulette.rollUnder[addBets], curLocked) = prepareBetRoulette(
            147456, betAmount[tmpBetCount] / 5, bonuses);
          betRoulette.amount[addBets] = betAmount[tmpBetCount] / 5;

          // 17/20
          addBets += 1;
          (betRoulette.mask[addBets], betRoulette.rollUnder[addBets], tmpLocked) = prepareBetRoulette(
            1179648, betAmount[tmpBetCount] / 5, bonuses);
          betRoulette.amount[addBets] = betAmount[tmpBetCount] / 5;
          curLocked += tmpLocked;

          // 6/9
          (betRoulette.mask[tmpBetCount], betRoulette.rollUnder[tmpBetCount], tmpLocked) = prepareBetRoulette(
            576, betAmount[tmpBetCount] / 5, bonuses);
          betRoulette.amount[tmpBetCount] = betAmount[tmpBetCount] / 5;
          curLocked = (tmpLocked > curLocked) ? tmpLocked : curLocked;

          // 31/34
          addBets += 1;
          (betRoulette.mask[addBets], betRoulette.rollUnder[addBets], tmpLocked) = prepareBetRoulette(
            19327352832, betAmount[tmpBetCount] / 5, bonuses);
          betRoulette.amount[addBets] = betAmount[tmpBetCount] / 5;
          curLocked = (tmpLocked > curLocked) ? tmpLocked : curLocked;

          // 1
          addBets += 1;
          (betRoulette.mask[addBets], betRoulette.rollUnder[addBets], tmpLocked) = prepareBetRoulette(
            2, betAmount[tmpBetCount] / 5, bonuses);
          betRoulette.amount[addBets] = betAmount[tmpBetCount] / 5;
          curLocked = (tmpLocked > curLocked) ? tmpLocked : curLocked;

          locked += curLocked;

          addBets += 1;
          betsCount += 5;
        } else if (betMask[tmpBetCount] == 78542613792) { // Tier mask
          require (betAmount[tmpBetCount] >= MIN_BET * 6 && betAmount[tmpBetCount] <= MAX_AMOUNT, "Amount should be within range.");

          totalBetAmount += betAmount[tmpBetCount];
          require (totalBetAmount <= msg.value, "Total bets amount should be LTE amount");

          // 5/8
          (betRoulette.mask[tmpBetCount], betRoulette.rollUnder[tmpBetCount], curLocked) = prepareBetRoulette(
            288, betAmount[tmpBetCount] / 6, bonuses);
          betRoulette.amount[tmpBetCount] = betAmount[tmpBetCount] / 6;

          // 10/11
          (betRoulette.mask[addBets], betRoulette.rollUnder[addBets], tmpLocked) = prepareBetRoulette(
            3072, betAmount[tmpBetCount] / 6, bonuses);
          betRoulette.amount[addBets] = betAmount[tmpBetCount] / 6;
          curLocked = (tmpLocked > curLocked) ? tmpLocked : curLocked;

          // 13/16
          addBets += 1;
          (betRoulette.mask[addBets], betRoulette.rollUnder[addBets], tmpLocked) = prepareBetRoulette(
            73728, betAmount[tmpBetCount] / 6, bonuses);
          betRoulette.amount[addBets] = betAmount[tmpBetCount] / 6;
          curLocked = (tmpLocked > curLocked) ? tmpLocked : curLocked;

          // 23/24
          addBets += 1;
          (betRoulette.mask[addBets], betRoulette.rollUnder[addBets], tmpLocked) = prepareBetRoulette(
            25165824, betAmount[tmpBetCount] / 6, bonuses);
          betRoulette.amount[addBets] = betAmount[tmpBetCount] / 6;
          curLocked = (tmpLocked > curLocked) ? tmpLocked : curLocked;

          // 27/30
          addBets += 1;
          (betRoulette.mask[addBets], betRoulette.rollUnder[addBets], tmpLocked) = prepareBetRoulette(
            1207959552, betAmount[tmpBetCount] / 6, bonuses);
          betRoulette.amount[addBets] = betAmount[tmpBetCount] / 6;
          curLocked = (tmpLocked > curLocked) ? tmpLocked : curLocked;

          // 33/36
          addBets += 1;
          (betRoulette.mask[addBets], betRoulette.rollUnder[addBets], tmpLocked) = prepareBetRoulette(
            77309411328, betAmount[tmpBetCount] / 6, bonuses);
          betRoulette.amount[addBets] = betAmount[tmpBetCount] / 6;
          curLocked = (tmpLocked > curLocked) ? tmpLocked : curLocked;

          locked += curLocked;

          addBets += 1;
          betsCount += 6;
        } else {
          require (betAmount[tmpBetCount] >= MIN_BET && betAmount[tmpBetCount] <= MAX_AMOUNT, "Amount should be within range.");
          totalBetAmount += betAmount[tmpBetCount];
          require (totalBetAmount <= msg.value, "Total bets amount should be LTE amount");
          (betRoulette.mask[tmpBetCount], betRoulette.rollUnder[tmpBetCount], tmpLocked) = prepareBetRoulette(
            betMask[tmpBetCount], betAmount[tmpBetCount], bonuses);

          if (uint8(((betRoulette.mask[tmpBetCount] * POPCNT_MULT) & POPCNT_MASK) % POPCNT_MODULO) != 1) {
            locked += tmpLocked;
          } else {
            if (!numIsAlredyLocked) {
              numIsAlredyLocked = true;
              locked += tmpLocked;
            }
          }

          betRoulette.amount[tmpBetCount] = betAmount[tmpBetCount];
          betsCount += 1;
        }

        if (tmpBetCount == 0) break;
        tmpBetCount -= 1;
      }
    }

    function prepareBet(uint betMask, uint32 modulo, uint amount, uint commit, uint clientSeed, address gambler) private returns (uint mask, uint8 rollUnder, uint128 possibleWinAmount) {
        if (modulo <= MAX_MASK_MODULO) {
            rollUnder = uint8(((betMask * POPCNT_MULT) & POPCNT_MASK) % POPCNT_MODULO);
            mask = betMask;
        } else {
            require (betMask > 0 && betMask <= modulo, "High modulo range, betMask larger than modulo.");
            rollUnder = uint8(betMask);
        }

        uint jackpotFee;

        (possibleWinAmount, jackpotFee) = getDiceWinAmount(amount, modulo, rollUnder, gambler, true);
        require (possibleWinAmount <= amount + maxProfitPlinko, "maxProfitPlinko limit violation.");

        bonusProgrammAccumulated[gambler] += amount;
        lockedInBets += uint128(possibleWinAmount);
        jackpotSize += uint128(jackpotFee);

        require (jackpotSize + lockedInBets <= address(this).balance, "Cannot afford to lose this bet.");

        emit Commit(commit, clientSeed, amount);
    }

    function prepareBetRoulette(uint betMask, uint amount, uint8 bonuses) private returns (uint40 retMask, uint8 retRollUnder, uint128 possibleWinAmount) {
        uint8 rollUnder = uint8(((betMask * POPCNT_MULT) & POPCNT_MASK) % POPCNT_MODULO);
        uint mask = betMask;

        possibleWinAmount = getRouletteWinAmount(amount, 36, rollUnder, bonuses, true);
        require (possibleWinAmount <= amount + maxProfitRoulette, "maxProfitRoulette limit violation.");

        retMask = uint40(mask);
        retRollUnder = rollUnder;
    }

    function settleBet(uint reveal) external onlyCroupier {
        uint commit = uint(keccak256(abi.encodePacked(reveal)));

        Bet storage bet = bets[commit];
        uint placeBlockNumber = bet.placeBlockNumber;

        require (block.number > placeBlockNumber, "settleBet in the same block as placeBet, or before.");
        require (block.number <= placeBlockNumber + BET_EXPIRATION_BLOCKS, "Can't be queried by EVM.");

        if (bet.modulo == PLINKO_ID) {
            settleBetPlinko(bet, reveal);
        } else if (bet.modulo == SLOTS_ID) {
            settleBetSlots(bet, reveal);
        } else {
            settleBetCommon(bet, reveal);
        }

    }

    function settleBetRoulette(uint reveal) external onlyCroupier {
        uint commit = uint(keccak256(abi.encodePacked(reveal)));

        BetRoulette storage betRoulette = betsRoulette[commit];
        uint placeBlockNumber = betRoulette.placeBlockNumber;

        require (betRoulette.totalBetAmount > 0, "Bet already processed");
        require (block.number > placeBlockNumber, "settleBet in the same block as placeBet, or before.");
        require (block.number <= placeBlockNumber + BET_EXPIRATION_BLOCKS, "Can't be queried by EVM.");

        settleBetRoulette(betRoulette, reveal);
    }

    // Common bets
    function settleBetCommon(Bet storage bet, uint reveal) private {
        uint amount = bet.amount;
        uint8 rollUnder = bet.rollUnder;

        require (amount != 0, "Bet should be in an 'active' state");

        bet.amount = 0;
        bytes32 entropy = keccak256(abi.encodePacked(reveal, bet.clientSeed));
        uint dice = uint(entropy) % bet.modulo;
        uint diceWinAmount;
        uint _jackpotFee;
        uint diceWin;

        if (bet.modulo <= MAX_MASK_MODULO) {
            if ((2 ** dice) & bet.mask != 0) {
                (diceWinAmount, _jackpotFee) = getDiceWinAmount(amount, bet.modulo, rollUnder, bet.gambler, false);
                diceWin = diceWinAmount;
            }
        } else {
            if (dice < rollUnder) {
                (diceWinAmount, _jackpotFee) = getDiceWinAmount(amount, bet.modulo, rollUnder, bet.gambler, false);
                diceWin = diceWinAmount;
            }
        }

        lockedInBets -= uint128(bet.locked);

        uint jackpotWin = checkJackPotWin(entropy, amount, bet.modulo);
        if (jackpotWin > 0) {
            emit JackpotPayment(bet.gambler, uint(keccak256(abi.encodePacked(reveal))), jackpotWin);
        }

        sendFunds(
          bet.gambler,
          diceWin + jackpotWin == 0 ? 1 wei : diceWin + jackpotWin,
          diceWin,
          uint(keccak256(abi.encodePacked(reveal))),
          'payment'
        );
    }

    // Plinko
    function settleBetPlinko(Bet storage bet, uint reveal) private {
        uint amount = bet.amount;
        uint rollUnder = bet.rollUnder;

        require (amount != 0, "Bet should be in an 'active' state");

        bet.amount = 0;
        bytes32 entropy = keccak256(abi.encodePacked(reveal, bet.clientSeed));
        uint dice = uint(entropy) % bet.modulo;
        uint diceWin = _plinkoGetDiceWin(dice, amount, rollUnder, bet.gambler);

        lockedInBets -= uint128(bet.locked);

        uint jackpotWin = checkJackPotWin(entropy, amount, bet.modulo);
        if (jackpotWin > 0) {
            emit JackpotPayment(bet.gambler, uint(keccak256(abi.encodePacked(reveal))), jackpotWin);
        }

        sendFunds(
          bet.gambler,
          diceWin + jackpotWin == 0 ? 1 wei : diceWin + jackpotWin,
          diceWin,
          uint(keccak256(abi.encodePacked(reveal))),
          'payment'
        );
    }

    function _plinkoGetDiceWin(uint dice, uint amount, uint rollUnder, address gambler) internal view returns (uint) {
        uint bytesCount = 0;
        uint diceWin = 1;

        for (uint byteNum = 0; byteNum < PLINKO_BYTES; byteNum += 1) {
            if ((2 ** byteNum) & dice != 0) {
                bytesCount += 1;
            }
        }

        uint inCellRatio = _getPlinkoCellRatio(rollUnder, bytesCount);
        uint jackpotFee = amount >= MIN_JACKPOT_BET ? JACKPOT_FEE : 0;
        uint totalPercentages;

        if (plinkoSkipComission == 2) {
          totalPercentages = PLINKO_PERCENT + ADVERTISE_PERCENT + DIVIDENDS_PERCENT;
        } else {
          totalPercentages = HOUSE_EDGE_PERCENT + ADVERTISE_PERCENT + DIVIDENDS_PERCENT;
        }

        uint houseEdge = amount * (totalPercentages - getBonusProgrammLevel(gambler)) / PERCENTAGES_BASE;
        if (houseEdge < HOUSE_EDGE_MINIMUM_AMOUNT) {
            houseEdge = HOUSE_EDGE_MINIMUM_AMOUNT;
        }

        diceWin = (amount - houseEdge - jackpotFee) * inCellRatio / 100;

        return diceWin;
    }

    function _getPlinkoCellRatio(uint plinkoNum, uint cell) internal view returns (uint cellRatio) {
      if (plinkoNum == 1) {
        cellRatio = PLINKO1Ratios[cell];
      } else if (plinkoNum == 2) {
        cellRatio = PLINKO2Ratios[cell];
      } else {
        cellRatio = PLINKO3Ratios[cell];
      }
    }

    // Slots
    function settleBetSlots(Bet storage bet, uint reveal) private {
        uint amount = bet.amount;
        uint modulo = bet.modulo;

        require (amount != 0, "Bet should be in an 'active' state");

        bet.amount = 0;
        bytes32 entropy = keccak256(abi.encodePacked(reveal, bet.clientSeed));
        uint diceWin = _slotsWinAmount(entropy, amount, bet.gambler);

        lockedInBets -= uint128(bet.locked);

        uint jackpotWin = checkJackPotWin(entropy, amount, modulo);
        if (jackpotWin > 0) {
            emit JackpotPayment(bet.gambler, uint(keccak256(abi.encodePacked(reveal))), jackpotWin);
        }

        sendFunds(
          bet.gambler,
          diceWin + jackpotWin == 0 ? 1 wei : diceWin + jackpotWin,
          diceWin,
          uint(keccak256(abi.encodePacked(reveal))),
          'payment'
        );
    }

    function _slotsWinAmount(bytes32 entropy, uint amount, address gambler) internal view returns (uint winAmount) {
        uint8 wins;
        uint8 wild;

        (wins, wild) = _slotsCheckWin(entropy);

        winAmount = 0;

        uint jackpotFee = amount >= MIN_JACKPOT_BET ? JACKPOT_FEE : 0;
        uint totalPercentages = HOUSE_EDGE_PERCENT + ADVERTISE_PERCENT + DIVIDENDS_PERCENT;
        uint houseEdge = amount * (totalPercentages - getBonusProgrammLevel(gambler)) / PERCENTAGES_BASE;

        if (houseEdge < HOUSE_EDGE_MINIMUM_AMOUNT) {
            houseEdge = HOUSE_EDGE_MINIMUM_AMOUNT;
        }

        winAmount = (amount - houseEdge - jackpotFee) / 100 * SLOTSWinsRatios[wins];
        winAmount += (amount - houseEdge - jackpotFee) / 100 * SLOTSWildRatios[wild];
    }

    function _slotsCheckWin(bytes32 slots) internal pure returns(uint8 wins, uint8 wild) {
        uint curNum;
        uint prevNum;
        bytes1 charAtPos;
        uint8 firstNums;
        uint8 prevWins = 0;
        uint8 curWins = 0;

        wins = 0;
        wild = 0;

        for(uint8 i = 0; i < SLOTS_COUNT; i++) {
            charAtPos = charAt(slots, i + 2);
            firstNums = getLastN(charAtPos, 4);
            curNum = uint(firstNums);

            if (curNum > 8) {
                curNum = 16 - curNum;
            }

            if (curNum == 7) wild += 1;

            if (i == 0) {
                prevNum = curNum;
                continue;
            }

            if (prevNum == curNum) {
                curWins += 1;
            } else {
                prevWins = (curWins > prevWins) ? curWins : prevWins;
                curWins = 0;
            }

            prevNum = curNum;
        }

        wins = (curWins > prevWins) ? curWins : prevWins;
    }

    function settleBetRoulette(BetRoulette storage betRoulette, uint reveal) private {
        require (betRoulette.totalBetAmount != 0, "Bet should be in an 'active' state");
        address payable gambler = betRoulette.gambler;
        bytes32 entropy = keccak256(abi.encodePacked(reveal, betRoulette.clientSeed));
        uint diceWin = 0;
        uint diceWinAmount;
        uint feeToJP = betRoulette.totalBetAmount >= MIN_JACKPOT_BET ? JACKPOT_FEE / betRoulette.betsCount : 0;

        uint dice = uint(entropy) % ROULETTE_ID;

        uint8 bonuses = getBonusProgrammLevel(betRoulette.gambler);

        for(uint8 index = 0; index < betRoulette.betsCount; index += 1) {
          if ((2 ** dice) & betRoulette.mask[index] != 0) {
              diceWinAmount = getRouletteWinAmount(betRoulette.amount[index] - feeToJP, ROULETTE_ID - 1, betRoulette.rollUnder[index], bonuses, false);
              diceWin += diceWinAmount;
          }
        }

        lockedInBets -= betRoulette.locked;

        uint jackpotWin = checkJackPotWin(entropy, betRoulette.totalBetAmount, ROULETTE_ID);
        if (jackpotWin > 0) {
            emit JackpotPayment(gambler, uint(keccak256(abi.encodePacked(reveal))), jackpotWin);
        }

        sendFunds(
          gambler,
          diceWin + jackpotWin == 0 ? 1 wei : diceWin + jackpotWin,
          diceWin,
          uint(keccak256(abi.encodePacked(reveal))),
          'payment'
        );

        betRoulette.totalBetAmount = 0;
    }

    function refundBet(uint commit) external {
        Bet storage bet = bets[commit];
        uint amount = bet.amount;

        require (amount != 0, "Bet should be in an 'active' state");
        require (block.number > bet.placeBlockNumber + BET_EXPIRATION_BLOCKS, "Blockhash can't be queried by EVM.");

        bet.amount = 0;
        lockedInBets -= uint128(bet.locked);

        if (amount >= MIN_JACKPOT_BET && jackpotSize > JACKPOT_FEE) {
          jackpotSize -= uint128(JACKPOT_FEE);
        }

        sendFunds(bet.gambler, amount, amount, commit, 'refund');
    }

    function refundBetRoulette(uint commit) external {
        BetRoulette storage betRoulette = betsRoulette[commit];
        uint amount = betRoulette.totalBetAmount;

        require (amount != 0, "Bet should be in an 'active' state");
        require (block.number > betRoulette.placeBlockNumber + BET_EXPIRATION_BLOCKS, "Blockhash can't be queried by EVM.");

        betRoulette.totalBetAmount = 0;

        for(uint8 index = 0; index < betRoulette.betsCount; index += 1) {
          betRoulette.amount[index] = 0;
        }

        lockedInBets -= betRoulette.locked;

        if (amount >= MIN_JACKPOT_BET && jackpotSize > JACKPOT_FEE) {
          jackpotSize -= uint128(JACKPOT_FEE);
        }

        sendFunds(betRoulette.gambler, amount, amount, commit, 'refund');
    }

    function getDiceWinAmount(uint amount, uint32 modulo, uint8 rollUnder, address gambler, bool init) private returns (uint128 winAmount, uint jackpotFee) {
        require (0 < rollUnder && rollUnder <= modulo, "Win probability out of range.");

        jackpotFee = amount >= MIN_JACKPOT_BET ? JACKPOT_FEE : 0;
        uint8 totalPercentages;

        if (plinkoSkipComission == 2) { // Plinko
          totalPercentages = PLINKO_PERCENT + ADVERTISE_PERCENT + DIVIDENDS_PERCENT;
        } else { // All other games
          totalPercentages = HOUSE_EDGE_PERCENT + ADVERTISE_PERCENT + DIVIDENDS_PERCENT;
        }

        uint houseEdge = amount * (totalPercentages - getBonusProgrammLevel(gambler)) / PERCENTAGES_BASE;
        if (houseEdge < HOUSE_EDGE_MINIMUM_AMOUNT) {
            houseEdge = HOUSE_EDGE_MINIMUM_AMOUNT;
        }

        require (houseEdge + jackpotFee <= amount, "Bet doesn't even cover house edge.");

        if (init) {
          totalDividends += amount * DIVIDENDS_PERCENT / PERCENTAGES_BASE;
          totalAdvertise += amount * ADVERTISE_PERCENT / PERCENTAGES_BASE;
        }

        if (modulo == PLINKO_ID) {
          // We lock maximum for selected plinko row
          if (rollUnder == 1) {
            modulo = 10; // equal to  PLINKO1Ratios[0] / 100
          } else if (rollUnder == 2) {
            modulo = 20; // equal to  PLINKO2Ratios[0] / 100
          } else {
            modulo = 50; // equal to  PLINKO3Ratios[0] / 100
          }

          rollUnder = 1;
        }

        if (modulo == SLOTS_ID) {
          modulo = 5; // We lock x5 for slots
          rollUnder = 1;
        }

        winAmount = uint128((amount - houseEdge - jackpotFee) * modulo / rollUnder);
    }

    function getRouletteWinAmount(uint amount, uint32 modulo, uint8 rollUnder, uint8 bonuses, bool init) private returns (uint128 winAmount) {
        require (0 < rollUnder && rollUnder <= modulo, "Win probability out of range.");
        uint houseEdge;

        if (rouletteSkipComission == 1) { // Roulette
          houseEdge = amount * ROULETTE_PERCENT / PERCENTAGES_BASE;
        } else {
          if (init) {
            totalDividends += amount * DIVIDENDS_PERCENT / PERCENTAGES_BASE;
            totalAdvertise += amount * ADVERTISE_PERCENT / PERCENTAGES_BASE;
          }

          houseEdge = amount * (HOUSE_EDGE_PERCENT + ADVERTISE_PERCENT + DIVIDENDS_PERCENT - bonuses) / PERCENTAGES_BASE;
        }

        if (houseEdge < HOUSE_EDGE_MINIMUM_AMOUNT) {
            houseEdge = HOUSE_EDGE_MINIMUM_AMOUNT;
        }
        require (houseEdge <= amount, "Bet doesn't even cover house edge.");

        winAmount = uint128((amount - houseEdge) * modulo / rollUnder);
    }

    function sendFunds(address payable beneficiary, uint amount, uint successLogAmount, uint commit, string memory paymentType) private {
        if (beneficiary.send(amount)) {
            emit Payment(beneficiary, commit, successLogAmount, paymentType);
        } else {
            emit FailedPayment(beneficiary, commit, amount, paymentType);
        }
    }

    function checkJackPotWin(bytes32 entropy, uint amount, uint modulo) internal returns (uint jackpotWin) {
        jackpotWin = 0;
        if (amount >= MIN_JACKPOT_BET) {
            uint jackpotRng = (uint(entropy) / modulo) % JACKPOT_MODULO;

            if (jackpotRng == luckyNumber) {
                jackpotWin = jackpotSize;
                jackpotSize = 0;
            }
        }
    }

    uint constant POPCNT_MULT = 0x0000000000002000000000100000000008000000000400000000020000000001;
    uint constant POPCNT_MASK = 0x0001041041041041041041041041041041041041041041041041041041041041;
    uint constant POPCNT_MODULO = 0x3F;

    function charAt(bytes32 b, uint char) private pure returns (bytes1) {
        return bytes1(uint8(uint(b) / (2**((31 - char) * 8))));
    }

    function getLastN(bytes1 a, uint8 n) private pure returns (uint8) {
        uint8 lastN = uint8(a) % uint8(2) ** n;
        return lastN;
    }
}