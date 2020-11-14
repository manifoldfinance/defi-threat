/**
 * Source Code first verified at https://etherscan.io on Thursday, April 18, 2019
 (UTC) */

// File: contracts/Token/IERC20.sol

pragma solidity ^0.4.24;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender) external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value) external returns (bool);

  function transferFrom(address from, address to, uint256 value) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/library/SafeMath.sol

pragma solidity ^0.4.24;

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

// File: contracts/Token/ERC20.sol

pragma solidity ^0.4.24;



/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowed;

    uint256 internal _totalSupply;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
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
    function allowance(
        address owner,
        address spender
    )
        public
        view
        returns (uint256)
    {
        return _allowed[owner][spender];
    }

    /**
    * @dev Transfer token for a specified address
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
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        public
        returns (bool)
    {
        require(value <= _allowed[from][msg.sender]);

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(
        address spender,
        uint256 addedValue
    )
        public
        returns (bool)
    {
        require(spender != address(0));

        _allowed[msg.sender][spender] = (
        _allowed[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    )
        public
        returns (bool)
    {
        require(spender != address(0));

        _allowed[msg.sender][spender] = (
        _allowed[msg.sender][spender].sub(subtractedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function _transfer(address from, address to, uint256 value) internal {
        require(value <= _balances[from]);
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
        require(account != 0);
        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }
}

// File: contracts/library/Ownable.sol

pragma solidity ^0.4.24;

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

// File: contracts/library/Pausable.sol

pragma solidity ^0.4.24;


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

// File: contracts/Token/ERC20Pausable.sol

pragma solidity ^0.4.24;



/**
 * @title Pausable token
 * @dev ERC20 modified with pausable transfers.
 **/
contract ERC20Pausable is ERC20, Pausable {

    function transfer(
        address to,
        uint256 value
    )
        public
        whenNotPaused
        returns (bool)
    {
        return super.transfer(to, value);
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        public
        whenNotPaused
        returns (bool)
    {
        return super.transferFrom(from, to, value);
    }

    function approve(
        address spender,
        uint256 value
    )
        public
        whenNotPaused
        returns (bool)
    {
        return super.approve(spender, value);
    }

    function increaseAllowance(
        address spender,
        uint addedValue
    )
        public
        whenNotPaused
        returns (bool success)
    {
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(
        address spender,
        uint subtractedValue
    )
        public
        whenNotPaused
        returns (bool success)
    {
        return super.decreaseAllowance(spender, subtractedValue);
    }
}

// File: contracts/whitelist/Roles.sol

pragma solidity ^0.4.24;


/**
 * @title Roles
 * @author Francisco Giordano (@frangio)
 * @dev Library for managing addresses assigned to a Role.
 * See RBAC.sol for example usage.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an address access to this role
     */
    function add(Role storage _role, address _addr) internal {
        _role.bearer[_addr] = true;
    }

    /**
     * @dev remove an address' access to this role
     */
    function remove(Role storage _role, address _addr) internal {
        _role.bearer[_addr] = false;
    }

    /**
     * @dev check if an address has this role
     * // reverts
     */
    function check(Role storage _role, address _addr) internal view {
        require(has(_role, _addr));
    }

    /**
     * @dev check if an address has this role
     * @return bool
     */
    function has(Role storage _role, address _addr) internal view returns (bool) {
        return _role.bearer[_addr];
    }
}

// File: contracts/whitelist/RBAC.sol

pragma solidity ^0.4.24;



/**
 * @title RBAC (Role-Based Access Control)
 * @author Matt Condon (@Shrugs)
 * @dev Stores and provides setters and getters for roles and addresses.
 * Supports unlimited numbers of roles and addresses.
 * See //contracts/mocks/RBACMock.sol for an example of usage.
 * This RBAC method uses strings to key roles. It may be beneficial
 * for you to write your own implementation of this interface using Enums or similar.
 */
contract RBAC {
    using Roles for Roles.Role;

    mapping (string => Roles.Role) private roles;

    event RoleAdded(address indexed operator, string role);
    event RoleRemoved(address indexed operator, string role);

    /**
     * @dev reverts if addr does not have role
     * @param _operator address
     * @param _role the name of the role
     * // reverts
     */
    function checkRole(address _operator, string _role)
        public
        view
    {
        roles[_role].check(_operator);
    }

    /**
     * @dev determine if addr has role
     * @param _operator address
     * @param _role the name of the role
     * @return bool
     */
    function hasRole(address _operator, string _role)
        public
        view
        returns (bool)
    {
        return roles[_role].has(_operator);
    }

    /**
     * @dev add a role to an address
     * @param _operator address
     * @param _role the name of the role
     */
    function addRole(address _operator, string _role) internal {
        roles[_role].add(_operator);
        emit RoleAdded(_operator, _role);
    }

    /**
     * @dev remove a role from an address
     * @param _operator address
     * @param _role the name of the role
     */
    function removeRole(address _operator, string _role) internal {
        roles[_role].remove(_operator);
        emit RoleRemoved(_operator, _role);
    }

    /**
     * @dev modifier to scope access to a single role (uses msg.sender as addr)
     * @param _role the name of the role
     * // reverts
     */
    modifier onlyRole(string _role) {
        checkRole(msg.sender, _role);
        _;
    }

}

// File: contracts/whitelist/Whitelist.sol

pragma solidity ^0.4.24;



/**
 * @title Whitelist
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.
 * This simplifies the implementation of "user permissions".
 */
contract Whitelist is Ownable, RBAC {
    string public constant ROLE_WHITELISTED = "whitelist";

    /**
     * @dev Throws if operator is not whitelisted.
     * @param _operator address
     */
    modifier onlyIfWhitelisted(address _operator) {
        checkRole(_operator, ROLE_WHITELISTED);
        _;
    }

    /**
     * @dev add an address to the whitelist
     * @param _operator address
     * @return true if the address was added to the whitelist, false if the address was already in the whitelist
     */
    function addAddressToWhitelist(address _operator)
        public
        onlyOwner
    {
        addRole(_operator, ROLE_WHITELISTED);
    }

    /**
     * @dev getter to determine if address is in whitelist
     */
    function whitelist(address _operator)
        public
        view
        returns (bool)
    {
        return hasRole(_operator, ROLE_WHITELISTED);
    }

    /**
     * @dev add addresses to the whitelist
     * @param _operators addresses
     * @return true if at least one address was added to the whitelist,
     * false if all addresses were already in the whitelist
     */
    function addAddressesToWhitelist(address[] _operators)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < _operators.length; i++) {
            addAddressToWhitelist(_operators[i]);
        }
    }

    /**
     * @dev remove an address from the whitelist
     * @param _operator address
     * @return true if the address was removed from the whitelist,
     * false if the address wasn't in the whitelist in the first place
     */
    function removeAddressFromWhitelist(address _operator)
        public
        onlyOwner
    {
        removeRole(_operator, ROLE_WHITELISTED);
    }

    /**
     * @dev remove addresses from the whitelist
     * @param _operators addresses
     * @return true if at least one address was removed from the whitelist,
     * false if all addresses weren't in the whitelist in the first place
     */
    function removeAddressesFromWhitelist(address[] _operators)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < _operators.length; i++) {
            removeAddressFromWhitelist(_operators[i]);
        }
    }
}

// File: contracts/Xcoin.sol

pragma solidity ^0.4.24;



contract Xcoin is ERC20Pausable {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    mapping (address => bool) private _frozenAccounts;

    Whitelist private _whitelistForBurn;
    Pausable private _pauseForAll;

    event FrozenFunds(address indexed target, bool frozen);
    event WhitelistForBurnChanged(address indexed oldAddress, address indexed newAddress);
    event TransferWithMessage(address from, address to, uint256 value, bytes message);

    // Constructor
    constructor(
        string name,
        string symbol,
        uint8 decimals,
        uint256 initialSupply,
        address tokenHolder,
        address owner,
        address whitelistForBurn,
        address pauseForAll
    )
    public
    {
        _transferOwnership(owner);

        _name = name;
        _symbol = symbol;
        _decimals = decimals;

        _whitelistForBurn = Whitelist(whitelistForBurn);
        _pauseForAll = Pausable(pauseForAll);

        uint256 initialSupplyWithDecimals = initialSupply.mul(10 ** uint256(_decimals));
        _mint(tokenHolder, initialSupplyWithDecimals);
    }

    // Modifier to check _pauseForAll is not true
    modifier whenNotPausedForAll() {
        require(!_pauseForAll.paused(), "pausedForAll is paused");
        _;
    }

    /// @notice Return name of this token
    /// @return token name
    function name() public view returns (string) {
        return _name;
    }

    /// @notice Return symbol of this token
    /// @return token symbol
    function symbol() public view returns (string) {
        return _symbol;
    }

    /// @notice Return decimals of this token
    /// @return token decimals
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /// @notice Return flag whether account is freezed or not
    /// @return true if account is freezed
    function frozenAccounts(address target) public view returns (bool) {
        return _frozenAccounts[target];
    }

    /// @notice Return address of _whitelistForBurn contract
    /// @return _whitelistForBurn address
    function whitelistForBurn() public view returns (address) {
        return _whitelistForBurn;
    }

    /// @notice Return address of _pauseForAll contract
    /// @return _pauseForAll address
    function pauseForAll() public view returns (address) {
        return _pauseForAll;
    }

    /// @notice Change the address of _whitelistForBurn address.
    ///         Owner can only execute this function
    /// @param newWhitelistForBurn new _whitelistForBurn address
    function changeWhitelistForBurn(address newWhitelistForBurn) public onlyOwner {
        address oldWhitelist = _whitelistForBurn;
        _whitelistForBurn = Whitelist(newWhitelistForBurn);
        emit WhitelistForBurnChanged(oldWhitelist, newWhitelistForBurn);
    }

    /// @notice Freezes specific addresses.
    /// @param targets The array of target addresses.
    function freeze(address[] targets) public onlyOwner {
        require(targets.length > 0, "the length of targets is 0");

        for (uint i = 0; i < targets.length; i++) {
            require(targets[i] != address(0), "targets has zero address.");
            _frozenAccounts[targets[i]] = true;
            emit FrozenFunds(targets[i], true);
        }
    }

    /// @notice Unfreezes specific addresses.
    /// @param targets The array of target addresses.
    function unfreeze(address[] targets) public onlyOwner {
        require(targets.length > 0, "the length of targets is 0");

        for (uint i = 0; i < targets.length; i++) {
            require(targets[i] != address(0), "targets has zero address.");
            _frozenAccounts[targets[i]] = false;
            emit FrozenFunds(targets[i], false);
        }
    }

    /// @notice transfer token. If msg.sender is frozen, this function will be reverted.
    /// @param to Target address to transfer token.
    /// @param value Amount of token msg.sender wants to transfer.
    /// @return true if execution works correctly.
    function transfer(address to, uint256 value) public whenNotPaused whenNotPausedForAll returns (bool) {
        require(!frozenAccounts(msg.sender), "msg.sender address is frozen.");
        return super.transfer(to, value);
    }

    /// @notice transfer token with message.
    /// @param to Target address to transfer token.
    /// @param value Amount of token msg.sender wants to transfer.
    /// @param message UTF-8 encoded Message sent from msg.sender to to address.
    /// @return true if execution works correctly.
    function transferWithMessage(
        address to,
        uint256 value,
        bytes message
    )
    public
    whenNotPaused
    whenNotPausedForAll
    returns (bool)
    {
        require(!_frozenAccounts[msg.sender], "msg.sender is frozen");
        emit TransferWithMessage(msg.sender, to, value, message);
        return super.transfer(to, value);
    }

    /// @notice transfer token. If from address is frozen, this function will be reverted.
    /// @param from The sender address.
    /// @param to Target address to transfer token.
    /// @param value Amount of token msg.sender wants to transfer.
    /// @return true if execution works correctly.
    function transferFrom(address from, address to, uint256 value) public whenNotPaused whenNotPausedForAll returns (bool) {
        require(!frozenAccounts(from), "from address is frozen.");
        return super.transferFrom(from, to, value);
    }

    /// @notice Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    ///         Beware that changing an allowance with this method brings the risk that someone may use both the old
    ///         and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    ///         race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    /// @param spender The address which will spend the funds.
    /// @param value The amount of tokens to be spent.
    /// @return true if execution works correctly.
    function approve(address spender, uint256 value) public whenNotPaused whenNotPausedForAll returns (bool) {
        return super.approve(spender, value);
    }

    /// @notice Increase the amount of tokens that an owner allowed to a spender.
    ///         approve should be called when allowed_[_spender] == 0. To increment
    ///         allowed value is better to use this function to avoid 2 calls (and wait until
    ///         the first transaction is mined)
    /// @param spender The address which will spend the funds.
    /// @param addedValue The amount of tokens to increase the allowance by.
    /// @return true if execution works correctly.
    function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused whenNotPausedForAll returns (bool) {
        return super.increaseAllowance(spender, addedValue);
    }

    /// @notice Decrease the amount of tokens that an owner allowed to a spender.
    ///         approve should be called when allowed_[_spender] == 0. To decrement
    ///         allowed value is better to use this function to avoid 2 calls (and wait until
    ///         the first transaction is mined)
    /// @param spender The address which will spend the funds.
    /// @param subtractedValue The amount of tokens to decrease the allowance by.
    /// @return true if execution works correctly.
    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused whenNotPausedForAll returns (bool) {
        return super.decreaseAllowance(spender, subtractedValue);
    }

    /// @notice Function to mint tokens
    ///         Owner can only execute this function.
    /// @param to The address that will receive the minted tokens.
    /// @param value The amount of tokens to mint.
    /// @return A boolean that indicates if the operation was successful.
    function mint(address to, uint256 value) public onlyOwner returns (bool) {
        super._mint(to, value);
        return true;
    }

    /**
    * @dev Burns a specific amount of tokens.
    * @param _value The amount of token to be burned.
    */
    function burn(uint256 _value) public whenNotPaused whenNotPausedForAll {
        require(_whitelistForBurn.whitelist(msg.sender), "msg.sender is not added on whitelist");
        _burn(msg.sender, _value);
    }

    function _burn(address _who, uint256 _value) internal {
        require(_value <= _balances[_who]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        _balances[_who] = _balances[_who].sub(_value);
        _totalSupply = _totalSupply.sub(_value);
        emit Transfer(_who, address(0), _value);
    }
}