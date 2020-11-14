/**
 * Source Code first verified at https://etherscan.io on Tuesday, April 30, 2019
 (UTC) */

pragma solidity 0.5.4;


library SafeMath {

    uint256 constant internal MAX_UINT = 2 ** 256 - 1; // max uint256

    /**
     * @dev Multiplies two numbers, reverts on overflow.
     */
    function mul(uint256 _a, uint256 _b) internal pure returns(uint256) {
        if (_a == 0) {
            return 0;
        }
        require(MAX_UINT / _a >= _b);
        return _a * _b;
    }

    /**
     * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 _a, uint256 _b) internal pure returns(uint256) {
        require(_b != 0);
        return _a / _b;
    }

    /**
     * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 _a, uint256 _b) internal pure returns(uint256) {
        require(_b <= _a);
        return _a - _b;
    }

    /**
     * @dev Adds two numbers, reverts on overflow.
     */
    function add(uint256 _a, uint256 _b) internal pure returns(uint256) {
        require(MAX_UINT - _a >= _b);
        return _a + _b;
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

    event Approval(address indexed owner, address indexed spender, uint256 value);

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


/**
 * @title token
 * @dev Standard template for ERC20 Token
 */
contract Token is PausableToken, BurnableToken {
    string public name; 
    string public symbol; 
    uint8 public decimals;

    /**
     * @dev Constructor, to initialize the basic information of token
     * @param _name The name of token
     * @param _symbol The symbol of token
     * @param _decimals The dicemals of token
     * @param _INIT_TOTALSUPPLY The total supply of token
     */
    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _INIT_TOTALSUPPLY) public {
        totalSupply = _INIT_TOTALSUPPLY * 10 ** uint256(_decimals);
        balances[owner] = totalSupply; // Transfers all tokens to owner
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }
}


/**
 * @dev Interface of BDR contract
 */
interface BDRContract {
    function tokenFallback(address _from, uint256 _value, bytes calldata _data) external;
    function transfer(address _to, uint256 _value) external returns (bool);
    function decimals() external returns (uint8);
}


/**
 * @title IOAEX ENTITY TOKEN
 */
contract IOAEX is Token {
    // The address of BDR contract
    BDRContract public BDRInstance;
    // The total amount of locked tokens at the specified address
    mapping(address => uint256) public totalLockAmount;
    // The released amount of the specified address
    mapping(address => uint256) public releasedAmount;
    // 
    mapping(address => timeAndAmount[]) public allocations;
    // Stores the timestamp and the amount of tokens released each time
    struct timeAndAmount {
        uint256 releaseTime;
        uint256 releaseAmount;
    }
    
    // events
    event LockToken(address _beneficiary, uint256 totalLockAmount);
    event ReleaseToken(address indexed user, uint256 releaseAmount, uint256 releaseTime);
    event ExchangeBDR(address from, uint256 value);
    event SetBDRContract(address BDRInstanceess);

    /**
     * @dev Throws if called by any account other than the BDR contract
     */
    modifier onlyBDRContract() {
        require(msg.sender == address(BDRInstance));
        _;
    }

    /**
     * @dev Constructor, to initialize the basic information of token
     */
    constructor (string memory _name, string memory _symbol, uint8 _decimals, uint256 _INIT_TOTALSUPPLY) Token (_name, _symbol, _decimals, _INIT_TOTALSUPPLY) public {

    }

    /**
     * @dev Sets the address of BDR contract
     */
    function setBDRContract(address BDRAddress) public onlyOwner {
        require(BDRAddress != address(0));
        BDRInstance = BDRContract(BDRAddress);
        emit SetBDRContract(BDRAddress);
    }
    
    /**
     * @dev The owner can call this function to send tokens to the specified address, but these tokens are only available for more than the specified time
     * @param _beneficiary The address to receive tokens
     * @param _releaseTimes Array, the timestamp for releasing token
     * @param _releaseAmount Array, the amount for releasing token 
     */
    function lockToken(address _beneficiary, uint256[] memory _releaseTimes, uint256[] memory _releaseAmount) public onlyOwner returns(bool) {
        
        require(totalLockAmount[_beneficiary] == 0); // The beneficiary is not in any lock-plans at the current timestamp.
        require(_beneficiary != address(0)); // The beneficiary cannot be an empty address
        require(_releaseTimes.length == _releaseAmount.length); // These two lists are equal in length.
        releasedAmount[_beneficiary] = 0;
        for (uint256 i = 0; i < _releaseTimes.length; i++) {
            totalLockAmount[_beneficiary] = totalLockAmount[_beneficiary].add(_releaseAmount[i]);
            require(_releaseAmount[i] > 0); // The amount to release is greater than 0.
            require(_releaseTimes[i] >= now); // Each release time is not lower than the current timestamp.
            // Saves the lock-token information
            allocations[_beneficiary].push(timeAndAmount(_releaseTimes[i], _releaseAmount[i]));
        }
        balances[owner] = balances[owner].sub(totalLockAmount[_beneficiary]); // Removes this part of the locked token from the owner
        emit LockToken(_beneficiary, totalLockAmount[_beneficiary]);
        return true;
    }

    /**
     * Releases token
     */
    function releaseToken() public returns (bool) {
        release(msg.sender); 
    }

    /**
     * @dev The basic function of releasing token
     */
    function release(address addr) internal {
        require(totalLockAmount[addr] > 0); // The address has joined a lock-plan.

        uint256 amount = releasableAmount(addr); // Gets the amount of release and updates the lock-plans data
        // Unlocks token. Converting locked tokens into normal tokens
        balances[addr] = balances[addr].add(amount);
        // Updates the amount of released tokens.
        releasedAmount[addr] = releasedAmount[addr].add(amount);
        // If the token on this address has been completely released, clears the Record of locking token
        if (releasedAmount[addr] == totalLockAmount[addr]) {
            delete allocations[addr];
            totalLockAmount[addr] = 0;
        }
        emit ReleaseToken(addr, amount, now);
    }

    /**
     * @dev Gets the amount that can be released at current timestamps 
     * @param addr A specified address.
     */
    function releasableAmount(address addr) public view returns (uint256) {
        if(totalLockAmount[addr] == 0) {
            return 0;
        }
        uint256 num = 0;
        for (uint256 i = 0; i < allocations[addr].length; i++) {
            if (now >= allocations[addr][i].releaseTime) { // Determines the releasable stage under the current timestamp.
                num = num.add(allocations[addr][i].releaseAmount);
            }
        }
        return num.sub(releasedAmount[addr]); // the amount of current timestamps that can be released - the released amount.
    }
    
    /**
     * @dev Gets the amount of tokens that are still locked at current timestamp.
     * @param addr A specified address.
     */
    function balanceOfLocked(address addr) public view returns(uint256) {
        if (totalLockAmount[addr] > releasedAmount[addr]) {
            return totalLockAmount[addr].sub(releasedAmount[addr]);
        } else {
            return 0;
        }
        
    }

    /**
     * @dev Transfers token to a specified address. 
     *      If 'msg.sender' has releasable tokens, this part of the token will be released automatically.
     *      If the target address of transferring is BDR contract, the operation of changing BDR tokens will be executed.
     * @param to The target address of transfer, which may be the BDR contract
     * @param value The amount of tokens transferred
     */
    function transfer(address to, uint value) public returns (bool) {
        if(releasableAmount(msg.sender) > 0) {
            release(msg.sender); // Calls 'release' function
        }
        super.transfer(to, value); // Transfers tokens to address 'to'
        if(to == address(BDRInstance)) {
            BDRInstance.tokenFallback(msg.sender, value, bytes("")); // Calls 'tokenFallback' function in BDR contract to exchange tokens
            emit ExchangeBDR(msg.sender, value);
        }
        return true;
    }

    /**
     * @dev Transfers tokens from one address to another.
     *      If 'from' has releasable tokens, this part of the token will be released automatically.
     *      If the target address of transferring is  BDR contract, the operation of changing BDR tokens will be executed.
     * @param from The address which you want to send tokens from
     * @param to The address which you want to transfer to
     * @param value The amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint value) public returns (bool) {
        if(releasableAmount(from) > 0) {
            release(from); // Calls the 'release' function
        }
        super.transferFrom(from, to, value); // Transfers token to address 'to'
        if(to == address(BDRInstance)) {
            BDRInstance.tokenFallback(from, value, bytes("")); // Calls 'tokenFallback' function in BDR contract to exchange tokens
            emit ExchangeBDR(from, value);
        }
        return true;
    }

    /**
     * @dev Function that is called by the BDR contract to exchange 'Abc' tokens
     */
    function tokenFallback(address from, uint256 value, bytes calldata) external onlyBDRContract {
        require(from != address(0));
        require(value != uint256(0));
        
        uint256 AbcValue = value.mul(10**uint256(decimals)).div(10**uint256(BDRInstance.decimals())); // Calculates the number of 'Abc' tokens that can be exchanged
        require(AbcValue <= balances[address(BDRInstance)]);
        balances[address(BDRInstance)] = balances[address(BDRInstance)].sub(AbcValue);
        balances[from] = balances[from].add(AbcValue);
        emit Transfer(owner, from, AbcValue);
    }
    
}