/**
 * Source Code first verified at https://etherscan.io on Wednesday, March 27, 2019
 (UTC) */

pragma solidity 0.4.25;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
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
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

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


/// @title Date and Time utilities for Ethereum contracts.
library DateTime {
    using SafeMath for uint256;
    using SafeMath for uint16;
    using SafeMath for uint8;

    struct DT {
        uint16 year;
        uint8 month;
        uint8 day;
        uint8 hour;
        uint8 minute;
        uint8 second;
        uint8 weekday;
    }

    uint public constant SECONDS_IN_DAY = 86400;
    uint public constant SECONDS_IN_YEAR = 31536000;
    uint public constant SECONDS_IN_LEAP_YEAR = 31622400;
    uint public constant DAYS_IN_WEEK = 7;
    uint public constant HOURS_IN_DAY = 24;
    uint public constant MINUTES_IN_HOUR = 60;
    uint public constant SECONDS_IN_HOUR = 3600;
    uint public constant SECONDS_IN_MINUTE = 60;

    uint16 public constant ORIGIN_YEAR = 1970;

    /// @dev Returns whether the specified year is a leap year.
    /// @param _year uint16 The year to check.
    function isLeapYear(uint16 _year) public pure returns (bool) {
        if (_year % 4 != 0) {
            return false;
        }

        if (_year % 100 != 0) {
            return true;
        }

        if (_year % 400 != 0) {
            return false;
        }

        return true;
    }

    /// @dev Returns how many leap years were before the specified year.
    /// @param _year uint16 The year to check.
    function leapYearsBefore(uint16 _year) public pure returns (uint16) {
        _year = uint16(_year.sub(1));
        return uint16(_year.div(4).sub(_year.div(100)).add(_year.div(400)));
    }

    /// @dev Returns how many days are there in a specified month.
    /// @param _year uint16 The year of the month to check.
    /// @param _month uint8 The month to check.
    function getDaysInMonth(uint16 _year, uint8 _month) public pure returns (uint8) {
        if (_month == 1 || _month == 3 || _month == 5 || _month == 7 || _month == 8 || _month == 10 || _month == 12) {
            return 31;
        }

        if (_month == 4 || _month == 6 || _month == 9 || _month == 11) {
            return 30;
        }

        if (isLeapYear(_year)) {
            return 29;
        }

        return 28;
    }

    /// @dev Returns the year of the current UNIX timestamp.
    /// @param _timestamp uint256 The UNIX timestamp to parse.
    function getYear(uint256 _timestamp) public pure returns (uint16 year) {
        uint256 secondsAccountedFor;
        uint16 numLeapYears;

        // Year
        year = uint16(ORIGIN_YEAR.add(_timestamp.div(SECONDS_IN_YEAR)));
        numLeapYears = uint16(leapYearsBefore(year).sub(leapYearsBefore(ORIGIN_YEAR)));

        secondsAccountedFor = secondsAccountedFor.add(SECONDS_IN_LEAP_YEAR.mul(numLeapYears));
        secondsAccountedFor = secondsAccountedFor.add(SECONDS_IN_YEAR.mul((year.sub(ORIGIN_YEAR).sub(numLeapYears))));

        while (secondsAccountedFor > _timestamp) {
            if (isLeapYear(uint16(year.sub(1)))) {
                secondsAccountedFor = secondsAccountedFor.sub(SECONDS_IN_LEAP_YEAR);
            } else {
                secondsAccountedFor = secondsAccountedFor.sub(SECONDS_IN_YEAR);
            }

            year = uint16(year.sub(1));
        }
    }

    /// @dev Returns the month of the current UNIX timestamp.
    /// @param _timestamp uint256 The UNIX timestamp to parse.
    function getMonth(uint256 _timestamp) public pure returns (uint8) {
        return parseTimestamp(_timestamp).month;
    }

    /// @dev Returns the day of the current UNIX timestamp.
    /// @param _timestamp uint256 The UNIX timestamp to parse.
    function getDay(uint256 _timestamp) public pure returns (uint8) {
        return parseTimestamp(_timestamp).day;
    }

    /// @dev Returns the hour of the current UNIX timestamp.
    /// @param _timestamp uint256 The UNIX timestamp to parse.
    function getHour(uint256 _timestamp) public pure returns (uint8) {
        return uint8((_timestamp.div(SECONDS_IN_HOUR)) % HOURS_IN_DAY);
    }

    /// @dev Returns the minutes of the current UNIX timestamp.
    /// @param _timestamp uint256 The UNIX timestamp to parse.
    function getMinute(uint256 _timestamp) public pure returns (uint8) {
        return uint8((_timestamp.div(SECONDS_IN_MINUTE)) % MINUTES_IN_HOUR);
    }

    /// @dev Returns the seconds of the current UNIX timestamp.
    /// @param _timestamp uint256 The UNIX timestamp to parse.
    function getSecond(uint256 _timestamp) public pure returns (uint8) {
        return uint8(_timestamp % SECONDS_IN_MINUTE);
    }

    /// @dev Returns the weekday of the current UNIX timestamp.
    /// @param _timestamp uint256 The UNIX timestamp to parse.
    function getWeekday(uint256 _timestamp) public pure returns (uint8) {
        return uint8((_timestamp.div(SECONDS_IN_DAY).add(4)) % DAYS_IN_WEEK);
    }

    /// @dev Returns the timestamp of the beginning of the month.
    /// @param _month uint8 The month to check.
    /// @param _year uint16 The year of the month to check.
    function getBeginningOfMonth(uint16 _year, uint8 _month) public pure returns (uint256) {
        return toTimestamp(_year, _month, 1);
    }

    /// @dev Returns the timestamp of the beginning of the month.
    /// @param _month uint8 The month to check.
    /// @param _year uint16 The year of the month to check.
    function getNextMonth(uint16 _year, uint8 _month) public pure returns (uint16 year, uint8 month) {
        if (_month == 12) {
            year = uint16(_year.add(1));
            month = 1;
        } else {
            year = _year;
            month = uint8(_month.add(1));
        }
    }

    /// @dev Converts date to timestamp.
    /// @param _year uint16 The year of the date.
    /// @param _month uint8 The month of the date.
    function toTimestamp(uint16 _year, uint8 _month) public pure returns (uint) {
        return toTimestampFull(_year, _month, 0, 0, 0, 0);
    }

    /// @dev Converts date to timestamp.
    /// @param _year uint16 The year of the date.
    /// @param _month uint8 The month of the date.
    /// @param _day uint8 The day of the date.
    function toTimestamp(uint16 _year, uint8 _month, uint8 _day) public pure returns (uint) {
        return toTimestampFull(_year, _month, _day, 0, 0, 0);
    }

    /// @dev Converts date to timestamp.
    /// @param _year uint16 The year of the date.
    /// @param _month uint8 The month of the date.
    /// @param _day uint8 The day of the date.
    /// @param _hour uint8 The hour of the date.
    /// @param _minutes uint8 The minutes of the date.
    /// @param _seconds uint8 The seconds of the date.
    function toTimestampFull(uint16 _year, uint8 _month, uint8 _day, uint8 _hour, uint8 _minutes,
        uint8 _seconds) public pure returns (uint) {
        uint16 i;
        uint timestamp;

        // Year
        for (i = ORIGIN_YEAR; i < _year; ++i) {
            if (isLeapYear(i)) {
                timestamp = timestamp.add(SECONDS_IN_LEAP_YEAR);
            } else {
                timestamp = timestamp.add(SECONDS_IN_YEAR);
            }
        }

        // Month
        uint8[12] memory monthDayCounts;
        monthDayCounts[0] = 31;
        if (isLeapYear(_year)) {
            monthDayCounts[1] = 29;
        } else {
            monthDayCounts[1] = 28;
        }
        monthDayCounts[2] = 31;
        monthDayCounts[3] = 30;
        monthDayCounts[4] = 31;
        monthDayCounts[5] = 30;
        monthDayCounts[6] = 31;
        monthDayCounts[7] = 31;
        monthDayCounts[8] = 30;
        monthDayCounts[9] = 31;
        monthDayCounts[10] = 30;
        monthDayCounts[11] = 31;

        for (i = 1; i < _month; ++i) {
            timestamp = timestamp.add(SECONDS_IN_DAY.mul(monthDayCounts[i.sub(1)]));
        }

        // Day
        timestamp = timestamp.add(SECONDS_IN_DAY.mul(_day == 0 ? 0 : _day.sub(1)));

        // Hour
        timestamp = timestamp.add(SECONDS_IN_HOUR.mul(_hour));

        // Minutes
        timestamp = timestamp.add(SECONDS_IN_MINUTE.mul(_minutes));

        // Seconds
        timestamp = timestamp.add(_seconds);

        return timestamp;
    }

    /// @dev Parses a UNIX timestamp to a DT struct.
    /// @param _timestamp uint256 The UNIX timestamp to parse.
    function parseTimestamp(uint256 _timestamp) internal pure returns (DT memory dt) {
        uint256 secondsAccountedFor;
        uint256 buf;
        uint8 i;

        // Year
        dt.year = getYear(_timestamp);
        buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor = secondsAccountedFor.add(SECONDS_IN_LEAP_YEAR.mul(buf));
        secondsAccountedFor = secondsAccountedFor.add(SECONDS_IN_YEAR.mul((dt.year.sub(ORIGIN_YEAR).sub(buf))));

        // Month
        uint256 secondsInMonth;
        for (i = 1; i <= 12; ++i) {
            secondsInMonth = SECONDS_IN_DAY.mul(getDaysInMonth(dt.year, i));
            if (secondsInMonth.add(secondsAccountedFor) > _timestamp) {
                dt.month = i;
                break;
            }
            secondsAccountedFor = secondsAccountedFor.add(secondsInMonth);
        }

        // Day
        for (i = 1; i <= getDaysInMonth(dt.year, dt.month); ++i) {
            if (SECONDS_IN_DAY.add(secondsAccountedFor) > _timestamp) {
                dt.day = i;
                break;
            }
            secondsAccountedFor = secondsAccountedFor.add(SECONDS_IN_DAY);
        }

        // Hour
        dt.hour = getHour(_timestamp);

        // Minute
        dt.minute = getMinute(_timestamp);

        // Second
        dt.second = getSecond(_timestamp);

        // Day of week.
        dt.weekday = getWeekday(_timestamp);
    }
}



interface ISubscriptionChecker {
    /// @param _id the virtual chain id to check subscription for
    /// @return profile - the subscribed plan, e.g. 'gold', 'silver', etc
    function getSubscriptionData(bytes32 _id) external view returns (bytes32 id, string memory profile, uint256 startTime, uint256 tokens);
}


/// @title Orbs billing and subscription smart contract.
contract OrbsSubscriptions is ISubscriptionChecker {
    using SafeMath for uint256;

    // The version of the current subscription manager smart contract.
    uint public constant VERSION = 2;

    // The Orbs token smart contract.
    IERC20 public orbs;

    // The Orbs Validators smart contract.
    IOrbsValidators public validators;

    // The minimal monthly subscription allocation.
    uint public minimalMonthlySubscription;

    struct Subscription {
        bytes32 id;
        string profile;
        uint256 startTime;
        uint256 tokens;
    }

    struct MonthlySubscriptions {
        mapping(bytes32 => Subscription) subscriptions;
        uint256 totalTokens;
    }

    /// A mapping between time (in a monthly resolution) and subscriptions, in the following format:
    ///     YEAR --> MONTH -->   MONTHLY_SUBSCRIPTION  --> SUBSCRIPTION_ID -->  SUBSCRIPTION
    ///     2017 -->  12   --> {<subscriptions>, 1000} -->     "User1"     --> {"User1", 100}
    mapping(uint16 => mapping(uint8 => MonthlySubscriptions)) public subscriptions;

    bytes32 constant public EMPTY = bytes32(0);

    event Subscribed(address indexed subscriber, bytes32 indexed id, uint256 value, uint256 startFrom);
    event DistributedFees(address indexed validator, uint256 value);

    /// @dev Constructor that initializes the Subscription Manager.
    /// @param orbs_ IERC20 The address of the OrbsToken contract.
    /// @param validators_ The address of the OrbsValidators contract.
    /// @param minimalMonthlySubscription_ uint256 The minimal monthly subscription allocation.
    constructor(IERC20 orbs_, IOrbsValidators validators_, uint256 minimalMonthlySubscription_) public {
        require(address(orbs_) != address(0), "Address must not be 0!");
        require(address(validators_) != address(0), "OrbsValidators must not be 0!");
        require(minimalMonthlySubscription_ != 0, "Minimal subscription value must be greater than 0!");

        orbs = orbs_;
        validators = validators_;
        minimalMonthlySubscription = minimalMonthlySubscription_;
    }

    /// @dev Returns the current month's subscription data.
    /// @param _id bytes32 The ID of the subscription.
    function getSubscriptionData(bytes32 _id) public view returns (bytes32 id, string memory profile, uint256 startTime,
        uint256 tokens) {
        require(_id != EMPTY, "ID must not be empty!");

        // Get the current year and month.
        uint16 currentYear;
        uint8 currentMonth;
        (currentYear, currentMonth) = getCurrentTime();

        return getSubscriptionDataByTime(_id, currentYear, currentMonth);
    }

    /// @dev Returns the monthly subscription status.
    /// @param _id bytes32 The ID of the subscription.
    /// @param _year uint16 The year of the subscription.
    /// @param _month uint8 The month of the subscription.
    function getSubscriptionDataByTime(bytes32 _id, uint16 _year, uint8 _month) public view returns (bytes32 id,
        string memory profile, uint256 startTime, uint256 tokens) {
        require(_id != EMPTY, "ID must not be empty!");

        MonthlySubscriptions storage monthlySubscription = subscriptions[_year][_month];
        Subscription memory subscription = monthlySubscription.subscriptions[_id];

        id = subscription.id;
        profile = subscription.profile;
        startTime = subscription.startTime;
        tokens = subscription.tokens;
    }

    /// @dev Distributes monthly fees to validators.
    function distributeFees() public {
        // Get the current year and month.
        uint16 currentYear;
        uint8 currentMonth;
        (currentYear, currentMonth) = getCurrentTime();

        distributeFees(currentYear, currentMonth);
    }

    /// @dev Distributes monthly fees to validators.
    function distributeFees(uint16 _year, uint8 _month) public {
        uint16 currentYear;
        uint8 currentMonth;
        (currentYear, currentMonth) = getCurrentTime();

        // Don't allow distribution of any future fees (specifically, next month's subscription fees).
        require(DateTime.toTimestamp(currentYear, currentMonth) >= DateTime.toTimestamp(_year, _month),
            "Can't distribute future fees!");

        address[] memory validatorsAddress = validators.getValidators();
        uint validatorCount = validatorsAddress.length;

        MonthlySubscriptions storage monthlySubscription = subscriptions[_year][_month];
        uint256 fee = monthlySubscription.totalTokens.div(validatorCount);
        require(fee > 0, "Fee must be greater than 0!");

        for (uint i = 0; i < validatorCount; ++i) {
            address validator = validatorsAddress[i];
            uint256 validatorFee = fee;

            // Distribute the remainder to the first node.
            if (i == 0) {
                validatorFee = validatorFee.add(monthlySubscription.totalTokens % validatorCount);
            }

            monthlySubscription.totalTokens = monthlySubscription.totalTokens.sub(validatorFee);

            require(orbs.transfer(validator, validatorFee));
            emit DistributedFees(validator, validatorFee);
        }
    }

    /// @dev Receives subscription payment for the current month. This method needs to be called after the caller
    /// approves the smart contract to transfer _value ORBS tokens on its behalf.
    /// @param _id bytes32 The ID of the subscription.
    /// @param _profile string The name of the subscription profile. This parameter is ignored for subsequent
    /// subscriptions.
    /// @param _value uint256 The amount of tokens to fund the subscription.
    function subscribeForCurrentMonth(bytes32 _id, string memory _profile, uint256 _value) public {
        subscribe(_id, _profile, _value, now);
    }

    /// @dev Receives subscription payment for the next month. This method needs to be called after the caller approves
    /// the smart contract to transfer _value ORBS tokens on its behalf.
    /// @param _id bytes32 The ID of the subscription.
    /// @param _profile string The name of the subscription profile. This parameter is ignored for subsequent
    /// subscriptions.
    /// @param _value uint256 The amount of tokens to fund the subscription.
    function subscribeForNextMonth(bytes32 _id, string memory _profile, uint256 _value) public {
        // Get the current year and month.
        uint16 currentYear;
        uint8 currentMonth;
        (currentYear, currentMonth) = getCurrentTime();

        // Get the next month.
        uint16 nextYear;
        uint8 nextMonth;
        (nextYear, nextMonth) = DateTime.getNextMonth(currentYear, currentMonth);

        subscribe(_id, _profile, _value, DateTime.getBeginningOfMonth(nextYear, nextMonth));
    }

    /// @dev Receives subscription payment. This method needs to be called after the caller approves
    /// the smart contract to transfer _value ORBS tokens on its behalf.
    /// @param _id bytes32 The ID of the subscription.
    /// @param _profile string The name of the subscription profile. This parameter is ignored for subsequent
    /// subscriptions.
    /// @param _value uint256 The amount of tokens to fund the subscription.
    /// @param _startTime uint256 The start time of the subscription.
    function subscribe(bytes32 _id, string memory _profile, uint256 _value, uint256 _startTime) internal {
        require(_id != EMPTY, "ID must not be empty!");
        require(bytes(_profile).length > 0, "Profile must not be empty!");
        require(_value > 0, "Value must be greater than 0!");
        require(_startTime >= now, "Starting time must be in the future");

        // Verify that the subscriber approved enough tokens to pay for the subscription.
        require(orbs.transferFrom(msg.sender, address(this), _value), "Insufficient allowance!");

        uint16 year;
        uint8 month;
        (year, month) = getTime(_startTime);

        // Get the subscription.
        MonthlySubscriptions storage monthlySubscription = subscriptions[year][month];
        Subscription storage subscription = monthlySubscription.subscriptions[_id];

        // New subscription?
        if (subscription.id == EMPTY) {
            subscription.id = _id;
            subscription.profile = _profile;
            subscription.startTime = _startTime;
        }

        // Aggregate this month's subscription allocations.
        subscription.tokens = subscription.tokens.add(_value);

        // Make sure that the total monthly subscription allocation is above the minimal requirement.
        require(subscription.tokens >= minimalMonthlySubscription, "Subscription value is too low!");

        // Update selected month's total subscription allocations.
        monthlySubscription.totalTokens = monthlySubscription.totalTokens.add(_value);

        emit Subscribed(msg.sender, _id, _value, _startTime);
    }

    /// @dev Returns the current year and month.
    /// @return year uint16 The current year.
    /// @return month uint8 The current month.
    function getCurrentTime() private view returns (uint16 year, uint8 month) {
        return getTime(now);
    }

    /// @dev Returns the current year and month.
    /// @param _time uint256 The timestamp of the time to query.
    /// @return year uint16 The current year.
    /// @return month uint8 The current month.
    function getTime(uint256 _time) private pure returns (uint16 year, uint8 month) {
        year = DateTime.getYear(_time);
        month = DateTime.getMonth(_time);
    }
}