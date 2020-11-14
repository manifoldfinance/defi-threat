/**
 * Source Code first verified at https://etherscan.io on Wednesday, April 17, 2019
 (UTC) */

pragma solidity >=0.4.22 <0.6.0;

contract Coinflip {
    enum WagerState {emptyRoom,wagerMade, wagerAccepted, wagerWon}
    uint256 minimumBet = 10000000000000000;
    uint256 idRoom = 100000000;
    address owner;
    uint256 percent = 100;

    struct Room {
        WagerState currentState;
        uint wager;
        address payable player1;
        address payable player2;
        address winner;
        uint seedBlockNumber;
        bool isPlayerOneEagle;
    }
    mapping (uint256 => Room) games;

    uint256[] public gamesAccts;

    event roomCreated(uint256 id, bool side, uint256 wager, address player); 
    event endGame(uint256 finishedGame, address winner, address player2); 
    event playerLeave(uint256 leaveGameAddress); 

    function add(bool Side) public payable returns (bool) {
        require(msg.value >= minimumBet);
        games[idRoom].isPlayerOneEagle = Side;
        games[idRoom].currentState = WagerState.wagerMade;
        games[idRoom].wager = msg.value;
        games[idRoom].player1 = msg.sender;
        games[idRoom].seedBlockNumber = block.number;
        gamesAccts.push(idRoom);
        emit roomCreated(idRoom, Side, msg.value, msg.sender);
        idRoom++;
        return true;
    }

    function acceptWager(uint256 _address) public payable returns (bool) {

        require(games[_address].currentState == WagerState.wagerMade);
        require(msg.value == games[_address].wager);
        require(games[_address].player1 != msg.sender);
        games[_address].player2 = msg.sender;
        games[_address].seedBlockNumber = block.number;
        games[_address].currentState = WagerState.wagerAccepted;
        start(_address);
        return true;
    }

    function start(uint256 _address) private {
        require(games[_address].currentState == WagerState.wagerAccepted);
        uint8 coinFlip = uint8(uint256(keccak256(abi.encode(block.timestamp, block.difficulty)))%100);

        if(games[_address].isPlayerOneEagle == true && coinFlip <= 49) {
            games[_address].winner = games[_address].player1;
            games[_address].player1.transfer(games[_address].wager*2 - ((games[_address].wager*2) * percent) / 1000);
        }

        else if(games[_address].isPlayerOneEagle == false && coinFlip >= 50) {
            games[_address].winner = games[_address].player1;
            games[_address].player1.transfer(games[_address].wager*2 - ((games[_address].wager*2) * percent) / 1000);
        }
        else {
            games[_address].winner = games[_address].player2;
            games[_address].player2.transfer(games[_address].wager*2 - ((games[_address].wager*2) * percent) / 1000);
        }
        games[_address].currentState = WagerState.wagerWon;
        emit endGame(_address, games[_address].winner, games[_address].player2);
    }

    function leave(uint256 id) public {
        require(games[id].currentState == WagerState.wagerMade);
        require(msg.sender == games[id].player1);
        games[id].player1.transfer(games[id].wager);
        emit playerLeave(id); 
        delete games[id];
    }

    modifier onlyOwner {
        require(msg.sender == owner,"Only owner can call this function.");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function withdraw() onlyOwner public {
    msg.sender.transfer(address(this).balance);
    }
    
    function changePercent(uint256 newPercent) onlyOwner public {
        percent = newPercent;
    }
    
      function changeMinimumBet(uint256 newMinimumBet) onlyOwner public {
        minimumBet = newMinimumBet;
    }

    function countCoinflips() view public returns (uint) {
        return gamesAccts.length;
    }

    function getCurrentState(uint256 _address) public view returns(WagerState) {
        return games[_address].currentState;
    }

    function getWager(uint256 _address) public view returns(uint) {
        return games[_address].wager;
    }

    function getPlayer1(uint256 _address) public view returns(address) {
        return games[_address].player1;
    }

    function getPlayer2(uint256 _address) public view returns(address) {
        return games[_address].player2;
    }

    function getWinner(uint256 _address) public view returns(address) {
        return games[_address].winner;
    }

    function getSide(uint256 _address) public view returns(bool) {
        return games[_address].isPlayerOneEagle;
    }
    
    function getCoinflips() public view returns(uint256[] memory) {
        return gamesAccts;
    }
    
    function getPercent() public view returns(uint256) {
        return percent;
    }
    
    function getMinimumBet() public view returns(uint256){
        return minimumBet;
    }
}