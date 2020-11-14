/**
 * Source Code first verified at https://etherscan.io on Thursday, March 21, 2019
 (UTC) */

pragma solidity ^0.5.0;

contract DUO {
	// Public variables of the token
	string public name;
	string public symbol;
	uint8 public decimals = 18;
	// 18 decimals is the strongly suggested default, avoid changing it
	uint public totalSupply;

	// This creates an array with all balances
	mapping (address => uint) public balanceOf;
	mapping (address => mapping (address => uint)) public allowance;

	// This generates a public event on the blockchain that will notify clients
	event Transfer(address indexed from, address indexed to, uint tokens);
	event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

	/**
	 * Constrctor function
	 *
	 * Initializes contract with initial supply tokens to the creator of the contract
	 */
	constructor(
		uint initialSupply,
		string memory tokenName,
		string memory tokenSymbol
	) public 
	{
		totalSupply = initialSupply;  // Update total supply with the decimal amount
		balanceOf[msg.sender] = totalSupply;				// Give the creator all initial tokens
		name = tokenName;								   // Set the name for display purposes
		symbol = tokenSymbol;							   // Set the symbol for display purposes
	}

	/**
	 * Internal transfer, only can be called by this contract
	 */
	function transfer(address from, address to, uint value) internal {
		// Prevent transfer to 0x0 address. Use burn() instead
		require(to != address(0));
		// Check if the sender has enough
		require(balanceOf[from] >= value);
		// Check for overflows
		require(balanceOf[to] + value > balanceOf[to]);
		// Save this for an assertion in the future
		uint previousBalances = balanceOf[from] + balanceOf[to];
		// Subtract from the sender
		balanceOf[from] -= value;
		// Add the same to the recipient
		balanceOf[to] += value;
		emit Transfer(from, to, value);
		// Asserts are used to use static analysis to find bugs in your code. They should never fail
		assert(balanceOf[from] + balanceOf[to] == previousBalances);
	}

	/**
	 * Transfer tokens
	 *
	 * Send `value` tokens to `to` from your account
	 *
	 * @param to The address of the recipient
	 * @param value the amount to send
	 */
	function transfer(address to, uint value) public returns (bool success) {
		transfer(msg.sender, to, value);
		return true;
	}

	/**
	 * Transfer tokens from other address
	 *
	 * Send `value` tokens to `to` in behalf of `from`
	 *
	 * @param from The address of the sender
	 * @param to The address of the recipient
	 * @param value the amount to send
	 */
	function transferFrom(address from, address to, uint value) public returns (bool success) {
		require(value <= allowance[from][msg.sender]);	 // Check allowance
		allowance[from][msg.sender] -= value;
		transfer(from, to, value);
		return true;
	}

	/**
	 * Set allowance for other address
	 *
	 * Allows `spender` to spend no more than `value` tokens in your behalf
	 *
	 * @param spender The address authorized to spend
	 * @param value the max amount they can spend
	 */
	function approve(address spender, uint value) public returns (bool success) {
		allowance[msg.sender][spender] = value;
		emit Approval(msg.sender, spender, value);
		return true;
	}
}