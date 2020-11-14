/**
 * Source Code first verified at https://etherscan.io on Wednesday, March 20, 2019
 (UTC) */

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

// File: contracts/core/erc20/ERC20Interface.sol

/**
 * Copyright 2017–2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.11;

contract ERC20Interface {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed from, address indexed spender, uint256 value);
    string public symbol;

    function decimals() constant returns (uint8);
    function totalSupply() constant returns (uint256 supply);
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
}

// File: contracts/core/platform/ChronoBankAssetProxy.sol

/**
 * Copyright 2017–2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.21;

contract ERC20 is ERC20Interface {}

contract ChronoBankPlatform is ChronoBankPlatformInterface {}

contract ChronoBankAsset is ChronoBankAssetInterface {}

/// @title ChronoBank Asset Proxy.
///
/// Proxy implements ERC20 interface and acts as a gateway to a single platform asset.
/// Proxy adds symbol and caller(sender) when forwarding requests to platform.
/// Every request that is made by caller first sent to the specific asset implementation
/// contract, which then calls back to be forwarded onto platform.
///
/// Calls flow: Caller ->
///             Proxy.func(...) ->
///             Asset.__func(..., Caller.address) ->
///             Proxy.__func(..., Caller.address) ->
///             Platform.proxyFunc(..., symbol, Caller.address)
///
/// Asset implementation contract is mutable, but each user have an option to stick with
/// old implementation, through explicit decision made in timely manner, if he doesn't agree
/// with new rules.
/// Each user have a possibility to upgrade to latest asset contract implementation, without the
/// possibility to rollback.
///
/// Note: all the non constant functions return false instead of throwing in case if state change
/// didn't happen yet.
contract ChronoBankAssetProxy is ERC20 {

    /// @dev Supports ChronoBankPlatform ability to return error codes from methods
    uint constant OK = 1;

    /// @dev Assigned platform, immutable.
    ChronoBankPlatform public chronoBankPlatform;

    /// @dev Assigned symbol, immutable.
    bytes32 public smbl;

    /// @dev Assigned name, immutable.
    string public name;

    /// @dev Assigned symbol (from ERC20 standard), immutable
    string public symbol;

    /// @notice Sets platform address, assigns symbol and name.
    /// Can be set only once.
    /// @param _chronoBankPlatform platform contract address.
    /// @param _symbol assigned symbol.
    /// @param _name assigned name.
    /// @return success.
    function init(ChronoBankPlatform _chronoBankPlatform, string _symbol, string _name) public returns (bool) {
        if (address(chronoBankPlatform) != 0x0) {
            return false;
        }

        chronoBankPlatform = _chronoBankPlatform;
        symbol = _symbol;
        smbl = stringToBytes32(_symbol);
        name = _name;
        return true;
    }

    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        assembly {
           result := mload(add(source, 32))
        }
    }

    /// @dev Only platform is allowed to call.
    modifier onlyChronoBankPlatform {
        if (msg.sender == address(chronoBankPlatform)) {
            _;
        }
    }

    /// @dev Only current asset owner is allowed to call.
    modifier onlyAssetOwner {
        if (chronoBankPlatform.isOwner(msg.sender, smbl)) {
            _;
        }
    }

    /// @dev Returns asset implementation contract for current caller.
    /// @return asset implementation contract.
    function _getAsset() internal view returns (ChronoBankAsset) {
        return ChronoBankAsset(getVersionFor(msg.sender));
    }

    /// @notice Returns asset total supply.
    /// @return asset total supply.
    function totalSupply() public view returns (uint) {
        return chronoBankPlatform.totalSupply(smbl);
    }

    /// @notice Returns asset balance for a particular holder.
    /// @param _owner holder address.
    /// @return holder balance.
    function balanceOf(address _owner) public view returns (uint) {
        return chronoBankPlatform.balanceOf(_owner, smbl);
    }

    /// @notice Returns asset allowance from one holder to another.
    /// @param _from holder that allowed spending.
    /// @param _spender holder that is allowed to spend.
    /// @return holder to spender allowance.
    function allowance(address _from, address _spender) public view returns (uint) {
        return chronoBankPlatform.allowance(_from, _spender, smbl);
    }

    /// @notice Returns asset decimals.
    /// @return asset decimals.
    function decimals() public view returns (uint8) {
        return chronoBankPlatform.baseUnit(smbl);
    }

    /// @notice Transfers asset balance from the caller to specified receiver.
    /// @param _to holder address to give to.
    /// @param _value amount to transfer.
    /// @return success.
    function transfer(address _to, uint _value) public returns (bool) {
        if (_to != 0x0) {
            return _transferWithReference(_to, _value, "");
        }
    }

    /// @notice Transfers asset balance from the caller to specified receiver adding specified comment.
    /// @param _to holder address to give to.
    /// @param _value amount to transfer.
    /// @param _reference transfer comment to be included in a platform's Transfer event.
    /// @return success.
    function transferWithReference(address _to, uint _value, string _reference) public returns (bool) {
        if (_to != 0x0) {
            return _transferWithReference(_to, _value, _reference);
        }
    }

    /// @notice Resolves asset implementation contract for the caller and forwards there arguments along with
    /// the caller address.
    /// @return success.
    function _transferWithReference(address _to, uint _value, string _reference) internal returns (bool) {
        return _getAsset().__transferWithReference(_to, _value, _reference, msg.sender);
    }

    /// @notice Performs transfer call on the platform by the name of specified sender.
    ///
    /// Can only be called by asset implementation contract assigned to sender.
    ///
    /// @param _to holder address to give to.
    /// @param _value amount to transfer.
    /// @param _reference transfer comment to be included in a platform's Transfer event.
    /// @param _sender initial caller.
    ///
    /// @return success.
    function __transferWithReference(
        address _to, 
        uint _value, 
        string _reference, 
        address _sender
    ) 
    onlyAccess(_sender) 
    public 
    returns (bool) 
    {
        return chronoBankPlatform.proxyTransferWithReference(_to, _value, smbl, _reference, _sender) == OK;
    }

    /// @notice Performs allowance transfer of asset balance between holders.
    /// @param _from holder address to take from.
    /// @param _to holder address to give to.
    /// @param _value amount to transfer.
    /// @return success.
    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        if (_to != 0x0) {
            return _getAsset().__transferFromWithReference(_from, _to, _value, "", msg.sender);
        }
    }

    /// @notice Performs allowance transfer call on the platform by the name of specified sender.
    ///
    /// Can only be called by asset implementation contract assigned to sender.
    ///
    /// @param _from holder address to take from.
    /// @param _to holder address to give to.
    /// @param _value amount to transfer.
    /// @param _reference transfer comment to be included in a platform's Transfer event.
    /// @param _sender initial caller.
    ///
    /// @return success.
    function __transferFromWithReference(
        address _from, 
        address _to, 
        uint _value, 
        string _reference, 
        address _sender
    ) 
    onlyAccess(_sender) 
    public 
    returns (bool) 
    {
        return chronoBankPlatform.proxyTransferFromWithReference(_from, _to, _value, smbl, _reference, _sender) == OK;
    }

    /// @notice Sets asset spending allowance for a specified spender.
    /// @param _spender holder address to set allowance to.
    /// @param _value amount to allow.
    /// @return success.
    function approve(address _spender, uint _value) public returns (bool) {
        if (_spender != 0x0) {
            return _getAsset().__approve(_spender, _value, msg.sender);
        }
    }

    /// @notice Performs allowance setting call on the platform by the name of specified sender.
    /// Can only be called by asset implementation contract assigned to sender.
    /// @param _spender holder address to set allowance to.
    /// @param _value amount to allow.
    /// @param _sender initial caller.
    /// @return success.
    function __approve(address _spender, uint _value, address _sender) onlyAccess(_sender) public returns (bool) {
        return chronoBankPlatform.proxyApprove(_spender, _value, smbl, _sender) == OK;
    }

    /// @notice Emits ERC20 Transfer event on this contract.
    /// Can only be, and, called by assigned platform when asset transfer happens.
    function emitTransfer(address _from, address _to, uint _value) onlyChronoBankPlatform public {
        emit Transfer(_from, _to, _value);
    }

    /// @notice Emits ERC20 Approval event on this contract.
    /// Can only be, and, called by assigned platform when asset allowance set happens.
    function emitApprove(address _from, address _spender, uint _value) onlyChronoBankPlatform public {
        emit Approval(_from, _spender, _value);
    }

    /// @notice Resolves asset implementation contract for the caller and forwards there transaction data,
    /// along with the value. This allows for proxy interface growth.
    function () public payable {
        _getAsset().__process.value(msg.value)(msg.data, msg.sender);
    }

    /// @dev Indicates an upgrade freeze-time start, and the next asset implementation contract.
    event UpgradeProposal(address newVersion);

    /// @dev Current asset implementation contract address.
    address latestVersion;

    /// @dev Proposed next asset implementation contract address.
    address pendingVersion;

    /// @dev Upgrade freeze-time start.
    uint pendingVersionTimestamp;

    /// @dev Timespan for users to review the new implementation and make decision.
    uint constant UPGRADE_FREEZE_TIME = 3 days;

    /// @dev Asset implementation contract address that user decided to stick with.
    /// 0x0 means that user uses latest version.
    mapping(address => address) userOptOutVersion;

    /// @dev Only asset implementation contract assigned to sender is allowed to call.
    modifier onlyAccess(address _sender) {
        if (getVersionFor(_sender) == msg.sender) {
            _;
        }
    }

    /// @notice Returns asset implementation contract address assigned to sender.
    /// @param _sender sender address.
    /// @return asset implementation contract address.
    function getVersionFor(address _sender) public view returns (address) {
        return userOptOutVersion[_sender] == 0 ? latestVersion : userOptOutVersion[_sender];
    }

    /// @notice Returns current asset implementation contract address.
    /// @return asset implementation contract address.
    function getLatestVersion() public view returns (address) {
        return latestVersion;
    }

    /// @notice Returns proposed next asset implementation contract address.
    /// @return asset implementation contract address.
    function getPendingVersion() public view returns (address) {
        return pendingVersion;
    }

    /// @notice Returns upgrade freeze-time start.
    /// @return freeze-time start.
    function getPendingVersionTimestamp() public view returns (uint) {
        return pendingVersionTimestamp;
    }

    /// @notice Propose next asset implementation contract address.
    /// Can only be called by current asset owner.
    /// Note: freeze-time should not be applied for the initial setup.
    /// @param _newVersion asset implementation contract address.
    /// @return success.
    function proposeUpgrade(address _newVersion) onlyAssetOwner public returns (bool) {
        // Should not already be in the upgrading process.
        if (pendingVersion != 0x0) {
            return false;
        }

        // New version address should be other than 0x0.
        if (_newVersion == 0x0) {
            return false;
        }

        // Don't apply freeze-time for the initial setup.
        if (latestVersion == 0x0) {
            latestVersion = _newVersion;
            return true;
        }

        pendingVersion = _newVersion;
        pendingVersionTimestamp = now;

        emit UpgradeProposal(_newVersion);
        return true;
    }

    /// @notice Cancel the pending upgrade process.
    /// Can only be called by current asset owner.
    /// @return success.
    function purgeUpgrade() public onlyAssetOwner returns (bool) {
        if (pendingVersion == 0x0) {
            return false;
        }

        delete pendingVersion;
        delete pendingVersionTimestamp;
        return true;
    }

    /// @notice Finalize an upgrade process setting new asset implementation contract address.
    /// Can only be called after an upgrade freeze-time.
    /// @return success.
    function commitUpgrade() public returns (bool) {
        if (pendingVersion == 0x0) {
            return false;
        }

        if (pendingVersionTimestamp + UPGRADE_FREEZE_TIME > now) {
            return false;
        }

        latestVersion = pendingVersion;
        delete pendingVersion;
        delete pendingVersionTimestamp;
        return true;
    }

    /// @notice Disagree with proposed upgrade, and stick with current asset implementation
    /// until further explicit agreement to upgrade.
    /// @return success.
    function optOut() public returns (bool) {
        if (userOptOutVersion[msg.sender] != 0x0) {
            return false;
        }
        userOptOutVersion[msg.sender] = latestVersion;
        return true;
    }

    /// @notice Implicitly agree to upgrade to current and future asset implementation upgrades,
    /// until further explicit disagreement.
    /// @return success.
    function optIn() public returns (bool) {
        delete userOptOutVersion[msg.sender];
        return true;
    }
}