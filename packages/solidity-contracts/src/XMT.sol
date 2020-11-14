/**
 * Source Code first verified at https://etherscan.io on Friday, March 22, 2019
 (UTC) */

pragma solidity 0.5.4;

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
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () public {
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
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


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


contract StandardToken {
    using SafeMath for uint256;

    mapping(address => uint256) internal balances;

    mapping(address => mapping(address => uint256)) internal allowed;

    uint256 public totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed owner,uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 vaule);

    /**
     * @dev Gets the balance of the specified address.
     * @param _owner The address to query the the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address _owner) public view returns(uint256) {
        return balances[_owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public view returns(uint256) {
        return allowed[_owner][_spender];
    }

    /**
     * @dev Transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) public returns(bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns(bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the allowance by.
     */
    function increaseApproval(address _spender, uint256 _addedValue) public returns(bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns(bool) {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0));
        totalSupply = totalSupply.sub(value);
        balances[account] = balances[account].sub(value);
        emit Transfer(account, address(0), value);
        emit Burn(account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
        // this function needs to emit an event with the updated approval.
        allowed[account][msg.sender] = allowed[account][msg.sender].sub(value);
        _burn(account, value);
    }

}


contract BurnableToken is StandardToken {

    /**
     * @dev Burns a specific amount of tokens.
     * @param value The amount of token to be burned.
     */
    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }

    /**
     * @dev Burns a specific amount of tokens from the target address and decrements allowance
     * @param from address The address which you want to send tokens from
     * @param value uint256 The amount of token to be burned
     */
    function burnFrom(address from, uint256 value) public {
        _burnFrom(from, value);
    }
}


/**
 * @title Pausable token
 * @dev ERC20 modified with pausable transfers.
 */
contract PausableToken is StandardToken, Pausable {
    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        return super.approve(spender, value);
    }

    function increaseApproval(address spender, uint256 addedValue) public whenNotPaused returns (bool success) {
        return super.increaseApproval(spender, addedValue);
    }

    function decreaseApproval(address spender, uint256 subtractedValue) public whenNotPaused returns (bool success) {
        return super.decreaseApproval(spender, subtractedValue);
    }
}

contract Token is PausableToken, BurnableToken {
    string public constant name = "XMT"; // name of Token 
    string public constant symbol = "XMT"; // symbol of Token 
    uint8 public constant decimals = 18;

    uint256 internal constant INIT_TOTALSUPPLY = 1000000000; // Total amount of tokens

    constructor() public {
        totalSupply = INIT_TOTALSUPPLY * 10 ** uint256(decimals);
        balances[msg.sender] = totalSupply;
    }
}

/**
 * @dev Interface of Pair contract
 */
interface PairContract {
    function tokenFallback(address _from, uint256 _value, bytes calldata _data) external;
    function transfer(address _to, uint256 _value) external returns (bool);
    function decimals() external returns (uint8);
}

contract XMT is Token {
    // The address of Pair contract
    PairContract public pairInstance;
    /// @notice revoking rate precise
    /// @notice for example: RATE_PRECISE is 3, meaning that the revoking fee ratio is 3/10000
    uint public rate = 10000;  // default rate is 1:1
    uint public constant RATE_PRECISE = 10000;

    // events
    event ExchangePair(address indexed from, uint256 value);
    event SetPairContract(address PairToken);
    event RateChanged(uint256 previousOwner,uint256 newRate);

    /**
     * @dev Throws if called by any account other than the Pair contract
     */
    modifier onlyPairContract() {
        require(msg.sender == address(pairInstance));
        _;
    }

    /**
     * @dev Sets the address of pair contract
     */
    function setPairContract(address pairAddress) public onlyOwner {
        require(pairAddress != address(0));
        pairInstance = PairContract(pairAddress);
        emit SetPairContract(pairAddress);
    }

    /**
     * @dev Function Set the exchange rate of pair token.
     * for example: RATE_PRECISE is 300, means that the rate is 300/10000: 1 PT = 0.003 XMT
     * for example: RATE_PRECISE is 30000, means that the rate is 30000/10000: 1 PT = 3 XMT
     */
     function setRate(uint256 _newRate) public onlyOwner {
        require(_newRate > 0);
        emit RateChanged(rate,_newRate);
        rate = _newRate;
     }

    /**
     * @dev Transfers token to a specified address.
     *      If the target address of transferring is Pair contract, the operation of changing Pair tokens will be executed.
     * @param to The target address of transfer, which may be the  contract
     * @param value The amount of tokens transferred
     */
    function transfer(address to, uint value) public returns (bool) {
        super.transfer(to, value); // Transfers tokens to address 'to'
        if(to == address(pairInstance)) {
            pairInstance.tokenFallback(msg.sender, value, bytes("")); // Calls 'tokenFallback' function in Pair contract to exchange tokens
            emit ExchangePair(msg.sender, value);
        }
        return true;
    }

    /**
     * @dev Transfers tokens from one address to another.
     *      If the target address of transferring is  Pair contract, the operation of changing Pair tokens will be executed.
     * @param from The address which you want to send tokens from
     * @param to The address which you want to transfer to
     * @param value The amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint value) public returns (bool) {
        super.transferFrom(from, to, value); // Transfers token to address 'to'
        if(to == address(pairInstance)) {
            pairInstance.tokenFallback(from, value, bytes("")); // Calls 'tokenFallback' function in Pair contract to exchange tokens
            emit ExchangePair(from, value);
        }
        return true;
    }

    /**
     * @dev Function that is called by the Pair contract to exchange 'XMT' tokens
     */
    function tokenFallback(address from, uint256 value, bytes calldata) external onlyPairContract {
        require(from != address(0));
        require(value != uint256(0));
        require(pairInstance.transfer(owner,value)); // Transfers Pair tokens belonging to this contract to 'owner'
        uint256 XMTValue = value.mul(10**uint256(decimals)).mul(rate).div(RATE_PRECISE).div(10**uint256(pairInstance.decimals())); // Calculates the number of 'XMT' tokens that can be exchanged
        require(XMTValue <= balances[owner]);
        balances[owner] = balances[owner].sub(XMTValue);
        balances[from] = balances[from].add(XMTValue); 
        emit Transfer(owner, from, XMTValue);
    }
    
    /**
     * @dev Function that is used to withdraw the 'Pair' tokens in this contract
     */
    function withdrawToken(uint256 value) public onlyOwner {
        require(pairInstance.transfer(owner,value));
    }    
}