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

contract Factories {

    GooToken constant goo = GooToken(0xdf0960778c6e6597f197ed9a25f12f5d971da86c);
    Units units = Units(0x0);
    Inventory inventory = Inventory(0x0);

    mapping(address => uint256[]) private playerFactories;
    mapping(uint256 => mapping(uint256 => uint32[8])) public tileBonuses; // Tile -> UnitId -> Bonus
    mapping(address => bool) operator;

    address owner; // Minor management
    uint256 public constant MAX_SIZE = 40;

    constructor() public {
        owner = msg.sender;
    }

    function setUnits(address unitsContract) external {
        require(msg.sender == owner); // TODO hardcode for launch?
        units = Units(unitsContract);
    }

    function setInventory(address inventoryContract) external {
        require(msg.sender == owner); // TODO hardcode for launch?
        inventory = Inventory(inventoryContract);
    }

    function setOperator(address gameContract, bool isOperator) external {
        require(msg.sender == owner);
        operator[gameContract] = isOperator;
    }

    function getFactories(address player) external view returns (uint256[]) {
        return playerFactories[player];
    }

    // For website
    function getPlayersUnits(address player) external view returns (uint256[], uint80[], uint224[], uint32[], uint256[]) {
        uint80[] memory unitsOwnedByFactory = new uint80[](playerFactories[player].length);
        uint224[] memory unitsExperience = new uint224[](playerFactories[player].length);
        uint32[] memory unitsLevel = new uint32[](playerFactories[player].length);
        uint256[] memory unitsEquipment = new uint256[](playerFactories[player].length);

        for (uint256 i = 0; i < playerFactories[player].length; i++) {
            (unitsOwnedByFactory[i],) = units.unitsOwned(player, playerFactories[player][i]);
            (unitsExperience[i], unitsLevel[i]) = units.unitExp(player, playerFactories[player][i]);
            unitsEquipment[i] = inventory.getEquippedItemId(player, playerFactories[player][i]);
        }

        return (playerFactories[player], unitsOwnedByFactory, unitsExperience, unitsLevel, unitsEquipment);
    }

    function addFactory(address player, uint8 position, uint256 unitId) external {
        require(position < MAX_SIZE);
        require(msg.sender == address(units));

        uint256[] storage factories = playerFactories[player];
        if (factories.length > position) {
            require(factories[position] == 0); // Empty space
        } else {
            factories.length = position + 1; // Make space
        }
        factories[position] = unitId;

        // Grant buff to unit
        uint32[8] memory upgradeGains = tileBonuses[getAddressDigit(player, position)][unitId];
        if (upgradeGains[0] > 0 || upgradeGains[1] > 0 || upgradeGains[2] > 0 || upgradeGains[3] > 0 || upgradeGains[4] > 0 || upgradeGains[5] > 0 || upgradeGains[6] > 0 || upgradeGains[7] > 0) {
            units.increaseUpgradesExternal(player, unitId, upgradeGains[0], upgradeGains[1], upgradeGains[2], upgradeGains[3], upgradeGains[4], upgradeGains[5], upgradeGains[6], upgradeGains[7]);
        }
    }

    function moveFactory(uint8 position, uint8 newPosition) external {
        require(newPosition < MAX_SIZE);

        uint256[] storage factories = playerFactories[msg.sender];
        uint256 existingFactory = factories[position];
        require(existingFactory > 0); // Existing factory

        if (factories.length > newPosition) {
            require(factories[newPosition] == 0); // Empty space
        } else {
            factories.length = newPosition + 1; // Make space
        }

        factories[newPosition] = existingFactory;
        delete factories[position];

        uint32[8] memory newBonus = tileBonuses[getAddressDigit(msg.sender, newPosition)][existingFactory];
        uint32[8] memory oldBonus = tileBonuses[getAddressDigit(msg.sender, position)][existingFactory];
        units.swapUpgradesExternal(msg.sender, existingFactory, newBonus, oldBonus);
    }

    function getAddressDigit(address player, uint8 position) public pure returns (uint) {
        return (uint(player) >> (156 - position * 4)) & 0x0f;
    }

    function addTileBonus(uint256 tile, uint256 unit, uint32[8] upgradeGains) external {
        require(operator[msg.sender]);
        tileBonuses[tile][unit] = upgradeGains;
    }

}



contract GooToken {
    function updatePlayersGoo(address player) external;
    function increasePlayersGooProduction(address player, uint256 increase) external;
}

contract Units {
    mapping(address => mapping(uint256 => UnitsOwned)) public unitsOwned;
    mapping(address => mapping(uint256 => UnitExperience)) public unitExp;
    function increaseUpgradesExternal(address player, uint256 unitId, uint32 prodIncrease, uint32 prodMultiplier, uint32 attackIncrease, uint32 attackMultiplier, uint32 defenseIncrease, uint32 defenseMultiplier, uint32 lootingIncrease, uint32 lootingMultiplier) external;
    function swapUpgradesExternal(address player, uint256 unitId, uint32[8] upgradeGains, uint32[8] upgradeLosses) external;
    
    struct UnitsOwned {
        uint80 units;
        uint8 factoryBuiltFlag; // Incase user sells units, we still want to keep factory
    }
    
    struct UnitExperience {
        uint224 experience;
        uint32 level;
    }
}

contract Inventory {
    function getEquippedItemId(address player, uint256 unitId) external view returns (uint256);
}