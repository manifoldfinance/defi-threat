/**
 * Source Code first verified at https://etherscan.io on Monday, March 18, 2019
 (UTC) */

pragma solidity 0.4.24;


/// @title SafeMath
/// @dev Math operations with safety checks that throw on error
library SafeMath {

    /// @dev Multiply two numbers, throw on overflow.
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /// @dev Substract two numbers, throw on overflow (i.e. if subtrahend is greater than minuend).
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /// @dev Add two numbers, throw on overflow.
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

/// @title Ownable
/// @dev Provide a modifier that permits only a single user to call the function
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @dev Set the original `owner` of the contract to the sender account.
    constructor() public {
        owner = msg.sender;
    }

    /// @dev Require that the modified function is only called by `owner`
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /// @dev Allow `owner` to transfer control of the contract to `newOwner`.
    /// @param newOwner The address to transfer ownership to.
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

/// @notice Abstract contract for vesting schedule
/// @notice Implementations must provide vestedPercent()
contract Schedule is Ownable {
    using SafeMath for uint256;

    /// The timestamp of the start of vesting
    uint256 public tokenReleaseDate;

    /// The timestamp of the vesting release interval
    uint256 public releaseInterval = 30 days;

    constructor(uint256 _tokenReleaseDate) public {
        tokenReleaseDate = _tokenReleaseDate;
    }

    /// @notice Update the date that PLG trading unlocks
    /// @param newReleaseDate The new PLG release timestamp
    function setTokenReleaseDate(uint256 newReleaseDate) public onlyOwner {
        tokenReleaseDate = newReleaseDate;
    }

    /// @notice Calculates the percent of tokens that may be claimed at this time
    /// @return Number of tokens vested
    function vestedPercent() public view returns (uint256);

    /// @notice Helper for calculating the time of a specific release
    /// @param intervals The number of interval periods to calculate a release date for
    /// @return The timestamp of the release date
    function getReleaseTime(uint256 intervals) public view returns (uint256) {
        return tokenReleaseDate.add(releaseInterval.mul(intervals));
    }
}

/// @title ScheduleStandard
/// @notice Vesting schedule that releases:
/// @notice  15% at `tokenReleaseDate`,
/// @notice  15% at `tokenReleaseDate + releaseInterval`
/// @notice  25% at `tokenReleaseDate + (2 * releaseInterval)`
/// @notice  15% at `tokenReleaseDate + (3 * releaseInterval)`
/// @notice  15% at `tokenReleaseDate + (4 * releaseInterval)`
/// @notice  15% at `tokenReleaseDate + (5 * releaseInterval)`
contract ScheduleStandard is Schedule {

    constructor(uint256 _tokenReleaseDate) Schedule(_tokenReleaseDate) public {
    }

    /// @notice Calculates the percent of tokens that may be claimed at this time
    /// @return Number of tokens vested
    function vestedPercent() public view returns (uint256) {
        uint256 percentReleased = 0;

        if(now < tokenReleaseDate) {
            percentReleased = 0;
            
        } else if(now >= getReleaseTime(5)) {
            percentReleased = 100;

        } else if(now >= getReleaseTime(4)) {
            percentReleased = 85;

        } else if(now >= getReleaseTime(3)) {
            percentReleased = 70;

        } else if(now >= getReleaseTime(2)) {
            percentReleased = 55;

        } else if(now >= getReleaseTime(1)) {
            percentReleased = 30;

        } else {
            percentReleased = 15;
        }
        return percentReleased;
    }
}