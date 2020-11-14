/**
 * Source Code first verified at https://etherscan.io on Friday, May 10, 2019
 (UTC) */

pragma solidity >=0.4.21 <0.6.0;

contract AdminRole {
    using Roles for Roles.Role;

    event AdminAdded(address indexed account);
    event AdminRemoved(address indexed account);

    Roles.Role private _Admins;
    address private _owner;

    constructor () internal {
        _addAdmin(msg.sender);
        _owner = msg.sender;
    }

    modifier onlyAdmin() {
        require(isAdmin(msg.sender));
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    function addAdmin(address account) public onlyOwner {
        _addAdmin(account);
    }

    function removeAdmin(address account) public onlyOwner {
        _removeAdmin(account);
    }

    function transferOwnership(address account) public onlyOwner returns (bool) {
        _Admins.add(account);
        _owner = account;
        return true;
    }

    function isAdmin(address account) public view returns (bool) {
        return _Admins.has(account);
    }

    function _addAdmin(address account) internal {
        _Admins.add(account);
        emit AdminAdded(account);
    }

    function _removeAdmin(address account) internal {
        _Admins.remove(account);
        emit AdminRemoved(account);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract Equity is IERC20, AdminRole {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    string private _name;
    string private _symbol;
    uint8  private _decimals;
    uint256 private _totalSupply;
    string private _contractHash;
    string private _contractUrl;

    constructor (
        string memory name, 
        string memory symbol, 
        uint8 decimals,
        string memory contractHash, 
        string memory contractUrl) public {

        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _totalSupply = 0;
        _contractHash = contractHash;
        _contractUrl = contractUrl;
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

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
            
    /**
     * @return the contractHash
     */
    function contractHash() public view returns (string memory) {
        return _contractHash;
    }

     /**
     * @return the contractUrl
     */
    function contractUrl() public view returns (string memory) {
        return _contractUrl;
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
    * @dev Destroy the contract
    */
    function Destroy() public onlyAdmin returns (bool) {
        selfdestruct(msg.sender);
        return true;
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
    * @dev sudo Transfer tokens
    * @param from The address to transfer from.
    * @param to The address to transfer to.1
    * @param value The amount to be transferred.
    */
    function sudoTransfer(address from, address to, uint256 value) public onlyAdmin returns (bool) {
        _transfer(from, to, value);
        return true;
    }

    /**
    * @dev Mint tokens
    * @param to The address to mint in.
    * @param value The amount to be minted.
    */
    function Mint(address to, uint256 value) public onlyAdmin returns (bool) {
        _mint(to, value);
        return true;
    }

    /**
    * @dev Burn tokens
    * @param from The address to burn in.
    * @param value The amount to be burned.
    */
    function Burn(address from, uint256 value) public onlyAdmin returns (bool) {
        _burn(from, value);
        return true;
    }

    /**
     * @dev set the contract URL
     * @param newContractUrl The new contract URL.
     */
    function setContractUrl(string memory newContractUrl) public onlyAdmin returns (bool) {
        _contractUrl = newContractUrl;
        return true;
    }

    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0),"0x0 Address");

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
        require(account != address(0),"0x0 Address");

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
        require(account != address(0),"0x0 Address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }
}

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