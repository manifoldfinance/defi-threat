/**
 * Source Code first verified at https://etherscan.io on Monday, March 25, 2019
 (UTC) */

pragma solidity 0.4.25;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}


/**
 * Utility library of inline functions on addresses
 */
library Address {

  /**
   * Returns whether the target address is a contract
   * @dev This function will return false if invoked during the constructor of a contract,
   * as the code is not actually created until after the constructor finishes.
   * @param account address of the account to check
   * @return whether the target address is a contract
   */
  function isContract(address account) internal view returns (bool) {
    uint256 size;
    // XXX Currently there is no better way to check if there is a contract in an address
    // than to check the size of the code at that address.
    // See https://ethereum.stackexchange.com/a/14016/36603
    // for more details about how this works.
    // TODO Check this again before the Serenity release, because all addresses will be
    // contracts then.
    // solium-disable-next-line security/no-inline-assembly
    assembly { size := extcodesize(account) }
    return size > 0;
  }

}


interface IOrbsGuardians {

    event GuardianRegistered(address indexed guardian);
    event GuardianLeft(address indexed guardian);
    event GuardianUpdated(address indexed guardian);

    /// @dev register a new guardian. You will need to transfer registrationDepositWei amount of ether.
    /// @param name string The name of the guardian
    /// @param website string The website of the guardian
    function register(string name, string website) external payable;

    /// @dev update guardian details. only msg.sender can update it's own guardian details.
    /// @param name string The name of the guardian
    /// @param website string The website of the guardianfunction update(string name, string website) external;
    function update(string name, string website) external;

    /// @dev Delete the guardian and take back the locked ether. only msg.sender can leave.
    function leave() external;

    /// @dev Returns if the address belongs to a guardian
    /// @param guardian address the guardian address
    function isGuardian(address guardian) external view returns (bool);

    /// @dev Returns name and website for  a specific guardian.
    /// @param guardian address the guardian address
    function getGuardianData(address guardian)
        external
        view
        returns (string name, string website);

    /// @dev Returns in which block the guardian registered, and in which block it was last updated.
    /// @param guardian address the guardian address
    function getRegistrationBlockNumber(address guardian)
        external
        view
        returns (uint registeredOn, uint lastUpdatedOn);

    /// @dev Returns an array of guardians.
    /// @param offset uint offset from which to start getting guardians from the array
    /// @param limit uint limit of guardians to be returned.
    function getGuardians(uint offset, uint limit)
        external
        view
        returns (address[]);

    /// @dev Similar to getGuardians, but returns addresses represented as byte20.
    /// @param offset uint offset from which to start getting guardians from the array
    /// @param limit uint limit of guardians to be returned.
    function getGuardiansBytes20(uint offset, uint limit)
        external
        view
        returns (bytes20[]);
}


contract OrbsGuardians is IOrbsGuardians {
    using SafeMath for uint256;

    struct GuardianData {
        string name;
        string website;
        uint index;
        uint registeredOnBlock;
        uint lastUpdatedOnBlock;
        uint registeredOn;
    }

    // The version of the current Guardian smart contract.
    uint public constant VERSION = 1;

    // Amount of Ether in Wei need to be locked when registering - this will be set to 1.
    uint public registrationDepositWei;
    // The amount of time needed to wait until a guardian can leave and get registrationDepositWei_
    uint public registrationMinTime;

    // Iterable array to get a list of all guardians
    address[] internal guardians;

    // Mapping between address and the guardian data.
    mapping(address => GuardianData) internal guardiansData;

    /// @dev Check that the caller is a guardian.
    modifier onlyGuardian() {
        require(isGuardian(msg.sender), "You must be a registered guardian");
        _;
    }

    /// @dev Check that the caller is not a contract.
    modifier onlyEOA() {
        require(!Address.isContract(msg.sender),"Only EOA may register as Guardian");
        _;
    }

    /// @dev Constructor that initializes the amount of ether needed to lock when registering. This will be set to 1.
    /// @param registrationDepositWei_ uint the amount of ether needed to lock when registering.
    /// @param registrationMinTime_ uint the amount of time needed to wait until a guardian can leave and get registrationDepositWei_
    constructor(uint registrationDepositWei_, uint registrationMinTime_) public {
        require(registrationDepositWei_ > 0, "registrationDepositWei_ must be positive");

        registrationMinTime = registrationMinTime_;
        registrationDepositWei = registrationDepositWei_;
    }

    /// @dev register a new guardian. You will need to transfer registrationDepositWei amount of ether.
    /// @param name string The name of the guardian
    /// @param website string The website of the guardian
    function register(string name, string website)
        external
        payable
        onlyEOA
    {
        address sender = msg.sender;
        require(bytes(name).length > 0, "Please provide a valid name");
        require(bytes(website).length > 0, "Please provide a valid website");
        require(!isGuardian(sender), "Cannot be a guardian");
        require(msg.value == registrationDepositWei, "Please provide the exact registration deposit");

        uint index = guardians.length;
        guardians.push(sender);
        guardiansData[sender] = GuardianData({
            name: name,
            website: website,
            index: index ,
            registeredOnBlock: block.number,
            lastUpdatedOnBlock: block.number,
            registeredOn: now
        });

        emit GuardianRegistered(sender);
    }

    /// @dev update guardian details. only msg.sender can update it's own guardian details.
    /// @param name string The name of the guardian
    /// @param website string The website of the guardian
    function update(string name, string website)
        external
        onlyGuardian
        onlyEOA
    {
        address sender = msg.sender;
        require(bytes(name).length > 0, "Please provide a valid name");
        require(bytes(website).length > 0, "Please provide a valid website");


        guardiansData[sender].name = name;
        guardiansData[sender].website = website;
        guardiansData[sender].lastUpdatedOnBlock = block.number;

        emit GuardianUpdated(sender);
    }

    /// @dev Delete the guardian and take back the locked ether. only msg.sender can leave.
    function leave() external onlyGuardian onlyEOA {
        address sender = msg.sender;
        require(now >= guardiansData[sender].registeredOn.add(registrationMinTime), "Minimal guardian time didnt pass");

        uint i = guardiansData[sender].index;

        assert(guardians[i] == sender); // Will consume all available gas.

        // Replace with last element and remove from end
        guardians[i] = guardians[guardians.length - 1]; // Switch with last
        guardiansData[guardians[i]].index = i; // Update it's lookup index
        guardians.length--; // Remove the last one

        // Clear data
        delete guardiansData[sender];

        // Refund deposit
        sender.transfer(registrationDepositWei);

        emit GuardianLeft(sender);
    }

    /// @dev Similar to getGuardians, but returns addresses represented as byte20.
    /// @param offset uint offset from which to start getting guardians from the array
    /// @param limit uint limit of guardians to be returned.
    function getGuardiansBytes20(uint offset, uint limit)
        external
        view
        returns (bytes20[])
    {
        address[] memory guardianAddresses = getGuardians(offset, limit);
        uint guardianAddressesLength = guardianAddresses.length;

        bytes20[] memory result = new bytes20[](guardianAddressesLength);

        for (uint i = 0; i < guardianAddressesLength; i++) {
            result[i] = bytes20(guardianAddresses[i]);
        }

        return result;
    }

    /// @dev Returns in which block the guardian registered, and in which block it was last updated.
    /// @param guardian address the guardian address
    function getRegistrationBlockNumber(address guardian)
        external
        view
        returns (uint registeredOn, uint lastUpdatedOn)
    {
        require(isGuardian(guardian), "Please provide a listed Guardian");

        GuardianData storage entry = guardiansData[guardian];
        registeredOn = entry.registeredOnBlock;
        lastUpdatedOn = entry.lastUpdatedOnBlock;
    }

    /// @dev Returns an array of guardians.
    /// @param offset uint offset from which to start getting guardians from the array
    /// @param limit uint limit of guardians to be returned.
    function getGuardians(uint offset, uint limit)
        public
        view
        returns (address[] memory)
    {
        if (offset >= guardians.length) { // offset out of bounds
            return new address[](0);
        }

        if (offset.add(limit) > guardians.length) { // clip limit to array size
            limit = guardians.length.sub(offset);
        }

        address[] memory result = new address[](limit);

        uint resultLength = result.length;
        for (uint i = 0; i < resultLength; i++) {
            result[i] = guardians[offset.add(i)];
        }

        return result;
    }

    /// @dev Returns name and website for  a specific guardian.
    /// @param guardian address the guardian address
    function getGuardianData(address guardian)
        public
        view
        returns (string memory name, string memory website)
    {
        require(isGuardian(guardian), "Please provide a listed Guardian");
        name = guardiansData[guardian].name;
        website = guardiansData[guardian].website;
    }

    /// @dev Returns if the address belongs to a guardian
    /// @param guardian address the guardian address
    function isGuardian(address guardian) public view returns (bool) {
        return guardiansData[guardian].registeredOnBlock > 0;
    }
}