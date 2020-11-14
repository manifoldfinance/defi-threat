/**
 * Source Code first verified at https://etherscan.io on Friday, April 26, 2019
 (UTC) */

pragma solidity 0.5.0;

contract OwnedI {
    function getOwner() public view returns(address owner);
    function changeOwner(address newOwner) public returns (bool success);
}

contract Owned is OwnedI {

    address private contractOwner;

    event LogOwnerChanged(
        address oldOwner,
        address newOwner);

    modifier onlyOwner {
        require(msg.sender == contractOwner, "Owned:sender should be owner");
        _;
    }

    constructor() public {
        contractOwner = msg.sender;
    }

    function getOwner() public view returns(address owner) {
        return contractOwner;
    }

    function changeOwner(address newOwner)
        public
        onlyOwner
        returns(bool success)
    {
        require(newOwner != address(0), "Owned:invalid address");
        emit LogOwnerChanged(contractOwner, newOwner);
        contractOwner = newOwner;
        return true;
    }

}


contract SolidifiedDepositableFactoryI {
  function deployDepositableContract(address _userAddress, address _mainHub)
   public
   returns(address depositable);
}







/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal view returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal view returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal view returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal view returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


contract DeployerI {

    mapping(address => uint) public deployedContractPointers;
    address[] public deployedContracts;

    function getDeployedContractsCount() public view returns(uint count);
    function isDeployedContract(address deployed) public view returns(bool isIndeed);

}

contract Deployer is DeployerI {

    using SafeMath for uint;

    mapping(address => uint) public deployedContractPointers;
    address[] public deployedContracts;

    event LogDeployedContract(address sender, address deployed);

    modifier onlyDeployed {
        require(isDeployedContract(msg.sender), "Deployer:sender should be deployed contract");
        _;
    }

    function getDeployedContractsCount() public view returns(uint count) {
        return deployedContracts.length;
    }

    function insertDeployedContract(address deployed) internal returns(bool success) {
        require(!isDeployedContract(deployed), "Deployer:deployed is already inserted");
        deployedContractPointers[deployed] = deployedContracts.push(deployed).sub(uint(1));
        emit LogDeployedContract(msg.sender, deployed);
        return true;
    }

    function isDeployedContract(address deployed) public view returns(bool isIndeed) {
        if(deployedContracts.length == 0) return false;
        return deployedContracts[deployedContractPointers[deployed]] == deployed;
    }

}





/*
Manage a privileged user "controllerAddress" which is expected to be a centralized server.
*/

contract ControlledI is OwnedI {

    function getController() public view returns(address controller);
    function changeController(address newController) public returns(bool success);
}

contract Controlled is ControlledI, Owned {

    address private controllerAddress;

    event LogControllerChanged(
        address sender,
        address oldController,
        address newController);

    modifier onlyController {
        require(msg.sender == controllerAddress, "Controlled:Sender is not controller");
        _;
    }

    constructor(address controller) public {
        controllerAddress = controller;
        if(controllerAddress == address(0)) controllerAddress = msg.sender;
    }

    function getController() public view returns(address controller) {
        return controllerAddress;
    }

    function changeController(address newController)
        public
        onlyOwner
        returns(bool success)
    {
        require(newController != address(0), "Controlled:Invalid address");
        require(newController != controllerAddress, "Controlled:New controller should be different than controller");
        emit LogControllerChanged(msg.sender, controllerAddress, newController);
        controllerAddress = newController;
        return true;
    }

}





contract StoppableI is OwnedI {
    function isRunning() public view returns(bool contractRunning);
    function setRunSwitch(bool onOff) public returns(bool success);
}

contract Stoppable is StoppableI, Owned {
    bool private running;

    modifier onlyIfRunning
    {
        require(running);
        _;
    }

    event LogSetRunSwitch(address sender, bool isRunning);

    constructor() public {
        running = true;
    }

    function isRunning()
        public
        view
        returns(bool contractRunning)
    {
        return running;
    }

    function setRunSwitch(bool onOff)
        public
        onlyOwner
        returns(bool success)
    {
        emit LogSetRunSwitch(msg.sender, onOff);
        running = onOff;
        return true;
    }

}





/** @title Solidified Vault
    @author JG Carvalho
 **/
contract SolidifiedVault {

    /*
     *  Events
     */
    event Confirmation(address indexed sender, uint indexed transactionId);
    event Revocation(address indexed sender, uint indexed transactionId);
    event Submission(uint indexed transactionId);
    event Execution(uint indexed transactionId);
    event ExecutionFailure(uint indexed transactionId);
    event Deposit(address indexed sender, uint value);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event RequirementChange(uint required);

    /*
     *  views
     */
    uint constant public MAX_OWNER_COUNT = 3;

    /*
     *  Storage
     */
    mapping (uint => Transaction) public transactions;
    mapping (uint => mapping (address => bool)) public confirmations;
    mapping (address => bool) public isOwner;
    address[] public owners;
    uint public required;
    uint public transactionCount;

    struct Transaction {
        address destination;
        uint value;
        bool executed;
    }

    /*
     *  Modifiers
     */
    modifier onlyWallet() {
        require(msg.sender == address(this), "Vault: sender should be wallet");
        _;
    }

    modifier ownerDoesNotExist(address owner) {
        require(!isOwner[owner], "Vault:sender shouldn't be owner");
        _;
    }

    modifier ownerExists(address owner) {
        require(isOwner[owner], "Vault:sender should be owner");
        _;
    }

    modifier transactionExists(uint transactionId) {
        require(transactions[transactionId].destination != address(0),"Vault:transaction should exist");
        _;
    }

    modifier confirmed(uint transactionId, address owner) {
        require(confirmations[transactionId][owner], "Vault:transaction should be confirmed");
        _;
    }

    modifier notConfirmed(uint transactionId, address owner) {
        require(!confirmations[transactionId][owner], "Vault:transaction is already confirmed");
        _;
    }

    modifier notExecuted(uint transactionId) {
        require(!transactions[transactionId].executed, "Vault:transaction has already executed");
        _;
    }

    modifier notNull(address _address) {
        require(_address != address(0), "Vault:address shouldn't be null");
        _;
    }

    modifier validRequirement(uint ownerCount, uint _required) {
        require(ownerCount <= MAX_OWNER_COUNT
            && _required <= ownerCount
            && _required != 0
            && ownerCount != 0, "Vault:invalid requirement");
        _;
    }

    /**
      @dev Fallback function allows to deposit ether.
    **/
    function()
        external
        payable
    {
        if (msg.value > 0)
            emit Deposit(msg.sender, msg.value);
    }

    /*
     * Public functions
     */
     /**
     @dev Contract constructor sets initial owners and required number of confirmations.
     @param _owners List of initial owners.
     @param _required Number of required confirmations.
     **/
    constructor(address[] memory _owners, uint _required)
        public
        validRequirement(_owners.length, _required)
    {
        for (uint i=0; i<_owners.length; i++) {
            require(!isOwner[_owners[i]] && _owners[i] != address(0), "Vault:Invalid owner");
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        required = _required;
    }


    /// @dev Allows an owner to submit and confirm a transaction.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @return Returns transaction ID.
    function submitTransaction(address destination, uint value)
        public
        returns (uint transactionId)
    {
        transactionId = addTransaction(destination, value);
        confirmTransaction(transactionId);
    }

    /// @dev Allows an owner to confirm a transaction.
    /// @param transactionId Transaction ID.
    function confirmTransaction(uint transactionId)
        public
        ownerExists(msg.sender)
        transactionExists(transactionId)
        notConfirmed(transactionId, msg.sender)
    {
        confirmations[transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }

    /// @dev Allows an owner to revoke a confirmation for a transaction.
    /// @param transactionId Transaction ID.
    function revokeConfirmation(uint transactionId)
        public
        ownerExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {
        confirmations[transactionId][msg.sender] = false;
        emit Revocation(msg.sender, transactionId);
    }

    /// @dev Allows anyone to execute a confirmed transaction.
    /// @param transactionId Transaction ID.
    function executeTransaction(uint transactionId)
        public
        ownerExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {
        if (isConfirmed(transactionId)) {
            Transaction storage txn = transactions[transactionId];
            txn.executed = true;
            (bool exec, bytes memory _) = txn.destination.call.value(txn.value)("");
            if (exec)
                emit Execution(transactionId);
            else {
                emit ExecutionFailure(transactionId);
                txn.executed = false;
            }
        }
    }

    /// @dev Returns the confirmation status of a transaction.
    /// @param transactionId Transaction ID.
    /// @return Confirmation status.
    function isConfirmed(uint transactionId)
        public
        view
        returns (bool)
    {
        uint count = 0;
        for (uint i=0; i<owners.length; i++) {
            if (confirmations[transactionId][owners[i]])
                count += 1;
            if (count == required)
                return true;
        }
    }

    /*
     * Internal functions
     */
    /// @dev Adds a new transaction to the transaction mapping, if transaction does not exist yet.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @return Returns transaction ID.
    function addTransaction(address destination, uint value)
        internal
        notNull(destination)
        returns (uint transactionId)
    {
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            executed: false
        });
        transactionCount += 1;
        emit Submission(transactionId);
    }

    /*
     * Web3 call functions
     */
    /// @dev Returns number of confirmations of a transaction.
    /// @param transactionId Transaction ID.
    /// @return Number of confirmations.
    function getConfirmationCount(uint transactionId)
        public
        view
        returns (uint count)
    {
        for (uint i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]])
                count += 1;
    }

    /// @dev Returns total number of transactions after filers are applied.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return Total number of transactions after filters are applied.
    function getTransactionCount(bool pending, bool executed)
        public
        view
        returns (uint count)
    {
        for (uint i=0; i<transactionCount; i++)
            if (   pending && !transactions[i].executed
                || executed && transactions[i].executed)
                count += 1;
    }

    /// @dev Returns list of owners.
    /// @return List of owner addresses.
    function getOwners()
        public
        view
        returns (address[] memory)
    {
        return owners;
    }

    /// @dev Returns array with owner addresses, which confirmed transaction.
    /// @param transactionId Transaction ID.
    /// @return Returns array of owner addresses.
    function getConfirmations(uint transactionId)
        public
        view
        returns (address[] memory _confirmations)
    {
        address[] memory confirmationsTemp = new address[](owners.length);
        uint count = 0;
        uint i;
        for (i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i=0; i<count; i++)
            _confirmations[i] = confirmationsTemp[i];
    }

    /// @dev Returns list of transaction IDs in defined range.
    /// @param from Index start position of transaction array.
    /// @param to Index end position of transaction array.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return Returns array of transaction IDs.
    function getTransactionIds(uint from, uint to, bool pending, bool executed)
        public
        view
        returns (uint[] memory _transactionIds)
    {
        uint[] memory transactionIdsTemp = new uint[](transactionCount);
        uint count = 0;
        uint i;
        for (i=0; i<transactionCount; i++)
            if (   pending && !transactions[i].executed
                || executed && transactions[i].executed)
            {
                transactionIdsTemp[count] = i;
                count += 1;
            }
        _transactionIds = new uint[](to - from);
        for (i=from; i<to; i++)
            _transactionIds[i - from] = transactionIdsTemp[i];
    }
}


contract SolidifiedMain is Controlled, Deployer, Stoppable {

  using SafeMath for uint;

  // VARIABLES
  address public depositableFactoryAddress;
  address payable public vault;

  mapping(address => UserStruct) public userStructs;
  mapping(address => address) public depositAddresses; //maps user address to depositAddress

  struct UserStruct {
    uint balance;
    uint pointer;
  }
  address[] public userList;

  //EVENTS
  event LogUserDeposit(address user, address depositAddress, uint amount);
  event LogUserCreditCollected(address user, uint amount, bytes32 ref);
  event LogUserCreditDeposit(address user, uint amount, bytes32 ref);
  event LogDepositableDeployed(address user, address depositableAddress, uint id);
  event LogRequestWithdraw(address user, uint amount);
  event LogUserInserted(address user, uint userId);
  event LogVaultAddressChanged(address newAddress, address sender);
  event LogDepositableFactoryAddressChanged(address newAddress, address sender);

  // CONSTRUCTOR
  /**
  @dev Constructor function
  @param controller address Address of the controller
  @param _depositableFactoryAddress address Address of the depositable factoryAddress
  @param _vault address Address of the vault
  **/
  constructor(address controller,
      address _depositableFactoryAddress,
      address payable _vault)
      public
    Controlled(controller) {
      vault = _vault;
      depositableFactoryAddress = _depositableFactoryAddress;
    }

  //PUBLIC FUNCTIONS

  /**
  @dev Allows the contract to receive an deposit for specif user
  @param _userAddress address Address of the user to be deposited
  **/
  function receiveDeposit(address _userAddress)
    payable
    public
    onlyDeployed
    onlyIfRunning
  {
    require(msg.sender == depositAddresses[_userAddress], "Main:sender should be deposit address");
    userStructs[_userAddress].balance = userStructs[_userAddress].balance.add(msg.value);

    vault.transfer(msg.value);
    emit LogUserDeposit(_userAddress, msg.sender, msg.value);
  }

  /**
  @dev Allows the controller to collect/lock user funds
  @param _userAddress address Adress of the user to collect credit from
  @param amount uint256 Amount to be collected
  @param ref bytes32 Referece for the reason for collection
  **/
  function collectUserCredit(address _userAddress, uint256 amount, bytes32 ref)
    public
    onlyController
    onlyIfRunning
  {
      require(userStructs[_userAddress].balance >= amount, "Main:user does not have enough balance");
      userStructs[_userAddress].balance = userStructs[_userAddress].balance.sub(amount);
      emit LogUserCreditCollected(_userAddress, amount, ref);
  }

  /**
  @dev Allows controller to deposit funds for user
  @param _userAddress address Adress of the user to collect credit from
  @param amount uint256 Amount to be collected
  @param ref bytes32 Referece for the reason for collection
  **/
  function depositUserCredit(address _userAddress, uint256 amount, bytes32 ref)
    public
    onlyController
    onlyIfRunning
  {
      userStructs[_userAddress].balance = userStructs[_userAddress].balance.add(amount);
      emit LogUserCreditDeposit(_userAddress, amount, ref);
  }

  /**
  @dev Deploys a new depositable contract, which users can send ether to.
  @param _userAddress address Address of the user that will be credited the money
  @return An address of the new depositable address
  **/
  function deployDepositableContract(address _userAddress)
    public
    onlyController
    onlyIfRunning
    returns(address depositable)
  {
      if(!isUser(_userAddress)) require(insertNewUser(_userAddress), "Main:inserting user has failed");
      require(depositAddresses[_userAddress] == address(0), "Main:invalid address");
      SolidifiedDepositableFactoryI f = SolidifiedDepositableFactoryI(depositableFactoryAddress);
      address d = f.deployDepositableContract(_userAddress, address(this));

      require(insertDeployedContract(d), "Main:insert contract failed");
      require(registerDepositAddress(_userAddress, d), "Main:contract registration failed");

      emit LogDepositableDeployed(_userAddress, d,getDeployedContractsCount());

      return d;
  }

  /**
  @dev Request a eth withdraw in the vault for specif user
  @param _userAddress address Adress of the user to withdraw
  @param amount uint256 Amount to be withdrawn
  **/
  function requestWithdraw(address _userAddress, uint amount)
    public
    onlyController
    onlyIfRunning
  {
    require(userStructs[_userAddress].balance >= amount,"Main:user does not have enough balance");
    userStructs[_userAddress].balance = userStructs[_userAddress].balance.sub(amount);
    (bool success, bytes memory _) = vault.call(abi.encodeWithSignature("submitTransaction(address,uint256)",_userAddress,amount));
    require(success, "Main:low level call failed");

    emit LogRequestWithdraw(_userAddress, amount);
  }

  /**
  @dev Register a deposit address for a specif user, so all Eth deposited in that
  address will be credited only to the user.
  @param _userAddress address Address of the user
  @param _depositAddress address Address of the depositable contract
  **/
  function registerDepositAddress(address _userAddress, address _depositAddress)
    public
    onlyController
    onlyIfRunning
    returns(bool success)
  {
    depositAddresses[_userAddress] = _depositAddress;
    return true;
  }

  /**
  @dev Allows to disconnect an user address from a deposit address
  @param _userAddress address Address of the user
  **/
  function deregisterUserDepositAddress(address _userAddress)
    public
    onlyController
    onlyIfRunning
  {
    depositAddresses[_userAddress] = address(0);
  }

  /**
  @dev Allows to register a new user into the system
  @param user address Address of the user
  **/
  function insertNewUser(address user)
    public
    onlyController
    onlyIfRunning
    returns(bool success)
  {
    require(!isUser(user), "Main:address is already user");
    userStructs[user].pointer = userList.push(user).sub(uint(1));
    emit LogUserInserted(user, userStructs[user].pointer);
    return true;
  }

  /**
  @dev Change the vault address
  @param _newVault address Address of the new vault
  **/
  function changeVaultAddress(address payable _newVault)
    public
    onlyOwner
    onlyIfRunning
  {
    require(_newVault != address(0),"Main:invalid address");
    vault = _newVault;
    emit LogVaultAddressChanged(_newVault, msg.sender);
  }

  /**
  @dev Change depositable factory address
  @param _newAddress address Address of the new depositable factory
  **/
  function changeDespositableFactoryAddress(address _newAddress)
    public
    onlyController
    onlyIfRunning
  {
    require(_newAddress != address(0),"Main:invalid address");
    depositableFactoryAddress = _newAddress;

    emit LogDepositableFactoryAddressChanged(_newAddress, msg.sender);
  }

  /**
  @dev Check if an address is a registered user
  @param user address Address of the user
  @return true if address is user
  **/
  function isUser(address user) public view returns(bool isIndeed) {
      if(userList.length ==0) return false;
      return(userList[userStructs[user].pointer] == user);
  }

  /**
  @dev Checks the depositable Factory address of a specif user
  @return The depositable factory address
  **/
  function getDepositableFactoryAddress()
    public
    view
    returns(address factoryAddress)
  {
    return depositableFactoryAddress;
  }

  /**
  @dev Getter for the vault address
  @return The address of the vault
  **/
  function getVaultAddress()
    public
    view
    returns(address vaultAddress)
  {
    return vault;
  }

  /**
  @dev Checks the depositable Factory address of a specif user
  @param _userAddress address Address of the user
  @return The depositable address of the user.
  **/
  function getDepositAddressForUser(address _userAddress)
    public
    view
    returns(address depositAddress)
  {
    return depositAddresses[_userAddress];
  }

  /**
  @dev Checks the balance of specif user
  @param _userAddress address Address of the user
  @return uint representing the balance
  **/
  function getUserBalance(address _userAddress)
    public
    view
    returns(uint256 balance)
  {
    return userStructs[_userAddress].balance;
  }

}