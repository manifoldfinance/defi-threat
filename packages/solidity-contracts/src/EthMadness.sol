/**
 * Source Code first verified at https://etherscan.io on Monday, March 18, 2019
 (UTC) */

pragma solidity ^0.5.0;

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

contract EthMadness is Ownable {
    
    // Represents the submission to the contest.
    struct Entrant {
        // The user who submitted this entry
        address submitter;
        
        // The "index" of this entry. Used to break ties incase two submissions are the same. (earlier submission wins)
        uint48 entryIndex;
    }
    
    // Represents a current top score in the contest
    struct TopScore {
        // The index of this entry (used for tie-breakas a de-dups)
        uint48 entryIndex;

        // This bracket's score
        uint32 score;

        // The total point differential for this bracket
        uint64 difference;

        // The account which submitted this bracket
        address submitter;
    }
    
    // Represents the results of the contest. 
    struct Result {
        // The encoded results of the tournament
        bytes16 winners;

        // Team A's score in the final
        uint8 scoreA;

        // Team B's score in the final
        uint8 scoreB;

        // Whether or not this is the final Results (used to tell if a vote is real or not)
        bool isFinal;
    }
    
    // Represents the various states that the contest will go through.
    enum ContestState {
        // The contest is open for people to submit entries. Oracles can also be added during this period.
        OPEN_FOR_ENTRIES,
        
        // The tournament is in progress, no more entries can be received and no oracles can vote
        TOURNAMENT_IN_PROGRESS,
        
        // The tournament is over and we're waiting for all the oracles to submit the results
        WAITING_FOR_ORACLES,
        
        // The oracels have submitted the results and we're waiting for winners to claim their prize
        WAITING_FOR_WINNING_CLAIMS,
        
        // The contest has completed and the winners have been paid out
        COMPLETED
    }
    
    // Maximum number of entries that will be allowed
    uint constant MAX_ENTRIES = 2**48;
    
    // The number of entries which have been received.
    uint48 entryCount = 0;
    
    // Map of the encoded entry to the user who crreated it.
    mapping (uint256 => Entrant) public entries;
    
    // The times where we're allowed to transition the contract's state
    mapping (uint => uint) public transitionTimes;
    
    // The current state of the contest
    ContestState public currentState;
    
    // The recorded votes of our oracles
    mapping (address => Result) public oracleVotes;
    
    // The oracles who will submit the results of the tournament
    address[] public oracles;
    
    // The maximum number of oracles we'll allow vote in our contest
    uint constant MAX_ORACLES = 10;
    
    // The final result of the tournament that the oracles agreed on
    Result public finalResult;
    
    // Keeps the current top 3 best scores and who submitted them. When the contest ends, they'll be paid out
    TopScore[3] public topThree;
    
    // The address of the ERC20 token that defines our prize
    address public prizeERC20TokenAddress;
    
    // The amount of the prize to reward
    uint public prizeAmount;
    
    // Event emitted when a new entry gets submitted to the contest
    event EntrySubmitted(
        // The account who submitted this bracket
        address indexed submitter,

        // A compressed representation of the entry combining the picks and final game scores
        uint256 indexed entryCompressed,

        // The order this entry was received. Used for tiebreaks
        uint48 indexed entryIndex,

        // Optional bracket name provided by the submitter
        string bracketName
    );

    // Constructs a new instance of the EthMadness contract with the given transition times
    constructor(uint[] memory times, address erc20Token, uint erc20Amount) public {
        
        // Initialize the oracles array with the sender's address
        oracles = [msg.sender];
        
        // Set up our prize info
        prizeERC20TokenAddress = erc20Token;
        prizeAmount = erc20Amount;
        
        // Set up our transition times
        require(times.length == 4);
        transitionTimes[uint(ContestState.TOURNAMENT_IN_PROGRESS)] = times[0];
        transitionTimes[uint(ContestState.WAITING_FOR_ORACLES)] = times[1];
        transitionTimes[uint(ContestState.WAITING_FOR_WINNING_CLAIMS)] = times[2];
        transitionTimes[uint(ContestState.COMPLETED)] = times[3];
        
        // The initial state should be allowing people to make entries
        currentState = ContestState.OPEN_FOR_ENTRIES;
    }

    // Gets the total number of entries we've received
    function getEntryCount() public view returns (uint256) {
        return entryCount;
    }
    
    // Gets the number of Oracles we have registered
    function getOracleCount() public view returns(uint256) {
        return oracles.length;
    }
    
    // Returns the transition times for our contest
    function getTransitionTimes() public view returns (uint256, uint256, uint256, uint256) {
        return (
            transitionTimes[uint(ContestState.TOURNAMENT_IN_PROGRESS)],
            transitionTimes[uint(ContestState.WAITING_FOR_ORACLES)],
            transitionTimes[uint(ContestState.WAITING_FOR_WINNING_CLAIMS)],
            transitionTimes[uint(ContestState.COMPLETED)]
        );
    }
    
    // Internal function for advancing the state of the bracket
    function advanceState(ContestState nextState) private {
        require(uint(nextState) == uint(currentState) + 1, "Can only advance state by 1");
        require(now > transitionTimes[uint(nextState)], "Transition time hasn't happened yet");
        
        currentState = nextState;
    }

    // Helper to make sure the picks submitted are legal
    function arePicksOrResultsValid(bytes16 picksOrResults) public pure returns (bool) {
        // Go through and make sure that this entry has 1 pick for each game
        for (uint8 gameId = 0; gameId < 63; gameId++) {
            uint128 currentPick = extractResult(picksOrResults, gameId);
            if (currentPick != 2 && currentPick != 1) {
                return false;
            }
        }

        return true;
    }
    
    // Submits a new entry to the tournament
    function submitEntry(bytes16 picks, uint64 scoreA, uint64 scoreB, string memory bracketName) public {
        require(currentState == ContestState.OPEN_FOR_ENTRIES, "Must be in the open for entries state");
        require(arePicksOrResultsValid(picks), "The supplied picks are not valid");

        // Do some work to encode the picks and scores into a single uint256 which becomes a key
        uint256 scoreAShifted = uint256(scoreA) * (2 ** (24 * 8));
        uint256 scoreBShifted = uint256(scoreB) * (2 ** (16 * 8));
        uint256 picksAsNumber = uint128(picks);
        uint256 entryCompressed = scoreAShifted | scoreBShifted | picksAsNumber;

        require(entries[entryCompressed].submitter == address(0), "This exact bracket & score has already been submitted");
        
        // Emit the event that this entry was received and save the entry
        emit EntrySubmitted(msg.sender, entryCompressed, entryCount, bracketName);
        Entrant memory entrant = Entrant(msg.sender, entryCount);
        entries[entryCompressed] = entrant;
        entryCount++;
    }

    // Adds an allowerd oracle who will vote on the results of the contest. Only the contract owner can do this
    // and it can only be done while the tournament is still open for entries
    function addOracle(address oracle) public onlyOwner {
        require(currentState == ContestState.OPEN_FOR_ENTRIES, "Must be accepting entries");
        require(oracles.length < MAX_ORACLES - 1, "Must be less than max number of oracles");
        oracles.push(oracle);
    }

    // In case something goes wrong, allow the owner to eject from the contract
    // but only while picks are still being made or after the contest completes
    function refundRemaining(uint256 amount) public onlyOwner {
        require(currentState == ContestState.OPEN_FOR_ENTRIES || currentState == ContestState.COMPLETED, "Must be accepting entries");
        
        IERC20 erc20 = IERC20(prizeERC20TokenAddress);
        erc20.transfer(msg.sender, amount);
    }
    
    // Submits a new oracle's vote describing the results of the tournament
    function submitOracleVote(uint oracleIndex, bytes16 winners, uint8 scoreA, uint8 scoreB) public {
        require(currentState == ContestState.WAITING_FOR_ORACLES, "Must be in waiting for oracles state");
        require(oracles[oracleIndex] == msg.sender, "Wrong oracle index");
        require(arePicksOrResultsValid(winners), "Results are not valid");
        oracleVotes[msg.sender] = Result(winners, scoreA, scoreB, true);
    }
    
    // Close the voting and set the final result. Pass in what should be the consensus agreed by the
    // 70% of the oracles
    function closeOracleVoting(bytes16 winners, uint8 scoreA, uint8 scoreB) public {
        require(currentState == ContestState.WAITING_FOR_ORACLES);

        // Count up how many oracles agree with this result
        uint confirmingOracles = 0;
        for (uint i = 0; i < oracles.length; i++) {
            Result memory oracleVote = oracleVotes[oracles[i]];
            if (oracleVote.isFinal &&
                oracleVote.winners == winners &&
                oracleVote.scoreA == scoreA &&
                oracleVote.scoreB == scoreB) {

                confirmingOracles++;
            }
        }
        
        // Require 70%+ of Oracles to have voted and agree on the result
        uint percentAggreement = (confirmingOracles * 100) / oracles.length;
        require(percentAggreement > 70, "To close oracle voting, > 70% of oracles must agree");
        
        // Change the state and set our final result which will be used to compute scores
        advanceState(ContestState.WAITING_FOR_WINNING_CLAIMS);
        finalResult = Result(winners, scoreA, scoreB, true);
    }
    
    // Closes the entry period and marks that the actual tournament is in progress
    function markTournamentInProgress() public {
        advanceState(ContestState.TOURNAMENT_IN_PROGRESS);
        
        require(oracles.length > 0, "Must have at least 1 oracle registered");
        
        // Require that we have the amount of funds locked in the contract we expect
        IERC20 erc20 = IERC20(prizeERC20TokenAddress);
        require(erc20.balanceOf(address(this)) >= prizeAmount, "Must have a balance in this contract");
    }
    
    // Mark that the tournament has completed and oracles can start submitting results
    function markTournamentFinished() public {
        advanceState(ContestState.WAITING_FOR_ORACLES);
    }
    
    // After the oracles have voted and winners have claimed their prizes, this closes the contest and
    // pays out the winnings to the 3 winners
    function closeContestAndPayWinners() public {
        advanceState(ContestState.COMPLETED);
        require(topThree[0].submitter != address(0), "Not enough claims");
        require(topThree[1].submitter != address(0), "Not enough claims");
        require(topThree[2].submitter != address(0), "Not enough claims");
        
        uint firstPrize = (prizeAmount * 70) / 100;
        uint secondPrize = (prizeAmount * 20) / 100;
        uint thirdPrize = (prizeAmount * 10) / 100;
        IERC20 erc20 = IERC20(prizeERC20TokenAddress);
        erc20.transfer(topThree[0].submitter, firstPrize);
        erc20.transfer(topThree[1].submitter, secondPrize);
        erc20.transfer(topThree[2].submitter, thirdPrize);
    }
    
    // Scores an entry and places it in the right sort order
    function scoreAndSortEntry(uint256 entryCompressed, bytes16 results, uint64 scoreAActual, uint64 scoreBActual) private returns (uint32) {
        require(currentState == ContestState.WAITING_FOR_WINNING_CLAIMS, "Must be in the waiting for claims state");
        require(entries[entryCompressed].submitter != address(0), "The entry must have actually been submitted");

        // Pull out the pick information from the compressed entry
        bytes16 picks = bytes16(uint128((entryCompressed & uint256((2 ** 128) - 1))));
        uint256 shifted = entryCompressed / (2 ** 128); // shift over 128 bits
        uint64 scoreA = uint64((shifted & uint256((2 ** 64) - 1)));
        shifted = entryCompressed / (2 ** 192);
        uint64 scoreB = uint64((shifted & uint256((2 ** 64) - 1)));

        // Compute the score and the total difference
        uint32 score = scoreEntry(picks, results);
        uint64 difference = computeFinalGameDifference(scoreA, scoreB, scoreAActual, scoreBActual);

        // Make a score and place it in the right sort order
        TopScore memory scoreResult = TopScore(entries[entryCompressed].entryIndex, score, difference, entries[entryCompressed].submitter);
        if (isScoreBetter(scoreResult, topThree[0])) {
            topThree[2] = topThree[1];
            topThree[1] = topThree[0];
            topThree[0] = scoreResult;
        } else if (isScoreBetter(scoreResult, topThree[1])) {
            topThree[2] = topThree[1];
            topThree[1] = scoreResult;
        } else if (isScoreBetter(scoreResult, topThree[2])) {
            topThree[2] = scoreResult;
        }
        
        return score;
    }
    
    function claimTopEntry(uint256 entryCompressed) public {
        require(currentState == ContestState.WAITING_FOR_WINNING_CLAIMS, "Must be in the waiting for winners state");
        require(finalResult.isFinal, "The final result must be marked as final");
        scoreAndSortEntry(entryCompressed, finalResult.winners, finalResult.scoreA, finalResult.scoreB);
    }
    
    function computeFinalGameDifference(
        uint64 scoreAGuess, uint64 scoreBGuess, uint64 scoreAActual, uint64 scoreBActual) private pure returns (uint64) {
        
        // Don't worry about overflow here, not much you can really do with it
        uint64 difference = 0;
        difference += ((scoreAActual > scoreAGuess) ? (scoreAActual - scoreAGuess) : (scoreAGuess - scoreAActual));
        difference += ((scoreBActual > scoreBGuess) ? (scoreBActual - scoreBGuess) : (scoreBGuess - scoreBActual));
        return difference;
    }
    
    // Gets the bit at index n in a
    function getBit16(bytes16 a, uint16 n) private pure returns (bool) {
        uint128 mask = uint128(2) ** n;
        return uint128(a) & mask != 0;
    }
    
    // Sets the bit at index n to 1 in a
    function setBit16(bytes16 a, uint16 n) private pure returns (bytes16) {
        uint128 mask = uint128(2) ** n;
        return a | bytes16(mask);
    }
    
    // Sets the bit at index n to 0 in a
    function clearBit16(bytes16 a, uint16 n) private pure returns (bytes16) {
        uint128 mask = uint128(2) ** n;
        mask = mask ^ uint128(-1);
        return a & bytes16(mask);
    }
    
    // Returns either 0 if there is no possible winner, 1 if team B is chosen, or 2 if team A is chosen
    function extractResult(bytes16 a, uint8 n) private pure returns (uint128) {
        uint128 mask = uint128(0x00000000000000000000000000000003) * uint128(2) ** (n * 2);
        uint128 masked = uint128(a) & mask;
        
        // Shift back to get either 0, 1 or 2
        return (masked / (uint128(2) ** (n * 2)));
    }
    
    // Gets which round a game belongs to based on its id
    function getRoundForGame(uint8 gameId) private pure returns (uint8) {
        if (gameId < 32) {
            return 0;
        } else if (gameId < 48) {
            return 1;
        } else if (gameId < 56) {
            return 2;
        } else if (gameId < 60) {
            return 3;
        } else if (gameId < 62) {
            return 4;
        } else {
            return 5;
        }
    }
    
    // Gets the first game in a round given the round number
    function getFirstGameIdOfRound(uint8 round) private pure returns (uint8) {
        if (round == 0) {
            return 0;
        } else if (round == 1) {
            return 32;
        } else if (round == 2) {
            return 48;
        } else if (round == 3) {
            return 56;
        } else if (round == 4) {
            return 60;
        } else {
            return 62;
        }
    }
    
    // Looks at two scores and decided whether newScore is a better score than old score
    function isScoreBetter(TopScore memory newScore, TopScore memory oldScore) private pure returns (bool) {
        if (newScore.score > oldScore.score) {
            return true;
        }
        
        if (newScore.score < oldScore.score) {
            return false;
        }
        
        // Case where we have a tie
        if (newScore.difference < oldScore.difference) {
            return true;
        }
        
        if (newScore.difference < oldScore.difference) {
            return false;
        }

        require(newScore.entryIndex != oldScore.entryIndex, "This entry has already claimed a prize");
        
        // Crazy case where we have the same score and same diference. Return the earlier entry as the winnner
        return newScore.entryIndex < oldScore.entryIndex;
    }
    
    // Scores an entry given the picks and the results
    function scoreEntry(bytes16 picks, bytes16 results) private pure returns (uint32) {
        uint32 score = 0;
        uint8 round = 0;
        bytes16 currentPicks = picks;
        for (uint8 gameId = 0; gameId < 63; gameId++) {
            
            // Update which round we're in when on the transitions
            round = getRoundForGame(gameId);
            
            uint128 currentPick = extractResult(currentPicks, gameId);
            if (currentPick == extractResult(results, gameId)) {
                score += (uint32(2) ** round);
            } else if (currentPick != 0) { // If we actually had a pick, propagate forward
                // Mark all the future currentPicks which required this team winning as null
                uint16 currentPickId = (gameId * 2) + (currentPick == 2 ? 1 : 0);
                for (uint8 futureRound = round + 1; futureRound < 6; futureRound++) {
                    uint16 currentPickOffset = currentPickId - (getFirstGameIdOfRound(futureRound - 1) * 2);
                    currentPickId = (getFirstGameIdOfRound(futureRound) * 2) + (currentPickOffset / 2);
                    
                    bool pickedLoser = getBit16(currentPicks, currentPickId);
                    if (pickedLoser) {
                        currentPicks = clearBit16(currentPicks, currentPickId);
                    } else {
                        break;
                    }
                }
            }
        }
        
        return score;
    }
}