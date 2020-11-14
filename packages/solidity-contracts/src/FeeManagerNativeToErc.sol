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

// File: contracts/IRewardableValidators.sol

pragma solidity 0.4.19;


interface IRewardableValidators {
    function isValidator(address _validator) public view returns(bool);
    function requiredSignatures() public view returns(uint256);
    function owner() public view returns(address);
    function validatorList() public view returns (address[]);
    function getValidatorRewardAddress(address _validator) public view returns(address);
    function validatorCount() public view returns (uint256);
    function getNextValidator(address _address) public view returns (address);
}

// File: contracts/upgradeable_contracts/FeeTypes.sol

pragma solidity 0.4.19;


contract FeeTypes {
    bytes32 internal constant HOME_FEE = keccak256("home-fee");
    bytes32 internal constant FOREIGN_FEE = keccak256("foreign-fee");
}

// File: contracts/upgradeable_contracts/BaseFeeManager.sol

pragma solidity 0.4.19;






contract BaseFeeManager is EternalStorage, FeeTypes {
    using SafeMath for uint256;

    bytes32 public constant REWARD_FOR_TRANSFERRING_FROM_HOME = keccak256("reward-transferring-from-home");

    bytes32 public constant REWARD_FOR_TRANSFERRING_FROM_FOREIGN = keccak256("reward-transferring-from-foreign");

    event HomeFeeUpdated(uint256 fee);
    event ForeignFeeUpdated(uint256 fee);

    function calculateFee(uint256 _value, bool _recover, bytes32 _feeType) external view returns(uint256) {
        uint256 fee = _feeType == HOME_FEE ? getHomeFee() : getForeignFee();
        uint256 eth = 1 ether;
        if (!_recover) {
            return _value.mul(fee).div(eth);
        }
        return _value.mul(fee).div(eth.sub(fee));
    }

    function setHomeFee(uint256 _fee) external {
        uintStorage[keccak256("homeFee")] = _fee;
        HomeFeeUpdated(_fee);
    }

    function getHomeFee() public view returns(uint256) {
        return uintStorage[keccak256("homeFee")];
    }

    function setForeignFee(uint256 _fee) external {
        uintStorage[keccak256("foreignFee")] = _fee;
        ForeignFeeUpdated(_fee);
    }

    function getForeignFee() public view returns(uint256) {
        return uintStorage[keccak256("foreignFee")];
    }

    function distributeFeeFromAffirmation(uint256 _fee) external {
        distributeFeeProportionally(_fee, REWARD_FOR_TRANSFERRING_FROM_FOREIGN);
    }

    function distributeFeeFromSignatures(uint256 _fee) external {
        distributeFeeProportionally(_fee, REWARD_FOR_TRANSFERRING_FROM_HOME);
    }

    function getFeeManagerMode() public pure returns(bytes4);

    function random(uint256 _count) public view returns(uint256) {
        return uint256(block.blockhash(block.number.sub(1))) % _count;
    }

    function distributeFeeProportionally(uint256 _fee, bytes32 _direction) internal {
        IRewardableValidators validators = rewardableValidatorContract();
        address F_ADDR = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
        uint256 numOfValidators = validators.validatorCount();

        uint256 feePerValidator = _fee.div(numOfValidators);

        uint256 randomValidatorIndex;
        uint256 diff = _fee.sub(feePerValidator.mul(numOfValidators));
        if (diff > 0) {
            randomValidatorIndex = random(numOfValidators);
        }

        address nextValidator = validators.getNextValidator(F_ADDR);
        require((nextValidator != F_ADDR) && (nextValidator != address(0)));

        uint256 i = 0;
        while (nextValidator != F_ADDR) {
            uint256 feeToDistribute = feePerValidator;
            if (diff > 0 && randomValidatorIndex == i) {
                feeToDistribute = feeToDistribute.add(diff);
            }

            address rewardAddress = validators.getValidatorRewardAddress(nextValidator);
            onFeeDistribution(rewardAddress, feeToDistribute, _direction);

            nextValidator = validators.getNextValidator(nextValidator);
            require(nextValidator != address(0));
            i = i + 1;
        }
    }

    function onFeeDistribution(address _rewardAddress, uint256 _fee, bytes32 _direction) internal {
        if (_direction == REWARD_FOR_TRANSFERRING_FROM_FOREIGN) {
            onAffirmationFeeDistribution(_rewardAddress, _fee);
        } else {
            onSignatureFeeDistribution(_rewardAddress, _fee);
        }
    }

    function onAffirmationFeeDistribution(address _rewardAddress, uint256 _fee) internal;

    function onSignatureFeeDistribution(address _rewardAddress, uint256 _fee) internal;

    function rewardableValidatorContract() public view returns(IRewardableValidators) {
        return IRewardableValidators(addressStorage[keccak256("validatorContract")]);
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

// File: contracts/upgradeable_contracts/Sacrifice.sol

pragma solidity 0.4.19;


contract Sacrifice {
    function Sacrifice(address _recipient) public payable {
        selfdestruct(_recipient);
    }
}

// File: contracts/upgradeable_contracts/native_to_erc20/FeeManagerNativeToErc.sol

pragma solidity 0.4.19;





contract FeeManagerNativeToErc is BaseFeeManager {

    function getFeeManagerMode() public pure returns(bytes4) {
        return bytes4(keccak256("manages-one-direction"));
    }

    function erc677token() public view returns(IBurnableMintableERC677Token) {
        return IBurnableMintableERC677Token(addressStorage[keccak256("erc677token")]);
    }

    function onAffirmationFeeDistribution(address _rewardAddress, uint256 _fee) internal {
        if (!_rewardAddress.send(_fee)) {
            (new Sacrifice).value(_fee)(_rewardAddress);
        }
    }

    function onSignatureFeeDistribution(address _rewardAddress, uint256 _fee) internal {
        erc677token().mint(_rewardAddress, _fee);
    }
}