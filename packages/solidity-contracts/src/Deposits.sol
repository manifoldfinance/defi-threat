/**
 * Source Code first verified at https://etherscan.io on Friday, April 5, 2019
 (UTC) */

/*
    xgr_deposits.sol
    2.0.3
    
    Rajci 'iFA' Andor @ <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="98f1fef9d8feedebf1f7f6eff9f4f4fdecb6f1f7">[email protected]</a>
*/
pragma solidity 0.4.18;

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

contract TokenDB is SafeMath, Owned {
    /*
        This is just an abstract contract with the necessary functions
    */
    /* Structures */
    /* Variables */
    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public lockedBalances;
    address public tokenAddress;
    address public depositsAddress;
    /* Constructor */
    /* Externals */
    function openDeposit(address addr, uint256 amount, uint256 end, uint256 interestOnEnd,
        uint256 interestBeforeEnd, uint256 interestFee, uint256 multiplier, bool closeable) external returns(bool success, uint256 DID) {}
    function closeDeposit(uint256 DID) external returns (bool success) {}
    /* Constants */
    function getDeposit(uint256 UID) public constant returns(address addr, uint256 amount, uint256 start,
        uint256 end, uint256 interestOnEnd, uint256 interestBeforeEnd, uint256 interestFee, uint256 interestMultiplier, bool closeable, bool valid) {}
}

contract Token {
    /*
        This is just an abstract contract with the necessary functions
    */
    function mint(address owner, uint256 value) external returns (bool success) {}
}

contract Deposits is Owned, SafeMath {
    /* Structures */
    struct depositTypes_s {
        uint256 blockDelay;
        uint256 baseFunds;
        uint256 interestRateOnEnd;
        uint256 interestRateBeforeEnd;
        uint256 interestFee;
        bool closeable;
        bool valid;
    }
    struct deposits_s {
        address addr;
        uint256 amount;
        uint256 start;
        uint256 end;
        uint256 interestOnEnd;
        uint256 interestBeforeEnd;
        uint256 interestFee;
        uint256 interestMultiplier;
        bool    closeable;
        bool    valid;
    }
    /* Variables */
    mapping(uint256 => depositTypes_s) public depositTypes;
    uint256 public depositTypesCounter;
    address public tokenAddress;
    address public databaseAddress;
    address public founderAddress;
    uint256 public interestMultiplier = 1e3;
    /* Constructor */
    function Deposits(address TokenAddress, address DatabaseAddress, address FounderAddress) {
        tokenAddress = TokenAddress;
        databaseAddress = DatabaseAddress;
        founderAddress = FounderAddress;
    }
    /* Externals */
    function changeDataBaseAddress(address newDatabaseAddress) external onlyForOwner {
        databaseAddress = newDatabaseAddress;
    }
    function changeTokenAddress(address newTokenAddress) external onlyForOwner {
        tokenAddress = newTokenAddress;
    }
    function changeFounderAddresss(address newFounderAddress) external onlyForOwner {
        founderAddress = newFounderAddress;
    }
    function addDepositType(uint256 blockDelay, uint256 baseFunds, uint256 interestRateOnEnd,
        uint256 interestRateBeforeEnd, uint256 interestFee, bool closeable) external onlyForOwner {
        depositTypesCounter += 1;
        uint256 DTID = depositTypesCounter;
        depositTypes[DTID] = depositTypes_s(
            blockDelay,
            baseFunds,
            interestRateOnEnd,
            interestRateBeforeEnd,
            interestFee,
            closeable,
            true
        );
        EventNewDepositType(
            DTID,
            blockDelay,
            baseFunds,
            interestRateOnEnd,
            interestRateBeforeEnd,
            interestFee,
            interestMultiplier,
            closeable
        );
    }
    function rekoveDepositType(uint256 DTID) external onlyForOwner {
        delete depositTypes[DTID].valid;
        EventRevokeDepositType(DTID);
    }
    function placeDeposit(uint256 amount, uint256 depositType) external checkSelf {
        require( depositTypes[depositType].valid );
        require( depositTypes[depositType].baseFunds <= amount );
        uint256 balance = TokenDB(databaseAddress).balanceOf(msg.sender);
        uint256 locked = TokenDB(databaseAddress).lockedBalances(msg.sender);
        require( safeSub(balance, locked) >= amount );
        var (success, DID) = TokenDB(databaseAddress).openDeposit(
            msg.sender,
            amount,
            safeAdd(block.number, depositTypes[depositType].blockDelay),
            depositTypes[depositType].interestRateOnEnd,
            depositTypes[depositType].interestRateBeforeEnd,
            depositTypes[depositType].interestFee,
            interestMultiplier,
            depositTypes[depositType].closeable
        );
        require( success );
        EventNewDeposit(DID, msg.sender);
    }
    function closeDeposit(address beneficary, uint256 DID) external checkSelf {
        address _beneficary = beneficary;
        if ( _beneficary == 0x00 ) {
            _beneficary = msg.sender;
        }
        var (addr, amount, start, end, interestOnEnd, interestBeforeEnd, interestFee,
            interestM, closeable, valid) = TokenDB(databaseAddress).getDeposit(DID);
        _closeDeposit(_beneficary, DID, deposits_s(addr, amount, start, end, interestOnEnd, interestBeforeEnd, interestFee, interestM, closeable, valid));
    }
    /* Internals */
    function _closeDeposit(address beneficary, uint256 DID, deposits_s data) internal {
        require( data.valid && data.addr == msg.sender );
        var (interest, interestFee) = _calculateInterest(data);
        if ( interest > 0 ) {
            require( Token(tokenAddress).mint(beneficary, interest) );
        }
        if ( interestFee > 0 ) {
            require( Token(tokenAddress).mint(founderAddress, interestFee) );
        }
        require( TokenDB(databaseAddress).closeDeposit(DID) );
        EventDepositClosed(DID, msg.sender, beneficary, interest, interestFee);
    }
    function _calculateInterest(deposits_s data) internal view returns (uint256 interest, uint256 interestFee) {
        if ( ! data.valid || data.amount <= 0 || data.end <= data.start || block.number <= data.start ) { return (0, 0); }
        uint256 rate;
        uint256 delay;
        if ( data.end <= block.number ) {
            rate = data.interestOnEnd;
            delay = safeSub(data.end, data.start);
        } else {
            require( data.closeable );
            rate = data.interestBeforeEnd;
            delay = safeSub(block.number, data.start);
        }
        if ( rate == 0 ) { return (0, 0); }
        interest = safeDiv(safeMul(safeDiv(safeDiv(safeMul(data.amount, rate), 100), data.interestMultiplier), delay), safeSub(data.end, data.start));
        if ( data.interestFee > 0 && interest > 0) {
            interestFee = safeDiv(safeDiv(safeMul(interest, data.interestFee), 100), data.interestMultiplier);
        }
        if ( interestFee > 0 ) {
            interest = safeSub(interest, interestFee);
        }
    }
    /* Constants */
    function calculateInterest(uint256 DID) public view returns(uint256, uint256) {
        var (addr, amount, start, end, interestOnEnd, interestBeforeEnd, interestFee,
            interestM, closeable, valid) = TokenDB(databaseAddress).getDeposit(DID);
        return _calculateInterest(deposits_s(addr, amount, start, end, interestOnEnd, interestBeforeEnd, interestFee, interestM, closeable, valid));
    }
    /* Modifiers */
    modifier checkSelf {
        require( TokenDB(databaseAddress).tokenAddress() == tokenAddress );
        require( TokenDB(databaseAddress).depositsAddress() == address(this) );
        _;
    }
    /* Events */
    event EventNewDepositType(uint256 indexed DTID, uint256 blockDelay, uint256 baseFunds,
        uint256 interestRateOnEnd, uint256 interestRateBeforeEnd, uint256 interestFee, uint256 interestMultiplier, bool closeable);
    event EventRevokeDepositType(uint256 indexed DTID);
    event EventNewDeposit(uint256 indexed DID, address owner);
    event EventDepositClosed(uint256 indexed DID, address owner, address beneficary, uint256 interest, uint256 interestFee);
}