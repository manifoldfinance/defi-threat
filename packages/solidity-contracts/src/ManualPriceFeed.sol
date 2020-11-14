/**
 * Source Code first verified at https://etherscan.io on Monday, March 25, 2019
 (UTC) */

pragma solidity ^0.5.0;

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

// This interface allows contracts to query unverified prices.
interface PriceFeedInterface {
    // Whether this PriceFeeds provides prices for the given identifier.
    function isIdentifierSupported(bytes32 identifier) external view returns (bool isSupported);

    // Gets the latest time-price pair at which a price was published. The transaction will revert if no prices have
    // been published for this identifier.
    function latestPrice(bytes32 identifier) external view returns (uint publishTime, int price);

    // An event fired when a price is published.
    event PriceUpdated(bytes32 indexed identifier, uint indexed time, int price);
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

// Implementation of PriceFeedInterface with the ability to push prices.
contract ManualPriceFeed is PriceFeedInterface, Withdrawable, Testable {

    using SafeMath for uint;

    // A single price update.
    struct PriceTick {
        uint timestamp;
        int price;
    }

    // Mapping from identifier to the latest price for that identifier.
    mapping(bytes32 => PriceTick) private prices;

    // Ethereum timestamp tolerance.
    // Note: this is technically the amount of time that a block timestamp can be *ahead* of the current time. However,
    // we are assuming that blocks will never get more than this amount *behind* the current time. The only requirement
    // limiting how early the timestamp can be is that it must have a later timestamp than its parent. However,
    // this bound will probably work reasonably well in both directions.
    uint constant private BLOCK_TIMESTAMP_TOLERANCE = 900;

    constructor(bool _isTest) public Testable(_isTest) {} // solhint-disable-line no-empty-blocks

    // Adds a new price to the series for a given identifier. The pushed publishTime must be later than the last time
    // pushed so far.
    function pushLatestPrice(bytes32 identifier, uint publishTime, int newPrice) external onlyOwner {
        require(publishTime <= getCurrentTime().add(BLOCK_TIMESTAMP_TOLERANCE));
        require(publishTime > prices[identifier].timestamp);
        prices[identifier] = PriceTick(publishTime, newPrice);
        emit PriceUpdated(identifier, publishTime, newPrice);
    }

    // Whether this feed has ever published any prices for this identifier.
    function isIdentifierSupported(bytes32 identifier) external view returns (bool isSupported) {
        isSupported = _isIdentifierSupported(identifier);
    }

    function latestPrice(bytes32 identifier) external view returns (uint publishTime, int price) {
        require(_isIdentifierSupported(identifier));
        publishTime = prices[identifier].timestamp;
        price = prices[identifier].price;
    }

    function _isIdentifierSupported(bytes32 identifier) private view returns (bool isSupported) {
        isSupported = prices[identifier].timestamp > 0;
    }
}