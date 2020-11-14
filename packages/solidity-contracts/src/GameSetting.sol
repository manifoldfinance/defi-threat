/**
 * Source Code first verified at https://etherscan.io on Wednesday, May 8, 2019
 (UTC) */

pragma solidity ^0.4.24;

// https://www.ethereum.org/token

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }


/**
 * @title SpinWinInterface
 */
interface SpinWinInterface {
	function refundPendingBets() external returns (bool);
}


/**
 * @title SettingInterface
 */
interface SettingInterface {
	function uintSettings(bytes32 name) external constant returns (uint256);
	function boolSettings(bytes32 name) external constant returns (bool);
	function isActive() external constant returns (bool);
	function canBet(uint256 rewardValue, uint256 betValue, uint256 playerNumber, uint256 houseEdge) external constant returns (bool);
	function isExchangeAllowed(address playerAddress, uint256 tokenAmount) external constant returns (bool);

	/******************************************/
	/*          SPINWIN ONLY METHODS          */
	/******************************************/
	function spinwinSetUintSetting(bytes32 name, uint256 value) external;
	function spinwinIncrementUintSetting(bytes32 name) external;
	function spinwinSetBoolSetting(bytes32 name, bool value) external;
	function spinwinAddFunds(uint256 amount) external;
	function spinwinUpdateTokenToWeiExchangeRate() external;
	function spinwinRollDice(uint256 betValue) external;
	function spinwinUpdateWinMetric(uint256 playerProfit) external;
	function spinwinUpdateLoseMetric(uint256 betValue, uint256 tokenRewardValue) external;
	function spinwinUpdateLotteryContributionMetric(uint256 lotteryContribution) external;
	function spinwinUpdateExchangeMetric(uint256 exchangeAmount) external;

	/******************************************/
	/*      SPINLOTTERY ONLY METHODS          */
	/******************************************/
	function spinlotterySetUintSetting(bytes32 name, uint256 value) external;
	function spinlotteryIncrementUintSetting(bytes32 name) external;
	function spinlotterySetBoolSetting(bytes32 name, bool value) external;
	function spinlotteryUpdateTokenToWeiExchangeRate() external;
	function spinlotterySetMinBankroll(uint256 _minBankroll) external returns (bool);
}


/**
 * @title TokenInterface
 */
interface TokenInterface {
	function getTotalSupply() external constant returns (uint256);
	function getBalanceOf(address account) external constant returns (uint256);
	function transfer(address _to, uint256 _value) external returns (bool);
	function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
	function approve(address _spender, uint256 _value) external returns (bool success);
	function approveAndCall(address _spender, uint256 _value, bytes _extraData) external returns (bool success);
	function burn(uint256 _value) external returns (bool success);
	function burnFrom(address _from, uint256 _value) external returns (bool success);
	function mintTransfer(address _to, uint _value) external returns (bool);
	function burnAt(address _at, uint _value) external returns (bool);
}




// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol

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





// https://github.com/ethereum/ethereum-org/blob/master/solidity/token-advanced.sol



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



contract escaped {
	address public escapeActivator;

	/**
	 * Constructor
	 */
	constructor() public {
		escapeActivator = 0xB15C54b4B9819925Cd2A7eE3079544402Ac33cEe;
	}

	/**
	 * @dev Checks only escapeActivator address is calling
	 */
	modifier onlyEscapeActivator {
		require(msg.sender == escapeActivator);
		_;
	}

	/**
	 * @dev Allows escapeActivator to switch escapeActivator address
	 * @param _escapeActivator The new escapeActivator address to be set
	 */
	function changeAddress(address _escapeActivator) public onlyEscapeActivator {
		escapeActivator = _escapeActivator;
	}
}





/**
 * @title GameSetting
 */
contract GameSetting is developed, escaped, SettingInterface {
	using SafeMath for uint256;

	address public spinwinAddress;
	address public spinlotteryAddress;

	mapping(bytes32 => uint256) internal _uintSettings;    // Array containing all uint256 settings
	mapping(bytes32 => bool) internal _boolSettings;       // Array containing all bool settings

	uint256 constant public PERCENTAGE_DIVISOR = 10 ** 6;   // 1000000 = 100%
	uint256 constant public HOUSE_EDGE_DIVISOR = 1000;
	uint256 constant public CURRENCY_DIVISOR = 10**18;
	uint256 constant public TWO_DECIMALS = 100;
	uint256 constant public MAX_NUMBER = 99;
	uint256 constant public MIN_NUMBER = 2;
	uint256 constant public MAX_HOUSE_EDGE = 1000;          // 0% House Edge
	uint256 constant public MIN_HOUSE_EDGE = 0;             // 100% House edge

	TokenInterface internal _spintoken;
	SpinWinInterface internal _spinwin;

	/**
	 * @dev Log dev sets uint setting
	 */
	event LogSetUintSetting(address indexed who, bytes32 indexed name, uint256 value);

	/**
	 * @dev Log dev sets bool setting
	 */
	event LogSetBoolSetting(address indexed who, bytes32 indexed name, bool value);

	/**
	 * @dev Log when dev adds some funds
	 */
	event LogAddBankRoll(uint256 amount);

	/**
	 * @dev Log when the token to Wei exchange rate is updated
	 */
	event LogUpdateTokenToWeiExchangeRate(uint256 exchangeRate, uint256 exchangeRateBlockNumber);

	/**
	 * @dev Log when developer set spinwin contract to emergency mode
	 */
	event LogSpinwinEscapeHatch();

	/**
	 * Constructor
	 */
	constructor(address _spintokenAddress) public {
		_spintoken = TokenInterface(_spintokenAddress);
		devSetUintSetting('minBet', CURRENCY_DIVISOR.div(100));			// init min bet (0.01 ether)
		devSetUintSetting('maxProfitAsPercentOfHouse', 200000);         // init 200000 = 20% commission
		devSetUintSetting('minBankroll', CURRENCY_DIVISOR.mul(20));     // init min bank roll (20 eth)
		devSetTokenExchangeMinBankrollPercent(900000);                  // init token exchange min bank roll percentage (90%)
		devSetUintSetting('referralPercent', 10000);                    // init referral percentage (1%)
		devSetUintSetting('gasForLottery', 250000);                     // init gas for lottery
		devSetUintSetting('maxBlockSecurityCount', 256);                // init max block security count (256)
		devSetUintSetting('blockSecurityCount', 3);                     // init block security count (3)
		devSetUintSetting('tokenExchangeBlockSecurityCount', 3);        // init token exchange block security count (3)
		devSetUintSetting('maxProfitBlockSecurityCount', 3);            // init max profit block security count (3)
		devSetUintSetting('spinEdgeModifier', 80);                      // init spin edge modifier (0.8)
		devSetUintSetting('spinBankModifier', 50);                      // init spin bank modifier (0.5)
		devSetUintSetting('spinNumberModifier', 5);                     // init spin number modifier (0.05)
		devSetUintSetting('maxMinBankroll', CURRENCY_DIVISOR.mul(5000));   // init max value for min bankroll (5,000 eth)
		devSetUintSetting('lastProcessedBetInternalId', 1);             // init lastProcessedBetInternalId = 1
		devSetUintSetting('exchangeAmountDivisor', 2);                  // init exchangeAmountDivisor = 2
		devSetUintSetting('tokenExchangeRatio', 10);                    // init tokenExchangeRatio = 0.1 (divided by TWO_DECIMALS)
		devSetUintSetting('spinToWeiRate', CURRENCY_DIVISOR);           // init spinToWeiRate = 1
		devSetUintSetting('blockToSpinRate', CURRENCY_DIVISOR);         // init blockToSpinRate = 1
		devSetUintSetting('blockToWeiRate', CURRENCY_DIVISOR);          // init blockToWeiRate = 1
		devSetUintSetting('gasForClearingBet', 320000);                 // init gasForClearingBet = 320000 gas
		devSetUintSetting('gasPrice', 40000000000);                     // init gasPrice = 40 gwei
		devSetUintSetting('clearSingleBetMultiplier', 200);             // init clearSingleBetMultiplier = 2x (divided by TWO_DECIMALS)
		devSetUintSetting('clearMultipleBetsMultiplier', 100);          // init clearMultipleBetMultiplier = 1x (divided by TWO_DECIMALS)
		devSetUintSetting('maxNumClearBets', 4);                        // init maxNumClearBets = 4
		devSetUintSetting('lotteryTargetMultiplier', 200);              // init lotteryTargetMultiplier = 2x (divided by TWO_DECIMALS)
		_setMaxProfit(true);
	}

	/**
	 * @dev Checks only spinwinAddress is calling
	 */
	modifier onlySpinwin {
		require(msg.sender == spinwinAddress);
		_;
	}

	/**
	 * @dev Checks only spinlotteryAddress is calling
	 */
	modifier onlySpinlottery {
		require(msg.sender == spinlotteryAddress);
		_;
	}

	/******************************************/
	/*       DEVELOPER ONLY METHODS           */
	/******************************************/

	/**
	 * @dev Allows developer to set spinwin contract address
	 * @param _address The contract address to be set
	 */
	function devSetSpinwinAddress(address _address) public onlyDeveloper {
		require (_address != address(0));
		spinwinAddress = _address;
		_spinwin = SpinWinInterface(spinwinAddress);
	}

	/**
	 * @dev Allows developer to set spinlottery contract address
	 * @param _address The contract address to be set
	 */
	function devSetSpinlotteryAddress(address _address) public onlyDeveloper {
		require (_address != address(0));
		spinlotteryAddress = _address;
	}

	/**
	 * @dev Allows dev to set uint setting
	 * @param name The setting name to be set
	 * @param value The value to be set
	 */
	function devSetUintSetting(bytes32 name, uint256 value) public onlyDeveloper {
		_uintSettings[name] = value;
		emit LogSetUintSetting(developer, name, value);
	}

	/**
	 * @dev Allows dev to set bool setting
	 * @param name The setting name to be set
	 * @param value The value to be set
	 */
	function devSetBoolSetting(bytes32 name, bool value) public onlyDeveloper {
		_boolSettings[name] = value;
		emit LogSetBoolSetting(developer, name, value);
	}

	/**
	 * @dev Allows developer to set min bank roll
	 * @param minBankroll The new min bankroll value to be set
	 */
	function devSetMinBankroll(uint256 minBankroll) public onlyDeveloper {
		_uintSettings['minBankroll'] = minBankroll;
		_uintSettings['tokenExchangeMinBankroll'] = _uintSettings['minBankroll'].mul(_uintSettings['tokenExchangeMinBankrollPercent']).div(PERCENTAGE_DIVISOR);
	}

	/**
	 * @dev Allows developer to set token exchange min bank roll percent
	 * @param tokenExchangeMinBankrollPercent The new value to be set
	 */
	function devSetTokenExchangeMinBankrollPercent(uint256 tokenExchangeMinBankrollPercent) public onlyDeveloper {
		_uintSettings['tokenExchangeMinBankrollPercent'] = tokenExchangeMinBankrollPercent;
		_uintSettings['tokenExchangeMinBankroll'] = _uintSettings['minBankroll'].mul(_uintSettings['tokenExchangeMinBankrollPercent']).div(PERCENTAGE_DIVISOR);
	}

	/******************************************/
	/*      ESCAPE ACTIVATOR ONLY METHODS     */
	/******************************************/

	/**
	 * @dev Allows escapeActivator to trigger spinwin emergency mode. Will disable all bets and only allow token exchange at a fixed rate
	 */
	function spinwinEscapeHatch() public onlyEscapeActivator {
		_spinwin.refundPendingBets();
		_boolSettings['contractKilled'] = true;
		_uintSettings['contractBalanceHonor'] = _uintSettings['contractBalance'];
		_uintSettings['tokenExchangeMinBankroll'] = 0;
		_uintSettings['tokenExchangeMinBankrollHonor'] = 0;
		/**
		 * tokenToWeiExchangeRate is ETH in 36 decimals or WEI in 18 decimals to account for
		 * the state when token's totalSupply is 10^18 more than contractBalance.
		 * Otherwise the tokenToWeiExchangeRate will always be 0.
		 * This means, in the exchange token function, we need to divide
		 * tokenToWeiExchangeRate with CURRENCY_DIVISOR
		 */
		_uintSettings['tokenToWeiExchangeRate'] = _spintoken.getTotalSupply() > 0 ? _uintSettings['contractBalance'].mul(CURRENCY_DIVISOR).mul(CURRENCY_DIVISOR).div(_spintoken.getTotalSupply()) : 0;
		_uintSettings['tokenToWeiExchangeRateHonor'] = _uintSettings['tokenToWeiExchangeRate'];
		_uintSettings['tokenToWeiExchangeRateBlockNum'] = block.number;
		emit LogUpdateTokenToWeiExchangeRate(_uintSettings['tokenToWeiExchangeRateHonor'], _uintSettings['tokenToWeiExchangeRateBlockNum']);
		emit LogSpinwinEscapeHatch();
	}

	/******************************************/
	/*         SPINWIN ONLY METHODS           */
	/******************************************/
	/**
	 * @dev Allows spinwin to set uint setting
	 * @param name The setting name to be set
	 * @param value The value to be set
	 */
	function spinwinSetUintSetting(bytes32 name, uint256 value) public onlySpinwin {
		_uintSettings[name] = value;
		emit LogSetUintSetting(spinwinAddress, name, value);
	}

	/**
	 * @dev Allows spinwin to increment existing uint setting value
	 * @param name The setting name to be set
	 */
	function spinwinIncrementUintSetting(bytes32 name) public onlySpinwin {
		_uintSettings[name] = _uintSettings[name].add(1);
		emit LogSetUintSetting(spinwinAddress, name, _uintSettings[name]);
	}

	/**
	 * @dev Allows spinwin to set bool setting
	 * @param name The setting name to be set
	 * @param value The value to be set
	 */
	function spinwinSetBoolSetting(bytes32 name, bool value) public onlySpinwin {
		_boolSettings[name] = value;
		emit LogSetBoolSetting(spinwinAddress, name, value);
	}

	/**
	 * @dev Add funds to the spinwin contract
	 * @param amount The amount of eth sent
	 */
	function spinwinAddFunds(uint256 amount) public onlySpinwin {
		// Safely update contract balance
		_uintSettings['contractBalance'] = _uintSettings['contractBalance'].add(amount);

		// Update max profit
		_setMaxProfit(false);

		emit LogAddBankRoll(amount);
	}

	/**
	 * @dev Allow spinwin to update token to Wei exchange rate.
	 */
	function spinwinUpdateTokenToWeiExchangeRate() public onlySpinwin {
		_updateTokenToWeiExchangeRate();
	}

	/**
	 * @dev Allow spinwin to update settings when roll dice
	 * Increment totalBets
	 * Add betValue to totalWeiWagered
	 *
	 * @param betValue The bet value
	 * @return The internal bet ID
	 */
	function spinwinRollDice(uint256 betValue) public onlySpinwin {
		_uintSettings['totalBets']++;
		_uintSettings['totalWeiWagered'] = _uintSettings['totalWeiWagered'].add(betValue);
	}

	/**
	 * @dev Allows spinwin to update uint setting when player wins
	 * @param playerProfit The player profit to be subtracted from contractBalance and added to totalWeiWon
	 */
	function spinwinUpdateWinMetric(uint256 playerProfit) public onlySpinwin {
		_uintSettings['contractBalance'] = _uintSettings['contractBalance'].sub(playerProfit);
		_uintSettings['totalWeiWon'] = _uintSettings['totalWeiWon'].add(playerProfit);
		_setMaxProfit(false);
	}

	/**
	 * @dev Allows spinwin to update uint setting when player loses
	 * @param betValue The original wager
	 * @param tokenRewardValue The amount of token to be rewarded
	 */
	function spinwinUpdateLoseMetric(uint256 betValue, uint256 tokenRewardValue) public onlySpinwin {
		_uintSettings['contractBalance'] = _uintSettings['contractBalance'].add(betValue).sub(1);
		_uintSettings['totalWeiWon'] = _uintSettings['totalWeiWon'].add(1);
		_uintSettings['totalWeiLost'] = _uintSettings['totalWeiLost'].add(betValue).sub(1);
		_uintSettings['totalTokenPayouts'] = _uintSettings['totalTokenPayouts'].add(tokenRewardValue);
		_setMaxProfit(false);
	}

	/**
	 * @dev Allows spinwin to update uint setting when there is a lottery contribution
	 * @param lotteryContribution The amount to be contributed to lottery
	 */
	function spinwinUpdateLotteryContributionMetric(uint256 lotteryContribution) public onlySpinwin {
		_uintSettings['contractBalance'] = _uintSettings['contractBalance'].sub(lotteryContribution);
		_setMaxProfit(true);
	}

	/**
	 * @dev Allows spinwin to update uint setting when there is a token exchange transaction
	 * @param exchangeAmount The converted exchange amount
	 */
	function spinwinUpdateExchangeMetric(uint256 exchangeAmount) public onlySpinwin {
		_uintSettings['contractBalance'] = _uintSettings['contractBalance'].sub(exchangeAmount);
		_setMaxProfit(false);
	}


	/******************************************/
	/*      SPINLOTTERY ONLY METHODS          */
	/******************************************/
	/**
	 * @dev Allows spinlottery to set uint setting
	 * @param name The setting name to be set
	 * @param value The value to be set
	 */
	function spinlotterySetUintSetting(bytes32 name, uint256 value) public onlySpinlottery {
		_uintSettings[name] = value;
		emit LogSetUintSetting(spinlotteryAddress, name, value);
	}

	/**
	 * @dev Allows spinlottery to increment existing uint setting value
	 * @param name The setting name to be set
	 */
	function spinlotteryIncrementUintSetting(bytes32 name) public onlySpinlottery {
		_uintSettings[name] = _uintSettings[name].add(1);
		emit LogSetUintSetting(spinwinAddress, name, _uintSettings[name]);
	}

	/**
	 * @dev Allows spinlottery to set bool setting
	 * @param name The setting name to be set
	 * @param value The value to be set
	 */
	function spinlotterySetBoolSetting(bytes32 name, bool value) public onlySpinlottery {
		_boolSettings[name] = value;
		emit LogSetBoolSetting(spinlotteryAddress, name, value);
	}

	/**
	 * @dev Allow spinlottery to update token to Wei exchange rate.
	 */
	function spinlotteryUpdateTokenToWeiExchangeRate() public onlySpinlottery {
		_updateTokenToWeiExchangeRate();
	}

	/**
	 * @dev Allows lottery to set spinwin minBankroll value
	 * @param _minBankroll The new value to be set
	 * @return Return true if success
	 */
	function spinlotterySetMinBankroll(uint256 _minBankroll) public onlySpinlottery returns (bool) {
		if (_minBankroll > _uintSettings['maxMinBankroll']) {
			_minBankroll = _uintSettings['maxMinBankroll'];
		} else if (_minBankroll < _uintSettings['contractBalance']) {
			_minBankroll = _uintSettings['contractBalance'];
		}
		_uintSettings['minBankroll'] = _minBankroll;
		_uintSettings['tokenExchangeMinBankroll'] = _uintSettings['minBankroll'].mul(_uintSettings['tokenExchangeMinBankrollPercent']).div(PERCENTAGE_DIVISOR);

		// Update max profit
		_setMaxProfit(false);

		return true;
	}

	/******************************************/
	/*         PUBLIC ONLY METHODS            */
	/******************************************/
	/**
	 * @dev Gets uint setting value
	 * @param name The name of the uint setting
	 * @return The value of the setting
	 */
	function uintSettings(bytes32 name) public constant returns (uint256) {
		return _uintSettings[name];
	}

	/**
	 * @dev Gets bool setting value
	 * @param name The name of the bool setting
	 * @return The value of the setting
	 */
	function boolSettings(bytes32 name) public constant returns (bool) {
		return _boolSettings[name];
	}

	/**
	 * @dev Check if contract is active
	 * @return Return true if yes, false otherwise.
	 */
	function isActive() public constant returns (bool) {
		if (_boolSettings['contractKilled'] == false && _boolSettings['gamePaused'] == false) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * @dev Check whether current bet is valid
	 * @param rewardValue The winning amount
	 * @param betValue The original wager
	 * @param playerNumber The player chosen number
	 * @param houseEdge The house edge
	 * @return Return true if yes, false otherwise.
	 */
	function canBet(uint256 rewardValue, uint256 betValue, uint256 playerNumber, uint256 houseEdge) public constant returns (bool) {
		if (_boolSettings['contractKilled'] == false && _boolSettings['gamePaused'] == false && rewardValue <= _uintSettings['maxProfitHonor'] && betValue >= _uintSettings['minBet'] && houseEdge >= MIN_HOUSE_EDGE && houseEdge <= MAX_HOUSE_EDGE && playerNumber >= MIN_NUMBER && playerNumber <= MAX_NUMBER) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * @dev Check whether token exchange is allowed
	 * @param playerAddress The player address to be checked
	 * @param tokenAmount The amount of token to be exchanged
	 * @return Return true if yes, false otherwise.
	 */
	function isExchangeAllowed(address playerAddress, uint256 tokenAmount) public constant returns (bool) {
		if (_boolSettings['gamePaused'] == false && _boolSettings['tokenExchangePaused'] == false && _uintSettings['contractBalanceHonor'] >= _uintSettings['tokenExchangeMinBankrollHonor'] && _uintSettings['tokenToWeiExchangeRateHonor'] > 0 && _spintoken.getBalanceOf(playerAddress) >= tokenAmount) {
			return true;
		} else {
			return false;
		}
	}

	/******************************************/
	/*        INTERNAL ONLY METHODS           */
	/******************************************/

	/**
	 * @dev Calculates and sets the latest max profit a bet can possibly earn. Also update the honor variables that we are going to promise players.
	 * @param force If true, bypass the block security check and update honor settings
	 */
	function _setMaxProfit(bool force) internal {
		_uintSettings['maxProfit'] = _uintSettings['contractBalance'].mul(_uintSettings['maxProfitAsPercentOfHouse']).div(PERCENTAGE_DIVISOR);
		if (force || block.number > _uintSettings['maxProfitBlockNum'].add(_uintSettings['maxProfitBlockSecurityCount'])) {
			if (_uintSettings['contractBalance'] < 10 ether) {
				_uintSettings['maxProfitAsPercentOfHouse'] = 200000; // 20%
			} else if (_uintSettings['contractBalance'] >= 10 ether && _uintSettings['contractBalance'] < 100 ether) {
				_uintSettings['maxProfitAsPercentOfHouse'] = 100000; // 10%
			} else if (_uintSettings['contractBalance'] >= 100 ether && _uintSettings['contractBalance'] < 1000 ether) {
				_uintSettings['maxProfitAsPercentOfHouse'] = 50000; // 5%
			} else {
				_uintSettings['maxProfitAsPercentOfHouse'] = 10000; // 1%
			}
			_uintSettings['maxProfitHonor'] = _uintSettings['maxProfit'];
			_uintSettings['contractBalanceHonor'] = _uintSettings['contractBalance'];
			_uintSettings['minBankrollHonor'] = _uintSettings['minBankroll'];
			_uintSettings['tokenExchangeMinBankrollHonor'] = _uintSettings['tokenExchangeMinBankroll'];
			_uintSettings['totalWeiLostHonor'] = _uintSettings['totalWeiLost'];
			_uintSettings['maxProfitBlockNum'] = block.number;
		}
	}

	/**
	 * @dev Updates token to Wei exchange rate.
	 * The exchange rate will be updated everytime there is a transaction happens in spinwin.
	 * If contract is killed, we don't need to do anything
	 */
	function _updateTokenToWeiExchangeRate() internal {
		if (!_boolSettings['contractKilled']) {
			if (_uintSettings['contractBalance'] >= _uintSettings['tokenExchangeMinBankroll'] && _spintoken.getTotalSupply() > 0) {
				/**
				 * tokenToWeiExchangeRate is ETH in 36 decimals or WEI in 18 decimals to account for
				 * the state when token's totalSupply is 10^18 more than contractBalance.
				 * Otherwise the tokenToWeiExchangeRate will always be 0.
				 * This means, in the exchange token function, we need to divide
				 * tokenToWeiExchangeRate with CURRENCY_DIVISOR
				 */
				_uintSettings['tokenToWeiExchangeRate'] = ((_uintSettings['contractBalance'].sub(_uintSettings['tokenExchangeMinBankroll'])).mul(CURRENCY_DIVISOR).mul(CURRENCY_DIVISOR).div(_uintSettings['exchangeAmountDivisor'])).div(_spintoken.getTotalSupply().mul(_uintSettings['tokenExchangeRatio']).div(TWO_DECIMALS));
			} else {
				_uintSettings['tokenToWeiExchangeRate'] = 0;
			}

			if (block.number > _uintSettings['tokenToWeiExchangeRateBlockNum'].add(_uintSettings['tokenExchangeBlockSecurityCount'])) {
				_uintSettings['tokenToWeiExchangeRateHonor'] = _uintSettings['tokenToWeiExchangeRate'];
				_uintSettings['tokenToWeiExchangeRateBlockNum'] = block.number;
				emit LogUpdateTokenToWeiExchangeRate(_uintSettings['tokenToWeiExchangeRateHonor'], _uintSettings['tokenToWeiExchangeRateBlockNum']);
			}
		}
	}
}