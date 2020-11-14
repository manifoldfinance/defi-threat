/**
 * Source Code first verified at https://etherscan.io on Tuesday, April 23, 2019
 (UTC) */

pragma solidity ^0.5.7;


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
    function totalSupply() public view returns (uint256);
    function balanceOf(address _who) public view returns (uint256);
    function allowance(address _owner, address _spender) public view returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
    function approve(address _spender, uint256 _value) public returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a * _b;
        require(_a == 0 || c / _a == _b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a / _b;
        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

        return c;
    }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor() public {
        owner = msg.sender;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
    * @dev Allows the current owner to relinquish control of the contract.
    * @notice Renouncing to ownership will leave the contract without an owner.
    * It will not be possible to call the functions with the `onlyOwner`
    * modifier anymore.
    */
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function transferOwnership(address _newOwner) public onlyOwner {
		require(_newOwner != address(0), "New owner cannot be address(0)");
		emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

/**
 * @title Administator
 * @dev  This contract has a group of administrators who can add/remove any account to/from blacklist. 
*/
contract Administrator is Ownable {
    mapping (address=>bool) public admin;
    
    // Current number of members of the administrator group
    uint    public   adminLength;   
    // The maximum number of members of the administrator group, which is specified in the constructor
    uint    public   adminMaxLength;      
    
    event   AddAdmin(address indexed _address);
    event   RemoveAdmin(address indexed _address);
    
    constructor (uint _len) public {        
        adminMaxLength = _len;
    }
    
    modifier isAdmin(address _addr) {
        require(admin[_addr], "Not administrator");
        _;
    }
    
    modifier isNotAdmin(address _addr) {
        require(!admin[_addr], "Is administrator");
        _;        
    }
    
    /**
     * @dev Modifier: Limit that only the contract owner or administrator can execute the function
    */
	modifier onlyOwnerOrAdmin() {
		require(msg.sender == owner || admin[msg.sender], "msg.sender is nether owner nor administator");
		_;
	}
    
    /**
     * @dev Add a member to the Administrators group
    */
    function addAdmin(address _addr) onlyOwner isNotAdmin(_addr) public returns (bool) {
        require(_addr != address(0), "Administrator cannot be address(0)");
        require(_addr != owner, "Administrator cannot be owner");
        require(adminLength < adminMaxLength, "Exceeded the maximum number of administrators");
        
        admin[_addr] = true;
        adminLength++; 
        
        emit AddAdmin(_addr);
        return true;
    } 
    
    /**
     * @dev Remove a member from the Administrators group
    */
    function removeAdmin(address _addr) onlyOwner isAdmin(_addr) public returns (bool) {
        delete admin[_addr];
        adminLength--;
        
        emit RemoveAdmin(_addr);
        return true;
    }
}

/**
* @title Blacklisted
* @dev allow contract owner or administator to add/remove address to/from the blacklist
*/
contract Blacklisted is Administrator {
	mapping (address => bool) public blacklist;

	event SetBlacklist(address indexed _address, bool _bool);

	/**
	* @dev Modifier: throw if _address is in the blacklist
	*/
	modifier notInBlacklist(address _address) {
		require(!blacklist[_address], "Is in Blacklist");
		_;
	}

	/**
	* @dev call by the owner, set/unset single _address into the blacklist
	*/
	function setBlacklist(address _address, bool _bool) public onlyOwnerOrAdmin {
		require(_address != address(0));
		
		if(_bool) {
		    require(!blacklist[_address], "Already in blacklist");
		} else {
		    require(blacklist[_address], "Not in blacklist yet");
		}
		
		blacklist[_address] = _bool;
		emit SetBlacklist(_address, _bool);
	}
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    /**
    * @dev Modifier to make a function callable only when the contract is not paused.
    */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is paused.
    */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
    * @dev called by the owner to pause, triggers stopped state
    */
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    /**
    * @dev called by the owner to unpause, returns to normal state
    */
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 */
contract StandardToken is ERC20, Pausable, Blacklisted {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    mapping (address => mapping (address => uint256)) internal allowed;

    uint256 totalSupply_;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param _owner address The address which owns the funds.
    * @param _spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender.
    */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    /**
    * @dev Transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) whenNotPaused notInBlacklist(msg.sender) notInBlacklist(_to) public returns (bool) {
        require(_to != address(0));

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }


    /**
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
    function transferFrom(address _from, address _to, uint256 _value) whenNotPaused notInBlacklist(msg.sender) notInBlacklist(_from) notInBlacklist(_to) public returns (bool) {
        require(_to != address(0));

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);
        return true;
    }


    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
    function approve(address _spender, uint256 _value) whenNotPaused public returns (bool) {
		require(_value == 0 || allowed[msg.sender][_spender] == 0 );
        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    /**
    * @dev Increase the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed[_spender] == 0. To increment
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * @param _spender The address which will spend the funds.
    * @param _addedValue The amount of tokens to increase the allowance by.
    */
    function increaseApproval(address _spender, uint256 _addedValue) whenNotPaused public returns (bool) {
        allowed[msg.sender][_spender] = (allowed[msg.sender][_spender].add(_addedValue));

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
    * @dev Decrease the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed[_spender] == 0. To decrement
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * @param _spender The address which will spend the funds.
    * @param _subtractedValue The amount of tokens to decrease the allowance by.
    */
    function decreaseApproval(address _spender, uint256 _subtractedValue) whenNotPaused public returns (bool) {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}



/**
* @title GomicsToken
* @dev	GomicsToken main contract 
*/
contract GomicsToken is StandardToken {
    string public constant name = "Gomics";
    string public constant symbol = "GOM";
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 75000000;
    
    constructor() Administrator(3) public {
        totalSupply_ = INITIAL_SUPPLY * (10 ** uint256(decimals));
        balances[msg.sender] = totalSupply_;
        emit Transfer(address(0), msg.sender, totalSupply_);
    }
}