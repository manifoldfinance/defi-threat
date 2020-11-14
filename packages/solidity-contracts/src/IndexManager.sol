/**
 * Source Code first verified at https://etherscan.io on Monday, April 1, 2019
 (UTC) */

pragma solidity ^0.4.13;

contract IndexManager {

  bytes32 managerName;
  address owner;

  struct IndexStruct {
    address indexAddress;
    uint indexCategory;
    string label;
    uint index;
  }
  
  mapping(address=>bool) public delegatinglist;
  mapping(bytes32 => IndexStruct) private indexStructs;
  bytes32[] private indexIndex;

  event LogNewIndex   (bytes32 indexed indexName, uint index, address indexAddress, uint indexCategory);
  event LogUpdateIndex(bytes32 indexed indexName, uint index, address indexAddress, uint indexCategory, string label);
  event LogDeleteIndex(bytes32 indexed indexName, uint index);

  event indexInitialized(uint32 _date, bytes32 _indexName);
  event Authorized(address authorized, uint timestamp);
  event Revoked(address authorized, uint timestamp);

  modifier onlyAuthorized(){
      require(isdelegatinglisted(msg.sender));
      _;
  }

  function authorize(address authorized) public onlyAuthorized {
      delegatinglist[authorized] = true;
      emit Authorized(authorized, now);
  }

  // also if not in the list..
  function revoke(address authorized) public onlyAuthorized {
      delegatinglist[authorized] = false;
      emit Revoked(authorized, now);
  }

  function authorizeMany(address[50] authorized) public onlyAuthorized {
      for(uint i = 0; i < authorized.length; i++) {
          authorize(authorized[i]);
      }
  }

  function isdelegatinglisted(address authorized) public view returns(bool) {
    return delegatinglist[authorized];
  }

  constructor(bytes32 _name) public{        
      owner = msg.sender;
      delegatinglist[owner] = true;
      owner = msg.sender;
      managerName = _name;
  }

  function isIndex(bytes32 indexName)
    public
    constant
    returns(bool isIndeed)
  {
    if(indexIndex.length == 0) return false;
    return (indexIndex[indexStructs[indexName].index] == indexName);
  }

  function insertIndex(
    bytes32 indexName,
    address indexAddress,
    uint    indexCategory,
    string label)
    onlyAuthorized
    public
    returns(uint index)
  {
    if(isIndex(indexName)) revert();
    indexStructs[indexName].indexAddress = indexAddress;
    indexStructs[indexName].indexCategory   = indexCategory;
    indexStructs[indexName].label   = label;
    indexStructs[indexName].index     = indexIndex.push(indexName)-1;
    emit LogNewIndex(
        indexName,
        indexStructs[indexName].index,
        indexAddress,
        indexCategory);
    return indexIndex.length-1;
  }

  function deleteIndex(bytes32 indexName)
    onlyAuthorized
    public
    returns(uint index)
  {
    if(!isIndex(indexName)) revert();
    uint rowToDelete = indexStructs[indexName].index;
    bytes32 keyToMove = indexIndex[indexIndex.length-1];
    indexIndex[rowToDelete] = keyToMove;
    indexStructs[keyToMove].index = rowToDelete;
    indexIndex.length--;
    emit LogDeleteIndex(
        indexName,
        rowToDelete);
    emit LogUpdateIndex(
        keyToMove,
        rowToDelete,
        indexStructs[keyToMove].indexAddress,
        indexStructs[keyToMove].indexCategory,
        indexStructs[keyToMove].label);
    return rowToDelete;
  }

  function getIndex(bytes32 indexName)
    public
    constant
    returns(address indexAddress, uint indexCategory, uint index, string label)
  {
    if(!isIndex(indexName)) revert();
    return(
      indexStructs[indexName].indexAddress,
      indexStructs[indexName].indexCategory,
      indexStructs[indexName].index,
      indexStructs[indexName].label);
  }

  function updateIndexAddress(bytes32 indexName, address indexAddress)
    onlyAuthorized
    public
    returns(bool success)
  {
    if(!isIndex(indexName)) revert();
    indexStructs[indexName].indexAddress = indexAddress;
    emit LogUpdateIndex(
      indexName,
      indexStructs[indexName].index,
      indexAddress,
      indexStructs[indexName].indexCategory,
      indexStructs[indexName].label);
    return true;
  }

  function updateIndexCategory(bytes32 indexName, uint indexCategory)
    onlyAuthorized
    public
    returns(bool success)
  {
    if(!isIndex(indexName)) revert();
    indexStructs[indexName].indexCategory = indexCategory;
    emit LogUpdateIndex(
      indexName,
      indexStructs[indexName].index,
      indexStructs[indexName].indexAddress,
      indexCategory,
      indexStructs[indexName].label);
    return true;
  }

  function updateIndexLabel(bytes32 indexName, string newLabel)
    onlyAuthorized
    public
    returns(bool success)
  {
    if(!isIndex(indexName)) revert();
    indexStructs[indexName].label = newLabel;
    emit LogUpdateIndex(
      indexName,
      indexStructs[indexName].index,
      indexStructs[indexName].indexAddress,
      indexStructs[indexName].indexCategory,
      newLabel);
    return true;
  }

  function getIndexCount()
    public
    constant
    returns(uint count)
  {
    return indexIndex.length;
  }

  function getIndexAtIndex(uint index)
    public
    constant
    returns(bytes32 indexName)
  {
    return indexIndex[index];
  }

  function addIndexInitialization(uint32 _date, bytes32 _indexName) public onlyAuthorized {
    emit indexInitialized(_date, _indexName);
  }

}