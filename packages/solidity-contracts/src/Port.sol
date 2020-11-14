/**
 * Source Code first verified at https://etherscan.io on Thursday, April 25, 2019
 (UTC) */

pragma solidity ^0.5.2;

// File: openzeppelin-solidity/contracts/access/Roles.sol

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

// File: contracts/FoundationOwnable.sol

contract FoundationOwnable is Pausable {

	address public foundation;

	event FoundationTransferred(address oldAddr, address newAddr);

	constructor() public {
		foundation = msg.sender;
	}

	modifier onlyFoundation() {
		require(msg.sender == foundation, 'foundation required');
		_;
	}

	function transferFoundation(address f) public onlyFoundation {
		require(f != address(0), 'empty address');
		emit FoundationTransferred(foundation, f);
		_removePauser(foundation);
		_addPauser(f);
		foundation = f;
	}
}

// File: contracts/TeleportOwnable.sol

contract TeleportOwnable {

	address public teleport;

	event TeleportTransferred(address oldAddr, address newAddr);

	constructor() public {
		teleport = msg.sender;
	}

	modifier onlyTeleport() {
		require(msg.sender == teleport, 'caller not teleport');
		_;
	}

	function transferTeleport(address f) public onlyTeleport {
		require(f != address(0));
		emit TeleportTransferred(teleport, f);
		teleport = f;
	}
}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
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

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
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
    function allowance(address owner, address spender) public view returns (uint256) {
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
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
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
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol

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

// File: contracts/PortedToken.sol

contract PortedToken is TeleportOwnable, ERC20, ERC20Detailed{

	constructor(string memory name, string memory symbol, uint8 decimals)
		public ERC20Detailed(name, symbol, decimals) {}

	function mint(address to, uint256 value) public onlyTeleport {
		super._mint(to, value);
	}

	function burn(address from, uint256 value) public onlyTeleport {
		super._burn(from, value);
	}
}

// File: contracts/Port.sol

// Port is a contract that sends and recieves tokens to implement token
// teleportation between chains.
//
// Naming convention:
// - token: "main" is the original token and "cloned" is the ported one on
//          this/another chain.
// - address: "addr" is the address on this chain and "alt" is the one on
//            another chain.
contract Port is FoundationOwnable {
	// Library
	using SafeMath for uint256;

	// States

	// Beneficiary address is the address that the remaining tokens will be
	// transferred to for selfdestruct.
	address payable public beneficiary;

	// registeredMainTokens stores the tokens that are ported on this chain.
	address[] public registeredMainTokens;

	// registeredClonedTokens stores the ported tokens created by the foundation.
	address[] public registeredClonedTokens;

	// breakoutTokens is an address to address mapping that maps the currencies
	// to break out to the destination contract address on the destination chain.
	// Note that the zero address 0x0 represents the native token in this mapping.
	//
	// mapping structure
	//    main currency address                [this chain]
	// -> alt chain id of cloned token address
	// -> cloned token address                  [alt chain]
	mapping (address => mapping (uint256 => bytes)) public breakoutTokens;

	// breakinTokens is an address to address mapping that maps the ported token
	// contracts on this chain to the currencies on the source chain.
	//
	// mapping structure
	//    cloned token address                   [this chain]
	// -> alt chain id of main currency address
	// -> main currency address                   [alt chain]
	mapping (address => mapping (uint256 => bytes)) public breakinTokens;

	// proofs is an bytes to bool mapping that labels a proof is used, including
	// for withdrawal and mint.
	mapping (bytes => bool) proofs;

	// minPortValue records the minimum allowed porting value for each currency.
	//
	// mapping structure
	//    main/cloned currency address [this chain]
	// -> chain id of main/cloned currency address
	// -> minimum breakout value
	mapping (address => mapping (uint256 => uint256)) public minPortValue;


	// Events

	// A Deposit event is emitted when a user deposits native currency or tokens
	// with value into the Port contract to break out to the dest_addr as ported
	// token with cloned_token as address on the chain with chain_id
	event Deposit(
		uint256 indexed chain_id,        // id of the destination chain.
		bytes indexed cloned_token_hash,
		bytes indexed alt_addr_hash,
		address main_token,              // the source token address
		bytes cloned_token,              // alt token address on the destination chain.
		bytes alt_addr,                  // address of receiving alt token on the dest chain.
		uint256 value                    // value to deposit.
	);

	// A Withdraw event is emitted when a user sends withdrawal transaction
	// with proof to the Port on the destination chain to withdraw native
	// currency or token with value to the dest_addr.
	event Withdraw(
		uint256 indexed chain_id,   // id of the destination chain.
		address indexed main_token, // the source token address on this chain.
		address indexed addr,       // address to withdraw to on this chain.
		bytes proof,                // proof on the destination chain.
		bytes cloned_token,         // the dest token address on alt chain.
		uint256 value               // value to withdraw.
	);

	// A RegisterBreakout event is emitted when the foundation registers a pair
	// of currencies to break out to a destination chain.
	// Note that
	//   - the zero address 0x0 of main_token represents the native currency
	//   - cloned_token must be a PortedToken
	event RegisterBreakout(
		uint256 indexed chain_id,        // id of the destination chain.
		address indexed main_token,      // source token address on this chain.
		bytes indexed cloned_token_hash,
		bytes cloned_token,              // new destination address on the destination chain.
		bytes old_cloned_token,          // old destination address on the destination chain.
		uint256 minValue                 // minimum value to deposit and withdraw.
	);

	// A RegisterBreakin event is emitted when the foundation registers a pair
	// of currencies to break in from a source chain.
	// Note that
	//   - the zero address 0x0 of main_token represents the native currency
	//   - cloned_token must be a PortedToken
	event RegisterBreakin(
		uint256 indexed chain_id,      // id of the source chain.
		address indexed cloned_token,  // destination token address on this chain.
		bytes indexed main_token_hash,
		bytes main_token,              // new source address on the source chain.
		bytes old_main_token,          // old source address on the source chain.
		uint256 minValue               // minimum value to mint and burn.
	);

	// A Mint event is emitted when the foundation mints token with value to the
	// dest_addr as a user sends the transaction with proof on the source chain.
	event Mint(
		uint256 indexed chain_id,     // id of the source chain.
		address indexed cloned_token, // destination token address on this chain.
		address indexed addr,         // destination address to mint to.
		bytes proof,                  // proof of the deposit on the source chain.
		bytes main_token,             // the source token on alt chain.
		uint256 value                 // value to mint.
	);

	// A Burn event is emitted when a user burns broken-in tokens to withdraw to
	// dest_addr on the source chain.
	event Burn(
		uint256 indexed chain_id,      // id of the source chain to burn to.
		bytes indexed main_token_hash,
		bytes indexed alt_addr_hash,
		address cloned_token,          // destination token on this chain.
		bytes main_token,              // source token on the source chain.
		bytes alt_addr,                // destination address on the source chain.
		uint256 value                  // value to burn
	);

	constructor(address payable foundation_beneficiary) public {
		beneficiary = foundation_beneficiary;
	}

	function destruct() public onlyFoundation {
		// transfer all tokens to beneficiary.
		for (uint i=0; i<registeredMainTokens.length; i++) {
			IERC20 token = IERC20(registeredMainTokens[i]);
			uint256 balance = token.balanceOf(address(this));
			token.transfer(beneficiary, balance);
		}

		// transfer the ported tokens' control to the beneficiary
		for (uint i=0; i<registeredClonedTokens.length; i++) {
			PortedToken token = PortedToken(registeredClonedTokens[i]);
			token.transferTeleport(beneficiary);
		}

		selfdestruct(beneficiary);
	}

	modifier breakoutRegistered(uint256 chain_id, address token) {
		require(breakoutTokens[token][chain_id].length != 0, 'unregistered token');
		_;
	}

	modifier breakinRegistered(uint256 chain_id, address token) {
		require(breakinTokens[token][chain_id].length != 0, 'unregistered token');
		_;
	}

	modifier validAmount(uint256 chain_id, address token, uint256 value) {
		require(value >= minPortValue[token][chain_id], "value less than min amount");
		_;
	}

	modifier validProof(bytes memory proof) {
		require(!proofs[proof], 'duplicate proof');
		_;
	}

	function isProofUsed(bytes memory proof) view public returns (bool) {
		return proofs[proof];
	}

	// Caller needs to send at least min value native token when called (payable).
	// A Deposit event will be emitted for the foundation server to mint the
	// corresponding wrapped tokens to the dest_addr on the destination chain.
	//
	// chain_id: The id of destination chain.
	// alt_addr: The address to mint to on the destination chain.
	// value: The value to mint.
	function depositNative(
		uint256 chain_id,
		bytes memory alt_addr
	)
		payable
		public
		whenNotPaused
		breakoutRegistered(chain_id, address(0))
		validAmount(chain_id, address(0), msg.value)
	{
		bytes memory cloned_token = breakoutTokens[address(0)][chain_id];
		emit Deposit(chain_id,
			cloned_token, alt_addr, // indexed bytes value hashed automatically
			address(0), cloned_token, alt_addr, msg.value);
	}

	function () payable external {
		revert('not allowed to send value');
	}

	// Caller needs to provide a proof of the transfer (proof).
	// A Deposit event will be emitted for the foundation server to mint the
	// corresponding wrapped tokens to the dest_addr on the destination chain.
	//
	// main_token: The token to deposit with.
	// chain_id: The id of destination chain.
	// alt_addr: The address to mint to on the destination chain.
	// value: The value to mint.
	function depositToken(
		address main_token,
		uint256 chain_id,
		bytes memory alt_addr,
		uint256 value
	)
		public
		whenNotPaused
		breakoutRegistered(chain_id, main_token)
		validAmount(chain_id, main_token, value)
	{
		bytes memory cloned_token = breakoutTokens[main_token][chain_id];
		emit Deposit(chain_id,
			cloned_token, alt_addr, // indexed bytes value hashed automatically
			main_token, cloned_token, alt_addr, value);

		IERC20 token = IERC20(main_token);
		require(token.transferFrom(msg.sender, address(this), value));
	}

	// Caller needs to provide a proof of the transfer (proof).
	//
	// chain_id: The alt chain where the burn proof is.
	// proof: The proof of the corresponding transaction on the source chain.
	// addr: The address to withdraw to on this chain.
	// value: The value to withdraw.
	function withdrawNative(
		uint256 chain_id,
		bytes memory proof,
		address payable addr,
		uint256 value
	)
		public
		whenNotPaused
		onlyFoundation
		breakoutRegistered(chain_id, address(0))
		validProof(proof)
		validAmount(chain_id, address(0), value)
	{
		bytes memory cloned_token = breakoutTokens[address(0)][chain_id];
		emit Withdraw(chain_id, address(0), addr, proof, cloned_token, value);

		proofs[proof] = true;

		addr.transfer(value);
	}

	// Caller needs to provide a proof of the transfer (proof).
	//
	// chain_id: The alt chain where the burn proof is.
	// proof: The proof of the corresponding transaction on the destination chain.
	// main_token: The address of the token to mint on this chain.
	// addr: The address to withdraw to on this chain.
	// value: The value to withdraw.
	function withdrawToken(
		uint256 chain_id,
		bytes memory proof,
		address main_token,
		address addr,
		uint256 value
	)
		public
		whenNotPaused
		onlyFoundation
		breakoutRegistered(chain_id, main_token)
		validAmount(chain_id, main_token, value)
		validProof(proof)
	{
		bytes memory cloned_token = breakoutTokens[main_token][chain_id];
		emit Withdraw(chain_id, main_token, addr, proof, cloned_token, value);

		proofs[proof] = true;

		IERC20 token = IERC20(main_token);
		require(token.transfer(addr, value));
	}


	// Caller needs to provide the source and the destination of the mapped
	// token contract. The mapping will be updated if the register function is
	// called with a registered source address. The token is revoked if the dest
	// address is set to zero-length bytes.
	//
	// main_token: The address of the token on this chain.
	// chain_id: The id of the chain the cloned token is in.
	// cloned_token: The address of the token on the alt chain (dest chain).
	// old_cloned_token: The original address of the cloned token.
	// minValue: The minimum amount of each deposit/burn can transfer with.
	function registerBreakout(
		address main_token,
		uint256 chain_id,
		bytes memory old_cloned_token,
		bytes memory cloned_token,
		uint256 minValue
	)
		public
		whenNotPaused
		onlyFoundation
	{
		require(keccak256(breakoutTokens[main_token][chain_id]) == keccak256(old_cloned_token), 'wrong old dest');

		emit RegisterBreakout(chain_id, main_token,
			cloned_token, // indexed bytes value is hashed automatically
			cloned_token, old_cloned_token, minValue);

		breakoutTokens[main_token][chain_id] = cloned_token;
		minPortValue[main_token][chain_id] = minValue;

		bool firstTimeRegistration = old_cloned_token.length == 0;
		if (main_token != address(0) && firstTimeRegistration) {
			registeredMainTokens.push(main_token);
		}
	}

	// Caller needs to provide the source and the destination of the mapped
	// token contract. The mapping will be updated if the register function is
	// called with a registered source address. The token is revoked if the dest
	// address is set to zero-length bytes.
	//
	// cloned_token: The address of the token on this chain.
	// chain_id: The id of the chain the main token is in.
	// main_token: The address of the token on the alt chain (source chain).
	// old_main_token: The original address of the main token.
	// minValue: The minimum amount of each deposit/burn can transfer with.
	function registerBreakin(
		address cloned_token,
		uint256 chain_id,
		bytes memory old_main_token,
		bytes memory main_token,
		uint256 minValue
	)
		public
		whenNotPaused
		onlyFoundation
	{
		require(keccak256(breakinTokens[cloned_token][chain_id]) == keccak256(old_main_token), 'wrong old src');

		emit RegisterBreakin(chain_id, cloned_token,
			main_token, // indexed bytes value is hashed automatically
			main_token, old_main_token, minValue);

		breakinTokens[cloned_token][chain_id] = main_token;
		minPortValue[cloned_token][chain_id] = minValue;

		bool firstTimeRegistration = old_main_token.length == 0;
		if (firstTimeRegistration) {
			registeredClonedTokens.push(cloned_token);
		}
	}

	// Caller needs to provide the proof of the Deposit (proof), which
	// can be verified on the source chain with corresponding transaction.
	//
	// chain_id: The id of the chain the main token is in.
	// proof: The proof of the corresponding transaction on alt chain.
	// cloned_token: The address of the token to mint on this chain.
	// addr: The address to mint to on this chain.
	// value: The value to mint.
	function mint(
		uint256 chain_id,
		bytes memory proof,
		address cloned_token,
		address addr,
		uint256 value
	)
		public
		whenNotPaused
		onlyFoundation
		breakinRegistered(chain_id, cloned_token)
		validAmount(chain_id, cloned_token, value)
		validProof(proof)
	{
		bytes memory main_token = breakinTokens[cloned_token][chain_id];
		emit Mint(chain_id, cloned_token, addr, proof, main_token, value);

		proofs[proof] = true;

		PortedToken token = PortedToken(cloned_token);
		token.mint(addr, value);
	}

	// Caller needs to provide the proof of the Burn (proof), which contains
	// proof matching the destination and value.
	//
	// chain_id: The id of the chain the main token is in.
	// cloned_token: The address of the ported token on this chain.
	// alt_addr: The address to withdraw to on altchain.
	// value: The value to withdraw.
	function burn(
		uint256 chain_id,
		address cloned_token,
		bytes memory alt_addr,
		uint256 value
	)
		public
		whenNotPaused
		breakinRegistered(chain_id, cloned_token)
		validAmount(chain_id, cloned_token, value)
	{
		bytes memory main_token = breakinTokens[cloned_token][chain_id];
		emit Burn(chain_id,
			main_token, alt_addr, // indexed value are hashed automatically
			cloned_token, main_token, alt_addr, value);

		PortedToken token = PortedToken(cloned_token);
		token.burn(msg.sender, value);
	}
}