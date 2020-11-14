/**
 * Source Code first verified at https://etherscan.io on Tuesday, May 7, 2019
 (UTC) */

pragma solidity ^0.4.24;

/**
 * @title LotteryInterface
 */
interface LotteryInterface {
	function claimReward(address playerAddress, uint256 tokenAmount) external returns (bool);
	function calculateLotteryContributionPercentage() external constant returns (uint256);
	function getNumLottery() external constant returns (uint256);
	function isActive() external constant returns (bool);
	function getCurrentTicketMultiplierHonor() external constant returns (uint256);
	function getCurrentLotteryTargetBalance() external constant returns (uint256, uint256);
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
 * @title SpinLottery
 */
contract SpinLottery is developed, escaped, LotteryInterface {
	using SafeMath for uint256;

	/**
	 * @dev Game variables
	 */
	address public owner;
	address public spinwinAddress;

	bool public contractKilled;
	bool public gamePaused;

	uint256 public numLottery;
	uint256 public lotteryTarget;
	uint256 public totalBankroll;
	uint256 public totalBuyTickets;
	uint256 public totalTokenWagered;
	uint256 public lotteryTargetIncreasePercentage;
	uint256 public lastBlockNumber;
	uint256 public lastLotteryTotalBlocks;

	uint256 public currentTicketMultiplier;
	uint256 public currentTicketMultiplierHonor;
	uint256 public currentTicketMultiplierBlockNumber;

	uint256 public maxBlockSecurityCount;
	uint256 public blockSecurityCount;
	uint256 public currentTicketMultiplierBlockSecurityCount;

	uint256 public ticketMultiplierModifier;

	uint256 public avgLotteryHours; // Average hours needed to complete a lottery
	uint256 public totalLotteryHours; // Total accumulative lottery hours
	uint256 public minBankrollDecreaseRate; // The rate to use to decrease spinwin's min bankroll
	uint256 public minBankrollIncreaseRate; // The rate to use to increase spinwin's min bankroll
	uint256 public lotteryContributionPercentageModifier; // The lottery contribution percentage modifier, used to calculate lottery contribution percentage
	uint256 public rateConfidenceModifier; // The rate confidence modifier, used to calculate lottery contribution percentage
	uint256 public currentLotteryPaceModifier; // The current lottery pace modifier, used to calculate lottery contribution percentage
	uint256 public maxLotteryContributionPercentage; // The maximum percent that we can contribute to the lottery

	uint256 constant public PERCENTAGE_DIVISOR = 1000000;
	uint256 constant public TWO_DECIMALS = 100; // To account for calculation with 2 decimal points
	uint256 constant public CURRENCY_DIVISOR = 10 ** 18;

	uint256 public startLotteryRewardPercentage; // The percentage of blocks that we want to reward player for starting next lottery
	uint256 internal lotteryContribution;
	uint256 internal carryOverContribution;
	uint256 public minRewardBlocksAmount;

	TokenInterface internal _spintoken;
	SettingInterface internal _setting;

	struct Lottery {
		uint256 lotteryTarget;
		uint256 bankroll;
		uint256 tokenWagered;
		uint256 lotteryResult;
		uint256 totalBlocks;
		uint256 totalBlocksRewarded;
		uint256 startTimestamp;
		uint256 endTimestamp;
		address winnerPlayerAddress;
		bool ended;
		bool cashedOut;
	}

	struct Ticket {
		bytes32 ticketId;
		uint256 numLottery;
		address playerAddress;
		uint256 minNumber;
		uint256 maxNumber;
		bool claimed;
	}
	mapping (uint256 => Lottery) public lotteries;
	mapping (bytes32 => Ticket) public tickets;
	mapping (uint256 => mapping (address => uint256)) public playerTokenWagered;
	mapping (address => uint256) public playerPendingWithdrawals;
	mapping (uint256 => mapping (address => uint256)) public playerTotalBlocks;
	mapping (uint256 => mapping (address => uint256)) public playerTotalBlocksRewarded;

	/**
	 * @dev Log when new lottery is created
	 */
	event LogCreateLottery(uint256 indexed numLottery, uint256 lotteryBankrollGoal);

	/**
	 * @dev Log when lottery is ended
	 */
	event LogEndLottery(uint256 indexed numLottery, uint256 lotteryResult);

	/**
	 * @dev Log when spinwin adds some funds
	 */
	event LogAddBankRoll(uint256 indexed numLottery, uint256 amount);

	/**
	 * @dev Log when player buys ticket
	 * Ticket type
	 * 1 = normal purchase
	 * 2 = Spinwin Reward
	 * 3 = Start Lottery Reward
	 */
	event LogBuyTicket(uint256 indexed numLottery, bytes32 indexed ticketId, address indexed playerAddress, uint256 tokenAmount, uint256 ticketMultiplier, uint256 minNumber, uint256 maxNumber, uint256 ticketType);

	/**
	 * @dev Log when player claims lotto ticket
	 *
	 * Status:
	 * 0: Lose
	 * 1: Win
	 * 2: Win + Failed send
	 */
	event LogClaimTicket(uint256 indexed numLottery, bytes32 indexed ticketId, address indexed playerAddress, uint256 lotteryResult, uint256 playerMinNumber, uint256 playerMaxNumber, uint256 winningReward, uint256 status);

	/**
	 * @dev Log when player withdraw balance
	 *
	 * Status:
	 * 0 = failed
	 * 1 = success
	 */
	event LogPlayerWithdrawBalance(address indexed playerAddress, uint256 withdrawAmount, uint256 status);

	/**
	 * @dev Log when current ticket multiplier is updated
	 */
	event LogUpdateCurrentTicketMultiplier(uint256 currentTicketMultiplier, uint256 currentTicketMultiplierBlockNumber);

	/**
	 * @dev Log when developer set contract to emergency mode
	 */
	event LogEscapeHatch();

	/**
	 * Constructor
	 */
	constructor(address _settingAddress, address _tokenAddress, address _spinwinAddress) public {
		_setting = SettingInterface(_settingAddress);
		_spintoken = TokenInterface(_tokenAddress);
		spinwinAddress = _spinwinAddress;
		lastLotteryTotalBlocks = 100 * CURRENCY_DIVISOR;                // init last lottery total blocks (10^20 blocks)
		devSetLotteryTargetIncreasePercentage(150000);                  // init lottery target increase percentage (15%);
		devSetMaxBlockSecurityCount(256);                               // init max block security count (256)
		devSetBlockSecurityCount(3);                                    // init block security count (3)
		devSetCurrentTicketMultiplierBlockSecurityCount(3);             // init current ticket multiplier block security count (3)
		devSetTicketMultiplierModifier(300);                            // init ticket multiplier modifier (3)
		devSetMinBankrollDecreaseRate(80);                              // init min bankroll decrease rate (0.8)
		devSetMinBankrollIncreaseRate(170);                             // init min bankroll increase rate (1.7)
		devSetLotteryContributionPercentageModifier(10);                // init lottery contribution percentage modifier (0.1)
		devSetRateConfidenceModifier(200);                              // init rate confidence modifier (2)
		devSetCurrentLotteryPaceModifier(200);                          // init current lottery pace modifier (2)
		devSetStartLotteryRewardPercentage(10000);                      // init start lottery reward percentage (1%)
		devSetMinRewardBlocksAmount(1);                                 // init min reward blocks amount (1)
		devSetMaxLotteryContributionPercentage(100);                    // init max lottery contribution percentage (1)
		_createNewLottery();                                            // start lottery
	}

	/**
	 * @dev Checks if the contract is currently alive
	 */
	modifier contractIsAlive {
		require(contractKilled == false);
		_;
	}

	/**
	 * @dev Checks if the game is currently active
	 */
	modifier gameIsActive {
		require(gamePaused == false);
		_;
	}

	/**
	 * @dev Checks only spinwin address is calling
	 */
	modifier onlySpinwin {
		require(msg.sender == spinwinAddress);
		_;
	}

	/******************************************/
	/*       DEVELOPER ONLY METHODS           */
	/******************************************/

	/**
	 * @dev Allows developer to set lotteryTarget
	 * @param _lotteryTarget The new lottery target value to be set
	 */
	function devSetLotteryTarget(uint256 _lotteryTarget) public onlyDeveloper {
		require (_lotteryTarget >= 0);
		lotteryTarget = _lotteryTarget;
		Lottery storage _lottery = lotteries[numLottery];
		_lottery.lotteryTarget = lotteryTarget;
	}

	/**
	 * @dev Allows developer to set lottery target increase percentage
	 * @param _lotteryTargetIncreasePercentage The new value to be set
	 * 1% = 10000
	 */
	function devSetLotteryTargetIncreasePercentage(uint256 _lotteryTargetIncreasePercentage) public onlyDeveloper {
		lotteryTargetIncreasePercentage = _lotteryTargetIncreasePercentage;
	}

	/**
	 * @dev Allows developer to set block security count
	 * @param _blockSecurityCount The new value to be set
	 */
	function devSetBlockSecurityCount(uint256 _blockSecurityCount) public onlyDeveloper {
		require (_blockSecurityCount > 0);
		blockSecurityCount = _blockSecurityCount;
	}

	/**
	 * @dev Allows developer to set max block security count
	 * @param _maxBlockSecurityCount The new value to be set
	 */
	function devSetMaxBlockSecurityCount(uint256 _maxBlockSecurityCount) public onlyDeveloper {
		require (_maxBlockSecurityCount > 0);
		maxBlockSecurityCount = _maxBlockSecurityCount;
	}

	/**
	 * @dev Allows developer to set current ticket multiplier block security count
	 * @param _currentTicketMultiplierBlockSecurityCount The new value to be set
	 */
	function devSetCurrentTicketMultiplierBlockSecurityCount(uint256 _currentTicketMultiplierBlockSecurityCount) public onlyDeveloper {
		require (_currentTicketMultiplierBlockSecurityCount > 0);
		currentTicketMultiplierBlockSecurityCount = _currentTicketMultiplierBlockSecurityCount;
	}

	/**
	 * @dev Allows developer to set ticket multiplier modifier
	 * @param _ticketMultiplierModifier The new value to be set (in two decimals)
	 * 1 = 100
	 */
	function devSetTicketMultiplierModifier(uint256 _ticketMultiplierModifier) public onlyDeveloper {
		require (_ticketMultiplierModifier > 0);
		ticketMultiplierModifier = _ticketMultiplierModifier;
	}

	/**
	 * @dev Allows developer to set min bankroll decrease rate
	 * @param _minBankrollDecreaseRate The new value to be set  (in two decimals)
	 * 1 = 100
	 */
	function devSetMinBankrollDecreaseRate(uint256 _minBankrollDecreaseRate) public onlyDeveloper {
		require (_minBankrollDecreaseRate >= 0);
		minBankrollDecreaseRate = _minBankrollDecreaseRate;
	}

	/**
	 * @dev Allows developer to set min bankroll increase rate
	 * @param _minBankrollIncreaseRate The new value to be set  (in two decimals)
	 * 1 = 100
	 */
	function devSetMinBankrollIncreaseRate(uint256 _minBankrollIncreaseRate) public onlyDeveloper {
		require (_minBankrollIncreaseRate > minBankrollDecreaseRate);
		minBankrollIncreaseRate = _minBankrollIncreaseRate;
	}

	/**
	 * @dev Allows developer to set lottery contribution percentage modifier
	 * @param _lotteryContributionPercentageModifier The new value to be set (in two decimals)
	 * 1 = 100
	 */
	function devSetLotteryContributionPercentageModifier(uint256 _lotteryContributionPercentageModifier) public onlyDeveloper {
		lotteryContributionPercentageModifier = _lotteryContributionPercentageModifier;
	}

	/**
	 * @dev Allows developer to set rate confidence modifier
	 * @param _rateConfidenceModifier The new value to be set (in two decimals)
	 * 1 = 100
	 */
	function devSetRateConfidenceModifier(uint256 _rateConfidenceModifier) public onlyDeveloper {
		rateConfidenceModifier = _rateConfidenceModifier;
	}

	/**
	 * @dev Allows developer to set current lottery pace modifier
	 * @param _currentLotteryPaceModifier The new value to be set (in two decimals)
	 * 1 = 100
	 */
	function devSetCurrentLotteryPaceModifier(uint256 _currentLotteryPaceModifier) public onlyDeveloper {
		currentLotteryPaceModifier = _currentLotteryPaceModifier;
	}

	/**
	 * @dev Allows developer to pause the game
	 * @param paused The new paused value to be set
	 */
	function devPauseGame(bool paused) public onlyDeveloper {
		gamePaused = paused;
	}

	/**
	 * @dev Allows developer to start new lottery (only when current lottery is ended)
	 * @return Return true if success
	 */
	function devStartLottery() public onlyDeveloper returns (bool) {
		Lottery memory _currentLottery = lotteries[numLottery];
		require (_currentLottery.ended == true);
		_createNewLottery();
		return true;
	}

	/**
	 * @dev Allows developer to end current lottery
	 * @param _startNextLottery Boolean value whether or not we should start next lottery
	 * @return Return true if success
	 */
	function devEndLottery(bool _startNextLottery) public onlyDeveloper returns (bool) {
		_endLottery();
		if (_startNextLottery) {
			_createNewLottery();
		}
		return true;
	}

	/**
	 * @dev Allows developer to set start lottery reward percentage
	 * @param _startLotteryRewardPercentage The new value to be set
	 * 1% = 10000
	 */
	function devSetStartLotteryRewardPercentage(uint256 _startLotteryRewardPercentage) public onlyDeveloper {
		startLotteryRewardPercentage = _startLotteryRewardPercentage;
	}

	/**
	 * @dev Allows developer to set start lottery min reward blocks amount
	 * @param _minRewardBlocksAmount The new value to be set
	 */
	function devSetMinRewardBlocksAmount(uint256 _minRewardBlocksAmount) public onlyDeveloper {
		minRewardBlocksAmount = _minRewardBlocksAmount;
	}

	/**
	 * @dev Allows developer to set max lottery contribution percentage
	 * @param _maxLotteryContributionPercentage The new value to be set
	 * 1 = 100
	 */
	function devSetMaxLotteryContributionPercentage(uint256 _maxLotteryContributionPercentage) public onlyDeveloper {
		maxLotteryContributionPercentage = _maxLotteryContributionPercentage;
	}

	/******************************************/
	/*      ESCAPE ACTIVATOR ONLY METHODS     */
	/******************************************/

	/**
	 * @dev Allows escapeActivator to trigger emergency mode. Will end current lottery and stop the game.
	 * @return Return true if success
	 */
	function escapeHatch() public
		onlyEscapeActivator
		contractIsAlive
		returns (bool) {
		contractKilled = true;
		_endLottery();
		emit LogEscapeHatch();
		return true;
	}

	/******************************************/
	/*         SPINWIN ONLY METHODS           */
	/******************************************/
	/**
	 * @dev Allows spinwin to buy ticket on behalf of playerAddress as part of claiming spinwin reward
	 * @param playerAddress The player address to be rewarded
	 * @param tokenAmount The amount of token to be spent
	 * @return The ticket ID
	 */
	function claimReward(address playerAddress, uint256 tokenAmount) public
		contractIsAlive
		gameIsActive
		onlySpinwin
		returns (bool) {
		return _buyTicket(playerAddress, tokenAmount, 2);
	}

	/******************************************/
	/*             PUBLIC METHODS             */
	/******************************************/
	/**
	 * @dev Add funds to the contract
	 * If the bankroll goal is reached, we want to end current lottery and start new lottery.
	 */
	function () payable public
		contractIsAlive
		gameIsActive {
		// Update the last block number
		lastBlockNumber = block.number;

		Lottery storage _currentLottery = lotteries[numLottery];
		if (_currentLottery.bankroll.add(msg.value) > lotteryTarget) {
			lotteryContribution = lotteryTarget.sub(_currentLottery.bankroll);
			carryOverContribution = carryOverContribution.add(msg.value.sub(lotteryContribution));
		} else {
			lotteryContribution = msg.value;
		}

		// Safely update bankroll
		if (lotteryContribution > 0) {
			_currentLottery.bankroll = _currentLottery.bankroll.add(lotteryContribution);
			totalBankroll = totalBankroll.add(lotteryContribution);
			emit LogAddBankRoll(numLottery, lotteryContribution);
		}
	}

	/**
	 * @dev Player buys lottery ticket
	 * @param tokenAmount The amount of token to spend
	 * @return Return the ticket ID
	 */
	function buyTicket(uint tokenAmount) public
		contractIsAlive
		gameIsActive
		returns (bool) {
		require (_spintoken.burnAt(msg.sender, tokenAmount));
		return _buyTicket(msg.sender, tokenAmount, 1);
	}

	/**
	 * @dev Player claims lottery ticket
	 * @param ticketId The ticket ID to be claimed
	 * @return Return true if success
	 */
	function claimTicket(bytes32 ticketId) public
		gameIsActive
		returns (bool) {
		Ticket storage _ticket = tickets[ticketId];
		require(_ticket.claimed == false && _ticket.playerAddress == msg.sender);

		Lottery storage _lottery = lotteries[_ticket.numLottery];
		require(_lottery.ended == true && _lottery.cashedOut == false && _lottery.bankroll > 0 && _lottery.totalBlocks.add(_lottery.totalBlocksRewarded) > 0 && _lottery.lotteryResult > 0);

		// Mark this ticket as claimed
		_ticket.claimed = true;
		uint256 status = 0; // status = failed
		if (_lottery.lotteryResult >= _ticket.minNumber && _lottery.lotteryResult <= _ticket.maxNumber) {
			uint256 lotteryReward = _lottery.bankroll;

			// Check if contract has enough bankroll to payout
			require(totalBankroll >= lotteryReward);

			// Safely adjust totalBankroll
			totalBankroll = totalBankroll.sub(lotteryReward);

			_lottery.bankroll = 0;
			_lottery.winnerPlayerAddress = msg.sender;
			_lottery.cashedOut = true;


			if (!msg.sender.send(lotteryReward)) {
				status = 2; // status = win + failed send
				// If send failed, let player withdraw via playerWithdrawPendingTransactions
				playerPendingWithdrawals[msg.sender] = playerPendingWithdrawals[msg.sender].add(lotteryReward);
			} else {
				status = 1; // status = win
			}
		}
		emit LogClaimTicket(_ticket.numLottery, ticketId, msg.sender, _lottery.lotteryResult, _ticket.minNumber, _ticket.maxNumber, lotteryReward, status);
		return true;
	}

	/**
	 * @dev Allows player to withdraw balance in case of a failed win send
	 * @return Return true if success
	 */
	function playerWithdrawPendingTransactions() public
		gameIsActive {
		require(playerPendingWithdrawals[msg.sender] > 0);
		uint256 withdrawAmount = playerPendingWithdrawals[msg.sender];

		playerPendingWithdrawals[msg.sender] = 0;

		// External call to untrusted contract
		uint256 status = 1; // status = success
		if (!msg.sender.send(withdrawAmount)) {
			status = 0; // status = failed

			/*
			 * If send failed, revert playerPendingWithdrawals[msg.sender] = 0
			 * so that player can try to withdraw again later
			 */
			playerPendingWithdrawals[msg.sender] = withdrawAmount;
		}
		emit LogPlayerWithdrawBalance(msg.sender, withdrawAmount, status);
	}

	/**
	 * @dev Calculates number of blocks the player will get when he/she buys the lottery ticket
	 *      based on player's entered token amount and current multiplier honor
	 * @return ticketMultiplier The ticket multiplier during this transaction
	 * @return numBlocks The lotto block count for this ticket
	 */
	function calculateNumBlocks(uint256 tokenAmount) public constant returns (uint256 ticketMultiplier, uint256 numBlocks) {
		return (currentTicketMultiplierHonor, currentTicketMultiplierHonor.mul(tokenAmount).div(TWO_DECIMALS));
	}

	/**
	 * @dev Get current num lottery
	 * @return Current num lottery
	 */
	function getNumLottery() public constant returns (uint256) {
		return numLottery;
	}

	/**
	 * @dev Check if contract is active
	 * @return Current state of contract
	 */
	function isActive() public constant returns (bool) {
		if (gamePaused == true || contractKilled == true) {
			return false;
		} else {
			return true;
		}
	}

	/**
	 * @dev Determines the lottery contribution percentage
	 * @return lotteryContributionPercentage (in two decimals)
	 */
	function calculateLotteryContributionPercentage() public
		contractIsAlive
		gameIsActive
		constant returns (uint256) {
		Lottery memory _currentLottery = lotteries[numLottery];
		uint256 currentTotalLotteryHours = _getHoursBetween(_currentLottery.startTimestamp, now);

		uint256 currentWeiToLotteryRate = 0;
		// To prevent division by 0
		if (currentTotalLotteryHours > 0) {
			/*
			 * currentWeiToLotteryRate = _currentLottery.bankroll / currentTotalLotteryHours;
			 * But since we need to account for decimal points
			 * currentWeiToLotteryRate = (_currentLottery.bankroll * TWO_DECIMALS)/currentTotalLotteryHours;
			 * currentWeiToLotteryRate needs to be divided by TWO_DECIMALS later on
			 */
			currentWeiToLotteryRate = (_currentLottery.bankroll.mul(TWO_DECIMALS)).div(currentTotalLotteryHours);
		}

		uint256 predictedCurrentLotteryHours = currentTotalLotteryHours;
		// To prevent division by 0
		if (currentWeiToLotteryRate > 0) {
			/*
			 * predictedCurrentLotteryHours = currentTotalLotteryHours + ((lotteryTarget - _currentLottery.bankroll)/currentWeiToLotteryRate);
			 * Let temp = (lotteryTarget - _currentLottery.bankroll)/currentWeiToLotteryRate;
			 * Since we need to account for decimal points
			 * temp = ((lotteryTarget - _currentLottery.bankroll)*TWO_DECIMALS)/currentWeiToLotteryRate;
			 * But currentWeiToLotteryRate is already in decimals
			 * temp = ((lotteryTarget - _currentLottery.bankroll)*TWO_DECIMALS)/(currentWeiToLotteryRate/TWO_DECIMALS);
			 * temp = ((lotteryTarget - _currentLottery.bankroll)*TWO_DECIMALS*TWO_DECIMALS)/currentWeiToLotteryRate;
			 * predictedCurrentLotteryHours = currentTotalLotteryHours + (temp/TWO_DECIMALS);
			 */
			uint256 temp = (lotteryTarget.sub(_currentLottery.bankroll)).mul(TWO_DECIMALS).mul(TWO_DECIMALS).div(currentWeiToLotteryRate);
			predictedCurrentLotteryHours = currentTotalLotteryHours.add(temp.div(TWO_DECIMALS));
		}

		uint256 currentLotteryPace = 0;
		// To prevent division by 0
		if (avgLotteryHours > 0) {
			/*
			 * currentLotteryPace = predictedCurrentLotteryHours/avgLotteryHours;
			 * But since we need to account for decimal points
			 * currentLotteryPace = (predictedCurrentLotteryHours*TWO_DECIMALS)/avgLotteryHours;
			 * But avgLotteryHours is already in decimals so we need to divide it by TWO_DECIMALS as well
			 * currentLotteryPace = (predictedCurrentLotteryHours*TWO_DECIMALS)/(avgLotteryHours/TWO_DECIMALS);
			 * OR
			 * currentLotteryPace = (predictedCurrentLotteryHours*TWO_DECIMALS*TWO_DECIMALS)/avgLotteryHours;
			 * currentLotteryPace needs to be divided by TWO_DECIMALS later on
			 */
			currentLotteryPace = (predictedCurrentLotteryHours.mul(TWO_DECIMALS).mul(TWO_DECIMALS)).div(avgLotteryHours);
		}

		uint256 percentageOverTarget = 0;
		// To prevent division by 0
		if (_setting.uintSettings('minBankroll') > 0) {
			/*
			 * percentageOverTarget = _spinwin.contractBalance() / _spinwin.minBankroll();
			 * But since we need to account for decimal points
			 * percentageOverTarget = (_spinwin.contractBalance()*TWO_DECIMALS) / _spinwin.minBankroll();
			 * percentageOverTarget needs to be divided by TWO_DECIMALS later on
			 */
			percentageOverTarget = (_setting.uintSettings('contractBalance').mul(TWO_DECIMALS)).div(_setting.uintSettings('minBankroll'));
		}

		currentTotalLotteryHours = currentTotalLotteryHours.mul(TWO_DECIMALS); // So that it has two decimals
		uint256 rateConfidence = 0;
		// To prevent division by 0
		if (avgLotteryHours.add(currentTotalLotteryHours) > 0) {
			/*
			 * rateConfidence = currentTotalLotteryHours / (avgLotteryHours + currentTotalLotteryHours);
			 * But since we need to account for decimal points
			 * rateConfidence = (currentTotalLotteryHours*TWO_DECIMALS) / (avgLotteryHours + currentTotalLotteryHours);
			 * rateConfidence needs to be divided by TWO_DECIMALS later on
			 */
			rateConfidence = currentTotalLotteryHours.mul(TWO_DECIMALS).div(avgLotteryHours.add(currentTotalLotteryHours));
		}

		/*
		 * lotteryContributionPercentage = 0.1 + (1-(1/percentageOverTarget))+(rateConfidence*2*(currentLotteryPace/(currentLotteryPace+2)))
		 * Replace the static number with modifier variables (that are already in decimals, so 0.1 is actually 10, 2 is actually 200)
		 * lotteryContributionPercentage = lotteryContributionPercentageModifier + (1-(1/percentageOverTarget)) + (rateConfidence*rateConfidenceModifier*(currentLotteryPace/(currentLotteryPace+currentLotteryPaceModifier)));
		 *
		 * Split to 3 sections
		 * lotteryContributionPercentage = calc1 + calc2 + calc3
		 * calc1 = lotteryContributionPercentageModifier
		 * calc2 = (1-(1/percentageOverTarget))
		 * calc3 = (rateConfidence*rateConfidenceModifier*(currentLotteryPace/(currentLotteryPace+currentLotteryPaceModifier)))
		 */
		uint256 lotteryContributionPercentage = lotteryContributionPercentageModifier;

		/*
		 * calc2 = 1-(1/percentageOverTarget)
		 * Since percentageOverTarget is already in two decimals
		 * calc2 = 1-(1/(percentageOverTarget/TWO_DECIMALS))
		 * calc2 = 1-(TWO_DECIMALS/percentageOverTarget)
		 * mult TWO_DECIMALS/TWO_DECIMALS to calculate fraction
		 * calc2 = (TWO_DECIMALS-((TWO_DECIMALS*TWO_DECIMALS)/percentageOverTarget))/TWO_DECIMALS
		 * since lotteryContributionPercentage needs to be in decimals, we can take out the division by TWO_DECIMALS
		 * calc2 = TWO_DECIMALS-((TWO_DECIMALS*TWO_DECIMALS)/percentageOverTarget)
		 */
		// To prevent division by 0
		if (percentageOverTarget > 0) {
			lotteryContributionPercentage = lotteryContributionPercentage.add(TWO_DECIMALS.sub((TWO_DECIMALS.mul(TWO_DECIMALS)).div(percentageOverTarget)));
		} else {
			lotteryContributionPercentage = lotteryContributionPercentage.add(TWO_DECIMALS);
		}

		/*
		 * calc3 = rateConfidence*rateConfidenceModifier*(currentLotteryPace/(currentLotteryPace+currentLotteryPaceModifier))
		 * But since rateConfidence, rateConfidenceModifier are already in decimals, we need to divide them by TWO_DECIMALS
		 * calc3 = (rateConfidence/TWO_DECIMALS)*(rateConfidenceModifier/TWO_DECIMALS)*(currentLotteryPace/(currentLotteryPace+currentLotteryPaceModifier))
		 * since we need to account for decimal points, mult the numerator `currentLotteryPace` with TWO_DECIMALS
		 * calc3 = (rateConfidence/TWO_DECIMALS)*(rateConfidenceModifier/TWO_DECIMALS)*((currentLotteryPace*TWO_DECIMALS)/(currentLotteryPace+currentLotteryPaceModifier))
		 * OR
		 * calc3 = (rateConfidence*rateConfidenceModifier*currentLotteryPace)/(TWO_DECIMALS*(currentLotteryPace+currentLotteryPaceModifier))
		 */
		// To prevent division by 0
		if (currentLotteryPace.add(currentLotteryPaceModifier) > 0) {
			lotteryContributionPercentage = lotteryContributionPercentage.add((rateConfidence.mul(rateConfidenceModifier).mul(currentLotteryPace)).div(TWO_DECIMALS.mul(currentLotteryPace.add(currentLotteryPaceModifier))));
		}
		if (lotteryContributionPercentage > maxLotteryContributionPercentage) {
			lotteryContributionPercentage = maxLotteryContributionPercentage;
		}
		return lotteryContributionPercentage;
	}

	/**
	 * @dev Allows player to start next lottery and reward player a percentage of last lottery total blocks
	 */
	function startNextLottery() public
		contractIsAlive
		gameIsActive {
		Lottery storage _currentLottery = lotteries[numLottery];
		require (_currentLottery.bankroll >= lotteryTarget && _currentLottery.totalBlocks.add(_currentLottery.totalBlocksRewarded) > 0);
		uint256 startLotteryRewardBlocks = calculateStartLotteryRewardBlocks();
		_endLottery();
		_createNewLottery();

		// If we have carry over contribution from prev contribution
		// add it to the next lottery
		if (carryOverContribution > 0) {
			_currentLottery = lotteries[numLottery];
			if (_currentLottery.bankroll.add(carryOverContribution) > lotteryTarget) {
				lotteryContribution = lotteryTarget.sub(_currentLottery.bankroll);
				carryOverContribution = carryOverContribution.sub(lotteryContribution);
			} else {
				lotteryContribution = carryOverContribution;
				carryOverContribution = 0;
			}

			// Safely update bankroll
			_currentLottery.bankroll = _currentLottery.bankroll.add(lotteryContribution);
			totalBankroll = totalBankroll.add(lotteryContribution);
			emit LogAddBankRoll(numLottery, lotteryContribution);
		}
		_buyTicket(msg.sender, startLotteryRewardBlocks, 3);
	}

	/**
	 * @dev Calculate start lottery reward blocks amount
	 * @return The reward blocks amount
	 */
	function calculateStartLotteryRewardBlocks() public constant returns (uint256) {
		uint256 totalRewardBlocks = lastLotteryTotalBlocks.mul(startLotteryRewardPercentage).div(PERCENTAGE_DIVISOR);
		if (totalRewardBlocks == 0) {
			totalRewardBlocks = minRewardBlocksAmount;
		}
		return totalRewardBlocks;
	}

	/**
	 * @dev Get current ticket multiplier honor
	 * @return Current ticket multiplier honor
	 */
	function getCurrentTicketMultiplierHonor() public constant returns (uint256) {
		return currentTicketMultiplierHonor;
	}

	/**
	 * @dev Get current lottery target and bankroll
	 * @return Current lottery target
	 * @return Current lottery bankroll
	 */
	function getCurrentLotteryTargetBalance() public constant returns (uint256, uint256) {
		Lottery memory _lottery = lotteries[numLottery];
		return (_lottery.lotteryTarget, _lottery.bankroll);
	}

	/*****************************************/
	/*          INTERNAL METHODS              */
	/******************************************/

	/**
	 * @dev Creates new lottery
	 */
	function _createNewLottery() internal returns (bool) {
		numLottery++;
		lotteryTarget = _setting.uintSettings('minBankroll').add(_setting.uintSettings('minBankroll').mul(lotteryTargetIncreasePercentage).div(PERCENTAGE_DIVISOR));
		Lottery storage _lottery = lotteries[numLottery];
		_lottery.lotteryTarget = lotteryTarget;
		_lottery.startTimestamp = now;
		_updateCurrentTicketMultiplier();
		emit LogCreateLottery(numLottery, lotteryTarget);
		return true;
	}

	/**
	 * @dev Ends current lottery
	 */
	function _endLottery() internal returns (bool) {
		Lottery storage _currentLottery = lotteries[numLottery];
		require (_currentLottery.totalBlocks.add(_currentLottery.totalBlocksRewarded) > 0);

		uint256 blockNumberDifference = block.number - lastBlockNumber;
		uint256 targetBlockNumber = 0;
		if (blockNumberDifference < maxBlockSecurityCount.sub(blockSecurityCount)) {
			targetBlockNumber = lastBlockNumber.add(blockSecurityCount);
		} else {
			targetBlockNumber = lastBlockNumber.add(maxBlockSecurityCount.mul(blockNumberDifference.div(maxBlockSecurityCount))).add(blockSecurityCount);
		}
		_currentLottery.lotteryResult = _generateRandomNumber(_currentLottery.totalBlocks.add(_currentLottery.totalBlocksRewarded), targetBlockNumber);

		// If contract is killed, we don't want any leftover eth sits in the contract
		// Add the carry over contribution to current lottery
		if (contractKilled == true && carryOverContribution > 0) {
			lotteryTarget = lotteryTarget.add(carryOverContribution);
			_currentLottery.lotteryTarget = lotteryTarget;
			_currentLottery.bankroll = _currentLottery.bankroll.add(carryOverContribution);
			totalBankroll = totalBankroll.add(carryOverContribution);
			emit LogAddBankRoll(numLottery, carryOverContribution);
		}
		_currentLottery.endTimestamp = now;
		_currentLottery.ended = true;
		uint256 endingLotteryHours = _getHoursBetween(_currentLottery.startTimestamp, now);
		totalLotteryHours = totalLotteryHours.add(endingLotteryHours);

		/*
		 * avgLotteryHours = totalLotteryHours/numLottery
		 * But since we are doing division in integer, needs to account for the decimal points
		 * avgLotteryHours = totalLotteryHours * TWO_DECIMALS / numLottery; // TWO_DECIMALS = 100
		 * avgLotteryHours needs to be divided by TWO_DECIMALS again later on
		 */
		avgLotteryHours = totalLotteryHours.mul(TWO_DECIMALS).div(numLottery);
		lastLotteryTotalBlocks = _currentLottery.totalBlocks.add(_currentLottery.totalBlocksRewarded);

		// Update spinwin's min bankroll
		if (_setting.boolSettings('contractKilled') == false && _setting.boolSettings('gamePaused') == false) {
			uint256 lotteryPace = 0;
			if (endingLotteryHours > 0) {
				/*
				 * lotteryPace = avgLotteryHours/endingLotteryHours
				 * Mult avgLotteryHours with TWO_DECIMALS to account for two decimal points
				 * lotteryPace = (avgLotteryHours * TWO_DECIMALS) / endingLotteryHours
				 * But from previous calculation, we already know that avgLotteryHours is already in decimals
				 * So, lotteryPace = ((avgLotteryHours*TWO_DECIMALS)/endingLotteryHours)/TWO_DECIMALS
				 * lotteryPace needs to be divided by TWO_DECIMALS again later on
				 */
				lotteryPace = avgLotteryHours.mul(TWO_DECIMALS).div(endingLotteryHours).div(TWO_DECIMALS);
			}

			uint256 newMinBankroll = 0;
			if (lotteryPace <= minBankrollDecreaseRate) {
				// If the pace is too slow, then we want to decrease spinwin min bankroll
				newMinBankroll = _setting.uintSettings('minBankroll').mul(minBankrollDecreaseRate).div(TWO_DECIMALS);
			} else if (lotteryPace <= minBankrollIncreaseRate) {
				// If the pace is too fast, then we want to increase spinwin min bankroll
				newMinBankroll = _setting.uintSettings('minBankroll').mul(minBankrollIncreaseRate).div(TWO_DECIMALS);
			} else {
				// Otherwise, set new min bankroll according to the lottery pace
				newMinBankroll = _setting.uintSettings('minBankroll').mul(lotteryPace).div(TWO_DECIMALS);
			}
			_setting.spinlotterySetMinBankroll(newMinBankroll);
		}

		emit LogEndLottery(numLottery, _currentLottery.lotteryResult);
	}

	/**
	 * @dev Buys ticket
	 * @param _playerAddress The player address that buys this ticket
	 * @param _tokenAmount The amount of SPIN token to spend
	 * @param _ticketType Is this a normal purchase / part of spinwin's reward program / start lottery reward?
	 * 1 = normal purchase
	 * 2 = spinwin reward
	 * 3 = start lottery reward
	 * @return Return true if success
	 */
	function _buyTicket(address _playerAddress, uint256 _tokenAmount, uint256 _ticketType) internal returns (bool) {
		require (_ticketType >=1 && _ticketType <= 3);
		totalBuyTickets++;
		Lottery storage _currentLottery = lotteries[numLottery];

		if (_ticketType > 1) {
			uint256 _ticketMultiplier = TWO_DECIMALS; // Ticket multiplier is 1
			uint256 _numBlocks = _tokenAmount;
			_tokenAmount = 0;  // Set token amount to 0 since we are not charging player any SPIN
		} else {
			_currentLottery.tokenWagered = _currentLottery.tokenWagered.add(_tokenAmount);
			totalTokenWagered = totalTokenWagered.add(_tokenAmount);
			(_ticketMultiplier, _numBlocks) = calculateNumBlocks(_tokenAmount);
		}

		// Generate ticketId
		bytes32 _ticketId = keccak256(abi.encodePacked(this, _playerAddress, numLottery, totalBuyTickets));
		Ticket storage _ticket = tickets[_ticketId];
		_ticket.ticketId = _ticketId;
		_ticket.numLottery = numLottery;
		_ticket.playerAddress = _playerAddress;
		_ticket.minNumber = _currentLottery.totalBlocks.add(_currentLottery.totalBlocksRewarded).add(1);
		_ticket.maxNumber = _currentLottery.totalBlocks.add(_currentLottery.totalBlocksRewarded).add(_numBlocks);

		playerTokenWagered[numLottery][_playerAddress] = playerTokenWagered[numLottery][_playerAddress].add(_tokenAmount);
		if (_ticketType > 1) {
			_currentLottery.totalBlocksRewarded = _currentLottery.totalBlocksRewarded.add(_numBlocks);
			playerTotalBlocksRewarded[numLottery][_playerAddress] = playerTotalBlocksRewarded[numLottery][_playerAddress].add(_numBlocks);
		} else {
			_currentLottery.totalBlocks = _currentLottery.totalBlocks.add(_numBlocks);
			playerTotalBlocks[numLottery][_playerAddress] = playerTotalBlocks[numLottery][_playerAddress].add(_numBlocks);
		}

		emit LogBuyTicket(numLottery, _ticket.ticketId, _ticket.playerAddress, _tokenAmount, _ticketMultiplier, _ticket.minNumber, _ticket.maxNumber, _ticketType);

		// Safely update current ticket multiplier
		_updateCurrentTicketMultiplier();

		// Call spinwin update token to wei exchange rate
		_setting.spinlotteryUpdateTokenToWeiExchangeRate();
		return true;
	}

	/**
	 * @dev Updates current ticket multiplier
	 */
	function _updateCurrentTicketMultiplier() internal returns (bool) {
		// Safely update current ticket multiplier
		Lottery memory _currentLottery = lotteries[numLottery];
		if (lastLotteryTotalBlocks > _currentLottery.totalBlocks.add(_currentLottery.totalBlocksRewarded)) {
			/*
			 * currentTicketMultiplier = 1 + (ticketMultiplierModifier * ((lastLotteryTotalBlocks-currentLotteryBlocks)/lastLotteryTotalBlocks))
			 * Since we are calculating in decimals so 1 is actually 100 or TWO_DECIMALS
			 * currentTicketMultiplier = TWO_DECIMALS + (ticketMultiplierModifier * ((lastLotteryTotalBlocks-currentLotteryBlocks)/lastLotteryTotalBlocks))
			 * Let temp = (lastLotteryTotalBlocks-currentLotteryBlocks)/lastLotteryTotalBlocks
			 * To account for decimal points, we mult (lastLotteryTotalBlocks-currentLotteryBlocks) with TWO_DECIMALS
			 * temp = ((lastLotteryTotalBlocks-currentLotteryBlocks)*TWO_DECIMALS)/lastLotteryTotalBlocks
			 * We need to divide temp with TWO_DECIMALS later
			 *
			 * currentTicketMultiplier = TWO_DECIMALS + ((ticketMultiplierModifier * temp)/TWO_DECIMALS);
			 */
			uint256 temp = (lastLotteryTotalBlocks.sub(_currentLottery.totalBlocks.add(_currentLottery.totalBlocksRewarded))).mul(TWO_DECIMALS).div(lastLotteryTotalBlocks);
			currentTicketMultiplier = TWO_DECIMALS.add(ticketMultiplierModifier.mul(temp).div(TWO_DECIMALS));
		} else {
			currentTicketMultiplier = TWO_DECIMALS;
		}
		if (block.number > currentTicketMultiplierBlockNumber.add(currentTicketMultiplierBlockSecurityCount) || _currentLottery.tokenWagered == 0) {
			currentTicketMultiplierHonor = currentTicketMultiplier;
			currentTicketMultiplierBlockNumber = block.number;
			emit LogUpdateCurrentTicketMultiplier(currentTicketMultiplierHonor, currentTicketMultiplierBlockNumber);
		}
		return true;
	}

	/**
	 * @dev Generates random number between 1 to maxNumber based on targetBlockNumber
	 * @return The random number integer between 1 to maxNumber
	 */
	function _generateRandomNumber(uint256 maxNumber, uint256 targetBlockNumber) internal constant returns (uint256) {
		uint256 randomNumber = 0;
		for (uint256 i = 1; i < blockSecurityCount; i++) {
			randomNumber = ((uint256(keccak256(abi.encodePacked(randomNumber, blockhash(targetBlockNumber-i), numLottery + totalBuyTickets + totalTokenWagered))) % maxNumber)+1);
		}
		return randomNumber;
	}

	/**
	 * @dev Get hours between two timestamp
	 * @param _startTimestamp Starting timestamp
	 * @param _endTimestamp End timestamp
	 * @return Hours in between starting and ending timestamp
	 */
	function _getHoursBetween(uint256 _startTimestamp, uint256 _endTimestamp) internal pure returns (uint256) {
		uint256 _timestampDiff = _endTimestamp.sub(_startTimestamp);

		uint256 _hours = 0;
		while(_timestampDiff >= 3600) {
			_timestampDiff -= 3600;
			_hours++;
		}
		return _hours;
	}
}