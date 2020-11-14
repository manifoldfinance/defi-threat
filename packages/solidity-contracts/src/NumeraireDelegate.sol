/**
 * Source Code first verified at https://etherscan.io on Tuesday, April 30, 2019
 (UTC) */

// From OpenZepplin: https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/ownership/Shareable.sol
/*
 * Shareable
 * 
 * Effectively our multisig contract
 *
 * Based on https://github.com/ethereum/dapp-bin/blob/master/wallet/wallet.sol
 *
 * inheritable "property" contract that enables methods to be protected by requiring the acquiescence of either a single, or, crucially, each of a number of, designated owners.
 *
 * usage:
 * use modifiers onlyowner (just own owned) or onlymanyowners(hash), whereby the same hash must be provided by some number (specified in constructor) of the set of owners (specified in the constructor) before the interior is executed.
 */
contract Shareable {
  // TYPES

  // struct for the status of a pending operation.
  struct PendingState {
    uint yetNeeded;
    uint ownersDone;
    uint index;
  }


  // FIELDS

  // the number of owners that must confirm the same operation before it is run.
  uint public required;

  // list of owners
  address[256] owners;
  uint constant c_maxOwners = 250;
  // index on the list of owners to allow reverse lookup
  mapping(address => uint) ownerIndex;
  // the ongoing operations.
  mapping(bytes32 => PendingState) pendings;
  bytes32[] pendingsIndex;


  // EVENTS

  // this contract only has six types of events: it can accept a confirmation, in which case
  // we record owner and operation (hash) alongside it.
  event Confirmation(address owner, bytes32 operation);
  event Revoke(address owner, bytes32 operation);


  // MODIFIERS

  address thisContract = this;

  // simple single-sig function modifier.
  modifier onlyOwner {
    if (isOwner(msg.sender))
      _;
  }

  // multi-sig function modifier: the operation must have an intrinsic hash in order
  // that later attempts can be realised as the same underlying operation and
  // thus count as confirmations.
  modifier onlyManyOwners(bytes32 _operation) {
    if (confirmAndCheck(_operation))
      _;
  }


  // CONSTRUCTOR

  // constructor is given number of sigs required to do protected "onlymanyowners" transactions
  // as well as the selection of addresses capable of confirming them.
  function Shareable(address[] _owners, uint _required) {
    owners[1] = msg.sender;
    ownerIndex[msg.sender] = 1;
    for (uint i = 0; i < _owners.length; ++i) {
      owners[2 + i] = _owners[i];
      ownerIndex[_owners[i]] = 2 + i;
    }
    if (required > owners.length) throw;
    required = _required;
  }


  // new multisig is given number of sigs required to do protected "onlymanyowners" transactions
  // as well as the selection of addresses capable of confirming them.
  // take all new owners as an array
  function changeShareable(address[] _owners, uint _required) onlyManyOwners(sha3(msg.data)) {
    for (uint i = 0; i < _owners.length; ++i) {
      owners[1 + i] = _owners[i];
      ownerIndex[_owners[i]] = 1 + i;
    }
    if (required > owners.length) throw;
    required = _required;
  }

  // METHODS

  // Revokes a prior confirmation of the given operation
  function revoke(bytes32 _operation) external {
    uint index = ownerIndex[msg.sender];
    // make sure they're an owner
    if (index == 0) return;
    uint ownerIndexBit = 2**index;
    var pending = pendings[_operation];
    if (pending.ownersDone & ownerIndexBit > 0) {
      pending.yetNeeded++;
      pending.ownersDone -= ownerIndexBit;
      Revoke(msg.sender, _operation);
    }
  }

  // Gets an owner by 0-indexed position (using numOwners as the count)
  function getOwner(uint ownerIndex) external constant returns (address) {
    return address(owners[ownerIndex + 1]);
  }

  function isOwner(address _addr) constant returns (bool) {
    return ownerIndex[_addr] > 0;
  }

  function hasConfirmed(bytes32 _operation, address _owner) constant returns (bool) {
    var pending = pendings[_operation];
    uint index = ownerIndex[_owner];

    // make sure they're an owner
    if (index == 0) return false;

    // determine the bit to set for this owner.
    uint ownerIndexBit = 2**index;
    return !(pending.ownersDone & ownerIndexBit == 0);
  }

  // INTERNAL METHODS

  function confirmAndCheck(bytes32 _operation) internal returns (bool) {
    // determine what index the present sender is:
    uint index = ownerIndex[msg.sender];
    // make sure they're an owner
    if (index == 0) return;

    var pending = pendings[_operation];
    // if we're not yet working on this operation, switch over and reset the confirmation status.
    if (pending.yetNeeded == 0) {
      // reset count of confirmations needed.
      pending.yetNeeded = required;
      // reset which owners have confirmed (none) - set our bitmap to 0.
      pending.ownersDone = 0;
      pending.index = pendingsIndex.length++;
      pendingsIndex[pending.index] = _operation;
    }
    // determine the bit to set for this owner.
    uint ownerIndexBit = 2**index;
    // make sure we (the message sender) haven't confirmed this operation previously.
    if (pending.ownersDone & ownerIndexBit == 0) {
      Confirmation(msg.sender, _operation);
      // ok - check if count is enough to go ahead.
      if (pending.yetNeeded <= 1) {
        // enough confirmations: reset and run interior.
        delete pendingsIndex[pendings[_operation].index];
        delete pendings[_operation];
        return true;
      }
      else
        {
          // not enough: record that this owner in particular confirmed.
          pending.yetNeeded--;
          pending.ownersDone |= ownerIndexBit;
        }
    }
  }

  function clearPending() internal {
    uint length = pendingsIndex.length;
    for (uint i = 0; i < length; ++i)
    if (pendingsIndex[i] != 0)
      delete pendings[pendingsIndex[i]];
    delete pendingsIndex;
  }
}

// From OpenZepplin: https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/lifecycle/Pausable.sol
/*
 * Stoppable
 * Abstract contract that allows children to implement an
 * emergency stop mechanism.
 */
contract StoppableShareable is Shareable {
  bool public stopped;
  bool public stoppable = true;

  modifier stopInEmergency { if (!stopped) _; }
  modifier onlyInEmergency { if (stopped) _; }

  function StoppableShareable(address[] _owners, uint _required) Shareable(_owners, _required) {
  }

  // called by the owner on emergency, triggers stopped state
  function emergencyStop() external onlyOwner {
    assert(stoppable);
    stopped = true;
  }

  // called by the owners on end of emergency, returns to normal state
  function release() external onlyManyOwners(sha3(msg.data)) {
    assert(stoppable);
    stopped = false;
  }

  // called by the owners to disable ability to begin or end an emergency stop
  function disableStopping() external onlyManyOwners(sha3(msg.data)) {
    stoppable = false;
  }
}

contract Safe {
    // Check if it is safe to add two numbers
    function safeAdd(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
        return c;
    }

    // Check if it is safe to subtract two numbers
    function safeSubtract(uint a, uint b) internal returns (uint) {
        uint c = a - b;
        assert(b <= a && c <= a);
        return c;
    }

    function safeMultiply(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || (c / a) == b);
        return c;
    }

    function shrink128(uint a) internal returns (uint128) {
        assert(a < 0x100000000000000000000000000000000);
        return uint128(a);
    }

    // mitigate short address attack
    modifier onlyPayloadSize(uint numWords) {
        assert(msg.data.length == numWords * 32 + 4);
        _;
    }

    // allow ether to be received
    function () payable { }

}

// Class variables used both in NumeraireBackend and NumeraireDelegate

contract NumeraireShared is Safe {

    address public numerai = this;

    // Cap the total supply and the weekly supply
    uint256 public supply_cap = 21000000e18; // 21 million
    uint256 public weekly_disbursement = 96153846153846153846153;

    uint256 public initial_disbursement;
    uint256 public deploy_time;

    uint256 public total_minted;

    // ERC20 requires totalSupply, balanceOf, and allowance
    uint256 public totalSupply;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    mapping (uint => Tournament) public tournaments;  // tournamentID

    struct Tournament {
        uint256 creationTime;
        uint256[] roundIDs;
        mapping (uint256 => Round) rounds;  // roundID
    } 

    struct Round {
        uint256 creationTime;
        uint256 endTime;
        uint256 resolutionTime;
        mapping (address => mapping (bytes32 => Stake)) stakes;  // address of staker
    }

    // The order is important here because of its packing characteristics.
    // Particularly, `amount` and `confidence` are in the *same* word, so
    // Solidity can update both at the same time (if the optimizer can figure
    // out that you're updating both).  This makes `stake()` cheap.
    struct Stake {
        uint128 amount; // Once the stake is resolved, this becomes 0
        uint128 confidence;
        bool successful;
        bool resolved;
    }

    // Generates a public event on the blockchain to notify clients
    event Mint(uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Staked(address indexed staker, bytes32 tag, uint256 totalAmountStaked, uint256 confidence, uint256 indexed tournamentID, uint256 indexed roundID);
    event RoundCreated(uint256 indexed tournamentID, uint256 indexed roundID, uint256 endTime, uint256 resolutionTime);
    event TournamentCreated(uint256 indexed tournamentID);
    event StakeDestroyed(uint256 indexed tournamentID, uint256 indexed roundID, address indexed stakerAddress, bytes32 tag);
    event StakeReleased(uint256 indexed tournamentID, uint256 indexed roundID, address indexed stakerAddress, bytes32 tag, uint256 etherReward);

    // Calculate allowable disbursement
    function getMintable() constant returns (uint256) {
        return
            safeSubtract(
                safeAdd(initial_disbursement,
                    safeMultiply(weekly_disbursement,
                        safeSubtract(block.timestamp, deploy_time))
                    / 1 weeks),
                total_minted);
    }
}

// Whoever creates the contract has the power to stop it, this person can be changed via transferOwnership(_new_address)
contract NumeraireDelegate is StoppableShareable, NumeraireShared {

    function NumeraireDelegate(address[] _owners, uint256 _num_required) StoppableShareable(_owners, _num_required) {
    }

    // All minted NMR are initially sent to Numerai, obeying both weekly and total supply caps
    function mint(uint256 _value) onlyOwner returns (bool ok) {
        // Prevent minting more than the supply cap.
        require(safeAdd(total_minted, _value) <= supply_cap);

        // Prevent minting more than the disbursement.
        require(_value <= getMintable());

        balanceOf[numerai] = safeAdd(balanceOf[numerai], _value);
        totalSupply = safeAdd(totalSupply, _value);
        total_minted = safeAdd(total_minted, _value);

        // Notify anyone listening.
        Mint(_value);

        return true;
    }

    // Numerai calls this function to release staked tokens when the staked predictions were successful
    function releaseStake(address _staker, bytes32 _tag, uint256 _etherValue, uint256 _tournamentID, uint256 _roundID, bool _successful) onlyOwner stopInEmergency returns (bool ok) {
        var round = tournaments[_tournamentID].rounds[_roundID];
        var stake = round.stakes[_staker][_tag];
        var originalStakeAmount = stake.amount;

        require(stake.amount > 0);
        require(!stake.resolved);
        require(round.resolutionTime <= block.timestamp);

        stake.amount = 0;
        balanceOf[_staker] = safeAdd(balanceOf[_staker], originalStakeAmount);
        stake.resolved = true;
        stake.successful = _successful;

        if (_etherValue > 0) {
            if (!_staker.send(_etherValue)) {
                stake.amount = originalStakeAmount;
                balanceOf[_staker] -= originalStakeAmount; // safe because we just added it
                stake.resolved = false;
                stake.successful = false;
                return false;
            }
        }

        StakeReleased(_tournamentID, _roundID, _staker, _tag, _etherValue);
        return true;
    }

    // Destroy staked tokens if the predictions were not successful
    function destroyStake(address _staker, bytes32 _tag, uint256 _tournamentID, uint256 _roundID) onlyOwner stopInEmergency returns (bool ok) {
        var round = tournaments[_tournamentID].rounds[_roundID];
        var stake = round.stakes[_staker][_tag];
        var originalStakeAmount = stake.amount;

        require(stake.amount > 0);
        require(!stake.resolved);
        require(round.resolutionTime <= block.timestamp);

        stake.amount = 0;
        totalSupply = safeSubtract(totalSupply, originalStakeAmount);
        stake.resolved = true;
        stake.successful = false;

        StakeDestroyed(_tournamentID, _roundID, _staker, _tag);
        return true;
    }

    // Anyone but Numerai can stake on themselves
    function stake(uint256 _value, bytes32 _tag, uint256 _tournamentID, uint256 _roundID, uint256 _confidence) stopInEmergency returns (bool ok) {
        return _stake(msg.sender, _value, _tag, _tournamentID, _roundID, _confidence);
    }

    // Only Numerai can stake on behalf of other accounts. _stake_owner will always be Numerai's hot wallet
    function stakeOnBehalf(address _staker, uint256 _value, bytes32 _tag, uint256 _tournamentID, uint256 _roundID, uint256 _confidence) onlyOwner stopInEmergency returns (bool ok) {
        var max_deposit_address = 1000000;
        require(_staker <= max_deposit_address);
        return _stake(_staker, _value, _tag, _tournamentID, _roundID, _confidence);
    }

    function _stake(address _staker, uint256 _value, bytes32 _tag, uint256 _tournamentID, uint256 _roundID, uint256 _confidence) stopInEmergency internal returns (bool ok) {
        var tournament = tournaments[_tournamentID];
        var round = tournament.rounds[_roundID];
        var stake = round.stakes[_staker][_tag];

        require(!isOwner(_staker) && _staker != numerai); // Numerai cannot stake on itself
        require(balanceOf[_staker] >= _value); // Check for sufficient funds
        require(tournament.creationTime > 0); // This tournament must be initialized
        require(round.creationTime > 0); // This round must be initialized
        require(round.endTime > block.timestamp); // Can't stake after round ends
        require(_value > 0 || stake.amount > 0); // Can't stake zero NMR

        require(stake.confidence == 0 || stake.confidence <= _confidence);

        // Keep these two lines together so that the Solidity optimizer can
        // merge them into a single SSTORE.
        stake.amount = shrink128(safeAdd(stake.amount, _value));
        stake.confidence = shrink128(_confidence);

        balanceOf[_staker] = safeSubtract(balanceOf[_staker], _value);

        // Notify anyone listening.
        Staked(_staker, _tag, stake.amount, stake.confidence, _tournamentID, _roundID);

        return true;
    }

    // Transfer NMR from Numerai account using multisig
    function numeraiTransfer(address _to, uint256 _value) onlyManyOwners(sha3(msg.data)) returns (bool ok) {
        // If _value is a special number, clear the _to address from owner index
        // We need this because changeShareable does not clear previous owners correctly
        if (_value == 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) {
          if(address(owners[ownerIndex[_to]]) != _to) {
            ownerIndex[_to] = 0;
          }
          return true;
        }

        // Check for sufficient funds.
        require(balanceOf[numerai] >= _value);

        balanceOf[numerai] = safeSubtract(balanceOf[numerai], _value);
        balanceOf[_to] = safeAdd(balanceOf[_to], _value);

        // Notify anyone listening.
        Transfer(numerai, _to, _value);

        return true;
    }

    // Allows Numerai to withdraw on behalf of a data scientist some NMR that they've deposited into a pre-assigned address
    // Numerai will assign these addresses on its website
    function withdraw(address _from, address _to, uint256 _value) onlyOwner returns(bool ok) {
        address max_deposit_address = 1000000;
        require(_from <= max_deposit_address);

        // Identical to transfer(), except msg.sender => _from
        require(balanceOf[_from] >= _value);

        balanceOf[_from] = safeSubtract(balanceOf[_from], _value);
        balanceOf[_to] = safeAdd(balanceOf[_to], _value);

        Transfer(_from, _to, _value);

        return true;
    }

    function createTournament(uint256 _tournamentID) onlyOwner returns (bool ok) {
        var tournament = tournaments[_tournamentID];
        require(tournament.creationTime == 0); // Already created
        tournament.creationTime = block.timestamp;
        TournamentCreated(_tournamentID);
        return true;
    }

    function createRound(uint256 _tournamentID, uint256 _roundID, uint256 _endTime, uint256 _resolutionTime) onlyOwner returns (bool ok) {
        var tournament = tournaments[_tournamentID];
        var round = tournament.rounds[_roundID];
        require(_endTime <= _resolutionTime);
        require(tournament.creationTime > 0);
        require(round.creationTime == 0);
        tournament.roundIDs.push(_roundID);
        round.creationTime = block.timestamp;
        round.endTime = _endTime;
        round.resolutionTime = _resolutionTime;
        RoundCreated(_tournamentID, _roundID, round.endTime, round.resolutionTime);
        return true;
    }
}