/**
 * Source Code first verified at https://etherscan.io on Monday, March 25, 2019
 (UTC) */

pragma solidity ^0.4.19;

//--------- OpenZeppelin's Safe Math
//Source : https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol
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
    	uint256 c = a / b;
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
//-----------------------------------------------------B


//"EXTERN" CONTRACTS
//============================
// ERC20 Interface: https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
  	function transfer(address _to, uint256 _value) public returns (bool success);
  	function balanceOf(address _owner) public constant returns (uint256 balance);
}

contract Viscous {
    function is_whitelisted(address) constant returns (bool);
}
//============================

contract Controller {

	address public owner;
  	//event ChangeOwner(address new_owner);

	modifier onlyOwner {
    	require(msg.sender == owner);
    	_;
  	}

  	function change_owner(address new_owner) onlyOwner {
    	require(new_owner != 0x0);
    	owner = new_owner;
    	//ChangeOwner(new_owner);
  	}

  	function Controller() {
    	owner = msg.sender;
  	}
}

contract Contract is Controller {

  //EVENTS
  //============================
  /* event BuyTheTokens(address sale, uint256 amount, bytes data);
  event Whitelist(bool boolean);
  event Contribution(address sender, uint256 amount, uint256 total_amount, uint256 contract_balance);
  event Withdraw(address sender, uint256 amount);
  event Refund(address sender, uint256 amount, uint256 total_amount, uint256 contract_balance); */
  //============================

	using SafeMath for uint256;

  	struct Contributor {
		uint256 balance;
	    uint256 fee;
	    uint8 rounds;
	    bool whitelisted;
  	}

	struct Snapshot {
		uint256 tokens_balance;
		uint256 eth_balance;
	}

	modifier minAmountReached {
		require(this.balance >= min_amount);
		_;
	}

  	modifier underMaxAmount {
    	require(max_amount == 0 || this.balance <= max_amount);
    	_;
  	}

	//FEES RELATED
	//============================
	address constant public DEVELOPER1 = 0x8C006d807EBAe91F341a4308132Fd756808e0126;
	address constant public DEVELOPER2 = 0x63F7547Ac277ea0B52A0B060Be6af8C5904953aa;
	uint256 constant public FEE_DEV = 670; //0.2% fee per dev -> so 0.4% fee in total
	//============================

	//VARIABLES TO BE CHANGED BY OWNER
	//============================
	uint256 public FEE_OWNER; //value as divisor (ie. 1 / FEE_OWNER = % Rate) or (1 / 200 = 0.4%)
	uint256 public max_amount;  //0 means there is no limit
	uint256 public min_amount;
	uint256 public individual_cap;
	uint256 public gas_price_max;
	uint8 public rounds;
	//flag controlled by owner to enable/disable whitelists for viscous or temporary whitelist
	bool public whitelist_enabled;
	//Contract containing the data
	Viscous public viscous_contract = Viscous(0x0);
	//============================

  //###############################################################################################################################

	//CONTRACT VARIABLES
	//============================
	//=== ARRAYS & MAPPINGS ===
	mapping (address => Contributor) public contributors;
	//First element will be the first wave of tokens, and so forth
	Snapshot[] public snapshots;

	//=== UINT ===
	// Record ETH value of tokens currently held by contract.
	uint256 public const_contract_eth_value;
	//The reduction of the allocation in % | example : 40 -> 40% reduction
	uint256 public percent_reduction;

	//=== ADDRESSES ===
	//The address of the contact.
	address public sale;
	//Token address
	ERC20 public token;
	//=== BOOLS ===
	//Track whether the contract has bought the tokens yet.
	bool public bought_tokens;
	//Track if the owner partially refunds his fee in the event of a partial refund post-buy
	bool public owner_supplied_eth;
	bool public allow_contributions = true;
  //============================

	function Contract(
		uint256 _max_amount,
		uint256 _min_amount,
		bool _whitelist,
		uint256 _owner_fee_divisor
		) {
			max_amount = calculate_with_fees(_max_amount);  //0 means there is no limit
		  	min_amount = calculate_with_fees(_min_amount);
		  	whitelist_enabled = _whitelist;
		  	FEE_OWNER = _owner_fee_divisor;
		  	Contributor storage contributor = contributors[msg.sender];
		  	contributor.whitelisted = true;
  		}

  //###############################################################################################################################

	//OWNER FUNCTIONS
	//============================
	// Buy the tokens. Sends ETH to the presale wallet and records the ETH amount held in the contract.
	function buy_the_tokens(bytes _data) onlyOwner minAmountReached {
		//Avoids burning the funds
		require(!bought_tokens && sale != 0x0);
		//Record that the contract has bought the tokens.
		bought_tokens = true;
		const_contract_eth_value = this.balance;
		take_fees_eth_dev();
		take_fees_eth_owner();
		//Record the amount of ETH sent as the contract's current value.
		const_contract_eth_value = this.balance;
		// Transfer all the funds to the crowdsale address.
		require(sale.call.gas(msg.gas).value(this.balance)(_data));
		//BuyTheTokens(sale, const_contract_eth_value, _data);
	}

	//These two functions concern the "temporary" whitelist
	function whitelist_addys(address[] _addys) onlyOwner {
		for (uint256 i = 0; i < _addys.length; i++) {
			Contributor storage contributor = contributors[_addys[i]];
			contributor.whitelisted = true;
		}
	}

	function blacklist_addys(address[] _addys) onlyOwner {
		for (uint256 i = 0; i < _addys.length; i++) {
			Contributor storage contributor = contributors[_addys[i]];
			contributor.whitelisted = false;
		}
	}

	function set_gas_price_max(uint256 _gas_price) onlyOwner {
		gas_price_max = _gas_price;
	}

	function set_sale_address(address _sale) onlyOwner {
		//Avoid mistake of putting 0x0
		require(_sale != 0x0);
		sale = _sale;
	}

	function set_token_address(address _token) onlyOwner {
		require(_token != 0x0);
		token = ERC20(_token);
	}

	function set_allow_contributions(bool _boolean) onlyOwner {
		allow_contributions = _boolean;
	}

	function set_tokens_received() onlyOwner {
		tokens_received();
	}

	function set_percent_reduction(uint256 _reduction) onlyOwner payable {
		require(bought_tokens && rounds == 0 && _reduction <= 100);
		percent_reduction = _reduction;
		if (msg.value > 0) {
			owner_supplied_eth = true;
		}
		//we substract by contract_eth_value*_reduction basically
		const_contract_eth_value = const_contract_eth_value.sub((const_contract_eth_value.mul(_reduction)).div(100));
	}

	function set_whitelist_enabled(bool _boolean) onlyOwner {
		whitelist_enabled = _boolean;
		//Whitelist(_boolean);
	}

	function change_viscous_contract(address _addy) onlyOwner {
		viscous_contract = Viscous(_addy);
	}

	function change_individual_cap(uint256 _cap) onlyOwner {
		individual_cap = _cap;
	}

	function change_max_amount(uint256 _amount) onlyOwner {
		//ATTENTION! The new amount should be in wei
		//Use https://etherconverter.online/
		max_amount = calculate_with_fees(_amount);
	}

	function change_min_amount(uint256 _amount) onlyOwner {
		//ATTENTION! The new amount should be in wei
		//Use https://etherconverter.online/
		min_amount = calculate_with_fees(_amount);
	}

	function change_fee(uint256 _fee) onlyOwner {
		FEE_OWNER = _fee;
	}

	function emergency_token_withdraw(address _address) onlyOwner {
	 	ERC20 temp_token = ERC20(_address);
		require(temp_token.transfer(msg.sender, temp_token.balanceOf(this)));
	}

	function emergency_eth_withdraw() onlyOwner {
		msg.sender.transfer(this.balance);
	}

//###############################################################################################################################


	//INTERNAL FUNCTIONS
	//============================
	// Allows any user to withdraw his tokens.
	function withdraw(address _user) internal {
		// Disallow withdraw if tokens haven't been bought yet.
		require(bought_tokens);
		uint256 contract_token_balance = token.balanceOf(address(this));
		// Disallow token withdrawals if there are no tokens to withdraw.
		require(contract_token_balance != 0);
		Contributor storage contributor = contributors[_user];
		if (contributor.rounds < rounds) {
            //contributor can claim his bonus tokens of previous rounds if he didn't withdrawn
            //uint256 this_contribution_claim = (rounds-contributor.rounds)*contributor.balance;
			Snapshot storage snapshot = snapshots[contributor.rounds];
            uint256 tokens_to_withdraw = contributor.balance.mul(snapshot.tokens_balance).div(snapshot.eth_balance);
			snapshot.tokens_balance = snapshot.tokens_balance.sub(tokens_to_withdraw);
			snapshot.eth_balance = snapshot.eth_balance.sub(contributor.balance);
            // Update the value of tokens currently held by the contract.
            //contract_eth_value -= contributor.balance;
            contributor.rounds++;
            // Send the funds.  Throws on failure to prevent loss of funds.
            require(token.transfer(_user, tokens_to_withdraw));
            //Withdraw(_user, tokens_to_withdraw);
        }
	}

	// Allows any user to get his eth refunded before the purchase is made.
	function refund(address _user) internal {
		require(!bought_tokens && percent_reduction == 0);
		Contributor storage contributor = contributors[_user];
		uint256 eth_to_withdraw = contributor.balance.add(contributor.fee);
		// Update the user's balance prior to sending ETH to prevent recursive call.
		contributor.balance = 0;
		contributor.fee = 0;
		// Return the user's funds.  Throws on failure to prevent loss of funds.
		_user.transfer(eth_to_withdraw);
		//Refund(_user, eth_to_withdraw, contributor.balance, this.balance);
	}

	//Allows any user to get a part of his ETH refunded, in proportion
	//to the % reduced of the allocation
	function partial_refund(address _user) internal {
		require(bought_tokens && rounds == 0 && percent_reduction > 0);
		Contributor storage contributor = contributors[_user];
		require(contributor.rounds == 0);
		uint256 eth_to_withdraw = contributor.balance.mul(percent_reduction).div(100);
		contributor.balance = contributor.balance.sub(eth_to_withdraw);
		if (owner_supplied_eth) {
			//dev fees aren't refunded, only owner fees
			//We don't care about updatng contributor's fee, it doesn't matter for receiving the tokens
			uint256 fee = contributor.fee.mul(percent_reduction).div(100);
			eth_to_withdraw = eth_to_withdraw.add(fee);
		}
		_user.transfer(eth_to_withdraw);
		//Refund(_user, eth_to_withdraw, contributor.balance, this.balance);
	}

	function take_fees_eth_dev() internal {
		if (FEE_DEV != 0) {
			DEVELOPER1.transfer(const_contract_eth_value.div(FEE_DEV));
			DEVELOPER2.transfer(const_contract_eth_value.div(FEE_DEV));
		}
	}

	function take_fees_eth_owner() internal {
	//Owner takes fees on the ETH in this case
	//In case owner doesn't want to take fees
		if (FEE_OWNER != 0) {
			owner.transfer(const_contract_eth_value.div(FEE_OWNER));
		}
	}

	function calculate_with_fees(uint256 _amount) internal returns (uint256) {
		//divided by two because 2 devs, so 0.4% in total
		uint256 temp = _amount;
		if (FEE_DEV != 0) {
			temp = temp.add(_amount.div(FEE_DEV/2));
		}
		if (FEE_OWNER != 0) {
			temp = temp.add(_amount.div(FEE_OWNER));
		}
		return temp;
	}

	function tokens_received() internal {
		//We need to check the previous token balance
		uint256 previous_balance;
		for (uint8 i = 0; i < snapshots.length; i++) {
			previous_balance = previous_balance.add(snapshots[i].tokens_balance);
		}
		snapshots.push(Snapshot(token.balanceOf(address(this)).sub(previous_balance), const_contract_eth_value));
		//we don't leave out the tokens that didn't get withdrawn
		rounds++;
	}


//###############################################################################################################################

  //PUBLIC FUNCTIONS
  //============================

  function tokenFallback(address _from, uint _value, bytes _data) {
		if (ERC20(msg.sender) == token) {
			tokens_received();
		}
	}

	function withdraw_my_tokens() {
		for (uint8 i = contributors[msg.sender].rounds; i < rounds; i++) {
			withdraw(msg.sender);
		}
	}

	function withdraw_tokens_for(address _addy) {
		for (uint8 i = contributors[_addy].rounds; i < rounds; i++) {
			withdraw(_addy);
		}
	}

	function refund_my_ether() {
		refund(msg.sender);
	}

	function partial_refund_my_ether() {
		partial_refund(msg.sender);
	}

	function provide_eth() payable {}

	// Default function.  Called when a user sends ETH to the contract.
	function () payable underMaxAmount {
		require(!bought_tokens && allow_contributions && (gas_price_max == 0 || tx.gasprice <= gas_price_max));
		Contributor storage contributor = contributors[msg.sender];
		//Checks if contributor is whitelisted
		if (whitelist_enabled) {
			require(contributor.whitelisted || viscous_contract.is_whitelisted(msg.sender));
		}
		//Manages cases of dev and/or owner taking fees
		//"Worst case", substract 0 from the msg.value
		uint256 fee = 0;
		if (FEE_OWNER != 0) {
			fee = SafeMath.div(msg.value, FEE_OWNER);
		}
		uint256 fees = fee;
		if (FEE_DEV != 0) {
			fee = msg.value.div(FEE_DEV/2);
			fees = fees.add(fee);
		}
		//Updates both of the balances
		contributor.balance = contributor.balance.add(msg.value).sub(fees);
		contributor.fee = contributor.fee.add(fees);

		//Checks if the individual cap is respected
		//If it's not, changes are reverted
		require(individual_cap == 0 || contributor.balance <= individual_cap);
		//Contribution(msg.sender, msg.value, contributor.balance, this.balance);
	}
}