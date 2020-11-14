/**
 * Source Code first verified at https://etherscan.io on Wednesday, March 20, 2019
 (UTC) */

pragma solidity ^0.4.24;

/**
 * @title Interface to be implemented by all checkpoint modules
 */
/*solium-disable-next-line no-empty-blocks*/
interface ICheckpoint {

}

/**
 * @title Holds the storage variable for the DividendCheckpoint modules (i.e ERC20, Ether)
 * @dev abstract contract
 */
contract DividendCheckpointStorage {

    // Address to which reclaimed dividends and withholding tax is sent
    address public wallet;
    uint256 public EXCLUDED_ADDRESS_LIMIT = 150;
    bytes32 public constant DISTRIBUTE = "DISTRIBUTE";
    bytes32 public constant MANAGE = "MANAGE";
    bytes32 public constant CHECKPOINT = "CHECKPOINT";

    struct Dividend {
        uint256 checkpointId;
        uint256 created; // Time at which the dividend was created
        uint256 maturity; // Time after which dividend can be claimed - set to 0 to bypass
        uint256 expiry;  // Time until which dividend can be claimed - after this time any remaining amount can be withdrawn by issuer -
                         // set to very high value to bypass
        uint256 amount; // Dividend amount in WEI
        uint256 claimedAmount; // Amount of dividend claimed so far
        uint256 totalSupply; // Total supply at the associated checkpoint (avoids recalculating this)
        bool reclaimed;  // True if expiry has passed and issuer has reclaimed remaining dividend
        uint256 totalWithheld;
        uint256 totalWithheldWithdrawn;
        mapping (address => bool) claimed; // List of addresses which have claimed dividend
        mapping (address => bool) dividendExcluded; // List of addresses which cannot claim dividends
        mapping (address => uint256) withheld; // Amount of tax withheld from claim
        bytes32 name; // Name/title - used for identification
    }

    // List of all dividends
    Dividend[] public dividends;

    // List of addresses which cannot claim dividends
    address[] public excluded;

    // Mapping from address to withholding tax as a percentage * 10**16
    mapping (address => uint256) public withholdingTax;

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
 * @title Math
 * @dev Assorted math operations
 */
library Math {
  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}

/**
 * DISCLAIMER: Under certain conditions, the function pushDividendPayment
 * may fail due to block gas limits.
 * If the total number of investors that ever held tokens is greater than ~15,000 then
 * the function may fail. If this happens investors can pull their dividends, or the Issuer
 * can use pushDividendPaymentToAddresses to provide an explict address list in batches
 */










/**
 * @title Checkpoint module for issuing ether dividends
 * @dev abstract contract
 */
contract DividendCheckpoint is DividendCheckpointStorage, ICheckpoint, Module, Pausable {
    using SafeMath for uint256;

    event SetDefaultExcludedAddresses(address[] _excluded, uint256 _timestamp);
    event SetWithholding(address[] _investors, uint256[] _withholding, uint256 _timestamp);
    event SetWithholdingFixed(address[] _investors, uint256 _withholding, uint256 _timestamp);
    event SetWallet(address indexed _oldWallet, address indexed _newWallet, uint256 _timestamp);
    event UpdateDividendDates(uint256 indexed _dividendIndex, uint256 _maturity, uint256 _expiry);

    modifier validDividendIndex(uint256 _dividendIndex) {
        _validDividendIndex(_dividendIndex);
        _;
    }

    function _validDividendIndex(uint256 _dividendIndex) internal view {
        require(_dividendIndex < dividends.length, "Invalid dividend");
        require(!dividends[_dividendIndex].reclaimed, "Dividend reclaimed");
        /*solium-disable-next-line security/no-block-members*/
        require(now >= dividends[_dividendIndex].maturity, "Dividend maturity in future");
        /*solium-disable-next-line security/no-block-members*/
        require(now < dividends[_dividendIndex].expiry, "Dividend expiry in past");
    }

    /**
     * @notice Pause (overridden function)
     */
    function pause() public onlyOwner {
        super._pause();
    }

    /**
     * @notice Unpause (overridden function)
     */
    function unpause() public onlyOwner {
        super._unpause();
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

    /**
     * @notice Function used to intialize the contract variables
     * @param _wallet Ethereum account address to receive reclaimed dividends and tax
     */
    function configure(
        address _wallet
    ) public onlyFactory {
        _setWallet(_wallet);
    }

    /**
    * @notice Init function i.e generalise function to maintain the structure of the module contract
    * @return bytes4
    */
    function getInitFunction() public pure returns (bytes4) {
        return this.configure.selector;
    }

    /**
     * @notice Function used to change wallet address
     * @param _wallet Ethereum account address to receive reclaimed dividends and tax
     */
    function changeWallet(address _wallet) external onlyOwner {
        _setWallet(_wallet);
    }

    function _setWallet(address _wallet) internal {
        require(_wallet != address(0));
        emit SetWallet(wallet, _wallet, now);
        wallet = _wallet;
    }

    /**
     * @notice Return the default excluded addresses
     * @return List of excluded addresses
     */
    function getDefaultExcluded() external view returns (address[]) {
        return excluded;
    }

    /**
     * @notice Creates a checkpoint on the security token
     * @return Checkpoint ID
     */
    function createCheckpoint() public withPerm(CHECKPOINT) returns (uint256) {
        return ISecurityToken(securityToken).createCheckpoint();
    }

    /**
     * @notice Function to clear and set list of excluded addresses used for future dividends
     * @param _excluded Addresses of investors
     */
    function setDefaultExcluded(address[] _excluded) public withPerm(MANAGE) {
        require(_excluded.length <= EXCLUDED_ADDRESS_LIMIT, "Too many excluded addresses");
        for (uint256 j = 0; j < _excluded.length; j++) {
            require (_excluded[j] != address(0), "Invalid address");
            for (uint256 i = j + 1; i < _excluded.length; i++) {
                require (_excluded[j] != _excluded[i], "Duplicate exclude address");
            }
        }
        excluded = _excluded;
        /*solium-disable-next-line security/no-block-members*/
        emit SetDefaultExcludedAddresses(excluded, now);
    }

    /**
     * @notice Function to set withholding tax rates for investors
     * @param _investors Addresses of investors
     * @param _withholding Withholding tax for individual investors (multiplied by 10**16)
     */
    function setWithholding(address[] _investors, uint256[] _withholding) public withPerm(MANAGE) {
        require(_investors.length == _withholding.length, "Mismatched input lengths");
        /*solium-disable-next-line security/no-block-members*/
        emit SetWithholding(_investors, _withholding, now);
        for (uint256 i = 0; i < _investors.length; i++) {
            require(_withholding[i] <= 10**18, "Incorrect withholding tax");
            withholdingTax[_investors[i]] = _withholding[i];
        }
    }

    /**
     * @notice Function to set withholding tax rates for investors
     * @param _investors Addresses of investor
     * @param _withholding Withholding tax for all investors (multiplied by 10**16)
     */
    function setWithholdingFixed(address[] _investors, uint256 _withholding) public withPerm(MANAGE) {
        require(_withholding <= 10**18, "Incorrect withholding tax");
        /*solium-disable-next-line security/no-block-members*/
        emit SetWithholdingFixed(_investors, _withholding, now);
        for (uint256 i = 0; i < _investors.length; i++) {
            withholdingTax[_investors[i]] = _withholding;
        }
    }

    /**
     * @notice Issuer can push dividends to provided addresses
     * @param _dividendIndex Dividend to push
     * @param _payees Addresses to which to push the dividend
     */
    function pushDividendPaymentToAddresses(
        uint256 _dividendIndex,
        address[] _payees
    )
        public
        withPerm(DISTRIBUTE)
        validDividendIndex(_dividendIndex)
    {
        Dividend storage dividend = dividends[_dividendIndex];
        for (uint256 i = 0; i < _payees.length; i++) {
            if ((!dividend.claimed[_payees[i]]) && (!dividend.dividendExcluded[_payees[i]])) {
                _payDividend(_payees[i], dividend, _dividendIndex);
            }
        }
    }

    /**
     * @notice Issuer can push dividends using the investor list from the security token
     * @param _dividendIndex Dividend to push
     * @param _start Index in investor list at which to start pushing dividends
     * @param _iterations Number of addresses to push dividends for
     */
    function pushDividendPayment(
        uint256 _dividendIndex,
        uint256 _start,
        uint256 _iterations
    )
        public
        withPerm(DISTRIBUTE)
        validDividendIndex(_dividendIndex)
    {
        Dividend storage dividend = dividends[_dividendIndex];
        uint256 checkpointId = dividend.checkpointId;
        address[] memory investors = ISecurityToken(securityToken).getInvestorsAt(checkpointId);
        uint256 numberInvestors = Math.min256(investors.length, _start.add(_iterations));
        for (uint256 i = _start; i < numberInvestors; i++) {
            address payee = investors[i];
            if ((!dividend.claimed[payee]) && (!dividend.dividendExcluded[payee])) {
                _payDividend(payee, dividend, _dividendIndex);
            }
        }
    }

    /**
     * @notice Investors can pull their own dividends
     * @param _dividendIndex Dividend to pull
     */
    function pullDividendPayment(uint256 _dividendIndex) public validDividendIndex(_dividendIndex) whenNotPaused
    {
        Dividend storage dividend = dividends[_dividendIndex];
        require(!dividend.claimed[msg.sender], "Dividend already claimed");
        require(!dividend.dividendExcluded[msg.sender], "msg.sender excluded from Dividend");
        _payDividend(msg.sender, dividend, _dividendIndex);
    }

    /**
     * @notice Internal function for paying dividends
     * @param _payee Address of investor
     * @param _dividend Storage with previously issued dividends
     * @param _dividendIndex Dividend to pay
     */
    function _payDividend(address _payee, Dividend storage _dividend, uint256 _dividendIndex) internal;

    /**
     * @notice Issuer can reclaim remaining unclaimed dividend amounts, for expired dividends
     * @param _dividendIndex Dividend to reclaim
     */
    function reclaimDividend(uint256 _dividendIndex) external;

    /**
     * @notice Calculate amount of dividends claimable
     * @param _dividendIndex Dividend to calculate
     * @param _payee Affected investor address
     * @return claim, withheld amounts
     */
    function calculateDividend(uint256 _dividendIndex, address _payee) public view returns(uint256, uint256) {
        require(_dividendIndex < dividends.length, "Invalid dividend");
        Dividend storage dividend = dividends[_dividendIndex];
        if (dividend.claimed[_payee] || dividend.dividendExcluded[_payee]) {
            return (0, 0);
        }
        uint256 balance = ISecurityToken(securityToken).balanceOfAt(_payee, dividend.checkpointId);
        uint256 claim = balance.mul(dividend.amount).div(dividend.totalSupply);
        uint256 withheld = claim.mul(withholdingTax[_payee]).div(uint256(10**18));
        return (claim, withheld);
    }

    /**
     * @notice Get the index according to the checkpoint id
     * @param _checkpointId Checkpoint id to query
     * @return uint256[]
     */
    function getDividendIndex(uint256 _checkpointId) public view returns(uint256[]) {
        uint256 counter = 0;
        for(uint256 i = 0; i < dividends.length; i++) {
            if (dividends[i].checkpointId == _checkpointId) {
                counter++;
            }
        }

        uint256[] memory index = new uint256[](counter);
        counter = 0;
        for(uint256 j = 0; j < dividends.length; j++) {
            if (dividends[j].checkpointId == _checkpointId) {
                index[counter] = j;
                counter++;
            }
        }
        return index;
    }

    /**
     * @notice Allows issuer to withdraw withheld tax
     * @param _dividendIndex Dividend to withdraw from
     */
    function withdrawWithholding(uint256 _dividendIndex) external;

    /**
     * @notice Allows issuer to change maturity / expiry dates for dividends
     * @dev NB - setting the maturity of a currently matured dividend to a future date
     * @dev will effectively refreeze claims on that dividend until the new maturity date passes
     * @ dev NB - setting the expiry date to a past date will mean no more payments can be pulled
     * @dev or pushed out of a dividend
     * @param _dividendIndex Dividend to withdraw from
     * @param _maturity updated maturity date
     * @param _expiry updated expiry date
     */
    function updateDividendDates(uint256 _dividendIndex, uint256 _maturity, uint256 _expiry) external onlyOwner {
        require(_dividendIndex < dividends.length, "Invalid dividend");
        require(_expiry > _maturity, "Expiry before maturity");
        Dividend storage dividend = dividends[_dividendIndex];
        dividend.expiry = _expiry;
        dividend.maturity = _maturity;
        emit UpdateDividendDates(_dividendIndex, _maturity, _expiry);
    }

    /**
     * @notice Get static dividend data
     * @return uint256[] timestamp of dividends creation
     * @return uint256[] timestamp of dividends maturity
     * @return uint256[] timestamp of dividends expiry
     * @return uint256[] amount of dividends
     * @return uint256[] claimed amount of dividends
     * @return bytes32[] name of dividends
     */
    function getDividendsData() external view returns (
        uint256[] memory createds,
        uint256[] memory maturitys,
        uint256[] memory expirys,
        uint256[] memory amounts,
        uint256[] memory claimedAmounts,
        bytes32[] memory names)
    {
        createds = new uint256[](dividends.length);
        maturitys = new uint256[](dividends.length);
        expirys = new uint256[](dividends.length);
        amounts = new uint256[](dividends.length);
        claimedAmounts = new uint256[](dividends.length);
        names = new bytes32[](dividends.length);
        for (uint256 i = 0; i < dividends.length; i++) {
            (createds[i], maturitys[i], expirys[i], amounts[i], claimedAmounts[i], names[i]) = getDividendData(i);
        }
    }

    /**
     * @notice Get static dividend data
     * @return uint256 timestamp of dividend creation
     * @return uint256 timestamp of dividend maturity
     * @return uint256 timestamp of dividend expiry
     * @return uint256 amount of dividend
     * @return uint256 claimed amount of dividend
     * @return bytes32 name of dividend
     */
    function getDividendData(uint256 _dividendIndex) public view returns (
        uint256 created,
        uint256 maturity,
        uint256 expiry,
        uint256 amount,
        uint256 claimedAmount,
        bytes32 name)
    {
        created = dividends[_dividendIndex].created;
        maturity = dividends[_dividendIndex].maturity;
        expiry = dividends[_dividendIndex].expiry;
        amount = dividends[_dividendIndex].amount;
        claimedAmount = dividends[_dividendIndex].claimedAmount;
        name = dividends[_dividendIndex].name;
    }

    /**
     * @notice Retrieves list of investors, their claim status and whether they are excluded
     * @param _dividendIndex Dividend to withdraw from
     * @return address[] list of investors
     * @return bool[] whether investor has claimed
     * @return bool[] whether investor is excluded
     * @return uint256[] amount of withheld tax (estimate if not claimed)
     * @return uint256[] amount of claim (estimate if not claimeed)
     * @return uint256[] investor balance
     */
    function getDividendProgress(uint256 _dividendIndex) external view returns (
        address[] memory investors,
        bool[] memory resultClaimed,
        bool[] memory resultExcluded,
        uint256[] memory resultWithheld,
        uint256[] memory resultAmount,
        uint256[] memory resultBalance)
    {
        require(_dividendIndex < dividends.length, "Invalid dividend");
        //Get list of Investors
        Dividend storage dividend = dividends[_dividendIndex];
        uint256 checkpointId = dividend.checkpointId;
        investors = ISecurityToken(securityToken).getInvestorsAt(checkpointId);
        resultClaimed = new bool[](investors.length);
        resultExcluded = new bool[](investors.length);
        resultWithheld = new uint256[](investors.length);
        resultAmount = new uint256[](investors.length);
        resultBalance = new uint256[](investors.length);
        for (uint256 i; i < investors.length; i++) {
            resultClaimed[i] = dividend.claimed[investors[i]];
            resultExcluded[i] = dividend.dividendExcluded[investors[i]];
            resultBalance[i] = ISecurityToken(securityToken).balanceOfAt(investors[i], dividend.checkpointId);
            if (!resultExcluded[i]) {
                if (resultClaimed[i]) {
                    resultWithheld[i] = dividend.withheld[investors[i]];
                    resultAmount[i] = resultBalance[i].mul(dividend.amount).div(dividend.totalSupply).sub(resultWithheld[i]);
                } else {
                    (uint256 claim, uint256 withheld) = calculateDividend(_dividendIndex, investors[i]);
                    resultWithheld[i] = withheld;
                    resultAmount[i] = claim.sub(withheld);
                }
            }
        }
    }

    /**
     * @notice Retrieves list of investors, their balances, and their current withholding tax percentage
     * @param _checkpointId Checkpoint Id to query for
     * @return address[] list of investors
     * @return uint256[] investor balances
     * @return uint256[] investor withheld percentages
     */
    function getCheckpointData(uint256 _checkpointId) external view returns (address[] memory investors, uint256[] memory balances, uint256[] memory withholdings) {
        require(_checkpointId <= ISecurityToken(securityToken).currentCheckpointId(), "Invalid checkpoint");
        investors = ISecurityToken(securityToken).getInvestorsAt(_checkpointId);
        balances = new uint256[](investors.length);
        withholdings = new uint256[](investors.length);
        for (uint256 i; i < investors.length; i++) {
            balances[i] = ISecurityToken(securityToken).balanceOfAt(investors[i], _checkpointId);
            withholdings[i] = withholdingTax[investors[i]];
        }
    }

    /**
     * @notice Checks whether an address is excluded from claiming a dividend
     * @param _dividendIndex Dividend to withdraw from
     * @return bool whether the address is excluded
     */
    function isExcluded(address _investor, uint256 _dividendIndex) external view returns (bool) {
        require(_dividendIndex < dividends.length, "Invalid dividend");
        return dividends[_dividendIndex].dividendExcluded[_investor];
    }

    /**
     * @notice Checks whether an address has claimed a dividend
     * @param _dividendIndex Dividend to withdraw from
     * @return bool whether the address has claimed
     */
    function isClaimed(address _investor, uint256 _dividendIndex) external view returns (bool) {
        require(_dividendIndex < dividends.length, "Invalid dividend");
        return dividends[_dividendIndex].claimed[_investor];
    }

    /**
     * @notice Return the permissions flag that are associated with this module
     * @return bytes32 array
     */
    function getPermissions() public view returns(bytes32[]) {
        bytes32[] memory allPermissions = new bytes32[](2);
        allPermissions[0] = DISTRIBUTE;
        allPermissions[1] = MANAGE;
        return allPermissions;
    }

}

/**
 * @title It holds the storage variables related to ERC20DividendCheckpoint module
 */
contract ERC20DividendCheckpointStorage {

    // Mapping to token address for each dividend
    mapping (uint256 => address) public dividendTokens;

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
interface IOwnable {
    /**
    * @dev Returns owner
    */
    function owner() external view returns (address);

    /**
    * @dev Allows the current owner to relinquish control of the contract.
    */
    function renounceOwnership() external;

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function transferOwnership(address _newOwner) external;

}

/**
 * @title Checkpoint module for issuing ERC20 dividends
 */
contract ERC20DividendCheckpoint is ERC20DividendCheckpointStorage, DividendCheckpoint {
    using SafeMath for uint256;

    event ERC20DividendDeposited(
        address indexed _depositor,
        uint256 _checkpointId,
        uint256 _created,
        uint256 _maturity,
        uint256 _expiry,
        address indexed _token,
        uint256 _amount,
        uint256 _totalSupply,
        uint256 _dividendIndex,
        bytes32 indexed _name
    );
    event ERC20DividendClaimed(
        address indexed _payee,
        uint256 indexed _dividendIndex,
        address indexed _token,
        uint256 _amount,
        uint256 _withheld
    );
    event ERC20DividendReclaimed(
        address indexed _claimer,
        uint256 indexed _dividendIndex,
        address indexed _token,
        uint256 _claimedAmount
    );
    event ERC20DividendWithholdingWithdrawn(
        address indexed _claimer,
        uint256 indexed _dividendIndex,
        address indexed _token,
        uint256 _withheldAmount
    );

    /**
     * @notice Constructor
     * @param _securityToken Address of the security token
     * @param _polyAddress Address of the polytoken
     */
    constructor (address _securityToken, address _polyAddress) public
    Module(_securityToken, _polyAddress)
    {
    }

    /**
     * @notice Creates a dividend and checkpoint for the dividend
     * @param _maturity Time from which dividend can be paid
     * @param _expiry Time until dividend can no longer be paid, and can be reclaimed by issuer
     * @param _token Address of ERC20 token in which dividend is to be denominated
     * @param _amount Amount of specified token for dividend
     * @param _name Name/Title for identification
     */
    function createDividend(
        uint256 _maturity,
        uint256 _expiry,
        address _token,
        uint256 _amount,
        bytes32 _name
    )
        external
        withPerm(MANAGE)
    {
        createDividendWithExclusions(_maturity, _expiry, _token, _amount, excluded, _name);
    }

    /**
     * @notice Creates a dividend with a provided checkpoint
     * @param _maturity Time from which dividend can be paid
     * @param _expiry Time until dividend can no longer be paid, and can be reclaimed by issuer
     * @param _token Address of ERC20 token in which dividend is to be denominated
     * @param _amount Amount of specified token for dividend
     * @param _checkpointId Checkpoint id from which to create dividends
     * @param _name Name/Title for identification
     */
    function createDividendWithCheckpoint(
        uint256 _maturity,
        uint256 _expiry,
        address _token,
        uint256 _amount,
        uint256 _checkpointId,
        bytes32 _name
    )
        external
        withPerm(MANAGE)
    {
        _createDividendWithCheckpointAndExclusions(_maturity, _expiry, _token, _amount, _checkpointId, excluded, _name);
    }

    /**
     * @notice Creates a dividend and checkpoint for the dividend
     * @param _maturity Time from which dividend can be paid
     * @param _expiry Time until dividend can no longer be paid, and can be reclaimed by issuer
     * @param _token Address of ERC20 token in which dividend is to be denominated
     * @param _amount Amount of specified token for dividend
     * @param _excluded List of addresses to exclude
     * @param _name Name/Title for identification
     */
    function createDividendWithExclusions(
        uint256 _maturity,
        uint256 _expiry,
        address _token,
        uint256 _amount,
        address[] _excluded,
        bytes32 _name
    )
        public
        withPerm(MANAGE)
    {
        uint256 checkpointId = ISecurityToken(securityToken).createCheckpoint();
        _createDividendWithCheckpointAndExclusions(_maturity, _expiry, _token, _amount, checkpointId, _excluded, _name);
    }

    /**
     * @notice Creates a dividend with a provided checkpoint
     * @param _maturity Time from which dividend can be paid
     * @param _expiry Time until dividend can no longer be paid, and can be reclaimed by issuer
     * @param _token Address of ERC20 token in which dividend is to be denominated
     * @param _amount Amount of specified token for dividend
     * @param _checkpointId Checkpoint id from which to create dividends
     * @param _excluded List of addresses to exclude
     * @param _name Name/Title for identification
     */
    function createDividendWithCheckpointAndExclusions(
        uint256 _maturity,
        uint256 _expiry,
        address _token,
        uint256 _amount,
        uint256 _checkpointId,
        address[] _excluded,
        bytes32 _name
    )
        public
        withPerm(MANAGE)
    {
        _createDividendWithCheckpointAndExclusions(_maturity, _expiry, _token, _amount, _checkpointId, _excluded, _name);
    }

    /**
     * @notice Creates a dividend with a provided checkpoint
     * @param _maturity Time from which dividend can be paid
     * @param _expiry Time until dividend can no longer be paid, and can be reclaimed by issuer
     * @param _token Address of ERC20 token in which dividend is to be denominated
     * @param _amount Amount of specified token for dividend
     * @param _checkpointId Checkpoint id from which to create dividends
     * @param _excluded List of addresses to exclude
     * @param _name Name/Title for identification
     */
    function _createDividendWithCheckpointAndExclusions(
        uint256 _maturity,
        uint256 _expiry,
        address _token,
        uint256 _amount,
        uint256 _checkpointId,
        address[] _excluded,
        bytes32 _name
    )
        internal
    {
        ISecurityToken securityTokenInstance = ISecurityToken(securityToken);
        require(_excluded.length <= EXCLUDED_ADDRESS_LIMIT, "Too many addresses excluded");
        require(_expiry > _maturity, "Expiry before maturity");
        /*solium-disable-next-line security/no-block-members*/
        require(_expiry > now, "Expiry in past");
        require(_amount > 0, "No dividend sent");
        require(_token != address(0), "Invalid token");
        require(_checkpointId <= securityTokenInstance.currentCheckpointId(), "Invalid checkpoint");
        require(IERC20(_token).transferFrom(msg.sender, address(this), _amount), "insufficent allowance");
        require(_name[0] != 0);
        uint256 dividendIndex = dividends.length;
        uint256 currentSupply = securityTokenInstance.totalSupplyAt(_checkpointId);
        uint256 excludedSupply = 0;
        dividends.push(
          Dividend(
            _checkpointId,
            now, /*solium-disable-line security/no-block-members*/
            _maturity,
            _expiry,
            _amount,
            0,
            0,
            false,
            0,
            0,
            _name
          )
        );

        for (uint256 j = 0; j < _excluded.length; j++) {
            require (_excluded[j] != address(0), "Invalid address");
            require(!dividends[dividendIndex].dividendExcluded[_excluded[j]], "duped exclude address");
            excludedSupply = excludedSupply.add(securityTokenInstance.balanceOfAt(_excluded[j], _checkpointId));
            dividends[dividendIndex].dividendExcluded[_excluded[j]] = true;
        }

        dividends[dividendIndex].totalSupply = currentSupply.sub(excludedSupply);
        dividendTokens[dividendIndex] = _token;
        _emitERC20DividendDepositedEvent(_checkpointId, _maturity, _expiry, _token, _amount, currentSupply, dividendIndex, _name);
    }

    /**
     * @notice Emits the ERC20DividendDeposited event.
     * Seperated into a different function as a workaround for stack too deep error
     */
    function _emitERC20DividendDepositedEvent(
        uint256 _checkpointId,
        uint256 _maturity,
        uint256 _expiry,
        address _token,
        uint256 _amount,
        uint256 currentSupply,
        uint256 dividendIndex,
        bytes32 _name
    )
        internal
    {
        /*solium-disable-next-line security/no-block-members*/
        emit ERC20DividendDeposited(msg.sender, _checkpointId, now, _maturity, _expiry, _token, _amount, currentSupply, dividendIndex, _name);
    }

    /**
     * @notice Internal function for paying dividends
     * @param _payee Address of investor
     * @param _dividend Storage with previously issued dividends
     * @param _dividendIndex Dividend to pay
     */
    function _payDividend(address _payee, Dividend storage _dividend, uint256 _dividendIndex) internal {
        (uint256 claim, uint256 withheld) = calculateDividend(_dividendIndex, _payee);
        _dividend.claimed[_payee] = true;
        _dividend.claimedAmount = claim.add(_dividend.claimedAmount);
        uint256 claimAfterWithheld = claim.sub(withheld);
        if (claimAfterWithheld > 0) {
            require(IERC20(dividendTokens[_dividendIndex]).transfer(_payee, claimAfterWithheld), "transfer failed");
        }
        if (withheld > 0) {
            _dividend.totalWithheld = _dividend.totalWithheld.add(withheld);
            _dividend.withheld[_payee] = withheld;
        }
        emit ERC20DividendClaimed(_payee, _dividendIndex, dividendTokens[_dividendIndex], claim, withheld);
    }

    /**
     * @notice Issuer can reclaim remaining unclaimed dividend amounts, for expired dividends
     * @param _dividendIndex Dividend to reclaim
     */
    function reclaimDividend(uint256 _dividendIndex) external withPerm(MANAGE) {
        require(_dividendIndex < dividends.length, "Invalid dividend");
        /*solium-disable-next-line security/no-block-members*/
        require(now >= dividends[_dividendIndex].expiry, "Dividend expiry in future");
        require(!dividends[_dividendIndex].reclaimed, "already claimed");
        dividends[_dividendIndex].reclaimed = true;
        Dividend storage dividend = dividends[_dividendIndex];
        uint256 remainingAmount = dividend.amount.sub(dividend.claimedAmount);
        require(IERC20(dividendTokens[_dividendIndex]).transfer(wallet, remainingAmount), "transfer failed");
        emit ERC20DividendReclaimed(wallet, _dividendIndex, dividendTokens[_dividendIndex], remainingAmount);
    }

    /**
     * @notice Allows issuer to withdraw withheld tax
     * @param _dividendIndex Dividend to withdraw from
     */
    function withdrawWithholding(uint256 _dividendIndex) external withPerm(MANAGE) {
        require(_dividendIndex < dividends.length, "Invalid dividend");
        Dividend storage dividend = dividends[_dividendIndex];
        uint256 remainingWithheld = dividend.totalWithheld.sub(dividend.totalWithheldWithdrawn);
        dividend.totalWithheldWithdrawn = dividend.totalWithheld;
        require(IERC20(dividendTokens[_dividendIndex]).transfer(wallet, remainingWithheld), "transfer failed");
        emit ERC20DividendWithholdingWithdrawn(wallet, _dividendIndex, dividendTokens[_dividendIndex], remainingWithheld);
    }

}