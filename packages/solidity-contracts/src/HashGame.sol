/**
 * Source Code first verified at https://etherscan.io on Wednesday, April 3, 2019
 (UTC) */

pragma solidity >0.4.99 <0.6.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma experimental ABIEncoderV2;

contract HashGame is Ownable {

    uint256 constant public MAX_BET = 1 ether;
    uint256 public ethRaised;
    uint256 public countRound = 1;

    struct Game {
        address player;
        uint256 betAmount;
        uint256 blockNumber;
        uint256 prize;
        uint256[] symbols;
        bool started;
        bool isWinner;
        string symbolWinner;
    }
    mapping(uint256 => Game) public games;
    mapping(address => uint256) public roundPlayer;

    address payable public beneficiar;

    event Result(address indexed player, uint[] symbols, string winSymbol, uint256 betAmount, uint256 prizeAmount, uint256 blockNumber);
    event PlaceBet(address indexed player, uint256 betAmount, uint256 prizeAmount, uint256 blockNumber, uint256[] symbols);

    constructor (address payable beneficiarAddress) public {
        setBeneficiarAddress(beneficiarAddress);
    }

    function () external payable {}

    function placeBet(uint[] memory symbolsUint) public payable {
        require(msg.value > 0 && msg.value <= MAX_BET, "Requires msg.value > 0 && msg.value <= MAX_BET");
        require(!games[roundPlayer[msg.sender]].started, "Requires not started");
        require(symbolsUint.length > 0 && symbolsUint.length <= 5, "Requires symbols.length > 0 && symbols.length <= 5");
        uint256 prize = calcPrize(symbolsUint.length, msg.value);
        require(address(this).balance >= prize, "require balance of contract >= prize");

        Game storage game = games[countRound];
        game.player = msg.sender;
        game.betAmount = msg.value;
        game.blockNumber = block.number;
        game.prize = prize;
        game.symbols = symbolsUint;
        game.started = true;

        roundPlayer[msg.sender]  = countRound;

        countRound++;
        emit PlaceBet(msg.sender, msg.value, prize, block.number, symbolsUint);
    }

    function bet() public {
        Game storage game = games[roundPlayer[msg.sender]];
        require(game.started, "require game started");
        require(block.number > game.blockNumber, "require current number of block > game number of block");
        if (block.number - game.blockNumber > 256) {
            if (address(this).balance > game.betAmount) {
                game.started = false;
                msg.sender.transfer(game.betAmount);
            }
        } else {
            string [] memory symbols = getValueSymbols(game.symbols);
            byte lastBlockhashByte = getLastByte(blockhash(game.blockNumber));
            string memory lastByteRightSymbol = getRightSymbolFromByte(lastBlockhashByte);
            game.symbolWinner = lastByteRightSymbol;
            uint256 prize = game.prize;
            if (address(this).balance > prize) {
                for (uint i = 0; i < symbols.length; i++) {
                    if ( keccak256(bytes(symbols[i])) == keccak256(bytes(lastByteRightSymbol)) ) {
                        ethRaised = ethRaised + prize;
                        game.isWinner = true;
                        msg.sender.transfer(prize);
                    }
                }
                game.started = false;
            }
            emit Result(msg.sender, game.symbols, lastByteRightSymbol, game.betAmount, prize, game.blockNumber);
        }
    }

    function getEtherFromBank(uint256 weiAmount) public {
        require(msg.sender == owner() || msg.sender == beneficiar);
        beneficiar.transfer(weiAmount);
    }

    function getBalanceContract() public view returns (uint) {
        return address(this).balance;
    }

    function getGamesByIndex(uint index) public view returns
    (
        address player,
        uint betAmount,
        uint prize,
        bool isWinner,
        uint[] memory symbols,
        bool started,
        string memory symbolWinner
    ) {
        Game memory game = games[index];
        player = game.player;
        betAmount = game.betAmount;
        prize = game.prize;
        isWinner = game.isWinner;
        symbols = game.symbols;
        started = game.started;
        symbolWinner = game.symbolWinner;
    }

    function setBeneficiarAddress(address payable beneficiarAddress) public onlyOwner {
        beneficiar = beneficiarAddress;
    }

    function getLastByte(bytes32 strBytes) private pure returns (byte lastByte) {
        lastByte = strBytes[31];
    }

    function getRightSymbolFromByte(byte input) private pure returns(string memory symbol) {
        byte val = input & 0x0f;
        if (val == 0x00) {
            symbol = '0';
        } else if (val == 0x01) {
            symbol = '1';
        } else if (val == 0x02) {
            symbol = '2';
        } else if (val == 0x03) {
            symbol = '3';
        } else if (val == 0x04) {
            symbol = '4';
        } else if (val == 0x05) {
            symbol = '5';
        } else if (val == 0x06) {
            symbol = '6';
        } else if (val == 0x07) {
            symbol = '7';
        } else if (val == 0x08) {
            symbol = '8';
        } else if (val == 0x09) {
            symbol = '9';
        } else if (val == 0x0a) {
            symbol = 'a';
        } else if (val == 0x0b) {
            symbol = 'b';
        } else if (val == 0x0c) {
            symbol = 'c';
        } else if (val == 0x0d) {
            symbol = 'd';
        } else if (val == 0x0e) {
            symbol = 'e';
        } else if (val == 0x0f) {
            symbol = 'f';
        }
    }

    function convertToSymbol(uint val) private pure returns(string memory symbol) {
        if (val == 0) {
            symbol = '0';
        } else if (val == 1) {
            symbol = '1';
        } else if (val == 2) {
            symbol = '2';
        } else if (val == 3) {
            symbol = '3';
        } else if (val == 4) {
            symbol = '4';
        } else if (val == 5) {
            symbol = '5';
        } else if (val == 6) {
            symbol = '6';
        } else if (val == 7) {
            symbol = '7';
        } else if (val == 8) {
            symbol = '8';
        } else if (val == 9) {
            symbol = '9';
        } else if (val == 10) {
            symbol = 'a';
        } else if (val == 11) {
            symbol = 'b';
        } else if (val == 12) {
            symbol = 'c';
        } else if (val == 13) {
            symbol = 'd';
        } else if (val == 14) {
            symbol = 'e';
        } else if (val == 15) {
            symbol = 'f';
        }
    }

    function calcPrize(uint len, uint value) internal pure returns (uint) {
        if (len == 1) {
            return value * 10;
        }
        if (len == 2) {
            return value * 5;
        }
        if (len == 3) {
            return value * 4;
        }
        if (len == 4) {
            return value * 3;
        }
        if (len == 5) {
            return value * 2;
        }
    }

    function getValueSymbols(uint[] memory arrayUintSymbols) internal pure returns (string[] memory arrayStrSymbols) {
        delete arrayStrSymbols;
        string [] memory arrayString = new string[](arrayUintSymbols.length);
        for (uint i = 0; i < arrayUintSymbols.length; i++) {
            arrayString[i] = convertToSymbol(arrayUintSymbols[i]);
        }
        arrayStrSymbols = arrayString;
    }

}