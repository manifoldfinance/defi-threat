/**
 * Source Code first verified at https://etherscan.io on Thursday, May 2, 2019
 (UTC) */

pragma solidity 0.4.24;

contract DocSignature {

  struct SignProcess {
    bytes16 id;
    bytes16[] participants;
  }

  address controller;
  mapping(address => bool) isOwner;
  mapping(bytes => SignProcess[]) documents;
  address[] public owners;

  constructor(address _controller, address _owner) public {
    controller = _controller;
    isOwner[_owner] = true;
    owners.push(_owner);
  }

  modifier notNull(address _address) {
    require(_address != 0);
    _;
  }

  function addOwner(address _owner) public notNull(_owner) returns (bool) {
    require(isOwner[msg.sender]);
    isOwner[_owner] = true;
    owners.push(_owner);
    return true;
  }

  function removeOwner(address _owner) public notNull(_owner) returns (bool) {
    require(msg.sender != _owner && isOwner[msg.sender]);
    isOwner[_owner] = false;
    for (uint i=0; i<owners.length - 1; i++)
      if (owners[i] == _owner) {
        owners[i] = owners[owners.length - 1];
        break;
      }
    owners.length -= 1;
    return true;
  }

  function getOwners() public constant returns (address[]) {
    return owners;
  }

  function setController(address _controller) public notNull(_controller) returns (bool) {
    require(isOwner[msg.sender]);
    controller = _controller;
    return true;
  }

  function signDocument(bytes _documentHash, bytes16 _signProcessId, bytes16[] _participants) public returns (bool) {
    require(msg.sender == controller);
    documents[_documentHash].push(SignProcess(_signProcessId, _participants));
    return true;
  }

  function getDocumentSignatures(bytes _documentHash) public view returns (bytes16[], bytes16[]) {
    uint _signaturesCount = 0;
    for (uint o = 0; o < documents[_documentHash].length; o++) {
      _signaturesCount += documents[_documentHash][o].participants.length;
    }

    bytes16[] memory _ids = new bytes16[](_signaturesCount);
    bytes16[] memory _participants = new bytes16[](_signaturesCount);

    uint _index = 0;
    for (uint i = 0; i < documents[_documentHash].length; i++) {
      for (uint j = 0; j < documents[_documentHash][i].participants.length; j++) {
        _ids[_index] =  documents[_documentHash][i].id;
        _participants[_index] = documents[_documentHash][i].participants[j];
        _index++;
      }
    }

    return (_ids, _participants);
  }

  function getDocumentProcesses(bytes _documentHash) public view returns (bytes16[]) {
    bytes16[] memory _ids = new bytes16[](documents[_documentHash].length);

    for (uint i = 0; i < documents[_documentHash].length; i++) {
      _ids[i] =  documents[_documentHash][i].id;
    }

    return (_ids);
  }

  function getProcessParties(bytes _documentHash, bytes16 _processId) public view returns (bytes16[]) {
    for (uint i = 0; i < documents[_documentHash].length; i++) {
      if (documents[_documentHash][i].id == _processId)
        return (documents[_documentHash][i].participants);
    }
    return (new bytes16[](0));
  }
}