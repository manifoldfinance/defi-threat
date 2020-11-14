/**
 * Source Code first verified at https://etherscan.io on Tuesday, May 7, 2019
 (UTC) */

pragma solidity ^0.4.24;

/**
 * @title SpinWinInterface
 */
interface SpinWinInterface {
	function refundPendingBets() external returns (bool);
}


/**
 * @title AdvertisingInterface
 */
interface AdvertisingInterface {
	function incrementBetCounter() external returns (bool);
}


contract SpinWinLibraryInterface {
	function calculateWinningReward(uint256 betValue, uint256 playerNumber, uint256 houseEdge) external pure returns (uint256);
	function calculateTokenReward(address settingAddress, uint256 betValue, uint256 playerNumber, uint256 houseEdge) external constant returns (uint256);
	function generateRandomNumber(address settingAddress, uint256 betBlockNumber, uint256 extraData, uint256 divisor) external constant returns (uint256);
	function calculateClearBetBlocksReward(address settingAddress, address lotteryAddress) external constant returns (uint256);
	function calculateLotteryContribution(address settingAddress, address lotteryAddress, uint256 betValue) external constant returns (uint256);
	function calculateExchangeTokenValue(address settingAddress, uint256 tokenAmount) external constant returns (uint256, uint256, uint256, uint256);
}


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








/**
 * @title SpinWin
 */
contract SpinWin is developed, SpinWinInterface {
	using SafeMath for uint256;

	address public tokenAddress;
	address public settingAddress;
	address public lotteryAddress;

	TokenInterface internal _spintoken;
	SettingInterface internal _setting;
	LotteryInterface internal _lottery;
	SpinWinLibraryInterface internal _lib;
	AdvertisingInterface internal _advertising;

	/**
	 * @dev Player variables
	 */
	struct Bet {
		address playerAddress;
		bytes32 betId;
		uint256 betValue;
		uint256 diceResult;
		uint256 playerNumber;
		uint256 houseEdge;
		uint256 rewardValue;
		uint256 tokenRewardValue;
		uint256 blockNumber;
		bool processed;
	}
	struct TokenExchange {
		address playerAddress;
		bytes32 exchangeId;
		bool processed;
	}

	mapping (uint256 => Bet) internal bets;
	mapping (bytes32 => uint256) internal betIdLookup;
	mapping (address => uint256) public playerPendingWithdrawals;
	mapping (address => uint256) public playerPendingTokenWithdrawals;
	mapping (address => address) public referees;
	mapping (bytes32 => TokenExchange) public tokenExchanges;
	mapping (address => uint256) public lotteryBlocksAmount;

	uint256 constant public TWO_DECIMALS = 100;
	uint256 constant public PERCENTAGE_DIVISOR = 10 ** 6;   // 1000000 = 100%
	uint256 constant public CURRENCY_DIVISOR = 10**18;

	uint256 public totalPendingBets;

	/**
	 * @dev Log when bet is placed
	 */
	event LogBet(bytes32 indexed betId, address indexed playerAddress, uint256 playerNumber, uint256 betValue, uint256 houseEdge, uint256 rewardValue, uint256 tokenRewardValue);

	/**
	 * @dev Log when bet is cleared
	 *
	 * Status:
	 * -2 = lose + failed mint and transfer
	 * -1 = lose + failed send
	 * 0 = lose
	 * 1 = win
	 * 2 = win + failed send
	 * 3 = refund
	 * 4 = refund + failed send
	 * 5 = owner cancel + refund
	 * 6 = owner cancel + refund + failed send
	 */
	event LogResult(bytes32 indexed betId, address indexed playerAddress, uint256 playerNumber, uint256 diceResult, uint256 betValue, uint256 houseEdge, uint256 rewardValue, uint256 tokenRewardValue, int256 status);

	/**
	 * @dev Log when spinwin contributes some ETH to the lottery contract address
	 */
	event LogLotteryContribution(bytes32 indexed betId, address indexed playerAddress, uint256 weiValue);

	/**
	 * @dev Log when spinwin rewards the referee of a bet or the person clears bet
	 * rewardType
	 * 1 = referral
	 * 2 = clearBet
	 */
	event LogRewardLotteryBlocks(address indexed receiver, bytes32 indexed betId, uint256 lottoBlocksAmount, uint256 rewardType, uint256 status);

	/**
	 * @dev Log when player clears bets
	 */
	event LogClearBets(address indexed playerAddress);

	/**
	 * @dev Log when player claims the lottery blocks reward
	 *
	 * Status:
	 * 0 = failed
	 * 1 = success
	 */
	event LogClaimLotteryBlocks(address indexed playerAddress, uint256 numLottery, uint256 claimAmount, uint256 claimStatus);

	/**
	 * @dev Log when player exchanges token to Wei
	 *
	 * Status:
	 * 0 = failed send
	 * 1 = success
	 * 2 = failed destroy token
	 */
	event LogTokenExchange(bytes32 indexed exchangeId, address indexed playerAddress, uint256 tokenValue, uint256 tokenToWeiExchangeRate, uint256 weiValue, uint256 receivedWeiValue, uint256 remainderTokenValue, uint256 status);

	/**
	 * @dev Log when player withdraws balance from failed transfer
	 *
	 * Status:
	 * 0 = failed
	 * 1 = success
	 */
	event LogPlayerWithdrawBalance(address indexed playerAddress, uint256 withdrawAmount, uint256 status);

	/**
	 * @dev Log when player withdraw token balance from failed token transfer
	 *
	 * Status:
	 * 0 = failed
	 * 1 = success
	 */
	event LogPlayerWithdrawTokenBalance(address indexed playerAddress, uint256 withdrawAmount, uint256 status);

	/**
	 * @dev Log when a bet ID is not found during clear bet
	 */
	event LogBetNotFound(bytes32 indexed betId);

	/**
	 * @dev Log when developer cancel existing active bet
	 */
	event LogDeveloperCancelBet(bytes32 indexed betId, address indexed playerAddress);

	/**
	 * Constructor
	 * @param _tokenAddress SpinToken contract address
	 * @param _settingAddress GameSetting contract address
	 * @param _libraryAddress SpinWinLibrary contract address
	 */
	constructor(address _tokenAddress, address _settingAddress, address _libraryAddress) public {
		tokenAddress = _tokenAddress;
		settingAddress = _settingAddress;
		_spintoken = TokenInterface(_tokenAddress);
		_setting = SettingInterface(_settingAddress);
		_lib = SpinWinLibraryInterface(_libraryAddress);
	}

	/**
	 * @dev Checks if contract is active
	 */
	modifier isActive {
		require(_setting.isActive() == true);
		_;
	}

	/**
	 * @dev Checks whether a bet is allowed, and player profit, bet value, house edge and player number are within range
	 */
	modifier canBet(uint256 _betValue, uint256 _playerNumber, uint256 _houseEdge) {
		require(_setting.canBet(_lib.calculateWinningReward(_betValue, _playerNumber, _houseEdge), _betValue, _playerNumber, _houseEdge) == true);
		_;
	}

	/**
	 * @dev Checks if bet exist
	 */
	modifier betExist(bytes32 betId, address playerAddress) {
		require(betIdLookup[betId] > 0 && bets[betIdLookup[betId]].betId == betId && bets[betIdLookup[betId]].playerAddress == playerAddress);
		_;
	}

	/**
	 * @dev Checks if token exchange is allowed
	 */
	modifier isExchangeAllowed(address playerAddress, uint256 tokenAmount) {
		require(_setting.isExchangeAllowed(playerAddress, tokenAmount) == true);
		_;
	}

	/******************************************/
	/*       DEVELOPER ONLY METHODS           */
	/******************************************/
	/**
	 * @dev Allows developer to set lottery contract address
	 * @param _lotteryAddress The new lottery contract address to be set
	 */
	function devSetLotteryAddress(address _lotteryAddress) public onlyDeveloper {
		require (_lotteryAddress != address(0));
		lotteryAddress = _lotteryAddress;
		_lottery = LotteryInterface(_lotteryAddress);
	}

	/**
	 * @dev Allows developer to set advertising contract address
	 * @param _advertisingAddress The new advertising contract address to be set
	 */
	function devSetAdvertisingAddress(address _advertisingAddress) public onlyDeveloper {
		require (_advertisingAddress != address(0));
		_advertising = AdvertisingInterface(_advertisingAddress);
	}

	/**
	 * @dev Allows developer to get bet internal ID based on public betId
	 * @param betId The public betId
	 * @return The bet internal ID
	 */
	function devGetBetInternalId(bytes32 betId) public onlyDeveloper constant returns (uint256) {
		return (betIdLookup[betId]);
	}

	/**
	 * @dev Allows developer to get bet info based on `betInternalId`
	 * @param betInternalId The bet internal ID to be queried
	 * @return The bet information
	 */
	function devGetBet(uint256 betInternalId) public
		onlyDeveloper
		constant returns (address, uint256, uint256, uint256, uint256, uint256, uint256, uint256, bool) {
		Bet memory _bet = bets[betInternalId];
		return (_bet.playerAddress, _bet.betValue, _bet.diceResult, _bet.playerNumber, _bet.houseEdge, _bet.rewardValue, _bet.tokenRewardValue, _bet.blockNumber, _bet.processed);
	}

	/**
	 * @dev Allows developer to manually refund existing active bet.
	 * @param betId The ID of the bet to be cancelled
	 * @return Return true if success
	 */
	function devRefundBet(bytes32 betId) public onlyDeveloper returns (bool) {
		require (betIdLookup[betId] > 0);

		Bet storage _bet = bets[betIdLookup[betId]];

		require(_bet.processed == false);

		_bet.processed = true;
		uint256 betValue = _bet.betValue;
		_bet.betValue = 0;
		_bet.rewardValue = 0;
		_bet.tokenRewardValue = 0;

		_refundPlayer(betIdLookup[betId], betValue);
		return true;
	}

	/**
	 * @dev Add funds to the contract
	 */
	function () public payable isActive {
		_setting.spinwinAddFunds(msg.value);
	}

	/******************************************/
	/*           SETTING METHODS              */
	/******************************************/
	/**
	 * @dev Triggered during escape hatch. Go through each pending bets
	 * and move the bet value to playerPendingWithdrawals so that player
	 * can withdraw later
	 */
	function refundPendingBets() public returns (bool) {
		require (msg.sender == settingAddress);
		uint256 totalBets = _setting.uintSettings('totalBets');
		if (totalBets > 0) {
			for (uint256 i = 1; i <= totalBets; i++) {
				Bet storage _bet = bets[i];
				if (_bet.processed == false) {
					uint256 _betValue = _bet.betValue;
					_bet.processed = true;
					_bet.betValue = 0;
					playerPendingWithdrawals[_bet.playerAddress] = playerPendingWithdrawals[_bet.playerAddress].add(_betValue);
					emit LogResult(_bet.betId, _bet.playerAddress, _bet.playerNumber, 0, _betValue, _bet.houseEdge, 0, 0, 4);
				}
			}
		}
		return true;
	}

	/******************************************/
	/*            PUBLIC METHODS              */
	/******************************************/
	/**
	 * @dev Player places a bet. If it has a `referrerAddress`, we want to give reward to the referrer accordingly.
	 * @dev If there is a bet that needs to be cleared, we will do it here too.
	 * @param playerNumber The number that the player chose
	 * @param houseEdge The house edge percentage that the player chose
	 * @param clearBetId The bet ID to be cleared
	 * @param referreeAddress The referree address if exist
	 * @return Return true if success
	 */
	function rollDice(uint256 playerNumber, uint256 houseEdge, bytes32 clearBetId, address referreeAddress) public
		payable
		canBet(msg.value, playerNumber, houseEdge)
		returns (bool) {
		uint256 betInternalId = _storeBet(msg.value, msg.sender, playerNumber, houseEdge);

		// Check if we need to clear a pending bet
		if (clearBetId != '') {
			_clearSingleBet(msg.sender, clearBetId, _setting.uintSettings('blockSecurityCount'));
		}

		// Check if we need to reward the referree
		_rewardReferree(referreeAddress, betInternalId);

		_advertising.incrementBetCounter();

		return true;
	}

	/**
	 * @dev Player can clear multiple bets
	 * @param betIds The bet ids to be cleared
	 */
	function clearBets(bytes32[] betIds) public isActive {
		require (betIds.length > 0 && betIds.length <= _setting.uintSettings('maxNumClearBets'));
		bool canClear = false;
		uint256 blockSecurityCount = _setting.uintSettings('blockSecurityCount');
		for (uint256 i = 0; i < betIds.length; i++) {
			Bet memory _bet = bets[betIdLookup[betIds[i]]];
			if (_bet.processed == false && _setting.uintSettings('contractBalance') >= _bet.rewardValue && (block.number.sub(_bet.blockNumber)) >= blockSecurityCount) {
				canClear = true;
				break;
			}
		}
		require(canClear == true);

		// Loop through each bets and clear it if possible
		for (i = 0; i < betIds.length; i++) {
			_clearSingleBet(msg.sender, betIds[i], blockSecurityCount);
		}
		emit LogClearBets(msg.sender);
	}

	/**
	 * @dev Allow player to claim lottery blocks reward
	 * and spend it on lottery blocks
	 */
	function claimLotteryBlocks() public isActive {
		require (_lottery.isActive() == true);
		require (lotteryBlocksAmount[msg.sender] > 0);
		uint256 claimAmount = lotteryBlocksAmount[msg.sender];
		lotteryBlocksAmount[msg.sender] = 0;
		uint256 claimStatus = 1;
		if (!_lottery.claimReward(msg.sender, claimAmount)) {
			claimStatus = 0;
			lotteryBlocksAmount[msg.sender] = claimAmount;
		}
		emit LogClaimLotteryBlocks(msg.sender, _lottery.getNumLottery(), claimAmount, claimStatus);
	}

	/**
	 * @dev Player exchanges token for Wei
	 * @param tokenAmount The amount of token to be exchanged
	 * @return Return true if success
	 */
	function exchangeToken(uint256 tokenAmount) public
		isExchangeAllowed(msg.sender, tokenAmount) {
		(uint256 weiValue, uint256 sendWei, uint256 tokenRemainder, uint256 burnToken) = _lib.calculateExchangeTokenValue(settingAddress, tokenAmount);

		_setting.spinwinIncrementUintSetting('totalTokenExchanges');

		// Generate exchangeId
		bytes32 _exchangeId = keccak256(abi.encodePacked(this, msg.sender, _setting.uintSettings('totalTokenExchanges')));
		TokenExchange storage _tokenExchange = tokenExchanges[_exchangeId];

		// Make sure we don't process the exchange bet twice
		require (_tokenExchange.processed == false);

		// Update exchange metric
		_setting.spinwinUpdateExchangeMetric(sendWei);

		/*
		 * Store the info about this exchange
		 */
		_tokenExchange.playerAddress = msg.sender;
		_tokenExchange.exchangeId = _exchangeId;
		_tokenExchange.processed = true;

		/*
		 * Burn token at this address
		 */
		if (!_spintoken.burnAt(_tokenExchange.playerAddress, burnToken)) {
			uint256 exchangeStatus = 2; // status = failed destroy token

		} else {
			if (!_tokenExchange.playerAddress.send(sendWei)) {
				exchangeStatus = 0; // status = failed send

				// If send failed, let player withdraw via playerWithdrawPendingTransactions
				playerPendingWithdrawals[_tokenExchange.playerAddress] = playerPendingWithdrawals[_tokenExchange.playerAddress].add(sendWei);
			} else {
				exchangeStatus = 1; // status = success
			}
		}
		// Update the token to wei exchange rate
		_setting.spinwinUpdateTokenToWeiExchangeRate();

		emit LogTokenExchange(_tokenExchange.exchangeId, _tokenExchange.playerAddress, tokenAmount, _setting.uintSettings('tokenToWeiExchangeRateHonor'), weiValue, sendWei, tokenRemainder, exchangeStatus);
	}

	/**
	 * @dev Calculate winning ETH when player wins
	 * @param betValue The amount of ETH for this bet
	 * @param playerNumber The number that player chose
	 * @param houseEdge The house edge for this bet
	 * @return The amount of ETH to be sent to player if he/she wins
	 */
	function calculateWinningReward(uint256 betValue, uint256 playerNumber, uint256 houseEdge) public view returns (uint256) {
		return _lib.calculateWinningReward(betValue, playerNumber, houseEdge);
	}

	/**
	 * @dev Calculates token reward amount when player loses
	 * @param betValue The amount of ETH for this bet
	 * @param playerNumber The number that player chose
	 * @param houseEdge The house edge for this bet
	 * @return The amount of token to be sent to player if he/she loses
	 */
	function calculateTokenReward(uint256 betValue, uint256 playerNumber, uint256 houseEdge) public constant returns (uint256) {
		return _lib.calculateTokenReward(settingAddress, betValue, playerNumber, houseEdge);
	}

	/**
	 * @dev Player withdraws balance in case of a failed refund or failed win send
	 */
	function playerWithdrawPendingTransactions() public {
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
	 * @dev Players withdraws SPIN token balance in case of a failed token transfer
	 */
	function playerWithdrawPendingTokenTransactions() public {
		require(playerPendingTokenWithdrawals[msg.sender] > 0);
		uint256 withdrawAmount = playerPendingTokenWithdrawals[msg.sender];
		playerPendingTokenWithdrawals[msg.sender] = 0;

		// Mint and transfer token to msg.sender
		uint256 status = 1; // status = success
		if (!_spintoken.mintTransfer(msg.sender, withdrawAmount)) {
			status = 0; // status = failed
			/*
			 * If transfer failed, revert playerPendingTokenWithdrawals[msg.sender] = 0
			 * so that player can try to withdraw again later
			 */
			playerPendingTokenWithdrawals[msg.sender] = withdrawAmount;
		}
		emit LogPlayerWithdrawTokenBalance(msg.sender, withdrawAmount, status);
	}

	/**
	 * @dev Player gets bet information based on betId
	 * @return The bet information
	 */
	function playerGetBet(bytes32 betId) public
		constant returns (uint256, uint256, uint256, uint256, uint256, uint256, bool) {
		require(betIdLookup[betId] > 0 && bets[betIdLookup[betId]].betId == betId);
		Bet memory _bet = bets[betIdLookup[betId]];
		return (_bet.betValue, _bet.diceResult, _bet.playerNumber, _bet.houseEdge, _bet.rewardValue, _bet.tokenRewardValue, _bet.processed);
	}

	/**
	 * @dev Player gets pending bet IDs
	 * @return The pending bet IDs
	 */
	function playerGetPendingBetIds() public constant returns (bytes32[]) {
		bytes32[] memory pendingBetIds = new bytes32[](totalPendingBets);
		if (totalPendingBets > 0) {
			uint256 counter = 0;
			for (uint256 i = 1; i <= _setting.uintSettings('totalBets'); i++) {
				Bet memory _bet = bets[i];
				if (_bet.processed == false) {
					pendingBetIds[counter] = _bet.betId;
					counter++;
				}
				if (counter == totalPendingBets) {
					break;
				}
			}
		}
		return pendingBetIds;
	}

	/**
	 * @dev Player gets pending bet information based on betId
	 * @return The bet information
	 */
	function playerGetPendingBet(bytes32 betId) public
		constant returns (address, uint256, uint256, uint256, uint256) {
		require(betIdLookup[betId] > 0 && bets[betIdLookup[betId]].betId == betId);
		Bet memory _bet = bets[betIdLookup[betId]];
		return (_bet.playerAddress, _bet.playerNumber, _bet.betValue, _bet.houseEdge, _bet.blockNumber);
	}

	/**
	 * @dev Calculates lottery block rewards when player clears a bet
	 * @return The amount of lottery blocks to be rewarded when player clears bet
	 */
	function calculateClearBetBlocksReward() public constant returns (uint256) {
		return _lib.calculateClearBetBlocksReward(settingAddress, lotteryAddress);
	}


	/******************************************/
	/*           INTERNAL METHODS             */
	/******************************************/

	/**
	 * @dev Stores bet information.
	 * @param betValue The value of the bet
	 * @param playerAddress The player address
	 * @param playerNumber The number that player chose
	 * @param houseEdge The house edge for this bet
	 * @return The internal  bet ID of this bet
	 */
	function _storeBet (uint256 betValue, address playerAddress, uint256 playerNumber, uint256 houseEdge) internal returns (uint256) {
		// Update the setting metric
		_setting.spinwinRollDice(betValue);

		uint256 betInternalId = _setting.uintSettings('totalBets');

		// Generate betId
		bytes32 betId = keccak256(abi.encodePacked(this, playerAddress, betInternalId));

		Bet storage _bet = bets[betInternalId];

		// Make sure we don't process the same bet twice
		require (_bet.processed == false);

		// Store the info about this bet
		betIdLookup[betId] = betInternalId;
		_bet.playerAddress = playerAddress;
		_bet.betId = betId;
		_bet.betValue = betValue;
		_bet.playerNumber = playerNumber;
		_bet.houseEdge = houseEdge;

		// Safely calculate winning reward
		_bet.rewardValue = calculateWinningReward(betValue, playerNumber, houseEdge);

		// Safely calculate token payout
		_bet.tokenRewardValue = calculateTokenReward(betValue, playerNumber, houseEdge);
		_bet.blockNumber = block.number;

		// Update the pendingBets counter
		totalPendingBets++;

		emit LogBet(_bet.betId, _bet.playerAddress, _bet.playerNumber, _bet.betValue, _bet.houseEdge, _bet.rewardValue, _bet.tokenRewardValue);
		return betInternalId;
	}

	/**
	 * @dev Internal function to clear single bet
	 * @param playerAddress The player who clears this bet
	 * @param betId The bet ID to be cleared
	 * @param blockSecurityCount The block security count to be checked
	 * @return true if success, false otherwise
	 */
	function _clearSingleBet(address playerAddress, bytes32 betId, uint256 blockSecurityCount) internal returns (bool) {
		if (betIdLookup[betId] > 0) {
			Bet memory _bet = bets[betIdLookup[betId]];

			/* Check if we can clear this bet
			 * - Make sure we don't process the same bet twice
			 * - Check if contract can payout on win
			 * - block number difference >= blockSecurityCount
			 */
			if (_bet.processed == false && _setting.uintSettings('contractBalance') >= _bet.rewardValue && (block.number.sub(_bet.blockNumber)) >= blockSecurityCount) {
				_processBet(playerAddress, betIdLookup[betId], true);
			} else {
				emit LogRewardLotteryBlocks(playerAddress, _bet.betId, 0, 2, 0);
			}
			return true;
		} else {
			emit LogBetNotFound(betId);
			return false;
		}
	}

	/**
	 * @dev Internal function to process existing bet.
	 * If no dice result, then we initiate a refund.
	 * If player wins (dice result < player number), we send player winning ETH.
	 * If player loses (dice result >= player number), we send player some SPIN token.
	 * If player loses and bankroll goal is reached, spinwin will contribute some ETH to lottery contract address.
	 *
	 * @param triggerAddress The player who clears this bet
	 * @param betInternalId The bet internal ID to be processed
	 * @param isClearMultiple Whether or not this is part of clear multiple bets transaction
	 * @return Return true if success
	 */
	function _processBet(address triggerAddress, uint256 betInternalId, bool isClearMultiple) internal returns (bool) {
		Bet storage _bet =  bets[betInternalId];
		uint256 _betValue = _bet.betValue;
		uint256 _rewardValue = _bet.rewardValue;
		uint256 _tokenRewardValue = _bet.tokenRewardValue;

		// Prevent re-entrancy
		_bet.processed = true;
		_bet.betValue = 0;
		_bet.rewardValue = 0;
		_bet.tokenRewardValue = 0;

		// Generate the result
		_bet.diceResult = _lib.generateRandomNumber(settingAddress, _bet.blockNumber, _setting.uintSettings('totalBets').add(_setting.uintSettings('totalWeiWagered')), 100);

		if (_bet.diceResult == 0) {
			/*
			 * Invalid random number. Refund the player
			 */
			_refundPlayer(betInternalId, _betValue);
		} else if (_bet.diceResult < _bet.playerNumber) {
			/*
			 * Player wins. Send the player the winning eth amount
			 */
			_payWinner(betInternalId, _betValue, _rewardValue);
		} else {
			/*
			 * Player loses. Send the player 1 wei and the spintoken amount
			 */
			_payLoser(betInternalId, _betValue, _tokenRewardValue);
		}
		// Update the pendingBets counter
		totalPendingBets--;

		// Update the token to wei exchange rate
		_setting.spinwinUpdateTokenToWeiExchangeRate();

		// Calculate the lottery blocks reward for this transaction
		uint256 lotteryBlocksReward = calculateClearBetBlocksReward();

		// If this is a single clear (from placing bet), we want to multiply this with clearSingleBetMultiplier
		if (isClearMultiple == false) {
			uint256 multiplier = _setting.uintSettings('clearSingleBetMultiplier');
		} else {
			multiplier = _setting.uintSettings('clearMultipleBetsMultiplier');
		}
		lotteryBlocksReward = (lotteryBlocksReward.mul(multiplier)).div(TWO_DECIMALS);

		lotteryBlocksAmount[triggerAddress] = lotteryBlocksAmount[triggerAddress].add(lotteryBlocksReward);
		emit LogRewardLotteryBlocks(triggerAddress, _bet.betId, lotteryBlocksReward, 2, 1);
		return true;
	}

	/**
	 * @dev Refund the player when we are unable to determine the dice result
	 * @param betInternalId The bet internal ID
	 * @param refundAmount The amount to be refunded
	 */
	function _refundPlayer(uint256 betInternalId, uint256 refundAmount) internal {
		Bet memory _bet =  bets[betInternalId];
		/*
		 * Send refund - external call to an untrusted contract
		 * If send fails, map refund value to playerPendingWithdrawals[address]
		 * for withdrawal later via playerWithdrawPendingTransactions
		 */
		int256 betStatus = 3; // status = refund
		if (!_bet.playerAddress.send(refundAmount)) {
			betStatus = 4; // status = refund + failed send

			// If send failed, let player withdraw via playerWithdrawPendingTransactions
			playerPendingWithdrawals[_bet.playerAddress] = playerPendingWithdrawals[_bet.playerAddress].add(refundAmount);
		}
		emit LogResult(_bet.betId, _bet.playerAddress, _bet.playerNumber, _bet.diceResult, refundAmount, _bet.houseEdge, 0, 0, betStatus);
	}

	/**
	 * @dev Pays the player the winning eth amount
	 * @param betInternalId The bet internal ID
	 * @param betValue The original wager
	 * @param playerProfit The player profit
	 */
	function _payWinner(uint256 betInternalId, uint256 betValue, uint256 playerProfit) internal {
		Bet memory _bet =  bets[betInternalId];
		// Update setting's contract balance and total wei won
		_setting.spinwinUpdateWinMetric(playerProfit);

		// Safely calculate payout via profit plus original wager
		playerProfit = playerProfit.add(betValue);

		/*
		 * Send win - external call to an untrusted contract
		 * If send fails, map reward value to playerPendingWithdrawals[address]
		 * for withdrawal later via playerWithdrawPendingTransactions
		 */
		int256 betStatus = 1; // status = win
		if (!_bet.playerAddress.send(playerProfit)) {
			betStatus = 2; // status = win + failed send

			// If send failed, let player withdraw via playerWithdrawPendingTransactions
			playerPendingWithdrawals[_bet.playerAddress] = playerPendingWithdrawals[_bet.playerAddress].add(playerProfit);
		}
		emit LogResult(_bet.betId, _bet.playerAddress, _bet.playerNumber, _bet.diceResult, betValue, _bet.houseEdge, playerProfit, 0, betStatus);
	}

	/**
	 * @dev Pays the player 1 wei and the spintoken amount
	 * @param betInternalId The bet internal ID
	 * @param betValue The original wager
	 * @param tokenRewardValue The token reward for this bet
	 */
	function _payLoser(uint256 betInternalId, uint256 betValue, uint256 tokenRewardValue) internal {
		Bet memory _bet =  bets[betInternalId];
		/*
		 * Update the game setting metric when player loses
		 */
		_setting.spinwinUpdateLoseMetric(betValue, tokenRewardValue);

		int256 betStatus; // status = lose

		/*
		 * Send 1 Wei to losing bet - external call to an untrusted contract
		 */
		if (!_bet.playerAddress.send(1)) {
			betStatus = -1; // status = lose + failed send

			// If send failed, let player withdraw via playerWithdrawPendingTransactions
			playerPendingWithdrawals[_bet.playerAddress] = playerPendingWithdrawals[_bet.playerAddress].add(1);
		}

		/*
		 * Mint and transfer token reward to this player
		 */
		if (tokenRewardValue > 0) {
			if (!_spintoken.mintTransfer(_bet.playerAddress, tokenRewardValue)) {
				betStatus = -2; // status = lose + failed mint and transfer

				// If transfer token failed, let player withdraw via playerWithdrawPendingTokenTransactions
				playerPendingTokenWithdrawals[_bet.playerAddress] = playerPendingTokenWithdrawals[_bet.playerAddress].add(tokenRewardValue);
			}
		}
		emit LogResult(_bet.betId, _bet.playerAddress, _bet.playerNumber, _bet.diceResult, betValue, _bet.houseEdge, 1, tokenRewardValue, betStatus);
		_sendLotteryContribution(betInternalId, betValue);
	}

	/**
	 * @dev Contribute the house win to lottery address
	 * @param betInternalId The bet internal ID
	 * @param betValue The original wager
	 * @return Return true if success
	 */
	function _sendLotteryContribution(uint256 betInternalId, uint256 betValue) internal returns (bool) {
		/*
		 * If contractBalance >= minBankroll, contribute the a percentage of the winning to lottery
		 */
		uint256 contractBalance = _setting.uintSettings('contractBalance');
		if (contractBalance >= _setting.uintSettings('minBankroll')) {
			Bet memory _bet =  bets[betInternalId];
			uint256 lotteryContribution = _lib.calculateLotteryContribution(settingAddress, lotteryAddress, betValue);

			if (lotteryContribution > 0 && contractBalance >= lotteryContribution) {
				// Safely adjust contractBalance
				_setting.spinwinUpdateLotteryContributionMetric(lotteryContribution);

				emit LogLotteryContribution(_bet.betId, _bet.playerAddress, lotteryContribution);

				// Contribute to the lottery
				if (!lotteryAddress.call.gas(_setting.uintSettings('gasForLottery')).value(lotteryContribution)()) {
					return false;
				}
			}
		}
		return true;
	}

	/**
	 * @dev Reward the referree if necessary.
	 * @param referreeAddress The address of the referree
	 * @param betInternalId The internal bet ID
	 */
	function _rewardReferree(address referreeAddress, uint256 betInternalId) internal {
		Bet memory _bet = bets[betInternalId];

		// If the player already has a referee, use that address
		if (referees[_bet.playerAddress] != address(0)) {
			referreeAddress = referees[_bet.playerAddress];
		}
		if (referreeAddress != address(0) && referreeAddress != _bet.playerAddress) {
			referees[_bet.playerAddress] = referreeAddress;
			uint256 _tokenForLotto = _bet.tokenRewardValue.mul(_setting.uintSettings('referralPercent')).div(PERCENTAGE_DIVISOR);
			lotteryBlocksAmount[referreeAddress] = lotteryBlocksAmount[referreeAddress].add(_tokenForLotto);
			emit LogRewardLotteryBlocks(referreeAddress, _bet.betId, _tokenForLotto, 1, 1);
		}
	}
}