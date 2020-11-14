/**
 * Source Code first verified at https://etherscan.io on Wednesday, March 20, 2019
 (UTC) */

pragma solidity ^0.4.24;

/**
 * @title Utility contract to allow pausing and unpausing of certain functions
 */
contract Pausable {

    event Pause(uint256 _timestammp);
    event Unpause(uint256 _timestamp);

    bool public paused = false;

    /**
    * @notice Modifier to make a function callable only when the contract is not paused.
    */
    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    /**
    * @notice Modifier to make a function callable only when the contract is paused.
    */
    modifier whenPaused() {
        require(paused, "Contract is not paused");
        _;
    }

   /**
    * @notice Called by the owner to pause, triggers stopped state
    */
    function _pause() internal whenNotPaused {
        paused = true;
        /*solium-disable-next-line security/no-block-members*/
        emit Pause(now);
    }

    /**
    * @notice Called by the owner to unpause, returns to normal state
    */
    function _unpause() internal whenPaused {
        paused = false;
        /*solium-disable-next-line security/no-block-members*/
        emit Unpause(now);
    }

}

/**
 * @title Interface that every module contract should implement
 */
interface IModule {

    /**
     * @notice This function returns the signature of configure function
     */
    function getInitFunction() external pure returns (bytes4);

    /**
     * @notice Return the permission flags that are associated with a module
     */
    function getPermissions() external view returns(bytes32[]);

    /**
     * @notice Used to withdraw the fee by the factory owner
     */
    function takeFee(uint256 _amount) external returns(bool);

}

/**
 * @title Interface for all security tokens
 */
interface ISecurityToken {

    // Standard ERC20 interface
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function decreaseApproval(address _spender, uint _subtractedValue) external returns (bool);
    function increaseApproval(address _spender, uint _addedValue) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    //transfer, transferFrom must respect the result of verifyTransfer
    function verifyTransfer(address _from, address _to, uint256 _value) external returns (bool success);

    /**
     * @notice Mints new tokens and assigns them to the target _investor.
     * Can only be called by the STO attached to the token (Or by the ST owner if there's no STO attached yet)
     * @param _investor Address the tokens will be minted to
     * @param _value is the amount of tokens that will be minted to the investor
     */
    function mint(address _investor, uint256 _value) external returns (bool success);

    /**
     * @notice Mints new tokens and assigns them to the target _investor.
     * Can only be called by the STO attached to the token (Or by the ST owner if there's no STO attached yet)
     * @param _investor Address the tokens will be minted to
     * @param _value is The amount of tokens that will be minted to the investor
     * @param _data Data to indicate validation
     */
    function mintWithData(address _investor, uint256 _value, bytes _data) external returns (bool success);

    /**
     * @notice Used to burn the securityToken on behalf of someone else
     * @param _from Address for whom to burn tokens
     * @param _value No. of tokens to be burned
     * @param _data Data to indicate validation
     */
    function burnFromWithData(address _from, uint256 _value, bytes _data) external;

    /**
     * @notice Used to burn the securityToken
     * @param _value No. of tokens to be burned
     * @param _data Data to indicate validation
     */
    function burnWithData(uint256 _value, bytes _data) external;

    event Minted(address indexed _to, uint256 _value);
    event Burnt(address indexed _burner, uint256 _value);

    // Permissions this to a Permission module, which has a key of 1
    // If no Permission return false - note that IModule withPerm will allow ST owner all permissions anyway
    // this allows individual modules to override this logic if needed (to not allow ST owner all permissions)
    function checkPermission(address _delegate, address _module, bytes32 _perm) external view returns (bool);

    /**
     * @notice Returns module list for a module type
     * @param _module Address of the module
     * @return bytes32 Name
     * @return address Module address
     * @return address Module factory address
     * @return bool Module archived
     * @return uint8 Module type
     * @return uint256 Module index
     * @return uint256 Name index

     */
    function getModule(address _module) external view returns(bytes32, address, address, bool, uint8, uint256, uint256);

    /**
     * @notice Returns module list for a module name
     * @param _name Name of the module
     * @return address[] List of modules with this name
     */
    function getModulesByName(bytes32 _name) external view returns (address[]);

    /**
     * @notice Returns module list for a module type
     * @param _type Type of the module
     * @return address[] List of modules with this type
     */
    function getModulesByType(uint8 _type) external view returns (address[]);

    /**
     * @notice Queries totalSupply at a specified checkpoint
     * @param _checkpointId Checkpoint ID to query as of
     */
    function totalSupplyAt(uint256 _checkpointId) external view returns (uint256);

    /**
     * @notice Queries balance at a specified checkpoint
     * @param _investor Investor to query balance for
     * @param _checkpointId Checkpoint ID to query as of
     */
    function balanceOfAt(address _investor, uint256 _checkpointId) external view returns (uint256);

    /**
     * @notice Creates a checkpoint that can be used to query historical balances / totalSuppy
     */
    function createCheckpoint() external returns (uint256);

    /**
     * @notice Gets length of investors array
     * NB - this length may differ from investorCount if the list has not been pruned of zero-balance investors
     * @return Length
     */
    function getInvestors() external view returns (address[]);

    /**
     * @notice returns an array of investors at a given checkpoint
     * NB - this length may differ from investorCount as it contains all investors that ever held tokens
     * @param _checkpointId Checkpoint id at which investor list is to be populated
     * @return list of investors
     */
    function getInvestorsAt(uint256 _checkpointId) external view returns(address[]);

    /**
     * @notice generates subset of investors
     * NB - can be used in batches if investor list is large
     * @param _start Position of investor to start iteration from
     * @param _end Position of investor to stop iteration at
     * @return list of investors
     */
    function iterateInvestors(uint256 _start, uint256 _end) external view returns(address[]);
    
    /**
     * @notice Gets current checkpoint ID
     * @return Id
     */
    function currentCheckpointId() external view returns (uint256);

    /**
    * @notice Gets an investor at a particular index
    * @param _index Index to return address from
    * @return Investor address
    */
    function investors(uint256 _index) external view returns (address);

   /**
    * @notice Allows the owner to withdraw unspent POLY stored by them on the ST or any ERC20 token.
    * @dev Owner can transfer POLY to the ST which will be used to pay for modules that require a POLY fee.
    * @param _tokenContract Address of the ERC20Basic compliance token
    * @param _value Amount of POLY to withdraw
    */
    function withdrawERC20(address _tokenContract, uint256 _value) external;

    /**
    * @notice Allows owner to approve more POLY to one of the modules
    * @param _module Module address
    * @param _budget New budget
    */
    function changeModuleBudget(address _module, uint256 _budget) external;

    /**
     * @notice Changes the tokenDetails
     * @param _newTokenDetails New token details
     */
    function updateTokenDetails(string _newTokenDetails) external;

    /**
    * @notice Allows the owner to change token granularity
    * @param _granularity Granularity level of the token
    */
    function changeGranularity(uint256 _granularity) external;

    /**
    * @notice Removes addresses with zero balances from the investors list
    * @param _start Index in investors list at which to start removing zero balances
    * @param _iters Max number of iterations of the for loop
    * NB - pruning this list will mean you may not be able to iterate over investors on-chain as of a historical checkpoint
    */
    function pruneInvestors(uint256 _start, uint256 _iters) external;

    /**
     * @notice Freezes all the transfers
     */
    function freezeTransfers() external;

    /**
     * @notice Un-freezes all the transfers
     */
    function unfreezeTransfers() external;

    /**
     * @notice Ends token minting period permanently
     */
    function freezeMinting() external;

    /**
     * @notice Mints new tokens and assigns them to the target investors.
     * Can only be called by the STO attached to the token or by the Issuer (Security Token contract owner)
     * @param _investors A list of addresses to whom the minted tokens will be delivered
     * @param _values A list of the amount of tokens to mint to corresponding addresses from _investor[] list
     * @return Success
     */
    function mintMulti(address[] _investors, uint256[] _values) external returns (bool success);

    /**
     * @notice Function used to attach a module to the security token
     * @dev  E.G.: On deployment (through the STR) ST gets a TransferManager module attached to it
     * @dev to control restrictions on transfers.
     * @dev You are allowed to add a new moduleType if:
     * @dev - there is no existing module of that type yet added
     * @dev - the last member of the module list is replacable
     * @param _moduleFactory is the address of the module factory to be added
     * @param _data is data packed into bytes used to further configure the module (See STO usage)
     * @param _maxCost max amount of POLY willing to pay to module. (WIP)
     */
    function addModule(
        address _moduleFactory,
        bytes _data,
        uint256 _maxCost,
        uint256 _budget
    ) external;

    /**
    * @notice Archives a module attached to the SecurityToken
    * @param _module address of module to archive
    */
    function archiveModule(address _module) external;

    /**
    * @notice Unarchives a module attached to the SecurityToken
    * @param _module address of module to unarchive
    */
    function unarchiveModule(address _module) external;

    /**
    * @notice Removes a module attached to the SecurityToken
    * @param _module address of module to archive
    */
    function removeModule(address _module) external;

    /**
     * @notice Used by the issuer to set the controller addresses
     * @param _controller address of the controller
     */
    function setController(address _controller) external;

    /**
     * @notice Used by a controller to execute a forced transfer
     * @param _from address from which to take tokens
     * @param _to address where to send tokens
     * @param _value amount of tokens to transfer
     * @param _data data to indicate validation
     * @param _log data attached to the transfer by controller to emit in event
     */
    function forceTransfer(address _from, address _to, uint256 _value, bytes _data, bytes _log) external;

    /**
     * @notice Used by a controller to execute a foced burn
     * @param _from address from which to take tokens
     * @param _value amount of tokens to transfer
     * @param _data data to indicate validation
     * @param _log data attached to the transfer by controller to emit in event
     */
    function forceBurn(address _from, uint256 _value, bytes _data, bytes _log) external;

    /**
     * @notice Used by the issuer to permanently disable controller functionality
     * @dev enabled via feature switch "disableControllerAllowed"
     */
     function disableController() external;

     /**
     * @notice Used to get the version of the securityToken
     */
     function getVersion() external view returns(uint8[]);

     /**
     * @notice Gets the investor count
     */
     function getInvestorCount() external view returns(uint256);

     /**
      * @notice Overloaded version of the transfer function
      * @param _to receiver of transfer
      * @param _value value of transfer
      * @param _data data to indicate validation
      * @return bool success
      */
     function transferWithData(address _to, uint256 _value, bytes _data) external returns (bool success);

     /**
      * @notice Overloaded version of the transferFrom function
      * @param _from sender of transfer
      * @param _to receiver of transfer
      * @param _value value of transfer
      * @param _data data to indicate validation
      * @return bool success
      */
     function transferFromWithData(address _from, address _to, uint256 _value, bytes _data) external returns(bool);

     /**
      * @notice Provides the granularity of the token
      * @return uint256
      */
     function granularity() external view returns(uint256);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function decreaseApproval(address _spender, uint _subtractedValue) external returns (bool);
    function increaseApproval(address _spender, uint _addedValue) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Storage for Module contract
 * @notice Contract is abstract
 */
contract ModuleStorage {

    /**
     * @notice Constructor
     * @param _securityToken Address of the security token
     * @param _polyAddress Address of the polytoken
     */
    constructor (address _securityToken, address _polyAddress) public {
        securityToken = _securityToken;
        factory = msg.sender;
        polyToken = IERC20(_polyAddress);
    }
    
    address public factory;

    address public securityToken;

    bytes32 public constant FEE_ADMIN = "FEE_ADMIN";

    IERC20 public polyToken;

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

/**
 * @title Interface that any module contract should implement
 * @notice Contract is abstract
 */
contract Module is IModule, ModuleStorage {

    /**
     * @notice Constructor
     * @param _securityToken Address of the security token
     * @param _polyAddress Address of the polytoken
     */
    constructor (address _securityToken, address _polyAddress) public
    ModuleStorage(_securityToken, _polyAddress)
    {
    }

    //Allows owner, factory or permissioned delegate
    modifier withPerm(bytes32 _perm) {
        bool isOwner = msg.sender == Ownable(securityToken).owner();
        bool isFactory = msg.sender == factory;
        require(isOwner||isFactory||ISecurityToken(securityToken).checkPermission(msg.sender, address(this), _perm), "Permission check failed");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == Ownable(securityToken).owner(), "Sender is not owner");
        _;
    }

    modifier onlyFactory {
        require(msg.sender == factory, "Sender is not factory");
        _;
    }

    modifier onlyFactoryOwner {
        require(msg.sender == Ownable(factory).owner(), "Sender is not factory owner");
        _;
    }

    modifier onlyFactoryOrOwner {
        require((msg.sender == Ownable(securityToken).owner()) || (msg.sender == factory), "Sender is not factory or owner");
        _;
    }

    /**
     * @notice used to withdraw the fee by the factory owner
     */
    function takeFee(uint256 _amount) public withPerm(FEE_ADMIN) returns(bool) {
        require(polyToken.transferFrom(securityToken, Ownable(factory).owner(), _amount), "Unable to take fee");
        return true;
    }

}

/**
 * @title Interface to be implemented by all STO modules
 */
interface ISTO {
    /**
     * @notice Returns the total no. of tokens sold
     */
    function getTokensSold() external view returns (uint256);
}

/**
 * @title Storage layout for the STO contract
 */
contract STOStorage {

    mapping (uint8 => bool) public fundRaiseTypes;
    mapping (uint8 => uint256) public fundsRaised;

    // Start time of the STO
    uint256 public startTime;
    // End time of the STO
    uint256 public endTime;
    // Time STO was paused
    uint256 public pausedTime;
    // Number of individual investors
    uint256 public investorCount;
    // Address where ETH & POLY funds are delivered
    address public wallet;
     // Final amount of tokens sold
    uint256 public totalTokensSold;

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title Interface to be implemented by all STO modules
 */
contract STO is ISTO, STOStorage, Module, Pausable  {
    using SafeMath for uint256;

    enum FundRaiseType { ETH, POLY, SC }

    // Event
    event SetFundRaiseTypes(FundRaiseType[] _fundRaiseTypes);

    /**
     * @notice Returns funds raised by the STO
     */
    function getRaised(FundRaiseType _fundRaiseType) public view returns (uint256) {
        return fundsRaised[uint8(_fundRaiseType)];
    }

    /**
     * @notice Pause (overridden function)
     */
    function pause() public onlyOwner {
        /*solium-disable-next-line security/no-block-members*/
        require(now < endTime, "STO has been finalized");
        super._pause();
    }

    /**
     * @notice Unpause (overridden function)
     */
    function unpause() public onlyOwner {
        super._unpause();
    }

    function _setFundRaiseType(FundRaiseType[] _fundRaiseTypes) internal {
        // FundRaiseType[] parameter type ensures only valid values for _fundRaiseTypes
        require(_fundRaiseTypes.length > 0 && _fundRaiseTypes.length <= 3, "Raise type is not specified");
        fundRaiseTypes[uint8(FundRaiseType.ETH)] = false;
        fundRaiseTypes[uint8(FundRaiseType.POLY)] = false;
        fundRaiseTypes[uint8(FundRaiseType.SC)] = false;
        for (uint8 j = 0; j < _fundRaiseTypes.length; j++) {
            fundRaiseTypes[uint8(_fundRaiseTypes[j])] = true;
        }
        emit SetFundRaiseTypes(_fundRaiseTypes);
    }

    /**
    * @notice Reclaims ERC20Basic compatible tokens
    * @dev We duplicate here due to the overriden owner & onlyOwner
    * @param _tokenContract The address of the token contract
    */
    function reclaimERC20(address _tokenContract) external onlyOwner {
        require(_tokenContract != address(0), "Invalid address");
        IERC20 token = IERC20(_tokenContract);
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(msg.sender, balance), "Transfer failed");
    }

    /**
    * @notice Reclaims ETH
    * @dev We duplicate here due to the overriden owner & onlyOwner
    */
    function reclaimETH() external onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

}

interface IOracle {

    /**
    * @notice Returns address of oracle currency (0x0 for ETH)
    */
    function getCurrencyAddress() external view returns(address);

    /**
    * @notice Returns symbol of oracle currency (0x0 for ETH)
    */
    function getCurrencySymbol() external view returns(bytes32);

    /**
    * @notice Returns denomination of price
    */
    function getCurrencyDenominated() external view returns(bytes32);

    /**
    * @notice Returns price - should throw if not valid
    */
    function getPrice() external view returns(uint256);

}

/**
 * @title Utility contract to allow owner to retreive any ERC20 sent to the contract
 */
contract ReclaimTokens is Ownable {

    /**
    * @notice Reclaim all ERC20Basic compatible tokens
    * @param _tokenContract The address of the token contract
    */
    function reclaimERC20(address _tokenContract) external onlyOwner {
        require(_tokenContract != address(0), "Invalid address");
        IERC20 token = IERC20(_tokenContract);
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(owner, balance), "Transfer failed");
    }
}

/**
 * @title Core functionality for registry upgradability
 */
contract PolymathRegistry is ReclaimTokens {

    mapping (bytes32 => address) public storedAddresses;

    event ChangeAddress(string _nameKey, address indexed _oldAddress, address indexed _newAddress);

    /**
     * @notice Gets the contract address
     * @param _nameKey is the key for the contract address mapping
     * @return address
     */
    function getAddress(string _nameKey) external view returns(address) {
        bytes32 key = keccak256(bytes(_nameKey));
        require(storedAddresses[key] != address(0), "Invalid address key");
        return storedAddresses[key];
    }

    /**
     * @notice Changes the contract address
     * @param _nameKey is the key for the contract address mapping
     * @param _newAddress is the new contract address
     */
    function changeAddress(string _nameKey, address _newAddress) external onlyOwner {
        bytes32 key = keccak256(bytes(_nameKey));
        emit ChangeAddress(_nameKey, storedAddresses[key], _newAddress);
        storedAddresses[key] = _newAddress;
    }


}

contract RegistryUpdater is Ownable {

    address public polymathRegistry;
    address public moduleRegistry;
    address public securityTokenRegistry;
    address public featureRegistry;
    address public polyToken;

    constructor (address _polymathRegistry) public {
        require(_polymathRegistry != address(0), "Invalid address");
        polymathRegistry = _polymathRegistry;
    }

    function updateFromRegistry() public onlyOwner {
        moduleRegistry = PolymathRegistry(polymathRegistry).getAddress("ModuleRegistry");
        securityTokenRegistry = PolymathRegistry(polymathRegistry).getAddress("SecurityTokenRegistry");
        featureRegistry = PolymathRegistry(polymathRegistry).getAddress("FeatureRegistry");
        polyToken = PolymathRegistry(polymathRegistry).getAddress("PolyToken");
    }

}

library DecimalMath {

    using SafeMath for uint256;

     /**
     * @notice This function multiplies two decimals represented as (decimal * 10**DECIMALS)
     * @return uint256 Result of multiplication represented as (decimal * 10**DECIMALS)
     */
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = SafeMath.add(SafeMath.mul(x, y), (10 ** 18) / 2) / (10 ** 18);
    }

    /**
     * @notice This function divides two decimals represented as (decimal * 10**DECIMALS)
     * @return uint256 Result of division represented as (decimal * 10**DECIMALS)
     */
    function div(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = SafeMath.add(SafeMath.mul(x, (10 ** 18)), y / 2) / y;
    }

}

/**
 * @title Helps contracts guard agains reentrancy attacks.
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="1f6d7a727c705f2d">[email protected]</a>π.com>
 * @notice If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

  /**
   * @dev We use a single lock for the whole contract.
   */
  bool private reentrancyLock = false;

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * @notice If you mark a function `nonReentrant`, you should also
   * mark it `external`. Calling one nonReentrant function from
   * another is not supported. Instead, you can implement a
   * `private` function doing the actual work, and a `external`
   * wrapper marked as `nonReentrant`.
   */
  modifier nonReentrant() {
    require(!reentrancyLock);
    reentrancyLock = true;
    _;
    reentrancyLock = false;
  }

}

/**
 * @title Contract used to store layout for the USDTieredSTO storage
 */
contract USDTieredSTOStorage {

    /////////////
    // Storage //
    /////////////
    struct Tier {
        // NB rates mentioned below are actually price and are used like price in the logic.
        // How many token units a buyer gets per USD in this tier (multiplied by 10**18)
        uint256 rate;

        // How many token units a buyer gets per USD in this tier (multiplied by 10**18) when investing in POLY up to tokensDiscountPoly
        uint256 rateDiscountPoly;

        // How many tokens are available in this tier (relative to totalSupply)
        uint256 tokenTotal;

        // How many token units are available in this tier (relative to totalSupply) at the ratePerTierDiscountPoly rate
        uint256 tokensDiscountPoly;

        // How many tokens have been minted in this tier (relative to totalSupply)
        uint256 mintedTotal;

        // How many tokens have been minted in this tier (relative to totalSupply) for each fund raise type
        mapping (uint8 => uint256) minted;

        // How many tokens have been minted in this tier (relative to totalSupply) at discounted POLY rate
        uint256 mintedDiscountPoly;
    }

    struct Investor {
        // Whether investor is accredited (0 = non-accredited, 1 = accredited)
        uint8 accredited;
        // Whether we have seen the investor before (already added to investors list)
        uint8 seen;
        // Overrides for default limit in USD for non-accredited investors multiplied by 10**18 (0 = no override)
        uint256 nonAccreditedLimitUSDOverride;
    }

    mapping (bytes32 => mapping (bytes32 => string)) oracleKeys;

    // Determine whether users can invest on behalf of a beneficiary
    bool public allowBeneficialInvestments = false;

    // Whether or not the STO has been finalized
    bool public isFinalized;

    // Address of issuer reserve wallet for unsold tokens
    address public reserveWallet;

    // List of stable coin addresses
    address[] public usdTokens;

    // Current tier
    uint256 public currentTier;

    // Amount of USD funds raised
    uint256 public fundsRaisedUSD;

    // Amount of stable coins raised
    mapping (address => uint256) public stableCoinsRaised;

    // Amount in USD invested by each address
    mapping (address => uint256) public investorInvestedUSD;

    // Amount in fund raise type invested by each investor
    mapping (address => mapping (uint8 => uint256)) public investorInvested;

    // Accredited & non-accredited investor data
    mapping (address => Investor) public investors;

    // List of active stable coin addresses
    mapping (address => bool) public usdTokenEnabled;

    // List of all addresses that have been added as accredited or non-accredited without
    // the default limit
    address[] public investorsList;

    // Default limit in USD for non-accredited investors multiplied by 10**18
    uint256 public nonAccreditedLimitUSD;

    // Minimum investable amount in USD
    uint256 public minimumInvestmentUSD;

    // Final amount of tokens returned to issuer
    uint256 public finalAmountReturned;

    // Array of Tiers
    Tier[] public tiers;

}

/**
 * @title STO module for standard capped crowdsale
 */
contract USDTieredSTO is USDTieredSTOStorage, STO, ReentrancyGuard {
    using SafeMath for uint256;

    string public constant POLY_ORACLE = "PolyUsdOracle";
    string public constant ETH_ORACLE = "EthUsdOracle";

    ////////////
    // Events //
    ////////////

    event SetAllowBeneficialInvestments(bool _allowed);
    event SetNonAccreditedLimit(address _investor, uint256 _limit);
    event SetAccredited(address _investor, bool _accredited);
    event TokenPurchase(
        address indexed _purchaser,
        address indexed _beneficiary,
        uint256 _tokens,
        uint256 _usdAmount,
        uint256 _tierPrice,
        uint256 _tier
    );
    event FundsReceived(
        address indexed _purchaser,
        address indexed _beneficiary,
        uint256 _usdAmount,
        FundRaiseType _fundRaiseType,
        uint256 _receivedValue,
        uint256 _spentValue,
        uint256 _rate
    );
    event ReserveTokenMint(address indexed _owner, address indexed _wallet, uint256 _tokens, uint256 _latestTier);
    event SetAddresses(
        address indexed _wallet,
        address indexed _reserveWallet,
        address[] _usdTokens
    );
    event SetLimits(
        uint256 _nonAccreditedLimitUSD,
        uint256 _minimumInvestmentUSD
    );
    event SetTimes(
        uint256 _startTime,
        uint256 _endTime
    );
    event SetTiers(
        uint256[] _ratePerTier,
        uint256[] _ratePerTierDiscountPoly,
        uint256[] _tokensPerTierTotal,
        uint256[] _tokensPerTierDiscountPoly
    );

    ///////////////
    // Modifiers //
    ///////////////

    modifier validETH {
        require(_getOracle(bytes32("ETH"), bytes32("USD")) != address(0), "Invalid Oracle");
        require(fundRaiseTypes[uint8(FundRaiseType.ETH)], "ETH not allowed");
        _;
    }

    modifier validPOLY {
        require(_getOracle(bytes32("POLY"), bytes32("USD")) != address(0), "Invalid Oracle");
        require(fundRaiseTypes[uint8(FundRaiseType.POLY)], "POLY not allowed");
        _;
    }

    modifier validSC(address _usdToken) {
        require(fundRaiseTypes[uint8(FundRaiseType.SC)] && usdTokenEnabled[_usdToken], "USD not allowed");
        _;
    }

    ///////////////////////
    // STO Configuration //
    ///////////////////////

    constructor (address _securityToken, address _polyAddress)
    public
    Module(_securityToken, _polyAddress)
    {
    }

    /**
     * @notice Function used to intialize the contract variables
     * @param _startTime Unix timestamp at which offering get started
     * @param _endTime Unix timestamp at which offering get ended
     * @param _ratePerTier Rate (in USD) per tier (* 10**18)
     * @param _tokensPerTierTotal Tokens available in each tier
     * @param _nonAccreditedLimitUSD Limit in USD (* 10**18) for non-accredited investors
     * @param _minimumInvestmentUSD Minimun investment in USD (* 10**18)
     * @param _fundRaiseTypes Types of currency used to collect the funds
     * @param _wallet Ethereum account address to hold the funds
     * @param _reserveWallet Ethereum account address to receive unsold tokens
     * @param _usdTokens Array of contract addressess of the stable coins
     */
    function configure(
        uint256 _startTime,
        uint256 _endTime,
        uint256[] _ratePerTier,
        uint256[] _ratePerTierDiscountPoly,
        uint256[] _tokensPerTierTotal,
        uint256[] _tokensPerTierDiscountPoly,
        uint256 _nonAccreditedLimitUSD,
        uint256 _minimumInvestmentUSD,
        FundRaiseType[] _fundRaiseTypes,
        address _wallet,
        address _reserveWallet,
        address[] _usdTokens
    ) public onlyFactory {
        oracleKeys[bytes32("ETH")][bytes32("USD")] = ETH_ORACLE;
        oracleKeys[bytes32("POLY")][bytes32("USD")] = POLY_ORACLE;
        require(endTime == 0, "Already configured");
        _modifyTimes(_startTime, _endTime);
        _modifyTiers(_ratePerTier, _ratePerTierDiscountPoly, _tokensPerTierTotal, _tokensPerTierDiscountPoly);
        // NB - _setFundRaiseType must come before modifyAddresses
        _setFundRaiseType(_fundRaiseTypes);
        _modifyAddresses(_wallet, _reserveWallet, _usdTokens);
        _modifyLimits(_nonAccreditedLimitUSD, _minimumInvestmentUSD);
    }

    /**
     * @dev Modifies fund raise types
     * @param _fundRaiseTypes Array of fund raise types to allow
     */
    function modifyFunding(FundRaiseType[] _fundRaiseTypes) external onlyOwner {
        /*solium-disable-next-line security/no-block-members*/
        require(now < startTime, "STO already started");
        _setFundRaiseType(_fundRaiseTypes);
    }

    /**
     * @dev modifies max non accredited invets limit and overall minimum investment limit
     * @param _nonAccreditedLimitUSD max non accredited invets limit
     * @param _minimumInvestmentUSD overall minimum investment limit
     */
    function modifyLimits(
        uint256 _nonAccreditedLimitUSD,
        uint256 _minimumInvestmentUSD
    ) external onlyOwner {
        /*solium-disable-next-line security/no-block-members*/
        require(now < startTime, "STO already started");
        _modifyLimits(_nonAccreditedLimitUSD, _minimumInvestmentUSD);
    }

    /**
     * @dev modifiers STO tiers. All tiers must be passed, can not edit specific tiers.
     * @param _ratePerTier Array of rates per tier
     * @param _ratePerTierDiscountPoly Array of discounted poly rates per tier
     * @param _tokensPerTierTotal Array of total tokens per tier
     * @param _tokensPerTierDiscountPoly Array of discounted tokens per tier
     */
    function modifyTiers(
        uint256[] _ratePerTier,
        uint256[] _ratePerTierDiscountPoly,
        uint256[] _tokensPerTierTotal,
        uint256[] _tokensPerTierDiscountPoly
    ) external onlyOwner {
        /*solium-disable-next-line security/no-block-members*/
        require(now < startTime, "STO already started");
        _modifyTiers(_ratePerTier, _ratePerTierDiscountPoly, _tokensPerTierTotal, _tokensPerTierDiscountPoly);
    }

    /**
     * @dev Modifies STO start and end times
     * @param _startTime start time of sto
     * @param _endTime end time of sto
     */
    function modifyTimes(
        uint256 _startTime,
        uint256 _endTime
    ) external onlyOwner {
        /*solium-disable-next-line security/no-block-members*/
        require(now < startTime, "STO already started");
        _modifyTimes(_startTime, _endTime);
    }

    /**
     * @dev Modifies addresses used as wallet, reserve wallet and usd token
     * @param _wallet Address of wallet where funds are sent
     * @param _reserveWallet Address of wallet where unsold tokens are sent
     * @param _usdTokens Address of usd tokens
     */
    function modifyAddresses(
        address _wallet,
        address _reserveWallet,
        address[] _usdTokens
    ) external onlyOwner {
        _modifyAddresses(_wallet, _reserveWallet, _usdTokens);
    }

    function _modifyLimits(
        uint256 _nonAccreditedLimitUSD,
        uint256 _minimumInvestmentUSD
    ) internal {
        minimumInvestmentUSD = _minimumInvestmentUSD;
        nonAccreditedLimitUSD = _nonAccreditedLimitUSD;
        emit SetLimits(minimumInvestmentUSD, nonAccreditedLimitUSD);
    }

    function _modifyTiers(
        uint256[] _ratePerTier,
        uint256[] _ratePerTierDiscountPoly,
        uint256[] _tokensPerTierTotal,
        uint256[] _tokensPerTierDiscountPoly
    ) internal {
        require(_tokensPerTierTotal.length > 0, "No tiers provided");
        require(_ratePerTier.length == _tokensPerTierTotal.length &&
            _ratePerTierDiscountPoly.length == _tokensPerTierTotal.length &&
            _tokensPerTierDiscountPoly.length == _tokensPerTierTotal.length,
            "Tier data length mismatch"
        );
        delete tiers;
        for (uint256 i = 0; i < _ratePerTier.length; i++) {
            require(_ratePerTier[i] > 0, "Invalid rate");
            require(_tokensPerTierTotal[i] > 0, "Invalid token amount");
            require(_tokensPerTierDiscountPoly[i] <= _tokensPerTierTotal[i], "Too many discounted tokens");
            require(_ratePerTierDiscountPoly[i] <= _ratePerTier[i], "Invalid discount");
            tiers.push(Tier(_ratePerTier[i], _ratePerTierDiscountPoly[i], _tokensPerTierTotal[i], _tokensPerTierDiscountPoly[i], 0, 0));
        }
        emit SetTiers(_ratePerTier, _ratePerTierDiscountPoly, _tokensPerTierTotal, _tokensPerTierDiscountPoly);
    }

    function _modifyTimes(
        uint256 _startTime,
        uint256 _endTime
    ) internal {
        /*solium-disable-next-line security/no-block-members*/
        require((_endTime > _startTime) && (_startTime > now), "Invalid times");
        startTime = _startTime;
        endTime = _endTime;
        emit SetTimes(_startTime, _endTime);
    }

    function _modifyAddresses(
        address _wallet,
        address _reserveWallet,
        address[] _usdTokens
    ) internal {
        require(_wallet != address(0) && _reserveWallet != address(0), "Invalid wallet");
        wallet = _wallet;
        reserveWallet = _reserveWallet;
        _modifyUSDTokens(_usdTokens);
    }

    function _modifyUSDTokens(address[] _usdTokens) internal {
        for(uint256 i = 0; i < usdTokens.length; i++) {
            usdTokenEnabled[usdTokens[i]] = false;
        }
        usdTokens = _usdTokens;
        for(i = 0; i < _usdTokens.length; i++) {
            require(_usdTokens[i] != address(0) && _usdTokens[i] != address(polyToken), "Invalid USD token");
            usdTokenEnabled[_usdTokens[i]] = true;
        }
        emit SetAddresses(wallet, reserveWallet, _usdTokens);
    }

    ////////////////////
    // STO Management //
    ////////////////////

    /**
     * @notice Finalizes the STO and mint remaining tokens to reserve address
     * @notice Reserve address must be whitelisted to successfully finalize
     */
    function finalize() external onlyOwner {
        require(!isFinalized, "STO is finalized");
        isFinalized = true;
        uint256 tempReturned;
        uint256 tempSold;
        uint256 remainingTokens;
        for (uint256 i = 0; i < tiers.length; i++) {
            remainingTokens = tiers[i].tokenTotal.sub(tiers[i].mintedTotal);
            tempReturned = tempReturned.add(remainingTokens);
            tempSold = tempSold.add(tiers[i].mintedTotal);
            if (remainingTokens > 0) {
                tiers[i].mintedTotal = tiers[i].tokenTotal;
            }
        }
        uint256 granularity = ISecurityToken(securityToken).granularity();
        tempReturned = tempReturned.div(granularity);
        tempReturned = tempReturned.mul(granularity);
        require(ISecurityToken(securityToken).mint(reserveWallet, tempReturned), "Error in minting");
        emit ReserveTokenMint(msg.sender, reserveWallet, tempReturned, currentTier);
        finalAmountReturned = tempReturned;
        totalTokensSold = tempSold;
    }

    /**
     * @notice Modifies the list of accredited addresses
     * @param _investors Array of investor addresses to modify
     * @param _accredited Array of bools specifying accreditation status
     */
    function changeAccredited(address[] _investors, bool[] _accredited) external onlyOwner {
        require(_investors.length == _accredited.length, "Array mismatch");
        for (uint256 i = 0; i < _investors.length; i++) {
            if (_accredited[i]) {
                investors[_investors[i]].accredited = uint8(1);
            } else {
                investors[_investors[i]].accredited = uint8(0);
            }
            _addToInvestorsList(_investors[i]);
            emit SetAccredited(_investors[i], _accredited[i]);
        }
    }

    /**
     * @notice Modifies the list of overrides for non-accredited limits in USD
     * @param _investors Array of investor addresses to modify
     * @param _nonAccreditedLimit Array of uints specifying non-accredited limits
     */
    function changeNonAccreditedLimit(address[] _investors, uint256[] _nonAccreditedLimit) external onlyOwner {
        //nonAccreditedLimitUSDOverride
        require(_investors.length == _nonAccreditedLimit.length, "Array mismatch");
        for (uint256 i = 0; i < _investors.length; i++) {
            investors[_investors[i]].nonAccreditedLimitUSDOverride = _nonAccreditedLimit[i];
            _addToInvestorsList(_investors[i]);
            emit SetNonAccreditedLimit(_investors[i], _nonAccreditedLimit[i]);
        }
    }

    function _addToInvestorsList(address _investor) internal {
        if (investors[_investor].seen == uint8(0)) {
            investors[_investor].seen = uint8(1);
            investorsList.push(_investor);
        }
    }

    /**
     * @notice Returns investor accredited & non-accredited override informatiomn
     * @return address[] list of all configured investors
     * @return bool[] whether investor is accredited
     * @return uint256[] any USD overrides for non-accredited limits for the investor
     */
    function getAccreditedData() external view returns (address[], bool[], uint256[]) {
        bool[] memory accrediteds = new bool[](investorsList.length);
        uint256[] memory nonAccreditedLimitUSDOverrides = new uint256[](investorsList.length);
        uint256 i;
        for (i = 0; i < investorsList.length; i++) {
            accrediteds[i] = (investors[investorsList[i]].accredited == uint8(0)? false: true);
            nonAccreditedLimitUSDOverrides[i] = investors[investorsList[i]].nonAccreditedLimitUSDOverride;
        }
        return (investorsList, accrediteds, nonAccreditedLimitUSDOverrides);
    }

    /**
     * @notice Function to set allowBeneficialInvestments (allow beneficiary to be different to funder)
     * @param _allowBeneficialInvestments Boolean to allow or disallow beneficial investments
     */
    function changeAllowBeneficialInvestments(bool _allowBeneficialInvestments) external onlyOwner {
        require(_allowBeneficialInvestments != allowBeneficialInvestments);
        allowBeneficialInvestments = _allowBeneficialInvestments;
        emit SetAllowBeneficialInvestments(allowBeneficialInvestments);
    }

    //////////////////////////
    // Investment Functions //
    //////////////////////////

    /**
    * @notice fallback function - assumes ETH being invested
    */
    function () external payable {
        buyWithETHRateLimited(msg.sender, 0);
    }

    // Buy functions without rate restriction
    function buyWithETH(address _beneficiary) external payable {
        buyWithETHRateLimited(_beneficiary, 0);
    }

    function buyWithPOLY(address _beneficiary, uint256 _investedPOLY) external {
        buyWithPOLYRateLimited(_beneficiary, _investedPOLY, 0);
    }

    function buyWithUSD(address _beneficiary, uint256 _investedSC, IERC20 _usdToken) external {
        buyWithUSDRateLimited(_beneficiary, _investedSC, 0, _usdToken);
    }

    /**
      * @notice Purchase tokens using ETH
      * @param _beneficiary Address where security tokens will be sent
      * @param _minTokens Minumum number of tokens to buy or else revert
      */
    function buyWithETHRateLimited(address _beneficiary, uint256 _minTokens) public payable validETH {
        uint256 rate = getRate(FundRaiseType.ETH);
        uint256 initialMinted = getTokensMinted();
        (uint256 spentUSD, uint256 spentValue) = _buyTokens(_beneficiary, msg.value, rate, FundRaiseType.ETH);
        require(getTokensMinted().sub(initialMinted) >= _minTokens, "Insufficient minted");
        // Modify storage
        investorInvested[_beneficiary][uint8(FundRaiseType.ETH)] = investorInvested[_beneficiary][uint8(FundRaiseType.ETH)].add(spentValue);
        fundsRaised[uint8(FundRaiseType.ETH)] = fundsRaised[uint8(FundRaiseType.ETH)].add(spentValue);
        // Forward ETH to issuer wallet
        wallet.transfer(spentValue);
        // Refund excess ETH to investor wallet
        msg.sender.transfer(msg.value.sub(spentValue));
        emit FundsReceived(msg.sender, _beneficiary, spentUSD, FundRaiseType.ETH, msg.value, spentValue, rate);
    }

    /**
      * @notice Purchase tokens using POLY
      * @param _beneficiary Address where security tokens will be sent
      * @param _investedPOLY Amount of POLY invested
      * @param _minTokens Minumum number of tokens to buy or else revert
      */
    function buyWithPOLYRateLimited(address _beneficiary, uint256 _investedPOLY, uint256 _minTokens) public validPOLY {
        _buyWithTokens(_beneficiary, _investedPOLY, FundRaiseType.POLY, _minTokens, polyToken);
    }

    /**
      * @notice Purchase tokens using Stable coins
      * @param _beneficiary Address where security tokens will be sent
      * @param _investedSC Amount of Stable coins invested
      * @param _minTokens Minumum number of tokens to buy or else revert
      * @param _usdToken Address of USD stable coin to buy tokens with
      */
    function buyWithUSDRateLimited(address _beneficiary, uint256 _investedSC, uint256 _minTokens, IERC20 _usdToken)
        public validSC(_usdToken)
    {
        _buyWithTokens(_beneficiary, _investedSC, FundRaiseType.SC, _minTokens, _usdToken);
    }

    function _buyWithTokens(address _beneficiary, uint256 _tokenAmount, FundRaiseType _fundRaiseType, uint256 _minTokens, IERC20 _token) internal {
        require(_fundRaiseType == FundRaiseType.POLY || _fundRaiseType == FundRaiseType.SC, "Invalid raise");
        uint256 initialMinted = getTokensMinted();
        uint256 rate = getRate(_fundRaiseType);
        (uint256 spentUSD, uint256 spentValue) = _buyTokens(_beneficiary, _tokenAmount, rate, _fundRaiseType);
        require(getTokensMinted().sub(initialMinted) >= _minTokens, "Insufficient minted");
        // Modify storage
        investorInvested[_beneficiary][uint8(_fundRaiseType)] = investorInvested[_beneficiary][uint8(_fundRaiseType)].add(spentValue);
        fundsRaised[uint8(_fundRaiseType)] = fundsRaised[uint8(_fundRaiseType)].add(spentValue);
        if(address(_token) != address(polyToken))
            stableCoinsRaised[address(_token)] = stableCoinsRaised[address(_token)].add(spentValue);
        // Forward coins to issuer wallet
        require(_token.transferFrom(msg.sender, wallet, spentValue), "Transfer failed");
        emit FundsReceived(msg.sender, _beneficiary, spentUSD, _fundRaiseType, _tokenAmount, spentValue, rate);
    }

    /**
      * @notice Low level token purchase
      * @param _beneficiary Address where security tokens will be sent
      * @param _investmentValue Amount of POLY, ETH or Stable coins invested
      * @param _fundRaiseType Fund raise type (POLY, ETH, SC)
      */
    function _buyTokens(
        address _beneficiary,
        uint256 _investmentValue,
        uint256 _rate,
        FundRaiseType _fundRaiseType
    )
        internal
        nonReentrant
        whenNotPaused
        returns(uint256 spentUSD, uint256 spentValue)
    {
        if (!allowBeneficialInvestments) {
            require(_beneficiary == msg.sender, "Beneficiary != funder");
        }

        uint256 originalUSD = DecimalMath.mul(_rate, _investmentValue);
        uint256 allowedUSD = _buyTokensChecks(_beneficiary, _investmentValue, originalUSD);

        for (uint256 i = currentTier; i < tiers.length; i++) {
            bool gotoNextTier;
            uint256 tempSpentUSD;
            // Update current tier if needed
            if (currentTier != i)
                currentTier = i;
            // If there are tokens remaining, process investment
            if (tiers[i].mintedTotal < tiers[i].tokenTotal) {
                (tempSpentUSD, gotoNextTier) = _calculateTier(_beneficiary, i, allowedUSD.sub(spentUSD), _fundRaiseType);
                spentUSD = spentUSD.add(tempSpentUSD);
                // If all funds have been spent, exit the loop
                if (!gotoNextTier)
                    break;
            }
        }

        // Modify storage
        if (spentUSD > 0) {
            if (investorInvestedUSD[_beneficiary] == 0)
                investorCount = investorCount + 1;
            investorInvestedUSD[_beneficiary] = investorInvestedUSD[_beneficiary].add(spentUSD);
            fundsRaisedUSD = fundsRaisedUSD.add(spentUSD);
        }

        spentValue = DecimalMath.div(spentUSD, _rate);
    }

    /**
      * @notice Getter function for buyer to calculate how many tokens will they get
      * @param _beneficiary Address where security tokens are to be sent
      * @param _investmentValue Amount of POLY, ETH or Stable coins invested
      * @param _fundRaiseType Fund raise type (POLY, ETH, SC)
      */
    function buyTokensView(
        address _beneficiary,
        uint256 _investmentValue,
        FundRaiseType _fundRaiseType
    )
        external
        view
        returns(uint256 spentUSD, uint256 spentValue, uint256 tokensMinted)
    {
        require(_fundRaiseType == FundRaiseType.POLY || _fundRaiseType == FundRaiseType.SC || _fundRaiseType == FundRaiseType.ETH, "Invalid raise type");
        uint256 rate = getRate(_fundRaiseType);
        uint256 originalUSD = DecimalMath.mul(rate, _investmentValue);
        uint256 allowedUSD = _buyTokensChecks(_beneficiary, _investmentValue, originalUSD);

        // Iterate over each tier and process payment
        for (uint256 i = currentTier; i < tiers.length; i++) {
            bool gotoNextTier;
            uint256 tempSpentUSD;
            uint256 tempTokensMinted;
            // If there are tokens remaining, process investment
            if (tiers[i].mintedTotal < tiers[i].tokenTotal) {
                (tempSpentUSD, gotoNextTier, tempTokensMinted) = _calculateTierView(i, allowedUSD.sub(spentUSD), _fundRaiseType);
                spentUSD = spentUSD.add(tempSpentUSD);
                tokensMinted = tokensMinted.add(tempTokensMinted);
                // If all funds have been spent, exit the loop
                if (!gotoNextTier)
                    break;
            }
        }

        spentValue = DecimalMath.div(spentUSD, rate);
    }

    function _buyTokensChecks(
        address _beneficiary,
        uint256 _investmentValue,
        uint256 investedUSD
    )
        internal
        view
        returns(uint256 netInvestedUSD)
    {
        require(isOpen(), "STO not open");
        require(_investmentValue > 0, "No funds were sent");

        // Check for minimum investment
        require(investedUSD.add(investorInvestedUSD[_beneficiary]) >= minimumInvestmentUSD, "investment < minimumInvestmentUSD");
        netInvestedUSD = investedUSD;
        // Check for non-accredited cap
        if (investors[_beneficiary].accredited == uint8(0)) {
            uint256 investorLimitUSD = (investors[_beneficiary].nonAccreditedLimitUSDOverride == 0) ? nonAccreditedLimitUSD : investors[_beneficiary].nonAccreditedLimitUSDOverride;
            require(investorInvestedUSD[_beneficiary] < investorLimitUSD, "Over investor limit");
            if (investedUSD.add(investorInvestedUSD[_beneficiary]) > investorLimitUSD)
                netInvestedUSD = investorLimitUSD.sub(investorInvestedUSD[_beneficiary]);
        }
    }

    function _calculateTier(
        address _beneficiary,
        uint256 _tier,
        uint256 _investedUSD,
        FundRaiseType _fundRaiseType
    )
        internal
        returns(uint256 spentUSD, bool gotoNextTier)
     {
        // First purchase any discounted tokens if POLY investment
        uint256 tierSpentUSD;
        uint256 tierPurchasedTokens;
        uint256 investedUSD = _investedUSD;
        Tier storage tierData = tiers[_tier];
        // Check whether there are any remaining discounted tokens
        if ((_fundRaiseType == FundRaiseType.POLY) && (tierData.tokensDiscountPoly > tierData.mintedDiscountPoly)) {
            uint256 discountRemaining = tierData.tokensDiscountPoly.sub(tierData.mintedDiscountPoly);
            uint256 totalRemaining = tierData.tokenTotal.sub(tierData.mintedTotal);
            if (totalRemaining < discountRemaining)
                (spentUSD, tierPurchasedTokens, gotoNextTier) = _purchaseTier(_beneficiary, tierData.rateDiscountPoly, totalRemaining, investedUSD, _tier);
            else
                (spentUSD, tierPurchasedTokens, gotoNextTier) = _purchaseTier(_beneficiary, tierData.rateDiscountPoly, discountRemaining, investedUSD, _tier);
            investedUSD = investedUSD.sub(spentUSD);
            tierData.mintedDiscountPoly = tierData.mintedDiscountPoly.add(tierPurchasedTokens);
            tierData.minted[uint8(_fundRaiseType)] = tierData.minted[uint8(_fundRaiseType)].add(tierPurchasedTokens);
            tierData.mintedTotal = tierData.mintedTotal.add(tierPurchasedTokens);
        }
        // Now, if there is any remaining USD to be invested, purchase at non-discounted rate
        if (investedUSD > 0 &&
            tierData.tokenTotal.sub(tierData.mintedTotal) > 0 &&
            (_fundRaiseType != FundRaiseType.POLY || tierData.tokensDiscountPoly <= tierData.mintedDiscountPoly)
        ) {
            (tierSpentUSD, tierPurchasedTokens, gotoNextTier) = _purchaseTier(_beneficiary, tierData.rate, tierData.tokenTotal.sub(tierData.mintedTotal), investedUSD, _tier);
            spentUSD = spentUSD.add(tierSpentUSD);
            tierData.minted[uint8(_fundRaiseType)] = tierData.minted[uint8(_fundRaiseType)].add(tierPurchasedTokens);
            tierData.mintedTotal = tierData.mintedTotal.add(tierPurchasedTokens);
        }
    }

    function _calculateTierView(
        uint256 _tier,
        uint256 _investedUSD,
        FundRaiseType _fundRaiseType
    )
        internal
        view
        returns(uint256 spentUSD, bool gotoNextTier, uint256 tokensMinted)
    {
        // First purchase any discounted tokens if POLY investment
        uint256 tierSpentUSD;
        uint256 tierPurchasedTokens;
        Tier storage tierData = tiers[_tier];
        // Check whether there are any remaining discounted tokens
        if ((_fundRaiseType == FundRaiseType.POLY) && (tierData.tokensDiscountPoly > tierData.mintedDiscountPoly)) {
            uint256 discountRemaining = tierData.tokensDiscountPoly.sub(tierData.mintedDiscountPoly);
            uint256 totalRemaining = tierData.tokenTotal.sub(tierData.mintedTotal);
            if (totalRemaining < discountRemaining)
                (spentUSD, tokensMinted, gotoNextTier) = _purchaseTierAmount(tierData.rateDiscountPoly, totalRemaining, _investedUSD);
            else
                (spentUSD, tokensMinted, gotoNextTier) = _purchaseTierAmount(tierData.rateDiscountPoly, discountRemaining, _investedUSD);
            _investedUSD = _investedUSD.sub(spentUSD);
        }
        // Now, if there is any remaining USD to be invested, purchase at non-discounted rate
        if (_investedUSD > 0 &&
            tierData.tokenTotal.sub(tierData.mintedTotal.add(tokensMinted)) > 0 &&
            (_fundRaiseType != FundRaiseType.POLY || tierData.tokensDiscountPoly <= tierData.mintedDiscountPoly)
        ) {
            (tierSpentUSD, tierPurchasedTokens, gotoNextTier) = _purchaseTierAmount(tierData.rate, tierData.tokenTotal.sub(tierData.mintedTotal), _investedUSD);
            spentUSD = spentUSD.add(tierSpentUSD);
            tokensMinted = tokensMinted.add(tierPurchasedTokens);
        }
    }

    function _purchaseTier(
        address _beneficiary,
        uint256 _tierPrice,
        uint256 _tierRemaining,
        uint256 _investedUSD,
        uint256 _tier
    )
        internal
        returns(uint256 spentUSD, uint256 purchasedTokens, bool gotoNextTier)
    {
        (spentUSD, purchasedTokens, gotoNextTier) = _purchaseTierAmount(_tierPrice, _tierRemaining, _investedUSD);
        if (purchasedTokens > 0) {
            require(ISecurityToken(securityToken).mint(_beneficiary, purchasedTokens), "Error in minting");
            emit TokenPurchase(msg.sender, _beneficiary, purchasedTokens, spentUSD, _tierPrice, _tier);
        }
    }

    function _purchaseTierAmount(
        uint256 _tierPrice,
        uint256 _tierRemaining,
        uint256 _investedUSD
    )
        internal
        view
        returns(uint256 spentUSD, uint256 purchasedTokens, bool gotoNextTier)
    {
        purchasedTokens = DecimalMath.div(_investedUSD, _tierPrice);
        uint256 granularity = ISecurityToken(securityToken).granularity();

        if (purchasedTokens > _tierRemaining) {
            purchasedTokens = _tierRemaining.div(granularity);
            gotoNextTier = true;
        } else {
            purchasedTokens = purchasedTokens.div(granularity);
        }

        purchasedTokens = purchasedTokens.mul(granularity);
        spentUSD = DecimalMath.mul(purchasedTokens, _tierPrice);

        // In case of rounding issues, ensure that spentUSD is never more than investedUSD
        if (spentUSD > _investedUSD) {
            spentUSD = _investedUSD;
        }
    }

    /////////////
    // Getters //
    /////////////

    /**
     * @notice This function returns whether or not the STO is in fundraising mode (open)
     * @return bool Whether the STO is accepting investments
     */
    function isOpen() public view returns(bool) {
        if (isFinalized)
            return false;
        /*solium-disable-next-line security/no-block-members*/
        if (now < startTime)
            return false;
        /*solium-disable-next-line security/no-block-members*/
        if (now >= endTime)
            return false;
        if (capReached())
            return false;
        return true;
    }

    /**
     * @notice Checks whether the cap has been reached.
     * @return bool Whether the cap was reached
     */
    function capReached() public view returns (bool) {
        if (isFinalized) {
            return (finalAmountReturned == 0);
        }
        return (tiers[tiers.length - 1].mintedTotal == tiers[tiers.length - 1].tokenTotal);
    }

    /**
     * @dev returns current conversion rate of funds
     * @param _fundRaiseType Fund raise type to get rate of
     */
    function getRate(FundRaiseType _fundRaiseType) public view returns (uint256) {
        if (_fundRaiseType == FundRaiseType.ETH) {
            return IOracle(_getOracle(bytes32("ETH"), bytes32("USD"))).getPrice();
        } else if (_fundRaiseType == FundRaiseType.POLY) {
            return IOracle(_getOracle(bytes32("POLY"), bytes32("USD"))).getPrice();
        } else if (_fundRaiseType == FundRaiseType.SC) {
            return 1 * 10**18;
        } else {
            revert("Incorrect funding");
        }
    }

    /**
     * @notice This function converts from ETH or POLY to USD
     * @param _fundRaiseType Currency key
     * @param _amount Value to convert to USD
     * @return uint256 Value in USD
     */
    function convertToUSD(FundRaiseType _fundRaiseType, uint256 _amount) external view returns(uint256) {
        uint256 rate = getRate(_fundRaiseType);
        return DecimalMath.mul(_amount, rate);
    }

    /**
     * @notice This function converts from USD to ETH or POLY
     * @param _fundRaiseType Currency key
     * @param _amount Value to convert from USD
     * @return uint256 Value in ETH or POLY
     */
    function convertFromUSD(FundRaiseType _fundRaiseType, uint256 _amount) external view returns(uint256) {
        uint256 rate = getRate(_fundRaiseType);
        return DecimalMath.div(_amount, rate);
    }

    /**
     * @notice Return the total no. of tokens sold
     * @return uint256 Total number of tokens sold
     */
    function getTokensSold() public view returns (uint256) {
        if (isFinalized)
            return totalTokensSold;
        else
            return getTokensMinted();
    }

    /**
     * @notice Return the total no. of tokens minted
     * @return uint256 Total number of tokens minted
     */
    function getTokensMinted() public view returns (uint256) {
        uint256 tokensMinted;
        for (uint256 i = 0; i < tiers.length; i++) {
            tokensMinted = tokensMinted.add(tiers[i].mintedTotal);
        }
        return tokensMinted;
    }

    /**
     * @notice Return the total no. of tokens sold for the given fund raise type
     * param _fundRaiseType The fund raising currency (e.g. ETH, POLY, SC) to calculate sold tokens for
     * @return uint256 Total number of tokens sold for ETH
     */
    function getTokensSoldFor(FundRaiseType _fundRaiseType) external view returns (uint256) {
        uint256 tokensSold;
        for (uint256 i = 0; i < tiers.length; i++) {
            tokensSold = tokensSold.add(tiers[i].minted[uint8(_fundRaiseType)]);
        }
        return tokensSold;
    }

    /**
     * @notice Return array of minted tokens in each fund raise type for given tier
     * param _tier The tier to return minted tokens for
     * @return uint256[] array of minted tokens in each fund raise type
     */
    function getTokensMintedByTier(uint256 _tier) external view returns (uint256[]) {
        require(_tier < tiers.length, "Invalid tier");
        uint256[] memory tokensMinted = new uint256[](3);
        tokensMinted[0] = tiers[_tier].minted[uint8(FundRaiseType.ETH)];
        tokensMinted[1] = tiers[_tier].minted[uint8(FundRaiseType.POLY)];
        tokensMinted[2] = tiers[_tier].minted[uint8(FundRaiseType.SC)];
        return tokensMinted;
    }

    /**
     * @notice Return the total no. of tokens sold in a given tier
     * param _tier The tier to calculate sold tokens for
     * @return uint256 Total number of tokens sold in the tier
     */
    function getTokensSoldByTier(uint256 _tier) external view returns (uint256) {
        require(_tier < tiers.length, "Incorrect tier");
        uint256 tokensSold;
        tokensSold = tokensSold.add(tiers[_tier].minted[uint8(FundRaiseType.ETH)]);
        tokensSold = tokensSold.add(tiers[_tier].minted[uint8(FundRaiseType.POLY)]);
        tokensSold = tokensSold.add(tiers[_tier].minted[uint8(FundRaiseType.SC)]);
        return tokensSold;
    }

    /**
     * @notice Return the total no. of tiers
     * @return uint256 Total number of tiers
     */
    function getNumberOfTiers() external view returns (uint256) {
        return tiers.length;
    }

    /**
     * @notice Return the usd tokens accepted by the STO
     * @return address[] usd tokens
     */
    function getUsdTokens() external view returns (address[]) {
        return usdTokens;
    }

    /**
     * @notice Return the permissions flag that are associated with STO
     */
    function getPermissions() public view returns(bytes32[]) {
        bytes32[] memory allPermissions = new bytes32[](0);
        return allPermissions;
    }

    /**
     * @notice Return the STO details
     * @return Unixtimestamp at which offering gets start.
     * @return Unixtimestamp at which offering ends.
     * @return Currently active tier
     * @return Array of Number of tokens this STO will be allowed to sell at different tiers.
     * @return Array Rate at which tokens are sold at different tiers
     * @return Amount of funds raised
     * @return Number of individual investors this STO have.
     * @return Amount of tokens sold.
     * @return Array of bools to show if funding is allowed in ETH, POLY, SC respectively
     */
    function getSTODetails() external view returns(uint256, uint256, uint256, uint256[], uint256[], uint256, uint256, uint256, bool[]) {
        uint256[] memory cap = new uint256[](tiers.length);
        uint256[] memory rate = new uint256[](tiers.length);
        for(uint256 i = 0; i < tiers.length; i++) {
            cap[i] = tiers[i].tokenTotal;
            rate[i] = tiers[i].rate;
        }
        bool[] memory _fundRaiseTypes = new bool[](3);
        _fundRaiseTypes[0] = fundRaiseTypes[uint8(FundRaiseType.ETH)];
        _fundRaiseTypes[1] = fundRaiseTypes[uint8(FundRaiseType.POLY)];
        _fundRaiseTypes[2] = fundRaiseTypes[uint8(FundRaiseType.SC)];
        return (
            startTime,
            endTime,
            currentTier,
            cap,
            rate,
            fundsRaisedUSD,
            investorCount,
            getTokensSold(),
            _fundRaiseTypes
        );
    }

    /**
     * @notice This function returns the signature of configure function
     * @return bytes4 Configure function signature
     */
    function getInitFunction() public pure returns (bytes4) {
        return 0xeac2f9e4;
    }

    function _getOracle(bytes32 _currency, bytes32 _denominatedCurrency) internal view returns (address) {
        return PolymathRegistry(RegistryUpdater(securityToken).polymathRegistry()).getAddress(oracleKeys[_currency][_denominatedCurrency]);
    }

}