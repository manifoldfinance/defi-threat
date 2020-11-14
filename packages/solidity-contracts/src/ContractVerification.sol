/**
 * Source Code first verified at https://etherscan.io on Tuesday, May 7, 2019
 (UTC) */

pragma solidity ^0.4.24;

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
 * @title ContractVerification
 */
contract ContractVerification is developed {
	bool public contractKilled;

	mapping(bytes32 => string) public stringSettings;  // Array containing all string settings
	mapping(bytes32 => uint256) public uintSettings;   // Array containing all uint256 settings
	mapping(bytes32 => bool) public boolSettings;      // Array containing all bool settings

	/**
	 * @dev Setting variables
	 */
	struct Version {
		bool active;
		uint256[] hostIds;
		string settings;
	}
	struct Host {
		bool active;
		string settings;
	}

	// mapping versionNum => Version
	mapping(uint256 => Version) public versions;

	// mapping hostId => Host
	mapping(uint256 => Host) public hosts;

	uint256 public totalVersionSetting;
	uint256 public totalHostSetting;

	/**
	 * @dev Log dev updates string setting
	 */
	event LogUpdateStringSetting(bytes32 indexed name, string value);

	/**
	 * @dev Log dev updates uint setting
	 */
	event LogUpdateUintSetting(bytes32 indexed name, uint256 value);

	/**
	 * @dev Log dev updates bool setting
	 */
	event LogUpdateBoolSetting(bytes32 indexed name, bool value);

	/**
	 * @dev Log dev deletes string setting
	 */
	event LogDeleteStringSetting(bytes32 indexed name);

	/**
	 * @dev Log dev deletes uint setting
	 */
	event LogDeleteUintSetting(bytes32 indexed name);

	/**
	 * @dev Log dev deletes bool setting
	 */
	event LogDeleteBoolSetting(bytes32 indexed name);

	/**
	 * @dev Log dev add version setting
	 */
	event LogAddVersionSetting(uint256 indexed versionNum, bool active, uint256[] hostIds, string settings);

	/**
	 * @dev Log dev delete version setting
	 */
	event LogDeleteVersionSetting(uint256 indexed versionNum);

	/**
	 * @dev Log dev update version setting
	 */
	event LogUpdateVersionSetting(uint256 indexed versionNum, bool active, uint256[] hostIds, string settings);

	/**
	 * @dev Log dev add host setting
	 */
	event LogAddHostSetting(uint256 indexed hostId, bool active, string settings);

	/**
	 * @dev Log dev delete host setting
	 */
	event LogDeleteHostSetting(uint256 indexed hostId);

	/**
	 * @dev Log dev update host setting
	 */
	event LogUpdateHostSetting(uint256 indexed hostId, bool active, string settings);

	/**
	 * @dev Log dev add host to version
	 */
	event LogAddHostIdToVersion(uint256 indexed hostId, uint256 versionNum, bool success);

	/**
	 * @dev Log dev remove host id at version
	 */
	event LogRemoveHostIdAtVersion(uint256 indexed hostId, uint256 versionNum, bool success);

	/**
	 * @dev Log when emergency mode is on
	 */
	event LogEscapeHatch();

	/**
	 * Constructor
	 */
	constructor() public {}

	/******************************************/
	/*       DEVELOPER ONLY METHODS           */
	/******************************************/

	/**
	 * @dev Allows dev to update string setting
	 * @param name The setting name to be set
	 * @param value The value to be set
	 */
	function updateStringSetting(bytes32 name, string value) public onlyDeveloper {
		stringSettings[name] = value;
		emit LogUpdateStringSetting(name, value);
	}

	/**
	 * @dev Allows dev to set uint setting
	 * @param name The setting name to be set
	 * @param value The value to be set
	 */
	function updateUintSetting(bytes32 name, uint256 value) public onlyDeveloper {
		uintSettings[name] = value;
		emit LogUpdateUintSetting(name, value);
	}

	/**
	 * @dev Allows dev to set bool setting
	 * @param name The setting name to be set
	 * @param value The value to be set
	 */
	function updateBoolSetting(bytes32 name, bool value) public onlyDeveloper {
		boolSettings[name] = value;
		emit LogUpdateBoolSetting(name, value);
	}

	/**
	 * @dev Allows dev to delete string setting
	 * @param name The setting name to be deleted
	 */
	function deleteStringSetting(bytes32 name) public onlyDeveloper {
		delete stringSettings[name];
		emit LogDeleteStringSetting(name);
	}

	/**
	 * @dev Allows dev to delete uint setting
	 * @param name The setting name to be deleted
	 */
	function deleteUintSetting(bytes32 name) public onlyDeveloper {
		delete uintSettings[name];
		emit LogDeleteUintSetting(name);
	}

	/**
	 * @dev Allows dev to delete bool setting
	 * @param name The setting name to be deleted
	 */
	function deleteBoolSetting(bytes32 name) public onlyDeveloper {
		delete boolSettings[name];
		emit LogDeleteBoolSetting(name);
	}

	/**
	 * @dev Allows dev to add version settings
	 * @param active The boolean value to be set
	 * @param hostIds An array of hostIds
	 * @param settings The settings string to be set
	 */
	function addVersionSetting(bool active, uint256[] hostIds, string settings) public onlyDeveloper {
		totalVersionSetting++;

		// Make sure every ID in hostIds exists
		if (hostIds.length > 0) {
			for(uint256 i=0; i<hostIds.length; i++) {
				require (bytes(hosts[hostIds[i]].settings).length > 0);
			}
		}
		Version storage _version = versions[totalVersionSetting];
		_version.active = active;
		_version.hostIds = hostIds;
		_version.settings = settings;

		emit LogAddVersionSetting(totalVersionSetting, _version.active, _version.hostIds, _version.settings);
	}

	/**
	 * @dev Allows dev to delete version settings
	 * @param versionNum The version num
	 */
	function deleteVersionSetting(uint256 versionNum) public onlyDeveloper {
		delete versions[versionNum];
		emit LogDeleteVersionSetting(versionNum);
	}

	/**
	 * @dev Allows dev to update version settings
	 * @param versionNum The version of this setting
	 * @param active The boolean value to be set
	 * @param hostIds The array of host ids
	 * @param settings The settings string to be set
	 */
	function updateVersionSetting(uint256 versionNum, bool active, uint256[] hostIds, string settings) public onlyDeveloper {
		// Make sure version setting of this versionNum exists
		require (bytes(versions[versionNum].settings).length > 0);

		// Make sure every ID in hostIds exists
		if (hostIds.length > 0) {
			for(uint256 i=0; i<hostIds.length; i++) {
				require (bytes(hosts[hostIds[i]].settings).length > 0);
			}
		}
		Version storage _version = versions[versionNum];
		_version.active = active;
		_version.hostIds = hostIds;
		_version.settings = settings;

		emit LogUpdateVersionSetting(versionNum, _version.active, _version.hostIds, _version.settings);
	}

	/**
	 * @dev Allows dev to add host id to version hostIds
	 * @param hostId The host Id to be added
	 * @param versionNum The version num destination
	 */
	function addHostIdToVersion(uint256 hostId, uint256 versionNum) public onlyDeveloper {
		require (hosts[hostId].active == true);
		require (versions[versionNum].active == true);

		Version storage _version = versions[versionNum];
		if (_version.hostIds.length == 0) {
			_version.hostIds.push(hostId);
			emit LogAddHostIdToVersion(hostId, versionNum, true);
		} else {
			bool exist = false;
			for (uint256 i=0; i < _version.hostIds.length; i++) {
				if (_version.hostIds[i] == hostId) {
					exist = true;
					break;
				}
			}
			if (!exist) {
				_version.hostIds.push(hostId);
				emit LogAddHostIdToVersion(hostId, versionNum, true);
			} else {
				emit LogAddHostIdToVersion(hostId, versionNum, false);
			}
		}
	}

	/**
	 * @dev Allows dev to remove host id at version hostIds
	 * @param hostId The host Id to be removed
	 * @param versionNum The version num destination
	 */
	function removeHostIdAtVersion(uint256 hostId, uint256 versionNum) public onlyDeveloper {
		Version storage _version = versions[versionNum];
		require (versions[versionNum].active == true);
		uint256 hostIdCount = versions[versionNum].hostIds.length;
		require (hostIdCount > 0);

		int256 position = -1;
		for (uint256 i=0; i < hostIdCount; i++) {
			if (_version.hostIds[i] == hostId) {
				position = int256(i);
				break;
			}
		}
		require (position >= 0);

		for (i = uint256(position); i < hostIdCount-1; i++){
			_version.hostIds[i] = _version.hostIds[i+1];
		}
		delete _version.hostIds[hostIdCount-1];
		_version.hostIds.length--;
		emit LogRemoveHostIdAtVersion(hostId, versionNum, true);
	}

	/**
	 * @dev Allows dev to add host settings
	 * @param active The boolean value to be set
	 * @param settings The settings string to be set
	 */
	function addHostSetting(bool active, string settings) public onlyDeveloper {
		totalHostSetting++;

		Host storage _host = hosts[totalHostSetting];
		_host.active = active;
		_host.settings = settings;

		emit LogAddHostSetting(totalHostSetting, _host.active, _host.settings);
	}

	/**
	 * @dev Allows dev to delete host settings
	 * @param hostId The host ID
	 */
	function deleteHostSetting(uint256 hostId) public onlyDeveloper {
		require (bytes(hosts[hostId].settings).length > 0);

		delete hosts[hostId];
		emit LogDeleteHostSetting(hostId);
	}

	/**
	 * @dev Allows dev to update host settings
	 * @param hostId The host ID
	 * @param active The boolean value to be set
	 * @param settings The settings string to be set
	 */
	function updateHostSetting(uint256 hostId, bool active, string settings) public onlyDeveloper {
		require (bytes(hosts[hostId].settings).length > 0);

		Host storage _host = hosts[hostId];
		_host.active = active;
		_host.settings = settings;

		emit LogUpdateHostSetting(hostId, _host.active, _host.settings);
	}

	/**
	 * @dev Allows developer to trigger emergency mode
	 */
	function escapeHatch() public onlyDeveloper {
		require (contractKilled == false);
		contractKilled = true;
		if (address(this).balance > 0) {
			developer.transfer(address(this).balance);
		}
		emit LogEscapeHatch();
	}

	/******************************************/
	/*             PUBLIC METHODS             */
	/******************************************/

	/**
	 * @dev Get version settings based on versionNum
	 * @param versionNum The version num
	 * @return Active state of this version
	 * @return Array of host Ids
	 * @return The settings string
	 */
	function getVersionSetting(uint256 versionNum) public constant returns (bool, uint256[], string) {
		Version memory _version = versions[versionNum];
		return (_version.active, _version.hostIds, _version.settings);
	}

	/**
	 * @dev Get latest version settings
	 * @return Active state of the latest version
	 * @return Array of host Ids
	 * @return The settings string
	 */
	function getLatestVersionSetting() public constant returns (bool, uint256[], string) {
		Version memory _version = versions[totalVersionSetting];
		return (_version.active, _version.hostIds, _version.settings);
	}
}