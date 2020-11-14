/**
 * Source Code first verified at https://etherscan.io on Wednesday, March 20, 2019
 (UTC) */

// File: contracts/core/platform/ChronoBankAssetInterface.sol

/**
 * Copyright 2017–2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.21;


contract ChronoBankAssetInterface {
    function __transferWithReference(address _to, uint _value, string _reference, address _sender) public returns (bool);
    function __transferFromWithReference(address _from, address _to, uint _value, string _reference, address _sender) public returns (bool);
    function __approve(address _spender, uint _value, address _sender) public returns(bool);
    function __process(bytes /*_data*/, address /*_sender*/) public payable {
        revert();
    }
}

// File: contracts/core/platform/ChronoBankAssetProxyInterface.sol

/**
 * Copyright 2017–2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.11;

contract ChronoBankAssetProxyInterface {
    address public chronoBankPlatform;
    bytes32 public smbl;
    function __transferWithReference(address _to, uint _value, string _reference, address _sender) public returns (bool);
    function __transferFromWithReference(address _from, address _to, uint _value, string _reference, address _sender) public returns (bool);
    function __approve(address _spender, uint _value, address _sender) public returns (bool);
    function getLatestVersion() public view returns (address);
    function init(address _chronoBankPlatform, string _symbol, string _name) public;
    function proposeUpgrade(address _newVersion) external returns (bool);
}

// File: contracts/core/platform/ChronoBankPlatformInterface.sol

/**
 * Copyright 2017–2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.11;


contract ChronoBankPlatformInterface {
    mapping(bytes32 => address) public proxies;

    function symbols(uint _idx) public view returns (bytes32);
    function symbolsCount() public view returns (uint);
    function isCreated(bytes32 _symbol) public view returns(bool);
    function isOwner(address _owner, bytes32 _symbol) public view returns(bool);
    function owner(bytes32 _symbol) public view returns(address);

    function setProxy(address _address, bytes32 _symbol) public returns(uint errorCode);

    function name(bytes32 _symbol) public view returns(string);

    function totalSupply(bytes32 _symbol) public view returns(uint);
    function balanceOf(address _holder, bytes32 _symbol) public view returns(uint);
    function allowance(address _from, address _spender, bytes32 _symbol) public view returns(uint);
    function baseUnit(bytes32 _symbol) public view returns(uint8);
    function description(bytes32 _symbol) public view returns(string);
    function isReissuable(bytes32 _symbol) public view returns(bool);

    function proxyTransferWithReference(address _to, uint _value, bytes32 _symbol, string _reference, address _sender) public returns(uint errorCode);
    function proxyTransferFromWithReference(address _from, address _to, uint _value, bytes32 _symbol, string _reference, address _sender) public returns(uint errorCode);

    function proxyApprove(address _spender, uint _value, bytes32 _symbol, address _sender) public returns(uint errorCode);

    function issueAsset(bytes32 _symbol, uint _value, string _name, string _description, uint8 _baseUnit, bool _isReissuable) public returns(uint errorCode);
    function issueAsset(bytes32 _symbol, uint _value, string _name, string _description, uint8 _baseUnit, bool _isReissuable, address _account) public returns(uint errorCode);
    function reissueAsset(bytes32 _symbol, uint _value) public returns(uint errorCode);
    function revokeAsset(bytes32 _symbol, uint _value) public returns(uint errorCode);

    function hasAssetRights(address _owner, bytes32 _symbol) public view returns (bool);
    function changeOwnership(bytes32 _symbol, address _newOwner) public returns(uint errorCode);
    
    function eventsHistory() public view returns (address);
}

// File: contracts/core/platform/ChronoBankAsset.sol

/**
 * Copyright 2017–2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.21;


contract ChronoBankAssetProxy is ChronoBankAssetProxyInterface {}

contract ChronoBankPlatform is ChronoBankPlatformInterface {}


/// @title ChronoBank Asset implementation contract.
///
/// Basic asset implementation contract, without any additional logic.
/// Every other asset implementation contracts should derive from this one.
/// Receives calls from the proxy, and calls back immediatly without arguments modification.
///
/// Note: all the non constant functions return false instead of throwing in case if state change
/// didn't happen yet.
contract ChronoBankAsset is ChronoBankAssetInterface {

    // @dev Assigned asset proxy contract, immutable.
    ChronoBankAssetProxy public proxy;

    // @dev banned addresses
    mapping (address => bool) public blacklist;

    // @dev stops asset transfers
    bool public paused = false;

    // @dev restriction/Unrestriction events
    event Restricted(bytes32 indexed symbol, address restricted);
    event Unrestricted(bytes32 indexed symbol, address unrestricted);

    // @dev Paused/Unpaused events
    event Paused(bytes32 indexed symbol);
    event Unpaused(bytes32 indexed symbol);

    /// @dev Only assigned proxy is allowed to call.
    modifier onlyProxy {
        if (proxy == msg.sender) {
            _;
        }
    }

    /// @dev Only not paused tokens could go further.
    modifier onlyNotPaused(address _sender) {
        if (!paused || isAuthorized(_sender)) {
            _;
        }
    }

    /// @dev Only acceptable (not in blacklist) addresses are allowed to call.
    modifier onlyAcceptable(address _address) {
        if (!blacklist[_address]) {
            _;
        }
    }

    /// @dev Only assets's admins are allowed to execute
    modifier onlyAuthorized {
        if (isAuthorized(msg.sender)) {
            _;
        }
    }

    /// @notice Sets asset proxy address.
    /// Can be set only once.
    /// @dev function is final, and must not be overridden.
    /// @param _proxy asset proxy contract address.
    /// @return success.
    function init(ChronoBankAssetProxy _proxy) public returns(bool) {
        if (address(proxy) != 0x0) {
            return false;
        }
        proxy = _proxy;
        return true;
    }

    /// @notice Gets eventsHistory contract used for events' triggering
    function eventsHistory() public view returns (address) {
        ChronoBankPlatform platform = ChronoBankPlatform(proxy.chronoBankPlatform());
        return platform.eventsHistory() != address(platform) ? platform.eventsHistory() : this;
    }

    /// @notice Lifts the ban on transfers for given addresses
    function restrict(address [] _restricted) onlyAuthorized external returns (bool) {
        for (uint i = 0; i < _restricted.length; i++) {
            address restricted = _restricted[i];
            blacklist[restricted] = true;
            _emitRestricted(restricted);
        }
        return true;
    }

    /// @notice Revokes the ban on transfers for given addresses
    function unrestrict(address [] _unrestricted) onlyAuthorized external returns (bool) {
        for (uint i = 0; i < _unrestricted.length; i++) {
            address unrestricted = _unrestricted[i];
            delete blacklist[unrestricted];
            _emitUnrestricted(unrestricted);
        }
        return true;
    }

    /// @notice called by the owner to pause, triggers stopped state
    /// Only admin is allowed to execute this method.
    function pause() onlyAuthorized external returns (bool) {
        paused = true;
        _emitPaused();
        return true;
    }

    /// @notice called by the owner to unpause, returns to normal state
    /// Only admin is allowed to execute this method.
    function unpause() onlyAuthorized external returns (bool) {
        paused = false;
        _emitUnpaused();
        return true;
    }

    /// @notice Passes execution into virtual function.
    /// Can only be called by assigned asset proxy.
    /// @dev function is final, and must not be overridden.
    /// @return success.
    function __transferWithReference(
        address _to, 
        uint _value, 
        string _reference, 
        address _sender
    ) 
    onlyProxy 
    public 
    returns (bool) 
    {
        return _transferWithReference(_to, _value, _reference, _sender);
    }

    /// @notice Calls back without modifications if an asset is not stopped.
    /// Checks whether _from/_sender are not in blacklist.
    /// @dev function is virtual, and meant to be overridden.
    /// @return success.
    function _transferWithReference(
        address _to, 
        uint _value, 
        string _reference, 
        address _sender
    )
    onlyNotPaused(_sender)
    onlyAcceptable(_to)
    onlyAcceptable(_sender)
    internal
    returns (bool)
    {
        return proxy.__transferWithReference(_to, _value, _reference, _sender);
    }

    /// @notice Passes execution into virtual function.
    /// Can only be called by assigned asset proxy.
    /// @dev function is final, and must not be overridden.
    /// @return success.
    function __transferFromWithReference(
        address _from, 
        address _to, 
        uint _value, 
        string _reference, 
        address _sender
    ) 
    onlyProxy 
    public 
    returns (bool) 
    {
        return _transferFromWithReference(_from, _to, _value, _reference, _sender);
    }

    /// @notice Calls back without modifications if an asset is not stopped.
    /// Checks whether _from/_sender are not in blacklist.
    /// @dev function is virtual, and meant to be overridden.
    /// @return success.
    function _transferFromWithReference(
        address _from, 
        address _to, 
        uint _value, 
        string _reference, 
        address _sender
    )
    onlyNotPaused(_sender)
    onlyAcceptable(_from)
    onlyAcceptable(_to)
    onlyAcceptable(_sender)
    internal
    returns (bool)
    {
        return proxy.__transferFromWithReference(_from, _to, _value, _reference, _sender);
    }

    /// @notice Passes execution into virtual function.
    /// Can only be called by assigned asset proxy.
    /// @dev function is final, and must not be overridden.
    /// @return success.
    function __approve(address _spender, uint _value, address _sender) onlyProxy public returns (bool) {
        return _approve(_spender, _value, _sender);
    }

    /// @notice Calls back without modifications.
    /// @dev function is virtual, and meant to be overridden.
    /// @return success.
    function _approve(address _spender, uint _value, address _sender)
    onlyAcceptable(_spender)
    onlyAcceptable(_sender)
    internal
    returns (bool)
    {
        return proxy.__approve(_spender, _value, _sender);
    }

    function isAuthorized(address _owner)
    public
    view
    returns (bool) {
        ChronoBankPlatform platform = ChronoBankPlatform(proxy.chronoBankPlatform());
        return platform.hasAssetRights(_owner, proxy.smbl());
    }

    function _emitRestricted(address _restricted) private {
        ChronoBankAsset(eventsHistory()).emitRestricted(proxy.smbl(), _restricted);
    }

    function _emitUnrestricted(address _unrestricted) private {
        ChronoBankAsset(eventsHistory()).emitUnrestricted(proxy.smbl(), _unrestricted);
    }

    function _emitPaused() private {
        ChronoBankAsset(eventsHistory()).emitPaused(proxy.smbl());
    }

    function _emitUnpaused() private {
        ChronoBankAsset(eventsHistory()).emitUnpaused(proxy.smbl());
    }

    function emitRestricted(bytes32 _symbol, address _restricted) public {
        emit Restricted(_symbol, _restricted);
    }

    function emitUnrestricted(bytes32 _symbol, address _unrestricted) public {
        emit Unrestricted(_symbol, _unrestricted);
    }

    function emitPaused(bytes32 _symbol) public {
        emit Paused(_symbol);
    }

    function emitUnpaused(bytes32 _symbol) public {
        emit Unpaused(_symbol);
    }
}