/**
 * Source Code first verified at https://etherscan.io on Monday, March 25, 2019
 (UTC) */

pragma solidity 0.4.25;


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


/// @title Orbs Validators Registry smart contract.
contract OrbsValidatorsRegistry is IOrbsValidatorsRegistry {

    // The validator registration data object.
    struct ValidatorData {
        string name;
        bytes4 ipAddress;
        string website;
        bytes20 orbsAddress;
        uint registeredOnBlock;
        uint lastUpdatedOnBlock;
    }

    // The version of the current validators data registration smart contract.
    uint public constant VERSION = 1;

    // A mapping from validator's Ethereum address to registration data.
    mapping(address => ValidatorData) internal validatorsData;

    // Lookups for IP Address & Orbs Address for uniqueness checks. Useful also be used for as a public lookup index.
    mapping(bytes4 => address) public lookupByIp;
    mapping(bytes20 => address) public lookupByOrbsAddr;

    /// @dev check that the caller is a validator.
    modifier onlyValidator() {
        require(isValidator(msg.sender), "You must be a registered validator");
        _;
    }

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
        external
    {
        address sender = msg.sender;
        require(bytes(name).length > 0, "Please provide a valid name");
        require(bytes(website).length > 0, "Please provide a valid website");
        require(!isValidator(sender), "Validator already exists");
        require(ipAddress != bytes4(0), "Please pass a valid ip address represented as an array of exactly 4 bytes");
        require(orbsAddress != bytes20(0), "Please provide a valid Orbs Address");
        require(lookupByIp[ipAddress] == address(0), "IP address already in use");
        require(lookupByOrbsAddr[orbsAddress] == address(0), "Orbs Address is already in use by another validator");

        lookupByIp[ipAddress] = sender;
        lookupByOrbsAddr[orbsAddress] = sender;

        validatorsData[sender] = ValidatorData({
            name: name,
            ipAddress: ipAddress,
            website: website,
            orbsAddress: orbsAddress,
            registeredOnBlock: block.number,
            lastUpdatedOnBlock: block.number
        });

        emit ValidatorRegistered(sender);
    }

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
        external
        onlyValidator
    {
        address sender = msg.sender;
        require(bytes(name).length > 0, "Please provide a valid name");
        require(bytes(website).length > 0, "Please provide a valid website");
        require(ipAddress != bytes4(0), "Please pass a valid ip address represented as an array of exactly 4 bytes");
        require(orbsAddress != bytes20(0), "Please provide a valid Orbs Address");
        require(isIpFreeToUse(ipAddress), "IP Address is already in use by another validator");
        require(isOrbsAddressFreeToUse(orbsAddress), "Orbs Address is already in use by another validator");

        ValidatorData storage data = validatorsData[sender];

        // Remove previous key from lookup.
        delete lookupByIp[data.ipAddress];
        delete lookupByOrbsAddr[data.orbsAddress];

        // Set new keys in lookup.
        lookupByIp[ipAddress] = sender;
        lookupByOrbsAddr[orbsAddress] = sender;

        data.name = name;
        data.ipAddress = ipAddress;
        data.website = website;
        data.orbsAddress = orbsAddress;
        data.lastUpdatedOnBlock = block.number;

        emit ValidatorUpdated(sender);
    }

    /// @dev deletes a validator registration entry associated with msg.sender.
    function leave() external onlyValidator {
        address sender = msg.sender;

        ValidatorData storage data = validatorsData[sender];

        delete lookupByIp[data.ipAddress];
        delete lookupByOrbsAddr[data.orbsAddress];

        delete validatorsData[sender];

        emit ValidatorLeft(sender);
    }

    /// @dev returns the blocks in which a validator was registered and last updated.
    /// if validator does not designate a registered validator this method returns zero values.
    /// @param validator address of a validator
    function getRegistrationBlockNumber(address validator)
        external
        view
        returns (uint registeredOn, uint lastUpdatedOn)
    {
        require(isValidator(validator), "Unlisted Validator");

        ValidatorData storage entry = validatorsData[validator];
        registeredOn = entry.registeredOnBlock;
        lastUpdatedOn = entry.lastUpdatedOnBlock;
    }

    /// @dev returns the orbs node public address of a specific validator.
    /// @param validator address address of the validator
    /// @return an Orbs node address
    function getOrbsAddress(address validator)
        external
        view
        returns (bytes20)
    {
        return validatorsData[validator].orbsAddress;
    }

    /// @dev returns validator registration data.
    /// @param validator address address of the validator.
    function getValidatorData(address validator)
        public
        view
        returns (
            string memory name,
            bytes4 ipAddress,
            string memory website,
            bytes20 orbsAddress
        )
    {
        ValidatorData storage entry = validatorsData[validator];
        name = entry.name;
        ipAddress = entry.ipAddress;
        website = entry.website;
        orbsAddress = entry.orbsAddress;
    }

    /// @dev Checks if validator is currently registered as a validator.
    /// @param validator address address of the validator
    /// @return true iff validator belongs to a registered validator
    function isValidator(address validator) public view returns (bool) {
        return validatorsData[validator].registeredOnBlock > 0;
    }

    /// @dev INTERNAL. Checks if ipAddress is currently available to msg.sender.
    /// @param ipAddress bytes4 ip address to check for uniqueness
    /// @return true iff ipAddress is currently not registered for any validator other than msg.sender.
    function isIpFreeToUse(bytes4 ipAddress) internal view returns (bool) {
        return
            lookupByIp[ipAddress] == address(0) ||
            lookupByIp[ipAddress] == msg.sender;
    }

    /// @dev INTERNAL. Checks if orbsAddress is currently available to msg.sender.
    /// @param orbsAddress bytes20 ip address to check for uniqueness
    /// @return true iff orbsAddress is currently not registered for a validator other than msg.sender.
    function isOrbsAddressFreeToUse(bytes20 orbsAddress)
        internal
        view
        returns (bool)
    {
        return
            lookupByOrbsAddr[orbsAddress] == address(0) ||
            lookupByOrbsAddr[orbsAddress] == msg.sender;
    }
}