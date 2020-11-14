/**
 * Source Code first verified at https://etherscan.io on Tuesday, May 7, 2019
 (UTC) */

pragma solidity ^0.4.24;

/**
 * @title AdvertisingInterface
 */
interface AdvertisingInterface {
	function incrementBetCounter() external returns (bool);
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
 * @title Advertising
 */
contract Advertising is developed, AdvertisingInterface {
	using SafeMath for uint256;
	address private incrementer;

	bool public paused;
	bool public contractKilled;

	uint256 public numCreatives;
	uint256 public numCreativeTypes;
	uint256 public maxCountPerCreativeType;
	uint256 public earnedBalance;

	struct Creative {
		bytes32 creativeId;
		address advertiser;
		uint256 creativeTypeId;       // This determines the creative size and where we display it
		string name;
		uint256 weiBudget;
		uint256 weiPerBet;
		uint256 betCounter;
		int256 position;
		string url;
		string imageUrl;
		bool approved;
		uint256 createdOn;
	}

	struct CreativeType {
		string name;
		uint256 width;
		uint256 height;
		/**
		 * @dev Where to display the creative
		 * 1 = top
		 * 2 = right
		 * 3 = bottom
		 * 4 = left
		 */
		uint256 position;
		bool active;
	}

	mapping (bytes32 => Creative) public creatives;
	mapping (bytes32 => uint256) private creativeIdLookup;
	mapping (uint256 => CreativeType) public creativeTypes;
	mapping (address => uint256) public advertiserPendingWithdrawals;
	mapping (uint256 => bytes32[]) public pendingCreativePosition;
	mapping (uint256 => bytes32[]) public approvedCreativePosition;

	/**
	 * @dev Log when dev add new creative type
	 */
	event LogAddCreativeType(uint256 indexed creativeTypeId, string name, uint256 width, uint256 height, uint256 position);

	/**
	 * @dev Log when dev activate/deactivate creative type
	 */
	event LogSetActiveCreativeType(uint256 creativeTypeId, bool active);

	/**
	 * @dev Log when dev approves creative
	 */
	event LogApproveCreative(bytes32 indexed creativeId, address indexed advertiser, uint256 indexed creativeTypeId, int256 position);

	/**
	 * @dev Log when dev set contract to emergency mode
	 */
	event LogEscapeHatch();

	/**
	 * @dev Log when advertiser creates creative
	 */
	event LogCreateCreative(bytes32 indexed creativeId, address indexed advertiser, uint256 indexed creativeTypeId, string name, uint256 weiBudget, uint256 weiPerBet, int256 position);

	/**
	 * @dev Log when we refund creative
	 * creativeStatus:
	 * 0 = pending
	 * 1 = approved
	 * refundStatus:
	 * 0 = failed
	 * 1 = success
	 */
	event LogRefundCreative(bytes32 indexed creativeId, address indexed advertiser, uint256 refundAmount, uint256 creativeStatus, uint256 refundStatus);

	/**
	 * @dev Log when advertiser withdraws balance from failed transfer
	 *
	 * Status:
	 * 0 = failed
	 * 1 = success
	 */
	event LogWithdrawBalance(address indexed advertiser, uint256 withdrawAmount, uint256 status);

	/**
	 * @dev Log when we increment bet counter for a creative
	 */
	event LogIncrementBetCounter(bytes32 indexed creativeId, address indexed advertiser, uint256 numBets);

	/**
	 * Constructor
	 */
	constructor(address _incrementer) public {
		devSetMaxCountPerCreativeType(10);
		devSetIncrementer(_incrementer);
	}

	/**
	 * @dev Checks if the contract is currently alive
	 */
	modifier contractIsAlive {
		require(contractKilled == false);
		_;
	}

	/**
	 * @dev Checks if contract is active
	 */
	modifier isActive {
		require(paused == false);
		_;
	}

	/**
	 * @dev Check if creative is valid
	 * @param creativeTypeId The creative type ID
	 * @param name The name of this creative
	 * @param weiBudget The budget for this creative
	 * @param weiPerBet Cost per bet for an ad
	 * @param url The url of the ad that we want to redirect to
	 * @param imageUrl The image url for this ad
	 */
	modifier creativeIsValid(uint256 creativeTypeId, string name, uint256 weiBudget, uint256 weiPerBet, string url, string imageUrl) {
		require (creativeTypes[creativeTypeId].active == true &&
			 bytes(name).length > 0 &&
			 weiBudget > 0 &&
			 weiPerBet > 0 &&
			 weiBudget >= weiPerBet &&
			 bytes(url).length > 0 &&
			 bytes(imageUrl).length > 0 &&
			 (pendingCreativePosition[creativeTypeId].length < maxCountPerCreativeType ||
			  (pendingCreativePosition[creativeTypeId].length == maxCountPerCreativeType && weiPerBet > creatives[pendingCreativePosition[creativeTypeId][maxCountPerCreativeType-1]].weiPerBet)
			 )
		);
		_;
	}

	/**
	 * @dev Checks is caller is from incrementer
	 */
	modifier onlyIncrementer {
		require (msg.sender == incrementer);
		_;
	}

	/******************************************/
	/*       DEVELOPER ONLY METHODS           */
	/******************************************/
	/**
	 * @dev Dev sets address that is allowed to increment ad metrics
	 * @param _incrementer The address to be set
	 */
	function devSetIncrementer(address _incrementer) public onlyDeveloper {
		incrementer = _incrementer;
	}

	/**
	 * @dev Dev get incrementer address
	 */
	function devGetIncrementer() public onlyDeveloper constant returns (address) {
		return incrementer;
	}

	/**
	 * @dev Dev sets max count per creative type
	 * @param _maxCountPerCreativeType The max number of ad for a creative type
	 */
	function devSetMaxCountPerCreativeType(uint256 _maxCountPerCreativeType) public onlyDeveloper {
		require (_maxCountPerCreativeType > 0);
		maxCountPerCreativeType = _maxCountPerCreativeType;
	}

	/**
	 * @dev Dev add creative type
	 * @param name The name of this creative type
	 * @param width The width of the creative
	 * @param height The height of the creative
	 * @param position The position of the creative
	 */
	function devAddCreativeType(string name, uint256 width, uint256 height, uint256 position) public onlyDeveloper {
		require (width > 0 && height > 0 && position > 0);

		// Increment num creative types
		numCreativeTypes++;

		CreativeType storage _creativeType = creativeTypes[numCreativeTypes];

		// Store the info about this creative type
		_creativeType.name = name;
		_creativeType.width = width;
		_creativeType.height = height;
		_creativeType.position = position;
		_creativeType.active = true;

		emit LogAddCreativeType(numCreativeTypes, _creativeType.name, _creativeType.width, _creativeType.height, _creativeType.position);
	}

	/**
	 * @dev Dev activate/deactivate creative type
	 * @param creativeTypeId The creative type ID to be set
	 * @param active The bool value to be set
	 */
	function devSetActiveCreativeType(uint256 creativeTypeId, bool active) public onlyDeveloper {
		creativeTypes[creativeTypeId].active = active;
		emit LogSetActiveCreativeType(creativeTypeId, active);
	}

	/**
	 * @dev Allows dev to approve/disapprove a creative
	 * @param creativeId The creative ID to be approved
	 */
	function devApproveCreative(bytes32 creativeId) public onlyDeveloper {
		Creative storage _creative = creatives[creativeId];
		require (_creative.approved == false && _creative.position > -1 && _creative.createdOn > 0);
		_creative.approved = true;
		_removePending(creativeId);
		_insertSortApprovedCreative(_creative.creativeTypeId, _creative.creativeId);
	}

	/**
	 * @dev Allows dev to withdraw earned balance
	 */
	function devWithdrawEarnedBalance() public onlyDeveloper returns (bool) {
		require (earnedBalance > 0);
		require (address(this).balance >= earnedBalance);
		uint256 withdrawAmount = earnedBalance;
		earnedBalance = 0;
		if (!developer.send(withdrawAmount)) {
			earnedBalance = withdrawAmount;
			return false;
		} else {
			return true;
		}
	}

	/**
	 * @dev Dev ends the ad
	 * @param creativeId The creative ID to be ended
	 */
	function devEndCreative(bytes32 creativeId) public onlyDeveloper {
		_endCreative(creativeId);
	}

	/**
	 * @dev Allows developer to pause the contract
	 * @param _paused The new paused value to be set
	 */
	function devSetPaused(bool _paused) public onlyDeveloper {
		paused = _paused;
	}

	/**
	 * @dev Allows developer to trigger emergency mode.
	 */
	function escapeHatch() public onlyDeveloper contractIsAlive returns (bool) {
		contractKilled = true;
		if (earnedBalance > 0) {
			uint256 withdrawAmount = earnedBalance;
			earnedBalance = 0;
			if (!developer.send(withdrawAmount)) {
				earnedBalance = withdrawAmount;
			}
		}

		if (numCreativeTypes > 0) {
			for (uint256 i=1; i <= numCreativeTypes; i++) {
				/*
				 * First, we refund all the pending creatives.
				 * Instead of sending the refund amount, we ask advertisers to withdraw the refunded amount themselves
				 */
				uint256 creativeCount = pendingCreativePosition[i].length;
				if (creativeCount > 0) {
					for (uint256 j=0; j < creativeCount; j++) {
						Creative memory _creative = creatives[pendingCreativePosition[i][j]];

						// let advertiser withdraw via advertiserPendingWithdrawals
						advertiserPendingWithdrawals[_creative.advertiser] = advertiserPendingWithdrawals[_creative.advertiser].add(_creative.weiBudget);
					}
				}

				/*
				 * Then, we refund all the approved creatives
				 */
				creativeCount = approvedCreativePosition[i].length;
				if (creativeCount > 0) {
					for (j=0; j < creativeCount; j++) {
						_creative = creatives[approvedCreativePosition[i][j]];
						uint256 refundAmount = _creative.weiBudget.sub(_creative.betCounter.mul(_creative.weiPerBet));
						// let advertiser withdraw via advertiserPendingWithdrawals
						advertiserPendingWithdrawals[_creative.advertiser] = advertiserPendingWithdrawals[_creative.advertiser].add(refundAmount);
					}
				}
			}
		}

		emit LogEscapeHatch();
		return true;
	}

	/******************************************/
	/*      INCREMENT ADDRESS METHODS         */
	/******************************************/
	function incrementBetCounter() public onlyIncrementer contractIsAlive isActive returns (bool) {
		if (numCreativeTypes > 0) {
			for (uint256 i=1; i <= numCreativeTypes; i++) {
				CreativeType memory _creativeType = creativeTypes[i];
				uint256 creativeCount = approvedCreativePosition[i].length;
				if (_creativeType.active == false || creativeCount == 0) {
					continue;
				}

				Creative storage _creative = creatives[approvedCreativePosition[i][0]];
				_creative.betCounter++;
				emit LogIncrementBetCounter(_creative.creativeId, _creative.advertiser, _creative.betCounter);

				uint256 totalSpent = _creative.weiPerBet.mul(_creative.betCounter);
				if (totalSpent > _creative.weiBudget) {
					earnedBalance = earnedBalance.add(_creative.weiBudget.sub(_creative.weiPerBet.mul(_creative.betCounter.sub(1))));
					_removeApproved(_creative.creativeId);
				} else {
					earnedBalance = earnedBalance.add(_creative.weiPerBet);
				}
			}
		}
		return true;
	}

	/******************************************/
	/*             PUBLIC METHODS             */
	/******************************************/

	/**
	 * @dev Advertiser submits an ad
	 * @param creativeTypeId The creative type ID (determines where we display it)
	 * @param name The name of this creative
	 * @param weiPerBet Cost per bet for an ad
	 * @param url The url of the ad that we want to redirect to
	 * @param imageUrl The image url for this ad
	 */
	function createCreative(uint256 creativeTypeId, string name, uint256 weiPerBet, string url, string imageUrl)
		public
		payable
		contractIsAlive
		isActive
		creativeIsValid(creativeTypeId, name, msg.value, weiPerBet, url, imageUrl) {
		// Increment num creatives
		numCreatives++;

		// Generate ID for this creative
		bytes32 creativeId = keccak256(abi.encodePacked(this, msg.sender, numCreatives));

		Creative storage _creative = creatives[creativeId];

		// Store the info about this creative
		_creative.creativeId = creativeId;
		_creative.advertiser = msg.sender;
		_creative.creativeTypeId = creativeTypeId;
		_creative.name = name;
		_creative.weiBudget = msg.value;
		_creative.weiPerBet = weiPerBet;
		_creative.url = url;
		_creative.imageUrl = imageUrl;
		_creative.createdOn = now;

		// Decide which position this creative is
		_insertSortPendingCreative(creativeTypeId, creativeId);
	}

	/**
	 * @dev Advertiser ends the ad
	 * @param creativeId The creative ID to be ended
	 */
	function endCreative(bytes32 creativeId) public
		contractIsAlive
		isActive {
		Creative storage _creative = creatives[creativeId];
		require (_creative.advertiser == msg.sender);
		_endCreative(creativeId);
	}

	/**
	 * @dev withdraws balance in case of a failed refund or failed win send
	 */
	function withdrawPendingTransactions() public {
		uint256 withdrawAmount = advertiserPendingWithdrawals[msg.sender];
		require (withdrawAmount > 0);
		require (address(this).balance >= withdrawAmount);

		advertiserPendingWithdrawals[msg.sender] = 0;

		// External call to untrusted contract
		if (msg.sender.send(withdrawAmount)) {
			emit LogWithdrawBalance(msg.sender, withdrawAmount, 1);
		} else {
			/*
			 * If send failed, revert advertiserPendingWithdrawals[msg.sender] = 0
			 * so that player can try to withdraw again later
			 */
			advertiserPendingWithdrawals[msg.sender] = withdrawAmount;
			emit LogWithdrawBalance(msg.sender, withdrawAmount, 0);
		}
	}

	/******************************************/
	/*           INTERNAL METHODS             */
	/******************************************/

	/**
	 * @dev Insert the newly submitted creative and sort the array to determine its position.
	 *      If the array container length is greater than max count, then we want to refund the last element
	 * @param creativeTypeId The creative type ID of this ad
	 * @param creativeId The creative ID of this ad
	 */
	function _insertSortPendingCreative(uint256 creativeTypeId, bytes32 creativeId) internal {
		pendingCreativePosition[creativeTypeId].push(creativeId);

		uint256 pendingCount = pendingCreativePosition[creativeTypeId].length;
		bytes32[] memory copyArray = new bytes32[](pendingCount);

		for (uint256 i=0; i<pendingCount; i++) {
			copyArray[i] = pendingCreativePosition[creativeTypeId][i];
		}

		uint256 value;
		bytes32 key;
		for (i = 1; i < copyArray.length; i++) {
			key = copyArray[i];
			value = creatives[copyArray[i]].weiPerBet;
			for (uint256 j=i; j > 0 && creatives[copyArray[j-1]].weiPerBet < value; j--) {
				copyArray[j] = copyArray[j-1];
			}
			copyArray[j] = key;
		}

		for (i=0; i<pendingCount; i++) {
			pendingCreativePosition[creativeTypeId][i] = copyArray[i];
			creatives[copyArray[i]].position = int(i);
		}

		Creative memory _creative = creatives[creativeId];
		emit LogCreateCreative(_creative.creativeId, _creative.advertiser, _creative.creativeTypeId, _creative.name, _creative.weiBudget, _creative.weiPerBet, _creative.position);

		// If total count is more than max count, then we want to refund the last ad
		if (pendingCount > maxCountPerCreativeType) {
			bytes32 removeCreativeId = pendingCreativePosition[creativeTypeId][pendingCount-1];
			creatives[removeCreativeId].position = -1;
			delete pendingCreativePosition[creativeTypeId][pendingCount-1];
			pendingCreativePosition[creativeTypeId].length--;
			_refundPending(removeCreativeId);
		}
	}

	/**
	 * @dev Refund the pending creative
	 * @param creativeId The creative ID of this ad
	 */
	function _refundPending(bytes32 creativeId) internal {
		Creative memory _creative = creatives[creativeId];
		require (address(this).balance >= _creative.weiBudget);
		require (_creative.position == -1);
		if (!_creative.advertiser.send(_creative.weiBudget)) {
			emit LogRefundCreative(_creative.creativeId, _creative.advertiser, _creative.weiBudget, 0, 0);

			// If send failed, let advertiser withdraw via advertiserPendingWithdrawals
			advertiserPendingWithdrawals[_creative.advertiser] = advertiserPendingWithdrawals[_creative.advertiser].add(_creative.weiBudget);
		} else {
			emit LogRefundCreative(_creative.creativeId, _creative.advertiser, _creative.weiBudget, 0, 1);
		}
	}

	/**
	 * @dev Insert the newly approved creative and sort the array to determine its position.
	 *      If the array container length is greater than max count, then we want to refund the last element.
	 * @param creativeTypeId The creative type ID of this ad
	 * @param creativeId The creative ID of this ad
	 */
	function _insertSortApprovedCreative(uint256 creativeTypeId, bytes32 creativeId) internal {
		approvedCreativePosition[creativeTypeId].push(creativeId);

		uint256 approvedCount = approvedCreativePosition[creativeTypeId].length;
		bytes32[] memory copyArray = new bytes32[](approvedCount);

		for (uint256 i=0; i<approvedCount; i++) {
			copyArray[i] = approvedCreativePosition[creativeTypeId][i];
		}

		uint256 value;
		bytes32 key;
		for (i = 1; i < copyArray.length; i++) {
			key = copyArray[i];
			value = creatives[copyArray[i]].weiPerBet;
			for (uint256 j=i; j > 0 && creatives[copyArray[j-1]].weiPerBet < value; j--) {
				copyArray[j] = copyArray[j-1];
			}
			copyArray[j] = key;
		}

		for (i=0; i<approvedCount; i++) {
			approvedCreativePosition[creativeTypeId][i] = copyArray[i];
			creatives[copyArray[i]].position = int(i);
		}

		Creative memory _creative = creatives[creativeId];
		emit LogApproveCreative(_creative.creativeId, _creative.advertiser, _creative.creativeTypeId, _creative.position);

		// If total count is more than max count, then we want to refund the last ad
		if (approvedCount > maxCountPerCreativeType) {
			bytes32 removeCreativeId = approvedCreativePosition[creativeTypeId][approvedCount-1];
			creatives[removeCreativeId].position = -1;
			delete approvedCreativePosition[creativeTypeId][approvedCount-1];
			approvedCreativePosition[creativeTypeId].length--;
			_refundApproved(removeCreativeId);
		}
	}

	/**
	 * @dev Refund the approved creative
	 * @param creativeId The creative ID of this ad
	 */
	function _refundApproved(bytes32 creativeId) internal {
		Creative memory _creative = creatives[creativeId];
		uint256 refundAmount = _creative.weiBudget.sub(_creative.betCounter.mul(_creative.weiPerBet));
		require (address(this).balance >= refundAmount);
		require (_creative.position == -1);
		if (!_creative.advertiser.send(refundAmount)) {
			emit LogRefundCreative(_creative.creativeId, _creative.advertiser, refundAmount, 1, 0);

			// If send failed, let advertiser withdraw via advertiserPendingWithdrawals
			advertiserPendingWithdrawals[_creative.advertiser] = advertiserPendingWithdrawals[_creative.advertiser].add(refundAmount);
		} else {
			emit LogRefundCreative(_creative.creativeId, _creative.advertiser, refundAmount, 1, 1);
		}
	}

	/**
	 * @dev End creative
	 * @param creativeId The creative ID to be removed
	 */
	function _endCreative(bytes32 creativeId) internal {
		Creative storage _creative = creatives[creativeId];
		require (_creative.position > -1 && _creative.createdOn > 0);

		if (_creative.approved == false) {
			_removePending(creativeId);
			_refundPending(creativeId);
		} else {
			_removeApproved(creativeId);
			_refundApproved(creativeId);
		}
	}

	/**
	 * @dev Remove element in pending creatives array
	 * @param creativeId The creative ID to be removed
	 */
	function _removePending(bytes32 creativeId) internal {
		Creative storage _creative = creatives[creativeId];
		uint256 pendingCount = pendingCreativePosition[_creative.creativeTypeId].length;

		if (_creative.position >= int256(pendingCount)) return;

		for (uint256 i = uint256(_creative.position); i < pendingCount-1; i++){
			pendingCreativePosition[_creative.creativeTypeId][i] = pendingCreativePosition[_creative.creativeTypeId][i+1];
			creatives[pendingCreativePosition[_creative.creativeTypeId][i]].position = int256(i);
		}
		_creative.position = -1;
		delete pendingCreativePosition[_creative.creativeTypeId][pendingCount-1];
		pendingCreativePosition[_creative.creativeTypeId].length--;
	}

	/**
	 * @dev Remove element in approved creatives array
	 * @param creativeId The creative ID to be removed
	 */
	function _removeApproved(bytes32 creativeId) internal {
		Creative storage _creative = creatives[creativeId];
		uint256 approvedCount = approvedCreativePosition[_creative.creativeTypeId].length;

		if (_creative.position >= int256(approvedCount)) return;

		for (uint256 i = uint256(_creative.position); i < approvedCount-1; i++){
			approvedCreativePosition[_creative.creativeTypeId][i] = approvedCreativePosition[_creative.creativeTypeId][i+1];
			creatives[approvedCreativePosition[_creative.creativeTypeId][i]].position = int256(i);
		}
		_creative.position = -1;
		delete approvedCreativePosition[_creative.creativeTypeId][approvedCount-1];
		approvedCreativePosition[_creative.creativeTypeId].length--;
	}
}