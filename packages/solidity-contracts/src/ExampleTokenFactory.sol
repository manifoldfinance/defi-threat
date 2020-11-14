/**
 * Source Code first verified at https://etherscan.io on Wednesday, May 8, 2019
 (UTC) */

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.2;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
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
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/utils/Utils.sol

/**
 * @title Utilities Contract
 * @author Validity Labs AG <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="620b0c040d2214030e0b060b161b0e0300114c0d1005">[email protected]</a>>
 */
 
pragma solidity ^0.5.7;


contract Utils {
    /** MODIFIERS **/
    /**
     * @notice Check if the address is not zero
     */
    modifier onlyValidAddress(address _address) {
        require(_address != address(0), "Invalid address");
        _;
    }

    /**
     * @notice Check if the address is not the sender's address
    */
    modifier isSenderNot(address _address) {
        require(_address != msg.sender, "Address is the same as the sender");
        _;
    }

    /**
     * @notice Check if the address is the sender's address
    */
    modifier isSender(address _address) {
        require(_address == msg.sender, "Address is different from the sender");
        _;
    }

    /**
     * @notice Controle if a boolean attribute (false by default) was updated to true.
     * @dev This attribute is designed specifically for recording an action.
     * @param criterion The boolean attribute that records if an action has taken place
     */
    modifier onlyOnce(bool criterion) {
        require(criterion == false, "Already been set");
        _;
        criterion = true;
    }
}

// File: contracts/utils/Managed.sol

pragma solidity ^0.5.7;




contract Managed is Utils, Ownable {
    // managers can be set and altered by owner, multiple manager accounts are possible
    mapping(address => bool) public isManager;
    
    /** EVENTS **/
    event ChangedManager(address indexed manager, bool active);

    /*** MODIFIERS ***/
    modifier onlyManager() {
        require(isManager[msg.sender], "not manager");
        _;
    }
    
    /**
     * @dev Set / alter manager / whitelister "account". This can be done from owner only
     * @param manager address address of the manager to create/alter
     * @param active bool flag that shows if the manager account is active
     */
    function setManager(address manager, bool active) public onlyOwner onlyValidAddress(manager) {
        isManager[manager] = active;
        emit ChangedManager(manager, active);
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.2;

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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol

pragma solidity ^0.5.2;


/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.2;

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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.5.2;



/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://eips.ethereum.org/EIPS/eip-20
 * Originally based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 *
 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
 * all accounts just by listening to said events. Note that this isn't required by the specification, and other
 * compliant implementations may not do it.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    /**
     * @dev Total number of tokens in existence
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the balance of.
     * @return A uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
     * @dev Transfer token to a specified address
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
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
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when _allowed[msg.sender][spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when _allowed[msg.sender][spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Transfer token for a specified addresses
     * @param from The address to transfer from.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
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
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Approve an address to spend another addresses' tokens.
     * @param owner The address that owns the tokens.
     * @param spender The address that will spend the tokens.
     * @param value The number of tokens that can be spent.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol

pragma solidity ^0.5.2;


/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract ERC20Burnable is ERC20 {
    /**
     * @dev Burns a specific amount of tokens.
     * @param value The amount of token to be burned.
     */
    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }

    /**
     * @dev Burns a specific amount of tokens from the target address and decrements allowance
     * @param from address The account whose tokens will be burned.
     * @param value uint256 The amount of token to be burned.
     */
    function burnFrom(address from, uint256 value) public {
        _burnFrom(from, value);
    }
}

// File: openzeppelin-solidity/contracts/access/Roles.sol

pragma solidity ^0.5.2;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

// File: openzeppelin-solidity/contracts/access/roles/PauserRole.sol

pragma solidity ^0.5.2;


contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender));
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

pragma solidity ^0.5.2;


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Pausable.sol

pragma solidity ^0.5.2;



/**
 * @title Pausable token
 * @dev ERC20 modified with pausable transfers.
 */
contract ERC20Pausable is ERC20, Pausable {
    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint addedValue) public whenNotPaused returns (bool success) {
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint subtractedValue) public whenNotPaused returns (bool success) {
        return super.decreaseAllowance(spender, subtractedValue);
    }
}

// File: openzeppelin-solidity/contracts/access/roles/MinterRole.sol

pragma solidity ^0.5.2;


contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol

pragma solidity ^0.5.2;



/**
 * @title ERC20Mintable
 * @dev ERC20 minting logic
 */
contract ERC20Mintable is ERC20, MinterRole {
    /**
     * @dev Function to mint tokens
     * @param to The address that will receive the minted tokens.
     * @param value The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address to, uint256 value) public onlyMinter returns (bool) {
        _mint(to, value);
        return true;
    }
}

// File: openzeppelin-solidity/contracts/utils/Address.sol

pragma solidity ^0.5.2;

/**
 * Utility library of inline functions on addresses
 */
library Address {
    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol

pragma solidity ^0.5.2;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require((value == 0) || (token.allowance(address(this), spender) == 0));
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must equal true).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.

        require(address(token).isContract());

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success);

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)));
        }
    }
}

// File: contracts/utils/Reclaimable.sol

/**
 * @title Reclaimable
 * @dev This contract gives owner right to recover any ERC20 tokens accidentally sent to 
 * the token contract. The recovered token will be sent to the owner of token. 
 * @author Validity Labs AG <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="bbd2d5ddd4fbcddad7d2dfd2cfc2d7dad9c895d4c9dc">[email protected]</a>>
 */
// solhint-disable-next-line compiler-fixed, compiler-gt-0_5
pragma solidity ^0.5.7;





contract Reclaimable is Ownable {
    using SafeERC20 for IERC20;

    /**
     * @notice Let the owner to retrieve other tokens accidentally sent to this contract.
     * @dev This function is suitable when no token of any kind shall be stored under
     * the address of the inherited contract.
     * @param tokenToBeRecovered address of the token to be recovered.
     */
    function reclaimToken(IERC20 tokenToBeRecovered) external onlyOwner {
        uint256 balance = tokenToBeRecovered.balanceOf(address(this));
        tokenToBeRecovered.safeTransfer(msg.sender, balance);
    }
}

// File: openzeppelin-solidity/contracts/access/roles/WhitelistAdminRole.sol

pragma solidity ^0.5.2;


/**
 * @title WhitelistAdminRole
 * @dev WhitelistAdmins are responsible for assigning and removing Whitelisted accounts.
 */
contract WhitelistAdminRole {
    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;

    constructor () internal {
        _addWhitelistAdmin(msg.sender);
    }

    modifier onlyWhitelistAdmin() {
        require(isWhitelistAdmin(msg.sender));
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {
        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {
        _addWhitelistAdmin(account);
    }

    function renounceWhitelistAdmin() public {
        _removeWhitelistAdmin(msg.sender);
    }

    function _addWhitelistAdmin(address account) internal {
        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {
        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }
}

// File: openzeppelin-solidity/contracts/access/roles/WhitelistedRole.sol

pragma solidity ^0.5.2;



/**
 * @title WhitelistedRole
 * @dev Whitelisted accounts have been approved by a WhitelistAdmin to perform certain actions (e.g. participate in a
 * crowdsale). This role is special in that the only accounts that can add it are WhitelistAdmins (who can also remove
 * it), and not Whitelisteds themselves.
 */
contract WhitelistedRole is WhitelistAdminRole {
    using Roles for Roles.Role;

    event WhitelistedAdded(address indexed account);
    event WhitelistedRemoved(address indexed account);

    Roles.Role private _whitelisteds;

    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender));
        _;
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _whitelisteds.has(account);
    }

    function addWhitelisted(address account) public onlyWhitelistAdmin {
        _addWhitelisted(account);
    }

    function removeWhitelisted(address account) public onlyWhitelistAdmin {
        _removeWhitelisted(account);
    }

    function renounceWhitelisted() public {
        _removeWhitelisted(msg.sender);
    }

    function _addWhitelisted(address account) internal {
        _whitelisteds.add(account);
        emit WhitelistedAdded(account);
    }

    function _removeWhitelisted(address account) internal {
        _whitelisteds.remove(account);
        emit WhitelistedRemoved(account);
    }
}

// File: openzeppelin-solidity/contracts/math/Math.sol

pragma solidity ^0.5.2;

/**
 * @title Math
 * @dev Assorted math operations
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Calculates the average of two numbers. Since these are integers,
     * averages of an even and odd number cannot be represented, and will be
     * rounded down.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// File: contracts/token/ERC20/library/Snapshots.sol

/**
 * @title Snapshot
 * @dev Utility library of the Snapshot structure, including getting value.
 * @author Validity Labs AG <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="771e1911183701161b1e131e">[email protected]</a>tylabs.org>
 */
pragma solidity ^0.5.7;




library Snapshots {
    using Math for uint256;
    using SafeMath for uint256;

    /**
     * @notice This structure stores the historical value associate at a particular timestamp
     * @param timestamp The timestamp of the creation of the snapshot
     * @param value The value to be recorded
     */
    struct Snapshot {
        uint256 timestamp;
        uint256 value;
    }

    struct SnapshotList {
        Snapshot[] history;
    }

    /** TODO: within 1 block: transfer w/ snapshot, then dividend distrubtion, transfer w/ snapshot
     *
     * @notice This function creates snapshots for certain value...
     * @dev To avoid having two Snapshots with the same block.timestamp, we check if the last
     * existing one is the current block.timestamp, we update the last Snapshot
     * @param item The SnapshotList to be operated
     * @param _value The value associated the the item that is going to have a snapshot
     */
    function createSnapshot(SnapshotList storage item, uint256 _value) internal {
        uint256 length = item.history.length;
        if (length == 0 || (item.history[length.sub(1)].timestamp < block.timestamp)) {
            item.history.push(Snapshot(block.timestamp, _value));
        } else {
            // When the last existing snapshot is ready to be updated
            item.history[length.sub(1)].value = _value;
        }
    }

    /**
     * @notice Find the index of the item in the SnapshotList that contains information
     * corresponding to the timestamp. (FindLowerBond of the array)
     * @dev The binary search logic is inspired by the Arrays.sol from Openzeppelin
     * @param item The list of Snapshots to be queried
     * @param timestamp The timestamp of the queried moment
     * @return The index of the Snapshot array
     */
    function findBlockIndex(
        SnapshotList storage item, 
        uint256 timestamp
    ) 
        internal
        view 
        returns (uint256)
    {
        // Find lower bound of the array
        uint256 length = item.history.length;

        // Return value for extreme cases: If no snapshot exists and/or the last snapshot
        if (item.history[length.sub(1)].timestamp <= timestamp) {
            return length.sub(1);
        } else {
            // Need binary search for the value
            uint256 low = 0;
            uint256 high = length.sub(1);

            while (low < high.sub(1)) {
                uint256 mid = Math.average(low, high);
                // mid will always be strictly less than high and it rounds down
                if (item.history[mid].timestamp <= timestamp) {
                    low = mid;
                } else {
                    high = mid;
                }
            }
            return low;
        }   
    }

    /**
     * @notice This function returns the value of the corresponding Snapshot
     * @param item The list of Snapshots to be queried
     * @param timestamp The timestamp of the queried moment
     * @return The value of the queried moment
     */
    function getValueAt(
        SnapshotList storage item, 
        uint256 timestamp
    )
        internal
        view
        returns (uint256)
    {
        if (item.history.length == 0 || timestamp < item.history[0].timestamp) {
            return 0;
        } else {
            uint256 index = findBlockIndex(item, timestamp);
            return item.history[index].value;
        }
    }
}

// File: contracts/token/ERC20/ERC20Snapshot.sol

/**
 * @title ERC20 Snapshot Token
 * @dev This is an ERC20 compatible token that takes snapshots of account balances.
 * @author Validity Labs AG <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="026b6c646d4274636e6b666b767b6e6360712c6d7065">[email protected]</a>>
 */
pragma solidity ^0.5.7;  




contract ERC20Snapshot is ERC20 {
    using Snapshots for Snapshots.SnapshotList;

    mapping(address => Snapshots.SnapshotList) private _snapshotBalances; 
    Snapshots.SnapshotList private _snapshotTotalSupply;   

    event CreatedAccountSnapshot(address indexed account, uint256 indexed timestamp, uint256 value);
    event CreatedTotalSupplySnapshot(uint256 indexed timestamp, uint256 value);

    /**
     * @notice Return the historical supply of the token at a certain time
     * @param timestamp The block number of the moment when token supply is queried
     * @return The total supply at "timestamp"
     */
    function totalSupplyAt(uint256 timestamp) public view returns (uint256) {
        return _snapshotTotalSupply.getValueAt(timestamp);
    }

    /**
     * @notice Return the historical balance of an account at a certain time
     * @param owner The address of the token holder
     * @param timestamp The block number of the moment when token supply is queried
     * @return The balance of the queried token holder at "timestamp"
     */
    function balanceOfAt(address owner, uint256 timestamp) 
        public 
        view 
        returns (uint256) {
            return _snapshotBalances[owner].getValueAt(timestamp);
        }

    /** OVERRIDE
     * @notice Transfer tokens between two accounts while enforcing the update of Snapshots
     * @param from The address to transfer from
     * @param to The address to transfer to
     * @param value The amount to be transferred
     */
    function _transfer(address from, address to, uint256 value) internal {
        super._transfer(from, to, value); // ERC20 transfer

        _createAccountSnapshot(from, balanceOf(from));
        _createAccountSnapshot(to, balanceOf(to));
    }

    /** OVERRIDE
     * @notice Mint tokens to one account while enforcing the update of Snapshots
     * @param account The address that receives tokens
     * @param value The amount of tokens to be created
     */
    function _mint(address account, uint256 value) internal {
        super._mint(account, value);
        
        _createAccountSnapshot(account, balanceOf(account));
        _createTotalSupplySnapshot(account, totalSupplyAt(block.timestamp).add(value));
    }

    /** OVERRIDE
     * @notice Burn tokens of one account
     * @param account The address whose tokens will be burnt
     * @param value The amount of tokens to be burnt
     */
    function _burn(address account, uint256 value) internal {
        super._burn(account, value);

        _createAccountSnapshot(account, balanceOf(account));
        _createTotalSupplySnapshot(account, totalSupplyAt(block.timestamp).sub(value));
    }

    /**
    * @notice creates a total supply snapshot & emits event
    * @param amount uint256 
    * @param account address
    */
    function _createTotalSupplySnapshot(address account, uint256 amount) internal {
        _snapshotTotalSupply.createSnapshot(amount);

        emit CreatedTotalSupplySnapshot(block.timestamp, amount);
    }

    /**
    * @notice creates an account snapshot & emits event
    * @param amount uint256 
    * @param account address
    */
    function _createAccountSnapshot(address account, uint256 amount) internal {
        _snapshotBalances[account].createSnapshot(amount);

        emit CreatedAccountSnapshot(account, block.timestamp, amount);
    }

    function _precheckSnapshot() internal {
        // FILL LATER TODO: comment on how this is utilized
        // Why it's not being abstract
    }
}

// File: contracts/STO/token/WhitelistedSnapshot.sol

/**
 * @title Whitelisted Snapshot Token
 * @author Validity Labs AG <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="51383f373e1127303d38353825283d3033227f3e2336">[email protected]</a>>
 */
pragma solidity ^0.5.7;




/**
* Whitelisted Snapshot repurposes the following 2 variables inherited from ERC20Snapshot:
* _snapshotBalances: only whitelisted accounts get snapshots
* _snapshotTotalSupply: only the total sum of whitelisted
*/
contract WhitelistedSnapshot is ERC20Snapshot, WhitelistedRole {
    /** OVERRIDE
    * @notice add account to whitelist & create a snapshot of current balance
    * @param account address
    */
    function addWhitelisted(address account) public {
        super.addWhitelisted(account);

        uint256 balance = balanceOf(account);
        _createAccountSnapshot(account, balance);

        uint256 newSupplyValue = totalSupplyAt(now).add(balance);
        _createTotalSupplySnapshot(account, newSupplyValue);
    }
    
    /** OVERRIDE
    * @notice remove account from white & create a snapshot of 0 balance
    * @param account address
    */
    function removeWhitelisted(address account) public {
        super.removeWhitelisted(account);

        _createAccountSnapshot(account, 0);

        uint256 balance = balanceOf(account);
        uint256 newSupplyValue = totalSupplyAt(now).sub(balance);
        _createTotalSupplySnapshot(account, newSupplyValue);
    }

    /** OVERRIDE & call parent
     * @notice Transfer tokens between two accounts while enforcing the update of Snapshots
     * @dev the super._transfer call handles the snapshot of each account. See the internal functions 
     * below: _createTotalSupplySnapshot & _createAccountSnapshot
     * @param from address The address to transfer from
     * @param to address The address to transfer to
     * @param value uint256 The amount to be transferred
     */
    function _transfer(address from, address to, uint256 value) internal {
        // if available will call the sibiling's inherited function before calling the parent's
        super._transfer(from, to, value);

        /**
        * Possibilities:
        * Homogeneous Transfers:
        *   0: _whitelist to _whitelist: 0 total supply snapshot
        *   1: nonwhitelist to nonwhitelist: 0 total supply snapshot
        * Heterogeneous Transfers:
        *   2: _whitelist to nonwhitelist: 1 whitelisted total supply snapshot
        *   3: nonwhitelist to _whitelist: 1 whitelisted total supply snapshot
        */
        // isWhitelistedHetero tells us to/from is a mix of whitelisted/not whitelisted accounts
        // isAdding tell us whether or not to add or subtract from the whitelisted total supply value
        (bool isWhitelistedHetero, bool isAdding) = _isWhitelistedHeterogeneousTransfer(from, to);

        if (isWhitelistedHetero) { // one account is whitelisted, the other is not
            uint256 newSupplyValue = totalSupplyAt(block.timestamp);
            address account;

            if (isAdding) { 
                newSupplyValue = newSupplyValue.add(value);
                account = to;
            } else { 
                newSupplyValue = newSupplyValue.sub(value);
                account = from;
            }

            _createTotalSupplySnapshot(account, newSupplyValue);
        }
    }

    /**
    * @notice returns true (isHetero) for a mix-match of whitelisted & nonwhitelisted account transfers
    * returns true (isAdding) if total supply is increasing or false for decreasing
    * @param from address
    * @param to address
    * @return isHetero, isAdding. bool, bool
    */
    function _isWhitelistedHeterogeneousTransfer(address from, address to) 
        internal 
        view 
        returns (bool isHetero, bool isAdding) {
            bool _isToWhitelisted = isWhitelisted(to);
            bool _isFromWhitelisted = isWhitelisted(from);

            if (!_isFromWhitelisted && _isToWhitelisted) {
                isHetero = true;    
                isAdding = true;    // increase whitelisted total supply
            } else if (_isFromWhitelisted && !_isToWhitelisted) {
                isHetero = true;    
            }
        }

    /** OVERRIDE
    * @notice creates a total supply snapshot & emits event
    * @param amount uint256 
    * @param account address
    */
    function _createTotalSupplySnapshot(address account, uint256 amount) internal {
        if (isWhitelisted(account)) {
            super._createTotalSupplySnapshot(account, amount);
        }
    }

    /** OVERRIDE
    * @notice only snapshot if account is whitelisted
    * @param account address
    * @param amount uint256 
    */
    function _createAccountSnapshot(address account, uint256 amount) internal {
        if (isWhitelisted(account)) {
            super._createAccountSnapshot(account, amount);
        }
    }

    function _precheckSnapshot() internal onlyWhitelisted {}
}

// File: contracts/STO/BaseOptedIn.sol

/**
 * @title Base Opt In
 * @author Validity Labs AG <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="7a13141c153a0c1b16131e130e03161b18095415081d">[email protected]</a>>
 * This allows accounts to "opt out" or "opt in"
 * Defaults everyone to opted in 
 * Example: opt out from onchain dividend payments
 */
pragma solidity ^0.5.7;


contract BaseOptedIn {
    // uint256 = timestamp. Default: 0 = opted in. > 0 = opted out
    mapping(address => uint256) public optedOutAddresses; // whitelisters who've opted to receive offchain dividends

    /** EVENTS **/
    event OptedOut(address indexed account);
    event OptedIn(address indexed account);

    modifier onlyOptedBool(bool isIn) { // true for onlyOptedIn, false for onlyOptedOut
        if (isIn) {
            require(optedOutAddresses[msg.sender] > 0, "already opted in");
        } else {
            require(optedOutAddresses[msg.sender] == 0, "already opted out");
        }
        _;
    }

    /**
    * @notice accounts who have opted out from onchain dividend payments
    */
    function optOut() public onlyOptedBool(false) {
        optedOutAddresses[msg.sender] = block.timestamp;
        
        emit OptedOut(msg.sender);
    }

    /**
    * @notice accounts who previously opted out, who opt back in
    */
    function optIn() public onlyOptedBool(true) {
        optedOutAddresses[msg.sender] = 0;

        emit OptedIn(msg.sender);
    }

    /**
    * @notice returns true if opted in
    * @param account address 
    * @return optedIn bool 
    */
    function isOptedIn(address account) public view returns (bool optedIn) {
        if (optedOutAddresses[account] == 0) {
            optedIn = true;
        }
    }
}

// File: contracts/STO/token/OptedInSnapshot.sol

/**
 * @title Opted In Snapshot
 * @author Validity Labs AG <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="2841464e47685e4944414c415c5144494a5b06475a4f">[email protected]</a>>
 */
pragma solidity ^0.5.7;




/**
* Opted In Snapshot repurposes the following 2 variables inherited from ERC20Snapshot:
* _snapshotBalances: snapshots of opted in accounts
* _snapshotTotalSupply: only the total sum of opted in accounts
*/
contract OptedInSnapshot is ERC20Snapshot, BaseOptedIn {
    /** OVERRIDE
    * @notice accounts who previously opted out, who opt back in
    */
    function optIn() public {
        // protects against TODO: Fill later
        super._precheckSnapshot();
        super.optIn();

        address account = msg.sender;
        uint256 balance = balanceOf(account);
        _createAccountSnapshot(account, balance);

        _createTotalSupplySnapshot(account, totalSupplyAt(now).add(balance));
    }

    /** OVERRIDE
    * @notice call parent f(x) & 
    * create new snapshot for account: setting to 0
    * create new shapshot for total supply: oldTotalSupply.sub(balance)
    */
    function optOut() public {
        // protects against TODO: Fill later
        super._precheckSnapshot();
        super.optOut();

        address account = msg.sender;
        _createAccountSnapshot(account, 0);

        _createTotalSupplySnapshot(account, totalSupplyAt(now).sub(balanceOf(account)));
    }

    /** OVERRIDE
     * @notice Transfer tokens between two accounts while enforcing the update of Snapshots
     * @param from The address to transfer from
     * @param to The address to transfer to
     * @param value The amount to be transferred
     */
    function _transfer(address from, address to, uint256 value) internal {
        // if available will call the sibiling's inherited function before calling the parent's
        super._transfer(from, to, value);

        /**
        * Possibilities:
        * Homogeneous Transfers:
        *   0: opted in to opted in: 0 total supply snapshot
        *   1: opted out to opted out: 0 total supply snapshot
        * Heterogeneous Transfers:
        *   2: opted out to opted in: 1 whitelisted total supply snapshot
        *   3: opted in to opted out: 1 whitelisted total supply snapshot
        */
        // isOptedHetero tells us to/from is a mix of opted in/out accounts
        // isAdding tell us whether or not to add or subtract from the opted in total supply value
        (bool isOptedHetero, bool isAdding) = _isOptedHeterogeneousTransfer(from, to);

        if (isOptedHetero) { // one account is whitelisted, the other is not
            uint256 newSupplyValue = totalSupplyAt(block.timestamp);
            address account;

            if (isAdding) {
                newSupplyValue = newSupplyValue.add(value);
                account = to;
            } else {
                newSupplyValue = newSupplyValue.sub(value);
                account = from;
            }

            _createTotalSupplySnapshot(account, newSupplyValue);
        }
    }

    /**
    * @notice returns true for a mix-match of opted in & opted out transfers. 
    *         if true, returns true/false for increasing either optedIn or opetedOut total supply balances
    * @dev should only be calling if both to and from accounts are whitelisted
    * @param from address
    * @param to address
    * @return isOptedHetero, isOptedInIncrease. bool, bool
    */
    function _isOptedHeterogeneousTransfer(address from, address to) 
        internal 
        view 
        returns (bool isOptedHetero, bool isOptedInIncrease) {
            bool _isToOptedIn = isOptedIn(to);
            bool _isFromOptedIn = isOptedIn(from);
            
            if (!_isFromOptedIn && _isToOptedIn) {
                isOptedHetero = true;    
                isOptedInIncrease = true;    // increase opted in total supply
            } else if (_isFromOptedIn && !_isToOptedIn) {
                isOptedHetero = true; 
            }
        }

    /** OVERRIDE
    * @notice creates a total supply snapshot & emits event
    * @param amount uint256 
    * @param account address
    */
    function _createTotalSupplySnapshot(address account, uint256 amount) internal {
        if (isOptedIn(account)) {
            super._createTotalSupplySnapshot(account, amount);
        }
    }

    /** OVERRIDE
    * @notice only snapshot if opted in
    * @param account address
    * @param amount uint256 
    */
    function _createAccountSnapshot(address account, uint256 amount) internal {
        if (isOptedIn(account)) {
            super._createAccountSnapshot(account, amount);
        }
    }
}

// File: contracts/STO/token/ERC20ForceTransfer.sol

/**
 * @title ERC20 ForceTransfer
 * @author Validity Labs AG <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a8c1c6cec7e8dec9c4c1ccc1dcd1c4c9cadb86c7dacf">[email protected]</a>>
 */
pragma solidity ^0.5.7;  




/**
* @dev inherit contract, create external/public function that calls these internal functions
* to activate the ability for one or both forceTransfer implementations
*/
contract ERC20ForceTransfer is Ownable, ERC20 {
    event ForcedTransfer(address indexed confiscatee, uint256 amount, address indexed receiver);

    /**
    * @notice takes all funds from confiscatee and sends them to receiver
    * @param confiscatee address who's funds are being confiscated
    * @param receiver address who's receiving the funds 
    */
    function forceTransfer(address confiscatee, address receiver) external onlyOwner {
        uint256 balance = balanceOf(confiscatee);
        _transfer(confiscatee, receiver, balance);

        emit ForcedTransfer(confiscatee, balance, receiver);
    }

    /**
    * @notice takes an amount of funds from confiscatee and sends them to receiver
    * @param confiscatee address who's funds are being confiscated
    * @param receiver address who's receiving the funds 
    */
    function forceTransfer(address confiscatee, address receiver, uint256 amount) external onlyOwner {
        _transfer(confiscatee, receiver, amount);

        emit ForcedTransfer(confiscatee, amount, receiver);
    }
}

// File: contracts/STO/BaseDocumentRegistry.sol

/**
 * @title Base Document Registry Contract
 * @author Validity Labs AG <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="d9b0b7bfb699afb8b5b0bdb0ada0b5b8bbaaf7b6abbe">[email protected]</a>>
 * inspired by Neufund's iAgreement smart contract
 */
pragma solidity ^0.5.7;




// solhint-disable not-rely-on-time
contract BaseDocumentRegistry is Ownable {
    using SafeMath for uint256;
    
    struct HashedDocument {
        uint256 timestamp;
        string documentUri;
    }

    HashedDocument[] private _documents;

    event AddedLogDocumented(string documentUri, uint256 documentIndex);

    /**
    * @notice adds a document's uri from IPFS to the array
    * @param documentUri string
    */
    function addDocument(string calldata documentUri) external onlyOwner {
        require(bytes(documentUri).length > 0, "invalid documentUri");

        HashedDocument memory document = HashedDocument({
            timestamp: block.timestamp,
            documentUri: documentUri
        });

        _documents.push(document);

        emit AddedLogDocumented(documentUri, _documents.length.sub(1));
    }

    /**
    * @notice fetch the latest document on the array
    * @return uint256, string, uint256 
    */
    function currentDocument() 
        public 
        view 
        returns (uint256 timestamp, string memory documentUri, uint256 index) {
            require(_documents.length > 0, "no documents exist");
            uint256 last = _documents.length.sub(1);

            HashedDocument storage document = _documents[last];
            return (document.timestamp, document.documentUri, last);
        }

    /**
    * @notice adds a document's uri from IPFS to the array
    * @param documentIndex uint256
    * @return uint256, string, uint256 
    */
    function getDocument(uint256 documentIndex) 
        public 
        view
        returns (uint256 timestamp, string memory documentUri, uint256 index) {
            require(documentIndex < _documents.length, "invalid index");

            HashedDocument storage document = _documents[documentIndex];
            return (document.timestamp, document.documentUri, documentIndex);
        }

    /**
    * @notice return the total amount of documents in the array
    * @return uint256
    */
    function documentCount() public view returns (uint256) {
        return _documents.length;
    }
}

// File: contracts/examples/ExampleSecurityToken.sol

/**
 * @title Example Security Token
 * @author Validity Labs AG <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="721b1c141d3204131e1b161b060b1e1310015c1d0015">[email protected]</a>>
 */
pragma solidity ^0.5.7;












contract ExampleSecurityToken is 
    Utils, 
    Reclaimable, 
    ERC20Detailed, 
    WhitelistedSnapshot, 
    OptedInSnapshot,
    ERC20Mintable, 
    ERC20Burnable, 
    ERC20Pausable,
    ERC20ForceTransfer,
    BaseDocumentRegistry {
    
    bool private _isSetup;

    /**
    * @notice contructor for the token contract
    */
    constructor(string memory name, string memory symbol, address initialAccount, uint256 initialBalance) 
        public
        ERC20Detailed(name, symbol, 0) {
            // pause();
            _mint(initialAccount, initialBalance);
            roleSetup(initialAccount);
        }

    /**
    * @notice setup roles and contract addresses for the new token
    * @param board Address of the owner who is also a manager 
    */
    function roleSetup(address board) internal onlyOwner onlyOnce(_isSetup) {   
        addMinter(board);
        addPauser(board);
        _addWhitelistAdmin(board);
    }

    /** OVERRIDE - onlyOwner role (the board) can call 
     * @notice Burn tokens of one account
     * @param account The address whose tokens will be burnt
     * @param value The amount of tokens to be burnt
     */
    function _burn(address account, uint256 value) internal onlyOwner {
        super._burn(account, value);
    } 
}

// File: contracts/STO/dividends/Dividends.sol

/**
 * @title Dividend contract for STO
 * @author Validity Labs AG <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="4920272f26093f2825202d203d3025282b3a67263b2e">[email protected]</a>>
 */
pragma solidity ^0.5.7;








contract Dividends is Utils, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public _wallet;  // set at deploy time
    
    struct Dividend {
        uint256 recordDate;     // timestamp of the record date
        uint256 claimPeriod;    // claim period, in seconds, of the claiming period
        address payoutToken;    // payout token, which could be different each time.
        uint256 payoutAmount;   // the total amount of tokens deposit
        uint256 claimedAmount;  // the total amount of tokens being claimed
        uint256 totalSupply;    // the total supply of sto token when deposit was made
        bool reclaimed;          // If the unclaimed deposit was reclaimed by the team
        mapping(address => bool) claimed; // If investors have claimed their dividends.
    }

    address public _token;
    Dividend[] public dividends;

    // Record the balance of each ERC20 token deposited to this contract as dividends.
    mapping(address => uint256) public totalBalance;

    // EVENTS
    event DepositedDividend(uint256 indexed dividendIndex, address indexed payoutToken, uint256 payoutAmount, uint256 recordDate, uint256 claimPeriod);
    event ReclaimedDividend(uint256 indexed dividendIndex, address indexed claimer, uint256 claimedAmount);
    event RecycledDividend(uint256 indexed dividendIndex, uint256 timestamp, uint256 recycledAmount);

    /**
     * @notice Check if the index is valid
     */
    modifier validDividendIndex(uint256 _dividendIndex) {
        require(_dividendIndex < dividends.length, "Such dividend does not exist");
        _;
    } 

    /**
    * @notice initialize the Dividend contract with the STO Token contract and the new owner
    * @param stoToken The token address, of which the holders could claim dividends.
    * @param wallet the address of the wallet to receive the reclaimed funds
    */
    /* solhint-disable */
    constructor(address stoToken, address wallet) public onlyValidAddress(stoToken) onlyValidAddress(wallet) {
        _token = stoToken;
        _wallet = wallet;
        transferOwnership(wallet);
    }
    /* solhint-enable */

    /**
    * @notice deposit payoutDividend tokens (ERC20) into this contract
    * @param payoutToken ERC20 address of the token used for payout the current dividend 
    * @param amount uint256 total amount of the ERC20 tokens deposited to payout to all 
    * token holders as of previous block from when this function is included
    * @dev The owner should first call approve(STODividendsContractAddress, amount) 
    * in the payoutToken contract
    */
    function depositDividend(address payoutToken, uint256 recordDate, uint256 claimPeriod, uint256 amount)
        public
        onlyOwner
        onlyValidAddress(payoutToken)
    {
        require(amount > 0, "invalid deposit amount");
        require(recordDate > 0, "invalid recordDate");
        require(claimPeriod > 0, "invalid claimPeriod");

        IERC20(payoutToken).safeTransferFrom(msg.sender, address(this), amount);     // transfer ERC20 to this contract
        totalBalance[payoutToken] = totalBalance[payoutToken].add(amount); // update global balance of ERC20 token

        dividends.push(
            Dividend(
                recordDate,
                claimPeriod,
                payoutToken,
                amount,
                0,
                ERC20Snapshot(_token).totalSupplyAt(block.timestamp), //eligible supply
                false
            )
        );

        emit DepositedDividend((dividends.length).sub(1), payoutToken, amount, block.timestamp, claimPeriod);
    }

    /** TODO: check for "recycle" or "recycled" - replace with reclaimed
     * @notice Token holder claim their dividends
     * @param dividendIndex The index of the deposit dividend to be claimed.
     */
    function claimDividend(uint256 dividendIndex) 
        public 
        validDividendIndex(dividendIndex) 
    {
        Dividend storage dividend = dividends[dividendIndex];
        require(dividend.claimed[msg.sender] == false, "Dividend already claimed");
        require(dividend.reclaimed == false, "Dividend already reclaimed");
        require((dividend.recordDate).add(dividend.claimPeriod) >= block.timestamp, "No longer claimable");

        _claimDividend(dividendIndex, msg.sender);
    }

    /**
     * @notice Claim dividends from a startingIndex to all possible dividends
     * @param startingIndex The index from which the loop of claiming dividend starts
     * @dev To claim all dividends from the beginning, set this value to 0.
     * This parameter may help reducing the risk of running out-of-gas due to many loops
     */
    function claimAllDividends(uint256 startingIndex) 
        public 
        validDividendIndex(startingIndex) 
    {
        for (uint256 i = startingIndex; i < dividends.length; i++) {
            Dividend storage dividend = dividends[i];

            if (dividend.claimed[msg.sender] == false 
                && (dividend.recordDate).add(dividend.claimPeriod) >= block.timestamp && dividend.reclaimed == false) {
                _claimDividend(i, msg.sender);
            }
        }
    }

    /**
     * @notice recycle the dividend. Transfer tokens back to the _wallet
     * @param dividendIndex the storage index of the dividend in the pushed array.
     */
    function reclaimDividend(uint256 dividendIndex) 
        public
        onlyOwner
        validDividendIndex(dividendIndex)     
    {
        Dividend storage dividend = dividends[dividendIndex];
        require(dividend.reclaimed == false, "Dividend already reclaimed");
        require((dividend.recordDate).add(dividend.claimPeriod) < block.timestamp, "Still claimable");

        dividend.reclaimed = true;
        uint256 recycledAmount = (dividend.payoutAmount).sub(dividend.claimedAmount);
        totalBalance[dividend.payoutToken] = totalBalance[dividend.payoutToken].sub(recycledAmount);
        IERC20(dividend.payoutToken).safeTransfer(_wallet, recycledAmount);

        emit RecycledDividend(dividendIndex, block.timestamp, recycledAmount);
    }

    /**
    * @notice get dividend info at index
    * @param dividendIndex the storage index of the dividend in the pushed array. 
    * @return recordDate (uint256) of the dividend
    * @return claimPeriod (uint256) of the dividend
    * @return payoutToken (address) of the dividend
    * @return payoutAmount (uint256) of the dividend
    * @return claimedAmount (uint256) of the dividend
    * @return the total supply (uint256) of the dividend
    * @return Whether this dividend was reclaimed (bool) of the dividend
    */
    function getDividend(uint256 dividendIndex) 
        public
        view 
        validDividendIndex(dividendIndex)
        returns (uint256, uint256, address, uint256, uint256, uint256, bool)
    {
        Dividend memory result = dividends[dividendIndex];
        return (
            result.recordDate,
            result.claimPeriod,
            address(result.payoutToken),
            result.payoutAmount,
            result.claimedAmount,
            result.totalSupply,
            result.reclaimed);
    }

    /**
     * @notice Internal function that claim the dividend
     * @param dividendIndex the index of the dividend to be claimed
     * @param account address of the account to receive dividend
     */
    function _claimDividend(uint256 dividendIndex, address account) internal {
        Dividend storage dividend = dividends[dividendIndex];

        uint256 claimAmount = _calcClaim(dividendIndex, account);
        
        dividend.claimed[account] = true;
        dividend.claimedAmount = (dividend.claimedAmount).add(claimAmount);
        totalBalance[dividend.payoutToken] = totalBalance[dividend.payoutToken].sub(claimAmount);

        IERC20(dividend.payoutToken).safeTransfer(account, claimAmount);
        emit ReclaimedDividend(dividendIndex, account, claimAmount);
    }

    /**
    * @notice calculate dividend claim amount
    */
    function _calcClaim(uint256 dividendIndex, address account) internal view returns (uint256) {
        Dividend memory dividend = dividends[dividendIndex];

        uint256 balance = ERC20Snapshot(_token).balanceOfAt(account, dividend.recordDate);
        return balance.mul(dividend.payoutAmount).div(dividend.totalSupply);
    }
}

// File: contracts/examples/ExampleTokenFactory.sol

/**
 * @title Example Token Factory Contract
 * @author Validity Labs AG <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="5e373038311e283f32373a372a27323f3c2d70312c39">[email protected]</a>>
 */

pragma solidity 0.5.7;





/* solhint-disable max-line-length */
/* solhint-disable separate-by-one-line-in-contract */
contract ExampleTokenFactory is Managed {

    mapping(address => address) public tokenToDividend;

    /*** EVENTS ***/
    event DeployedToken(address indexed contractAddress, string name, string symbol, address indexed clientOwner);
    event DeployedDividend(address indexed contractAddress);
   
    /*** FUNCTIONS ***/
    function newToken(string calldata _name, string calldata _symbol, address _clientOwner, uint256 _initialAmount) external onlyOwner {
        address tokenAddress = _deployToken(_name, _symbol, _clientOwner, _initialAmount);
    }

    function newTokenAndDividend(string calldata _name, string calldata _symbol, address _clientOwner, uint256 _initialAmount) external onlyOwner {
        address tokenAddress = _deployToken(_name, _symbol, _clientOwner, _initialAmount);
        address dividendAddress = _deployDividend(tokenAddress, _clientOwner);
        tokenToDividend[tokenAddress] = dividendAddress;
    }
    
    /** MANGER FUNCTIONS **/
    /**
    * @notice Prospectus and Quarterly Reports 
    * @dev string null check is done at the token level - see ERC20DocumentRegistry
    * @param _est address of the targeted EST
    * @param _documentUri string IPFS URI to the document
    */
    function addDocument(address _est, string calldata _documentUri) external onlyValidAddress(_est) onlyManager {
        ExampleSecurityToken(_est).addDocument(_documentUri);
    }

    /**
    * @notice pause or unpause individual EST
    * @param _est address of the targeted EST
    */
    function togglePauseEST(address _est) public onlyValidAddress(_est) onlyManager {
        ExampleSecurityToken est = ExampleSecurityToken(_est);
        bool result = est.paused();
        result ? est.unpause() : est.pause();
    }

    /**
    * @notice force the transfer of tokens from _confiscatee to _receiver
    * @param _est address of the targeted EST
    * @param _confiscatee address to confiscate tokens from
    * @param _receiver address to receive the balance of tokens
    * @param _amount uint256 amount to take away from _confiscatee
    */
    function forceTransferEST(address _est, address _confiscatee, address _receiver, uint256 _amount) 
        public 
        onlyValidAddress(_est) 
        onlyValidAddress(_confiscatee)
        onlyValidAddress(_receiver)
        onlyManager {
            require(_amount > 0, "invalid amount");

            ExampleSecurityToken est = ExampleSecurityToken(_est);
            est.forceTransfer(_confiscatee, _receiver, _amount);
        }

    function _deployToken(string memory _name, string memory _symbol, address _clientOwner, uint256 _initialAmount) internal returns (address) {
        require(bytes(_name).length > 0, "name cannot be blank");
        require(bytes(_symbol).length > 0, "symbol cannot be blank");

        ExampleSecurityToken tokenContract = new ExampleSecurityToken(_name, _symbol, _clientOwner, _initialAmount);
        
        emit DeployedToken(address(tokenContract), _name, _symbol, _clientOwner);
        return address(tokenContract);
    }

    function _deployDividend(address tokenAddress, address wallet) internal returns (address) {
        Dividends dividendContract = new Dividends(tokenAddress, wallet);

        emit DeployedDividend(address(dividendContract));
        return address(dividendContract);
    }
}