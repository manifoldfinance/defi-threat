/**
 * Source Code first verified at https://etherscan.io on Tuesday, May 7, 2019
 (UTC) */

pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		if (a == 0) {
			return 0;
		}
		uint256 c = a * b;
		assert(c / a == b);
		return c;
	}

	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		// assert(b > 0); // Solidity automatically throws when dividing by 0
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold
		return c;
	}

	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}
}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract TokenERC20 {
	// Public variables of the token
	string public name;
	string public symbol;
	uint8 public decimals = 18;
	// 18 decimals is the strongly suggested default, avoid changing it
	uint256 public totalSupply;

	// This creates an array with all balances
	mapping (address => uint256) public balanceOf;
	mapping (address => mapping (address => uint256)) public allowance;

	// This generates a public event on the blockchain that will notify clients
	event Transfer(address indexed from, address indexed to, uint256 value);

	// This generates a public event on the blockchain that will notify clients
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);

	// This notifies clients about the amount burnt
	event Burn(address indexed from, uint256 value);

	/**
	 * Constructor function
	 *
	 * Initializes contract with initial supply tokens to the creator of the contract
	 */
	constructor(
		uint256 initialSupply,
		string tokenName,
		string tokenSymbol
	) public {
		totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
		balanceOf[msg.sender] = totalSupply;                // Give the creator all initial tokens
		name = tokenName;                                   // Set the name for display purposes
		symbol = tokenSymbol;                               // Set the symbol for display purposes
	}

	/**
	 * Internal transfer, only can be called by this contract
	 */
	function _transfer(address _from, address _to, uint _value) internal {
		// Prevent transfer to 0x0 address. Use burn() instead
		require(_to != 0x0);
		// Check if the sender has enough
		require(balanceOf[_from] >= _value);
		// Check for overflows
		require(balanceOf[_to] + _value > balanceOf[_to]);
		// Save this for an assertion in the future
		uint previousBalances = balanceOf[_from] + balanceOf[_to];
		// Subtract from the sender
		balanceOf[_from] -= _value;
		// Add the same to the recipient
		balanceOf[_to] += _value;
		emit Transfer(_from, _to, _value);
		// Asserts are used to use static analysis to find bugs in your code. They should never fail
		assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
	}

	/**
	 * Transfer tokens
	 *
	 * Send `_value` tokens to `_to` from your account
	 *
	 * @param _to The address of the recipient
	 * @param _value the amount to send
	 */
	function transfer(address _to, uint256 _value) public returns (bool success) {
		_transfer(msg.sender, _to, _value);
		return true;
	}

	/**
	 * Transfer tokens from other address
	 *
	 * Send `_value` tokens to `_to` in behalf of `_from`
	 *
	 * @param _from The address of the sender
	 * @param _to The address of the recipient
	 * @param _value the amount to send
	 */
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
		require(_value <= allowance[_from][msg.sender]);     // Check allowance
		allowance[_from][msg.sender] -= _value;
		_transfer(_from, _to, _value);
		return true;
	}

	/**
	 * Set allowance for other address
	 *
	 * Allows `_spender` to spend no more than `_value` tokens in your behalf
	 *
	 * @param _spender The address authorized to spend
	 * @param _value the max amount they can spend
	 */
	function approve(address _spender, uint256 _value) public returns (bool success) {
		allowance[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;
	}

	/**
	 * Set allowance for other address and notify
	 *
	 * Allows `_spender` to spend no more than `_value` tokens in your behalf, and then ping the contract about it
	 *
	 * @param _spender The address authorized to spend
	 * @param _value the max amount they can spend
	 * @param _extraData some extra information to send to the approved contract
	 */
	function approveAndCall(address _spender, uint256 _value, bytes _extraData)
		public
		returns (bool success) {
		tokenRecipient spender = tokenRecipient(_spender);
		if (approve(_spender, _value)) {
			spender.receiveApproval(msg.sender, _value, this, _extraData);
			return true;
		}
	}

	/**
	 * Destroy tokens
	 *
	 * Remove `_value` tokens from the system irreversibly
	 *
	 * @param _value the amount of money to burn
	 */
	function burn(uint256 _value) public returns (bool success) {
		require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
		balanceOf[msg.sender] -= _value;            // Subtract from the sender
		totalSupply -= _value;                      // Updates totalSupply
		emit Burn(msg.sender, _value);
		return true;
	}

	/**
	 * Destroy tokens from other account
	 *
	 * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
	 *
	 * @param _from the address of the sender
	 * @param _value the amount of money to burn
	 */
	function burnFrom(address _from, uint256 _value) public returns (bool success) {
		require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
		require(_value <= allowance[_from][msg.sender]);    // Check allowance
		balanceOf[_from] -= _value;                         // Subtract from the targeted balance
		allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
		totalSupply -= _value;                              // Update totalSupply
		emit Burn(_from, _value);
		return true;
	}
}

contract developed {
	address public developer;

	/**
	 * Constructor
	 */
	constructor() public {
		developer = msg.sender;
	}

	/**
	 * @dev Checks only developer address is calling
	 */
	modifier onlyDeveloper {
		require(msg.sender == developer);
		_;
	}

	/**
	 * @dev Allows developer to switch developer address
	 * @param _developer The new developer address to be set
	 */
	function changeDeveloper(address _developer) public onlyDeveloper {
		developer = _developer;
	}

	/**
	 * @dev Allows developer to withdraw ERC20 Token
	 */
	function withdrawToken(address tokenContractAddress) public onlyDeveloper {
		TokenERC20 _token = TokenERC20(tokenContractAddress);
		if (_token.balanceOf(this) > 0) {
			_token.transfer(developer, _token.balanceOf(this));
		}
	}
}

contract MyAdvancedToken is developed, TokenERC20 {

	uint256 public sellPrice;
	uint256 public buyPrice;

	mapping (address => bool) public frozenAccount;

	/* This generates a public event on the blockchain that will notify clients */
	event FrozenFunds(address target, bool frozen);

	/* Initializes contract with initial supply tokens to the creator of the contract */
	constructor (
		uint256 initialSupply,
		string tokenName,
		string tokenSymbol
	) TokenERC20(initialSupply, tokenName, tokenSymbol) public {}

	/* Internal transfer, only can be called by this contract */
	function _transfer(address _from, address _to, uint _value) internal {
		require (_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
		require (balanceOf[_from] >= _value);               // Check if the sender has enough
		require (balanceOf[_to] + _value >= balanceOf[_to]); // Check for overflows
		require(!frozenAccount[_from]);                     // Check if sender is frozen
		require(!frozenAccount[_to]);                       // Check if recipient is frozen
		balanceOf[_from] -= _value;                         // Subtract from the sender
		balanceOf[_to] += _value;                           // Add the same to the recipient
		emit Transfer(_from, _to, _value);
	}

	/// @notice Create `mintedAmount` tokens and send it to `target`
	/// @param target Address to receive the tokens
	/// @param mintedAmount the amount of tokens it will receive
	function mintToken(address target, uint256 mintedAmount) onlyDeveloper public {
		balanceOf[target] += mintedAmount;
		totalSupply += mintedAmount;
		emit Transfer(0, this, mintedAmount);
		emit Transfer(this, target, mintedAmount);
	}

	/// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
	/// @param target Address to be frozen
	/// @param freeze either to freeze it or not
	function freezeAccount(address target, bool freeze) onlyDeveloper public {
		frozenAccount[target] = freeze;
		emit FrozenFunds(target, freeze);
	}

	/// @notice Allow users to buy tokens for `newBuyPrice` eth and sell tokens for `newSellPrice` eth
	/// @param newSellPrice Price the users can sell to the contract
	/// @param newBuyPrice Price users can buy from the contract
	function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyDeveloper public {
		sellPrice = newSellPrice;
		buyPrice = newBuyPrice;
	}

	/// @notice Buy tokens from contract by sending ether
	function buy() payable public {
		uint amount = msg.value / buyPrice;               // calculates the amount
		_transfer(this, msg.sender, amount);              // makes the transfers
	}

	/// @notice Sell `amount` tokens to contract
	/// @param amount amount of tokens to be sold
	function sell(uint256 amount) public {
		address myAddress = this;
		require(myAddress.balance >= amount * sellPrice);      // checks if the contract has enough ether to buy
		_transfer(msg.sender, this, amount);              // makes the transfers
		msg.sender.transfer(amount * sellPrice);          // sends ether to the seller. It's important to do this last to avoid recursion attacks
	}
}

/**
 * @title SpinToken
 */
contract SpinToken is MyAdvancedToken {
	using SafeMath for uint256;

	bool public paused;

	mapping (address => bool) public allowMintTransfer;
	mapping (address => bool) public allowBurn;

	event Mint(address indexed account, uint256 value);

	/**
	 * @dev Checks if account address is allowed to mint and transfer
	 */
	modifier onlyMintTransferBy(address account) {
		require(allowMintTransfer[account] == true || account == developer);
		_;
	}

	/**
	 * @dev Checks if account address is allowed to burn token
	 */
	modifier onlyBurnBy(address account) {
		require(allowBurn[account] == true || account == developer);
		_;
	}

	/**
	 * @dev Checks if contract is currently active
	 */
	modifier contractIsActive {
		require(paused == false);
		_;
	}

	/**
	 * Constructor
	 * @dev Initializes contract with initial supply tokens to the creator of the contract
	 */
	constructor(
		uint256 initialSupply,
		string tokenName,
		string tokenSymbol
	) MyAdvancedToken(initialSupply, tokenName, tokenSymbol) public {}

	/******************************************/
	/*       DEVELOPER ONLY METHODS           */
	/******************************************/
	/**
	 * @dev Only developer can pause contract
	 * @param _paused The boolean value to be set
	 */
	function setPaused(bool _paused) public onlyDeveloper {
		paused = _paused;
	}

	/**
	 * @dev Only developer can allow `_account` address to mint transfer
	 * @param _account The address of the sender
	 * @param _allowed The boolean value to be set
	 */
	function setAllowMintTransfer(address _account, bool _allowed) public onlyDeveloper {
		allowMintTransfer[_account] = _allowed;
	}

	/**
	 * @dev Only developer can allow `_account` address to burn token
	 * @param _account The address of the sender
	 * @param _allowed The boolean value to be set
	 */
	function setAllowBurn(address _account, bool _allowed) public onlyDeveloper {
		allowBurn[_account] = _allowed;
	}

	/******************************************/
	/*            PUBLIC METHODS              */
	/******************************************/

	/**
	 * @dev Get total supply
	 * @return The token total supply
	 */
	function getTotalSupply() public constant returns (uint256) {
		return totalSupply;
	}

	/**
	 * @dev Get balance of an account
	 * @param account The account to be checked
	 * @return The token balance of the account
	 */
	function getBalanceOf(address account) public constant returns (uint256) {
		return balanceOf[account];
	}

	/**
	 * Transfer tokens
	 *
	 * Send `_value` tokens to `_to` from your account
	 *
	 * @param _to The address of the recipient
	 * @param _value the amount to send
	 */
	function transfer(address _to, uint256 _value) public contractIsActive returns (bool success) {
		_transfer(msg.sender, _to, _value);
		return true;
	}

	/**
	 * Transfer tokens from other address
	 *
	 * Send `_value` tokens to `_to` in behalf of `_from`
	 *
	 * @param _from The address of the sender
	 * @param _to The address of the recipient
	 * @param _value the amount to send
	 */
	function transferFrom(address _from, address _to, uint256 _value) public contractIsActive returns (bool success) {
		require(_value <= allowance[_from][msg.sender]);     // Check allowance
		allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
		_transfer(_from, _to, _value);
		return true;
	}

	/**
	 * Set allowance for other address
	 *
	 * Allows `_spender` to spend no more than `_value` tokens in your behalf
	 *
	 * @param _spender The address authorized to spend
	 * @param _value the max amount they can spend
	 */
	function approve(address _spender, uint256 _value) public contractIsActive returns (bool success) {
		allowance[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;
	}

	/**
	 * Set allowance for other address and notify
	 *
	 * Allows `_spender` to spend no more than `_value` tokens in your behalf, and then ping the contract about it
	 *
	 * @param _spender The address authorized to spend
	 * @param _value the max amount they can spend
	 * @param _extraData some extra information to send to the approved contract
	 */
	function approveAndCall(address _spender, uint256 _value, bytes _extraData)
		public
		contractIsActive
		returns (bool success) {
		tokenRecipient spender = tokenRecipient(_spender);
		if (approve(_spender, _value)) {
			spender.receiveApproval(msg.sender, _value, this, _extraData);
			return true;
		}
	}

	/**
	 * Destroy tokens
	 *
	 * Remove `_value` tokens from the system irreversibly
	 *
	 * @param _value the amount of money to burn
	 */
	function burn(uint256 _value) public contractIsActive returns (bool success) {
		require(balanceOf[msg.sender] >= _value);						// Check if the sender has enough
		balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);		// Subtract from the sender
		totalSupply = totalSupply.sub(_value);							// Updates totalSupply
		emit Burn(msg.sender, _value);
		return true;
	}

	/**
	 * Destroy tokens from other account
	 *
	 * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
	 *
	 * @param _from the address of the sender
	 * @param _value the amount of money to burn
	 */
	function burnFrom(address _from, uint256 _value) public contractIsActive returns (bool success) {
		require(balanceOf[_from] >= _value);									// Check if the targeted balance is enough
		require(_value <= allowance[_from][msg.sender]);						// Check allowance
		balanceOf[_from] = balanceOf[_from].sub(_value);						// Subtract from the targeted balance
		allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);// Subtract from the sender's allowance
		totalSupply = totalSupply.sub(_value);									// Update totalSupply
		emit Burn(_from, _value);
		return true;
	}

	/// @notice Buy tokens from contract by sending ether
	function buy() payable public contractIsActive {
		uint amount = msg.value.div(buyPrice);				// calculates the amount
		_transfer(this, msg.sender, amount);				// makes the transfers
	}

	/// @notice Sell `amount` tokens to contract
	/// @param amount amount of tokens to be sold
	function sell(uint256 amount) public contractIsActive {
		address myAddress = this;
		require(myAddress.balance >= amount.mul(sellPrice));	// checks if the contract has enough ether to buy
		_transfer(msg.sender, this, amount);					// makes the transfers
		msg.sender.transfer(amount.mul(sellPrice));				// sends ether to the seller. It's important to do this last to avoid recursion attacks
	}

	/**
	 * @dev Mints and transfers token to `_to` address.
	 * @param _to The address of the recipient
	 * @param _value The amount of token to mint and transfer
	 * @return Return true if success
	 */
	function mintTransfer(address _to, uint _value) public contractIsActive
		onlyMintTransferBy(msg.sender)
		returns (bool) {
		require(_value > 0);
		totalSupply = totalSupply.add(_value);
		/*
		 * We are actually minting to msg.sender
		 * and then transfer from msg.sender to to address
		 *
		 * Since they cancel out each other, we don't need
		 * these executions:
		 * balances[msg.sender] = balances[msg.sender].add(value);
		 * balances[msg.sender] = balances[msg.sender].sub(value);
		 */
		balanceOf[_to] = balanceOf[_to].add(_value);
		emit Mint(msg.sender, _value);
		emit Transfer(msg.sender, _to, _value);
		return true;
	}

	/**
	 * @dev Burns token at specific address.
	 * @param _at the address of the sender
	 * @param _value the amount of token to burn
	 * @return true if success
	 */
	function burnAt(address _at, uint _value) public contractIsActive
		onlyBurnBy(msg.sender)
		returns (bool) {
		balanceOf[_at] = balanceOf[_at].sub(_value);
		totalSupply = totalSupply.sub(_value);
		emit Burn(_at, _value);
		return true;
	}

	/******************************************/
	/*          INTERNAL METHODS              */
	/******************************************/

	/**
	 * @dev Internal transfer, only can be called by this contract
	 * @param _from The address of the sender
	 * @param _to The address of the recipient
	 * @param _value the amount to send
	 */
	function _transfer(address _from, address _to, uint256 _value) internal contractIsActive {
		// Prevent transfer to 0x0 address. Use burn() instead
		require(_to != 0x0);
		// Check if the sender has enough
		require(balanceOf[_from] >= _value);
		require(!frozenAccount[_from]);                     // Check if sender is frozen
		require(!frozenAccount[_to]);                       // Check if recipient is frozen
		// Save this for an assertion in the future
		uint previousBalances = balanceOf[_from].add(balanceOf[_to]);
		// Subtract from the sender
		balanceOf[_from] = balanceOf[_from].sub(_value);
		// Add the same to the recipient
		balanceOf[_to] = balanceOf[_to].add(_value);
		emit Transfer(_from, _to, _value);
		// Asserts are used to use static analysis to find bugs in your code. They should never fail
		assert(balanceOf[_from].add(balanceOf[_to]) == previousBalances);
	}
}