/**
 * Source Code first verified at https://etherscan.io on Friday, April 5, 2019
 (UTC) */

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.2;

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

// File: contracts/DAORegistry.sol

pragma solidity ^0.5.4;


contract DAORegistry is Ownable {

    event Propose(address indexed _avatar);
    event Register(address indexed _avatar, string _name);
    event UnRegister(address indexed _avatar);

    mapping(string=>bool) private registry;

    constructor(address _owner) public {
        transferOwnership(_owner);
    }

    function propose(address _avatar) public {
        emit Propose(_avatar);
    }

    function register(address _avatar, string memory _name) public onlyOwner {
        require(!registry[_name]);
        registry[_name] = true;
        emit Register(_avatar, _name);
    }

    function unRegister(address _avatar) public onlyOwner {
        emit UnRegister(_avatar);
    }

    //This getter is needed because Dynamically-sized keys for public mappings are not supported.
    function isRegister(string memory _name) public view returns(bool) {
        return registry[_name];
    }

}