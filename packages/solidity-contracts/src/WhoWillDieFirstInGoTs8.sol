/**
 * Source Code first verified at https://etherscan.io on Wednesday, March 27, 2019
 (UTC) */

pragma solidity ^0.5.7;

contract WhoWillDieFirstInGoTs8 {
    
    uint8 public constant Withdraw = 0;
    uint8 public constant firstHero = 1;
    uint8 public constant lastHero = 38;
    uint8 public constant ArraySize = lastHero + 1;
/*
EuronGreyjoy = 1;
CerseiLannister = 2;
LordVarys = 3;
JorahMormont = 4;
BericDondarrion = 5;
Melisandre = 6;
JaimeLannister = 7;
TheHound = 8;
DaenerysTargaryen = 9;
GreyWorm = 10;
TheonGreyjoy = 11;
TyrionLannister = 12;
PodrickPayne = 14;
BrienneOfTarth = 15;
BronnOfTheBlackwater = 16;
AryaStark = 17;
JonSnow = 18;
Gendry = 19;
BranStark = 20;
Gilly = 21;
SamwellTarly = 22;
SansaStark = 13;
YaraGreyjoy = 23;
Drogon = 24;
EddisonTollett = 25;
EdmureTully = 26;
GregorClegane = 27;
HotPie = 28;
LyannaMormont = 29;
Rhaegal = 30;
RobinArryn = 31;
DavosSeaworth = 32;
YohnRoyce = 33;
Missandei = 34;
TheNightKing = 35;
TormundGiantsbane = 36;
DaarioNaharis = 37;
JaqunH’ghar = 38;
*/
    mapping(address => bool) sith;
    mapping(address => uint256[ArraySize]) public bets;
    uint256[ArraySize] public betAmount;
    uint256[ArraySize] public playerCount;
    uint256 public resultWin = 0;
    uint256 public winRatio;
    uint256 constant minBet = 0.001 ether;
    uint256 constant RR = 100000000000000;
    uint256 sithCount;
    uint256 public likeDAPP;
    bool public endBetting = false;
    bool public startPayment = false;
    bool public onPause = false;
    address payable Martin;
    address payable George;
    
    event Bet(address indexed _who, uint8 _hero, uint256 amount);
    
    modifier onlySiths {
        require(sith[msg.sender] == true);
        _;
    }

    constructor(address payable _M, address payable _G) public {
        Martin = _M;
        George = _G;
        sith[msg.sender] = true;
        sithCount++;
    }

    function like() external {
        likeDAPP++;
    }

    function dislike() external {
        if (likeDAPP > 0) {
            likeDAPP--;
        }
    }

    function setBet(uint8 _hero) external payable {
        require(onPause == false);
        require(msg.value >= minBet);
        require(endBetting == false);
        require(_hero >= firstHero || _hero <= lastHero);
        if (bets[msg.sender][_hero] == 0) {
            playerCount[_hero]++;
        }
        bets[msg.sender][_hero] += msg.value;
        betAmount[_hero] += msg.value;
        emit Bet(msg.sender, _hero, msg.value);

    }

    function getProfit(address payable _winer) external {
        require(startPayment == true);
        if (resultWin == Withdraw) {
            uint256 retValue;
            for(uint256 i = firstHero; i <= lastHero; i++) {
                uint256 bet = bets[_winer][i];
                if (bet > 0) {
                    bets[_winer][i] = 0;
                    retValue += bet;
                }
            }
            if (retValue > 0) {
                _winer.transfer(retValue); 
            }
            return;
        } else {
            uint256 winersBet = bets[_winer][resultWin];
            require(winersBet > 0);
            bets[_winer][resultWin] = 0;
            playerCount[resultWin]--;
            _winer.transfer(winersBet + winersBet * winRatio / RR);
        }
    }

    function getStatistics() external view returns (uint256[2 * ArraySize] memory) {
        uint256[2 * ArraySize] memory output;
        for(uint256 i = firstHero; i <= lastHero; i++) {
            output[i] = betAmount[i];
            output[i + ArraySize] = playerCount[i];
        }
        return output;
    }

    function getPlayerStatistics(address _player) external view returns (uint256[ArraySize] memory) {
        uint256[ArraySize] memory output;
        for(uint256 i = firstHero; i <= lastHero; i++) {
            output[i] = bets[_player][i];
        }
        return output;
    }
    
    function endBetPeriod() external onlySiths {
        endBetting = true;
    }

    function setResult(uint32 _result) external onlySiths {
        require(_result >=  firstHero || _result <= lastHero);
        require(startPayment == false);
        if (betAmount[_result] == 0) {
            startWithdraw();
            return;
        }
        uint256 donation = (address(this).balance - betAmount[_result]) / 10;
        Martin.transfer(donation / 2);
        George.transfer(donation / 2);
        uint256 totalBets = (address(this).balance - betAmount[_result]);
        winRatio = totalBets * RR / betAmount[_result];
        resultWin = _result;
        startPayment = true;
        if (endBetting != true) {
            endBetting = true;
        }
    }

    function startWithdraw() public onlySiths {
        require(startPayment == false);
        startPayment = true;
        if (endBetting != true) {
            endBetting = true;
        }
        if (resultWin != Withdraw) {
            resultWin = Withdraw;
        }
    }

    function pauseOn() external onlySiths {
        onPause = true;
    }

    function pauseOff() external onlySiths {
        onPause = false;
    }

    function clearBlockchain() external {
        require(startPayment && endBetting);
        if (resultWin == Withdraw) {
            require(address(this).balance < minBet);
            selfdestruct(msg.sender);
        } else {
            require(playerCount[resultWin] == 0);
            selfdestruct(msg.sender);
        }
    }

    function addSith(address _sith) external onlySiths {
        sith[_sith] = true;
        sithCount++;
    }

    function delSith(address _sith) external onlySiths {
        require(sithCount >= 2);
        sith[_sith] = false;
        sithCount--;
    }
}