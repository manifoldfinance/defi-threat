/**
 * Source Code first verified at https://etherscan.io on Friday, April 5, 2019
 (UTC) */

/*
    xgr_token_db.sol
    2.0.0
    
    Rajci 'iFA' Andor @ <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="076e6166476172746e686970666b6b6273296e68">[email protected]</a>
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
    /* Structures */
    struct allowance_s {
        uint256 amount;
        uint256 nonce;
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
    mapping(address => mapping(address => allowance_s)) public allowance;
    mapping(address => uint256) public balanceOf;
    mapping(uint256 => deposits_s) private deposits;
    mapping(address => uint256) public lockedBalances;
    address public tokenAddress;
    address public depositsAddress;
    uint256 public depositsCounter;
    uint256 public totalSupply;
    /* Constructor */
    /* Externals */
    function changeTokenAddress(address newTokenAddress) external onlyForOwner {
        tokenAddress = newTokenAddress;
    }
    function changeDepositsAddress(address newDepositsAddress) external onlyForOwner {
        depositsAddress = newDepositsAddress;
    }
    function openDeposit(address addr, uint256 amount, uint256 end, uint256 interestOnEnd,
        uint256 interestBeforeEnd, uint256 interestFee, uint256 multiplier, bool closeable) external onlyForDeposits returns(bool success, uint256 DID) {
        depositsCounter += 1;
        DID = depositsCounter;
        lockedBalances[addr] = safeAdd(lockedBalances[addr], amount);
        deposits[DID] = deposits_s(
            addr,
            amount,
            block.number,
            end,
            interestOnEnd,
            interestBeforeEnd,
            interestFee,
            multiplier,
            closeable,
            true
        );
        return (true, DID);
    }
    function closeDeposit(uint256 DID) external onlyForDeposits returns (bool success) {
        require( deposits[DID].valid );
        delete deposits[DID].valid;
        lockedBalances[deposits[DID].addr] = safeSub(lockedBalances[deposits[DID].addr], deposits[DID].amount);
        return true;
    }
    function transfer(address from, address to, uint256 amount, uint256 fee) external onlyForToken returns(bool success) {
        balanceOf[from] = safeSub(balanceOf[from], safeAdd(amount, fee));
        balanceOf[to] = safeAdd(balanceOf[to], amount);
        totalSupply = safeSub(totalSupply, fee);
        return true;
    }
    function increase(address owner, uint256 value) external onlyForToken returns(bool success) {
        balanceOf[owner] = safeAdd(balanceOf[owner], value);
        totalSupply = safeAdd(totalSupply, value);
        return true;
    }
    function decrease(address owner, uint256 value) external onlyForToken returns(bool success) {
        require( safeSub(balanceOf[owner], safeAdd(lockedBalances[owner], value)) >= 0 );
        balanceOf[owner] = safeSub(balanceOf[owner], value);
        totalSupply = safeSub(totalSupply, value);
        return true;
    }
    function setAllowance(address owner, address spender, uint256 amount, uint256 nonce) external onlyForToken returns(bool success) {
        allowance[owner][spender].amount = amount;
        allowance[owner][spender].nonce = nonce;
        return true;
    }
    /* Constants */
    function getAllowance(address owner, address spender) public constant returns(bool success, uint256 remaining, uint256 nonce) {
        return ( true, allowance[owner][spender].amount, allowance[owner][spender].nonce );
    }
    function getDeposit(uint256 UID) public constant returns(address addr, uint256 amount, uint256 start,
        uint256 end, uint256 interestOnEnd, uint256 interestBeforeEnd, uint256 interestFee, uint256 interestMultiplier, bool closeable, bool valid) {
        addr = deposits[UID].addr;
        amount = deposits[UID].amount;
        start = deposits[UID].start;
        end = deposits[UID].end;
        interestOnEnd = deposits[UID].interestOnEnd;
        interestBeforeEnd = deposits[UID].interestBeforeEnd;
        interestFee = deposits[UID].interestFee;
        interestMultiplier = deposits[UID].interestMultiplier;
        closeable = deposits[UID].closeable;
        valid = deposits[UID].valid;
    }
    /* Modifiers */
    modifier onlyForToken {
        require( msg.sender == tokenAddress );
        _;
    }
    modifier onlyForDeposits {
        require( msg.sender == depositsAddress );
        _;
    }
}