pragma solidity ^0.5.0;

/**
 * (E)t)h)e)x) Loto Contract 
 *  This smart-contract is the part of Ethex Lottery fair game.
 *  See latest version at https://github.com/ethex-bet/ethex-contacts 
 *  http://ethex.bet
 */

import "./EthexJackpot.sol";
import "./EthexHouse.sol";

contract EthexLoto {
    struct Bet {
        uint256 blockNumber;
        uint256 amount;
        bytes16 id;
        bytes6 bet;
        address payable gamer;
    }
    
    struct Payout {
        uint256 amount;
        bytes32 blockHash;
        bytes16 id;
        address payable gamer;
    }
    
    Bet[] betArray;
    
    address payable public jackpotAddress;
    address payable public houseAddress;
    address payable private owner;

    event Result (
        uint256 amount,
        bytes32 blockHash,
        bytes16 indexed id,
        address indexed gamer
    );
    
    uint8 constant N = 16;
    uint256 constant MIN_BET = 0.01 ether;
    uint256 constant PRECISION = 1 ether;
    uint256 constant JACKPOT_PERCENT = 10;
    uint256 constant HOUSE_EDGE = 10;
    
    constructor(address payable jackpot, address payable house) public payable {
        owner = msg.sender;
        jackpotAddress = jackpot;
        houseAddress = house;
    }
    
    function() external payable { }
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    function placeBet(bytes22 params) external payable {
        require(msg.value >= MIN_BET, "Bet amount should be greater or equal than minimal amount");
        require(bytes16(params) != 0, "Id should not be 0");
        
        bytes16 id = bytes16(params);
        bytes6 bet = bytes6(params << 128);
        
        uint8 markedCount = 0;
        uint256 coefficient = 0;
        for (uint8 i = 0; i < bet.length; i++) {
            if (bet[i] > 0x13)
                continue;
            markedCount++;
            if (bet[i] < 0x10) {
                coefficient += 300;
                continue;
            }
            if (bet[i] == 0x10) {
                coefficient += 50;
                continue;
            }
            if (bet[i] == 0x11) {
                coefficient += 30;
                continue;
            }
            if (bet[i] == 0x12) {
                coefficient += 60;
                continue;
            }
            if (bet[i] == 0x13) {
                coefficient += 60;
                continue;
            }
        }
        
        require(msg.value <= 180000 ether / ((coefficient * N - 300) * (100 - JACKPOT_PERCENT - HOUSE_EDGE)));
        
        uint256 jackpotFee = msg.value * JACKPOT_PERCENT * PRECISION / 100 / PRECISION;
        uint256 houseEdgeFee = msg.value * HOUSE_EDGE * PRECISION / 100 / PRECISION;
        betArray.push(Bet(block.number, msg.value - jackpotFee - houseEdgeFee, id, bet, msg.sender));
        
        if (markedCount > 1)
            EthexJackpot(jackpotAddress).registerTicket(id, msg.sender);
        
        EthexJackpot(jackpotAddress).payIn.value(jackpotFee)();
        EthexHouse(houseAddress).payIn.value(houseEdgeFee)();
    }
    
    function settleBets() external {
        if (betArray.length == 0)
            return;

        Payout[] memory payouts = new Payout[](betArray.length);
        Bet[] memory missedBets = new Bet[](betArray.length);
        uint256 totalPayout;
        uint i = betArray.length;
        do {
            i--;
            if(betArray[i].blockNumber >= block.number || betArray[i].blockNumber < block.number - 256)
                missedBets[i] = betArray[i];
            else {
                bytes32 blockHash = blockhash(betArray[i].blockNumber);
                uint256 coefficient = 0;
                uint8 markedCount;
                uint8 matchesCount;
                for (uint8 j = 0; j < betArray[i].bet.length; j++) {
                    if (betArray[i].bet[j] > 0x13)
                        continue;
                    markedCount++;
                    byte field;
                    if (j % 2 == 0)
                        field = blockHash[29 + j / 2] >> 4;
                    else
                        field = blockHash[29 + j / 2] & 0x0F;
                    if (betArray[i].bet[j] < 0x10) {
                        if (field == betArray[i].bet[j]) {
                            matchesCount++;
                            coefficient += 300;
                        }
                        continue;
                    }
                    if (betArray[i].bet[j] == 0x10) {
                        if (field > 0x09 && field < 0x10) {
                            matchesCount++;
                            coefficient += 50;
                        }
                        continue;
                    }
                    if (betArray[i].bet[j] == 0x11) {
                        if (field < 0x0A) {
                            matchesCount++;
                            coefficient += 30;
                        }
                        continue;
                    }
                    if (betArray[i].bet[j] == 0x12) {
                        if (field < 0x0A && field & 0x01 == 0x01) {
                            matchesCount++;
                            coefficient += 60;
                        }
                        continue;
                    }
                    if (betArray[i].bet[j] == 0x13) {
                        if (field < 0x0A && field & 0x01 == 0x0) {
                            matchesCount++;
                            coefficient += 60;
                        }
                        continue;
                    }
                }
            
                if (matchesCount == 0) 
                    coefficient = 0;
                else                    
                    coefficient *= PRECISION * N;
                
                uint payoutAmount = betArray[i].amount * coefficient / (PRECISION * 300 * markedCount);
                if (payoutAmount == 0 && matchesCount > 0)
                    payoutAmount = matchesCount;
                payouts[i] = Payout(payoutAmount, blockHash, betArray[i].id, betArray[i].gamer);
                totalPayout += payoutAmount;
            }
            betArray.pop();
        } while (i > 0);
        
        i = missedBets.length;
        do {
            i--;
            if (missedBets[i].id != 0)
                betArray.push(missedBets[i]);
        } while (i > 0);
        
        uint balance = address(this).balance;
        for (i = 0; i < payouts.length; i++) {
            if (payouts[i].id > 0) {
                if (totalPayout > balance)
                    emit Result(balance * payouts[i].amount * PRECISION / totalPayout / PRECISION, payouts[i].blockHash, payouts[i].id, payouts[i].gamer);
                else
                    emit Result(payouts[i].amount, payouts[i].blockHash, payouts[i].id, payouts[i].gamer);
            }
        }
        for (i = 0; i < payouts.length; i++) {
            if (payouts[i].amount > 0) {
                if (totalPayout > balance)
                    payouts[i].gamer.transfer(balance * payouts[i].amount * PRECISION / totalPayout / PRECISION);
                else
                    payouts[i].gamer.transfer(payouts[i].amount);
            }
        }
    }
    
    function migrate(address payable newContract) external onlyOwner {
        newContract.transfer(address(this).balance);
    }

    function setJackpot(address payable jackpot) external onlyOwner {
        jackpotAddress = jackpot;
    }
}
