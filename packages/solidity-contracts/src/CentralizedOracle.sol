/**
 * Source Code first verified at https://etherscan.io on Monday, March 25, 2019
 (UTC) */

pragma solidity ^0.5.0;

pragma experimental ABIEncoderV2;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
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
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

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

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// The functionality that all derivative contracts expose to the admin.
interface AdminInterface {
    // Initiates the shutdown process, in case of an emergency.
    function emergencyShutdown() external;

    // A core contract method called immediately before or after any financial transaction. It pays fees and moves money
    // between margin accounts to make sure they reflect the NAV of the contract.
    function remargin() external;
}

// This interface allows contracts to query a verified, trusted price.
interface OracleInterface {
    // Requests the Oracle price for an identifier at a time. Returns the time at which a price will be available.
    // Returns 0 is the price is available now, and returns 2^256-1 if the price will never be available.  Reverts if
    // the Oracle doesn't support this identifier. Only contracts registered in the Registry are authorized to call this
    // method.
    function requestPrice(bytes32 identifier, uint time) external returns (uint expectedTime);

    // Checks whether a price has been resolved.
    function hasPrice(bytes32 identifier, uint time) external view returns (bool hasPriceAvailable);

    // Returns the Oracle price for identifier at a time. Reverts if the Oracle doesn't support this identifier or if
    // the Oracle doesn't have a price for this time. Only contracts registered in the Registry are authorized to call
    // this method.
    function getPrice(bytes32 identifier, uint time) external view returns (int price);

    // Returns whether the Oracle provides verified prices for the given identifier.
    function isIdentifierSupported(bytes32 identifier) external view returns (bool isSupported);

    // An event fired when a request for a (identifier, time) pair is made.
    event VerifiedPriceRequested(bytes32 indexed identifier, uint indexed time);

    // An event fired when a verified price is available for a (identifier, time) pair.
    event VerifiedPriceAvailable(bytes32 indexed identifier, uint indexed time, int price);
}

interface RegistryInterface {
    struct RegisteredDerivative {
        address derivativeAddress;
        address derivativeCreator;
    }

    // Registers a new derivative. Only authorized derivative creators can call this method.
    function registerDerivative(address[] calldata counterparties, address derivativeAddress) external;

    // Adds a new derivative creator to this list of authorized creators. Only the owner of this contract can call
    // this method.   
    function addDerivativeCreator(address derivativeCreator) external;

    // Removes a derivative creator to this list of authorized creators. Only the owner of this contract can call this
    // method.  
    function removeDerivativeCreator(address derivativeCreator) external;

    // Returns whether the derivative has been registered with the registry (and is therefore an authorized participant
    // in the UMA system).
    function isDerivativeRegistered(address derivative) external view returns (bool isRegistered);

    // Returns a list of all derivatives that are associated with a particular party.
    function getRegisteredDerivatives(address party) external view returns (RegisteredDerivative[] memory derivatives);

    // Returns all registered derivatives.
    function getAllRegisteredDerivatives() external view returns (RegisteredDerivative[] memory derivatives);

    // Returns whether an address is authorized to register new derivatives.
    function isDerivativeCreatorAuthorized(address derivativeCreator) external view returns (bool isAuthorized);
}

contract Testable is Ownable {

    // Is the contract being run on the test network. Note: this variable should be set on construction and never
    // modified.
    bool public isTest;

    uint private currentTime;

    constructor(bool _isTest) internal {
        isTest = _isTest;
        if (_isTest) {
            currentTime = now; // solhint-disable-line not-rely-on-time
        }
    }

    modifier onlyIfTest {
        require(isTest);
        _;
    }

    function setCurrentTime(uint _time) external onlyOwner onlyIfTest {
        currentTime = _time;
    }

    function getCurrentTime() public view returns (uint) {
        if (isTest) {
            return currentTime;
        } else {
            return now; // solhint-disable-line not-rely-on-time
        }
    }
}

contract Withdrawable is Ownable {
    // Withdraws ETH from the contract.
    function withdraw(uint amount) external onlyOwner {
        msg.sender.transfer(amount);
    }

    // Withdraws ERC20 tokens from the contract.
    function withdrawErc20(address erc20Address, uint amount) external onlyOwner {
        IERC20 erc20 = IERC20(erc20Address);
        require(erc20.transfer(msg.sender, amount));
    }
}

// Implements an oracle that allows the owner to push prices for queries that have been made.
contract CentralizedOracle is OracleInterface, Withdrawable, Testable {
    using SafeMath for uint;

    // This contract doesn't implement the voting routine, and naively indicates that all requested prices will be
    // available in a week.
    uint constant private SECONDS_IN_WEEK = 60*60*24*7;

    // Represents an available price. Have to keep a separate bool to allow for price=0.
    struct Price {
        bool isAvailable;
        int price;
        // Time the verified price became available.
        uint verifiedTime;
    }

    // The two structs below are used in an array and mapping to keep track of prices that have been requested but are
    // not yet available.
    struct QueryIndex {
        bool isValid;
        uint index;
    }

    // Represents a (identifier, time) point that has been queried.
    struct QueryPoint {
        bytes32 identifier;
        uint time;
    }

    // The set of identifiers the oracle can provide verified prices for.
    mapping(bytes32 => bool) private supportedIdentifiers;

    // Conceptually we want a (time, identifier) -> price map.
    mapping(bytes32 => mapping(uint => Price)) private verifiedPrices;

    // The mapping and array allow retrieving all the elements in a mapping and finding/deleting elements.
    // Can we generalize this data structure?
    mapping(bytes32 => mapping(uint => QueryIndex)) private queryIndices;
    QueryPoint[] private requestedPrices;

    // Registry to verify that a derivative is approved to use the Oracle.
    RegistryInterface private registry;

    constructor(address _registry, bool _isTest) public Testable(_isTest) {
        registry = RegistryInterface(_registry);
    }

    // Enqueues a request (if a request isn't already present) for the given (identifier, time) pair.
    function requestPrice(bytes32 identifier, uint time) external returns (uint expectedTime) {
        // Ensure that the caller has been registered with the Oracle before processing the request.
        require(registry.isDerivativeRegistered(msg.sender));
        require(supportedIdentifiers[identifier]);
        Price storage lookup = verifiedPrices[identifier][time];
        if (lookup.isAvailable) {
            // We already have a price, return 0 to indicate that.
            return 0;
        } else if (queryIndices[identifier][time].isValid) {
            // We already have a pending query, don't need to do anything.
            return getCurrentTime().add(SECONDS_IN_WEEK);
        } else {
            // New query, enqueue it for review.
            queryIndices[identifier][time] = QueryIndex(true, requestedPrices.length);
            requestedPrices.push(QueryPoint(identifier, time));
            emit VerifiedPriceRequested(identifier, time);
            return getCurrentTime().add(SECONDS_IN_WEEK);
        }
    }

    // Pushes the verified price for a requested query.
    function pushPrice(bytes32 identifier, uint time, int price) external onlyOwner {
        verifiedPrices[identifier][time] = Price(true, price, getCurrentTime());
        emit VerifiedPriceAvailable(identifier, time, price);

        QueryIndex storage queryIndex = queryIndices[identifier][time];
        require(queryIndex.isValid, "Can't push prices that haven't been requested");
        // Delete from the array. Instead of shifting the queries over, replace the contents of `indexToReplace` with
        // the contents of the last index (unless it is the last index).
        uint indexToReplace = queryIndex.index;
        delete queryIndices[identifier][time];
        uint lastIndex = requestedPrices.length.sub(1);
        if (lastIndex != indexToReplace) {
            QueryPoint storage queryToCopy = requestedPrices[lastIndex];
            queryIndices[queryToCopy.identifier][queryToCopy.time].index = indexToReplace;
            requestedPrices[indexToReplace] = queryToCopy;
        }
        requestedPrices.length = requestedPrices.length.sub(1);
    }

    // Adds the provided identifier as a supported identifier.
    function addSupportedIdentifier(bytes32 identifier) external onlyOwner {
        if(!supportedIdentifiers[identifier]) {
            supportedIdentifiers[identifier] = true;
            emit AddSupportedIdentifier(identifier);
        }
    }

    // Calls emergencyShutdown() on the provided derivative.
    function callEmergencyShutdown(address derivative) external onlyOwner {
        AdminInterface admin = AdminInterface(derivative);
        admin.emergencyShutdown();
    }

    // Calls remargin() on the provided derivative.
    function callRemargin(address derivative) external onlyOwner {
        AdminInterface admin = AdminInterface(derivative);
        admin.remargin();
    }

    // Checks whether a price has been resolved.
    function hasPrice(bytes32 identifier, uint time) external view returns (bool hasPriceAvailable) {
        // Ensure that the caller has been registered with the Oracle before processing the request.
        require(registry.isDerivativeRegistered(msg.sender));
        require(supportedIdentifiers[identifier]);
        Price storage lookup = verifiedPrices[identifier][time];
        return lookup.isAvailable;
    }

    // Gets a price that has already been resolved.
    function getPrice(bytes32 identifier, uint time) external view returns (int price) {
        // Ensure that the caller has been registered with the Oracle before processing the request.
        require(registry.isDerivativeRegistered(msg.sender));
        require(supportedIdentifiers[identifier]);
        Price storage lookup = verifiedPrices[identifier][time];
        require(lookup.isAvailable);
        return lookup.price;
    }

    // Gets the queries that still need verified prices.
    function getPendingQueries() external view onlyOwner returns (QueryPoint[] memory queryPoints) {
        return requestedPrices;
    }

    // Whether the oracle provides verified prices for the provided identifier.
    function isIdentifierSupported(bytes32 identifier) external view returns (bool isSupported) {
        return supportedIdentifiers[identifier];
    }

    event AddSupportedIdentifier(bytes32 indexed identifier);
}