/**
 * Source Code first verified at https://etherscan.io on Tuesday, April 9, 2019
 (UTC) */

pragma solidity 0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner and manager address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;
    address public manager;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event ManagerTransfer(address indexed oldaddr, address indexed newaddr);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
        manager = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyManager() {
        require(msg.sender == manager);
        _;
    }
    modifier onlyAdmin() {
        require(msg.sender == owner || msg.sender == manager);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param _newOwner The address to transfer ownership to.
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    function transferManager(address _newManager) onlyAdmin public {
        require(_newManager != address(0));
        emit ManagerTransfer(manager, _newManager);
        manager = _newManager;
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param _newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

contract Pausable is Ownable {

    event Pause();
    event Unpause();

    bool public paused = false;

    /**
     * @dev modifier to allow actions only when the contract IS paused
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev modifier to allow actions only when the contract IS NOT paused
     */
    modifier whenPaused {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() onlyOwner whenNotPaused public returns (bool) {
        paused = true;
        emit Pause();
        return true;
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() onlyOwner whenPaused public returns (bool) {
        paused = false;
        emit Unpause();
        return true;
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
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
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

library ContractLib {
    /*
    * assemble the given address bytecode. If bytecode exists then the _addr is a contract.
    */
    function isContract(address _addr) internal view returns (bool) {
        uint length;
        assembly {
        //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
        }
        return (length > 0);
    }
}

/*
* Contract that is working with ERC223 tokens
*/
contract ContractReceiver {
    function tokenFallback(address _from, uint _value, bytes _data) public pure;
}

// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
contract ERC20Interface {

    function totalSupply() public constant returns (uint);

    function balanceOf(address tokenOwner) public constant returns (uint);

    function allowance(address tokenOwner, address spender) public constant returns (uint);

    function transfer(address to, uint tokens) public returns (bool);

    function approve(address spender, uint tokens) public returns (bool);

    function transferFrom(address from, address to, uint tokens) public returns (bool);

    function name() public constant returns (string);

    function symbol() public constant returns (string);

    function decimals() public constant returns (uint8);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}


/**
* ERC223 token by Dexaran
*
* https://github.com/Dexaran/ERC223-token-standard
*/

contract ERC223 is ERC20Interface {

    function transfer(address to, uint value, bytes data) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Transfer(address indexed from, address indexed to, uint value, bytes data);

}

contract Lock is Ownable {
    bool public useLock = true;
    //accounts that is locked
    mapping(address => bool) public lockedAccount;

    event Locked(address indexed target, bool locked);
    modifier tokenLock() {
        if (useLock == true) {
            require(!lockedAccount[msg.sender], "account is locked");
        }
        _;
    }

    function setLockToken(bool _lock) onlyAdmin public {
        useLock = _lock;
    }

    function lockAccounts(address[] targets) onlyAdmin public returns (bool){
        for (uint8 i = 0; i < targets.length; i++) {
            lockedAccount[targets[i]] = true;
            emit Locked(targets[i], true);
        }
        return true;
    }

    function unlockAccounts(address[] targets) onlyAdmin public returns (bool){
        for (uint8 i = 0; i < targets.length; i++) {
            lockedAccount[targets[i]] = false;
            emit Locked(targets[i], false);
        }
        return true;
    }
}

contract ACCToken is ERC223, Lock, Pausable {

    using SafeMath for uint256;
    using ContractLib for address;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    event Burn(address indexed from, uint256 value);

    constructor() public {
        symbol = "ACC";
        name = "AlphaCityCoin";
        decimals = 18;
        totalSupply = 100000000000 * 1 ether;
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // Function to access name of token .
    function name() public constant returns (string) {
        return name;
    }

    // Function to access symbol of token .
    function symbol() public constant returns (string) {
        return symbol;
    }

    // Function to access decimals of token .
    function decimals() public constant returns (uint8) {
        return decimals;
    }

    // Function to access total supply of tokens .
    function totalSupply() public constant returns (uint256) {
        return totalSupply;
    }

    // Function that is called when a user or another contract wants to transfer funds .
    function transfer(address _to, uint _value, bytes _data) public whenNotPaused tokenLock returns (bool) {
        require(_to != 0x0);
        if (_to.isContract()) {
            return transferToContract(_to, _value, _data);
        }
        else {
            return transferToAddress(_to, _value, _data);
        }
    }

    // Standard function transfer similar to ERC20 transfer with no _data .
    // Added due to backwards compatibility reasons .
    function transfer(address _to, uint _value) public whenNotPaused tokenLock returns (bool) {
        require(_to != 0x0);

        bytes memory empty;
        if (_to.isContract()) {
            return transferToContract(_to, _value, empty);
        }
        else {
            return transferToAddress(_to, _value, empty);
        }
    }

    // function that is called when transaction target is an address
    function transferToAddress(address _to, uint _value, bytes _data) private returns (bool) {
        balances[msg.sender] = balanceOf(msg.sender).sub(_value);
        balances[_to] = balanceOf(_to).add(_value);
        emit Transfer(msg.sender, _to, _value);
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }

    // function that is called when transaction target is a contract
    function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
        balances[msg.sender] = balanceOf(msg.sender).sub(_value);
        balances[_to] = balanceOf(_to).add(_value);
        ContractReceiver receiver = ContractReceiver(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
        emit Transfer(msg.sender, _to, _value);
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }

    // get the address of balance
    function balanceOf(address _owner) public constant returns (uint) {
        return balances[_owner];
    }

    function burn(uint256 _value) public whenNotPaused returns (bool) {
        require(_value > 0);
        require(balanceOf(msg.sender) >= _value);
        // Check if the sender has enough
        balances[msg.sender] = balanceOf(msg.sender).sub(_value);
        // Subtract from the sender
        totalSupply = totalSupply.sub(_value);
        // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }

    ///@dev Token owner can approve for `spender` to transferFrom() `tokens`
    ///from the token owner's account
    function approve(address spender, uint tokens) public whenNotPaused returns (bool) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function increaseApproval(address _spender, uint _addedValue) public whenNotPaused
    returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused
    returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    ///@dev Transfer `tokens` from the `from` account to the `to` account
    function transferFrom(address from, address to, uint tokens) public whenNotPaused tokenLock returns (bool) {
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[from] = balances[from].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public constant returns (uint) {
        return allowed[tokenOwner][spender];
    }

    function() public payable {
        revert();
    }

    // Owner can transfer out any accidentally sent ERC20 tokens
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }

}