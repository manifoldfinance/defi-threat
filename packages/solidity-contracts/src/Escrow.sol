pragma solidity ^0.5.7;

import "Ownable.sol";
import "IERC20.sol";
import "SafeMath.sol";


contract Escrow is Ownable {

    using SafeMath for uint;

    event Allocate(address indexed _beneficiary, uint amount, uint releaseDate);
    event Withdraw(address indexed _beneficiary, uint amount, uint time);
    event Release(address indexed _beneficiary, uint amount, uint time);
    
    struct TokenLock {
        uint amount;
        uint releaseDate;
    }

    // Global variables
    uint private timeLockPeriod = 3 * 365 days; // 3 years
    uint public lockedContributions;

    IERC20 public idealCoinToken;

    mapping (address => TokenLock[]) public allocations;

    constructor(address _idealCoinToken) public Ownable() {
        require(_idealCoinToken != address(0), "Cannot initialize Escrow contract with zero address token");
        lockedContributions = 0;
        idealCoinToken = IERC20(_idealCoinToken); 
    }

    // Allocate tokens to an address
    function allocate(address _beneficiary, uint _amount) public onlyOwner {
        require(_beneficiary != address(0), "Cannot assign tokens to zero address");
        require(_amount > 0, "Cannot assign zero tokens");
        require(lockedContributions.add(_amount) <= idealCoinToken.balanceOf(address(this)), "Insufficient contract token balance to allocate additional funds to escrow");
        
        // Create new token lock:
        TokenLock memory newTokenLock;
        newTokenLock.amount = _amount;
        newTokenLock.releaseDate = now + timeLockPeriod;
        allocations[_beneficiary].push(newTokenLock);

        lockedContributions = lockedContributions.add(_amount); 
        emit Allocate(_beneficiary, _amount, now + timeLockPeriod);
    }

    // Withdraw available tokens allocated to msg.sender
    function withdraw() public returns (uint) {
        require(allocations[msg.sender].length > 0, "Account has not been allocated any tokens");
        uint availableTokens = 0;
        
        for (uint i = 0; i < allocations[msg.sender].length; i++){
            if (block.timestamp > allocations[msg.sender][i].releaseDate){
                availableTokens = availableTokens.add(allocations[msg.sender][i].amount);
                allocations[msg.sender][i].amount = 0;
            }
        }

        require(availableTokens > 0, "No tokens currently available for withdrawal");
        require(idealCoinToken.transfer(msg.sender, availableTokens), "Failed to transfer tokens to contributor");
        lockedContributions = lockedContributions.sub(availableTokens);
        emit Withdraw(msg.sender, availableTokens, now);
        return availableTokens;
    }

    // Force release escrowed tokens to a specific beneficiary 
    function release(address _beneficiary) public onlyOwner returns (uint) {
        require(allocations[_beneficiary].length > 0, "Account has not been allocated any tokens");
        uint availableTokens = 0;
        
        for (uint i = 0; i < allocations[_beneficiary].length; i++){
            availableTokens = availableTokens.add(allocations[_beneficiary][i].amount);
            allocations[_beneficiary][i].amount = 0;
        }
        
        require(availableTokens > 0, "No tokens currently available for withdrawal");
        require(idealCoinToken.transfer(_beneficiary, availableTokens), "Failed to transfer tokens");
        lockedContributions = lockedContributions.sub(availableTokens);
        emit Withdraw(_beneficiary, availableTokens, now);
        emit Release(_beneficiary, availableTokens, now);
        return availableTokens;
    }

    // Get the unalloacted balance of tokens held by the contract
    function getAvailableBalance() public view returns (uint) {
        return idealCoinToken.balanceOf(address(this)).sub(lockedContributions);
    }

    // Withdraw unallocated tokens back to the owner account
    function withdrawUnallocatedTokens() public onlyOwner {
        uint unallocatedBalance = getAvailableBalance();
        require(unallocatedBalance > 0, "All tokens are locked in escrow");
        idealCoinToken.transfer(owner(), unallocatedBalance);
    }

    // Get the amount of tokens and release times for tokens allocated to an account
    function lockedBalances(address _beneficiary) public view returns (uint[] memory, uint[] memory) {
        uint[] memory amounts = new uint[](allocations[_beneficiary].length);
        uint[] memory releaseDates = new uint[](allocations[_beneficiary].length);

        for (uint i = 0; i < allocations[_beneficiary].length; i++) {
            TokenLock storage tokenLock = allocations[_beneficiary][i];
            amounts[i] = tokenLock.amount;
            releaseDates[i] = tokenLock.releaseDate;
        }

        return (amounts, releaseDates);
    }
}