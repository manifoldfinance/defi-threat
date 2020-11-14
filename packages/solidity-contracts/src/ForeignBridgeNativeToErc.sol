/**
 * Source Code first verified at https://etherscan.io on Monday, March 25, 2019
 (UTC) */

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

// File: contracts/IBridgeValidators.sol

pragma solidity 0.4.19;


interface IBridgeValidators {
    function isValidator(address _validator) public view returns(bool);
    function requiredSignatures() public view returns(uint256);
    function owner() public view returns(address);
}

// File: contracts/IOwnedUpgradeabilityProxy.sol

pragma solidity 0.4.19;


interface IOwnedUpgradeabilityProxy {
    function proxyOwner() public view returns (address);
}

// File: contracts/upgradeable_contracts/OwnedUpgradeability.sol

pragma solidity 0.4.19;



contract OwnedUpgradeability {

    function upgradeabilityAdmin() public view returns (address) {
        return IOwnedUpgradeabilityProxy(this).proxyOwner();
    }

    // Avoid using onlyProxyOwner name to prevent issues with implementation from proxy contract
    modifier onlyIfOwnerOfProxy() {
        require(msg.sender == upgradeabilityAdmin());
        _;
    }
}

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

// File: contracts/upgradeable_contracts/Validatable.sol

pragma solidity 0.4.19;




contract Validatable is EternalStorage {
    function validatorContract() public view returns(IBridgeValidators) {
        return IBridgeValidators(addressStorage[keccak256("validatorContract")]);
    }

    modifier onlyValidator() {
        require(validatorContract().isValidator(msg.sender));
        _;
    }

    function requiredSignatures() public view returns(uint256) {
        return validatorContract().requiredSignatures();
    }

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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

pragma solidity ^0.4.18;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: contracts/upgradeable_contracts/BasicBridge.sol

pragma solidity 0.4.19;









contract BasicBridge is EternalStorage, Validatable, Ownable, OwnedUpgradeability {
    using SafeMath for uint256;

    event GasPriceChanged(uint256 gasPrice);
    event RequiredBlockConfirmationChanged(uint256 requiredBlockConfirmations);
    event DailyLimitChanged(uint256 newLimit);
    event ExecutionDailyLimitChanged(uint256 newLimit);

    function getBridgeInterfacesVersion() public pure returns(uint64 major, uint64 minor, uint64 patch) {
        return (2, 2, 0);
    }

    function setGasPrice(uint256 _gasPrice) public onlyOwner {
        require(_gasPrice > 0);
        uintStorage[keccak256("gasPrice")] = _gasPrice;
        GasPriceChanged(_gasPrice);
    }

    function gasPrice() public view returns(uint256) {
        return uintStorage[keccak256("gasPrice")];
    }

    function setRequiredBlockConfirmations(uint256 _blockConfirmations) public onlyOwner {
        require(_blockConfirmations > 0);
        uintStorage[keccak256("requiredBlockConfirmations")] = _blockConfirmations;
        RequiredBlockConfirmationChanged(_blockConfirmations);
    }

    function requiredBlockConfirmations() public view returns(uint256) {
        return uintStorage[keccak256("requiredBlockConfirmations")];
    }

    function deployedAtBlock() public view returns(uint256) {
        return uintStorage[keccak256("deployedAtBlock")];
    }

    function setTotalSpentPerDay(uint256 _day, uint256 _value) internal {
        uintStorage[keccak256("totalSpentPerDay", _day)] = _value;
    }

    function totalSpentPerDay(uint256 _day) public view returns(uint256) {
        return uintStorage[keccak256("totalSpentPerDay", _day)];
    }

    function setTotalExecutedPerDay(uint256 _day, uint256 _value) internal {
        uintStorage[keccak256("totalExecutedPerDay", _day)] = _value;
    }

    function totalExecutedPerDay(uint256 _day) public view returns(uint256) {
        return uintStorage[keccak256("totalExecutedPerDay", _day)];
    }

    function minPerTx() public view returns(uint256) {
        return uintStorage[keccak256("minPerTx")];
    }

    function maxPerTx() public view returns(uint256) {
        return uintStorage[keccak256("maxPerTx")];
    }

    function executionMaxPerTx() public view returns(uint256) {
        return uintStorage[keccak256("executionMaxPerTx")];
    }

    function setInitialize(bool _status) internal {
        boolStorage[keccak256("isInitialized")] = _status;
    }

    function isInitialized() public view returns(bool) {
        return boolStorage[keccak256("isInitialized")];
    }

    function getCurrentDay() public view returns(uint256) {
        return now / 1 days;
    }

    function setDailyLimit(uint256 _dailyLimit) public onlyOwner {
        uintStorage[keccak256("dailyLimit")] = _dailyLimit;
        DailyLimitChanged(_dailyLimit);
    }

    function dailyLimit() public view returns(uint256) {
        return uintStorage[keccak256("dailyLimit")];
    }

    function setExecutionDailyLimit(uint256 _dailyLimit) public onlyOwner {
        uintStorage[keccak256("executionDailyLimit")] = _dailyLimit;
        ExecutionDailyLimitChanged(_dailyLimit);
    }

    function executionDailyLimit() public view returns(uint256) {
        return uintStorage[keccak256("executionDailyLimit")];
    }

    function setExecutionMaxPerTx(uint256 _maxPerTx) external onlyOwner {
        require(_maxPerTx < executionDailyLimit());
        uintStorage[keccak256("executionMaxPerTx")] = _maxPerTx;
    }

    function setMaxPerTx(uint256 _maxPerTx) external onlyOwner {
        require(_maxPerTx < dailyLimit());
        uintStorage[keccak256("maxPerTx")] = _maxPerTx;
    }

    function setMinPerTx(uint256 _minPerTx) external onlyOwner {
        require(_minPerTx < dailyLimit() && _minPerTx < maxPerTx());
        uintStorage[keccak256("minPerTx")] = _minPerTx;
    }

    function withinLimit(uint256 _amount) public view returns(bool) {
        uint256 nextLimit = totalSpentPerDay(getCurrentDay()).add(_amount);
        return dailyLimit() >= nextLimit && _amount <= maxPerTx() && _amount >= minPerTx();
    }

    function withinExecutionLimit(uint256 _amount) public view returns(bool) {
        uint256 nextLimit = totalExecutedPerDay(getCurrentDay()).add(_amount);
        return executionDailyLimit() >= nextLimit && _amount <= executionMaxPerTx();
    }

    function claimTokens(address _token, address _to) public onlyIfOwnerOfProxy {
        require(_to != address(0));
        if (_token == address(0)) {
            _to.transfer(address(this).balance);
            return;
        }

        ERC20Basic token = ERC20Basic(_token);
        uint256 balance = token.balanceOf(this);
        require(token.transfer(_to, balance));
    }


    function isContract(address _addr) internal view returns (bool)
    {
        uint length;
        assembly { length := extcodesize(_addr) }
        return length > 0;
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.4.18;



/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/ERC677.sol

pragma solidity 0.4.19;



contract ERC677 is ERC20 {
    event Transfer(address indexed from, address indexed to, uint value, bytes data);

    function transferAndCall(address, uint, bytes) external returns (bool);

}

// File: contracts/IBurnableMintableERC677Token.sol

pragma solidity 0.4.19;



contract IBurnableMintableERC677Token is ERC677 {
    function mint(address, uint256) public returns (bool);
    function burn(uint256 _value) public;
    function claimTokens(address _token, address _to) public;
}

// File: contracts/ERC677Receiver.sol

pragma solidity 0.4.19;


contract ERC677Receiver {
  function onTokenTransfer(address _from, uint _value, bytes _data) external returns(bool);
}

// File: contracts/libraries/Message.sol

pragma solidity 0.4.19;



library Message {
    // function uintToString(uint256 inputValue) internal pure returns (string) {
    //     // figure out the length of the resulting string
    //     uint256 length = 0;
    //     uint256 currentValue = inputValue;
    //     do {
    //         length++;
    //         currentValue /= 10;
    //     } while (currentValue != 0);
    //     // allocate enough memory
    //     bytes memory result = new bytes(length);
    //     // construct the string backwards
    //     uint256 i = length - 1;
    //     currentValue = inputValue;
    //     do {
    //         result[i--] = byte(48 + currentValue % 10);
    //         currentValue /= 10;
    //     } while (currentValue != 0);
    //     return string(result);
    // }

    function addressArrayContains(address[] array, address value) internal pure returns (bool) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == value) {
                return true;
            }
        }
        return false;
    }
    // layout of message :: bytes:
    // offset  0: 32 bytes :: uint256 - message length
    // offset 32: 20 bytes :: address - recipient address
    // offset 52: 32 bytes :: uint256 - value
    // offset 84: 32 bytes :: bytes32 - transaction hash
    // offset 104: 20 bytes :: address - contract address to prevent double spending

    // bytes 1 to 32 are 0 because message length is stored as little endian.
    // mload always reads 32 bytes.
    // so we can and have to start reading recipient at offset 20 instead of 32.
    // if we were to read at 32 the address would contain part of value and be corrupted.
    // when reading from offset 20 mload will read 12 zero bytes followed
    // by the 20 recipient address bytes and correctly convert it into an address.
    // this saves some storage/gas over the alternative solution
    // which is padding address to 32 bytes and reading recipient at offset 32.
    // for more details see discussion in:
    // https://github.com/paritytech/parity-bridge/issues/61
    function parseMessage(bytes message)
        internal
        pure
        returns(address recipient, uint256 amount, bytes32 txHash, address contractAddress)
    {
        require(isMessageValid(message));
        assembly {
            recipient := and(mload(add(message, 20)), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            amount := mload(add(message, 52))
            txHash := mload(add(message, 84))
            contractAddress := mload(add(message, 104))
        }
    }

    function isMessageValid(bytes _msg) internal pure returns(bool) {
        return _msg.length == requiredMessageLength();
    }

    function requiredMessageLength() internal pure returns(uint256) {
        return 104;
    }

    function recoverAddressFromSignedMessage(bytes signature, bytes message) internal pure returns (address) {
        require(signature.length == 65);
        bytes32 r;
        bytes32 s;
        bytes1 v;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := mload(add(signature, 0x60))
        }
        return ecrecover(hashMessage(message), uint8(v), r, s);
    }

    function hashMessage(bytes message) internal pure returns (bytes32) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n";
        // message is always 84 length
        string memory msgLength = "104";
        return keccak256(prefix, msgLength, message);
    }

    function hasEnoughValidSignatures(
        bytes _message,
        uint8[] _vs,
        bytes32[] _rs,
        bytes32[] _ss,
        IBridgeValidators _validatorContract) internal view {
        require(isMessageValid(_message));
        uint256 requiredSignatures = _validatorContract.requiredSignatures();
        require(_vs.length >= requiredSignatures);
        bytes32 hash = hashMessage(_message);
        address[] memory encounteredAddresses = new address[](requiredSignatures);

        for (uint256 i = 0; i < requiredSignatures; i++) {
            address recoveredAddress = ecrecover(hash, _vs[i], _rs[i], _ss[i]);
            require(_validatorContract.isValidator(recoveredAddress));
            if (addressArrayContains(encounteredAddresses, recoveredAddress)) {
                revert();
            }
            encounteredAddresses[i] = recoveredAddress;
        }
    }
}

// File: contracts/upgradeable_contracts/BasicForeignBridge.sol

pragma solidity 0.4.19;






contract BasicForeignBridge is EternalStorage, Validatable {
    using SafeMath for uint256;
    /// triggered when relay of deposit from HomeBridge is complete
    event RelayedMessage(address recipient, uint value, bytes32 transactionHash);
    function executeSignatures(uint8[] vs, bytes32[] rs, bytes32[] ss, bytes message) external {
        Message.hasEnoughValidSignatures(message, vs, rs, ss, validatorContract());
        address recipient;
        uint256 amount;
        bytes32 txHash;
        address contractAddress;
        (recipient, amount, txHash, contractAddress) = Message.parseMessage(message);
        if (messageWithinLimits(amount)) {
            require(contractAddress == address(this));
            require(!relayedMessages(txHash));
            setRelayedMessages(txHash, true);
            require(onExecuteMessage(recipient, amount));
            RelayedMessage(recipient, amount, txHash);
        } else {
            onFailedMessage(recipient, amount, txHash);
        }
    }

    function onExecuteMessage(address, uint256) internal returns(bool);

    function setRelayedMessages(bytes32 _txHash, bool _status) internal {
        boolStorage[keccak256("relayedMessages", _txHash)] = _status;
    }

    function relayedMessages(bytes32 _txHash) public view returns(bool) {
        return boolStorage[keccak256("relayedMessages", _txHash)];
    }

    function messageWithinLimits(uint256) internal view returns(bool);

    function onFailedMessage(address, uint256, bytes32) internal;
}

// File: contracts/upgradeable_contracts/ERC677Bridge.sol

pragma solidity 0.4.19;



contract ERC677Bridge is BasicBridge {
    function erc677token() public view returns(IBurnableMintableERC677Token) {
        return IBurnableMintableERC677Token(addressStorage[keccak256("erc677token")]);
    }

    function setErc677token(address _token) internal {
        require(_token != address(0) && isContract(_token));
        addressStorage[keccak256("erc677token")] = _token;
    }

    function onTokenTransfer(address _from, uint256 _value, bytes /*_data*/) external returns(bool) {
        require(msg.sender == address(erc677token()));
        require(withinLimit(_value));
        setTotalSpentPerDay(getCurrentDay(), totalSpentPerDay(getCurrentDay()).add(_value));
        erc677token().burn(_value);
        fireEventOnTokenTransfer(_from, _value);
        return true;
    }

    function fireEventOnTokenTransfer(address /*_from */, uint256 /* _value */) internal {
        // has to be defined
    }

}

// File: contracts/upgradeable_contracts/FeeTypes.sol

pragma solidity 0.4.19;


contract FeeTypes {
    bytes32 internal constant HOME_FEE = keccak256("home-fee");
    bytes32 internal constant FOREIGN_FEE = keccak256("foreign-fee");
}

// File: contracts/upgradeable_contracts/RewardableBridge.sol

pragma solidity 0.4.19;




contract RewardableBridge is Ownable, FeeTypes {

    function _getFee(bytes32 _feeType) internal view returns(uint256) {
        uint256 fee;
        address feeManager = feeManagerContract();
        string memory method = _feeType == HOME_FEE ? "getHomeFee()" : "getForeignFee()";
        bytes4 sig = bytes4(keccak256(method));

        assembly {
            let x := mload(0x40)
            mstore(x, sig)
            let result := callcode(gas, feeManager, 0x0, x, 4, 0, 32)
            fee := mload(0)

            switch result
            case 0 { revert(0, 0) }
        }
        return fee;
    }

    function getFeeManagerMode() public view returns(bytes4) {
        bytes4 mode;
        bytes4 sig = bytes4(keccak256("getFeeManagerMode()"));
        address feeManager = feeManagerContract();
        assembly {
            let x := mload(0x40)
            mstore(x, sig)
            let result := callcode(gas, feeManager, 0x0, x, 4, 0, 4)
            mode := mload(0)

            switch result
            case 0 { revert(0, 0) }
        }
        return mode;
    }

    function feeManagerContract() public view returns(address) {
        return addressStorage[keccak256("feeManagerContract")];
    }

    function setFeeManagerContract(address _feeManager) public onlyOwner {
        require(_feeManager == address(0) || isContract(_feeManager));
        addressStorage[keccak256("feeManagerContract")] = _feeManager;
    }

    function _setFee(address _feeManager, uint256 _fee, bytes32 _feeType) internal {
        string memory method = _feeType == HOME_FEE ? "setHomeFee(uint256)" : "setForeignFee(uint256)";
        require(_feeManager.delegatecall(bytes4(keccak256(method)), _fee));
    }

    function isContract(address _addr) internal view returns (bool)
    {
        uint length;
        assembly { length := extcodesize(_addr) }
        return length > 0;
    }

    function calculateFee(uint256 _value, bool _recover, address _impl, bytes32 _feeType) internal view returns(uint256) {
        uint256 fee;
        bytes4 sig = bytes4(keccak256("calculateFee(uint256,bool,bytes32)"));
        assembly {
            let callData := mload(0x40)
            mstore(callData,sig)
            mstore(add(callData,4),_value)
            mstore(add(callData,36),_recover)
            mstore(add(callData,68),_feeType)
            let result := callcode(gas, _impl, 0x0, callData, 100, 0, 32)
            fee := mload(0)

            switch result
            case 0 { revert(0, 0) }
        }
        return fee;
    }

    function distributeFeeFromSignatures(uint256 _fee, address _feeManager) internal {
        require(_feeManager.delegatecall(bytes4(keccak256("distributeFeeFromSignatures(uint256)")), _fee));
    }

    function distributeFeeFromAffirmation(uint256 _fee, address _feeManager) internal {
        require(_feeManager.delegatecall(bytes4(keccak256("distributeFeeFromAffirmation(uint256)")), _fee));
    }
}

// File: contracts/upgradeable_contracts/native_to_erc20/RewardableForeignBridgeNativeToErc.sol

pragma solidity 0.4.19;



contract RewardableForeignBridgeNativeToErc is RewardableBridge {

    function setHomeFee(uint256 _fee) external onlyOwner {
        _setFee(feeManagerContract(), _fee, HOME_FEE);
    }

    function getHomeFee() public view returns(uint256) {
        return _getFee(HOME_FEE);
    }
}

// File: contracts/upgradeable_contracts/native_to_erc20/ForeignBridgeNativeToErc.sol

pragma solidity 0.4.19;










contract ForeignBridgeNativeToErc is ERC677Receiver, BasicBridge, BasicForeignBridge, ERC677Bridge, RewardableForeignBridgeNativeToErc {

    /// Event created on money withdraw.
    event UserRequestForAffirmation(address recipient, uint256 value);

    function initialize(
        address _validatorContract,
        address _erc677token,
        uint256 _dailyLimit,
        uint256 _maxPerTx,
        uint256 _minPerTx,
        uint256 _foreignGasPrice,
        uint256 _requiredBlockConfirmations,
        uint256 _homeDailyLimit,
        uint256 _homeMaxPerTx,
        address _owner
    ) public returns(bool) {
        _initialize(
            _validatorContract,
            _erc677token,
            _dailyLimit,
            _maxPerTx,
            _minPerTx,
            _foreignGasPrice,
            _requiredBlockConfirmations,
            _homeDailyLimit,
            _homeMaxPerTx,
            _owner
        );
        setInitialize(true);
        return isInitialized();
    }

    function rewardableInitialize(
        address _validatorContract,
        address _erc677token,
        uint256 _dailyLimit,
        uint256 _maxPerTx,
        uint256 _minPerTx,
        uint256 _foreignGasPrice,
        uint256 _requiredBlockConfirmations,
        uint256 _homeDailyLimit,
        uint256 _homeMaxPerTx,
        address _owner,
        address _feeManager,
        uint256 _homeFee
    ) public returns(bool) {
        _initialize(
            _validatorContract,
            _erc677token,
            _dailyLimit,
            _maxPerTx,
            _minPerTx,
            _foreignGasPrice,
            _requiredBlockConfirmations,
            _homeDailyLimit,
            _homeMaxPerTx,
            _owner
        );
        require(isContract(_feeManager));
        addressStorage[keccak256("feeManagerContract")] = _feeManager;
        _setFee(_feeManager, _homeFee, HOME_FEE);
        setInitialize(true);
        return isInitialized();
    }

    function getBridgeMode() public pure returns(bytes4 _data) {
        return bytes4(keccak256("native-to-erc-core"));
    }

    function claimTokensFromErc677(address _token, address _to) external onlyIfOwnerOfProxy {
        erc677token().claimTokens(_token, _to);
    }

    function _initialize(
        address _validatorContract,
        address _erc677token,
        uint256 _dailyLimit,
        uint256 _maxPerTx,
        uint256 _minPerTx,
        uint256 _foreignGasPrice,
        uint256 _requiredBlockConfirmations,
        uint256 _homeDailyLimit,
        uint256 _homeMaxPerTx,
        address _owner
    ) internal {
        require(!isInitialized());
        require(_validatorContract != address(0) && isContract(_validatorContract));
        require(_minPerTx > 0 && _maxPerTx > _minPerTx && _dailyLimit > _maxPerTx);
        require(_foreignGasPrice > 0);
        require(_homeMaxPerTx < _homeDailyLimit);
        require(_owner != address(0));
        addressStorage[keccak256("validatorContract")] = _validatorContract;
        setErc677token(_erc677token);
        uintStorage[keccak256("dailyLimit")] = _dailyLimit;
        uintStorage[keccak256("deployedAtBlock")] = block.number;
        uintStorage[keccak256("maxPerTx")] = _maxPerTx;
        uintStorage[keccak256("minPerTx")] = _minPerTx;
        uintStorage[keccak256("gasPrice")] = _foreignGasPrice;
        uintStorage[keccak256("requiredBlockConfirmations")] = _requiredBlockConfirmations;
        uintStorage[keccak256("executionDailyLimit")] = _homeDailyLimit;
        uintStorage[keccak256("executionMaxPerTx")] = _homeMaxPerTx;
        setOwner(_owner);
    }

    function onExecuteMessage(address _recipient, uint256 _amount) internal returns(bool) {
        setTotalExecutedPerDay(getCurrentDay(), totalExecutedPerDay(getCurrentDay()).add(_amount));
        uint256 valueToMint = _amount;
        address feeManager = feeManagerContract();
        if (feeManager != address(0)) {
            uint256 fee = calculateFee(valueToMint, false, feeManager, HOME_FEE);
            if (fee != 0) {
                distributeFeeFromSignatures(fee, feeManager);
                valueToMint = valueToMint.sub(fee);
            }
        }
        return erc677token().mint(_recipient, valueToMint);
    }

    function fireEventOnTokenTransfer(address _from, uint256 _value) internal {
        UserRequestForAffirmation(_from, _value);
    }

    function messageWithinLimits(uint256 _amount) internal view returns(bool) {
        return withinExecutionLimit(_amount);
    }

    function onFailedMessage(address, uint256, bytes32) internal {
        revert();
    }
}