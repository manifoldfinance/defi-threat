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


contract Units {

    GooToken constant goo = GooToken(0xdf0960778c6e6597f197ed9a25f12f5d971da86c);
    Army army = Army(0x0);
    Clans clans = Clans(0x0);
    Factories constant factories = Factories(0xc81068cd335889736fc485592e4d73a82403d44b);

    mapping(address => mapping(uint256 => UnitsOwned)) public unitsOwned;
    mapping(address => mapping(uint256 => UnitExperience)) public unitExp;
    mapping(address => mapping(uint256 => uint256)) private unitMaxCap;

    mapping(address => mapping(uint256 => UnitUpgrades)) private unitUpgrades;
    mapping(address => mapping(uint256 => UpgradesOwned)) public upgradesOwned; // For each unitId, which upgrades owned (3 columns of uint64)

    mapping(uint256 => Unit) public unitList;
    mapping(uint256 => Upgrade) public upgradeList;
    mapping(address => bool) operator;

    address owner;

    constructor() public {
        owner = msg.sender;
    }

    struct UnitsOwned {
        uint80 units;
        uint8 factoryBuiltFlag; // Incase user sells units, we still want to keep factory
    }

    struct UnitExperience {
        uint224 experience;
        uint32 level;
    }

    struct UnitUpgrades {
        uint32 prodIncrease;
        uint32 prodMultiplier;

        uint32 attackIncrease;
        uint32 attackMultiplier;
        uint32 defenseIncrease;
        uint32 defenseMultiplier;
        uint32 lootingIncrease;
        uint32 lootingMultiplier;
    }

    struct UpgradesOwned {
        uint64 column0;
        uint64 column1;
        uint64 column2;
    }


    // Unit & Upgrade data:
    
    struct Unit {
        uint256 unitId;
        uint224 gooCost;
        uint256 baseProduction;
        uint80 attack;
        uint80 defense;
        uint80 looting;
    }

    struct Upgrade {
        uint256 upgradeId;
        uint224 gooCost;
        uint256 unitId;
        uint256 column; // Columns of upgrades (1st & 2nd are unit specific, then 3rd is capacity)
        uint256 prerequisiteUpgrade;

        uint256 unitMaxCapacityGain;
        uint32 prodIncrease;
        uint32 prodMultiplier;
        uint32 attackIncrease;
        uint32 attackMultiplier;
        uint32 defenseIncrease;
        uint32 defenseMultiplier;
        uint32 lootingIncrease;
        uint32 lootingMultiplier;
    }

    function setArmy(address armyContract) external {
        require(msg.sender == owner);
        army = Army(armyContract);
    }

    function setClans(address clansContract) external {
        require(msg.sender == owner);
        clans = Clans(clansContract);
    }

    function setOperator(address gameContract, bool isOperator) external {
        require(msg.sender == owner);
        operator[gameContract] = isOperator;
    }

    function mintUnitExternal(uint256 unit, uint80 amount, address player, uint8 chosenPosition) external {
        require(operator[msg.sender]);
        mintUnit(unit, amount, player, chosenPosition);
    }

    function mintUnit(uint256 unit, uint80 amount, address player, uint8 chosenPosition) internal {
        UnitsOwned storage existingUnits = unitsOwned[player][unit];
        if (existingUnits.factoryBuiltFlag == 0) {
            // Edge case to create factory for player (on empty tile) where it is their first unit
            uint256[] memory existingFactories = factories.getFactories(player);
            uint256 length = existingFactories.length;

            // Provided position is not valid so find valid factory position
            if (chosenPosition >= factories.MAX_SIZE() || (chosenPosition < length && existingFactories[chosenPosition] > 0)) {
                chosenPosition = 0;
                while (chosenPosition < length && existingFactories[chosenPosition] > 0) {
                    chosenPosition++;
                }
            }

            factories.addFactory(player, chosenPosition, unit);
            unitsOwned[player][unit] = UnitsOwned(amount, 1); // 1 = Flag to say factory exists
        } else {
            existingUnits.units += amount;
        }

        (uint80 attackStats, uint80 defenseStats, uint80 lootingStats) = getUnitsCurrentBattleStats(player, unit);
        if (attackStats > 0 || defenseStats > 0 || lootingStats > 0) {
            army.increasePlayersArmyPowerTrio(player, attackStats * amount, defenseStats * amount, lootingStats * amount);
        } else {
            uint256 prodIncrease = getUnitsCurrentProduction(player, unit) * amount;
            goo.increasePlayersGooProduction(player, prodIncrease / 100);
        }
    }


    function deleteUnitExternal(uint80 amount, uint256 unit, address player) external {
        require(operator[msg.sender]);
        deleteUnit(amount, unit, player);
    }

    function deleteUnit(uint80 amount, uint256 unit, address player) internal {
        (uint80 attackStats, uint80 defenseStats, uint80 lootingStats) = getUnitsCurrentBattleStats(player, unit);
        if (attackStats > 0 || defenseStats > 0 || lootingStats > 0) {
            army.decreasePlayersArmyPowerTrio(player, attackStats * amount, defenseStats * amount, lootingStats * amount);
        } else {
            uint256 prodDecrease = getUnitsCurrentProduction(player, unit) * amount;
            goo.decreasePlayersGooProduction(player, prodDecrease / 100);
        }
        unitsOwned[player][unit].units -= amount;
    }


    function getUnitsCurrentBattleStats(address player, uint256 unitId) internal view returns (uint80 attack, uint80 defense, uint80 looting) {
        Unit memory unit = unitList[unitId];
        UnitUpgrades memory existingUpgrades = unitUpgrades[player][unitId];
        attack = (unit.attack + existingUpgrades.attackIncrease) * (100 + existingUpgrades.attackMultiplier);
        defense = (unit.defense + existingUpgrades.defenseIncrease) * (100 + existingUpgrades.defenseMultiplier);
        looting = (unit.looting + existingUpgrades.lootingIncrease) * (100 + existingUpgrades.lootingMultiplier);
    }
    
    function getUnitsCurrentProduction(address player, uint256 unitId) public view returns (uint256) {
        UnitUpgrades memory existingUpgrades = unitUpgrades[player][unitId];
        return (unitList[unitId].baseProduction + existingUpgrades.prodIncrease) * (100 + existingUpgrades.prodMultiplier);
    }


    function buyUnit(uint256 unitId, uint80 amount, uint8 position) external {
        uint224 gooCost = SafeMath224.mul(unitList[unitId].gooCost, amount);
        require(gooCost > 0); // Valid unit

        uint80 newTotal = unitsOwned[msg.sender][unitId].units + amount;
        if (newTotal > 99) {
            require(newTotal < 99 + unitMaxCap[msg.sender][unitId]);
        }

        // Clan discount
        uint224 unitDiscount = clans.getPlayersClanUpgrade(msg.sender, 1); // class 1 = unit discount
        uint224 reducedGooCost = gooCost - ((gooCost * unitDiscount) / 100);
        uint224 seventyFivePercentRefund = (gooCost * 3) / 4;

        // Update players goo
        goo.updatePlayersGooFromPurchase(msg.sender, reducedGooCost);
        goo.mintGoo(seventyFivePercentRefund, this); // 75% refund is stored (in this contract) for when player sells unit
        army.depositSpentGoo(reducedGooCost - seventyFivePercentRefund); // Upto 25% Goo spent goes to divs (Remaining is discount + 75% player gets back when selling unit)
        mintUnit(unitId, amount, msg.sender, position);
    }


    function sellUnit(uint256 unitId, uint80 amount) external {
        require(unitsOwned[msg.sender][unitId].units >= amount && amount > 0);

        uint224 gooCost = unitList[unitId].gooCost;
        require(gooCost > 0);

        goo.updatePlayersGoo(msg.sender);
        deleteUnit(amount, unitId, msg.sender);
        goo.transfer(msg.sender, (gooCost * amount * 3) / 4); // Refund 75%
    }


    function grantArmyExp(address player, uint256 unitId, uint224 amount) external returns(bool) {
        require(operator[msg.sender]);

        UnitExperience memory existingExp = unitExp[player][unitId];
        uint224 expRequirement = (existingExp.level + 1) * 80; // Lvl 1: 80; Lvl 2: 160, Lvl 3: 240 (480 in total) etc.

        if (existingExp.experience + amount >= expRequirement) {
            existingExp.experience = (existingExp.experience + amount) - expRequirement;
            existingExp.level++;
            unitExp[player][unitId] = existingExp;

            // Grant buff to unit (5% additive multiplier)
            UnitUpgrades memory existingUpgrades = unitUpgrades[player][unitId];
            existingUpgrades.attackMultiplier += 5;
            existingUpgrades.defenseMultiplier += 5;
            existingUpgrades.lootingMultiplier += 5;
            unitUpgrades[player][unitId] = existingUpgrades;

            // Increase player's army power
            uint80 multiplierGain = unitsOwned[player][unitId].units * 5;

            Unit memory unit = unitList[unitId];
            uint80 attackGain = multiplierGain * (unit.attack + existingUpgrades.attackIncrease);
            uint80 defenseGain = multiplierGain * (unit.defense + existingUpgrades.defenseIncrease);
            uint80 lootingGain = multiplierGain * (unit.looting + existingUpgrades.lootingIncrease);
            army.increasePlayersArmyPowerTrio(player, attackGain, defenseGain, lootingGain);
            return true;
        } else {
            unitExp[player][unitId].experience += amount;
            return false;
        }
    }

    function increaseUnitCapacity(address player, uint256 upgradeGain, uint256 unitId) external {
        require(operator[msg.sender]);
        unitMaxCap[player][unitId] += upgradeGain;
    }

    function decreaseUnitCapacity(address player, uint256 upgradeGain, uint256 unitId) external {
        require(operator[msg.sender]);
        unitMaxCap[player][unitId] -= upgradeGain;
    }


    function increaseUpgradesExternal(address player, uint256 unitId, uint32 prodIncrease, uint32 prodMultiplier, uint32 attackIncrease, uint32 attackMultiplier, uint32 defenseIncrease, uint32 defenseMultiplier, uint32 lootingIncrease, uint32 lootingMultiplier) external {
        require(operator[msg.sender]);
        Upgrade memory upgrade = Upgrade(0,0,0,0,0,0, prodIncrease, prodMultiplier, attackIncrease, attackMultiplier, defenseIncrease, defenseMultiplier, lootingIncrease, lootingMultiplier);
        increaseUpgrades(player, upgrade, unitId);
    }


    function increaseUpgrades(address player, Upgrade upgrade, uint256 unitId) internal {
        uint80 units = unitsOwned[player][unitId].units;
        UnitUpgrades memory existingUpgrades = unitUpgrades[player][unitId];

        Unit memory unit = unitList[unitId];
        if (unit.baseProduction > 0) {
            // Increase goo production
            uint256 prodGain = units * upgrade.prodMultiplier * (unit.baseProduction + existingUpgrades.prodIncrease); // Multiplier gains
            prodGain += units * upgrade.prodIncrease * (100 + existingUpgrades.prodMultiplier); // Base prod gains

            goo.updatePlayersGoo(player);
            goo.increasePlayersGooProduction(player, prodGain / 100);
        } else {
            // Increase army power
            uint80 attackGain = units * upgrade.attackMultiplier * (unit.attack + existingUpgrades.attackIncrease); // Multiplier gains
            uint80 defenseGain = units * upgrade.defenseMultiplier * (unit.defense + existingUpgrades.defenseIncrease); // Multiplier gains
            uint80 lootingGain = units * upgrade.lootingMultiplier * (unit.looting + existingUpgrades.lootingIncrease); // Multiplier gains

            attackGain += units * upgrade.attackIncrease * (100 + existingUpgrades.attackMultiplier); // + Base gains
            defenseGain += units * upgrade.defenseIncrease * (100 + existingUpgrades.defenseMultiplier); // + Base gains
            lootingGain += units * upgrade.lootingIncrease * (100 + existingUpgrades.lootingMultiplier); // + Base gains

            army.increasePlayersArmyPowerTrio(player, attackGain, defenseGain, lootingGain);
        }

        existingUpgrades.prodIncrease += upgrade.prodIncrease;
        existingUpgrades.prodMultiplier += upgrade.prodMultiplier;
        existingUpgrades.attackIncrease += upgrade.attackIncrease;
        existingUpgrades.attackMultiplier += upgrade.attackMultiplier;
        existingUpgrades.defenseIncrease += upgrade.defenseIncrease;
        existingUpgrades.defenseMultiplier += upgrade.defenseMultiplier;
        existingUpgrades.lootingIncrease += upgrade.lootingIncrease;
        existingUpgrades.lootingMultiplier += upgrade.lootingMultiplier;
        unitUpgrades[player][unitId] = existingUpgrades;
    }


    function decreaseUpgradesExternal(address player, uint256 unitId, uint32 prodIncrease, uint32 prodMultiplier, uint32 attackIncrease, uint32 attackMultiplier, uint32 defenseIncrease, uint32 defenseMultiplier, uint32 lootingIncrease, uint32 lootingMultiplier) external {
        require(operator[msg.sender]);
        Upgrade memory upgrade = Upgrade(0,0,0,0,0,0, prodIncrease, prodMultiplier, attackIncrease, attackMultiplier, defenseIncrease, defenseMultiplier, lootingIncrease, lootingMultiplier);
        decreaseUpgrades(player, upgrade, unitId);
    }


    function decreaseUpgrades(address player, Upgrade upgrade, uint256 unitId) internal {
        uint80 units = unitsOwned[player][unitId].units;
        UnitUpgrades memory existingUpgrades = unitUpgrades[player][unitId];

        Unit memory unit = unitList[unitId];
        if (unit.baseProduction > 0) {
            // Decrease goo production
            uint256 prodLoss = units * upgrade.prodMultiplier * (unit.baseProduction + existingUpgrades.prodIncrease); // Multiplier losses
            prodLoss += units * upgrade.prodIncrease * (100 + existingUpgrades.prodMultiplier); // Base prod losses

            goo.updatePlayersGoo(player);
            goo.decreasePlayersGooProduction(player, prodLoss / 100);
        } else {
            // Decrease army power
            uint80 attackLoss = units * upgrade.attackMultiplier * (unit.attack + existingUpgrades.attackIncrease); // Multiplier losses
            uint80 defenseLoss = units * upgrade.defenseMultiplier * (unit.defense + existingUpgrades.defenseIncrease); // Multiplier losses
            uint80 lootingLoss = units * upgrade.lootingMultiplier * (unit.looting + existingUpgrades.lootingIncrease); // Multiplier losses

            attackLoss += units * upgrade.attackIncrease * (100 + existingUpgrades.attackMultiplier); // + Base losses
            defenseLoss += units * upgrade.defenseIncrease * (100 + existingUpgrades.defenseMultiplier); // + Base losses
            lootingLoss += units * upgrade.lootingIncrease * (100 + existingUpgrades.lootingMultiplier); // + Base losses
            army.decreasePlayersArmyPowerTrio(player, attackLoss, defenseLoss, lootingLoss);
        }

        existingUpgrades.prodIncrease -= upgrade.prodIncrease;
        existingUpgrades.prodMultiplier -= upgrade.prodMultiplier;
        existingUpgrades.attackIncrease -= upgrade.attackIncrease;
        existingUpgrades.attackMultiplier -= upgrade.attackMultiplier;
        existingUpgrades.defenseIncrease -= upgrade.defenseIncrease;
        existingUpgrades.defenseMultiplier -= upgrade.defenseMultiplier;
        existingUpgrades.lootingIncrease -= upgrade.lootingIncrease;
        existingUpgrades.lootingMultiplier -= upgrade.lootingMultiplier;
        unitUpgrades[player][unitId] = existingUpgrades;
    }

    function swapUpgradesExternal(address player, uint256 unitId, uint32[8] upgradeGains, uint32[8] upgradeLosses) external {
        require(operator[msg.sender]);

        UnitUpgrades memory existingUpgrades = unitUpgrades[player][unitId];
        Unit memory unit = unitList[unitId];

        if (unit.baseProduction > 0) {
            // Change goo production
            gooProductionChange(player, unitId, existingUpgrades, unit.baseProduction, upgradeGains, upgradeLosses);
        } else {
            // Change army power
            armyPowerChange(player, existingUpgrades, unit, upgradeGains, upgradeLosses);
        }
    }
    
    function armyPowerChange(address player, UnitUpgrades existingUpgrades, Unit unit, uint32[8] upgradeGains, uint32[8] upgradeLosses) internal {
        int256 existingAttack = int256((unit.attack + existingUpgrades.attackIncrease) * (100 + existingUpgrades.attackMultiplier));
        int256 existingDefense = int256((unit.defense + existingUpgrades.defenseIncrease) * (100 + existingUpgrades.defenseMultiplier));
        int256 existingLooting = int256((unit.looting + existingUpgrades.lootingIncrease) * (100 + existingUpgrades.lootingMultiplier));
    
        existingUpgrades.attackIncrease = uint32(int(existingUpgrades.attackIncrease) + (int32(upgradeGains[2]) - int32(upgradeLosses[2])));
        existingUpgrades.attackMultiplier = uint32(int(existingUpgrades.attackMultiplier) + (int32(upgradeGains[3]) - int32(upgradeLosses[3])));
        existingUpgrades.defenseIncrease = uint32(int(existingUpgrades.defenseIncrease) + (int32(upgradeGains[4]) - int32(upgradeLosses[4])));
        existingUpgrades.defenseMultiplier = uint32(int(existingUpgrades.defenseMultiplier) + (int32(upgradeGains[5]) - int32(upgradeLosses[5])));
        existingUpgrades.lootingIncrease = uint32(int(existingUpgrades.lootingIncrease) + (int32(upgradeGains[6]) - int32(upgradeLosses[6])));
        existingUpgrades.lootingMultiplier = uint32(int(existingUpgrades.lootingMultiplier) + (int32(upgradeGains[7]) - int32(upgradeLosses[7])));
        
        int256 attackChange = ((int256(unit.attack) + existingUpgrades.attackIncrease) * (100 + existingUpgrades.attackMultiplier)) - existingAttack;
        int256 defenseChange = ((int256(unit.defense) + existingUpgrades.defenseIncrease) * (100 + existingUpgrades.defenseMultiplier)) - existingDefense;
        int256 lootingChange = ((int256(unit.looting) + existingUpgrades.lootingIncrease) * (100 + existingUpgrades.lootingMultiplier)) - existingLooting;
        
        uint256 unitId = unit.unitId;
        int256 units = int256(unitsOwned[player][unitId].units);
        
        army.changePlayersArmyPowerTrio(player, units * attackChange, units * defenseChange, units * lootingChange);
        unitUpgrades[player][unitId] = existingUpgrades;
    }
    
    function gooProductionChange(address player, uint256 unitId, UnitUpgrades existingUpgrades, uint256 baseProduction, uint32[8] upgradeGains, uint32[8] upgradeLosses) internal {
        goo.updatePlayersGoo(player);
        
        int256 existingProd = int256((baseProduction + existingUpgrades.prodIncrease) * (100 + existingUpgrades.prodMultiplier));
        existingUpgrades.prodIncrease = uint32(int(existingUpgrades.prodIncrease) + (int32(upgradeGains[0]) - int32(upgradeLosses[0])));
        existingUpgrades.prodMultiplier = uint32(int(existingUpgrades.prodMultiplier) + (int32(upgradeGains[1]) - int32(upgradeLosses[1])));            
        
        int256 prodChange = ((int256(baseProduction) + existingUpgrades.prodIncrease) * (100 + existingUpgrades.prodMultiplier)) - existingProd;
        if (prodChange > 0) {
            goo.increasePlayersGooProduction(player, (unitsOwned[player][unitId].units * uint256(prodChange)) / 100);
        } else {
            goo.decreasePlayersGooProduction(player, (unitsOwned[player][unitId].units * uint256(-prodChange)) / 100);
        }
        
        unitUpgrades[player][unitId] = existingUpgrades;
    }

    function addUnit(uint256 id, uint224 baseGooCost, uint256 baseGooProduction, uint80 baseAttack, uint80 baseDefense, uint80 baseLooting) external {
        require(operator[msg.sender]);
        unitList[id] = Unit(id, baseGooCost, baseGooProduction, baseAttack, baseDefense, baseLooting);
    }


    function addUpgrade(uint256 id, uint224 gooCost, uint256 unit, uint256 column, uint256 prereq, uint256 unitMaxCapacityGain, uint32[8] upgradeGains) external {
        require(operator[msg.sender]);
        upgradeList[id] = Upgrade(id, gooCost, unit, column, prereq, unitMaxCapacityGain, upgradeGains[0], upgradeGains[1], upgradeGains[2], upgradeGains[3], upgradeGains[4], upgradeGains[5], upgradeGains[6], upgradeGains[7]);
    }

    function buyUpgrade(uint64 upgradeId) external {
        Upgrade memory upgrade = upgradeList[upgradeId];
        uint256 unitId = upgrade.unitId;
        UpgradesOwned memory ownedUpgrades = upgradesOwned[msg.sender][unitId];

        uint64 latestUpgradeOwnedForColumn;
        if (upgrade.column == 0) {
            latestUpgradeOwnedForColumn = ownedUpgrades.column0;
            ownedUpgrades.column0 = upgradeId;  // Update upgradesOwned
        } else if (upgrade.column == 1) {
            latestUpgradeOwnedForColumn = ownedUpgrades.column1;
            ownedUpgrades.column1 = upgradeId;  // Update upgradesOwned
        } else if (upgrade.column == 2) {
            latestUpgradeOwnedForColumn = ownedUpgrades.column2;
            ownedUpgrades.column2 = upgradeId;  // Update upgradesOwned
        }
        upgradesOwned[msg.sender][unitId] = ownedUpgrades;

        require(unitId > 0); // Valid upgrade
        require(latestUpgradeOwnedForColumn < upgradeId); // Haven't already purchased
        require(latestUpgradeOwnedForColumn >= upgrade.prerequisiteUpgrade); // Own prequisite

        // Clan discount
        uint224 upgradeDiscount = clans.getPlayersClanUpgrade(msg.sender, 0); // class 0 = upgrade discount
        uint224 reducedUpgradeCost = upgrade.gooCost - ((upgrade.gooCost * upgradeDiscount) / 100);

        // Update players goo
        goo.updatePlayersGooFromPurchase(msg.sender, reducedUpgradeCost);
        army.depositSpentGoo(reducedUpgradeCost); // Transfer to goo bankroll

        // Update stats for upgrade
        if (upgrade.column == 2) {
            unitMaxCap[msg.sender][unitId] += upgrade.unitMaxCapacityGain;
        } else if (upgrade.column == 1) {
            increaseUpgrades(msg.sender, upgrade, unitId);
        } else if (upgrade.column == 0) {
            increaseUpgrades(msg.sender, upgrade, unitId);
        }
    }

}




contract GooToken {
    function transfer(address to, uint256 tokens) external returns (bool);
    function increasePlayersGooProduction(address player, uint256 increase) external;
    function decreasePlayersGooProduction(address player, uint256 decrease) external;
    function updatePlayersGooFromPurchase(address player, uint224 purchaseCost) external;
    function updatePlayersGoo(address player) external;
    function mintGoo(uint224 amount, address player) external;
}

contract Army {
    function depositSpentGoo(uint224 gooSpent) external;
    function increasePlayersArmyPowerTrio(address player, uint80 attackGain, uint80 defenseGain, uint80 lootingGain) public;
    function decreasePlayersArmyPowerTrio(address player, uint80 attackLoss, uint80 defenseLoss, uint80 lootingLoss) public;
    function changePlayersArmyPowerTrio(address player, int attackChange, int defenseChange, int lootingChange) public;

}

contract Clans {
    mapping(uint256 => uint256) public clanTotalArmyPower;
    function totalSupply() external view returns (uint256);
    function depositGoo(uint256 amount, uint256 clanId) external;
    function getPlayerFees(address player) external view returns (uint224 clansFee, uint224 leadersFee, address leader, uint224 referalsFee, address referer);
    function getPlayersClanUpgrade(address player, uint256 upgradeClass) external view returns (uint224 upgradeGain);
    function mintGoo(address player, uint256 amount) external;
    function increaseClanPower(address player, uint256 amount) external;
    function decreaseClanPower(address player, uint256 amount) external;
}

contract Factories {
    uint256 public constant MAX_SIZE = 40;
    function getFactories(address player) external returns (uint256[]);
    function addFactory(address player, uint8 position, uint256 unitId) external;
}


library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint224 a, uint224 b) internal pure returns (uint224) {
    if (a == 0) {
      return 0;
    }
    uint224 c = a * b;
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


library SafeMath224 {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint224 a, uint224 b) internal pure returns (uint224) {
    if (a == 0) {
      return 0;
    }
    uint224 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint224 a, uint224 b) internal pure returns (uint224) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint224 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint224 a, uint224 b) internal pure returns (uint224) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint224 a, uint224 b) internal pure returns (uint224) {
    uint224 c = a + b;
    assert(c >= a);
    return c;
  }
}