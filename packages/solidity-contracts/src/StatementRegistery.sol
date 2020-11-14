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






contract ImmutableEternalStorageInterface is OwnableSecondary {
  /********************/
  /** PUBLIC - WRITE **/
  /********************/
  function createUint(bytes32 key, uint value) external;

  function createString(bytes32 key, string calldata value) external;

  function createAddress(bytes32 key, address value) external;

  function createBytes(bytes32 key, bytes calldata value) external;

  function createBytes32(bytes32 key, bytes32 value) external;

  function createBool(bytes32 key, bool value) external;

  function createInt(bytes32 key, int value) external;

  /*******************/
  /** PUBLIC - READ **/
  /*******************/
  function getUint(bytes32 key) external view returns(uint);

  function uintExists(bytes32 key) external view returns(bool);

  function getString(bytes32 key) external view returns(string memory);

  function stringExists(bytes32 key) external view returns(bool);

  function getAddress(bytes32 key) external view returns(address);

  function addressExists(bytes32 key) external view returns(bool);

  function getBytes(bytes32 key) external view returns(bytes memory);

  function bytesExists(bytes32 key) external view returns(bool);

  function getBytes32(bytes32 key) external view returns(bytes32);

  function bytes32Exists(bytes32 key) external view returns(bool);

  function getBool(bytes32 key) external view returns(bool);

  function boolExists(bytes32 key) external view returns(bool);

  function getInt(bytes32 key) external view returns(int);

  function intExists(bytes32 key) external view returns(bool);
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



contract StatementRegistery is StatementRegisteryInterface {
  ImmutableEternalStorageInterface public dataStore;
  string[] public buildingPermitIds;
  mapping(bytes32 => uint) public statementCountByBuildingPermitHash;

  event NewStatementEvent(string indexed buildingPermitId, bytes32 statementId);

  /********************/
  /** PUBLIC - WRITE **/
  /********************/
  constructor(address immutableDataStore) public {
    require(immutableDataStore != address(0), "null data store");
    dataStore = ImmutableEternalStorageInterface(immutableDataStore);
  }

  /* Only to be called by the Controller contract */
  function recordStatement(
    string calldata buildingPermitId,
    uint[] calldata statementDataLayout,
    bytes calldata statementData
  ) external onlyPrimaryOrOwner returns(bytes32) {
    bytes32 statementId = generateNewStatementId(buildingPermitId);

    assert(!statementExists(statementId));

    recordStatementKeyValues(statementId, statementDataLayout, statementData);

    dataStore.createBool(keccak256(abi.encodePacked(statementId)), true);
    updateStatementCountByBuildingPermit(buildingPermitId);

    emit NewStatementEvent(buildingPermitId, statementId);

    return statementId;
  }

  /*******************/
  /** PUBLIC - READ **/
  /*******************/
  function statementIdsByBuildingPermit(string calldata buildingPermitId) external view returns(bytes32[] memory) {
    uint nbStatements = statementCountByBuildingPermit(buildingPermitId);

    bytes32[] memory res = new bytes32[](nbStatements);

    while(nbStatements > 0) {
      nbStatements--;
      res[nbStatements] = computeStatementId(buildingPermitId,nbStatements);
    }

    return res;
  }

  function statementExists(bytes32 statementId) public view returns(bool) {
    return dataStore.boolExists(keccak256(abi.encodePacked(statementId)));
  }

  function getStatementString(bytes32 statementId, string memory key) public view returns(string memory) {
    return dataStore.getString(keccak256(abi.encodePacked(statementId, key)));
  }

  function getStatementPcId(bytes32 statementId) external view returns (string memory) {
    return getStatementString(statementId, "pcId");
  }

  function getStatementAcquisitionDate(bytes32 statementId) external view returns (string memory) {
    return getStatementString(statementId, "acquisitionDate");
  }

  function getStatementRecipient(bytes32 statementId) external view returns (string memory) {
    return getStatementString(statementId, "recipient");
  }

  function getStatementArchitect(bytes32 statementId) external view returns (string memory) {
    return getStatementString(statementId, "architect");
  }

  function getStatementCityHall(bytes32 statementId) external view returns (string memory) {
    return getStatementString(statementId, "cityHall");
  }

  function getStatementMaximumHeight(bytes32 statementId) external view returns (string memory) {
    return getStatementString(statementId, "maximumHeight");
  }

  function getStatementDestination(bytes32 statementId) external view returns (string memory) {
    return getStatementString(statementId, "destination");
  }

  function getStatementSiteArea(bytes32 statementId) external view returns (string memory) {
    return getStatementString(statementId, "siteArea");
  }

  function getStatementBuildingArea(bytes32 statementId) external view returns (string memory) {
    return getStatementString(statementId, "buildingArea");
  }

  function getStatementNearImage(bytes32 statementId) external view returns(string memory) {
    return getStatementString(statementId, "nearImage");
  }

  function getStatementFarImage(bytes32 statementId) external view returns(string memory) {
    return getStatementString(statementId, "farImage");
  }

  function getAllStatements() external view returns(bytes32[] memory) {
    uint nbStatements = 0;
    for(uint idx = 0; idx < buildingPermitIds.length; idx++) {
      nbStatements += statementCountByBuildingPermit(buildingPermitIds[idx]);
    }

    bytes32[] memory res = new bytes32[](nbStatements);

    uint statementIdx = 0;
    for(uint idx = 0; idx < buildingPermitIds.length; idx++) {
      nbStatements = statementCountByBuildingPermit(buildingPermitIds[idx]);
      while(nbStatements > 0){
        nbStatements--;
        res[statementIdx] = computeStatementId(buildingPermitIds[idx],nbStatements);
        statementIdx++;
      }
    }

    return res;
  }

  /**********************/
  /** INTERNAL - WRITE **/
  /**********************/
  function updateStatementCountByBuildingPermit(string memory buildingPermitId) internal {
    uint oldCount = statementCountByBuildingPermitHash[keccak256(abi.encodePacked(buildingPermitId))];

    if(oldCount == 0) { // first record for this building permit id
      buildingPermitIds.push(buildingPermitId);
    }

    uint newCount = oldCount + 1;
    assert(newCount > oldCount);
    statementCountByBuildingPermitHash[keccak256(abi.encodePacked(buildingPermitId))] = newCount;
  }

  function recordStatementKeyValues(
    bytes32 statementId,
    uint[] memory statementDataLayout,
    bytes memory statementData) internal {
    string[] memory infos = parseStatementStrings(statementDataLayout, statementData);

    require(infos.length == 11, "the statement key values array length is incorrect");

    /** enforce the rules given in the legal specifications **/
    // required infos
    require(!isEmpty(infos[0]) && !isEmpty(infos[1]), "acquisitionDate and pcId are required");
    require(!isEmpty(infos[9]) && !isEmpty(infos[10]), "missing image");

    // < 2 missing non required info
    uint nbMissingNRIs = (isEmpty(infos[2]) ? 1 : 0) + (isEmpty(infos[3]) ? 1 : 0) + (isEmpty(infos[4]) ? 1 : 0) + (isEmpty(infos[7]) ? 1 : 0);
    require(nbMissingNRIs <= 2, "> 2 missing non required info");

    // mo missing mandatory info or one missing mandatory info and 0 missing non required info
    uint nbMissingMIs = (isEmpty(infos[5]) ? 1 : 0) + (isEmpty(infos[6]) ? 1 : 0) + (isEmpty(infos[8]) ? 1 : 0);
    require(nbMissingMIs == 0 || (nbMissingMIs == 1 && nbMissingNRIs == 0), "missing mandatory info");

    recordStatementString(statementId, "pcId", infos[0]);
    recordStatementString(statementId, "acquisitionDate", infos[1]);
    if(!isEmpty(infos[2])) recordStatementString(statementId, "recipient", infos[2]);
    if(!isEmpty(infos[3])) recordStatementString(statementId, "architect", infos[3]);
    if(!isEmpty(infos[4])) recordStatementString(statementId, "cityHall", infos[4]);
    if(!isEmpty(infos[5])) recordStatementString(statementId, "maximumHeight", infos[5]);
    if(!isEmpty(infos[6])) recordStatementString(statementId, "destination", infos[6]);
    if(!isEmpty(infos[7])) recordStatementString(statementId, "siteArea", infos[7]);
    if(!isEmpty(infos[8])) recordStatementString(statementId, "buildingArea", infos[8]);
    recordStatementString(statementId, "nearImage", infos[9]);
    recordStatementString(statementId, "farImage", infos[10]);
  }

  function recordStatementString(bytes32 statementId, string memory key, string memory value) internal {
    require(!dataStore.stringExists(keccak256(abi.encodePacked(statementId, key))), "Trying to write an existing key-value string pair");

    dataStore.createString(keccak256(abi.encodePacked(statementId,key)), value);
  }

  /*********************/
  /** INTERNAL - READ **/
  /*********************/
  function generateNewStatementId(string memory buildingPermitId) internal view returns (bytes32) {
    uint nbStatements = statementCountByBuildingPermit(buildingPermitId);
    return computeStatementId(buildingPermitId,nbStatements);
  }

  function statementCountByBuildingPermit(string memory buildingPermitId) internal view returns (uint) {
    return statementCountByBuildingPermitHash[keccak256(abi.encodePacked(buildingPermitId))]; // mapping's default is 0
  }

  function computeStatementId(string memory buildingPermitId, uint statementNb) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(buildingPermitId,statementNb));
  }

  function parseStatementStrings(uint[] memory statementDataLayout, bytes memory statementData) internal pure returns(string[] memory) {
    string[] memory res = new string[](statementDataLayout.length);
    uint bytePos = 0;
    uint resLength = res.length;
    for(uint i = 0; i < resLength; i++) {
      bytes memory strBytes = new bytes(statementDataLayout[i]);
      uint strBytesLength = strBytes.length;
      for(uint j = 0; j < strBytesLength; j++) {
        strBytes[j] = statementData[bytePos];
        bytePos++;
      }
      res[i] = string(strBytes);
    }

    return res;
  }

  function isEmpty(string memory s) internal pure returns(bool) {
    return bytes(s).length == 0;
  }
}