/**
 * Source Code first verified at https://etherscan.io on Friday, May 3, 2019
 (UTC) */

pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;

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

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath
{
	/**
	* @dev Adds two unsigned integers, reverts on overflow.
	*/
	function add(uint256 a, uint256 b) internal pure returns (uint256)
	{
		uint256 c = a + b;
		require(c >= a);
		return c;
	}

	/**
	* @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
	*/
	function sub(uint256 a, uint256 b) internal pure returns (uint256)
	{
		require(b <= a);
		uint256 c = a - b;
		return c;
	}

	/**
	* @dev Multiplies two unsigned integers, reverts on overflow.
	*/
	function mul(uint256 a, uint256 b) internal pure returns (uint256)
	{
		// Gas optimization: this is cheaper than requiring 'a' not being zero, but the
		// benefit is lost if 'b' is also tested.
		// See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
		if (a == 0)
		{
			return 0;
		}
		uint256 c = a * b;
		require(c / a == b);
		return c;
	}

	/**
	* @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
	*/
	function div(uint256 a, uint256 b) internal pure returns (uint256)
	{
			// Solidity only automatically asserts when dividing by 0
			require(b > 0);
			uint256 c = a / b;
			// assert(a == b * c + a % b); // There is no case in which this doesn't hold
			return c;
	}

	/**
	* @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
	* reverts when dividing by zero.
	*/
	function mod(uint256 a, uint256 b) internal pure returns (uint256)
	{
		require(b != 0);
		return a % b;
	}

	/**
	* @dev Returns the largest of two numbers.
	*/
	function max(uint256 a, uint256 b) internal pure returns (uint256)
	{
		return a >= b ? a : b;
	}

	/**
	* @dev Returns the smallest of two numbers.
	*/
	function min(uint256 a, uint256 b) internal pure returns (uint256)
	{
		return a < b ? a : b;
	}

	/**
	* @dev Multiplies the a by the fraction b/c
	*/
	function mulByFraction(uint256 a, uint256 b, uint256 c) internal pure returns (uint256)
	{
		return div(mul(a, b), c);
	}

	/**
	* @dev Return b percents of a (equivalent to a percents of b)
	*/
	function percentage(uint256 a, uint256 b) internal pure returns (uint256)
	{
		return mulByFraction(a, b, 100);
	}

	/**
	* @dev Returns the base 2 log of x
	* @notice Source : https://ethereum.stackexchange.com/questions/8086/logarithm-math-operation-in-solidity
	*/
	function log(uint x) internal pure returns (uint y)
	{
		assembly
		{
			let arg := x
			x := sub(x,1)
			x := or(x, div(x, 0x02))
			x := or(x, div(x, 0x04))
			x := or(x, div(x, 0x10))
			x := or(x, div(x, 0x100))
			x := or(x, div(x, 0x10000))
			x := or(x, div(x, 0x100000000))
			x := or(x, div(x, 0x10000000000000000))
			x := or(x, div(x, 0x100000000000000000000000000000000))
			x := add(x, 1)
			let m := mload(0x40)
			mstore(m,           0xf8f9cbfae6cc78fbefe7cdc3a1793dfcf4f0e8bbd8cec470b6a28a7a5a3e1efd)
			mstore(add(m,0x20), 0xf5ecf1b3e9debc68e1d9cfabc5997135bfb7a7a3938b7b606b5b4b3f2f1f0ffe)
			mstore(add(m,0x40), 0xf6e4ed9ff2d6b458eadcdf97bd91692de2d4da8fd2d0ac50c6ae9a8272523616)
			mstore(add(m,0x60), 0xc8c0b887b0a8a4489c948c7f847c6125746c645c544c444038302820181008ff)
			mstore(add(m,0x80), 0xf7cae577eec2a03cf3bad76fb589591debb2dd67e0aa9834bea6925f6a4a2e0e)
			mstore(add(m,0xa0), 0xe39ed557db96902cd38ed14fad815115c786af479b7e83247363534337271707)
			mstore(add(m,0xc0), 0xc976c13bb96e881cb166a933a55e490d9d56952b8d4e801485467d2362422606)
			mstore(add(m,0xe0), 0x753a6d1b65325d0c552a4d1345224105391a310b29122104190a110309020100)
			mstore(0x40, add(m, 0x100))
			let magic := 0x818283848586878898a8b8c8d8e8f929395969799a9b9d9e9faaeb6bedeeff
			let shift := 0x100000000000000000000000000000000000000000000000000000000000000
			let a := div(mul(x, magic), shift)
			y := div(mload(add(m,sub(255,a))), shift)
			y := add(y, mul(256, gt(arg, 0x8000000000000000000000000000000000000000000000000000000000000000)))
		}
	}
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 */
interface IERC20
{
	function totalSupply()
		external view returns (uint256);

	function balanceOf(address who)
		external view returns (uint256);

	function allowance(address owner, address spender)
		external view returns (uint256);

	function transfer(address to, uint256 value)
		external returns (bool);

	function approve(address spender, uint256 value)
		external returns (bool);

	function transferFrom(address from, address to, uint256 value)
		external returns (bool);

	event Transfer(
		address indexed from,
		address indexed to,
		uint256 value
	);

	event Approval(
		address indexed owner,
		address indexed spender,
		uint256 value
	);
}

contract IERC734
{
	// 1: MANAGEMENT keys, which can manage the identity
	uint256 public constant MANAGEMENT_KEY = 1;
	// 2: ACTION keys, which perform actions in this identities name (signing, logins, transactions, etc.)
	uint256 public constant ACTION_KEY = 2;
	// 3: CLAIM signer keys, used to sign claims on other identities which need to be revokable.
	uint256 public constant CLAIM_SIGNER_KEY = 3;
	// 4: ENCRYPTION keys, used to encrypt data e.g. hold in claims.
	uint256 public constant ENCRYPTION_KEY = 4;

	// KeyType
	uint256 public constant ECDSA_TYPE = 1;
	// https://medium.com/@alexberegszaszi/lets-bring-the-70s-to-ethereum-48daa16a4b51
	uint256 public constant RSA_TYPE = 2;

	// Events
	event KeyAdded          (bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);
	event KeyRemoved        (bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);
	event ExecutionRequested(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);
	event Executed          (uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);
	event ExecutionFailed   (uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);
	event Approved          (uint256 indexed executionId, bool approved);

	// Functions
	function getKey          (bytes32 _key                                     ) external view returns (uint256[] memory purposes, uint256 keyType, bytes32 key);
	function keyHasPurpose   (bytes32 _key, uint256 purpose                    ) external view returns (bool exists);
	function getKeysByPurpose(uint256 _purpose                                 ) external view returns (bytes32[] memory keys);
	function addKey          (bytes32 _key, uint256 _purpose, uint256 _keyType ) external      returns (bool success);
	function removeKey       (bytes32 _key, uint256 _purpose                   ) external      returns (bool success);
	function execute         (address _to, uint256 _value, bytes calldata _data) external      returns (uint256 executionId);
	function approve         (uint256 _id, bool _approve                       ) external      returns (bool success);
}

contract IERC1271
{
	// bytes4(keccak256("isValidSignature(bytes,bytes)")
	bytes4 constant internal MAGICVALUE = 0x20c13b0b;

	/**
	 * @dev Should return whether the signature provided is valid for the provided data
	 * @param _data Arbitrary length data signed on the behalf of address(this)
	 * @param _signature Signature byte array associated with _data
	 *
	 * MUST return the bytes4 magic value 0x20c13b0b when function passes.
	 * MUST NOT modify state (using STATICCALL for solc < 0.5, view modifier for solc > 0.5)
	 * MUST allow external calls
	 */
	// function isValidSignature(
	// 	bytes memory _data,
	// 	bytes memory _signature)
	// 	public
	// 	view
	// 	returns (bytes4 magicValue);

	// Newer version ? From 0x V2
	function isValidSignature(
		bytes32 _data,
		bytes memory _signature
	)
	public
	view
	returns (bool isValid);
}

/**
 * @title EIP1154 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-1154
 */
interface IOracleConsumer
{
	function receiveResult(bytes32, bytes calldata)
		external;
}

interface IOracle
{
	function resultFor(bytes32)
		external view returns (bytes memory);
}

library IexecODBLibCore
{
	/**
	* Tools
	*/
	struct Account
	{
		uint256 stake;
		uint256 locked;
	}
	struct Category
	{
		string  name;
		string  description;
		uint256 workClockTimeRef;
	}

	/**
	 * Clerk - Deals
	 */
	struct Resource
	{
		address pointer;
		address owner;
		uint256 price;
	}
	struct Deal
	{
		// Ressources
		Resource app;
		Resource dataset;
		Resource workerpool;
		uint256 trust;
		uint256 category;
		bytes32 tag;
		// execution details
		address requester;
		address beneficiary;
		address callback;
		string  params;
		// execution settings
		uint256 startTime;
		uint256 botFirst;
		uint256 botSize;
		// consistency
		uint256 workerStake;
		uint256 schedulerRewardRatio;
	}

	/**
	 * Tasks
	 // TODO: rename Workorder → Task
	 */
	enum TaskStatusEnum
	{
		UNSET,     // Work order not yet initialized (invalid address)
		ACTIVE,    // Marketed → constributions are open
		REVEALING, // Starting consensus reveal
		COMPLETED, // Concensus achieved
		FAILLED    // Failled consensus
	}
	struct Task
	{
		TaskStatusEnum status;
		bytes32   dealid;
		uint256   idx;
		uint256   timeref;
		uint256   contributionDeadline;
		uint256   revealDeadline;
		uint256   finalDeadline;
		bytes32   consensusValue;
		uint256   revealCounter;
		uint256   winnerCounter;
		address[] contributors;
		bytes32   resultDigest;
		bytes     results;
	}

	/**
	 * Consensus
	 */
	enum ContributionStatusEnum
	{
		UNSET,
		CONTRIBUTED,
		PROVED,
		REJECTED
	}
	struct Contribution
	{
		ContributionStatusEnum status;
		bytes32 resultHash;
		bytes32 resultSeal;
		address enclaveChallenge;
	}

}

library IexecODBLibOrders
{
	// bytes32 public constant    EIP712DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
	// bytes32 public constant        APPORDER_TYPEHASH = keccak256("AppOrder(address app,uint256 appprice,uint256 volume,bytes32 tag,address datasetrestrict,address workerpoolrestrict,address requesterrestrict,bytes32 salt)");
	// bytes32 public constant    DATASETORDER_TYPEHASH = keccak256("DatasetOrder(address dataset,uint256 datasetprice,uint256 volume,bytes32 tag,address apprestrict,address workerpoolrestrict,address requesterrestrict,bytes32 salt)");
	// bytes32 public constant WORKERPOOLORDER_TYPEHASH = keccak256("WorkerpoolOrder(address workerpool,uint256 workerpoolprice,uint256 volume,bytes32 tag,uint256 category,uint256 trust,address apprestrict,address datasetrestrict,address requesterrestrict,bytes32 salt)");
	// bytes32 public constant    REQUESTORDER_TYPEHASH = keccak256("RequestOrder(address app,uint256 appmaxprice,address dataset,uint256 datasetmaxprice,address workerpool,uint256 workerpoolmaxprice,address requester,uint256 volume,bytes32 tag,uint256 category,uint256 trust,address beneficiary,address callback,string params,bytes32 salt)");
	bytes32 public constant    EIP712DOMAIN_TYPEHASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;
	bytes32 public constant        APPORDER_TYPEHASH = 0x60815a0eeec47dddf1615fe53b31d016c31444e01b9d796db365443a6445d008;
	bytes32 public constant    DATASETORDER_TYPEHASH = 0x6cfc932a5a3d22c4359295b9f433edff52b60703fa47690a04a83e40933dd47c;
	bytes32 public constant WORKERPOOLORDER_TYPEHASH = 0xaa3429fb281b34691803133d3d978a75bb77c617ed6bc9aa162b9b30920022bb;
	bytes32 public constant    REQUESTORDER_TYPEHASH = 0xf24e853034a3a450aba845a82914fbb564ad85accca6cf62be112a154520fae0;

	struct EIP712Domain
	{
		string  name;
		string  version;
		uint256 chainId;
		address verifyingContract;
	}
	struct AppOrder
	{
		address app;
		uint256 appprice;
		uint256 volume;
		bytes32 tag;
		address datasetrestrict;
		address workerpoolrestrict;
		address requesterrestrict;
		bytes32 salt;
		bytes   sign;
	}
	struct DatasetOrder
	{
		address dataset;
		uint256 datasetprice;
		uint256 volume;
		bytes32 tag;
		address apprestrict;
		address workerpoolrestrict;
		address requesterrestrict;
		bytes32 salt;
		bytes   sign;
	}
	struct WorkerpoolOrder
	{
		address workerpool;
		uint256 workerpoolprice;
		uint256 volume;
		bytes32 tag;
		uint256 category;
		uint256 trust;
		address apprestrict;
		address datasetrestrict;
		address requesterrestrict;
		bytes32 salt;
		bytes   sign;
	}
	struct RequestOrder
	{
		address app;
		uint256 appmaxprice;
		address dataset;
		uint256 datasetmaxprice;
		address workerpool;
		uint256 workerpoolmaxprice;
		address requester;
		uint256 volume;
		bytes32 tag;
		uint256 category;
		uint256 trust;
		address beneficiary;
		address callback;
		string  params;
		bytes32 salt;
		bytes   sign;
	}

	function hash(EIP712Domain memory _domain)
	public pure returns (bytes32 domainhash)
	{
		/**
		 * Readeable but expensive
		 */
		// return keccak256(abi.encode(
		// 	EIP712DOMAIN_TYPEHASH
		// , keccak256(bytes(_domain.name))
		// , keccak256(bytes(_domain.version))
		// , _domain.chainId
		// , _domain.verifyingContract
		// ));

		// Compute sub-hashes
		bytes32 typeHash    = EIP712DOMAIN_TYPEHASH;
		bytes32 nameHash    = keccak256(bytes(_domain.name));
		bytes32 versionHash = keccak256(bytes(_domain.version));
		assembly {
			// Back up select memory
			let temp1 := mload(sub(_domain, 0x20))
			let temp2 := mload(add(_domain, 0x00))
			let temp3 := mload(add(_domain, 0x20))
			// Write typeHash and sub-hashes
			mstore(sub(_domain, 0x20),    typeHash)
			mstore(add(_domain, 0x00),    nameHash)
			mstore(add(_domain, 0x20), versionHash)
			// Compute hash
			domainhash := keccak256(sub(_domain, 0x20), 0xA0) // 160 = 32 + 128
			// Restore memory
			mstore(sub(_domain, 0x20), temp1)
			mstore(add(_domain, 0x00), temp2)
			mstore(add(_domain, 0x20), temp3)
		}
	}
	function hash(AppOrder memory _apporder)
	public pure returns (bytes32 apphash)
	{
		/**
		 * Readeable but expensive
		 */
		// return keccak256(abi.encode(
		// 	APPORDER_TYPEHASH
		// , _apporder.app
		// , _apporder.appprice
		// , _apporder.volume
		// , _apporder.tag
		// , _apporder.datasetrestrict
		// , _apporder.workerpoolrestrict
		// , _apporder.requesterrestrict
		// , _apporder.salt
		// ));

		// Compute sub-hashes
		bytes32 typeHash = APPORDER_TYPEHASH;
		assembly {
			// Back up select memory
			let temp1 := mload(sub(_apporder, 0x20))
			// Write typeHash and sub-hashes
			mstore(sub(_apporder, 0x20), typeHash)
			// Compute hash
			apphash := keccak256(sub(_apporder, 0x20), 0x120) // 288 = 32 + 256
			// Restore memory
			mstore(sub(_apporder, 0x20), temp1)
		}
	}
	function hash(DatasetOrder memory _datasetorder)
	public pure returns (bytes32 datasethash)
	{
		/**
		 * Readeable but expensive
		 */
		// return keccak256(abi.encode(
		// 	DATASETORDER_TYPEHASH
		// , _datasetorder.dataset
		// , _datasetorder.datasetprice
		// , _datasetorder.volume
		// , _datasetorder.tag
		// , _datasetorder.apprestrict
		// , _datasetorder.workerpoolrestrict
		// , _datasetorder.requesterrestrict
		// , _datasetorder.salt
		// ));

		// Compute sub-hashes
		bytes32 typeHash = DATASETORDER_TYPEHASH;
		assembly {
			// Back up select memory
			let temp1 := mload(sub(_datasetorder, 0x20))
			// Write typeHash and sub-hashes
			mstore(sub(_datasetorder, 0x20), typeHash)
			// Compute hash
			datasethash := keccak256(sub(_datasetorder, 0x20), 0x120) // 288 = 32 + 256
			// Restore memory
			mstore(sub(_datasetorder, 0x20), temp1)
		}
	}
	function hash(WorkerpoolOrder memory _workerpoolorder)
	public pure returns (bytes32 workerpoolhash)
	{
		/**
		 * Readeable but expensive
		 */
		// return keccak256(abi.encode(
		// 	WORKERPOOLORDER_TYPEHASH
		// , _workerpoolorder.workerpool
		// , _workerpoolorder.workerpoolprice
		// , _workerpoolorder.volume
		// , _workerpoolorder.tag
		// , _workerpoolorder.category
		// , _workerpoolorder.trust
		// , _workerpoolorder.apprestrict
		// , _workerpoolorder.datasetrestrict
		// , _workerpoolorder.requesterrestrict
		// , _workerpoolorder.salt
		// ));

		// Compute sub-hashes
		bytes32 typeHash = WORKERPOOLORDER_TYPEHASH;
		assembly {
			// Back up select memory
			let temp1 := mload(sub(_workerpoolorder, 0x20))
			// Write typeHash and sub-hashes
			mstore(sub(_workerpoolorder, 0x20), typeHash)
			// Compute hash
			workerpoolhash := keccak256(sub(_workerpoolorder, 0x20), 0x160) // 352 = 32 + 320
			// Restore memory
			mstore(sub(_workerpoolorder, 0x20), temp1)
		}
	}
	function hash(RequestOrder memory _requestorder)
	public pure returns (bytes32 requesthash)
	{
		/**
		 * Readeable but expensive
		 */
		//return keccak256(abi.encodePacked(
		//	abi.encode(
		//		REQUESTORDER_TYPEHASH
		//	, _requestorder.app
		//	, _requestorder.appmaxprice
		//	, _requestorder.dataset
		//	, _requestorder.datasetmaxprice
		//	, _requestorder.workerpool
		//	, _requestorder.workerpoolmaxprice
		//	, _requestorder.requester
		//	, _requestorder.volume
		//	, _requestorder.tag
		//	, _requestorder.category
		//	, _requestorder.trust
		//	, _requestorder.beneficiary
		//	, _requestorder.callback
		//	, keccak256(bytes(_requestorder.params))
		//	, _requestorder.salt
		//	)
		//));

		// Compute sub-hashes
		bytes32 typeHash = REQUESTORDER_TYPEHASH;
		bytes32 paramsHash = keccak256(bytes(_requestorder.params));
		assembly {
			// Back up select memory
			let temp1 := mload(sub(_requestorder, 0x020))
			let temp2 := mload(add(_requestorder, 0x1A0))
			// Write typeHash and sub-hashes
			mstore(sub(_requestorder, 0x020), typeHash)
			mstore(add(_requestorder, 0x1A0), paramsHash)
			// Compute hash
			requesthash := keccak256(sub(_requestorder, 0x20), 0x200) // 512 = 32 + 480
			// Restore memory
			mstore(sub(_requestorder, 0x020), temp1)
			mstore(add(_requestorder, 0x1A0), temp2)
		}
	}

	function toEthTypedStructHash(bytes32 _structHash, bytes32 _domainHash)
	public pure returns (bytes32 typedStructHash)
	{
		return keccak256(abi.encodePacked("\x19\x01", _domainHash, _structHash));
	}
}


contract RegistryBase
{

	using SafeMath for uint256;

	/**
	 * Members
	 */
	mapping(address => bool                       ) m_registered;
	mapping(address => mapping(uint256 => address)) m_byOwnerByIndex;
	mapping(address => uint256                    ) m_countByOwner;

	/**
	 * Constructor
	 */
	constructor()
	public
	{
	}

	/**
	 * Accessors
	 */
	function isRegistered(address _entry)
	public view returns (bool)
	{
		return m_registered[_entry];
	}

	function viewEntry(address _owner, uint256 _index)
	public view returns (address)
	{
		return m_byOwnerByIndex[_owner][_index];
	}

	function viewCount(address _owner)
	public view returns (uint256)
	{
		return m_countByOwner[_owner];
	}

	/**
	 * Internal
	 */
	function insert(
		address _entry,
		address _owner)
	internal returns (bool)
	{
		uint id = m_countByOwner[_owner].add(1);
		m_countByOwner  [_owner]     = id;
		m_byOwnerByIndex[_owner][id] = _entry;
		m_registered    [_entry]     = true;
		return true;
	}
}


contract App is Ownable
{
	/**
	 * Members
	 */
	string  public m_appName;
	string  public m_appType;
	bytes   public m_appMultiaddr;
	bytes32 public m_appChecksum;
	bytes   public m_appMREnclave;

	/**
	 * Constructor
	 */
	constructor(
		address        _appOwner,
		string  memory _appName,
		string  memory _appType,
		bytes   memory _appMultiaddr,
		bytes32        _appChecksum,
		bytes   memory _appMREnclave)
	public
	{
		_transferOwnership(_appOwner);
		m_appName      = _appName;
		m_appType      = _appType;
		m_appMultiaddr = _appMultiaddr;
		m_appChecksum  = _appChecksum;
		m_appMREnclave = _appMREnclave;
	}

	function transferOwnership(address) public { revert("disabled"); }

}


contract AppRegistry is RegistryBase //, OwnableMutable // is Owned by IexecHub
{
	event CreateApp(address indexed appOwner, address app);

	/**
	 * Constructor
	 */
	constructor()
	public
	{
	}

	/**
	 * App creation
	 */
	function createApp(
		address          _appOwner,
		string  calldata _appName,
		string  calldata _appType,
		bytes   calldata _appMultiaddr,
		bytes32          _appChecksum,
		bytes   calldata _appMREnclave)
	external /* onlyOwner /*owner == IexecHub*/ returns (App)
	{
		App newApp = new App(
			_appOwner,
			_appName,
			_appType,
			_appMultiaddr,
			_appChecksum,
			_appMREnclave
		);
		require(insert(address(newApp), _appOwner));
		emit CreateApp(_appOwner, address(newApp));
		return newApp;
	}

}


contract Dataset is Ownable
{
	/**
	 * Members
	 */
	string  public m_datasetName;
	bytes   public m_datasetMultiaddr;
	bytes32 public m_datasetChecksum;

	/**
	 * Constructor
	 */
	constructor(
		address        _datasetOwner,
		string  memory _datasetName,
		bytes   memory _datasetMultiaddr,
		bytes32        _datasetChecksum)
	public
	{
		_transferOwnership(_datasetOwner);
		m_datasetName      = _datasetName;
		m_datasetMultiaddr = _datasetMultiaddr;
		m_datasetChecksum  = _datasetChecksum;
	}

	function transferOwnership(address) public { revert("disabled"); }

}


contract DatasetRegistry is RegistryBase //, OwnableMutable // is Owned by IexecHub
{
	event CreateDataset(address indexed datasetOwner, address dataset);

	/**
	 * Constructor
	 */
	constructor()
	public
	{
	}

	/**
	 * Dataset creation
	 */
	function createDataset(
		address          _datasetOwner,
		string  calldata _datasetName,
		bytes   calldata _datasetMultiaddr,
		bytes32          _datasetChecksum)
	external /* onlyOwner /*owner == IexecHub*/ returns (Dataset)
	{
		Dataset newDataset = new Dataset(
			_datasetOwner,
			_datasetName,
			_datasetMultiaddr,
			_datasetChecksum
		);
		require(insert(address(newDataset), _datasetOwner));
		emit CreateDataset(_datasetOwner, address(newDataset));
		return newDataset;
	}
}


contract Workerpool is Ownable
{
	/**
	 * Parameters
	 */
	string  public m_workerpoolDescription;
	uint256 public m_workerStakeRatioPolicy;     // % of reward to stake
	uint256 public m_schedulerRewardRatioPolicy; // % of reward given to scheduler

	/**
	 * Events
	 */
	event PolicyUpdate(
		uint256 oldWorkerStakeRatioPolicy,     uint256 newWorkerStakeRatioPolicy,
		uint256 oldSchedulerRewardRatioPolicy, uint256 newSchedulerRewardRatioPolicy);

	/**
	 * Constructor
	 */
	constructor(
		address        _workerpoolOwner,
		string  memory _workerpoolDescription)
	public
	{
		_transferOwnership(_workerpoolOwner);
		m_workerpoolDescription      = _workerpoolDescription;
		m_workerStakeRatioPolicy     = 30; // mutable
		m_schedulerRewardRatioPolicy = 1;  // mutable
	}

	function changePolicy(
		uint256 _newWorkerStakeRatioPolicy,
		uint256 _newSchedulerRewardRatioPolicy)
	public onlyOwner
	{
		require(_newSchedulerRewardRatioPolicy <= 100);

		emit PolicyUpdate(
			m_workerStakeRatioPolicy,     _newWorkerStakeRatioPolicy,
			m_schedulerRewardRatioPolicy, _newSchedulerRewardRatioPolicy
		);

		m_workerStakeRatioPolicy     = _newWorkerStakeRatioPolicy;
		m_schedulerRewardRatioPolicy = _newSchedulerRewardRatioPolicy;
	}

	function transferOwnership(address) public { revert("disabled"); }

}


contract WorkerpoolRegistry is RegistryBase //, OwnableMutable // is Owned by IexecHub
{
	event CreateWorkerpool(address indexed workerpoolOwner, address indexed workerpool, string workerpoolDescription);

	/**
	 * Constructor
	 */
	constructor()
	public
	{
	}

	/**
	 * Pool creation
	 */
	function createWorkerpool(
		address          _workerpoolOwner,
		string  calldata _workerpoolDescription)
	external /* onlyOwner /*owner == IexecHub*/ returns (Workerpool)
	{
		Workerpool newWorkerpool = new Workerpool(
			_workerpoolOwner,
			_workerpoolDescription
		);
		require(insert(address(newWorkerpool), _workerpoolOwner));
		emit CreateWorkerpool(_workerpoolOwner, address(newWorkerpool), _workerpoolDescription);
		return newWorkerpool;
	}
}



contract CategoryManager is Ownable
{
	/**
	 * Content
	 */
	IexecODBLibCore.Category[] m_categories;

	/**
	 * Event
	 */
	event CreateCategory(
		uint256 catid,
		string  name,
		string  description,
		uint256 workClockTimeRef);

	/**
	 * Constructor
	 */
	constructor()
	public
	{
	}

	/**
	 * Accessors
	 */
	function viewCategory(uint256 _catid)
	external view returns (IexecODBLibCore.Category memory category)
	{
		return m_categories[_catid];
	}

	function countCategory()
	external view returns (uint256 count)
	{
		return m_categories.length;
	}

	/**
	 * Methods
	 */
	function createCategory(
		string  calldata name,
		string  calldata description,
		uint256          workClockTimeRef)
	external onlyOwner returns (uint256)
	{
		uint256 catid = m_categories.push(IexecODBLibCore.Category(
			name,
			description,
			workClockTimeRef
		)) - 1;

		emit CreateCategory(
			catid,
			name,
			description,
			workClockTimeRef
		);
		return catid;
	}
	/**
	 * TODO: move to struct based initialization ?
	 *
	function createCategory(IexecODBLib.Category _category)
	public onlyOwner returns (uint256)
	{
		uint256 catid = m_categories.push(_category);
		emit CreateCategory(
			catid,
			_category.name,
			_category.description,
			_category.workClockTimeRef
		);
		return catid;
	}
	*/

}



contract Escrow
{
	using SafeMath for uint256;

	/**
	* token contract for transfers.
	*/
	IERC20 public token;

	/**
	 * Escrow content
	 */
	mapping(address => IexecODBLibCore.Account) m_accounts;

	/**
	 * Events
	 */
	event Deposit   (address owner, uint256 amount);
	event DepositFor(address owner, uint256 amount, address target);
	event Withdraw  (address owner, uint256 amount);
	event Reward    (address user,  uint256 amount, bytes32 ref);
	event Seize     (address user,  uint256 amount, bytes32 ref);
	event Lock      (address user,  uint256 amount);
	event Unlock    (address user,  uint256 amount);

	/**
	 * Constructor
	 */
	constructor(address _token)
	public
	{
		token = IERC20(_token);
	}

	/**
	 * Accessor
	 */
	function viewAccount(address _user)
	external view returns (IexecODBLibCore.Account memory account)
	{
		return m_accounts[_user];
	}

	/**
	 * Wallet methods: public
	 */
	function deposit(uint256 _amount)
	external returns (bool)
	{
		require(token.transferFrom(msg.sender, address(this), _amount));
		m_accounts[msg.sender].stake = m_accounts[msg.sender].stake.add(_amount);
		emit Deposit(msg.sender, _amount);
		return true;
	}

	function depositFor(uint256 _amount, address _target)
	public returns (bool)
	{
		require(_target != address(0));

		require(token.transferFrom(msg.sender, address(this), _amount));
		m_accounts[_target].stake = m_accounts[_target].stake.add(_amount);
		emit DepositFor(msg.sender, _amount, _target);
		return true;
	}

	function depositForArray(uint256[] calldata _amounts, address[] calldata _targets)
	external returns (bool)
	{
		require(_amounts.length == _targets.length);
		for (uint i = 0; i < _amounts.length; ++i)
		{
			depositFor(_amounts[i], _targets[i]);
		}
		return true;
	}

	function withdraw(uint256 _amount)
	external returns (bool)
	{
		m_accounts[msg.sender].stake = m_accounts[msg.sender].stake.sub(_amount);
		require(token.transfer(msg.sender, _amount));
		emit Withdraw(msg.sender, _amount);
		return true;
	}

	/**
	 * Wallet methods: Internal
	 */
	function reward(address _user, uint256 _amount, bytes32 _reference) internal /* returns (bool) */
	{
		m_accounts[_user].stake = m_accounts[_user].stake.add(_amount);
		emit Reward(_user, _amount, _reference);
		/* return true; */
	}
	function seize(address _user, uint256 _amount, bytes32 _reference) internal /* returns (bool) */
	{
		m_accounts[_user].locked = m_accounts[_user].locked.sub(_amount);
		emit Seize(_user, _amount, _reference);
		/* return true; */
	}
	function lock(address _user, uint256 _amount) internal /* returns (bool) */
	{
		m_accounts[_user].stake  = m_accounts[_user].stake.sub(_amount);
		m_accounts[_user].locked = m_accounts[_user].locked.add(_amount);
		emit Lock(_user, _amount);
		/* return true; */
	}
	function unlock(address _user, uint256 _amount) internal /* returns (bool) */
	{
		m_accounts[_user].locked = m_accounts[_user].locked.sub(_amount);
		m_accounts[_user].stake  = m_accounts[_user].stake.add(_amount);
		emit Unlock(_user, _amount);
		/* return true; */
	}
}


contract Relay
{
	event BroadcastAppOrder       (IexecODBLibOrders.AppOrder        apporder       );
	event BroadcastDatasetOrder   (IexecODBLibOrders.DatasetOrder    datasetorder   );
	event BroadcastWorkerpoolOrder(IexecODBLibOrders.WorkerpoolOrder workerpoolorder);
	event BroadcastRequestOrder   (IexecODBLibOrders.RequestOrder    requestorder   );

	constructor() public {}

	function broadcastAppOrder       (IexecODBLibOrders.AppOrder        memory _apporder       ) public { emit BroadcastAppOrder       (_apporder       ); }
	function broadcastDatasetOrder   (IexecODBLibOrders.DatasetOrder    memory _datasetorder   ) public { emit BroadcastDatasetOrder   (_datasetorder   ); }
	function broadcastWorkerpoolOrder(IexecODBLibOrders.WorkerpoolOrder memory _workerpoolorder) public { emit BroadcastWorkerpoolOrder(_workerpoolorder); }
	function broadcastRequestOrder   (IexecODBLibOrders.RequestOrder    memory _requestorder   ) public { emit BroadcastRequestOrder   (_requestorder   ); }
}


contract SignatureVerifier
{
	function addrToKey(address _addr)
	internal pure returns (bytes32)
	{
		return bytes32(uint256(_addr));
	}

	function checkIdentity(address _identity, address _candidate, uint256 _purpose)
	internal view returns (bool valid)
	{
		return _identity == _candidate || IERC734(_identity).keyHasPurpose(addrToKey(_candidate), _purpose); // Simple address || ERC 734 identity contract
	}

	// internal ?
	function verifySignature(
		address      _identity,
		bytes32      _hash,
		bytes memory _signature)
	public view returns (bool)
	{
		return recoverCheck(_identity, _hash, _signature) || IERC1271(_identity).isValidSignature(_hash, _signature);
	}

	// recoverCheck does not revert if signature has invalid format
	function recoverCheck(address candidate, bytes32 hash, bytes memory sign)
	internal pure returns (bool)
	{
		bytes32 r;
		bytes32 s;
		uint8   v;
		if (sign.length != 65) return false;
		assembly
		{
			r :=         mload(add(sign, 0x20))
			s :=         mload(add(sign, 0x40))
			v := byte(0, mload(add(sign, 0x60)))
		}
		if (v < 27) v += 27;
		if (v != 27 && v != 28) return false;
		return candidate == ecrecover(hash, v, r, s);
	}

	function toEthSignedMessageHash(bytes32 hash)
	internal pure returns (bytes32)
	{
		return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
	}
}

interface IexecHubInterface
{
	function checkResources(address, address, address)
	external view returns (bool);
}


contract IexecHubAccessor
{
	IexecHubInterface public iexechub;

	modifier onlyIexecHub()
	{
		require(msg.sender == address(iexechub));
		_;
	}

	constructor(address _iexechub)
	public
	{
		require(_iexechub != address(0));
		iexechub = IexecHubInterface(_iexechub);
	}

}

contract IexecClerkABILegacy
{
	uint256 public constant POOL_STAKE_RATIO = 30;
	uint256 public constant KITTY_RATIO      = 10;
	uint256 public constant KITTY_MIN        = 1000000000; // TODO: 1RLC ?

	bytes32 public /* immutable */ EIP712DOMAIN_SEPARATOR;

	mapping(bytes32 => bytes32[]) public m_requestdeals;
	mapping(bytes32 => uint256  ) public m_consumed;
	mapping(bytes32 => bool     ) public m_presigned;

	event OrdersMatched        (bytes32 dealid, bytes32 appHash, bytes32 datasetHash, bytes32 workerpoolHash, bytes32 requestHash, uint256 volume);
	event ClosedAppOrder       (bytes32 appHash);
	event ClosedDatasetOrder   (bytes32 datasetHash);
	event ClosedWorkerpoolOrder(bytes32 workerpoolHash);
	event ClosedRequestOrder   (bytes32 requestHash);
	event SchedulerNotice      (address indexed workerpool, bytes32 dealid);

	function viewRequestDeals(bytes32 _id)
	external view returns (bytes32[] memory);

	function viewConsumed(bytes32 _id)
	external view returns (uint256);

	function lockContribution(bytes32 _dealid, address _worker)
	external;

	function unlockContribution(bytes32 _dealid, address _worker)
	external;

	function unlockAndRewardForContribution(bytes32 _dealid, address _worker, uint256 _amount, bytes32 _taskid)
	external;

	function seizeContribution(bytes32 _dealid, address _worker, bytes32 _taskid)
	external;

	function rewardForScheduling(bytes32 _dealid, uint256 _amount, bytes32 _taskid)
	external;

	function successWork(bytes32 _dealid, bytes32 _taskid)
	external;

	function failedWork(bytes32 _dealid, bytes32 _taskid)
	external;




	function viewDealABILegacy_pt1(bytes32 _id)
	external view returns
	( address
	, address
	, uint256
	, address
	, address
	, uint256
	, address
	, address
	, uint256
	);

	function viewDealABILegacy_pt2(bytes32 _id)
	external view returns
	( uint256
	, bytes32
	, address
	, address
	, address
	, string memory
	);

	function viewConfigABILegacy(bytes32 _id)
	external view returns
	( uint256
	, uint256
	, uint256
	, uint256
	, uint256
	, uint256
	);

	function viewAccountABILegacy(address _user)
	external view returns (uint256, uint256);
}



/**
 * /!\ TEMPORARY LEGACY /!\
 */

contract IexecClerk is Escrow, Relay, IexecHubAccessor, SignatureVerifier, IexecClerkABILegacy
{
	using SafeMath          for uint256;
	using IexecODBLibOrders for bytes32;
	using IexecODBLibOrders for IexecODBLibOrders.EIP712Domain;
	using IexecODBLibOrders for IexecODBLibOrders.AppOrder;
	using IexecODBLibOrders for IexecODBLibOrders.DatasetOrder;
	using IexecODBLibOrders for IexecODBLibOrders.WorkerpoolOrder;
	using IexecODBLibOrders for IexecODBLibOrders.RequestOrder;

	/***************************************************************************
	 *                                Constants                                *
	 ***************************************************************************/
	uint256 public constant WORKERPOOL_STAKE_RATIO = 30;
	uint256 public constant KITTY_RATIO            = 10;
	uint256 public constant KITTY_MIN              = 1000000000; // TODO: 1RLC ?

	// For authorizations
	uint256 public constant GROUPMEMBER_PURPOSE    = 4;

	/***************************************************************************
	 *                            EIP712 signature                             *
	 ***************************************************************************/
	bytes32 public /* immutable */ EIP712DOMAIN_SEPARATOR;

	/***************************************************************************
	 *                               Clerk data                                *
	 ***************************************************************************/
	mapping(bytes32 => bytes32[]           ) m_requestdeals;
	mapping(bytes32 => IexecODBLibCore.Deal) m_deals;
	mapping(bytes32 => uint256             ) m_consumed;
	mapping(bytes32 => bool                ) m_presigned;

	/***************************************************************************
	 *                                 Events                                  *
	 ***************************************************************************/
	event OrdersMatched        (bytes32 dealid, bytes32 appHash, bytes32 datasetHash, bytes32 workerpoolHash, bytes32 requestHash, uint256 volume);
	event ClosedAppOrder       (bytes32 appHash);
	event ClosedDatasetOrder   (bytes32 datasetHash);
	event ClosedWorkerpoolOrder(bytes32 workerpoolHash);
	event ClosedRequestOrder   (bytes32 requestHash);
	event SchedulerNotice      (address indexed workerpool, bytes32 dealid);

	/***************************************************************************
	 *                               Constructor                               *
	 ***************************************************************************/
	constructor(
		address _token,
		address _iexechub,
		uint256 _chainid)
	public
	Escrow(_token)
	IexecHubAccessor(_iexechub)
	{
		EIP712DOMAIN_SEPARATOR = IexecODBLibOrders.EIP712Domain({
			name:              "iExecODB"
		, version:           "3.0-alpha"
		, chainId:           _chainid
		, verifyingContract: address(this)
		}).hash();
	}

	/***************************************************************************
	 *                                Accessor                                 *
	 ***************************************************************************/
	function viewRequestDeals(bytes32 _id)
	external view returns (bytes32[] memory requestdeals)
	{
		return m_requestdeals[_id];
	}

	function viewDeal(bytes32 _id)
	external view returns (IexecODBLibCore.Deal memory deal)
	{
		return m_deals[_id];
	}

	function viewConsumed(bytes32 _id)
	external view returns (uint256 consumed)
	{
		return m_consumed[_id];
	}

	function viewPresigned(bytes32 _id)
	external view returns (bool presigned)
	{
		return m_presigned[_id];
	}

	/***************************************************************************
	 *                            pre-signing tools                            *
	 ***************************************************************************/
	// should be external
	function signAppOrder(IexecODBLibOrders.AppOrder memory _apporder)
	public returns (bool)
	{
		require(msg.sender == App(_apporder.app).owner());
		m_presigned[_apporder.hash().toEthTypedStructHash(EIP712DOMAIN_SEPARATOR)] = true;
		return true;
	}

	// should be external
	function signDatasetOrder(IexecODBLibOrders.DatasetOrder memory _datasetorder)
	public returns (bool)
	{
		require(msg.sender == Dataset(_datasetorder.dataset).owner());
		m_presigned[_datasetorder.hash().toEthTypedStructHash(EIP712DOMAIN_SEPARATOR)] = true;
		return true;
	}

	// should be external
	function signWorkerpoolOrder(IexecODBLibOrders.WorkerpoolOrder memory _workerpoolorder)
	public returns (bool)
	{
		require(msg.sender == Workerpool(_workerpoolorder.workerpool).owner());
		m_presigned[_workerpoolorder.hash().toEthTypedStructHash(EIP712DOMAIN_SEPARATOR)] = true;
		return true;
	}

	// should be external
	function signRequestOrder(IexecODBLibOrders.RequestOrder memory _requestorder)
	public returns (bool)
	{
		require(msg.sender == _requestorder.requester);
		m_presigned[_requestorder.hash().toEthTypedStructHash(EIP712DOMAIN_SEPARATOR)] = true;
		return true;
	}

	/***************************************************************************
	 *                              Clerk methods                              *
	 ***************************************************************************/
	struct Identities
	{
		bytes32 appHash;
		address appOwner;
		bytes32 datasetHash;
		address datasetOwner;
		bytes32 workerpoolHash;
		address workerpoolOwner;
		bytes32 requestHash;
		bool    hasDataset;
	}

	// should be external
	function matchOrders(
		IexecODBLibOrders.AppOrder        memory _apporder,
		IexecODBLibOrders.DatasetOrder    memory _datasetorder,
		IexecODBLibOrders.WorkerpoolOrder memory _workerpoolorder,
		IexecODBLibOrders.RequestOrder    memory _requestorder)
	public returns (bytes32)
	{
		/**
		 * Check orders compatibility
		 */

		// computation environment & allowed enough funds
		require(_requestorder.category           == _workerpoolorder.category       );
		require(_requestorder.trust              <= _workerpoolorder.trust          );
		require(_requestorder.appmaxprice        >= _apporder.appprice              );
		require(_requestorder.datasetmaxprice    >= _datasetorder.datasetprice      );
		require(_requestorder.workerpoolmaxprice >= _workerpoolorder.workerpoolprice);
		require((_apporder.tag | _datasetorder.tag | _requestorder.tag) & ~_workerpoolorder.tag == 0x0);

		// Check matching and restrictions
		require(_requestorder.app     == _apporder.app        );
		require(_requestorder.dataset == _datasetorder.dataset);
		require(_requestorder.workerpool           == address(0) || checkIdentity(_requestorder.workerpool,           _workerpoolorder.workerpool, GROUPMEMBER_PURPOSE)); // requestorder.workerpool is a restriction
		require(_apporder.datasetrestrict          == address(0) || checkIdentity(_apporder.datasetrestrict,          _datasetorder.dataset,       GROUPMEMBER_PURPOSE));
		require(_apporder.workerpoolrestrict       == address(0) || checkIdentity(_apporder.workerpoolrestrict,       _workerpoolorder.workerpool, GROUPMEMBER_PURPOSE));
		require(_apporder.requesterrestrict        == address(0) || checkIdentity(_apporder.requesterrestrict,        _requestorder.requester,     GROUPMEMBER_PURPOSE));
		require(_datasetorder.apprestrict          == address(0) || checkIdentity(_datasetorder.apprestrict,          _apporder.app,               GROUPMEMBER_PURPOSE));
		require(_datasetorder.workerpoolrestrict   == address(0) || checkIdentity(_datasetorder.workerpoolrestrict,   _workerpoolorder.workerpool, GROUPMEMBER_PURPOSE));
		require(_datasetorder.requesterrestrict    == address(0) || checkIdentity(_datasetorder.requesterrestrict,    _requestorder.requester,     GROUPMEMBER_PURPOSE));
		require(_workerpoolorder.apprestrict       == address(0) || checkIdentity(_workerpoolorder.apprestrict,       _apporder.app,               GROUPMEMBER_PURPOSE));
		require(_workerpoolorder.datasetrestrict   == address(0) || checkIdentity(_workerpoolorder.datasetrestrict,   _datasetorder.dataset,       GROUPMEMBER_PURPOSE));
		require(_workerpoolorder.requesterrestrict == address(0) || checkIdentity(_workerpoolorder.requesterrestrict, _requestorder.requester,     GROUPMEMBER_PURPOSE));

		require(iexechub.checkResources(_apporder.app, _datasetorder.dataset, _workerpoolorder.workerpool));

		/**
		 * Check orders authenticity
		 */
		Identities memory ids;
		ids.hasDataset = _datasetorder.dataset != address(0);

		// app
		ids.appHash  = _apporder.hash().toEthTypedStructHash(EIP712DOMAIN_SEPARATOR);
		ids.appOwner = App(_apporder.app).owner();
		require(m_presigned[ids.appHash] || verifySignature(ids.appOwner, ids.appHash, _apporder.sign));

		// dataset
		if (ids.hasDataset) // only check if dataset is enabled
		{
			ids.datasetHash  = _datasetorder.hash().toEthTypedStructHash(EIP712DOMAIN_SEPARATOR);
			ids.datasetOwner = Dataset(_datasetorder.dataset).owner();
			require(m_presigned[ids.datasetHash] || verifySignature(ids.datasetOwner, ids.datasetHash, _datasetorder.sign));
		}

		// workerpool
		ids.workerpoolHash  = _workerpoolorder.hash().toEthTypedStructHash(EIP712DOMAIN_SEPARATOR);
		ids.workerpoolOwner = Workerpool(_workerpoolorder.workerpool).owner();
		require(m_presigned[ids.workerpoolHash] || verifySignature(ids.workerpoolOwner, ids.workerpoolHash, _workerpoolorder.sign));

		// request
		ids.requestHash = _requestorder.hash().toEthTypedStructHash(EIP712DOMAIN_SEPARATOR);
		require(m_presigned[ids.requestHash] || verifySignature(_requestorder.requester, ids.requestHash, _requestorder.sign));

		/**
		 * Check availability
		 */
		uint256 volume;
		volume =                             _apporder.volume.sub       (m_consumed[ids.appHash       ]);
		volume = ids.hasDataset ? volume.min(_datasetorder.volume.sub   (m_consumed[ids.datasetHash   ])) : volume;
		volume =                  volume.min(_workerpoolorder.volume.sub(m_consumed[ids.workerpoolHash]));
		volume =                  volume.min(_requestorder.volume.sub   (m_consumed[ids.requestHash   ]));
		require(volume > 0);

		/**
		 * Record
		 */
		bytes32 dealid = keccak256(abi.encodePacked(
			ids.requestHash,            // requestHash
			m_consumed[ids.requestHash] // idx of first subtask
		));

		IexecODBLibCore.Deal storage deal = m_deals[dealid];
		deal.app.pointer          = _apporder.app;
		deal.app.owner            = ids.appOwner;
		deal.app.price            = _apporder.appprice;
		deal.dataset.owner        = ids.datasetOwner;
		deal.dataset.pointer      = _datasetorder.dataset;
		deal.dataset.price        = ids.hasDataset ? _datasetorder.datasetprice : 0;
		deal.workerpool.pointer   = _workerpoolorder.workerpool;
		deal.workerpool.owner     = ids.workerpoolOwner;
		deal.workerpool.price     = _workerpoolorder.workerpoolprice;
		deal.trust                = _requestorder.trust.max(1);
		deal.category             = _requestorder.category;
		deal.tag                  = _apporder.tag | _datasetorder.tag | _requestorder.tag;
		deal.requester            = _requestorder.requester;
		deal.beneficiary          = _requestorder.beneficiary;
		deal.callback             = _requestorder.callback;
		deal.params               = _requestorder.params;
		deal.startTime            = now;
		deal.botFirst             = m_consumed[ids.requestHash];
		deal.botSize              = volume;
		deal.workerStake          = _workerpoolorder.workerpoolprice.percentage(Workerpool(_workerpoolorder.workerpool).m_workerStakeRatioPolicy());
		deal.schedulerRewardRatio = Workerpool(_workerpoolorder.workerpool).m_schedulerRewardRatioPolicy();

		m_requestdeals[ids.requestHash].push(dealid);

		/**
		 * Update consumed
		 */
		m_consumed[ids.appHash       ] = m_consumed[ids.appHash       ].add(                 volume    );
		m_consumed[ids.datasetHash   ] = m_consumed[ids.datasetHash   ].add(ids.hasDataset ? volume : 0);
		m_consumed[ids.workerpoolHash] = m_consumed[ids.workerpoolHash].add(                 volume    );
		m_consumed[ids.requestHash   ] = m_consumed[ids.requestHash   ].add(                 volume    );

		/**
		 * Lock
		 */
		lock(
			deal.requester,
			deal.app.price
			.add(deal.dataset.price)
			.add(deal.workerpool.price)
			.mul(volume)
		);
		lock(
			deal.workerpool.owner,
			deal.workerpool.price
			.percentage(WORKERPOOL_STAKE_RATIO) // ORDER IS IMPORTANT HERE!
			.mul(volume)                        // ORDER IS IMPORTANT HERE!
		);

		/**
		 * Advertize deal
		 */
		emit SchedulerNotice(deal.workerpool.pointer, dealid);

		/**
		 * Advertize consumption
		 */
		emit OrdersMatched(
			dealid,
			ids.appHash,
			ids.datasetHash,
			ids.workerpoolHash,
			ids.requestHash,
			volume
		);

		return dealid;
	}

	// should be external
	function cancelAppOrder(IexecODBLibOrders.AppOrder memory _apporder)
	public returns (bool)
	{
		bytes32 dapporderHash = _apporder.hash().toEthTypedStructHash(EIP712DOMAIN_SEPARATOR);
		require(msg.sender == App(_apporder.app).owner());
		m_consumed[dapporderHash] = _apporder.volume;
		emit ClosedAppOrder(dapporderHash);
		return true;
	}

	// should be external
	function cancelDatasetOrder(IexecODBLibOrders.DatasetOrder memory _datasetorder)
	public returns (bool)
	{
		bytes32 dataorderHash = _datasetorder.hash().toEthTypedStructHash(EIP712DOMAIN_SEPARATOR);
		require(msg.sender == Dataset(_datasetorder.dataset).owner());
		m_consumed[dataorderHash] = _datasetorder.volume;
		emit ClosedDatasetOrder(dataorderHash);
		return true;
	}

	// should be external
	function cancelWorkerpoolOrder(IexecODBLibOrders.WorkerpoolOrder memory _workerpoolorder)
	public returns (bool)
	{
		bytes32 poolorderHash = _workerpoolorder.hash().toEthTypedStructHash(EIP712DOMAIN_SEPARATOR);
		require(msg.sender == Workerpool(_workerpoolorder.workerpool).owner());
		m_consumed[poolorderHash] = _workerpoolorder.volume;
		emit ClosedWorkerpoolOrder(poolorderHash);
		return true;
	}

	// should be external
	function cancelRequestOrder(IexecODBLibOrders.RequestOrder memory _requestorder)
	public returns (bool)
	{
		bytes32 requestorderHash = _requestorder.hash().toEthTypedStructHash(EIP712DOMAIN_SEPARATOR);
		require(msg.sender == _requestorder.requester);
		m_consumed[requestorderHash] = _requestorder.volume;
		emit ClosedRequestOrder(requestorderHash);
		return true;
	}

	/***************************************************************************
	 *                    Escrow overhead for contribution                     *
	 ***************************************************************************/
	function lockContribution(bytes32 _dealid, address _worker)
	external onlyIexecHub
	{
		lock(_worker, m_deals[_dealid].workerStake);
	}

	function unlockContribution(bytes32 _dealid, address _worker)
	external onlyIexecHub
	{
		unlock(_worker, m_deals[_dealid].workerStake);
	}

	function unlockAndRewardForContribution(bytes32 _dealid, address _worker, uint256 _amount, bytes32 _taskid)
	external onlyIexecHub
	{
		unlock(_worker, m_deals[_dealid].workerStake);
		reward(_worker, _amount, _taskid);
	}

	function seizeContribution(bytes32 _dealid, address _worker, bytes32 _taskid)
	external onlyIexecHub
	{
		seize(_worker, m_deals[_dealid].workerStake, _taskid);
	}

	function rewardForScheduling(bytes32 _dealid, uint256 _amount, bytes32 _taskid)
	external onlyIexecHub
	{
		reward(m_deals[_dealid].workerpool.owner, _amount, _taskid);
	}

	function successWork(bytes32 _dealid, bytes32 _taskid)
	external onlyIexecHub
	{
		IexecODBLibCore.Deal storage deal = m_deals[_dealid];

		uint256 requesterstake = deal.app.price
		                         .add(deal.dataset.price)
		                         .add(deal.workerpool.price);
		uint256 poolstake = deal.workerpool.price
		                    .percentage(WORKERPOOL_STAKE_RATIO);

		// seize requester funds
		seize(deal.requester, requesterstake, _taskid);
		// dapp reward
		if (deal.app.price > 0)
		{
			reward(deal.app.owner, deal.app.price, _taskid);
		}
		// data reward
		if (deal.dataset.price > 0 && deal.dataset.pointer != address(0))
		{
			reward(deal.dataset.owner, deal.dataset.price, _taskid);
		}
		// unlock pool stake
		unlock(deal.workerpool.owner, poolstake);
		// pool reward performed by consensus manager

		/**
		 * Retrieve part of the kitty
		 * TODO: remove / keep ?
		 */
		uint256 kitty = m_accounts[address(0)].locked;
		if (kitty > 0)
		{
			kitty = kitty
			        .percentage(KITTY_RATIO) // fraction
			        .max(KITTY_MIN)          // at least this
			        .min(kitty);             // but not more than available
			seize (address(0),            kitty, _taskid);
			reward(deal.workerpool.owner, kitty, _taskid);
		}
	}

	function failedWork(bytes32 _dealid, bytes32 _taskid)
	external onlyIexecHub
	{
		IexecODBLibCore.Deal storage deal = m_deals[_dealid];

		uint256 requesterstake = deal.app.price
		                         .add(deal.dataset.price)
		                         .add(deal.workerpool.price);
		uint256 poolstake = deal.workerpool.price
		                    .percentage(WORKERPOOL_STAKE_RATIO);

		unlock(deal.requester,        requesterstake    );
		seize (deal.workerpool.owner, poolstake, _taskid);
		reward(address(0),            poolstake, _taskid); // → Kitty / Burn
		lock  (address(0),            poolstake         ); // → Kitty / Burn
	}


















	/**
	 * /!\ TEMPORARY LEGACY /!\
	 */

	function viewDealABILegacy_pt1(bytes32 _id)
	external view returns
	( address
	, address
	, uint256
	, address
	, address
	, uint256
	, address
	, address
	, uint256
	)
	{
		IexecODBLibCore.Deal memory deal = m_deals[_id];
		return (
			deal.app.pointer,
			deal.app.owner,
			deal.app.price,
			deal.dataset.pointer,
			deal.dataset.owner,
			deal.dataset.price,
			deal.workerpool.pointer,
			deal.workerpool.owner,
			deal.workerpool.price
		);
	}

	function viewDealABILegacy_pt2(bytes32 _id)
	external view returns
	( uint256
	, bytes32
	, address
	, address
	, address
	, string memory
	)
	{
		IexecODBLibCore.Deal memory deal = m_deals[_id];
		return (
			deal.trust,
			deal.tag,
			deal.requester,
			deal.beneficiary,
			deal.callback,
			deal.params
		);
	}

	function viewConfigABILegacy(bytes32 _id)
	external view returns
	( uint256
	, uint256
	, uint256
	, uint256
	, uint256
	, uint256
	)
	{
		IexecODBLibCore.Deal memory deal = m_deals[_id];
		return (
			deal.category,
			deal.startTime,
			deal.botFirst,
			deal.botSize,
			deal.workerStake,
			deal.schedulerRewardRatio
		);
	}

	function viewAccountABILegacy(address _user)
	external view returns (uint256, uint256)
	{
		IexecODBLibCore.Account memory account = m_accounts[_user];
		return ( account.stake, account.locked );
	}
}



contract IexecHubABILegacy
{
	uint256 public constant CONSENSUS_DURATION_RATIO = 10;
	uint256 public constant REVEAL_DURATION_RATIO    = 2;

	IexecClerk   public iexecclerk;
	RegistryBase public appregistry;
	RegistryBase public datasetregistry;
	RegistryBase public workerpoolregistry;

	event TaskInitialize(bytes32 indexed taskid, address indexed workerpool               );
	event TaskContribute(bytes32 indexed taskid, address indexed worker, bytes32 hash     );
	event TaskConsensus (bytes32 indexed taskid,                         bytes32 consensus);
	event TaskReveal    (bytes32 indexed taskid, address indexed worker, bytes32 digest   );
	event TaskReopen    (bytes32 indexed taskid                                           );
	event TaskFinalize  (bytes32 indexed taskid,                         bytes   results  );
	event TaskClaimed   (bytes32 indexed taskid                                           );

	event AccurateContribution(address indexed worker, bytes32 indexed taskid);
	event FaultyContribution  (address indexed worker, bytes32 indexed taskid);

	function attachContracts(
		address _iexecclerkAddress,
		address _appregistryAddress,
		address _datasetregistryAddress,
		address _workerpoolregistryAddress)
	external;

	function viewScore(address _worker)
	external view returns (uint256);

	function checkResources(address aap, address dataset, address workerpool)
	external view returns (bool);

	function resultFor(bytes32 id)
	external view returns (bytes memory);

	function initialize(
		bytes32 _dealid,
		uint256 idx)
	public returns (bytes32);

	function contribute(
		bytes32      _taskid,
		bytes32      _resultHash,
		bytes32      _resultSeal,
		address      _enclaveChallenge,
		bytes memory _enclaveSign,
		bytes memory _workerpoolSign)
	public;

	function reveal(
		bytes32 _taskid,
		bytes32 _resultDigest)
	external;

	function reopen(
		bytes32 _taskid)
	external;

	function finalize(
		bytes32 _taskid,
		bytes calldata  _results)
	external;

	function claim(
		bytes32 _taskid)
	public;

	function initializeArray(
		bytes32[] calldata _dealid,
		uint256[] calldata _idx)
	external returns (bool);

	function claimArray(
		bytes32[] calldata _taskid)
	external returns (bool);

	function initializeAndClaimArray(
		bytes32[] calldata _dealid,
		uint256[] calldata _idx)
	external returns (bool);

	function viewTaskABILegacy(bytes32 _taskid)
	external view returns
	( IexecODBLibCore.TaskStatusEnum
	, bytes32
	, uint256
	, uint256
	, uint256
	, uint256
	, uint256
	, bytes32
	, uint256
	, uint256
	, address[] memory
	, bytes     memory
	);

	function viewContributionABILegacy(bytes32 _taskid, address _worker)
	external view returns
	( IexecODBLibCore.ContributionStatusEnum
	, bytes32
	, bytes32
	, address
	);

	function viewCategoryABILegacy(uint256 _catid)
	external view returns (string memory, string memory, uint256);
}



/**
 * /!\ TEMPORARY LEGACY /!\
 */

contract IexecHub is CategoryManager, IOracle, SignatureVerifier, IexecHubABILegacy
{
	using SafeMath for uint256;

	/***************************************************************************
	 *                                Constants                                *
	 ***************************************************************************/
	uint256 public constant CONTRIBUTION_DEADLINE_RATIO = 7;
	uint256 public constant       REVEAL_DEADLINE_RATIO = 2;
	uint256 public constant        FINAL_DEADLINE_RATIO = 10;

	/***************************************************************************
	 *                             Other contracts                             *
	 ***************************************************************************/
	IexecClerk   public iexecclerk;
	RegistryBase public appregistry;
	RegistryBase public datasetregistry;
	RegistryBase public workerpoolregistry;

	/***************************************************************************
	 *                          Consensuses & Workers                          *
	 ***************************************************************************/
	mapping(bytes32 =>                    IexecODBLibCore.Task         ) m_tasks;
	mapping(bytes32 => mapping(address => IexecODBLibCore.Contribution)) m_contributions;
	mapping(address =>                    uint256                      ) m_workerScores;

	mapping(bytes32 => mapping(address => uint256                     )) m_logweight;
	mapping(bytes32 => mapping(bytes32 => uint256                     )) m_groupweight;
	mapping(bytes32 =>                    uint256                      ) m_totalweight;

	/***************************************************************************
	 *                                 Events                                  *
	 ***************************************************************************/
	event TaskInitialize(bytes32 indexed taskid, address indexed workerpool               );
	event TaskContribute(bytes32 indexed taskid, address indexed worker, bytes32 hash     );
	event TaskConsensus (bytes32 indexed taskid,                         bytes32 consensus);
	event TaskReveal    (bytes32 indexed taskid, address indexed worker, bytes32 digest   );
	event TaskReopen    (bytes32 indexed taskid                                           );
	event TaskFinalize  (bytes32 indexed taskid,                         bytes results    );
	event TaskClaimed   (bytes32 indexed taskid                                           );

	event AccurateContribution(address indexed worker, bytes32 indexed taskid);
	event FaultyContribution  (address indexed worker, bytes32 indexed taskid);

	/***************************************************************************
	 *                                Modifiers                                *
	 ***************************************************************************/
	modifier onlyScheduler(bytes32 _taskid)
	{
		require(msg.sender == iexecclerk.viewDeal(m_tasks[_taskid].dealid).workerpool.owner);
		_;
	}

	/***************************************************************************
	 *                               Constructor                               *
	 ***************************************************************************/
	constructor()
	public
	{
	}

	function attachContracts(
		address _iexecclerkAddress,
		address _appregistryAddress,
		address _datasetregistryAddress,
		address _workerpoolregistryAddress)
	external onlyOwner
	{
		require(address(iexecclerk) == address(0));
		iexecclerk         = IexecClerk  (_iexecclerkAddress  );
		appregistry        = RegistryBase(_appregistryAddress);
		datasetregistry    = RegistryBase(_datasetregistryAddress);
		workerpoolregistry = RegistryBase(_workerpoolregistryAddress);
	}

	/***************************************************************************
	 *                                Accessors                                *
	 ***************************************************************************/
	function viewTask(bytes32 _taskid)
	external view returns (IexecODBLibCore.Task memory)
	{
		return m_tasks[_taskid];
	}

	function viewContribution(bytes32 _taskid, address _worker)
	external view returns (IexecODBLibCore.Contribution memory)
	{
		return m_contributions[_taskid][_worker];
	}

	function viewScore(address _worker)
	external view returns (uint256)
	{
		return m_workerScores[_worker];
	}

	function checkResources(address app, address dataset, address workerpool)
	external view returns (bool)
	{
		require(                         appregistry.isRegistered(app));
		require(dataset == address(0) || datasetregistry.isRegistered(dataset));
		require(                         workerpoolregistry.isRegistered(workerpool));
		return true;
	}

	/***************************************************************************
	 *                         EIP 1154 PULL INTERFACE                         *
	 ***************************************************************************/
	function resultFor(bytes32 id)
	external view returns (bytes memory)
	{
		IexecODBLibCore.Task storage task = m_tasks[id];
		require(task.status == IexecODBLibCore.TaskStatusEnum.COMPLETED);
		return task.results;
	}

	/***************************************************************************
	 *                            Consensus methods                            *
	 ***************************************************************************/
	function initialize(bytes32 _dealid, uint256 idx)
	public returns (bytes32)
	{
		IexecODBLibCore.Deal memory deal = iexecclerk.viewDeal(_dealid);

		require(idx >= deal.botFirst                  );
		require(idx <  deal.botFirst.add(deal.botSize));

		bytes32 taskid  = keccak256(abi.encodePacked(_dealid, idx));
		IexecODBLibCore.Task storage task = m_tasks[taskid];
		require(task.status == IexecODBLibCore.TaskStatusEnum.UNSET);

		task.status               = IexecODBLibCore.TaskStatusEnum.ACTIVE;
		task.dealid               = _dealid;
		task.idx                  = idx;
		task.timeref              = m_categories[deal.category].workClockTimeRef;
		task.contributionDeadline = task.timeref.mul(CONTRIBUTION_DEADLINE_RATIO).add(deal.startTime);
		task.finalDeadline        = task.timeref.mul(       FINAL_DEADLINE_RATIO).add(deal.startTime);

		// setup denominator
		m_totalweight[taskid] = 1;

		emit TaskInitialize(taskid, iexecclerk.viewDeal(_dealid).workerpool.pointer);

		return taskid;
	}

	// TODO: make external w/ calldata
	function contribute(
		bytes32      _taskid,
		bytes32      _resultHash,
		bytes32      _resultSeal,
		address      _enclaveChallenge,
		bytes memory _enclaveSign,
		bytes memory _workerpoolSign)
	public
	{
		IexecODBLibCore.Task         storage task         = m_tasks[_taskid];
		IexecODBLibCore.Contribution storage contribution = m_contributions[_taskid][msg.sender];
		IexecODBLibCore.Deal         memory  deal         = iexecclerk.viewDeal(task.dealid);

		require(task.status               == IexecODBLibCore.TaskStatusEnum.ACTIVE       );
		require(task.contributionDeadline >  now                                         );
		require(contribution.status       == IexecODBLibCore.ContributionStatusEnum.UNSET);

		// Check that the worker + taskid + enclave combo is authorized to contribute (scheduler signature)
		require(verifySignature(
			deal.workerpool.owner,
			toEthSignedMessageHash(
				keccak256(abi.encodePacked(
					msg.sender,
					_taskid,
					_enclaveChallenge
				))
			),
			_workerpoolSign
		));

		// need enclave challenge if tag is set
		require(_enclaveChallenge != address(0) || (deal.tag[31] & 0x01 == 0));

		// Check enclave signature
		require(_enclaveChallenge == address(0) || verifySignature(
			_enclaveChallenge,
			toEthSignedMessageHash(
				keccak256(abi.encodePacked(
					_resultHash,
					_resultSeal
				))
			),
			_enclaveSign
		));

		// Update contribution entry
		contribution.status           = IexecODBLibCore.ContributionStatusEnum.CONTRIBUTED;
		contribution.resultHash       = _resultHash;
		contribution.resultSeal       = _resultSeal;
		contribution.enclaveChallenge = _enclaveChallenge;
		task.contributors.push(msg.sender);

		iexecclerk.lockContribution(task.dealid, msg.sender);

		emit TaskContribute(_taskid, msg.sender, _resultHash);

		// Contribution done → updating and checking concensus

		/*************************************************************************
		 *                           SCORE POLICY 1/3                            *
		 *                                                                       *
		 *                          see documentation!                           *
		 *************************************************************************/
		// k = 3
		uint256 weight = m_workerScores[msg.sender].div(3).max(3).sub(1);
		uint256 group  = m_groupweight[_taskid][_resultHash];
		uint256 delta  = group.max(1).mul(weight).sub(group);

		m_logweight  [_taskid][msg.sender ] = weight.log();
		m_groupweight[_taskid][_resultHash] = m_groupweight[_taskid][_resultHash].add(delta);
		m_totalweight[_taskid]              = m_totalweight[_taskid].add(delta);

		// Check consensus
		checkConsensus(_taskid, _resultHash);
	}
	function checkConsensus(
		bytes32 _taskid,
		bytes32 _consensus)
	private
	{
		uint256 trust = iexecclerk.viewDeal(m_tasks[_taskid].dealid).trust;
		if (m_groupweight[_taskid][_consensus].mul(trust) > m_totalweight[_taskid].mul(trust.sub(1)))
		{
			// Preliminary checks done in "contribute()"

			IexecODBLibCore.Task storage task = m_tasks[_taskid];
			uint256 winnerCounter = 0;
			for (uint256 i = 0; i < task.contributors.length; ++i)
			{
				address w = task.contributors[i];
				if
				(
					m_contributions[_taskid][w].resultHash == _consensus
					&&
					m_contributions[_taskid][w].status == IexecODBLibCore.ContributionStatusEnum.CONTRIBUTED // REJECTED contribution must not be count
				)
				{
					winnerCounter = winnerCounter.add(1);
				}
			}
			// msg.sender is a contributor: no need to check
			// require(winnerCounter > 0);
			task.status         = IexecODBLibCore.TaskStatusEnum.REVEALING;
			task.consensusValue = _consensus;
			task.revealDeadline = task.timeref.mul(REVEAL_DEADLINE_RATIO).add(now);
			task.revealCounter  = 0;
			task.winnerCounter  = winnerCounter;

			emit TaskConsensus(_taskid, _consensus);
		}
	}

	function reveal(
		bytes32 _taskid,
		bytes32 _resultDigest)
	external // worker
	{
		IexecODBLibCore.Task         storage task         = m_tasks[_taskid];
		IexecODBLibCore.Contribution storage contribution = m_contributions[_taskid][msg.sender];
		require(task.status             == IexecODBLibCore.TaskStatusEnum.REVEALING                       );
		require(task.revealDeadline     >  now                                                            );
		require(contribution.status     == IexecODBLibCore.ContributionStatusEnum.CONTRIBUTED             );
		require(contribution.resultHash == task.consensusValue                                            );
		require(contribution.resultHash == keccak256(abi.encodePacked(            _taskid, _resultDigest)));
		require(contribution.resultSeal == keccak256(abi.encodePacked(msg.sender, _taskid, _resultDigest)));

		contribution.status = IexecODBLibCore.ContributionStatusEnum.PROVED;
		task.revealCounter  = task.revealCounter.add(1);
		task.resultDigest   = _resultDigest;

		emit TaskReveal(_taskid, msg.sender, _resultDigest);
	}

	function reopen(
		bytes32 _taskid)
	external onlyScheduler(_taskid)
	{
		IexecODBLibCore.Task storage task = m_tasks[_taskid];
		require(task.status         == IexecODBLibCore.TaskStatusEnum.REVEALING);
		require(task.finalDeadline  >  now                                     );
		require(task.revealDeadline <= now
		     && task.revealCounter  == 0                                       );

		for (uint256 i = 0; i < task.contributors.length; ++i)
		{
			address worker = task.contributors[i];
			if (m_contributions[_taskid][worker].resultHash == task.consensusValue)
			{
				m_contributions[_taskid][worker].status = IexecODBLibCore.ContributionStatusEnum.REJECTED;
			}
		}

		m_totalweight[_taskid]                      = m_totalweight[_taskid].sub(m_groupweight[_taskid][task.consensusValue]);
		m_groupweight[_taskid][task.consensusValue] = 0;

		task.status         = IexecODBLibCore.TaskStatusEnum.ACTIVE;
		task.consensusValue = 0x0;
		task.revealDeadline = 0;
		task.winnerCounter  = 0;

		emit TaskReopen(_taskid);
	}

	function finalize(
		bytes32          _taskid,
		bytes   calldata _results)
	external onlyScheduler(_taskid)
	{
		IexecODBLibCore.Task storage task = m_tasks[_taskid];
		require(task.status        == IexecODBLibCore.TaskStatusEnum.REVEALING);
		require(task.finalDeadline >  now                                     );
		require(task.revealCounter == task.winnerCounter
		    || (task.revealCounter >  0  && task.revealDeadline <= now)       );

		task.status  = IexecODBLibCore.TaskStatusEnum.COMPLETED;
		task.results = _results;

		/**
		 * Stake and reward management
		 */
		iexecclerk.successWork(task.dealid, _taskid);
		distributeRewards(_taskid);

		/**
		 * Event
		 */
		emit TaskFinalize(_taskid, _results);

		/**
		 * Callback for smartcontracts using EIP1154
		 */
		address callbackTarget = iexecclerk.viewDeal(task.dealid).callback;
		if (callbackTarget != address(0))
		{
			/**
			 * Call does not revert if the target smart contract is incompatible or reverts
			 *
			 * ATTENTION!
			 * This call is dangerous and target smart contract can charge the stack.
			 * Assume invalid state after the call.
			 * See: https://solidity.readthedocs.io/en/develop/types.html#members-of-addresses
			 *
			 * TODO: gas provided?
			 */
			require(gasleft() > 100000);
			bool success;
			(success,) = callbackTarget.call.gas(100000)(abi.encodeWithSignature(
				"receiveResult(bytes32,bytes)",
				_taskid,
				_results
			));
		}
	}

	function distributeRewards(bytes32 _taskid)
	private
	{
		IexecODBLibCore.Task storage task = m_tasks[_taskid];
		IexecODBLibCore.Deal memory  deal = iexecclerk.viewDeal(task.dealid);

		uint256 i;
		address worker;

		uint256 totalLogWeight = 0;
		uint256 totalReward = iexecclerk.viewDeal(task.dealid).workerpool.price;

		for (i = 0; i < task.contributors.length; ++i)
		{
			worker = task.contributors[i];
			if (m_contributions[_taskid][worker].status == IexecODBLibCore.ContributionStatusEnum.PROVED)
			{
				totalLogWeight = totalLogWeight.add(m_logweight[_taskid][worker]);
			}
			else // ContributionStatusEnum.REJECT or ContributionStatusEnum.CONTRIBUTED (not revealed)
			{
				totalReward = totalReward.add(deal.workerStake);
			}
		}
		require(totalLogWeight > 0);

		// compute how much is going to the workers
		uint256 workersReward = totalReward.percentage(uint256(100).sub(deal.schedulerRewardRatio));

		for (i = 0; i < task.contributors.length; ++i)
		{
			worker = task.contributors[i];
			if (m_contributions[_taskid][worker].status == IexecODBLibCore.ContributionStatusEnum.PROVED)
			{
				uint256 workerReward = workersReward.mulByFraction(m_logweight[_taskid][worker], totalLogWeight);
				totalReward          = totalReward.sub(workerReward);

				iexecclerk.unlockAndRewardForContribution(task.dealid, worker, workerReward, _taskid);

				// Only reward if replication happened
				if (task.contributors.length > 1)
				{
					/*******************************************************************
					 *                        SCORE POLICY 2/3                         *
					 *                                                                 *
					 *                       see documentation!                        *
					 *******************************************************************/
					m_workerScores[worker] = m_workerScores[worker].add(1);
					emit AccurateContribution(worker, _taskid);
				}
			}
			else // WorkStatusEnum.POCO_REJECT or ContributionStatusEnum.CONTRIBUTED (not revealed)
			{
				// No Reward
				iexecclerk.seizeContribution(task.dealid, worker, _taskid);

				// Always punish bad contributors
				{
					/*******************************************************************
					 *                        SCORE POLICY 3/3                         *
					 *                                                                 *
					 *                       see documentation!                        *
					 *******************************************************************/
					// k = 3
					m_workerScores[worker] = m_workerScores[worker].mulByFraction(2,3);
					emit FaultyContribution(worker, _taskid);
				}
			}
		}
		// totalReward now contains the scheduler share
		iexecclerk.rewardForScheduling(task.dealid, totalReward, _taskid);
	}

	function claim(
		bytes32 _taskid)
	public
	{
		IexecODBLibCore.Task storage task = m_tasks[_taskid];
		require(task.status == IexecODBLibCore.TaskStatusEnum.ACTIVE
		     || task.status == IexecODBLibCore.TaskStatusEnum.REVEALING);
		require(task.finalDeadline <= now);

		task.status = IexecODBLibCore.TaskStatusEnum.FAILLED;

		/**
		 * Stake management
		 */
		iexecclerk.failedWork(task.dealid, _taskid);
		for (uint256 i = 0; i < task.contributors.length; ++i)
		{
			address worker = task.contributors[i];
			iexecclerk.unlockContribution(task.dealid, worker);
		}

		emit TaskClaimed(_taskid);
	}

	/***************************************************************************
	 *                            Array operations                             *
	 ***************************************************************************/
	function initializeArray(
		bytes32[] calldata _dealid,
		uint256[] calldata _idx)
	external returns (bool)
	{
		require(_dealid.length == _idx.length);
		for (uint i = 0; i < _dealid.length; ++i)
		{
			initialize(_dealid[i], _idx[i]);
		}
		return true;
	}

	function claimArray(
		bytes32[] calldata _taskid)
	external returns (bool)
	{
		for (uint i = 0; i < _taskid.length; ++i)
		{
			claim(_taskid[i]);
		}
		return true;
	}

	function initializeAndClaimArray(
		bytes32[] calldata _dealid,
		uint256[] calldata _idx)
	external returns (bool)
	{
		require(_dealid.length == _idx.length);
		for (uint i = 0; i < _dealid.length; ++i)
		{
			claim(initialize(_dealid[i], _idx[i]));
		}
		return true;
	}

	/**
	 * /!\ TEMPORARY LEGACY /!\
	 */

	function viewTaskABILegacy(bytes32 _taskid)
	external view returns
	( IexecODBLibCore.TaskStatusEnum
	, bytes32
	, uint256
	, uint256
	, uint256
	, uint256
	, uint256
	, bytes32
	, uint256
	, uint256
	, address[] memory
	, bytes     memory
	)
	{
		IexecODBLibCore.Task memory task = m_tasks[_taskid];
		return (
			task.status,
			task.dealid,
			task.idx,
			task.timeref,
			task.contributionDeadline,
			task.revealDeadline,
			task.finalDeadline,
			task.consensusValue,
			task.revealCounter,
			task.winnerCounter,
			task.contributors,
			task.results
		);
	}

	function viewContributionABILegacy(bytes32 _taskid, address _worker)
	external view returns
	( IexecODBLibCore.ContributionStatusEnum
	, bytes32
	, bytes32
	, address
	)
	{
		IexecODBLibCore.Contribution memory contribution = m_contributions[_taskid][_worker];
		return (
			contribution.status,
			contribution.resultHash,
			contribution.resultSeal,
			contribution.enclaveChallenge
		);
	}

	function viewCategoryABILegacy(uint256 _catid)
	external view returns (string memory, string memory, uint256)
	{
		IexecODBLibCore.Category memory category = m_categories[_catid];
		return ( category.name, category.description, category.workClockTimeRef );
	}
}