/**
 * Source Code first verified at https://etherscan.io on Monday, April 8, 2019
 (UTC) */

// full contract sources : https://github.com/DigixGlobal/dao-contracts

pragma solidity ^0.4.25;

contract ContractResolver {
    bool public locked_forever;

    function get_contract(bytes32) public view returns (address);

    function init_register_contract(bytes32, address) public returns (bool);
}

contract ResolverClient {

  /// The address of the resolver contract for this project
  address public resolver;
  bytes32 public key;

  /// Make our own address available to us as a constant
  address public CONTRACT_ADDRESS;

  /// Function modifier to check if msg.sender corresponds to the resolved address of a given key
  /// @param _contract The resolver key
  modifier if_sender_is(bytes32 _contract) {
    require(sender_is(_contract));
    _;
  }

  function sender_is(bytes32 _contract) internal view returns (bool _isFrom) {
    _isFrom = msg.sender == ContractResolver(resolver).get_contract(_contract);
  }

  modifier if_sender_is_from(bytes32[3] _contracts) {
    require(sender_is_from(_contracts));
    _;
  }

  function sender_is_from(bytes32[3] _contracts) internal view returns (bool _isFrom) {
    uint256 _n = _contracts.length;
    for (uint256 i = 0; i < _n; i++) {
      if (_contracts[i] == bytes32(0x0)) continue;
      if (msg.sender == ContractResolver(resolver).get_contract(_contracts[i])) {
        _isFrom = true;
        break;
      }
    }
  }

  /// Function modifier to check resolver's locking status.
  modifier unless_resolver_is_locked() {
    require(is_locked() == false);
    _;
  }

  /// @dev Initialize new contract
  /// @param _key the resolver key for this contract
  /// @return _success if the initialization is successful
  function init(bytes32 _key, address _resolver)
           internal
           returns (bool _success)
  {
    bool _is_locked = ContractResolver(_resolver).locked_forever();
    if (_is_locked == false) {
      CONTRACT_ADDRESS = address(this);
      resolver = _resolver;
      key = _key;
      require(ContractResolver(resolver).init_register_contract(key, CONTRACT_ADDRESS));
      _success = true;
    }  else {
      _success = false;
    }
  }

  /// @dev Check if resolver is locked
  /// @return _locked if the resolver is currently locked
  function is_locked()
           private
           view
           returns (bool _locked)
  {
    _locked = ContractResolver(resolver).locked_forever();
  }

  /// @dev Get the address of a contract
  /// @param _key the resolver key to look up
  /// @return _contract the address of the contract
  function get_contract(bytes32 _key)
           public
           view
           returns (address _contract)
  {
    _contract = ContractResolver(resolver).get_contract(_key);
  }
}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

contract DaoConstants {
    using SafeMath for uint256;
    bytes32 EMPTY_BYTES = bytes32(0x0);
    address EMPTY_ADDRESS = address(0x0);


    bytes32 PROPOSAL_STATE_PREPROPOSAL = "proposal_state_preproposal";
    bytes32 PROPOSAL_STATE_DRAFT = "proposal_state_draft";
    bytes32 PROPOSAL_STATE_MODERATED = "proposal_state_moderated";
    bytes32 PROPOSAL_STATE_ONGOING = "proposal_state_ongoing";
    bytes32 PROPOSAL_STATE_CLOSED = "proposal_state_closed";
    bytes32 PROPOSAL_STATE_ARCHIVED = "proposal_state_archived";

    uint256 PRL_ACTION_STOP = 1;
    uint256 PRL_ACTION_PAUSE = 2;
    uint256 PRL_ACTION_UNPAUSE = 3;

    uint256 COLLATERAL_STATUS_UNLOCKED = 1;
    uint256 COLLATERAL_STATUS_LOCKED = 2;
    uint256 COLLATERAL_STATUS_CLAIMED = 3;

    bytes32 INTERMEDIATE_DGD_IDENTIFIER = "inter_dgd_id";
    bytes32 INTERMEDIATE_MODERATOR_DGD_IDENTIFIER = "inter_mod_dgd_id";
    bytes32 INTERMEDIATE_BONUS_CALCULATION_IDENTIFIER = "inter_bonus_calculation_id";

    // interactive contracts
    bytes32 CONTRACT_DAO = "dao";
    bytes32 CONTRACT_DAO_SPECIAL_PROPOSAL = "dao:special:proposal";
    bytes32 CONTRACT_DAO_STAKE_LOCKING = "dao:stake-locking";
    bytes32 CONTRACT_DAO_VOTING = "dao:voting";
    bytes32 CONTRACT_DAO_VOTING_CLAIMS = "dao:voting:claims";
    bytes32 CONTRACT_DAO_SPECIAL_VOTING_CLAIMS = "dao:svoting:claims";
    bytes32 CONTRACT_DAO_IDENTITY = "dao:identity";
    bytes32 CONTRACT_DAO_REWARDS_MANAGER = "dao:rewards-manager";
    bytes32 CONTRACT_DAO_REWARDS_MANAGER_EXTRAS = "dao:rewards-extras";
    bytes32 CONTRACT_DAO_ROLES = "dao:roles";
    bytes32 CONTRACT_DAO_FUNDING_MANAGER = "dao:funding-manager";
    bytes32 CONTRACT_DAO_WHITELISTING = "dao:whitelisting";
    bytes32 CONTRACT_DAO_INFORMATION = "dao:information";

    // service contracts
    bytes32 CONTRACT_SERVICE_ROLE = "service:role";
    bytes32 CONTRACT_SERVICE_DAO_INFO = "service:dao:info";
    bytes32 CONTRACT_SERVICE_DAO_LISTING = "service:dao:listing";
    bytes32 CONTRACT_SERVICE_DAO_CALCULATOR = "service:dao:calculator";

    // storage contracts
    bytes32 CONTRACT_STORAGE_DAO = "storage:dao";
    bytes32 CONTRACT_STORAGE_DAO_COUNTER = "storage:dao:counter";
    bytes32 CONTRACT_STORAGE_DAO_UPGRADE = "storage:dao:upgrade";
    bytes32 CONTRACT_STORAGE_DAO_IDENTITY = "storage:dao:identity";
    bytes32 CONTRACT_STORAGE_DAO_POINTS = "storage:dao:points";
    bytes32 CONTRACT_STORAGE_DAO_SPECIAL = "storage:dao:special";
    bytes32 CONTRACT_STORAGE_DAO_CONFIG = "storage:dao:config";
    bytes32 CONTRACT_STORAGE_DAO_STAKE = "storage:dao:stake";
    bytes32 CONTRACT_STORAGE_DAO_REWARDS = "storage:dao:rewards";
    bytes32 CONTRACT_STORAGE_DAO_WHITELISTING = "storage:dao:whitelisting";
    bytes32 CONTRACT_STORAGE_INTERMEDIATE_RESULTS = "storage:intermediate:results";

    bytes32 CONTRACT_DGD_TOKEN = "t:dgd";
    bytes32 CONTRACT_DGX_TOKEN = "t:dgx";
    bytes32 CONTRACT_BADGE_TOKEN = "t:badge";

    uint8 ROLES_ROOT = 1;
    uint8 ROLES_FOUNDERS = 2;
    uint8 ROLES_PRLS = 3;
    uint8 ROLES_KYC_ADMINS = 4;

    uint256 QUARTER_DURATION = 90 days;

    bytes32 CONFIG_MINIMUM_LOCKED_DGD = "min_dgd_participant";
    bytes32 CONFIG_MINIMUM_DGD_FOR_MODERATOR = "min_dgd_moderator";
    bytes32 CONFIG_MINIMUM_REPUTATION_FOR_MODERATOR = "min_reputation_moderator";

    bytes32 CONFIG_LOCKING_PHASE_DURATION = "locking_phase_duration";
    bytes32 CONFIG_QUARTER_DURATION = "quarter_duration";
    bytes32 CONFIG_VOTING_COMMIT_PHASE = "voting_commit_phase";
    bytes32 CONFIG_VOTING_PHASE_TOTAL = "voting_phase_total";
    bytes32 CONFIG_INTERIM_COMMIT_PHASE = "interim_voting_commit_phase";
    bytes32 CONFIG_INTERIM_PHASE_TOTAL = "interim_voting_phase_total";

    bytes32 CONFIG_DRAFT_QUORUM_FIXED_PORTION_NUMERATOR = "draft_quorum_fixed_numerator";
    bytes32 CONFIG_DRAFT_QUORUM_FIXED_PORTION_DENOMINATOR = "draft_quorum_fixed_denominator";
    bytes32 CONFIG_DRAFT_QUORUM_SCALING_FACTOR_NUMERATOR = "draft_quorum_sfactor_numerator";
    bytes32 CONFIG_DRAFT_QUORUM_SCALING_FACTOR_DENOMINATOR = "draft_quorum_sfactor_denominator";
    bytes32 CONFIG_VOTING_QUORUM_FIXED_PORTION_NUMERATOR = "vote_quorum_fixed_numerator";
    bytes32 CONFIG_VOTING_QUORUM_FIXED_PORTION_DENOMINATOR = "vote_quorum_fixed_denominator";
    bytes32 CONFIG_VOTING_QUORUM_SCALING_FACTOR_NUMERATOR = "vote_quorum_sfactor_numerator";
    bytes32 CONFIG_VOTING_QUORUM_SCALING_FACTOR_DENOMINATOR = "vote_quorum_sfactor_denominator";
    bytes32 CONFIG_FINAL_REWARD_SCALING_FACTOR_NUMERATOR = "final_reward_sfactor_numerator";
    bytes32 CONFIG_FINAL_REWARD_SCALING_FACTOR_DENOMINATOR = "final_reward_sfactor_denominator";

    bytes32 CONFIG_DRAFT_QUOTA_NUMERATOR = "draft_quota_numerator";
    bytes32 CONFIG_DRAFT_QUOTA_DENOMINATOR = "draft_quota_denominator";
    bytes32 CONFIG_VOTING_QUOTA_NUMERATOR = "voting_quota_numerator";
    bytes32 CONFIG_VOTING_QUOTA_DENOMINATOR = "voting_quota_denominator";

    bytes32 CONFIG_MINIMAL_QUARTER_POINT = "minimal_qp";
    bytes32 CONFIG_QUARTER_POINT_SCALING_FACTOR = "quarter_point_scaling_factor";
    bytes32 CONFIG_REPUTATION_POINT_SCALING_FACTOR = "rep_point_scaling_factor";

    bytes32 CONFIG_MODERATOR_MINIMAL_QUARTER_POINT = "minimal_mod_qp";
    bytes32 CONFIG_MODERATOR_QUARTER_POINT_SCALING_FACTOR = "mod_qp_scaling_factor";
    bytes32 CONFIG_MODERATOR_REPUTATION_POINT_SCALING_FACTOR = "mod_rep_point_scaling_factor";

    bytes32 CONFIG_QUARTER_POINT_DRAFT_VOTE = "quarter_point_draft_vote";
    bytes32 CONFIG_QUARTER_POINT_VOTE = "quarter_point_vote";
    bytes32 CONFIG_QUARTER_POINT_INTERIM_VOTE = "quarter_point_interim_vote";

    /// this is per 10000 ETHs
    bytes32 CONFIG_QUARTER_POINT_MILESTONE_COMPLETION_PER_10000ETH = "q_p_milestone_completion";

    bytes32 CONFIG_BONUS_REPUTATION_NUMERATOR = "bonus_reputation_numerator";
    bytes32 CONFIG_BONUS_REPUTATION_DENOMINATOR = "bonus_reputation_denominator";

    bytes32 CONFIG_SPECIAL_PROPOSAL_COMMIT_PHASE = "special_proposal_commit_phase";
    bytes32 CONFIG_SPECIAL_PROPOSAL_PHASE_TOTAL = "special_proposal_phase_total";

    bytes32 CONFIG_SPECIAL_QUOTA_NUMERATOR = "config_special_quota_numerator";
    bytes32 CONFIG_SPECIAL_QUOTA_DENOMINATOR = "config_special_quota_denominator";

    bytes32 CONFIG_SPECIAL_PROPOSAL_QUORUM_NUMERATOR = "special_quorum_numerator";
    bytes32 CONFIG_SPECIAL_PROPOSAL_QUORUM_DENOMINATOR = "special_quorum_denominator";

    bytes32 CONFIG_MAXIMUM_REPUTATION_DEDUCTION = "config_max_reputation_deduction";
    bytes32 CONFIG_PUNISHMENT_FOR_NOT_LOCKING = "config_punishment_not_locking";

    bytes32 CONFIG_REPUTATION_PER_EXTRA_QP_NUM = "config_rep_per_extra_qp_num";
    bytes32 CONFIG_REPUTATION_PER_EXTRA_QP_DEN = "config_rep_per_extra_qp_den";

    bytes32 CONFIG_MAXIMUM_MODERATOR_REPUTATION_DEDUCTION = "config_max_m_rp_deduction";
    bytes32 CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_NUM = "config_rep_per_extra_m_qp_num";
    bytes32 CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_DEN = "config_rep_per_extra_m_qp_den";

    bytes32 CONFIG_PORTION_TO_MODERATORS_NUM = "config_mod_portion_num";
    bytes32 CONFIG_PORTION_TO_MODERATORS_DEN = "config_mod_portion_den";

    bytes32 CONFIG_DRAFT_VOTING_PHASE = "config_draft_voting_phase";

    bytes32 CONFIG_REPUTATION_POINT_BOOST_FOR_BADGE = "config_rp_boost_per_badge";

    bytes32 CONFIG_VOTE_CLAIMING_DEADLINE = "config_claiming_deadline";

    bytes32 CONFIG_PREPROPOSAL_COLLATERAL = "config_preproposal_collateral";

    bytes32 CONFIG_MAX_FUNDING_FOR_NON_DIGIX = "config_max_funding_nonDigix";
    bytes32 CONFIG_MAX_MILESTONES_FOR_NON_DIGIX = "config_max_milestones_nonDigix";
    bytes32 CONFIG_NON_DIGIX_PROPOSAL_CAP_PER_QUARTER = "config_nonDigix_proposal_cap";

    bytes32 CONFIG_PROPOSAL_DEAD_DURATION = "config_dead_duration";
    bytes32 CONFIG_CARBON_VOTE_REPUTATION_BONUS = "config_cv_reputation";
}

contract DaoWhitelistingStorage is ResolverClient, DaoConstants {
    mapping (address => bool) public whitelist;
}

contract DaoWhitelistingCommon is ResolverClient, DaoConstants {

    function daoWhitelistingStorage()
        internal
        view
        returns (DaoWhitelistingStorage _contract)
    {
        _contract = DaoWhitelistingStorage(get_contract(CONTRACT_STORAGE_DAO_WHITELISTING));
    }

    /**
    @notice Check if a certain address is whitelisted to read sensitive information in the storage layer
    @dev if the address is an account, it is allowed to read. If the address is a contract, it has to be in the whitelist
    */
    function senderIsAllowedToRead()
        internal
        view
        returns (bool _senderIsAllowedToRead)
    {
        // msg.sender is allowed to read only if its an EOA or a whitelisted contract
        _senderIsAllowedToRead = (msg.sender == tx.origin) || daoWhitelistingStorage().whitelist(msg.sender);
    }
}

contract DaoIdentityStorage {
    function read_user_role_id(address) constant public returns (uint256);

    function is_kyc_approved(address) public view returns (bool);
}

contract IdentityCommon is DaoWhitelistingCommon {

    modifier if_root() {
        require(identity_storage().read_user_role_id(msg.sender) == ROLES_ROOT);
        _;
    }

    modifier if_founder() {
        require(is_founder());
        _;
    }

    function is_founder()
        internal
        view
        returns (bool _isFounder)
    {
        _isFounder = identity_storage().read_user_role_id(msg.sender) == ROLES_FOUNDERS;
    }

    modifier if_prl() {
        require(identity_storage().read_user_role_id(msg.sender) == ROLES_PRLS);
        _;
    }

    modifier if_kyc_admin() {
        require(identity_storage().read_user_role_id(msg.sender) == ROLES_KYC_ADMINS);
        _;
    }

    function identity_storage()
        internal
        view
        returns (DaoIdentityStorage _contract)
    {
        _contract = DaoIdentityStorage(get_contract(CONTRACT_STORAGE_DAO_IDENTITY));
    }
}

library MathHelper {

  using SafeMath for uint256;

  function max(uint256 a, uint256 b) internal pure returns (uint256 _max){
      _max = b;
      if (a > b) {
          _max = a;
      }
  }

  function min(uint256 a, uint256 b) internal pure returns (uint256 _min){
      _min = b;
      if (a < b) {
          _min = a;
      }
  }

  function sumNumbers(uint256[] _numbers) internal pure returns (uint256 _sum) {
      for (uint256 i=0;i<_numbers.length;i++) {
          _sum = _sum.add(_numbers[i]);
      }
  }
}

contract DaoListingService {
    function listParticipants(uint256, bool) public view returns (address[]);

    function listParticipantsFrom(address, uint256, bool) public view returns (address[]);

    function listModerators(uint256, bool) public view returns (address[]);

    function listModeratorsFrom(address, uint256, bool) public view returns (address[]);
}

contract DaoConfigsStorage {
    mapping (bytes32 => uint256) public uintConfigs;
    mapping (bytes32 => address) public addressConfigs;
    mapping (bytes32 => bytes32) public bytesConfigs;

    function updateUintConfigs(uint256[]) external;

    function readUintConfigs() public view returns (uint256[]);
}

contract DaoStakeStorage {
    mapping (address => uint256) public lockedDGDStake;

    function readLastModerator() public view returns (address);

    function readLastParticipant() public view returns (address);
}

contract DaoProposalCounterStorage {
    mapping (uint256 => uint256) public proposalCountByQuarter;

    function addNonDigixProposalCountInQuarter(uint256) public;
}

contract DaoStorage {
    function readProposal(bytes32) public view returns (bytes32, address, address, bytes32, uint256, uint256, bytes32, bytes32, bool, bool);

    function readProposalProposer(bytes32) public view returns (address);

    function readProposalDraftVotingResult(bytes32) public view returns (bool);

    function readProposalVotingResult(bytes32, uint256) public view returns (bool);

    function readProposalDraftVotingTime(bytes32) public view returns (uint256);

    function readProposalVotingTime(bytes32, uint256) public view returns (uint256);

    function readVote(bytes32, uint256, address) public view returns (bool, uint256);

    function readVotingCount(bytes32, uint256, address[]) external view returns (uint256, uint256);

    function isDraftClaimed(bytes32) public view returns (bool);

    function isClaimed(bytes32, uint256) public view returns (bool);

    function setProposalDraftPass(bytes32, bool) public;

    function setDraftVotingClaim(bytes32, bool) public;

    function readDraftVotingCount(bytes32, address[]) external view returns (uint256, uint256);

    function setProposalVotingTime(bytes32, uint256, uint256) public;

    function setProposalCollateralStatus(bytes32, uint256) public;

    function setVotingClaim(bytes32, uint256, bool) public;

    function setProposalPass(bytes32, uint256, bool) public;

    function readProposalFunding(bytes32) public view returns (uint256[] memory, uint256);

    function archiveProposal(bytes32) public;

    function readProposalMilestone(bytes32, uint256) public view returns (uint256);

    function readVotingRoundVotes(bytes32, uint256, address[], bool) external view returns (address[] memory, uint256);
}

contract DaoUpgradeStorage {
    uint256 public startOfFirstQuarter;
    bool public isReplacedByNewDao;
}

contract DaoSpecialStorage {
    function readProposalProposer(bytes32) public view returns (address);

    function readConfigs(bytes32) public view returns (uint256[] memory, address[] memory, bytes32[] memory);

    function readVotingCount(bytes32, address[]) external view returns (uint256, uint256);

    function readVotingTime(bytes32) public view returns (uint256);

    function setPass(bytes32, bool) public;

    function setVotingClaim(bytes32, bool) public;

    function isClaimed(bytes32) public view returns (bool);

    function readVote(bytes32, address) public view returns (bool, uint256);
}

contract DaoPointsStorage {
  function getReputation(address) public view returns (uint256);

  function addQuarterPoint(address, uint256, uint256) public returns (uint256, uint256);

  function increaseReputation(address, uint256) public returns (uint256, uint256);
}

contract DaoRewardsStorage {
    mapping (address => uint256) public lastParticipatedQuarter;

    function readDgxDistributionDay(uint256) public view returns (uint256);
}

contract IntermediateResultsStorage {
    function getIntermediateResults(bytes32) public view returns (address, uint256, uint256, uint256);

    function setIntermediateResults(bytes32, address, uint256, uint256, uint256) public;

    function resetIntermediateResults(bytes32) public;
}

contract DaoCommonMini is IdentityCommon {

    using MathHelper for MathHelper;

    /**
    @notice Check if the DAO contracts have been replaced by a new set of contracts
    @return _isNotReplaced true if it is not replaced, false if it has already been replaced
    */
    function isDaoNotReplaced()
        public
        view
        returns (bool _isNotReplaced)
    {
        _isNotReplaced = !daoUpgradeStorage().isReplacedByNewDao();
    }

    /**
    @notice Check if it is currently in the locking phase
    @dev No governance activities can happen in the locking phase. The locking phase is from t=0 to t=CONFIG_LOCKING_PHASE_DURATION-1
    @return _isLockingPhase true if it is in the locking phase
    */
    function isLockingPhase()
        public
        view
        returns (bool _isLockingPhase)
    {
        _isLockingPhase = currentTimeInQuarter() < getUintConfig(CONFIG_LOCKING_PHASE_DURATION);
    }

    /**
    @notice Check if it is currently in a main phase.
    @dev The main phase is where all the governance activities could take plase. If the DAO is replaced, there can never be any more main phase.
    @return _isMainPhase true if it is in a main phase
    */
    function isMainPhase()
        public
        view
        returns (bool _isMainPhase)
    {
        _isMainPhase =
            isDaoNotReplaced() &&
            currentTimeInQuarter() >= getUintConfig(CONFIG_LOCKING_PHASE_DURATION);
    }

    /**
    @notice Check if the calculateGlobalRewardsBeforeNewQuarter function has been done for a certain quarter
    @dev However, there is no need to run calculateGlobalRewardsBeforeNewQuarter for the first quarter
    */
    modifier ifGlobalRewardsSet(uint256 _quarterNumber) {
        if (_quarterNumber > 1) {
            require(daoRewardsStorage().readDgxDistributionDay(_quarterNumber) > 0);
        }
        _;
    }

    /**
    @notice require that it is currently during a phase, which is within _relativePhaseStart and _relativePhaseEnd seconds, after the _startingPoint
    */
    function requireInPhase(uint256 _startingPoint, uint256 _relativePhaseStart, uint256 _relativePhaseEnd)
        internal
        view
    {
        require(_startingPoint > 0);
        require(now < _startingPoint.add(_relativePhaseEnd));
        require(now >= _startingPoint.add(_relativePhaseStart));
    }

    /**
    @notice Get the current quarter index
    @dev Quarter indexes starts from 1
    @return _quarterNumber the current quarter index
    */
    function currentQuarterNumber()
        public
        view
        returns(uint256 _quarterNumber)
    {
        _quarterNumber = getQuarterNumber(now);
    }

    /**
    @notice Get the quarter index of a timestamp
    @dev Quarter indexes starts from 1
    @return _index the quarter index
    */
    function getQuarterNumber(uint256 _time)
        internal
        view
        returns (uint256 _index)
    {
        require(startOfFirstQuarterIsSet());
        _index =
            _time.sub(daoUpgradeStorage().startOfFirstQuarter())
            .div(getUintConfig(CONFIG_QUARTER_DURATION))
            .add(1);
    }

    /**
    @notice Get the relative time in quarter of a timestamp
    @dev For example, the timeInQuarter of the first second of any quarter n-th is always 1
    */
    function timeInQuarter(uint256 _time)
        internal
        view
        returns (uint256 _timeInQuarter)
    {
        require(startOfFirstQuarterIsSet()); // must be already set
        _timeInQuarter =
            _time.sub(daoUpgradeStorage().startOfFirstQuarter())
            % getUintConfig(CONFIG_QUARTER_DURATION);
    }

    /**
    @notice Check if the start of first quarter is already set
    @return _isSet true if start of first quarter is already set
    */
    function startOfFirstQuarterIsSet()
        internal
        view
        returns (bool _isSet)
    {
        _isSet = daoUpgradeStorage().startOfFirstQuarter() != 0;
    }

    /**
    @notice Get the current relative time in the quarter
    @dev For example: the currentTimeInQuarter of the first second of any quarter is 1
    @return _currentT the current relative time in the quarter
    */
    function currentTimeInQuarter()
        public
        view
        returns (uint256 _currentT)
    {
        _currentT = timeInQuarter(now);
    }

    /**
    @notice Get the time remaining in the quarter
    */
    function getTimeLeftInQuarter(uint256 _time)
        internal
        view
        returns (uint256 _timeLeftInQuarter)
    {
        _timeLeftInQuarter = getUintConfig(CONFIG_QUARTER_DURATION).sub(timeInQuarter(_time));
    }

    function daoListingService()
        internal
        view
        returns (DaoListingService _contract)
    {
        _contract = DaoListingService(get_contract(CONTRACT_SERVICE_DAO_LISTING));
    }

    function daoConfigsStorage()
        internal
        view
        returns (DaoConfigsStorage _contract)
    {
        _contract = DaoConfigsStorage(get_contract(CONTRACT_STORAGE_DAO_CONFIG));
    }

    function daoStakeStorage()
        internal
        view
        returns (DaoStakeStorage _contract)
    {
        _contract = DaoStakeStorage(get_contract(CONTRACT_STORAGE_DAO_STAKE));
    }

    function daoStorage()
        internal
        view
        returns (DaoStorage _contract)
    {
        _contract = DaoStorage(get_contract(CONTRACT_STORAGE_DAO));
    }

    function daoProposalCounterStorage()
        internal
        view
        returns (DaoProposalCounterStorage _contract)
    {
        _contract = DaoProposalCounterStorage(get_contract(CONTRACT_STORAGE_DAO_COUNTER));
    }

    function daoUpgradeStorage()
        internal
        view
        returns (DaoUpgradeStorage _contract)
    {
        _contract = DaoUpgradeStorage(get_contract(CONTRACT_STORAGE_DAO_UPGRADE));
    }

    function daoSpecialStorage()
        internal
        view
        returns (DaoSpecialStorage _contract)
    {
        _contract = DaoSpecialStorage(get_contract(CONTRACT_STORAGE_DAO_SPECIAL));
    }

    function daoPointsStorage()
        internal
        view
        returns (DaoPointsStorage _contract)
    {
        _contract = DaoPointsStorage(get_contract(CONTRACT_STORAGE_DAO_POINTS));
    }

    function daoRewardsStorage()
        internal
        view
        returns (DaoRewardsStorage _contract)
    {
        _contract = DaoRewardsStorage(get_contract(CONTRACT_STORAGE_DAO_REWARDS));
    }

    function intermediateResultsStorage()
        internal
        view
        returns (IntermediateResultsStorage _contract)
    {
        _contract = IntermediateResultsStorage(get_contract(CONTRACT_STORAGE_INTERMEDIATE_RESULTS));
    }

    function getUintConfig(bytes32 _configKey)
        public
        view
        returns (uint256 _configValue)
    {
        _configValue = daoConfigsStorage().uintConfigs(_configKey);
    }
}

contract DaoCommon is DaoCommonMini {

    using MathHelper for MathHelper;

    /**
    @notice Check if the transaction is called by the proposer of a proposal
    @return _isFromProposer true if the caller is the proposer
    */
    function isFromProposer(bytes32 _proposalId)
        internal
        view
        returns (bool _isFromProposer)
    {
        _isFromProposer = msg.sender == daoStorage().readProposalProposer(_proposalId);
    }

    /**
    @notice Check if the proposal can still be "editted", or in other words, added more versions
    @dev Once the proposal is finalized, it can no longer be editted. The proposer will still be able to add docs and change fundings though.
    @return _isEditable true if the proposal is editable
    */
    function isEditable(bytes32 _proposalId)
        internal
        view
        returns (bool _isEditable)
    {
        bytes32 _finalVersion;
        (,,,,,,,_finalVersion,,) = daoStorage().readProposal(_proposalId);
        _isEditable = _finalVersion == EMPTY_BYTES;
    }

    /**
    @notice returns the balance of DaoFundingManager, which is the wei in DigixDAO
    */
    function weiInDao()
        internal
        view
        returns (uint256 _wei)
    {
        _wei = get_contract(CONTRACT_DAO_FUNDING_MANAGER).balance;
    }

    /**
    @notice Check if it is after the draft voting phase of the proposal
    */
    modifier ifAfterDraftVotingPhase(bytes32 _proposalId) {
        uint256 _start = daoStorage().readProposalDraftVotingTime(_proposalId);
        require(_start > 0); // Draft voting must have started. In other words, proposer must have finalized the proposal
        require(now >= _start.add(getUintConfig(CONFIG_DRAFT_VOTING_PHASE)));
        _;
    }

    modifier ifCommitPhase(bytes32 _proposalId, uint8 _index) {
        requireInPhase(
            daoStorage().readProposalVotingTime(_proposalId, _index),
            0,
            getUintConfig(_index == 0 ? CONFIG_VOTING_COMMIT_PHASE : CONFIG_INTERIM_COMMIT_PHASE)
        );
        _;
    }

    modifier ifRevealPhase(bytes32 _proposalId, uint256 _index) {
      requireInPhase(
          daoStorage().readProposalVotingTime(_proposalId, _index),
          getUintConfig(_index == 0 ? CONFIG_VOTING_COMMIT_PHASE : CONFIG_INTERIM_COMMIT_PHASE),
          getUintConfig(_index == 0 ? CONFIG_VOTING_PHASE_TOTAL : CONFIG_INTERIM_PHASE_TOTAL)
      );
      _;
    }

    modifier ifAfterProposalRevealPhase(bytes32 _proposalId, uint256 _index) {
      uint256 _start = daoStorage().readProposalVotingTime(_proposalId, _index);
      require(_start > 0);
      require(now >= _start.add(getUintConfig(_index == 0 ? CONFIG_VOTING_PHASE_TOTAL : CONFIG_INTERIM_PHASE_TOTAL)));
      _;
    }

    modifier ifDraftVotingPhase(bytes32 _proposalId) {
        requireInPhase(
            daoStorage().readProposalDraftVotingTime(_proposalId),
            0,
            getUintConfig(CONFIG_DRAFT_VOTING_PHASE)
        );
        _;
    }

    modifier isProposalState(bytes32 _proposalId, bytes32 _STATE) {
        bytes32 _currentState;
        (,,,_currentState,,,,,,) = daoStorage().readProposal(_proposalId);
        require(_currentState == _STATE);
        _;
    }

    /**
    @notice Check if the DAO has enough ETHs for a particular funding request
    */
    modifier ifFundingPossible(uint256[] _fundings, uint256 _finalReward) {
        require(MathHelper.sumNumbers(_fundings).add(_finalReward) <= weiInDao());
        _;
    }

    modifier ifDraftNotClaimed(bytes32 _proposalId) {
        require(daoStorage().isDraftClaimed(_proposalId) == false);
        _;
    }

    modifier ifNotClaimed(bytes32 _proposalId, uint256 _index) {
        require(daoStorage().isClaimed(_proposalId, _index) == false);
        _;
    }

    modifier ifNotClaimedSpecial(bytes32 _proposalId) {
        require(daoSpecialStorage().isClaimed(_proposalId) == false);
        _;
    }

    modifier hasNotRevealed(bytes32 _proposalId, uint256 _index) {
        uint256 _voteWeight;
        (, _voteWeight) = daoStorage().readVote(_proposalId, _index, msg.sender);
        require(_voteWeight == uint(0));
        _;
    }

    modifier hasNotRevealedSpecial(bytes32 _proposalId) {
        uint256 _weight;
        (,_weight) = daoSpecialStorage().readVote(_proposalId, msg.sender);
        require(_weight == uint256(0));
        _;
    }

    modifier ifAfterRevealPhaseSpecial(bytes32 _proposalId) {
      uint256 _start = daoSpecialStorage().readVotingTime(_proposalId);
      require(_start > 0);
      require(now.sub(_start) >= getUintConfig(CONFIG_SPECIAL_PROPOSAL_PHASE_TOTAL));
      _;
    }

    modifier ifCommitPhaseSpecial(bytes32 _proposalId) {
        requireInPhase(
            daoSpecialStorage().readVotingTime(_proposalId),
            0,
            getUintConfig(CONFIG_SPECIAL_PROPOSAL_COMMIT_PHASE)
        );
        _;
    }

    modifier ifRevealPhaseSpecial(bytes32 _proposalId) {
        requireInPhase(
            daoSpecialStorage().readVotingTime(_proposalId),
            getUintConfig(CONFIG_SPECIAL_PROPOSAL_COMMIT_PHASE),
            getUintConfig(CONFIG_SPECIAL_PROPOSAL_PHASE_TOTAL)
        );
        _;
    }

    function daoWhitelistingStorage()
        internal
        view
        returns (DaoWhitelistingStorage _contract)
    {
        _contract = DaoWhitelistingStorage(get_contract(CONTRACT_STORAGE_DAO_WHITELISTING));
    }

    function getAddressConfig(bytes32 _configKey)
        public
        view
        returns (address _configValue)
    {
        _configValue = daoConfigsStorage().addressConfigs(_configKey);
    }

    function getBytesConfig(bytes32 _configKey)
        public
        view
        returns (bytes32 _configValue)
    {
        _configValue = daoConfigsStorage().bytesConfigs(_configKey);
    }

    /**
    @notice Check if a user is a participant in the current quarter
    */
    function isParticipant(address _user)
        public
        view
        returns (bool _is)
    {
        _is =
            (daoRewardsStorage().lastParticipatedQuarter(_user) == currentQuarterNumber())
            && (daoStakeStorage().lockedDGDStake(_user) >= getUintConfig(CONFIG_MINIMUM_LOCKED_DGD));
    }

    /**
    @notice Check if a user is a moderator in the current quarter
    */
    function isModerator(address _user)
        public
        view
        returns (bool _is)
    {
        _is =
            (daoRewardsStorage().lastParticipatedQuarter(_user) == currentQuarterNumber())
            && (daoStakeStorage().lockedDGDStake(_user) >= getUintConfig(CONFIG_MINIMUM_DGD_FOR_MODERATOR))
            && (daoPointsStorage().getReputation(_user) >= getUintConfig(CONFIG_MINIMUM_REPUTATION_FOR_MODERATOR));
    }

    /**
    @notice Calculate the start of a specific milestone of a specific proposal.
    @dev This is calculated from the voting start of the voting round preceding the milestone
         This would throw if the voting start is 0 (the voting round has not started yet)
         Note that if the milestoneIndex is exactly the same as the number of milestones,
         This will just return the end of the last voting round.
    */
    function startOfMilestone(bytes32 _proposalId, uint256 _milestoneIndex)
        internal
        view
        returns (uint256 _milestoneStart)
    {
        uint256 _startOfPrecedingVotingRound = daoStorage().readProposalVotingTime(_proposalId, _milestoneIndex);
        require(_startOfPrecedingVotingRound > 0);
        // the preceding voting round must have started

        if (_milestoneIndex == 0) { // This is the 1st milestone, which starts after voting round 0
            _milestoneStart =
                _startOfPrecedingVotingRound
                .add(getUintConfig(CONFIG_VOTING_PHASE_TOTAL));
        } else { // if its the n-th milestone, it starts after voting round n-th
            _milestoneStart =
                _startOfPrecedingVotingRound
                .add(getUintConfig(CONFIG_INTERIM_PHASE_TOTAL));
        }
    }

    /**
    @notice Calculate the actual voting start for a voting round, given the tentative start
    @dev The tentative start is the ideal start. For example, when a proposer finish a milestone, it should be now
         However, sometimes the tentative start is too close to the end of the quarter, hence, the actual voting start should be pushed to the next quarter
    */
    function getTimelineForNextVote(
        uint256 _index,
        uint256 _tentativeVotingStart
    )
        internal
        view
        returns (uint256 _actualVotingStart)
    {
        uint256 _timeLeftInQuarter = getTimeLeftInQuarter(_tentativeVotingStart);
        uint256 _votingDuration = getUintConfig(_index == 0 ? CONFIG_VOTING_PHASE_TOTAL : CONFIG_INTERIM_PHASE_TOTAL);
        _actualVotingStart = _tentativeVotingStart;
        if (timeInQuarter(_tentativeVotingStart) < getUintConfig(CONFIG_LOCKING_PHASE_DURATION)) { // if the tentative start is during a locking phase
            _actualVotingStart = _tentativeVotingStart.add(
                getUintConfig(CONFIG_LOCKING_PHASE_DURATION).sub(timeInQuarter(_tentativeVotingStart))
            );
        } else if (_timeLeftInQuarter < _votingDuration.add(getUintConfig(CONFIG_VOTE_CLAIMING_DEADLINE))) { // if the time left in quarter is not enough to vote and claim voting
            _actualVotingStart = _tentativeVotingStart.add(
                _timeLeftInQuarter.add(getUintConfig(CONFIG_LOCKING_PHASE_DURATION)).add(1)
            );
        }
    }

    /**
    @notice Check if we can add another non-Digix proposal in this quarter
    @dev There is a max cap to the number of non-Digix proposals CONFIG_NON_DIGIX_PROPOSAL_CAP_PER_QUARTER
    */
    function checkNonDigixProposalLimit(bytes32 _proposalId)
        internal
        view
    {
        require(isNonDigixProposalsWithinLimit(_proposalId));
    }

    function isNonDigixProposalsWithinLimit(bytes32 _proposalId)
        internal
        view
        returns (bool _withinLimit)
    {
        bool _isDigixProposal;
        (,,,,,,,,,_isDigixProposal) = daoStorage().readProposal(_proposalId);
        _withinLimit = true;
        if (!_isDigixProposal) {
            _withinLimit = daoProposalCounterStorage().proposalCountByQuarter(currentQuarterNumber()) < getUintConfig(CONFIG_NON_DIGIX_PROPOSAL_CAP_PER_QUARTER);
        }
    }

    /**
    @notice If its a non-Digix proposal, check if the fundings are within limit
    @dev There is a max cap to the fundings and number of milestones for non-Digix proposals
    */
    function checkNonDigixFundings(uint256[] _milestonesFundings, uint256 _finalReward)
        internal
        view
    {
        if (!is_founder()) {
            require(_milestonesFundings.length <= getUintConfig(CONFIG_MAX_MILESTONES_FOR_NON_DIGIX));
            require(MathHelper.sumNumbers(_milestonesFundings).add(_finalReward) <= getUintConfig(CONFIG_MAX_FUNDING_FOR_NON_DIGIX));
        }
    }

    /**
    @notice Check if msg.sender can do operations as a proposer
    @dev Note that this function does not check if he is the proposer of the proposal
    */
    function senderCanDoProposerOperations()
        internal
        view
    {
        require(isMainPhase());
        require(isParticipant(msg.sender));
        require(identity_storage().is_kyc_approved(msg.sender));
    }
}

library DaoIntermediateStructs {
    struct VotingCount {
        // weight of votes "FOR" the voting round
        uint256 forCount;
        // weight of votes "AGAINST" the voting round
        uint256 againstCount;
    }

    // Struct used in large functions to cut down on variables
    struct Users {
        // Length of the above list
        uint256 usersLength;
        // List of addresses, participants of DigixDAO
        address[] users;
    }
}

library DaoStructs {
    struct IntermediateResults {
        // weight of "FOR" votes counted up until the current calculation step
        uint256 currentForCount;

        // weight of "AGAINST" votes counted up until the current calculation step
        uint256 currentAgainstCount;

        // summation of effectiveDGDs up until the iteration of calculation
        uint256 currentSumOfEffectiveBalance;

        // Address of user until which the calculation has been done
        address countedUntil;
    }
}

contract DaoCalculatorService {
    function minimumVotingQuorumForSpecial() public view returns (uint256);

    function votingQuotaForSpecialPass(uint256, uint256) public view returns (bool);

    function minimumDraftQuorum(bytes32) public view returns (uint256);

    function draftQuotaPass(uint256, uint256) public view returns (bool);

    function minimumVotingQuorum(bytes32, uint256) public view returns (uint256);

    function votingQuotaPass(uint256, uint256) public view returns (bool);
}

contract DaoFundingManager {
    function refundCollateral(address, bytes32) public returns (bool);
}

contract DaoRewardsManager {
}

/**
@title Contract to claim voting results
@author Digix Holdings
*/
contract DaoVotingClaims is DaoCommon {
    using DaoIntermediateStructs for DaoIntermediateStructs.VotingCount;
    using DaoIntermediateStructs for DaoIntermediateStructs.Users;
    using DaoStructs for DaoStructs.IntermediateResults;

    function daoCalculatorService()
        internal
        view
        returns (DaoCalculatorService _contract)
    {
        _contract = DaoCalculatorService(get_contract(CONTRACT_SERVICE_DAO_CALCULATOR));
    }

    function daoFundingManager()
        internal
        view
        returns (DaoFundingManager _contract)
    {
        _contract = DaoFundingManager(get_contract(CONTRACT_DAO_FUNDING_MANAGER));
    }

    function daoRewardsManager()
        internal
        view
        returns (DaoRewardsManager _contract)
    {
        _contract = DaoRewardsManager(get_contract(CONTRACT_DAO_REWARDS_MANAGER));
    }

    constructor(address _resolver) public {
        require(init(CONTRACT_DAO_VOTING_CLAIMS, _resolver));
    }


    /**
    @notice Function to claim the draft voting result (can only be called by the proposal proposer)
    @dev The founder/or anyone is supposed to call this function after the claiming deadline has passed, to clean it up and close this proposal.
         If this voting fails, the collateral will be refunded
    @param _proposalId ID of the proposal
    @param _operations Number of operations to do in this call
    @return {
      "_passed": "Boolean, true if the draft voting has passed, false if the claiming deadline has passed or the voting has failed",
      "_done": "Boolean, true if the calculation has finished"
    }
    */
    function claimDraftVotingResult(
        bytes32 _proposalId,
        uint256 _operations
    )
        public
        ifDraftNotClaimed(_proposalId)
        ifAfterDraftVotingPhase(_proposalId)
        returns (bool _passed, bool _done)
    {
        // if after the claiming deadline, or the limit for non-digix proposals is reached, its auto failed
        if (now > daoStorage().readProposalDraftVotingTime(_proposalId)
                    .add(getUintConfig(CONFIG_DRAFT_VOTING_PHASE))
                    .add(getUintConfig(CONFIG_VOTE_CLAIMING_DEADLINE))
            || !isNonDigixProposalsWithinLimit(_proposalId))
        {
            daoStorage().setProposalDraftPass(_proposalId, false);
            daoStorage().setDraftVotingClaim(_proposalId, true);
            processCollateralRefund(_proposalId);
            return (false, true);
        }
        require(isFromProposer(_proposalId));
        senderCanDoProposerOperations();

        if (_operations == 0) { // if no operations are passed, return with done = false
            return (false, false);
        }

        // get the previously stored intermediary state
        DaoStructs.IntermediateResults memory _currentResults;
        (
            _currentResults.countedUntil,
            _currentResults.currentForCount,
            _currentResults.currentAgainstCount,
        ) = intermediateResultsStorage().getIntermediateResults(_proposalId);

        // get the moderators to calculate in this transaction, based on intermediate state
        address[] memory _moderators;
        if (_currentResults.countedUntil == EMPTY_ADDRESS) {
            _moderators = daoListingService().listModerators(
                _operations,
                true
            );
        } else {
            _moderators = daoListingService().listModeratorsFrom(
               _currentResults.countedUntil,
               _operations,
               true
           );
        }

        // count the votes for this batch of moderators
        DaoIntermediateStructs.VotingCount memory _voteCount;
        (_voteCount.forCount, _voteCount.againstCount) = daoStorage().readDraftVotingCount(_proposalId, _moderators);

        _currentResults.countedUntil = _moderators[_moderators.length-1];
        _currentResults.currentForCount = _currentResults.currentForCount.add(_voteCount.forCount);
        _currentResults.currentAgainstCount = _currentResults.currentAgainstCount.add(_voteCount.againstCount);

        if (_moderators[_moderators.length-1] == daoStakeStorage().readLastModerator()) {
            // this is the last iteration
            _passed = processDraftVotingClaim(_proposalId, _currentResults);
            _done = true;

            // reset intermediate result for the proposal.
            intermediateResultsStorage().resetIntermediateResults(_proposalId);
        } else {
            // update intermediate results
            intermediateResultsStorage().setIntermediateResults(
                _proposalId,
                _currentResults.countedUntil,
                _currentResults.currentForCount,
                _currentResults.currentAgainstCount,
                0
            );
        }
    }


    function processDraftVotingClaim(bytes32 _proposalId, DaoStructs.IntermediateResults _currentResults)
        internal
        returns (bool _passed)
    {
        if (
            (_currentResults.currentForCount.add(_currentResults.currentAgainstCount) > daoCalculatorService().minimumDraftQuorum(_proposalId)) &&
            (daoCalculatorService().draftQuotaPass(_currentResults.currentForCount, _currentResults.currentAgainstCount))
        ) {
            daoStorage().setProposalDraftPass(_proposalId, true);

            // set startTime of first voting round
            // and the start of first milestone.
            uint256 _idealStartTime = daoStorage().readProposalDraftVotingTime(_proposalId).add(getUintConfig(CONFIG_DRAFT_VOTING_PHASE));
            daoStorage().setProposalVotingTime(
                _proposalId,
                0,
                getTimelineForNextVote(0, _idealStartTime)
            );
            _passed = true;
        } else {
            daoStorage().setProposalDraftPass(_proposalId, false);
            processCollateralRefund(_proposalId);
        }

        daoStorage().setDraftVotingClaim(_proposalId, true);
    }

    /// NOTE: Voting round i-th is before milestone index i-th


    /**
    @notice Function to claim the  voting round results
    @dev This function has two major steps:
         - Counting the votes
            + There is no need for this step if there are some conditions that makes the proposal auto failed
            + The number of operations needed for this step is the number of participants in the quarter
         - Calculating the bonus for the voters in the preceding round
            + We can skip this step if this is the Voting round 0 (there is no preceding voting round to calculate bonus)
            + The number of operations needed for this step is the number of participants who voted "correctly" in the preceding voting round
         Step 1 will have to finish first before step 2. The proposer is supposed to call this function repeatedly,
         until _done is true

         If the voting round fails, the collateral will be returned back to the proposer
    @param _proposalId ID of the proposal
    @param _index Index of the  voting round
    @param _operations Number of operations to do in this call
    @return {
      "_passed": "Boolean, true if the  voting round passed, false if failed"
    }
    */
    function claimProposalVotingResult(bytes32 _proposalId, uint256 _index, uint256 _operations)
        public
        ifNotClaimed(_proposalId, _index)
        ifAfterProposalRevealPhase(_proposalId, _index)
        returns (bool _passed, bool _done)
    {
        require(isMainPhase());

        // STEP 1
        // If the claiming deadline is over, the proposal is auto failed, and anyone can call this function
        // Here, _done is refering to whether STEP 1 is done
        _done = true;
        _passed = false; // redundant, put here just to emphasize that its false
        uint256 _operationsLeft = _operations;

        if (_operations == 0) { // if no operations are passed, return with done = false
            return (false, false);
        }

        // In other words, we only need to do Step 1 if its before the deadline
        if (now < startOfMilestone(_proposalId, _index)
                    .add(getUintConfig(CONFIG_VOTE_CLAIMING_DEADLINE)))
        {
            (_operationsLeft, _passed, _done) = countProposalVote(_proposalId, _index, _operations);
            // from here on, _operationsLeft is the number of operations left, after Step 1 is done
            if (!_done) return (_passed, false); // haven't done Step 1 yet, return. The value of _passed here is irrelevant
        }

        // STEP 2
        // from this point onwards, _done refers to step 2
        _done = false;

        if (_index > 0) { // We only need to do bonus calculation if its a interim voting round
            _done = calculateVoterBonus(_proposalId, _index, _operationsLeft, _passed);
            if (!_done) return (_passed, false); // Step 2 is not done yet, return
        } else {
            // its the first voting round, we return the collateral if it fails, locks if it passes

            _passed = _passed && isNonDigixProposalsWithinLimit(_proposalId); // can only pass if its within the non-digix proposal limit
            if (_passed) {
                daoStorage().setProposalCollateralStatus(
                    _proposalId,
                    COLLATERAL_STATUS_LOCKED
                );

            } else {
                processCollateralRefund(_proposalId);
            }
        }

        if (_passed) {
            processSuccessfulVotingClaim(_proposalId, _index);
        }
        daoStorage().setVotingClaim(_proposalId, _index, true);
        daoStorage().setProposalPass(_proposalId, _index, _passed);
        _done = true;
    }


    // do the necessary steps after a successful voting round.
    function processSuccessfulVotingClaim(bytes32 _proposalId, uint256 _index)
        internal
    {
        // clear the intermediate results for the proposal, so that next voting rounds can reuse the same key <proposal_id> for the intermediate results
        intermediateResultsStorage().resetIntermediateResults(_proposalId);

        // if this was the final voting round, unlock their original collateral
        uint256[] memory _milestoneFundings;
        (_milestoneFundings,) = daoStorage().readProposalFunding(_proposalId);
        if (_index == _milestoneFundings.length) {
            processCollateralRefund(_proposalId);
            daoStorage().archiveProposal(_proposalId);
        }

        // increase the non-digix proposal count accordingly
        bool _isDigixProposal;
        (,,,,,,,,,_isDigixProposal) = daoStorage().readProposal(_proposalId);
        if (_index == 0 && !_isDigixProposal) {
            daoProposalCounterStorage().addNonDigixProposalCountInQuarter(currentQuarterNumber());
        }

        // Add quarter point for the proposer
        uint256 _funding = daoStorage().readProposalMilestone(_proposalId, _index);
        daoPointsStorage().addQuarterPoint(
            daoStorage().readProposalProposer(_proposalId),
            getUintConfig(CONFIG_QUARTER_POINT_MILESTONE_COMPLETION_PER_10000ETH).mul(_funding).div(10000 ether),
            currentQuarterNumber()
        );
    }


    function getInterResultKeyForBonusCalculation(bytes32 _proposalId) public view returns (bytes32 _key) {
        _key = keccak256(abi.encodePacked(
            _proposalId,
            INTERMEDIATE_BONUS_CALCULATION_IDENTIFIER
        ));
    }


    // calculate and update the bonuses for voters who voted "correctly" in the preceding voting round
    function calculateVoterBonus(bytes32 _proposalId, uint256 _index, uint256 _operations, bool _passed)
        internal
        returns (bool _done)
    {
        if (_operations == 0) return false;
        address _countedUntil;
        (_countedUntil,,,) = intermediateResultsStorage().getIntermediateResults(
            getInterResultKeyForBonusCalculation(_proposalId)
        );

        address[] memory _voterBatch;
        if (_countedUntil == EMPTY_ADDRESS) {
            _voterBatch = daoListingService().listParticipants(
                _operations,
                true
            );
        } else {
            _voterBatch = daoListingService().listParticipantsFrom(
                _countedUntil,
                _operations,
                true
            );
        }
        address _lastVoter = _voterBatch[_voterBatch.length - 1]; // this will fail if _voterBatch is empty. However, there is at least the proposer as a participant in the quarter.

        DaoIntermediateStructs.Users memory _bonusVoters;
        if (_passed) {

            // give bonus points for all those who
            // voted YES in the previous round
            (_bonusVoters.users, _bonusVoters.usersLength) = daoStorage().readVotingRoundVotes(_proposalId, _index.sub(1), _voterBatch, true);
        } else {
            // give bonus points for all those who
            // voted NO in the previous round
            (_bonusVoters.users, _bonusVoters.usersLength) = daoStorage().readVotingRoundVotes(_proposalId, _index.sub(1), _voterBatch, false);
        }

        if (_bonusVoters.usersLength > 0) addBonusReputation(_bonusVoters.users, _bonusVoters.usersLength);

        if (_lastVoter == daoStakeStorage().readLastParticipant()) {
            // this is the last iteration

            intermediateResultsStorage().resetIntermediateResults(
                getInterResultKeyForBonusCalculation(_proposalId)
            );
            _done = true;
        } else {
            // this is not the last iteration yet, save the intermediate results
            intermediateResultsStorage().setIntermediateResults(
                getInterResultKeyForBonusCalculation(_proposalId),
                _lastVoter, 0, 0, 0
            );
        }
    }


    // Count the votes for a Voting Round and find out if its passed
    /// @return _operationsLeft The number of operations left after the calculations in this function
    /// @return _passed Whether this voting round passed
    /// @return _done Whether the calculation for this step 1 is already done. If its not done, this function will need to run again in subsequent transactions
    /// until _done is true
    function countProposalVote(bytes32 _proposalId, uint256 _index, uint256 _operations)
        internal
        returns (uint256 _operationsLeft, bool _passed, bool _done)
    {
        senderCanDoProposerOperations();
        require(isFromProposer(_proposalId));

        DaoStructs.IntermediateResults memory _currentResults;
        (
            _currentResults.countedUntil,
            _currentResults.currentForCount,
            _currentResults.currentAgainstCount,
        ) = intermediateResultsStorage().getIntermediateResults(_proposalId);
        address[] memory _voters;
        if (_currentResults.countedUntil == EMPTY_ADDRESS) { // This is the first transaction to count votes for this voting round
            _voters = daoListingService().listParticipants(
                _operations,
                true
            );
        } else {
            _voters = daoListingService().listParticipantsFrom(
                _currentResults.countedUntil,
                _operations,
                true
            );

            // If there's no voters left to count, this means that STEP 1 is already done, just return whether it was passed
            // Note that _currentResults should already be storing the final tally of votes for this voting round, as already calculated in previous iterations of this function
            if (_voters.length == 0) {
                return (
                    _operations,
                    isVoteCountPassed(_currentResults, _proposalId, _index),
                    true
                );
            }
        }

        address _lastVoter = _voters[_voters.length - 1];

        DaoIntermediateStructs.VotingCount memory _count;
        (_count.forCount, _count.againstCount) = daoStorage().readVotingCount(_proposalId, _index, _voters);

        _currentResults.currentForCount = _currentResults.currentForCount.add(_count.forCount);
        _currentResults.currentAgainstCount = _currentResults.currentAgainstCount.add(_count.againstCount);
        intermediateResultsStorage().setIntermediateResults(
            _proposalId,
            _lastVoter,
            _currentResults.currentForCount,
            _currentResults.currentAgainstCount,
            0
        );

        if (_lastVoter != daoStakeStorage().readLastParticipant()) {
            return (0, false, false); // hasn't done STEP 1 yet. The parent function (claimProposalVotingResult) should return after this. More transactions are needed to continue the calculation
        }

        // If it comes to here, this means all votes have already been counted
        // From this point, the IntermediateResults struct will store the total tally of the votes for this voting round until processSuccessfulVotingClaim() is called,
        // which will reset it.

        _operationsLeft = _operations.sub(_voters.length);
        _done = true;

        _passed = isVoteCountPassed(_currentResults, _proposalId, _index);
    }


    function isVoteCountPassed(DaoStructs.IntermediateResults _currentResults, bytes32 _proposalId, uint256 _index)
        internal
        view
        returns (bool _passed)
    {
        _passed = (_currentResults.currentForCount.add(_currentResults.currentAgainstCount) > daoCalculatorService().minimumVotingQuorum(_proposalId, _index))
                && (daoCalculatorService().votingQuotaPass(_currentResults.currentForCount, _currentResults.currentAgainstCount));
    }


    function processCollateralRefund(bytes32 _proposalId)
        internal
    {
        daoStorage().setProposalCollateralStatus(_proposalId, COLLATERAL_STATUS_CLAIMED);
        require(daoFundingManager().refundCollateral(daoStorage().readProposalProposer(_proposalId), _proposalId));
    }


    // add bonus reputation for voters that voted "correctly" in the preceding voting round AND is currently participating this quarter
    function addBonusReputation(address[] _voters, uint256 _n)
        private
    {
        uint256 _qp = getUintConfig(CONFIG_QUARTER_POINT_VOTE);
        uint256 _rate = getUintConfig(CONFIG_BONUS_REPUTATION_NUMERATOR);
        uint256 _base = getUintConfig(CONFIG_BONUS_REPUTATION_DENOMINATOR);

        uint256 _bonus = _qp.mul(_rate).mul(getUintConfig(CONFIG_REPUTATION_PER_EXTRA_QP_NUM))
            .div(
                _base.mul(getUintConfig(CONFIG_REPUTATION_PER_EXTRA_QP_DEN))
            );

        for (uint256 i = 0; i < _n; i++) {
            if (isParticipant(_voters[i])) { // only give bonus reputation to current participants
                daoPointsStorage().increaseReputation(_voters[i], _bonus);
            }
        }
    }
}