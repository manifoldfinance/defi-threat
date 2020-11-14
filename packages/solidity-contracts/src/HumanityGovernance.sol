/**
 * Source Code first verified at https://etherscan.io on Thursday, May 9, 2019
 (UTC) */

pragma solidity 0.5.7;
pragma experimental ABIEncoderV2;


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
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
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath::mul: Integer overflow");

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath::div: Invalid divisor zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath::sub: Integer underflow");
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath::add: Integer overflow");

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath::mod: Invalid divisor zero");
        return a % b;
    }
}

/**
 * @title Void
 * @dev Collects failed proposal fees.
 */
contract Void {}


/**
 * @title Governance
 * @dev Plutocratic voting system.
 */
contract Governance {
    using SafeMath for uint;

    event Execute(uint indexed proposalId);
    event Propose(uint indexed proposalId, address indexed proposer, address indexed target, bytes data);
    event RemoveVote(uint indexed proposalId, address indexed voter);
    event Terminate(uint indexed proposalId);
    event Vote(uint indexed proposalId, address indexed voter, bool approve, uint weight);

    enum Result { Pending, Yes, No }

    struct Proposal {
        Result result;
        address target;
        bytes data;
        address proposer;
        address feeRecipient;
        uint fee;
        uint startTime;
        uint yesCount;
        uint noCount;
    }

    uint public constant OPEN_VOTE_PERIOD = 2 days;
    uint public constant VETO_PERIOD = 2 days;
    uint public constant TOTAL_VOTE_PERIOD = OPEN_VOTE_PERIOD + VETO_PERIOD;

    uint public proposalFee;
    IERC20 public token;
    Void public void;

    Proposal[] public proposals;

    // Proposal Id => Voter => Yes Votes
    mapping(uint => mapping(address => uint)) public yesVotes;

    // Proposal Id => Voter => No Votes
    mapping(uint => mapping(address => uint)) public noVotes;

    // Voter => Deposit
    mapping (address => uint) public deposits;

    // Voter => Withdraw timestamp
    mapping (address => uint) public withdrawTimes;

    constructor(IERC20 _token, uint _initialProposalFee) public {
        token = _token;
        proposalFee = _initialProposalFee;
        void = new Void();
    }

    function deposit(uint amount) public {
        require(token.transferFrom(msg.sender, address(this), amount), "Governance::deposit: Transfer failed");
        deposits[msg.sender] = deposits[msg.sender].add(amount);
    }

    function withdraw(uint amount) public {
        require(time() > withdrawTimes[msg.sender], "Governance::withdraw: Voters with an active proposal cannot withdraw");
        deposits[msg.sender] = deposits[msg.sender].sub(amount);
        require(token.transfer(msg.sender, amount), "Governance::withdraw: Transfer failed");
    }

    function propose(address target, bytes memory data) public returns (uint) {
        return proposeWithFeeRecipient(msg.sender, target, data);
    }

    function proposeWithFeeRecipient(address feeRecipient, address target, bytes memory data) public returns (uint) {
        require(msg.sender != address(this) && target != address(token), "Governance::proposeWithFeeRecipient: Invalid proposal");
        require(token.transferFrom(msg.sender, address(this), proposalFee), "Governance::proposeWithFeeRecipient: Transfer failed");

        uint proposalId = proposals.length;

        // Create a new proposal and vote yes
        Proposal memory proposal;
        proposal.target = target;
        proposal.data = data;
        proposal.proposer = msg.sender;
        proposal.feeRecipient = feeRecipient;
        proposal.fee = proposalFee;
        proposal.startTime = time();
        proposal.yesCount = proposalFee;

        proposals.push(proposal);

        emit Propose(proposalId, msg.sender, target, data);

        return proposalId;
    }

    function voteYes(uint proposalId) public {
        Proposal storage proposal = proposals[proposalId];
        require(time() <= proposal.startTime.add(OPEN_VOTE_PERIOD), "Governance::voteYes: Proposal is no longer accepting yes votes");

        uint proposalEndTime = proposal.startTime.add(TOTAL_VOTE_PERIOD);
        if (proposalEndTime > withdrawTimes[msg.sender]) withdrawTimes[msg.sender] = proposalEndTime;

        uint weight = deposits[msg.sender].sub(yesVotes[proposalId][msg.sender]);
        proposal.yesCount = proposal.yesCount.add(weight);
        yesVotes[proposalId][msg.sender] = deposits[msg.sender];

        emit Vote(proposalId, msg.sender, true, weight);
    }

    function voteNo(uint proposalId) public {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.result == Result.Pending, "Governance::voteNo: Proposal is already finalized");

        uint proposalEndTime = proposal.startTime.add(TOTAL_VOTE_PERIOD);
        uint _time = time();
        require(_time <= proposalEndTime, "Governance::voteNo: Proposal is no longer in voting period");

        uint _deposit = deposits[msg.sender];
        uint weight = _deposit.sub(noVotes[proposalId][msg.sender]);
        proposal.noCount = proposal.noCount.add(weight);
        noVotes[proposalId][msg.sender] = _deposit;

        emit Vote(proposalId, msg.sender, false, weight);

        // Finalize the vote and burn the proposal fee if no votes outnumber yes votes and open voting has ended
        if (_time > proposal.startTime.add(OPEN_VOTE_PERIOD) && proposal.noCount >= proposal.yesCount) {
            proposal.result = Result.No;
            require(token.transfer(address(void), proposal.fee), "Governance::voteNo: Transfer to void failed");
            emit Terminate(proposalId);
        } else if (proposalEndTime > withdrawTimes[msg.sender]) {
            withdrawTimes[msg.sender] = proposalEndTime;
        }

    }

    function removeVote(uint proposalId) public {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.result == Result.Pending, "Governance::removeVote: Proposal is already finalized");
        require(time() <= proposal.startTime.add(TOTAL_VOTE_PERIOD), "Governance::removeVote: Proposal is no longer in voting period");

        proposal.yesCount = proposal.yesCount.sub(yesVotes[proposalId][msg.sender]);
        proposal.noCount = proposal.noCount.sub(noVotes[proposalId][msg.sender]);
        delete yesVotes[proposalId][msg.sender];
        delete noVotes[proposalId][msg.sender];

        emit RemoveVote(proposalId, msg.sender);
    }

    function finalize(uint proposalId) public {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.result == Result.Pending, "Governance::finalize: Proposal is already finalized");
        uint _time = time();

        if (proposal.yesCount > proposal.noCount) {
            require(_time > proposal.startTime.add(TOTAL_VOTE_PERIOD), "Governance::finalize: Proposal cannot be executed until end of veto period");

            proposal.result = Result.Yes;
            require(token.transfer(proposal.feeRecipient, proposal.fee), "Governance::finalize: Return proposal fee failed");
            proposal.target.call(proposal.data);

            emit Execute(proposalId);
        } else {
            require(_time > proposal.startTime.add(OPEN_VOTE_PERIOD), "Governance::finalize: Proposal cannot be terminated until end of yes vote period");

            proposal.result = Result.No;
            require(token.transfer(address(void), proposal.fee), "Governance::finalize: Transfer to void failed");

            emit Terminate(proposalId);
        }
    }

    function setProposalFee(uint fee) public {
        require(msg.sender == address(this), "Governance::setProposalFee: Proposal fee can only be set via governance");
        proposalFee = fee;
    }

    function time() public view returns (uint) {
        return block.timestamp;
    }

    function getProposal(uint proposalId) external view returns (Proposal memory) {
        return proposals[proposalId];
    }

    function getProposalsCount() external view returns (uint) {
        return proposals.length;
    }

}


/**
 * @title HumanityGovernance
 * @dev Plutocratic voting system that uses Humanity token for voting and proposal fees.
 */
contract HumanityGovernance is Governance {

    constructor(IERC20 humanity, uint proposalFee) public
        Governance(humanity, proposalFee) {}

}