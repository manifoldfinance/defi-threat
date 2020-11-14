/**
 * Source Code first verified at https://etherscan.io on Wednesday, April 17, 2019
 (UTC) */

pragma solidity 0.5.1;
contract zDappRunner {  
	address payable gadrOwner;
	uint32 gnEntryCount = 0;

	struct clsEntry {
		address adrCreator;
		bool bDisabled;
	}

	mapping(bytes32 => clsEntry) gmapEntry;
	mapping (uint => bytes32) gmapEntryIndex;

	constructor() public { gadrOwner = msg.sender; }

	modifier onlyByOwner()
	{
		require(
			msg.sender == gadrOwner, "Sender not authorized."
		);
		_;
	}

	event Entries(bytes32 indexed b32AlphaID, address indexed adrCreator, uint indexed nDateCreated, string sParms);

	function zKill() onlyByOwner() external {selfdestruct (gadrOwner);}
	
	function zGetAllEntries() external view returns (bytes32[] memory ab32AlphaID, address[] memory aadrCreator, bool[] memory abDisabled) {
		ab32AlphaID = new bytes32[](gnEntryCount);
		aadrCreator = new address[](gnEntryCount);
		abDisabled = new bool[](gnEntryCount);
	
		for (uint i = 0; i < gnEntryCount; i++) {
			clsEntry memory objEntry = gmapEntry[gmapEntryIndex[i]];
			ab32AlphaID[i] = gmapEntryIndex[i];
			aadrCreator[i] = objEntry.adrCreator;
			abDisabled[i] = objEntry.bDisabled;
		}	
	}

	function zAddEntry(bytes32 b32AlphaID, string calldata sParms) external {
		gmapEntry[b32AlphaID].adrCreator = msg.sender;
		gmapEntryIndex[gnEntryCount] = b32AlphaID;
		gnEntryCount++;
		emit Entries(b32AlphaID, msg.sender, block.timestamp, sParms);
	}

	function zSetDisabled(bytes32 b32AlphaID, bool bDisabled) external {
		require(msg.sender == gadrOwner || msg.sender == gmapEntry[b32AlphaID].adrCreator);
		gmapEntry[b32AlphaID].bDisabled = bDisabled;
	}
}