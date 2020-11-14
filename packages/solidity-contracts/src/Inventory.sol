/**
 * Source Code first verified at https://etherscan.io on Sunday, May 5, 2019
 (UTC) */

pragma solidity ^0.4.25;

/**
 * 
 * World War Goo - Competitive Idle Game
 * 
 * https://ethergoo.io
 * 
 */

interface ERC721 {
    function totalSupply() external view returns (uint256 tokens);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function exists(uint256 tokenId) external view returns (bool tokenExists);
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address approvee);

    function transferFrom(address from, address to, uint256 tokenId) external;
    function tokensOf(address owner) external view returns (uint256[] tokens);
    //function tokenByIndex(uint256 index) external view returns (uint256 token);

    // Events
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);
}


interface ERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes data) external returns(bytes4);
}

contract Inventory is ERC721 {

    Units constant units = Units(0xf936aa9e1f22c915abf4a66a5a6e94eb8716ba5e);

    string public constant name = "Goo Item";
    string public constant symbol = "GOOITEM";

    mapping(address => mapping(uint256 => uint256)) public unitEquippedItems; // address -> unitId -> tokenId
    mapping(uint256 => Item) public itemList;

    // ERC721 stuff
    mapping(uint256 => address) public tokenOwner;
    mapping(uint256 => address) public tokenApprovals;
    mapping(address => uint256[]) public ownedTokens;
    mapping(uint256 => uint256) public ownedTokensIndex;
    mapping(uint256 => uint256) public tokenItems; // tokenId -> ItemId
    mapping(address => bool) operator;

    // Offset by one (so token id starts from 1)
    uint256 nextTokenId = 1;
    uint256 tokensBurnt = 1;

    struct Item {
        uint256 itemId;
        uint256 unitId;
        uint256 rarity;
        uint32[8] upgradeGains;
    }

    address owner; // Minor management

    constructor() public {
        owner = msg.sender;
    }

    function setOperator(address gameContract, bool isOperator) external {
        require(msg.sender == owner);
        operator[gameContract] = isOperator;
    }

    function totalSupply() external view returns (uint256) {
        return nextTokenId - tokensBurnt;
    }

    function balanceOf(address player) public view returns (uint256) {
        return ownedTokens[player].length;
    }

    function ownerOf(uint256 tokenId) external view returns (address) {
        return tokenOwner[tokenId];
    }

    function exists(uint256 tokenId) external view returns (bool) {
        return tokenOwner[tokenId] != address(0);
    }

    function approve(address to, uint256 tokenId) external {
        require(msg.sender == tokenOwner[tokenId]);
        tokenApprovals[tokenId] = to;
        emit Approval(msg.sender, to, tokenId);
    }

    function getApproved(uint256 tokenId) external view returns (address) {
        return tokenApprovals[tokenId];
    }

    function tokensOf(address player) external view returns (uint256[] tokens) {
         return ownedTokens[player];
    }

    function itemsOf(address player) external view returns (uint256[], uint256[]) {
        uint256 unequippedItemsCount = 0; // TODO better way?
        uint256 tokensLength = ownedTokens[player].length;
        for (uint256 i = 0; i < tokensLength; i++) {
            if (tokenOwner[ownedTokens[player][i]] == player) {
                unequippedItemsCount++;
            }
        }

        uint256[] memory tokensOwned = new uint256[](unequippedItemsCount);
        uint256 j = 0;
        for (i = 0; i < tokensLength; i++) {
            uint256 tokenId = ownedTokens[player][i];
            if (tokenOwner[tokenId] == player) { // Unequipped items only
                tokensOwned[j] = tokenId;
                j++;
            }
        }

        uint256[] memory itemIdsOwned = new uint256[](unequippedItemsCount);
        for (i = 0; i < unequippedItemsCount; i++) {
            itemIdsOwned[i] = tokenItems[tokensOwned[i]];
        }

        return (tokensOwned, itemIdsOwned);
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        require(tokenApprovals[tokenId] == msg.sender || tokenOwner[tokenId] == msg.sender || operator[msg.sender]);
        require(tokenOwner[tokenId] == from);

        removeTokenFrom(from, tokenId);
        addTokenTo(to, tokenId);

        delete tokenApprovals[tokenId]; // Clear approval
        emit Transfer(from, to, tokenId);
    }
    
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }
    
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public {
        transferFrom(from, to, tokenId);
        checkERC721Recieved(from, to, tokenId, data);
    }
    
    function checkERC721Recieved(address from, address to, uint256 tokenId, bytes memory data) internal {
        uint256 size;
        assembly { size := extcodesize(to) }
        if (size > 0) { // Recipient is contract so must confirm recipt
            bytes4 successfullyRecieved = ERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data);
            require(successfullyRecieved == bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")));
        }
    }

    function removeTokenFrom(address from, uint256 tokenId) internal {
        require(tokenOwner[tokenId] == from);
        tokenOwner[tokenId] = address(0);

        uint256 tokenIndex = ownedTokensIndex[tokenId];
        uint256 lastTokenIndex = SafeMath.sub(ownedTokens[from].length, 1);
        uint256 lastToken = ownedTokens[from][lastTokenIndex];

        ownedTokens[from][tokenIndex] = lastToken;
        ownedTokens[from][lastTokenIndex] = 0;

        ownedTokens[from].length--;
        ownedTokensIndex[tokenId] = 0;
        ownedTokensIndex[lastToken] = tokenIndex;
    }

    function addTokenTo(address to, uint256 tokenId) internal {
        require(tokenOwner[tokenId] == address(0));
        tokenOwner[tokenId] = to;

        ownedTokensIndex[tokenId] = ownedTokens[to].length;
        ownedTokens[to].push(tokenId);
    }
    
    function burn(uint256 tokenId) external {
        address itemOwner = tokenOwner[tokenId];
        require(itemOwner == msg.sender || operator[msg.sender]);
        
        removeTokenFrom(itemOwner, tokenId);
        delete tokenApprovals[tokenId]; // Clear approval
        delete tokenItems[tokenId]; // Delete token-item
        emit Transfer(itemOwner, address(0), tokenId);
        tokensBurnt++;
    }

    function mintItem(uint256 itemId, address player) external {
        require(operator[msg.sender]);
        require(validItem(itemId));

        uint256 tokenId = nextTokenId; // Start from id 1
        tokenItems[tokenId] = itemId;
        addTokenTo(player, tokenId);
        emit Transfer(address(0), player, tokenId);
        nextTokenId++;
    }

    function getEquippedItemId(address player, uint256 unitId) external view returns (uint256) {
        return tokenItems[unitEquippedItems[player][unitId]];
    }

    function equipSingle(uint256 tokenId) public {
        require(tokenOwner[tokenId] == msg.sender);
        uint256 itemId = tokenItems[tokenId];
        uint256 unitId = itemList[itemId].unitId;

        // Remove item from user
        tokenOwner[tokenId] = 0;
        delete tokenApprovals[tokenId]; // Clear approval

        uint256 existingEquipment = unitEquippedItems[msg.sender][unitId];
        uint32[8] memory newItemGains = itemList[itemId].upgradeGains;
        
        if (existingEquipment == 0) {
            // Grant buff to unit
            units.increaseUpgradesExternal(msg.sender, unitId, newItemGains[0], newItemGains[1], newItemGains[2], newItemGains[3], newItemGains[4], newItemGains[5], newItemGains[6], newItemGains[7]);
        } else if (existingEquipment != tokenId) {
            uint256 existingItemId = tokenItems[existingEquipment];

            // Grant buff to unit
            units.swapUpgradesExternal(msg.sender, unitId, newItemGains, itemList[existingItemId].upgradeGains);

            // Return old item to user
            tokenOwner[existingEquipment] = msg.sender;
        }

        // Finally equip token (item)
        unitEquippedItems[msg.sender][unitId] = tokenId;
    }

    function unequipSingle(uint256 unitId) public {
        require(unitEquippedItems[msg.sender][unitId] > 0);

        uint256 tokenId = unitEquippedItems[msg.sender][unitId];
        require(tokenOwner[tokenId] == 0);

        uint256 itemId = tokenItems[tokenId];
        uint32[8] memory existingItemGains = itemList[itemId].upgradeGains;
        units.decreaseUpgradesExternal(msg.sender, unitId, existingItemGains[0], existingItemGains[1], existingItemGains[2], existingItemGains[3], existingItemGains[4], existingItemGains[5], existingItemGains[6], existingItemGains[7]);

        // Finally return item
        tokenOwner[tokenId] = msg.sender;
        unitEquippedItems[msg.sender][unitId] = 0;
    }

    function equipMultipleTokens(uint256[] tokens) external {
        for (uint256 i = 0; i < tokens.length; ++i) {
            equipSingle(tokens[i]);
        }
    }

    function unequipMultipleUnits(uint256[] unitIds) external {
        for (uint256 i = 0; i < unitIds.length; ++i) {
            unequipSingle(unitIds[i]);
        }
    }

    function addItem(uint256 itemId, uint256 unitId, uint256 rarity, uint32[8] upgradeGains) external {
        require(operator[msg.sender]);
        itemList[itemId] = Item(itemId, unitId, rarity, upgradeGains);
    }

    function validItem(uint256 itemId) internal constant returns (bool) {
        return itemList[itemId].itemId == itemId;
    }
    
    function getItemRarity(uint256 itemId) external view returns (uint256) {
        return itemList[itemId].rarity;
    }
}


contract Units {
    function increaseUpgradesExternal(address player, uint256 unitId, uint32 prodIncrease, uint32 prodMultiplier, uint32 attackIncrease, uint32 attackMultiplier, uint32 defenseIncrease, uint32 defenseMultiplier, uint32 lootingIncrease, uint32 lootingMultiplier) external;
    function decreaseUpgradesExternal(address player, uint256 unitId, uint32 prodIncrease, uint32 prodMultiplier, uint32 attackIncrease, uint32 attackMultiplier, uint32 defenseIncrease, uint32 defenseMultiplier, uint32 lootingIncrease, uint32 lootingMultiplier) external;
    function swapUpgradesExternal(address player, uint256 unitId, uint32[8] upgradeGains, uint32[8] upgradeLosses) external;
}



library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}