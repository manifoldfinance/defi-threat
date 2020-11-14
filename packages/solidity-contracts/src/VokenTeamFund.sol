/**
 * Source Code first verified at https://etherscan.io on Friday, May 3, 2019
 (UTC) */

pragma solidity ^0.5.7;

// Voken Team Fund
//   Freezed till 2021-06-30 23:59:59, (timestamp 1625039999).
//   Release 10% per 3 months.
//
// More info:
//   https://vision.network
//   https://voken.io
//
// Contact us:
//   <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e89b9d9898879a9ca89e819b818786c6868d9c9f879a83">[email protected]</a>
//   <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="abd8dedbdbc4d9dfebddc4c0cec585c2c4">[email protected]</a>


/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
 */
library SafeMath {
    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient,
     * reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + a % b);
        return a / b;
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
 */
contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract
     * to the sender account.
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
        require(msg.sender == _owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
    }

    /**
     * @dev Withdraw Ether
     */
    function withdrawEther(address payable to, uint256 amount) external onlyOwner {
        require(to != address(0));

        uint256 balance = address(this).balance;

        require(balance >= amount);
        to.transfer(amount);
    }
}


/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20{
    function balanceOf(address owner) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
}


/**
 * @title Voken Team Fund
 */
contract VokenTeamFund is Ownable{
    using SafeMath for uint256;
    
    IERC20 public VOKEN;

    uint256 private _till = 1625039999;
    uint256 private _vokenAmount = 4200000000000000; // 4.2 billion
    uint256 private _3mo = 2592000; // Three months: 2,592,000 seconds

    uint256[10] private _freezedPct = [
        100,    // 100%
        90,     // 90%
        80,     // 80%
        70,     // 70%
        60,     // 60%
        50,     // 50%
        40,     // 40%
        30,     // 30%
        20,     // 20%
        10      // 10%
    ];

    event Donate(address indexed account, uint256 amount);


    /**
     * @dev constructor
     */
    constructor() public {
        VOKEN = IERC20(0x82070415FEe803f94Ce5617Be1878503e58F0a6a);
    }

    /**
     * @dev Voken freezed amount.
     */
    function vokenFreezed() public view returns (uint256) {
        uint256 __freezed;

        if (now > _till) {
            uint256 __qrPassed = now.sub(_till).div(_3mo);

            if (__qrPassed >= 10) {
                __freezed = 0;
            }
            else {
                __freezed = _vokenAmount.mul(_freezedPct[__qrPassed]).div(100);
            }

            return __freezed;
        }

        return _vokenAmount;
    }

    /**
     * @dev Donate
     */
    function () external payable {
        emit Donate(msg.sender, msg.value);
    }

    /**
     * @dev transfer Voken
     */
    function transferVoken(address to, uint256 amount) external onlyOwner {
        uint256 __freezed = vokenFreezed();
        uint256 __released = VOKEN.balanceOf(address(this)).sub(__freezed);

        require(__released >= amount);

        assert(VOKEN.transfer(to, amount));
    }

    /**
     * @dev Rescue compatible ERC20 Token, except "Voken"
     *
     * @param tokenAddr ERC20 The address of the ERC20 token contract
     * @param receiver The address of the receiver
     * @param amount uint256
     */
    function rescueTokens(address tokenAddr, address receiver, uint256 amount) external onlyOwner {
        IERC20 _token = IERC20(tokenAddr);
        require(VOKEN != _token);
        require(receiver != address(0));
    
        uint256 balance = _token.balanceOf(address(this));
        require(balance >= amount);
        assert(_token.transfer(receiver, amount));
    }
}