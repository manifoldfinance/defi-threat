/**
 * Source Code first verified at https://etherscan.io on Monday, March 25, 2019
 (UTC) */

pragma solidity ^0.5.0;

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
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
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

contract AddressWhitelist is Ownable {
    enum Status { None, In, Out }
    mapping(address => Status) private whitelist;

    address[] private whitelistIndices;

    // Adds an address to the whitelist
    function addToWhitelist(address newElement) external onlyOwner {
        // Ignore if address is already included
        if (whitelist[newElement] == Status.In) {
            return;
        }

        // Only append new addresses to the array, never a duplicate
        if (whitelist[newElement] == Status.None) {
            whitelistIndices.push(newElement);
        }

        whitelist[newElement] = Status.In;

        emit AddToWhitelist(newElement);
    }

    // Removes an address from the whitelist.
    function removeFromWhitelist(address elementToRemove) external onlyOwner {
        if (whitelist[elementToRemove] != Status.Out) {
            whitelist[elementToRemove] = Status.Out;
            emit RemoveFromWhitelist(elementToRemove);
        }
    }

    // Checks whether an address is on the whitelist.
    function isOnWhitelist(address elementToCheck) external view returns (bool) {
        return whitelist[elementToCheck] == Status.In;
    }

    // Gets all addresses that are currently included in the whitelist
    // Note: This method skips over, but still iterates through addresses.
    // It is possible for this call to run out of gas if a large number of
    // addresses have been removed. To prevent this unlikely scenario, we can
    // modify the implementation so that when addresses are removed, the last addresses
    // in the array is moved to the empty index.
    function getWhitelist() external view returns (address[] memory activeWhitelist) {
        // Determine size of whitelist first
        uint activeCount = 0;
        for (uint i = 0; i < whitelistIndices.length; i++) {
            if (whitelist[whitelistIndices[i]] == Status.In) {
                activeCount++;
            }
        }

        // Populate whitelist
        activeWhitelist = new address[](activeCount);
        activeCount = 0;
        for (uint i = 0; i < whitelistIndices.length; i++) {
            address addr = whitelistIndices[i];
            if (whitelist[addr] == Status.In) {
                activeWhitelist[activeCount] = addr;
                activeCount++;
            }
        }
    }

    event AddToWhitelist(address indexed addedAddress);
    event RemoveFromWhitelist(address indexed removedAddress);
}