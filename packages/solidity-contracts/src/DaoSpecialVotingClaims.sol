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

    function listParticipantsFrom(
        address,
        uint256,
        bool
    ) public view returns (address[]);
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
}

contract DaoStorage {
    function readProposal(bytes32) public view returns (bytes32, address, address, bytes32, uint256, uint256, bytes32, bytes32, bool, bool);

    function readProposalProposer(bytes32) public view returns (address);

    function readProposalDraftVotingResult(bytes32) public view returns (bool);

    function readProposalVotingResult(bytes32, uint256) public view returns (bool);

    function readProposalDraftVotingTime(bytes32) public view returns (uint256);

    function readProposalVotingTime(bytes32, uint256) public view returns (uint256);

    function readVote(bytes32, uint256, address) public view returns (bool, uint256);

    function isDraftClaimed(bytes32) public view returns (bool);

    function isClaimed(bytes32, uint256) public view returns (bool);
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
}

contract DaoRewardsStorage {
    mapping (address => uint256) public lastParticipatedQuarter;

    function readDgxDistributionDay(uint256) public view returns (uint256);
}

contract IntermediateResultsStorage {
    function getIntermediateResults(bytes32) public view returns (address, uint256, uint256, uint256);

    function setIntermediateResults(bytes32, address, uint256, uint256, uint256) public;
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
}

contract DaoFundingManager {
}

contract DaoRewardsManager {
}

/**
@title Contract to claim voting results
@author Digix Holdings
*/
contract DaoSpecialVotingClaims is DaoCommon {
    using DaoIntermediateStructs for DaoIntermediateStructs.VotingCount;
    using DaoStructs for DaoStructs.IntermediateResults;

    event SpecialProposalClaim(bytes32 indexed _proposalId, bool _result);

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
        require(init(CONTRACT_DAO_SPECIAL_VOTING_CLAIMS, _resolver));
    }


    /**
    @notice Function to claim the voting result on special proposal
    @param _proposalId ID of the special proposal
    @return {
      "_passed": "Boolean, true if voting passed, throw if failed, returns false if passed deadline"
    }
    */
    function claimSpecialProposalVotingResult(bytes32 _proposalId, uint256 _operations)
        public
        ifNotClaimedSpecial(_proposalId)
        ifAfterRevealPhaseSpecial(_proposalId)
        returns (bool _passed)
    {
        require(isMainPhase());
        if (now > daoSpecialStorage().readVotingTime(_proposalId)
                    .add(getUintConfig(CONFIG_SPECIAL_PROPOSAL_PHASE_TOTAL))
                    .add(getUintConfig(CONFIG_VOTE_CLAIMING_DEADLINE))) {
            daoSpecialStorage().setPass(_proposalId, false);
            return false;
        }
        require(msg.sender == daoSpecialStorage().readProposalProposer(_proposalId));

        if (_operations == 0) { // if no operations are passed, return false
            return (false);
        }

        DaoStructs.IntermediateResults memory _currentResults;
        (
            _currentResults.countedUntil,
            _currentResults.currentForCount,
            _currentResults.currentAgainstCount,
        ) = intermediateResultsStorage().getIntermediateResults(_proposalId);

        address[] memory _voters;
        if (_currentResults.countedUntil == EMPTY_ADDRESS) {
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
        }

        address _lastVoter = _voters[_voters.length - 1];

        DaoIntermediateStructs.VotingCount memory _voteCount;
        (_voteCount.forCount, _voteCount.againstCount) = daoSpecialStorage().readVotingCount(_proposalId, _voters);

        _currentResults.countedUntil = _lastVoter;
        _currentResults.currentForCount = _currentResults.currentForCount.add(_voteCount.forCount);
        _currentResults.currentAgainstCount = _currentResults.currentAgainstCount.add(_voteCount.againstCount);

        if (_lastVoter == daoStakeStorage().readLastParticipant()) {
            // this is already the last transaction, we have counted all the votes

            if (
                (_currentResults.currentForCount.add(_currentResults.currentAgainstCount) > daoCalculatorService().minimumVotingQuorumForSpecial()) &&
                (daoCalculatorService().votingQuotaForSpecialPass(_currentResults.currentForCount, _currentResults.currentAgainstCount))
            ) {
                _passed = true;
                setConfigs(_proposalId);
            }
            daoSpecialStorage().setPass(_proposalId, _passed);
            daoSpecialStorage().setVotingClaim(_proposalId, true);
            emit SpecialProposalClaim(_proposalId, _passed);
        } else {
            intermediateResultsStorage().setIntermediateResults(
                _proposalId,
                _currentResults.countedUntil,
                _currentResults.currentForCount,
                _currentResults.currentAgainstCount,
                0
            );
        }
    }


    function setConfigs(bytes32 _proposalId)
        private
    {
        uint256[] memory _uintConfigs;
        address[] memory _addressConfigs;
        bytes32[] memory _bytesConfigs;
        (
            _uintConfigs,
            _addressConfigs,
            _bytesConfigs
        ) = daoSpecialStorage().readConfigs(_proposalId);
        daoConfigsStorage().updateUintConfigs(_uintConfigs);
    }

}