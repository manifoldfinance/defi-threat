/**
 * Source Code first verified at https://etherscan.io on Wednesday, May 8, 2019
 (UTC) */

pragma solidity 0.5.0;



/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
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

contract Owned {
    address private _owner;
    address private _newOwner;

    event TransferredOwner(
        address indexed previousOwner,
        address indexed newOwner
    );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
    constructor() internal {
        _owner = msg.sender;
        emit TransferredOwner(address(0), _owner);
    }

  /**
   * @return the address of the owner.
   */

    function owner() public view returns(address) {
        return _owner;
    }

  /**
   * @dev Throws if called by any account other than the owner.
   */
    modifier onlyOwner() {
        require(isOwner(), "Access is denied");
        _;
    }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
    function isOwner() public view returns(bool) {
        return msg.sender == _owner;
    }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
    function renounceOwner() public onlyOwner {
        emit TransferredOwner(_owner, address(0));
        _owner = address(0);
    }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
    function transferOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Empty address");
        _newOwner = newOwner;
    }


    function cancelOwner() public onlyOwner {
        _newOwner = address(0);
    }

    function confirmOwner() public {
        require(msg.sender == _newOwner, "Access is denied");
        emit TransferredOwner(_owner, _newOwner);
        _owner = _newOwner;
    }
}


contract Freezed {
	bool public frozen;

	/**
	* Logged when token transfers were frozen/unfrozen.
	*/
	event Freeze ();
	event Unfreeze ();


    modifier onlyUnfreeze() {
        require(!frozen, "Action temporarily paused");
        _;
    }

	constructor(bool _frozen) public {
		frozen = _frozen;
	}

	function _freezeTransfers () internal {
		if (!frozen) {
			frozen = true;
			emit Freeze();
		}
	}

	function _unfreezeTransfers () internal {
		if (frozen) {
			frozen = false;
			emit Unfreeze();
		}
	}
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 */

contract ERC20Base {



    mapping (address => uint) internal _balanceOf;
    uint internal _totalSupply; 

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );


    /**
    * @dev Total number of tokens in existence
    */

    function totalSupply() public view returns(uint) {
        return _totalSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */

    function balanceOf(address owner) public view returns(uint) {
        return _balanceOf[owner];
    }



    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */

    function _transfer(address from, address to, uint256 value) internal {
        _checkRequireERC20(to, value, true, _balanceOf[from]);

        // _balanceOf[from] -= value;
        // _balanceOf[to] += value;
        _balanceOf[from] = SafeMath.sub(_balanceOf[from], value);
        _balanceOf[to] = SafeMath.add(_balanceOf[to], value);
        emit Transfer(from, to, value);
    }


    /**
    * @dev Internal function that mints an amount of the token and assigns it to
    * an account. This encapsulates the modification of balances such that the
    * proper events are emitted.
    * @param account The account that will receive the created tokens.
    * @param value The amount that will be created.
    */

    function _mint(address account, uint256 value) internal {
        _checkRequireERC20(account, value, false, 0);
        _totalSupply = SafeMath.add(_totalSupply, value);
        _balanceOf[account] = SafeMath.add(_balanceOf[account], value);
        emit Transfer(address(0), account, value);
    }

    /**
    * @dev Internal function that burns an amount of the token of a given
    * account.
    * @param account The account whose tokens will be burnt.
    * @param value The amount that will be burnt.
    */

    function _burn(address account, uint256 value) internal {
        _checkRequireERC20(account, value, true, _balanceOf[account]);

        _totalSupply = SafeMath.sub(_totalSupply, value);
        _balanceOf[account] = SafeMath.sub(_balanceOf[account], value);
        emit Transfer(account, address(0), value);
    }


    function _checkRequireERC20(address addr, uint value, bool checkMax, uint max) internal pure {
        require(addr != address(0), "Empty address");
        require(value > 0, "Empty value");
        if (checkMax) {
            require(value <= max, "Out of value");
        }
    }

}


contract ERC20 is ERC20Base {
    string public name;
    string public symbol;
    uint8 public decimals;

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _total, address _fOwner) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _mint(_fOwner, _total);
    }


    mapping (address => mapping (address => uint256)) private _allowed;


    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    ); 

    /**
    * @dev Transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */

    function transfer(address to, uint256 value) public {
        _transfer(msg.sender, to, value);
    }

    /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param owner address The address which owns the funds.
    * @param spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender.
    */
    
    function allowance(address owner, address spender) public view returns(uint) {
        return _allowed[owner][spender];
    }


    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * Beware that changing an allowance with this method brings the risk that someone may use both the old
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * @param spender The address which will spend the funds.
    * @param value The amount of tokens to be spent.
    */

    function approve(address spender, uint256 value) public {
        _checkRequireERC20(spender, value, true, _balanceOf[msg.sender]);

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }


    /**
    * @dev Transfer tokens from one address to another
    * @param from address The address which you want to send tokens from
    * @param to address The address which you want to transfer to
    * @param value uint256 the amount of tokens to be transferred
    */

    function transferFrom(address from, address to, uint256 value) public {
        _checkRequireERC20(to, value, true, _allowed[from][msg.sender]);

        _allowed[from][msg.sender] = SafeMath.sub(_allowed[from][msg.sender], value);
        _transfer(from, to, value);
    }

    /**
    * @dev Increase the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed_[_spender] == 0. To increment
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * @param spender The address which will spend the funds.
    * @param value The amount of tokens to increase the allowance by.
    */

    function increaseAllowance(address spender, uint256 value)  public {
        _checkRequireERC20(spender, value, false, 0);
        require(_balanceOf[msg.sender] >= (_allowed[msg.sender][spender] + value), "Out of value");

        _allowed[msg.sender][spender] = SafeMath.add(_allowed[msg.sender][spender], value);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    }



    /**
    * @dev Decrease the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed_[_spender] == 0. To decrement
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * @param spender The address which will spend the funds.
    * @param value The amount of tokens to decrease the allowance by.
    */

    function decreaseAllowance(address spender, uint256 value) public {
        _checkRequireERC20(spender, value, true, _allowed[msg.sender][spender]);

        _allowed[msg.sender][spender] = SafeMath.sub(_allowed[msg.sender][spender],value);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    }
}


contract MCVToken is ERC20, Owned, Freezed {
    
    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _total, address _fOwner, bool _freeze) 
        public 
        ERC20(_name, _symbol, _decimals, _total, _fOwner) 
        Freezed(_freeze) {
    }


	function freezeTransfers () public onlyOwner {
		_freezeTransfers();
	}

	/**
	* Unfreeze token transfers.
	* May only be called by smart contract owner.
	*/
	function unfreezeTransfers () public onlyOwner {
		_unfreezeTransfers();
	}

    /**
    * @dev Internal function that burns an amount of the token of a sender
    * @param value The amount that will be burnt.
    */

    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }

    function transfer(address to, uint256 value) public onlyUnfreeze {
        super.transfer(to, value);
    }



    function transferFrom(address from, address to, uint256 value) public onlyUnfreeze {
        super.transferFrom(from, to, value);
    }

}