/**
 * Source Code first verified at https://etherscan.io on Wednesday, March 20, 2019
 (UTC) */

/**
 * Allows to create contracts which would be able to receive ETH and tokens.
 * Contract will help to detect ETH deposits faster.
 * Contract idea was borrowed from Bittrex.
 * Version: 2
 * */

pragma solidity 0.4.25;


contract Owned {
    address public owner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor() internal {
        owner = msg.sender;
    }

    function setOwner(address _address) public onlyOwner {
        owner = _address;
    }
}


contract RequiringAuthorization is Owned {
    Casino public casino;
    bool public casinoAuthorized;
    mapping(address => bool) public authorized;

    modifier onlyAuthorized {
        require(authorized[msg.sender] || casinoAuthorized && casino.authorized(msg.sender));
        _;
    }

    constructor(address _casino) internal {
        authorized[msg.sender] = true;
        casino = Casino(_casino);
        casinoAuthorized = true;
    }

    function authorize(address _address) public onlyOwner {
        authorized[_address] = true;
    }

    function deauthorize(address _address) public onlyOwner {
        authorized[_address] = false;
    }

    function authorizeCasino() public onlyOwner {
        casinoAuthorized = true;
    }

    function deauthorizeCasino() public onlyOwner {
        casinoAuthorized = false;
    }

    function setCasino(address _casino) public onlyOwner {
        casino = Casino(_casino);
    }
}


contract WalletController is RequiringAuthorization {
    address public destination;
    address public defaultSweeper = address(new DefaultSweeper(address(this)));
    bool public halted = false;

    mapping(address => address) public sweepers;
    mapping(address => bool) public wallets;

    event EthDeposit(address _from, address _to, uint _amount);
    event WalletCreated(address _address);
    event Sweeped(address _from, address _to, address _token, uint _amount);

    modifier onlyWallet {
        require(wallets[msg.sender]);
        _;
    }

    constructor(address _casino) public RequiringAuthorization(_casino) {
        owner = msg.sender;
        destination = msg.sender;
    }

    function setDestination(address _destination) public {
        destination = _destination;
    }

    function createWallet() public {
        address wallet = address(new UserWallet(this));
        wallets[wallet] = true;
        emit WalletCreated(wallet);
    }

    function createWallets(uint count) public {
        for (uint i = 0; i < count; i++) {
            createWallet();
        }
    }

    function addSweeper(address _token, address _sweeper) public onlyOwner {
        sweepers[_token] = _sweeper;
    }

    function halt() public onlyAuthorized {
        halted = true;
    }

    function start() public onlyOwner {
        halted = false;
    }

    function sweeperOf(address _token) public view returns (address) {
        address sweeper = sweepers[_token];
        if (sweeper == 0) sweeper = defaultSweeper;
        return sweeper;
    }

    function logEthDeposit(address _from, address _to, uint _amount) public onlyWallet {
        emit EthDeposit(_from, _to, _amount);
    }

    function logSweep(address _from, address _to, address _token, uint _amount) public onlyWallet {
        emit Sweeped(_from, _to, _token, _amount);
    }
}


contract UserWallet {
    WalletController private controller;

    constructor (address _controller) public {
        controller = WalletController(_controller);
    }

    function () public payable {
        controller.logEthDeposit(msg.sender, address(this), msg.value);
    }

    function tokenFallback(address _from, uint _value, bytes _data) public pure {
        (_from);
        (_value);
        (_data);
    }

    function sweep(address _token, uint _amount) public returns (bool) {
        (_amount);
        return controller.sweeperOf(_token).delegatecall(msg.data);
    }
}


contract AbstractSweeper {
    WalletController public controller;

    constructor (address _controller) public {
        controller = WalletController(_controller);
    }

    function () public { revert(); }

    function sweep(address token, uint amount) public returns (bool);

    modifier canSweep() {
        if (!controller.authorized(msg.sender)) revert();
        if (controller.halted()) revert();
        _;
    }
}


contract DefaultSweeper is AbstractSweeper {

    constructor (address controller) public AbstractSweeper(controller) {}

    function sweep(address _token, uint _amount) public canSweep returns (bool) {
        bool success = false;
        address destination = controller.destination();

        if (_token != address(0)) {
            Token token = Token(_token);
            uint amount = _amount;
            if (amount > token.balanceOf(this)) {
                return false;
            }

            success = token.transfer(destination, amount);
        } else {
            uint amountInWei = _amount;
            if (amountInWei > address(this).balance) {
                return false;
            }
            success = destination.send(amountInWei);
        }

        if (success) {
            controller.logSweep(this, destination, _token, _amount);
        }
        return success;
    }
}


contract Token {
    function balanceOf(address a) public pure returns (uint) {
        (a);
        return 0;
    }

    function transfer(address a, uint val) public pure returns (bool) {
        (a);
        (val);
        return false;
    }
}


contract Casino {
    mapping(address => bool) public authorized;
}