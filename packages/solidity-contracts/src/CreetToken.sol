/**
 * Source Code first verified at https://etherscan.io on Tuesday, March 19, 2019
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

contract Ownable
{
    bool private stopped;
    address private _owner;
    address private _master;

    event Stopped();
    event Started();
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event MasterRoleTransferred(address indexed previousMaster, address indexed newMaster);

    constructor () internal
    {
        stopped = false;
        _owner = msg.sender;
        _master = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
        emit MasterRoleTransferred(address(0), _master);
    }

    function owner() public view returns (address)
    {
        return _owner;
    }

    function master() public view returns (address)
    {
        return _master;
    }

    modifier onlyOwner()
    {
        require(isOwner());
        _;
    }

    modifier onlyMaster()
    {
        require(isMaster() || isOwner());
        _;
    }

    modifier onlyWhenNotStopped()
    {
        require(!isStopped());
        _;
    }

    function isOwner() public view returns (bool)
    {
        return msg.sender == _owner;
    }

    function isMaster() public view returns (bool)
    {
        return msg.sender == _master;
    }

    function transferOwnership(address newOwner) external onlyOwner
    {
        _transferOwnership(newOwner);
    }

    function transferMasterRole(address newMaster) external onlyOwner
    {
        _transferMasterRole(newMaster);
    }

    function isStopped() public view returns (bool)
    {
        return stopped;
    }

    function stop() public onlyOwner
    {
        _stop();
    }

    function start() public onlyOwner
    {
        _start();
    }

    function _transferOwnership(address newOwner) internal
    {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function _transferMasterRole(address newMaster) internal
    {
        require(newMaster != address(0));
        emit MasterRoleTransferred(_master, newMaster);
        _master = newMaster;
    }

    function _stop() internal
    {
        emit Stopped();
        stopped = true;
    }

    function _start() internal
    {
        emit Started();
        stopped = false;
    }
}

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

contract BaseToken is IERC20, Ownable
{
    using SafeMath for uint256;

    mapping (address => uint256) public balances;
    mapping (address => mapping ( address => uint256 )) public approvals;

    uint256 public totalTokenSupply;

    function totalSupply() view external returns (uint256)
    {
        return totalTokenSupply;
    }

    function balanceOf(address _who) view external returns (uint256)
    {
        return balances[_who];
    }

    function transfer(address _to, uint256 _value) external onlyWhenNotStopped returns (bool)
    {
        require(balances[msg.sender] >= _value);
        require(_to != address(0));

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value) external onlyWhenNotStopped returns (bool)
    {
        require(balances[msg.sender] >= _value);

        approvals[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function allowance(address _owner, address _spender) view external returns (uint256)
    {
        return approvals[_owner][_spender];
    }

    function transferFrom(address _from, address _to, uint256 _value) external onlyWhenNotStopped returns (bool)
    {
        require(_from != address(0));
        require(balances[_from] >= _value);
        require(approvals[_from][msg.sender] >= _value);

        approvals[_from][msg.sender] = approvals[_from][msg.sender].sub(_value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to]  = balances[_to].add(_value);

        emit Transfer(_from, _to, _value);

        return true;
    }
}

contract CreetToken is BaseToken
{
    using SafeMath for uint256;

    string public name;
    uint256 public decimals;
    string public symbol;

    uint256 constant private E18 = 1000000000000000000;
    uint256 constant private MAX_TOKEN_SUPPLY = 5000000000;

    event Deposit(address indexed from, address to, uint256 value);
    event ReferralDrop(address indexed from, address indexed to1, uint256 value1, address indexed to2, uint256 value2);

    constructor() public
    {
        name        = 'Creet';
        decimals    = 18;
        symbol      = 'CREET';

        totalTokenSupply = MAX_TOKEN_SUPPLY * E18;

        balances[msg.sender] = totalTokenSupply;
    }

    function deposit(address _to, uint256 _value) external returns (bool)
    {
        require(balances[msg.sender] >= _value);
        require(_to != address(0));

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Deposit(msg.sender, _to, _value);

        return true;
    }

    function referralDrop2(address _to, uint256 _value, address _sale, uint256 _fee) external onlyWhenNotStopped returns (bool)
    {
        require(balances[msg.sender] >= _value + _fee);
        require(_to != address(0));
        require(_sale != address(0));

        balances[msg.sender] = balances[msg.sender].sub(_value + _fee);
        balances[_to] = balances[_to].add(_value);
        balances[_sale] = balances[_sale].add(_fee);

        emit ReferralDrop(msg.sender, _to, _value, address(0), 0);

        return true;
    }

    function referralDrop3(address _to1, uint256 _value1, address _to2, uint256 _value2, address _sale, uint256 _fee) external onlyWhenNotStopped returns (bool)
    {
        require(balances[msg.sender] >= _value1 + _value2 + _fee);
        require(_to1 != address(0));
        require(_to2 != address(0));
        require(_sale != address(0));

        balances[msg.sender] = balances[msg.sender].sub(_value1 + _value2 + _fee);
        balances[_to1] = balances[_to1].add(_value1);
        balances[_to2] = balances[_to2].add(_value2);
        balances[_sale] = balances[_sale].add(_fee);

        emit ReferralDrop(msg.sender, _to1, _value1, _to2, _value2);

        return true;
    }
}