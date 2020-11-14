/**
 * Source Code first verified at https://etherscan.io on Tuesday, March 19, 2019
 (UTC) */

pragma solidity 0.5.0;

// File: contracts/ownerships/ClusterRole.sol

contract ClusterRole {
    address payable private _cluster;

    /**
     * @dev Throws if called by any account other than the cluster.
     */
    modifier onlyCluster() {
        require(isCluster(), "onlyCluster: only cluster can call this method.");
        _;
    }

    /**
     * @dev The Cluster Role sets the original `cluster` of the contract to the sender
     * account.
     */
    constructor () internal {
        _cluster = msg.sender;
    }

    /**
     * @return the address of the cluster contract.
     */
    function cluster() public view returns (address payable) {
        return _cluster;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isCluster() public view returns (bool) {
        return msg.sender == _cluster;
    }
}

// File: contracts/ownerships/Roles.sol

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

// File: contracts/ownerships/ArbiterRole.sol

contract ArbiterRole is ClusterRole {
    using Roles for Roles.Role;

    uint256 private _arbitersAmount;

    event ArbiterAdded(address indexed arbiter);
    event ArbiterRemoved(address indexed arbiter);

    Roles.Role private _arbiters;

    modifier onlyArbiter() {
        require(isArbiter(msg.sender), "onlyArbiter: only arbiter can call this method.");
        _;
    }

    // -----------------------------------------
    // EXTERNAL
    // -----------------------------------------

    function addArbiter(address arbiter) public onlyCluster {
        _addArbiter(arbiter);
        _arbitersAmount++;
    }

    function removeArbiter(address arbiter) public onlyCluster {
        _removeArbiter(arbiter);
        _arbitersAmount--;
    }

    // -----------------------------------------
    // INTERNAL
    // -----------------------------------------

    function _addArbiter(address arbiter) private {
        _arbiters.add(arbiter);
        emit ArbiterAdded(arbiter);
    }

    function _removeArbiter(address arbiter) private {
        _arbiters.remove(arbiter);
        emit ArbiterRemoved(arbiter);
    }

    // -----------------------------------------
    // GETTERS
    // -----------------------------------------

    function isArbiter(address account) public view returns (bool) {
        return _arbiters.has(account);
    }

    function getArbitersAmount() external view returns (uint256) {
        return _arbitersAmount;
    }
}

// File: contracts/interfaces/ICluster.sol

interface ICluster {
    function solveDispute(address crowdsale, bytes32 milestoneHash, address investor, bool investorWins) external;
}

// File: contracts/ArbitersPool.sol

contract ArbitersPool is ArbiterRole {
    uint256 private _disputsAmount;
    uint256 private constant _necessaryVoices = 3;

    enum DisputeStatus { WAITING, SOLVED }
    enum Choice { OPERATOR_WINS, INVESTOR_WINS }

    ICluster private _clusterInterface;

    struct Vote {
        address arbiter;
        Choice choice;
    }

    struct Dispute {
        address investor;
        address crowdsale;
        bytes32 milestoneHash;
        string reason;
        uint256 votesAmount;
        DisputeStatus status;
        mapping(address => bool) hasVoted;
        mapping(uint256 => Vote) choices;
    }

    mapping(bytes32 => uint256[]) private _disputesByMilestone;
    mapping(uint256 => Dispute) private _disputesById;

    event Voted(uint256 indexed disputeId, address indexed arbiter, Choice choice);
    event NewDisputeCreated(uint256 disputeId, address indexed crowdsale, bytes32 indexed hash, address indexed investor);
    event DisputeSolved(uint256 disputeId, Choice choice, address indexed crowdsale, bytes32 indexed hash, address indexed investor);

    constructor () public {
        _clusterInterface = ICluster(msg.sender);
    }

    function createDispute(bytes32 milestoneHash, address crowdsale, address investor, string calldata reason) external onlyCluster returns (uint256) {
        Dispute memory dispute = Dispute(
            investor,
            crowdsale,
            milestoneHash,
            reason,
            0,
            DisputeStatus.WAITING
        );

        uint256 thisDisputeId = _disputsAmount;
        _disputsAmount++;

        _disputesById[thisDisputeId] = dispute;
        _disputesByMilestone[milestoneHash].push(thisDisputeId);

        emit NewDisputeCreated(thisDisputeId, crowdsale, milestoneHash, investor);

        return thisDisputeId;
    }

    function voteDispute(uint256 id, Choice choice) public onlyArbiter {
        require(_disputsAmount > id, "voteDispute: invalid number of dispute.");
        require(_disputesById[id].hasVoted[msg.sender] == false, "voteDispute: arbiter was already voted.");
        require(_disputesById[id].status == DisputeStatus.WAITING, "voteDispute: dispute was already closed.");
        require(_disputesById[id].votesAmount < _necessaryVoices, "voteDispute: dispute was already voted and finished.");

        _disputesById[id].hasVoted[msg.sender] = true;

        // updating the votes amount
        _disputesById[id].votesAmount++;

        // storing info about this vote
        uint256 votesAmount = _disputesById[id].votesAmount;
        _disputesById[id].choices[votesAmount] = Vote(msg.sender, choice);

        // checking, if the second arbiter voted the same result with the 1st voted arbiter, then dispute will be solved without 3rd vote
        if (_disputesById[id].votesAmount == 2 && _disputesById[id].choices[0].choice == choice) {
            _executeDispute(id, choice);
        } else if (_disputesById[id].votesAmount == _necessaryVoices) {
            Choice winner = _calculateWinner(id);
            _executeDispute(id, winner);
        }

        emit Voted(id, msg.sender, choice);
    }

    // -----------------------------------------
    // INTERNAL
    // -----------------------------------------

    function _calculateWinner(uint256 id) private view returns (Choice choice) {
        uint256 votesForInvestor = 0;
        for (uint256 i = 0; i < _necessaryVoices; i++) {
            if (_disputesById[id].choices[i].choice == Choice.INVESTOR_WINS) {
                votesForInvestor++;
            }
        }

        return votesForInvestor >= 2 ? Choice.INVESTOR_WINS : Choice.OPERATOR_WINS;
    }

    function _executeDispute(uint256 id, Choice choice) private {
        _disputesById[id].status = DisputeStatus.SOLVED;
        _clusterInterface.solveDispute(
            _disputesById[id].crowdsale,
            _disputesById[id].milestoneHash,
            _disputesById[id].investor,
            choice == Choice.INVESTOR_WINS
        );

        emit DisputeSolved(
            id,
            choice,
            _disputesById[id].crowdsale,
            _disputesById[id].milestoneHash,
            _disputesById[id].investor
        );
    }

    // -----------------------------------------
    // GETTERS
    // -----------------------------------------

    function getDisputesAmount() external view returns (uint256) {
        return _disputsAmount;
    }

    function getDisputeDetails(uint256 id) external view returns (bytes32, address, address, string memory, uint256, DisputeStatus status) {
        Dispute memory dispute = _disputesById[id];
        return (
            dispute.milestoneHash,
            dispute.crowdsale,
            dispute.investor,
            dispute.reason,
            dispute.votesAmount,
            dispute.status
        );
    }

    function getMilestoneDisputes(bytes32 hash) external view returns (uint256[] memory disputesIDs) {
        uint256 disputesLength = _disputesByMilestone[hash].length;
        disputesIDs = new uint256[](disputesLength);

        for (uint256 i = 0; i < disputesLength; i++) {
            disputesIDs[i] = _disputesByMilestone[hash][i];
        }

        return disputesIDs;
    }

    function getDisputeVotes(uint256 id) external view returns(address[] memory arbiters, Choice[] memory choices) {
        uint256 votedArbitersAmount = _disputesById[id].votesAmount;
        arbiters = new address[](votedArbitersAmount);
        choices = new Choice[](votedArbitersAmount);

        for (uint256 i = 0; i < votedArbitersAmount; i++) {
            arbiters[i] = _disputesById[id].choices[i].arbiter;
            choices[i] = _disputesById[id].choices[i].choice;
        }

        return (
            arbiters,
            choices
        );
    }

    function hasDisputeSolved(uint256 id) external view returns (bool) {
        return _disputesById[id].status == DisputeStatus.SOLVED;
    }

    function hasArbiterVoted(uint256 id, address arbiter) external view returns (bool) {
        return _disputesById[id].hasVoted[arbiter];
    }
}