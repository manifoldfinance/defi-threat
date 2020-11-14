/**
 * Source Code first verified at https://etherscan.io on Tuesday, May 7, 2019
 (UTC) */

pragma solidity 0.5.3;







/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


/**
 * @title Secondary
 * @dev A Secondary contract can only be used by its primary account (the one that created it)
 */
contract OwnableSecondary is Ownable {
  address private _primary;

  event PrimaryTransferred(
    address recipient
  );

  /**
   * @dev Sets the primary account to the one that is creating the Secondary contract.
   */
  constructor() internal {
    _primary = msg.sender;
    emit PrimaryTransferred(_primary);
  }

  /**
   * @dev Reverts if called from any account other than the primary or the owner.
   */
   modifier onlyPrimaryOrOwner() {
     require(msg.sender == _primary || msg.sender == owner(), "not the primary user nor the owner");
     _;
   }

   /**
    * @dev Reverts if called from any account other than the primary.
    */
  modifier onlyPrimary() {
    require(msg.sender == _primary, "not the primary user");
    _;
  }

  /**
   * @return the address of the primary.
   */
  function primary() public view returns (address) {
    return _primary;
  }

  /**
   * @dev Transfers contract to a new primary.
   * @param recipient The address of new primary.
   */
  function transferPrimary(address recipient) public onlyOwner {
    require(recipient != address(0), "new primary address is null");
    _primary = recipient;
    emit PrimaryTransferred(_primary);
  }
}


contract StatementRegisteryInterface is OwnableSecondary {
  /********************/
  /** PUBLIC - WRITE **/
  /********************/
  function recordStatement(string calldata buildingPermitId, uint[] calldata statementDataLayout, bytes calldata statementData) external returns(bytes32);

  /*******************/
  /** PUBLIC - READ **/
  /*******************/
  function statementIdsByBuildingPermit(string calldata id) external view returns(bytes32[] memory);

  function statementExists(bytes32 statementId) public view returns(bool);

  function getStatementString(bytes32 statementId, string memory key) public view returns(string memory);

  function getStatementPcId(bytes32 statementId) external view returns (string memory);

  function getStatementAcquisitionDate(bytes32 statementId) external view returns (string memory);

  function getStatementRecipient(bytes32 statementId) external view returns (string memory);

  function getStatementArchitect(bytes32 statementId) external view returns (string memory);

  function getStatementCityHall(bytes32 statementId) external view returns (string memory);

  function getStatementMaximumHeight(bytes32 statementId) external view returns (string memory);

  function getStatementDestination(bytes32 statementId) external view returns (string memory);

  function getStatementSiteArea(bytes32 statementId) external view returns (string memory);

  function getStatementBuildingArea(bytes32 statementId) external view returns (string memory);

  function getStatementNearImage(bytes32 statementId) external view returns(string memory);

  function getStatementFarImage(bytes32 statementId) external view returns(string memory);

  function getAllStatements() external view returns(bytes32[] memory);
}





contract OwnablePausable is Ownable {

  event Paused();
  event Unpaused();
  bool private _paused;

  constructor() internal {
    _paused = false;
    emit Unpaused();
  }

  /**
   * @return true if the contract is paused, false otherwise.
   */
  function paused() public view returns (bool) {
      return _paused;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
      require(!_paused);
      _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
      require(_paused);
      _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused {
      _paused = true;
      emit Paused();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
      _paused = false;
      emit Unpaused();
  }
}


contract Controller is OwnablePausable {
  StatementRegisteryInterface public registery;
  uint public price = 0;
  address payable private _wallet;
  address private _serverSide;

  event LogEvent(string content);
  event NewStatementEvent(string indexed buildingPermitId, bytes32 statementId);

  /********************/
  /** PUBLIC - WRITE **/
  /********************/
  constructor(address registeryAddress, address payable walletAddr, address serverSideAddr) public {
    require(registeryAddress != address(0), "null registery address");
    require(walletAddr != address(0), "null wallet address");
    require(serverSideAddr != address(0), "null server side address");

    registery = StatementRegisteryInterface(registeryAddress);
    _wallet = walletAddr;
    _serverSide = serverSideAddr;
  }

  /* The price of the service offered by this smart contract is to be updated freely
  by IMMIRIS. It is also updated on a daily basis by the server to reflect the current
  EUR/ETH exchange rate */
  function setPrice(uint priceInWei) external whenNotPaused {
    require(msg.sender == owner() || msg.sender == _serverSide);

    price = priceInWei;
  }

  function setWallet(address payable addr) external onlyOwner whenNotPaused {
    require(addr != address(0), "null wallet address");

    _wallet = addr;
  }

  function setServerSide(address payable addr) external onlyOwner whenNotPaused {
    require(addr != address(0), "null server side address");

    _serverSide = addr;
  }

  /* record a statement for a given price or for free if the request comes from the server.
  builidngPermitId: the id of the building permit associated with this statement. More than one statement can be recorded for a given permit id
  statementDataLayout: an array containing the length of each string packed in the bytes array, such as [string1Length, string2Length,...]
  statementData: all the strings packed as bytes by the D-App in javascript */
  function recordStatement(string calldata buildingPermitId, uint[] calldata statementDataLayout, bytes calldata statementData) external payable whenNotPaused returns(bytes32) {
      if(msg.sender != owner() && msg.sender != _serverSide) {
        require(msg.value >= price, "received insufficient value");

        uint refund = msg.value - price;

        _wallet.transfer(price); // ETH TRANSFER

        if(refund > 0) {
          msg.sender.transfer(refund); // ETH TRANSFER
        }
      }

      bytes32 statementId = registery.recordStatement(
        buildingPermitId,
        statementDataLayout,
        statementData
      );

      emit NewStatementEvent(buildingPermitId, statementId);

      return statementId;
  }

  /*******************/
  /** PUBLIC - READ **/
  /*******************/
  function wallet() external view returns (address) {
    return _wallet;
  }

  function serverSide() external view returns (address) {
    return _serverSide;
  }

  function statementExists(bytes32 statementId) external view returns (bool) {
    return registery.statementExists(statementId);
  }

  function getStatementIdsByBuildingPermit(string calldata buildingPermitId) external view returns(bytes32[] memory) {
    return registery.statementIdsByBuildingPermit(buildingPermitId);
  }

  function getAllStatements() external view returns(bytes32[] memory) {
    return registery.getAllStatements();
  }

  function getStatementPcId(bytes32 statementId) external view returns (string memory) {
    return registery.getStatementPcId(statementId);
  }

  function getStatementAcquisitionDate(bytes32 statementId) external view returns (string memory) {
    return registery.getStatementAcquisitionDate(statementId);
  }

  function getStatementRecipient(bytes32 statementId) external view returns (string memory) {
    return registery.getStatementRecipient(statementId);
  }

  function getStatementArchitect(bytes32 statementId) external view returns (string memory) {
    return registery.getStatementArchitect(statementId);
  }

  function getStatementCityHall(bytes32 statementId) external view returns (string memory) {
    return registery.getStatementCityHall(statementId);
  }

  function getStatementMaximumHeight(bytes32 statementId) external view returns (string memory) {
    return registery.getStatementMaximumHeight(statementId);
  }

  function getStatementDestination(bytes32 statementId) external view returns (string memory) {
    return registery.getStatementDestination(statementId);
  }

  function getStatementSiteArea(bytes32 statementId) external view returns (string memory) {
    return registery.getStatementSiteArea(statementId);
  }

  function getStatementBuildingArea(bytes32 statementId) external view returns (string memory) {
    return registery.getStatementBuildingArea(statementId);
  }

  function getStatementNearImage(bytes32 statementId) external view returns(string memory) {
    return registery.getStatementNearImage(statementId);
  }

  function getStatementFarImage(bytes32 statementId) external view returns(string memory) {
    return registery.getStatementFarImage(statementId);
  }
}