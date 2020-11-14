/**
 * Source Code first verified at https://etherscan.io on Saturday, May 4, 2019
 (UTC) */

pragma solidity ^0.5.0;

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
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
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

contract HarukaTest01 is IERC20 {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    using SafeMath for uint256;

    enum ReleaseType {
        Public,
        Private1,
        Private23,
        Foundation,
        Ecosystem,
        Team,
        Airdrop,
        Contributor
    }

    // Default is Public aka no locking
    mapping (address => ReleaseType) private _accountType;

    // Required to calculate actual balance
    // uint256 should be more than enough in lifetime
    mapping (address => uint256) private _totalBalance;
    mapping (address => uint256) private _spentBalance;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply = 10_000_000_000E18;

    string private _name = "Haruka Test Token #01";
    string private _symbol = "HARUKAT01";
    uint8 private _decimals = 18;

    address public owner;

    // Used when calculating available balance
    // Will change after
    uint256 public reference_time = 2000000000;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor() public {
        owner = msg.sender;

        // Initial balance
        _totalBalance[owner] = _totalSupply;
        _accountType[owner] = ReleaseType.Private1;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        require(_spender != address(0));

        _allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        _transfer(_from, _to, _value);
        _allowed[_from][_to] = _allowed[_from][_to].sub(_value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(value <= balanceOf(from));
        require(to != address(0));

        _spentBalance[from] = _spentBalance[from].add(value);
        _totalBalance[to] = _totalBalance[to].add(value);
        emit Transfer(from, to, value);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    // For ERC20 compatible clients, show current available balance instead of total balance
    // This is also called in other functions to get the balance
    // SafeMath should be unnecessary as all calculations should be already "safe"
    // May lose precision due to truncating but it only loses fraction of E-18 so should be safe to ignore
    // Overflow should be impossible as uint256 has E+77 and total supply has only E+28
    // For complete readable schedule, please refer to official documents
    function balanceOf(address _owner) public view returns (uint256) {
        // Type of address
        ReleaseType _type = _accountType[_owner];
        uint256 balance = _totalBalance[_owner].sub(_spentBalance[_owner]);

        // Contract owner is exempt from "before release" check to be able to make initial distribution
        // Contract owner is also exempt from locking
        if (_owner == owner) {
            return balance;
        }

        // Elapsed time since release
        uint256 elapsed = now - reference_time;
        // Before release
        if (elapsed < 0) {
            return 0;
        }
        // Shortcut: after complete unlock
        if (elapsed >= 21 * 30 minutes) {
            return balance;
        }

        // Available amount for each type of address
        if (_type == ReleaseType.Public) {
            // No locking
            return balance;
        } else if (_type == ReleaseType.Private1) {
            if (elapsed < 3 * 30 minutes) {
                return 0;
            } else if (elapsed < 6 * 30 minutes) {
                return balance / 6;
            } else if (elapsed < 9 * 30 minutes) {
                return balance * 2 / 6;
            } else if (elapsed < 12 * 30 minutes) {
                return balance * 3 / 6;
            } else if (elapsed < 15 * 30 minutes) {
                return balance * 4 / 6;
            } else if (elapsed < 18 * 30 minutes) {
                return balance * 5 / 6;
            } else {
                return balance;
            }
        } else if (_type == ReleaseType.Private23) {
            if (elapsed < 6 * 30 minutes) {
                return 0;
            } else if (elapsed < 9 * 30 minutes) {
                return balance / 4;
            } else if (elapsed < 12 * 30 minutes) {
                return balance * 2 / 4;
            } else if (elapsed < 15 * 30 minutes) {
                return balance * 3 / 4;
            } else {
                return balance;
            }
        } else if (_type == ReleaseType.Foundation) {
            if (elapsed < 3 * 30 minutes) {
                return 0;
            } else if (elapsed < 6 * 30 minutes) {
                return balance * 3 / 20;
            } else if (elapsed < 9 * 30 minutes) {
                return balance * 6 / 20;
            } else if (elapsed < 12 * 30 minutes) {
                return balance * 9 / 20;
            } else if (elapsed < 15 * 30 minutes) {
                return balance * 12 / 20;
            } else if (elapsed < 18 * 30 minutes) {
                return balance * 15 / 20;
            } else if (elapsed < 21 * 30 minutes) {
                return balance * 18 / 20;
            } else {
                return balance;
            }
        } else if (_type == ReleaseType.Ecosystem) {
            if (elapsed < 3 * 30 minutes) {
                return balance * 5 / 30;
            } else if (elapsed < 6 * 30 minutes) {
                return balance * 10 / 30;
            } else if (elapsed < 9 * 30 minutes) {
                return balance * 15 / 30;
            } else if (elapsed < 12 * 30 minutes) {
                return balance * 18 / 30;
            } else if (elapsed < 15 * 30 minutes) {
                return balance * 21 / 30;
            } else if (elapsed < 18 * 30 minutes) {
                return balance * 24 / 30;
            } else if (elapsed < 21 * 30 minutes) {
                return balance * 27 / 30;
            } else {
                return balance;
            }
        } else if (_type == ReleaseType.Team) {
            if (elapsed < 12 * 30 minutes) {
                return 0;
            } else if (elapsed < 15 * 30 minutes) {
                return balance / 4;
            } else if (elapsed < 18 * 30 minutes) {
                return balance * 2 / 4;
            } else if (elapsed < 21 * 30 minutes) {
                return balance * 3 / 4;
            } else {
                return balance;
            }
        } else if (_type == ReleaseType.Airdrop) {
            if (elapsed < 3 * 30 minutes) {
                return balance / 2;
            } else {
                return balance;
            }
        } else if (_type == ReleaseType.Contributor) {
            if (elapsed < 12 * 30 minutes) {
                return 0;
            } else if (elapsed < 15 * 30 minutes) {
                return balance / 4;
            } else if (elapsed < 18 * 30 minutes) {
                return balance * 2 / 4;
            } else if (elapsed < 21 * 30 minutes) {
                return balance * 3 / 4;
            } else {
                return balance;
            }
        }

        // For unknown type which is quite impossible, return zero
        return 0;

    }

    // Total balance including locked part
    function totalBalanceOf(address _owner) public view returns (uint256) {
        return _totalBalance[_owner].sub(_spentBalance[_owner]);
    }

    // Allowance is not affected by locking
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return _allowed[_owner][_spender];
    }

    // Set the release type of specified address
    // Only contract owner could call this
    function setReleaseType(address _target, ReleaseType _type) public onlyOwner {
        require(_target != address(0));
        _accountType[_target] = _type;
    }

    // Set reference time
    // Only contract owner could call this
    function setReferenceTime(uint256 newTime) public onlyOwner {
        reference_time = newTime;
    }

    // Contract owner transfer
    // Note that only current contract owner and "Public" addresses are exempt from locking
    function ownerTransfer(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}