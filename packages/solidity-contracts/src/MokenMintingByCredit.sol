/**
 * Source Code first verified at https://etherscan.io on Friday, March 15, 2019
 (UTC) */

pragma solidity 0.4.24;
pragma experimental "v0.5.0";
/******************************************************************************\
* Author: Nick Mudge, <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e7898e848ca78a888c828994c98e88">[email protected]</a>
* Mokens
* Copyright (c) 2019
*
* Minting mokens with credit.
/******************************************************************************/

///////////////////////////////////////////////////////////////////////////////////
//Storage contracts
////////////
//Some delegate contracts are listed with storage contracts they inherit.
///////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////
//Mokens
///////////////////////////////////////////////////////////////////////////////////
contract Storage0 {
    // funcId => delegate contract
    mapping(bytes4 => address) internal delegates;
}
///////////////////////////////////////////////////////////////////////////////////
//MokenUpdates
//MokenOwner
//QueryMokenDelegates
///////////////////////////////////////////////////////////////////////////////////
contract Storage1 is Storage0 {
    address internal contractOwner;
    bytes[] internal funcSignatures;
    // signature => index+1
    mapping(bytes => uint256) internal funcSignatureToIndex;
}
///////////////////////////////////////////////////////////////////////////////////
//MokensSupportsInterfaces
///////////////////////////////////////////////////////////////////////////////////
contract Storage2 is Storage1 {
    mapping(bytes4 => bool) internal supportedInterfaces;
}
///////////////////////////////////////////////////////////////////////////////////
//MokenRootOwnerOf
//MokenERC721Metadata
///////////////////////////////////////////////////////////////////////////////////
contract Storage3 is Storage2 {
    struct Moken {
        string name;
        uint256 data;
        uint256 parentTokenId;
    }
    //tokenId => moken
    mapping(uint256 => Moken) internal mokens;
    uint256 internal mokensLength;
    // child address => child tokenId => tokenId+1
    mapping(address => mapping(uint256 => uint256)) internal childTokenOwner;
}
///////////////////////////////////////////////////////////////////////////////////
//MokenERC721Enumerable
//MokenLinkHash
///////////////////////////////////////////////////////////////////////////////////
contract Storage4 is Storage3 {
    // root token owner address => (tokenId => approved address)
    mapping(address => mapping(uint256 => address)) internal rootOwnerAndTokenIdToApprovedAddress;
    // token owner => (operator address => bool)
    mapping(address => mapping(address => bool)) internal tokenOwnerToOperators;
    // Mapping from owner to list of owned token IDs
    mapping(address => uint32[]) internal ownedTokens;
}
///////////////////////////////////////////////////////////////////////////////////
//MokenERC998ERC721TopDown
//MokenERC998ERC721TopDownBatch
//MokenERC721
//MokenERC721Batch
///////////////////////////////////////////////////////////////////////////////////
contract Storage5 is Storage4 {
    // tokenId => (child address => array of child tokens)
    mapping(uint256 => mapping(address => uint256[])) internal childTokens;
    // tokenId => (child address => (child token => child index)
    mapping(uint256 => mapping(address => mapping(uint256 => uint256))) internal childTokenIndex;
    // tokenId => (child address => contract index)
    mapping(uint256 => mapping(address => uint256)) internal childContractIndex;
    // tokenId => child contract
    mapping(uint256 => address[]) internal childContracts;
}
///////////////////////////////////////////////////////////////////////////////////
//MokenERC998ERC20TopDown
//MokenStateChange
///////////////////////////////////////////////////////////////////////////////////
contract Storage6 is Storage5 {
    // tokenId => token contract
    mapping(uint256 => address[]) internal erc20Contracts;
    // tokenId => (token contract => token contract index)
    mapping(uint256 => mapping(address => uint256)) erc20ContractIndex;
    // tokenId => (token contract => balance)
    mapping(uint256 => mapping(address => uint256)) internal erc20Balances;
}
///////////////////////////////////////////////////////////////////////////////////
//MokenERC998ERC721BottomUp
//MokenERC998ERC721BottomUpBatch
///////////////////////////////////////////////////////////////////////////////////
contract Storage7 is Storage6 {
    // parent address => (parent tokenId => array of child tokenIds)
    mapping(address => mapping(uint256 => uint32[])) internal parentToChildTokenIds;
    // tokenId => position in childTokens array
    mapping(uint256 => uint256) internal tokenIdToChildTokenIdsIndex;
}
///////////////////////////////////////////////////////////////////////////////////
//MokenMinting
//MokenMintContractManagement
//MokenEras
//QueryMokenData
///////////////////////////////////////////////////////////////////////////////////
contract Storage8 is Storage7 {
    // index => category
    mapping(uint256 => bytes32) internal categories;
    uint256 internal categoryLength;
    // category => index+1
    mapping(bytes32 => uint256) internal categoryIndex;
    uint256 internal mintPriceOffset; // = 0 szabo;
    uint256 internal mintStepPrice; // = 500 szabo;
    uint256 internal mintPriceBuffer; // = 5000 szabo;
    address[] internal permissionsList;
    // Order is from right to left
    // 0 bit is permission to give permission
    // 1 bit is permission to mint
    mapping(address => uint256) internal permissions;
    //moken name => tokenId+1
    mapping(string => uint256) internal tokenByName_;
}

///////////////////////////////////////////////////////////////////////////////////
// MokenCredit
///////////////////////////////////////////////////////////////////////////////////
contract Storage9 is Storage8 {
    // molder => wei
    mapping(address => uint256) internal credit;

    // categoryIndex >> mint price
    mapping(uint256 => uint256) internal categoryMintPrice;
}

contract MokenMintingByCredit is Storage9 {

    uint256 constant MAX_MOKENS = 4294967296;
    uint256 constant MAX_OWNER_MOKENS = 65536;
    uint256 constant MOKEN_LINK_HASH_MASK = 0xffffffffffffffff000000000000000000000000000000000000000000000000;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Mint(
        address indexed mintContract,
        address indexed owner,
        bytes32 indexed category,
        string mokenName,
        bytes32 data,
        uint256 tokenId,
        bytes32 currencyName,
        uint256 price
    );

    function mintInfo(uint256 _categoryIndex) external view returns (uint256 balance, uint256 mintPrice){
        balance = credit[msg.sender];
        require(_categoryIndex < categoryLength, "categoryIndex does not exist");
        mintPrice = categoryMintPrice[_categoryIndex];
    }

    function mintInfo(bytes32 _category) external view returns (uint256 balance, uint256 mintPrice){
        balance = credit[msg.sender];
        uint256 index = categoryIndex[_category];
        require(index != 0, "No category exists with this name.");
        mintPrice = categoryMintPrice[index-1];
    }

    function creditToPay(uint256 _categoryIndex) external view returns (uint256 toPay) {
        uint256 balance = credit[msg.sender];
        require(_categoryIndex < categoryLength, "categoryIndex does not exist");
        uint256 mintPrice = categoryMintPrice[_categoryIndex];
        if(balance >= mintPrice) {
            toPay = 0;
        }
        else {
            toPay = mintPrice - balance;
        }
    }

    function creditToPay(bytes32 _category) external view returns (uint256 toPay) {
        uint256 balance = credit[msg.sender];
        uint256 index = categoryIndex[_category];
        require(index != 0, "No category exists with this name.");
        uint256 mintPrice = categoryMintPrice[index-1];
        if(balance >= mintPrice) {
            toPay = 0;
        }
        else {
            toPay = mintPrice - balance;
        }
    }


    function mint(address _tokenOwner, string _mokenName, bytes32 _category, bytes32 _linkHash) external returns (uint256 tokenId) {
        require((permissions[msg.sender] >> 1) & 1 == 1, "Only a minter can call this function.");

        require(_tokenOwner != address(0), "Owner cannot be the 0 address.");

        tokenId = mokensLength++;
        // prevents 32 bit overflow
        require(tokenId < MAX_MOKENS, "Only 4,294,967,296 mokens can be created.");

        //Was enough ether passed in?
        uint256 categoryIndex = categoryIndex[_category];
        require(categoryIndex != 0, "No category exists with this name.");
        categoryIndex--;
        uint256 currentMintPrice = categoryMintPrice[categoryIndex];
        uint256 creditBalance = credit[_tokenOwner];
        uint256 ownedTokensIndex = ownedTokens[_tokenOwner].length;
        require(creditBalance >= currentMintPrice, "Paid ether is lower than mint price.");
        credit[_tokenOwner] = creditBalance - currentMintPrice;

        string memory lowerMokenName = validateAndLower(_mokenName);
        require(tokenByName_[lowerMokenName] == 0, "Moken name already exists.");

        // prevents 16 bit overflow
        require(ownedTokensIndex < MAX_OWNER_MOKENS, "An single owner address cannot possess more than 65,536 mokens.");

        // adding the current category index, ownedTokenIndex and owner address to data
        // this saves gas for each mint.
        uint256 data = uint256(_linkHash) & MOKEN_LINK_HASH_MASK | categoryIndex << 176 | ownedTokensIndex << 160 | uint160(_tokenOwner);

        // create moken
        mokens[tokenId].name = _mokenName;
        mokens[tokenId].data = data;
        tokenByName_[lowerMokenName] = tokenId + 1;

        //add moken to the specific owner
        ownedTokens[_tokenOwner].push(uint32(tokenId));

        //emit events
        emit Transfer(address(0), _tokenOwner, tokenId);
        emit Mint(address(this), _tokenOwner, _category, _mokenName, bytes32(data), tokenId, "Ether", currentMintPrice);

        return tokenId;
    }


    function validateAndLower(string memory _s) internal pure returns (string memory mokenName) {
        assembly {
        // get length of _s
            let len := mload(_s)
        // get position of _s
            let p := add(_s, 0x20)
        // _s cannot be 0 characters
            if eq(len, 0) {
                revert(0, 0)
            }
        // _s cannot be more than 100 characters
            if gt(len, 100) {
                revert(0, 0)
            }
        // get first character
            let b := byte(0, mload(add(_s, 0x20)))
        // first character cannot be whitespace/unprintable
            if lt(b, 0x21) {
                revert(0, 0)
            }
        // get last character
            b := byte(0, mload(add(p, sub(len, 1))))
        // last character cannot be whitespace/unprintable
            if lt(b, 0x21) {
                revert(0, 0)
            }
        // loop through _s and lowercase uppercase characters
            for {let end := add(p, len)}
            lt(p, end)
            {p := add(p, 1)}
            {
                b := byte(0, mload(p))
                if lt(b, 0x5b) {
                    if gt(b, 0x40) {
                        mstore8(p, add(b, 32))
                    }
                }
            }
        }
        return _s;
    }
}