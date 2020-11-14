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

contract Crafting {

    Clans clans = Clans(0x0);
    Inventory constant inventory = Inventory(0xb545507080b0f63df02ff9bd9302c2bb2447b826);
    Material constant clothMaterial = Material(0x8a6014227138556a259e7b2bf1dce668f9bdfd06);
    Material constant woodMaterial = Material(0x6804bbb708b8af0851e2980c8a5e9abb42adb179);
    Material constant metalMaterial = Material(0xb334f68bf47c1f1c1556e7034954d389d7fbbf07);

    address owner;
    mapping(uint256 => Recipe) public recipeList;
    mapping(address => bool) operator;

    struct Recipe {
        uint256 id;
        uint256 itemId;

        uint256 clothRequired;
        uint256 woodRequired;
        uint256 metalRequired;
    }

    constructor() public {
        owner = msg.sender;
    }

    function setClans(address clansContract) external {
        require(msg.sender == owner); // TODO hardcode for launch?
        clans = Clans(clansContract);
    }

    function setOperator(address gameContract, bool isOperator) external {
        require(msg.sender == owner);
        operator[gameContract] = isOperator;
    }

    function craftItem(uint256 recipeId) external {
        Recipe memory recipe = recipeList[recipeId];
        require(recipe.itemId > 0); // Valid recipe

        // Clan discount
        uint224 upgradeDiscount = clans.getPlayersClanUpgrade(msg.sender, 2); // class 2 = crafting discount

        // Burn materials
        if (recipe.clothRequired > 0) {
            clothMaterial.burn(recipe.clothRequired - ((recipe.clothRequired * upgradeDiscount) / 100), msg.sender);
        }
        if (recipe.woodRequired > 0) {
            woodMaterial.burn(recipe.woodRequired - ((recipe.woodRequired * upgradeDiscount) / 100), msg.sender);
        }
        if (recipe.metalRequired > 0) {
            metalMaterial.burn(recipe.metalRequired - ((recipe.metalRequired * upgradeDiscount) / 100), msg.sender);
        }

        // Mint item
        inventory.mintItem(recipe.itemId, msg.sender);
    }

    function addRecipe(uint256 id, uint256 itemId, uint256 clothRequired, uint256 woodRequired, uint256 metalRequired) external {
        require(operator[msg.sender]);
        recipeList[id] = Recipe(id, itemId, clothRequired, woodRequired, metalRequired);
    }

}


contract Clans {
    function getPlayersClanUpgrade(address player, uint256 upgradeClass) external view returns (uint224 upgradeGain);
}

contract Inventory {
    function mintItem(uint256 itemId, address player) external;
}

contract Material {
    function burn(uint256 amount, address player) public;
}