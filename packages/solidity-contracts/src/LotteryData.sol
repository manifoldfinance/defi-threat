/**
 * Source Code first verified at https://etherscan.io on Monday, April 15, 2019
 (UTC) */

pragma solidity ^0.5.4;

/**
    INSTRUCTION:
    Send more then 0.01 ETH to one of Wallet Contract address
    [wallet_0, wallet_1, wallet_2], after round end send to This contract 0 ETH
    transaction and if you choise won, take your winnings.

    DAPP:     http://smartlottery.game (mirror: http://smartlottery.clab)
    BOT:      http://t.me/SmartLotteryGame_bot
    LICENSE:  Under proprietary rights. All rights reserved.
              Except <lib.SafeMath, cont.Ownable> under The MIT License (MIT)
    AUTHOR:   http://t.me/pironmind
    
*/

library SafeMath {
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        if (_a == 0) {
            return 0;
        }
        uint256 c = _a * _b;
        require(c / _a == _b);
        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0);
        uint256 c = _a / _b;
        return c;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;
        return c;
    }

    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a);
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract Ownable {
    address public owner;

    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

contract Wallet is Ownable {
    using SafeMath for uint256;

    LotteryData public lotteryData;

    uint256 public minPaymnent = 10**16;

    function setMinPayment(uint256 value) public onlyOwner {
        minPaymnent = value;
    }

    constructor() public {
        lotteryData = LotteryData(msg.sender);
    }

    function() payable external {
        require(msg.value >= minPaymnent);
        lotteryData.participate(msg.sender, msg.value);
    }

    function finishDay() external returns(uint256) {
        require(msg.sender == address(lotteryData));
        uint256 balance = address(this).balance;
        if (balance >= minPaymnent) {
            lotteryData.getFunds.value(balance)();
            return balance;
        } else {
            return 0;
        }
    }
}

contract LotteryData is Ownable {
    using SafeMath for uint;

    event Withdrawn(address indexed payee, uint256 weiAmount);
    event Deposited(address indexed payee, uint256 weiAmount);
    event WinnerWallet(address indexed wallet, uint256 bank);

    Wallet public wallet_0 = new Wallet();
    Wallet public wallet_1 = new Wallet();
    Wallet public wallet_2 = new Wallet();

    uint256 public finishTime;
    uint256 constant roundTime = 86400;

    uint internal dilemma;
    uint internal max_participators = 100;
    uint internal participators;
    uint internal randNonce = 19;
    uint internal winner;
    uint internal winner_1;
    uint internal winner_2;
    uint256 internal fund;
    uint256 internal commission;
    uint256 internal totalBetsWithoutCommission;

    mapping(uint => address) public wallets;
    mapping(address => mapping (address => uint256)) public playersBets;
    mapping(address => mapping (uint => address)) public players;
    mapping(address => uint256) public totalBets;
    mapping(address => uint) public totalPlayers;
    mapping(address => uint256) private _deposits;

    uint public games;

    struct wins{
        address winner;
        uint256 time;
    }

    mapping(uint => wins) public gamesLog;

    constructor() public {
        wallets[0] = address(wallet_0);
        wallets[1] = address(wallet_1);
        wallets[2] = address(wallet_2);
        finishTime = now.add(roundTime);
    }

    modifier validWallets() {
        require(
            msg.sender == address(wallet_0) ||
            msg.sender == address(wallet_1) ||
            msg.sender == address(wallet_2)
        );
        _;
    }

    function depositsOf(address payee) public view returns (uint256) {
        return _deposits[payee];
    }

    function deposit(address payee, uint256 amount) internal {
        _deposits[payee] = _deposits[payee].add(amount);
        emit Deposited(payee, amount);
    }

    function getFunds() public payable validWallets {}

    function lastWinner() public view returns(address) {
        return gamesLog[games].winner;
    }

    function getRandomWallet() internal returns(uint) {
        uint result = uint(keccak256(abi.encodePacked(now, randNonce, blockhash(block.number - 1)))) % 3;
        randNonce = randNonce.add(result.add(2));
        return result;
    }

    function _fundriser() internal returns(uint256) {
        fund = fund.add(wallet_0.finishDay());
        fund = fund.add(wallet_1.finishDay());
        return fund.add(wallet_2.finishDay());
    }

    function _randomizer() internal returns(uint) {
        // random choose one of three wallets
        winner = getRandomWallet();
        // check if this address had payments, if no solving it
        if(totalPlayers[wallets[winner]] == 0) {
            dilemma = uint(keccak256(abi.encodePacked(now, winner, blockhash(block.number - 1)))) % 2;
            if(winner == 0) {
                if(dilemma == 1) {
                    winner_1 = 2; winner_2 = 1;
                } else {
                    winner_1 = 1; winner_2 = 2;
                }
            }
            if(winner == 1) {
                if(dilemma == 1) {
                    winner_1 = 2; winner_2 = 0;
                } else {
                    winner_1 = 0; winner_2 = 2;
                }
            }
            if(winner == 2) {
                if(dilemma == 1) {
                    winner_1 = 1; winner_2 = 0;
                } else {
                    winner_1 = 0; winner_2 = 1;
                }
            }
            winner = (totalPlayers[wallets[winner_1]] == 0) ? winner_2 : winner_1;
        }

        return winner;
    }

    function _distribute() internal {
        // calculate commission
        commission = fund.mul(15).div(100);
        totalBetsWithoutCommission = fund.sub(commission);
        deposit(owner, commission);
        // calculate and make deposits
        for (uint i = 0; i < totalPlayers[wallets[winner]]; i++) {
            uint percents = playersBets[wallets[winner]][players[wallets[winner]][i]].mul(10000).div(totalBets[wallets[winner]]);
            deposit(players[wallets[winner]][i], totalBetsWithoutCommission.mul(percents).div(10000));
        }
    }

    function _collector() internal {
        fund = 0;
        participators = 0;
        totalBets[wallets[0]] = 0;
        for (uint j = 0; j < 3; j++) {
            for (uint k = 0; k < totalPlayers[wallets[j]]; k++) {
                playersBets[wallets[j]][players[wallets[j]][k]] = 0;
                players[wallets[j]][k] = address(0x0);
            }
            totalBets[wallets[j]] = 0;
            totalPlayers[wallets[j]] = 0;
        }
    }

    function _logger(address _winner, uint256 _fund) internal {
        games = games + 1;
        gamesLog[games].winner =_winner;
        gamesLog[games].time = now;
        emit WinnerWallet(_winner, _fund);
    }

    function participate(address player, uint256 amount) external validWallets {
        if (now >= finishTime || participators >= max_participators) {
            // send all funds to this wallet
            fund = _fundriser();
            // if it has participators
            if(fund > 0) {
                // get winner
                winner = _randomizer();
                // _distribute
                _distribute();
                // clear state
                _collector();
                // log data
                _logger(wallets[winner], fund);
            }
            // update round
            finishTime = now.add(roundTime);
        }

        if (playersBets[msg.sender][player] == 0) {
            players[msg.sender][totalPlayers[msg.sender]] = player;
            totalPlayers[msg.sender] = totalPlayers[msg.sender].add(1);
            participators = participators.add(1);
        }
        playersBets[msg.sender][player] = playersBets[msg.sender][player].add(amount);
        totalBets[msg.sender] = totalBets[msg.sender].add(amount);
    }

    /**
    * @dev Withdraw accumulated balance for a payee.
    */
    function withdraw() public {
        uint256 payment = _deposits[msg.sender];
        _deposits[msg.sender] = 0;
        msg.sender.transfer(payment);
        emit Withdrawn(msg.sender, payment);
    }

    function paymentValidator(address _payee, uint256 _amount) internal {
        if(_payee != address(wallet_0) &&
           _payee != address(wallet_1) &&
           _payee != address(wallet_2))
        {
            if(_amount == uint(0)) {
                if(depositsOf(_payee) != uint(0)) {
                    withdraw();
                } else {
                    revert("You have zero balance");
                }
            } else {
                revert("You can't do nonzero transaction");
            }
        }
    }

    function() external payable {
        paymentValidator(msg.sender, msg.value);
    }
}