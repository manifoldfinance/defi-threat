/**
 * Source Code first verified at https://etherscan.io on Monday, March 25, 2019
 (UTC) */

pragma solidity 0.4.25;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
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
  function isOwner() public view returns(bool) {
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


interface IOrbsNetworkTopology {

    /// @dev returns an array of pairs with node addresses and ip addresses.
    function getNetworkTopology()
        external
        view
        returns (bytes20[] nodeAddresses, bytes4[] ipAddresses);
}


interface IOrbsValidators {

    event ValidatorApproved(address indexed validator);
    event ValidatorRemoved(address indexed validator);

    /// @dev Adds a validator to participate in network
    /// @param validator address The address of the validators.
    function approve(address validator) external;

    /// @dev Remove a validator from the List based on Guardians votes.
    /// @param validator address The address of the validators.
    function remove(address validator) external;

    /// @dev returns if an address belongs to the approved list & exists in the validators metadata registration database.
    /// @param validator address The address of the validators.
    function isValidator(address validator) external view returns (bool);

    /// @dev returns if an address belongs to the approved list
    /// @param validator address The address of the validators.
    function isApproved(address validator) external view returns (bool);

    /// @dev returns a list of all validators that have been approved and exist in the validator registration database.
    function getValidators() external view returns (address[]);

    /// @dev returns a list of all validators that have been approved and exist in the validator registration
    ///      database. same as getValidators but returns addresses represented as byte20.
    function getValidatorsBytes20() external view returns (bytes20[]);

    /// @dev returns the block number in which the validator was approved.
    /// @param validator address The address of the validators.
    function getApprovalBlockNumber(address validator)
        external
        view
        returns (uint);
}


interface IOrbsValidatorsRegistry {

    event ValidatorLeft(address indexed validator);
    event ValidatorRegistered(address indexed validator);
    event ValidatorUpdated(address indexed validator);

    /// @dev register a validator and provide registration data.
    /// the new validator entry will be owned and identified by msg.sender.
    /// if msg.sender is already registered as a validator in this registry the
    /// transaction will fail.
    /// @param name string The name of the validator
    /// @param ipAddress bytes4 The validator node ip address. If another validator previously registered this ipAddress the transaction will fail
    /// @param website string The website of the validator
    /// @param orbsAddress bytes20 The validator node orbs public address. If another validator previously registered this orbsAddress the transaction will fail
    function register(
        string name,
        bytes4 ipAddress,
        string website,
        bytes20 orbsAddress
    )
        external;

    /// @dev update the validator registration data entry associated with msg.sender.
    /// msg.sender must be registered in this registry contract.
    /// @param name string The name of the validator
    /// @param ipAddress bytes4 The validator node ip address. If another validator previously registered this ipAddress the transaction will fail
    /// @param website string The website of the validator
    /// @param orbsAddress bytes20 The validator node orbs public address. If another validator previously registered this orbsAddress the transaction will fail
    function update(
        string name,
        bytes4 ipAddress,
        string website,
        bytes20 orbsAddress
    )
        external;

    /// @dev deletes a validator registration entry associated with msg.sender.
    function leave() external;

    /// @dev returns validator registration data.
    /// @param validator address address of the validator.
    function getValidatorData(address validator)
        external
        view
        returns (
            string name,
            bytes4 ipAddress,
            string website,
            bytes20 orbsAddress
        );

    /// @dev returns the blocks in which a validator was registered and last updated.
    /// if validator does not designate a registered validator this method returns zero values.
    /// @param validator address of a validator
    function getRegistrationBlockNumber(address validator)
        external
        view
        returns (uint registeredOn, uint lastUpdatedOn);

    /// @dev Checks if validator is currently registered as a validator.
    /// @param validator address address of the validator
    /// @return true iff validator belongs to a registered validator
    function isValidator(address validator) external view returns (bool);

    /// @dev returns the orbs node public address of a specific validator.
    /// @param validator address address of the validator
    /// @return an Orbs node address
    function getOrbsAddress(address validator)
        external
        view
        returns (bytes20 orbsAddress);
}


contract OrbsValidators is Ownable, IOrbsValidators, IOrbsNetworkTopology {

    // The version of the current Validators smart contract.
    uint public constant VERSION = 1;

    // Maximum number of validators.
    uint internal constant MAX_VALIDATOR_LIMIT = 100;
    uint public validatorsLimit;

    // The validators metadata registration database smart contract
    IOrbsValidatorsRegistry public orbsValidatorsRegistry;

    // Array of approved validators addresses
    address[] internal approvedValidators;

    // Mapping of address and in which block it was approved.
    mapping(address => uint) internal approvalBlockNumber;

    /// @dev Constructor that initializes the validators smart contract with the validators metadata registration
    ///     database smart contract.
    /// @param registry_ IOrbsValidatorsRegistry The address of the validators metadata registration database.
    /// @param validatorsLimit_ uint Maximum number of validators list maximum size.
    constructor(IOrbsValidatorsRegistry registry_, uint validatorsLimit_) public {
        require(registry_ != IOrbsValidatorsRegistry(0), "Registry contract address 0");
        require(validatorsLimit_ > 0, "Limit must be positive");
        require(validatorsLimit_ <= MAX_VALIDATOR_LIMIT, "Limit is too high");

        validatorsLimit = validatorsLimit_;
        orbsValidatorsRegistry = registry_;
    }

    /// @dev Adds a validator to participate in network
    /// @param validator address The address of the validators.
    function approve(address validator) external onlyOwner {
        require(validator != address(0), "Address must not be 0!");
        require(approvedValidators.length < validatorsLimit, "Can't add more members!");
        require(!isApproved(validator), "Address must not be already approved");

        approvedValidators.push(validator);
        approvalBlockNumber[validator] = block.number;
        emit ValidatorApproved(validator);
    }

    /// @dev Remove a validator from the List based on Guardians votes.
    /// @param validator address The address of the validators.
    function remove(address validator) external onlyOwner {
        require(isApproved(validator), "Not an approved validator");

        uint approvedLength = approvedValidators.length;
        for (uint i = 0; i < approvedLength; ++i) {
            if (approvedValidators[i] == validator) {

                // Replace with last element and remove from end
                approvedValidators[i] = approvedValidators[approvedLength - 1];
                approvedValidators.length--;

                // Clear approval block height
                delete approvalBlockNumber[validator];

                emit ValidatorRemoved(validator);
                return;
            }
        }
    }

    /// @dev returns if an address belongs to the approved list & exists in the validators metadata registration database.
    /// @param validator address The address of the validators.
    function isValidator(address validator) public view returns (bool) {
        return isApproved(validator) && orbsValidatorsRegistry.isValidator(validator);
    }

    /// @dev returns if an address belongs to the approved list
    /// @param validator address The address of the validators.
    function isApproved(address validator) public view returns (bool) {
        return approvalBlockNumber[validator] > 0;
    }

    /// @dev returns a list of all validators that have been approved and exist in the validator registration database.
    function getValidators() public view returns (address[] memory) {
        uint approvedLength = approvedValidators.length;
        address[] memory validators = new address[](approvedLength);

        uint pushAt = 0;
        for (uint i = 0; i < approvedLength; i++) {
            if (orbsValidatorsRegistry.isValidator(approvedValidators[i])) {
                validators[pushAt] = approvedValidators[i];
                pushAt++;
            }
        }

        return sliceArray(validators, pushAt);
    }

    /// @dev returns a list of all validators that have been approved and exist in the validator registration
    ///      database. same as getValidators but returns addresses represented as byte20.
    function getValidatorsBytes20() external view returns (bytes20[]) {
        address[] memory validatorAddresses = getValidators();
        uint validatorAddressesLength = validatorAddresses.length;

        bytes20[] memory result = new bytes20[](validatorAddressesLength);

        for (uint i = 0; i < validatorAddressesLength; i++) {
            result[i] = bytes20(validatorAddresses[i]);
        }

        return result;
    }

    /// @dev returns the block number in which the validator was approved.
    /// @param validator address The address of the validators.
    function getApprovalBlockNumber(address validator)
        public
        view
        returns (uint)
    {
        return approvalBlockNumber[validator];
    }

    /// @dev returns an array of pairs with node addresses and ip addresses.
    function getNetworkTopology()
        external
        view
        returns (bytes20[] memory nodeAddresses, bytes4[] memory ipAddresses)
    {
        address[] memory validators = getValidators(); // filter unregistered
        uint validatorsLength = validators.length;
        nodeAddresses = new bytes20[](validatorsLength);
        ipAddresses = new bytes4[](validatorsLength);

        for (uint i = 0; i < validatorsLength; i++) {
            bytes4 ip;
            bytes20 orbsAddr;
            ( , ip , , orbsAddr) = orbsValidatorsRegistry.getValidatorData(validators[i]);
            nodeAddresses[i] = orbsAddr;
            ipAddresses[i] = ip;
        }
    }

    /// @dev internal method that returns a slice of an array.
    function sliceArray(address[] memory arr, uint len)
        internal
        pure
        returns (address[] memory)
    {
        require(len <= arr.length, "sub array must be longer then array");

        address[] memory result = new address[](len);
        for(uint i = 0; i < len; i++) {
            result[i] = arr[i];
        }
        return result;
    }
}