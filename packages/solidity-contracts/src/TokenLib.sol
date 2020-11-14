/**
 * Source Code first verified at https://etherscan.io on Friday, April 5, 2019
 (UTC) */

/*
    Gold Reserve Token
    
    xgr_token_lib.sol
    3.1.0
    
    Fusion Solutions KFT <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="ed8e8283998c8e99ad8b989e8482839e828198998482839ec38482">[email protected]</a>>
    
    Written by Andor Rajci, November 2018
*/
pragma solidity 0.4.18;

contract SafeMath {
    /* Internals */
    function safeAdd(uint256 a, uint256 b) internal pure returns(uint256) {
        if ( b > 0 ) {
            assert( a + b > a );
        }
        return a + b;
    }
    function safeSub(uint256 a, uint256 b) internal pure returns(uint256) {
        if ( b > 0 ) {
            assert( a - b < a );
        }
        return a - b;
    }
    function safeMul(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
    function safeDiv(uint256 a, uint256 b) internal pure returns(uint256) {
        return a / b;
    }
}

contract Owned {
    /* Variables */
    address public owner = msg.sender;
    /* Externals */
    function replaceOwner(address newOwner) external returns(bool success) {
        require( isOwner() );
        owner = newOwner;
        return true;
    }
    /* Internals */
    function isOwner() internal view returns(bool) {
        return owner == msg.sender;
    }
    /* Modifiers */
    modifier onlyForOwner {
        require( isOwner() );
        _;
    }
}

contract TokenDB is SafeMath, Owned {
    /*
        This is just an abstract contract with the necessary functions
    */
    /* Structures */
    /* Variables */
    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public lockedBalances;
    uint256 public totalSupply;
    /* Constructor */
    /* Externals */
    function changeDepositsAddress(address newDepositsAddress) external onlyForOwner {}
    function transfer(address from, address to, uint256 amount, uint256 fee) external returns(bool success) {}
    function increase(address owner, uint256 value) external returns(bool success) {}
    function setAllowance(address owner, address spender, uint256 amount, uint256 nonce) external returns(bool success) {}
    /* Constants */
    function getAllowance(address owner, address spender) public constant returns(bool success, uint256 remaining, uint256 nonce) {}
}

contract TokenLib is SafeMath, Owned {
    /**
    * @title Gold Reserve [XGR] token
    */
    /* Variables */
    string  public name = "GoldReserve";
    string  public symbol = "XGR";
    uint8   public decimals = 8;
    uint256 public transactionFeeRate   = 20; // 0.02 %
    uint256 public transactionFeeRateM  = 1e3; // 1000
    uint256 public transactionFeeMin    =   2000000; // 0.2 XGR
    uint256 public transactionFeeMax    = 200000000; // 2.0 XGR
    address public databaseAddress;
    address public depositsAddress;
    address public forkAddress;
    address public libAddress;
    /* Constructor */
    function TokenLib(address newDatabaseAddress, address newDepositAddress, address newFrokAddress, address newLibAddress) public {
        databaseAddress = newDatabaseAddress;
        depositsAddress = newDepositAddress;
        forkAddress = newFrokAddress;
        libAddress = newLibAddress;
    }
    /* Fallback */
    function () public {
        revert();
    }
    /* Externals */
    function changeDataBaseAddress(address newDatabaseAddress) external onlyForOwner {
        databaseAddress = newDatabaseAddress;
    }
    function changeDepositsAddress(address newDepositsAddress) external onlyForOwner {
        depositsAddress = newDepositsAddress;
    }
    function changeForkAddress(address newForkAddress) external onlyForOwner {
        forkAddress = newForkAddress;
    }
    function changeLibAddress(address newLibAddress) external onlyForOwner {
        libAddress = newLibAddress;
    }
    function changeFees(uint256 rate, uint256 rateMultiplier, uint256 min, uint256 max) external onlyForOwner {
        transactionFeeRate = rate;
        transactionFeeRateM = rateMultiplier;
        transactionFeeMin = min;
        transactionFeeMax = max;
    }
    function approve(address spender, uint256 amount) external returns (bool success) {
        _approve(spender, amount);
        return true;
    }
    function transfer(address to, uint256 amount) external returns (bool success) {
        bytes memory _data;
        _transfer(msg.sender, to, amount, true, _data);
        return true;
    }
    function transferFrom(address from, address to, uint256 amount) external returns (bool success) {
        if ( from != msg.sender ) {
            var (_success, _reamining, _nonce) = TokenDB(databaseAddress).getAllowance(from, msg.sender);
            require( _success );
            _reamining = safeSub(_reamining, amount);
            _nonce = safeAdd(_nonce, 1);
            require( TokenDB(databaseAddress).setAllowance(from, msg.sender, _reamining, _nonce) );
            AllowanceUsed(msg.sender, from, amount);
        }
        bytes memory _data;
        _transfer(from, to, amount, true, _data);
        return true;
    }
    function transfer(address to, uint256 amount, bytes extraData) external returns (bool success) {
        _transfer(msg.sender, to, amount, true, extraData);
        return true;
    }
    function mint(address owner, uint256 value) external returns (bool success) {
        require( msg.sender == forkAddress || msg.sender == depositsAddress );
        _mint(owner, value);
        return true;
    }
    /* Internals */
    function _transfer(address from, address to, uint256 amount, bool fee, bytes extraData) internal {
        bool _success;
        uint256 _fee;
        uint256 _payBack;
        uint256 _amount = amount;
        uint256 balance = TokenDB(databaseAddress).balanceOf(from);
        uint256 lockedBalance = TokenDB(databaseAddress).lockedBalances(from);
        balance = safeSub(balance, lockedBalance);
        require( _amount > 0 && balance > 0 );
        require( from != 0x00 && to != 0x00 );
        if( fee ) {
            (_success, _fee) = getTransactionFee(amount);
            require( _success );
            if ( balance == amount ) {
                _amount = safeSub(amount, _fee);
            }
        }
        require( balance >= safeAdd(_amount, _fee) );
        if ( fee ) {
            Burn(from, _fee);
        }
        Transfer(from, to, _amount);
        Transfer2(from, to, _amount, extraData);
        require( TokenDB(databaseAddress).transfer(from, to, _amount, _fee) );
    }
    function _mint(address owner, uint256 value) internal {
        require( TokenDB(databaseAddress).increase(owner, value) );
        Mint(owner, value);
    }
    function _approve(address spender, uint256 amount) internal {
        require( msg.sender != spender );
        require( TokenDB(databaseAddress).setAllowance(msg.sender, spender, amount, 0x00) );
        Approval(msg.sender, spender, amount);
    }
    /* Constants */
    function allowance(address owner, address spender) public constant returns (uint256 remaining, uint256 nonce) {
        var (_success, _remaining, _nonce) = TokenDB(databaseAddress).getAllowance(owner, spender);
        require( _success );
        return (_remaining, _nonce);
    }
    function getTransactionFee(uint256 value) public constant returns (bool success, uint256 fee) {
        fee = safeMul(value, transactionFeeRate) / transactionFeeRateM / 100;
        if ( fee > transactionFeeMax ) { fee = transactionFeeMax; }
        else if ( fee < transactionFeeMin ) { fee = transactionFeeMin; }
        return (true, fee);
    }
    function balanceOf(address owner) public constant returns (uint256 value) {
        return TokenDB(databaseAddress).balanceOf(owner);
    }
    function balancesOf(address owner) public constant returns (uint256 balance, uint256 lockedAmount) {
        return (TokenDB(databaseAddress).balanceOf(owner), TokenDB(databaseAddress).lockedBalances(owner));
    }
    function totalSupply() public constant returns (uint256 value) {
        return TokenDB(databaseAddress).totalSupply();
    }
    /* Events */
    event AllowanceUsed(address indexed spender, address indexed owner, uint256 indexed value);
    event Mint(address indexed addr, uint256 indexed value);
    event Burn(address indexed addr, uint256 indexed value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Transfer2(address indexed from, address indexed to, uint256 indexed value, bytes data);
}