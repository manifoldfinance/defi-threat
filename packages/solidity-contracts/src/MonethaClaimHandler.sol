/**
 * Source Code first verified at https://etherscan.io on Monday, April 15, 2019
 (UTC) */

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
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

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.4.24;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

pragma solidity ^0.4.24;



/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

pragma solidity ^0.4.24;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.4.24;



/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol

pragma solidity ^0.4.24;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(
    ERC20Basic _token,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transfer(_to, _value));
  }

  function safeTransferFrom(
    ERC20 _token,
    address _from,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transferFrom(_from, _to, _value));
  }

  function safeApprove(
    ERC20 _token,
    address _spender,
    uint256 _value
  )
    internal
  {
    require(_token.approve(_spender, _value));
  }
}

// File: monetha-utility-contracts/contracts/Restricted.sol

pragma solidity ^0.4.18;



/** @title Restricted
 *  Exposes onlyMonetha modifier
 */
contract Restricted is Ownable {

    //MonethaAddress set event
    event MonethaAddressSet(
        address _address,
        bool _isMonethaAddress
    );

    mapping (address => bool) public isMonethaAddress;

    /**
     *  Restrict methods in such way, that they can be invoked only by monethaAddress account.
     */
    modifier onlyMonetha() {
        require(isMonethaAddress[msg.sender]);
        _;
    }

    /**
     *  Allows owner to set new monetha address
     */
    function setMonethaAddress(address _address, bool _isMonethaAddress) onlyOwner public {
        isMonethaAddress[_address] = _isMonethaAddress;

        emit MonethaAddressSet(_address, _isMonethaAddress);
    }
}

// File: monetha-utility-contracts/contracts/ownership/CanReclaimEther.sol

pragma solidity ^0.4.24;


contract CanReclaimEther is Ownable {
    event ReclaimEther(address indexed to, uint256 amount);

    /**
     * @dev Transfer all Ether held by the contract to the owner.
     */
    function reclaimEther() external onlyOwner {
        uint256 value = address(this).balance;
        owner.transfer(value);

        emit ReclaimEther(owner, value);
    }

    /**
     * @dev Transfer specified amount of Ether held by the contract to the address.
     * @param _to The address which will receive the Ether
     * @param _value The amount of Ether to transfer
     */
    function reclaimEtherTo(address _to, uint256 _value) external onlyOwner {
        require(_to != address(0), "zero address is not allowed");
        _to.transfer(_value);

        emit ReclaimEther(_to, _value);
    }
}

// File: monetha-utility-contracts/contracts/ownership/CanReclaimTokens.sol

pragma solidity ^0.4.24;




contract CanReclaimTokens is Ownable {
    using SafeERC20 for ERC20Basic;

    event ReclaimTokens(address indexed to, uint256 amount);

    /**
     * @dev Reclaim all ERC20Basic compatible tokens
     * @param _token ERC20Basic The address of the token contract
     */
    function reclaimToken(ERC20Basic _token) external onlyOwner {
        uint256 balance = _token.balanceOf(this);
        _token.safeTransfer(owner, balance);

        emit ReclaimTokens(owner, balance);
    }

    /**
     * @dev Reclaim specified amount of ERC20Basic compatible tokens
     * @param _token ERC20Basic The address of the token contract
     * @param _to The address which will receive the tokens
     * @param _value The amount of tokens to transfer
     */
    function reclaimTokenTo(ERC20Basic _token, address _to, uint256 _value) external onlyOwner {
        require(_to != address(0), "zero address is not allowed");
        _token.safeTransfer(_to, _value);

        emit ReclaimTokens(_to, _value);
    }
}

// File: contracts/MonethaClaimHandler.sol

pragma solidity ^0.4.24;









/**
 *  @title MonethaClaimHandler
 *
 *  MonethaClaimHandler handles claim creation, acceptance, resolution and confirmation.
 */
contract MonethaClaimHandler is Restricted, Pausable, CanReclaimEther, CanReclaimTokens {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;
    using SafeERC20 for ERC20Basic;

    event MinStakeUpdated(uint256 previousMinStake, uint256 newMinStake);

    event ClaimCreated(uint256 indexed dealId, uint256 indexed claimIdx);
    event ClaimAccepted(uint256 indexed dealId, uint256 indexed claimIdx);
    event ClaimResolved(uint256 indexed dealId, uint256 indexed claimIdx);
    event ClaimClosedAfterAcceptanceExpired(uint256 indexed dealId, uint256 indexed claimIdx);
    event ClaimClosedAfterResolutionExpired(uint256 indexed dealId, uint256 indexed claimIdx);
    event ClaimClosedAfterConfirmationExpired(uint256 indexed dealId, uint256 indexed claimIdx);
    event ClaimClosed(uint256 indexed dealId, uint256 indexed claimIdx);

    ERC20 public token;      // token contract address
    uint256 public minStake; // minimum amount of token units to create and accept claim

    // State of claim
    enum State {
        Null,
        AwaitingAcceptance,
        AwaitingResolution,
        AwaitingConfirmation,
        ClosedAfterAcceptanceExpired,
        ClosedAfterResolutionExpired,
        ClosedAfterConfirmationExpired,
        Closed
    }

    struct Claim {
        State state;
        uint256 modified;
        uint256 dealId; // immutable after AwaitingAcceptance
        bytes32 dealHash; // immutable after AwaitingAcceptance
        string reasonNote; // immutable after AwaitingAcceptance
        bytes32 requesterId; // immutable after AwaitingAcceptance
        address requesterAddress; // immutable after AwaitingAcceptance
        uint256 requesterStaked; // immutable after AwaitingAcceptance
        bytes32 respondentId; // immutable after AwaitingAcceptance
        address respondentAddress; // immutable after Accepted
        uint256 respondentStaked; // immutable after Accepted
        string resolutionNote; // immutable after Resolved
    }

    Claim[] public claims;

    constructor(ERC20 _token, uint256 _minStake) public {
        require(_token != address(0), "must be valid token address");

        token = _token;
        _setMinStake(_minStake);
    }

    /**
     * @dev sets the minimum amount of tokens units to stake when creating or accepting the claim.
     * Only Monetha account allowed to call this method.
     */
    function setMinStake(uint256 _newMinStake) external whenNotPaused onlyMonetha {
        _setMinStake(_newMinStake);
    }

    /**
     * @dev returns the number of claims created.
     */
    function getClaimsCount() public constant returns (uint256 count) {
        return claims.length;
    }

    /**
    * @dev creates new claim using provided parameters. Before calling this method, requester should approve
    * this contract to transfer min. amount of token units in their behalf, by calling
    * `approve(address _spender, uint _value)` method of token contract.
    * Respondent should accept the claim by calling accept() method.
    * claimIdx should be extracted from ClaimCreated event.
    *
    * Claim state after call 🡒 AwaitingAcceptance
    */
    function create(
        uint256 _dealId,
        bytes32 _dealHash,
        string _reasonNote,
        bytes32 _requesterId,
        bytes32 _respondentId,
        uint256 _amountToStake
    ) external whenNotPaused {
        require(bytes(_reasonNote).length > 0, "reason note must not be empty");
        require(_dealHash != bytes32(0), "deal hash must be non-zero");
        require(_requesterId != bytes32(0), "requester ID must be non-zero");
        require(_respondentId != bytes32(0), "respondent ID must be non-zero");
        require(keccak256(abi.encodePacked(_requesterId)) != keccak256(abi.encodePacked(_respondentId)),
            "requester and respondent must be different");
        require(_amountToStake >= minStake, "amount to stake must be greater or equal to min.stake");

        uint256 requesterAllowance = token.allowance(msg.sender, address(this));
        require(requesterAllowance >= _amountToStake, "allowance too small");
        token.safeTransferFrom(msg.sender, address(this), _amountToStake);

        Claim memory claim = Claim({
            state : State.AwaitingAcceptance,
            modified : now,
            dealId : _dealId,
            dealHash : _dealHash,
            reasonNote : _reasonNote,
            requesterId : _requesterId,
            requesterAddress : msg.sender,
            requesterStaked : _amountToStake,
            respondentId : _respondentId,
            respondentAddress : address(0),
            respondentStaked : 0,
            resolutionNote : ""
            });
        claims.push(claim);

        emit ClaimCreated(_dealId, claims.length - 1);
    }

    /**
     * @dev accepts the claim by respondent. Before calling this method, respondent should approve
     * this contract to transfer min. amount of token units in their behalf, by calling
     * `approve(address _spender, uint _value)` method of token contract. Respondent must stake the same amount
     * of tokens as requester.
     *
     * Claim state after call 🡒 AwaitingResolution (if was AwaitingAcceptance)
     */
    function accept(uint256 _claimIdx) external whenNotPaused {
        require(_claimIdx < claims.length, "invalid claim index");
        Claim storage claim = claims[_claimIdx];
        require(State.AwaitingAcceptance == claim.state, "State.AwaitingAcceptance required");
        require(msg.sender != claim.requesterAddress, "requester and respondent addresses must be different");

        uint256 requesterStaked = claim.requesterStaked;
        token.safeTransferFrom(msg.sender, address(this), requesterStaked);

        claim.state = State.AwaitingResolution;
        claim.modified = now;
        claim.respondentAddress = msg.sender;
        claim.respondentStaked = requesterStaked;

        emit ClaimAccepted(claim.dealId, _claimIdx);
    }

    /**
     * @dev resolves the claim by respondent. Respondent will get staked amount of tokens back.
     *
     * Claim state after call 🡒 AwaitingConfirmation (if was AwaitingResolution)
     */
    function resolve(uint256 _claimIdx, string _resolutionNote) external whenNotPaused {
        require(_claimIdx < claims.length, "invalid claim index");
        require(bytes(_resolutionNote).length > 0, "resolution note must not be empty");
        Claim storage claim = claims[_claimIdx];
        require(State.AwaitingResolution == claim.state, "State.AwaitingResolution required");
        require(msg.sender == claim.respondentAddress, "awaiting respondent");

        uint256 respStakedBefore = claim.respondentStaked;

        claim.state = State.AwaitingConfirmation;
        claim.modified = now;
        claim.respondentStaked = 0;
        claim.resolutionNote = _resolutionNote;

        token.safeTransfer(msg.sender, respStakedBefore);

        emit ClaimResolved(claim.dealId, _claimIdx);
    }

    /**
     * @dev closes the claim by requester.
     * Requester allowed to call this method 72 hours after call to create() or accept(), and immediately after resolve().
     * Requester will get staked amount of tokens back. Requester will also get the respondent’s tokens if
     * the respondent did not call the resolve() method within 72 hours.
     *
     * Claim state after call 🡒 Closed                         (if was AwaitingConfirmation, and less than 24 hours passed)
     *                        🡒 ClosedAfterConfirmationExpired (if was AwaitingConfirmation, after 24 hours)
     *                        🡒 ClosedAfterAcceptanceExpired   (if was AwaitingAcceptance, after 72 hours)
     *                        🡒 ClosedAfterResolutionExpired   (if was AwaitingResolution, after 72 hours)
     */
    function close(uint256 _claimIdx) external whenNotPaused {
        require(_claimIdx < claims.length, "invalid claim index");
        State state = claims[_claimIdx].state;

        if (State.AwaitingAcceptance == state) {
            return _closeAfterAwaitingAcceptance(_claimIdx);
        } else if (State.AwaitingResolution == state) {
            return _closeAfterAwaitingResolution(_claimIdx);
        } else if (State.AwaitingConfirmation == state) {
            return _closeAfterAwaitingConfirmation(_claimIdx);
        }

        revert("claim.State");
    }

    function _closeAfterAwaitingAcceptance(uint256 _claimIdx) internal {
        Claim storage claim = claims[_claimIdx];
        require(msg.sender == claim.requesterAddress, "awaiting requester");
        require(State.AwaitingAcceptance == claim.state, "State.AwaitingAcceptance required");
        require(_hoursPassed(claim.modified, 72), "expiration required");

        uint256 stakedBefore = claim.requesterStaked;

        claim.state = State.ClosedAfterAcceptanceExpired;
        claim.modified = now;
        claim.requesterStaked = 0;

        token.safeTransfer(msg.sender, stakedBefore);

        emit ClaimClosedAfterAcceptanceExpired(claim.dealId, _claimIdx);
    }

    function _closeAfterAwaitingResolution(uint256 _claimIdx) internal {
        Claim storage claim = claims[_claimIdx];
        require(State.AwaitingResolution == claim.state, "State.AwaitingResolution required");
        require(_hoursPassed(claim.modified, 72), "expiration required");
        require(msg.sender == claim.requesterAddress, "awaiting requester");

        uint256 totalStaked = claim.requesterStaked.add(claim.respondentStaked);

        claim.state = State.ClosedAfterResolutionExpired;
        claim.modified = now;
        claim.requesterStaked = 0;
        claim.respondentStaked = 0;

        token.safeTransfer(msg.sender, totalStaked);

        emit ClaimClosedAfterResolutionExpired(claim.dealId, _claimIdx);
    }

    function _closeAfterAwaitingConfirmation(uint256 _claimIdx) internal {
        Claim storage claim = claims[_claimIdx];
        require(msg.sender == claim.requesterAddress, "awaiting requester");
        require(State.AwaitingConfirmation == claim.state, "State.AwaitingConfirmation required");

        bool expired = _hoursPassed(claim.modified, 24);
        if (expired) {
            claim.state = State.ClosedAfterConfirmationExpired;
        } else {
            claim.state = State.Closed;
        }
        claim.modified = now;

        uint256 stakedBefore = claim.requesterStaked;
        claim.requesterStaked = 0;

        token.safeTransfer(msg.sender, stakedBefore);

        if (expired) {
            emit ClaimClosedAfterConfirmationExpired(claim.dealId, _claimIdx);
        } else {
            emit ClaimClosed(claim.dealId, _claimIdx);
        }
    }

    function _hoursPassed(uint256 start, uint256 hoursAfter) internal view returns (bool) {
        return now >= start + hoursAfter * 1 hours;
    }

    function _setMinStake(uint256 _newMinStake) internal {
        uint256 previousMinStake = minStake;
        if (previousMinStake != _newMinStake) {
            emit MinStakeUpdated(previousMinStake, _newMinStake);
            minStake = _newMinStake;
        }
    }
}