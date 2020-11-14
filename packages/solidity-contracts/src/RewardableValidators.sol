/**
 * Source Code first verified at https://etherscan.io on Tuesday, March 26, 2019
 (UTC) */

// File: contracts/upgradeability/EternalStorage.sol

pragma solidity 0.4.19;


/**
 * @title EternalStorage
 * @dev This contract holds all the necessary state variables to carry out the storage of any contract.
 */
contract EternalStorage {

    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;

}

// File: contracts/upgradeable_contracts/Ownable.sol

pragma solidity 0.4.19;



/**
 * @title Ownable
 * @dev This contract has an owner address providing basic authorization control
 */
contract Ownable is EternalStorage {
    /**
    * @dev Event to show ownership has been transferred
    * @param previousOwner representing the address of the previous owner
    * @param newOwner representing the address of the new owner
    */
    event OwnershipTransferred(address previousOwner, address newOwner);

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner());
        _;
    }

    /**
    * @dev Tells the address of the owner
    * @return the address of the owner
    */
    function owner() public view returns (address) {
        return addressStorage[keccak256("owner")];
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner the address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        setOwner(newOwner);
    }

    /**
    * @dev Sets a new owner address
    */
    function setOwner(address newOwner) internal {
        OwnershipTransferred(owner(), newOwner);
        addressStorage[keccak256("owner")] = newOwner;
    }
}

// File: contracts/libraries/SafeMath.sol

pragma solidity 0.4.19;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts/upgradeable_contracts/BaseBridgeValidators.sol

pragma solidity 0.4.19;





contract BaseBridgeValidators is EternalStorage, Ownable {
    using SafeMath for uint256;

    address public constant F_ADDR = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;

    event RequiredSignaturesChanged (uint256 requiredSignatures);

    function setRequiredSignatures(uint256 _requiredSignatures)
    external
    onlyOwner
    {
        require(validatorCount() >= _requiredSignatures);
        require(_requiredSignatures != 0);
        uintStorage[keccak256("requiredSignatures")] = _requiredSignatures;
        RequiredSignaturesChanged(_requiredSignatures);
    }

    function getBridgeValidatorsInterfacesVersion()
    public
    pure
    returns (uint64 major, uint64 minor, uint64 patch)
    {
        return (2, 1, 0);
    }

    function _addValidator(address _validator) internal {
        require(_validator != address(0) && _validator != F_ADDR);
        require(!isValidator(_validator));

        address firstValidator = getNextValidator(F_ADDR);
        require(firstValidator != address(0));
        setNextValidator(_validator, firstValidator);
        setNextValidator(F_ADDR, _validator);
        setValidatorCount(validatorCount().add(1));
    }

    function _removeValidator(address _validator) internal {
        require(validatorCount() > requiredSignatures());
        require(isValidator(_validator));
        address validatorsNext = getNextValidator(_validator);
        address index = F_ADDR;
        address next = getNextValidator(index);
        require(next != address(0));

        while (next != _validator) {
            index = next;
            next = getNextValidator(index);

            if (next == F_ADDR || next == address(0) ) {
                revert();
            }
        }

        setNextValidator(index, validatorsNext);
        deleteItemFromAddressStorage("validatorsList", _validator);
        setValidatorCount(validatorCount().sub(1));
    }

    function requiredSignatures() public view returns (uint256) {
        return uintStorage[keccak256("requiredSignatures")];
    }

    function validatorCount() public view returns (uint256) {
        return uintStorage[keccak256("validatorCount")];
    }

    function isValidator(address _validator) public view returns (bool) {
        return _validator != F_ADDR && getNextValidator(_validator) != address(0);
    }

    function isInitialized() public view returns (bool) {
        return boolStorage[keccak256("isInitialized")];
    }

    function deployedAtBlock() public view returns (uint256) {
        return uintStorage[keccak256("deployedAtBlock")];
    }

    function getNextValidator(address _address) public view returns (address) {
        return addressStorage[keccak256("validatorsList", _address)];
    }

    function deleteItemFromAddressStorage(string _mapName, address _address) internal {
        delete addressStorage[keccak256(_mapName, _address)];
    }

    function setValidatorCount(uint256 _validatorCount) internal {
        uintStorage[keccak256("validatorCount")] = _validatorCount;
    }

    function setNextValidator(address _prevValidator, address _validator) internal {
        addressStorage[keccak256("validatorsList", _prevValidator)] = _validator;
    }

    function setInitialize(bool _status) internal {
        boolStorage[keccak256("isInitialized")] = _status;
    }
}

// File: contracts/upgradeable_contracts/RewardableValidators.sol

pragma solidity 0.4.19;



contract RewardableValidators is BaseBridgeValidators {

    event ValidatorAdded (address indexed validator, address reward);
    event ValidatorRemoved (address indexed validator);

    function initialize(
        uint256 _requiredSignatures,
        address[] _initialValidators,
        address[] _initialRewards,
        address _owner
    )
    public
    returns (bool)
    {
        require(!isInitialized());
        require(_owner != address(0));
        setOwner(_owner);
        require(_requiredSignatures != 0);
        require(_initialValidators.length >= _requiredSignatures);
        require(_initialValidators.length == _initialRewards.length);

        for (uint256 i = 0; i < _initialValidators.length; i++) {
            require(_initialValidators[i] != address(0) && _initialValidators[i] != F_ADDR);
            require(_initialRewards[i] != address(0));
            require(!isValidator(_initialValidators[i]));

            if (i == 0) {
                setNextValidator(F_ADDR, _initialValidators[i]);
                if (_initialValidators.length == 1) {
                    setNextValidator(_initialValidators[i], F_ADDR);
                }
            } else if (i == _initialValidators.length - 1) {
                setNextValidator(_initialValidators[i - 1], _initialValidators[i]);
                setNextValidator(_initialValidators[i], F_ADDR);
            } else {
                setNextValidator(_initialValidators[i - 1], _initialValidators[i]);
            }

            setValidatorCount(validatorCount().add(1));
            setValidatorRewardAddress(_initialValidators[i], _initialRewards[i]);
            ValidatorAdded(_initialValidators[i], _initialRewards[i]);
        }

        uintStorage[keccak256("requiredSignatures")] = _requiredSignatures;
        uintStorage[keccak256("deployedAtBlock")] = block.number;
        setInitialize(true);
        RequiredSignaturesChanged(_requiredSignatures);

        return isInitialized();
    }

    function addValidator(address _validator, address _reward) external onlyOwner {
        require(_reward != address(0));
        _addValidator(_validator);
        setValidatorRewardAddress(_validator, _reward);
        ValidatorAdded(_validator, _reward);
    }

    function removeValidator(address _validator) external onlyOwner {
        _removeValidator(_validator);
        deleteItemFromAddressStorage("validatorsRewards", _validator);
        ValidatorRemoved(_validator);
    }

    function validatorList() public view returns (address[]) {
        address [] memory list = new address[](validatorCount());
        uint256 counter = 0;
        address nextValidator = getNextValidator(F_ADDR);
        require(nextValidator != address(0));

        while (nextValidator != F_ADDR) {
            list[counter] = nextValidator;
            nextValidator = getNextValidator(nextValidator);
            counter++;

            if (nextValidator == address(0) ) {
                revert();
            }
        }

        return list;
    }

    function getValidatorRewardAddress(address _validator) public view returns (address) {
        return addressStorage[keccak256("validatorsRewards", _validator)];
    }

    function setValidatorRewardAddress(address _validator, address _reward) internal {
        addressStorage[keccak256("validatorsRewards", _validator)] = _reward;
    }
}