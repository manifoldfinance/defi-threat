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

contract Army {

    GooToken constant goo = GooToken(0xdf0960778c6e6597f197ed9a25f12f5d971da86c);
    Clans clans = Clans(0x0);

    uint224 public totalArmyPower; // Global power of players (attack + defence)
    uint224 public gooBankroll; // Goo dividends to be split over time between clans/players' army power
    uint256 public nextSnapshotTime;
    address public owner; // Minor management of game

    mapping(address => mapping(uint256 => ArmyPower)) public armyPowerSnapshots; // Store player's army power for given day (snapshot)
    mapping(address => mapping(uint256 => bool)) public armyPowerZeroedSnapshots; // Edgecase to determine difference between 0 army and an unused/inactive day.
    mapping(address => uint256) public lastWarFundClaim; // Days (snapshot number)
    mapping(address => uint256) public lastArmyPowerUpdate; // Days (last snapshot) player's army was updated
    mapping(address => bool) operator;

    uint224[] public totalArmyPowerSnapshots; // The total player army power for each prior day past
    uint224[] public allocatedWarFundSnapshots; // Div pot (goo allocated to each prior day past)
    
    uint224 public playerDivPercent = 2;
    uint224 public clanDivPercent = 2;

    struct ArmyPower {
        uint80 attack;
        uint80 defense;
        uint80 looting;
    }

    constructor(uint256 firstSnapshotTime) public {
        nextSnapshotTime = firstSnapshotTime;
        owner = msg.sender;
    }

    function setClans(address clansContract) external {
        require(msg.sender == owner);
        clans = Clans(clansContract);
    }

    function setOperator(address gameContract, bool isOperator) external {
        require(msg.sender == owner);
        operator[gameContract] = isOperator;
    }
    
    function updateDailyDivPercents(uint224 newPlayersPercent, uint224 newClansPercent) external {
        require(msg.sender == owner);
        require(newPlayersPercent > 0 && newPlayersPercent <= 10); // 1-10% daily
        require(newClansPercent > 0 && newClansPercent <= 10); // 1-10% daily
        playerDivPercent = newPlayersPercent;
        clanDivPercent = newClansPercent;
    }

    function depositSpentGoo(uint224 gooSpent) external {
        require(operator[msg.sender]);
        gooBankroll += gooSpent;
    }

    function getArmyPower(address player) external view returns (uint80, uint80, uint80) {
        ArmyPower memory armyPower = armyPowerSnapshots[player][lastArmyPowerUpdate[player]];
        return (armyPower.attack, armyPower.defense, armyPower.looting);
    }
    
    // Convenience function 
    function getArmiesPower(address player, address target) external view returns (uint80 playersAttack, uint80 playersLooting, uint80 targetsDefense) {
        ArmyPower memory armyPower = armyPowerSnapshots[player][lastArmyPowerUpdate[player]];
        playersAttack = armyPower.attack;
        playersLooting = armyPower.looting;
        targetsDefense = armyPowerSnapshots[target][lastArmyPowerUpdate[target]].defense;
    }

    function increasePlayersArmyPowerTrio(address player, uint80 attackGain, uint80 defenseGain, uint80 lootingGain) public {
        require(operator[msg.sender]);

        ArmyPower memory existingArmyPower = armyPowerSnapshots[player][lastArmyPowerUpdate[player]];
        uint256 snapshotDay = allocatedWarFundSnapshots.length;

        // Adjust army power (reusing struct)
        existingArmyPower.attack += attackGain;
        existingArmyPower.defense += defenseGain;
        existingArmyPower.looting += lootingGain;
        armyPowerSnapshots[player][snapshotDay] = existingArmyPower;

        if (lastArmyPowerUpdate[player] != snapshotDay) {
            lastArmyPowerUpdate[player] = snapshotDay;
        }
        
        totalArmyPower += (attackGain + defenseGain);
        clans.increaseClanPower(player, attackGain + defenseGain);
    }

    function decreasePlayersArmyPowerTrio(address player, uint80 attackLoss, uint80 defenseLoss, uint80 lootingLoss) public {
        require(operator[msg.sender]);

        ArmyPower memory existingArmyPower = armyPowerSnapshots[player][lastArmyPowerUpdate[player]];
        uint256 snapshotDay = allocatedWarFundSnapshots.length;

        // Adjust army power (reusing struct)
        existingArmyPower.attack -= attackLoss;
        existingArmyPower.defense -= defenseLoss;
        existingArmyPower.looting -= lootingLoss;

        if (existingArmyPower.attack == 0 && existingArmyPower.defense == 0) { // Special case which tangles with "inactive day" snapshots (claiming divs)
            armyPowerZeroedSnapshots[player][snapshotDay] = true;
            delete armyPowerSnapshots[player][snapshotDay]; // 0
        } else {
            armyPowerSnapshots[player][snapshotDay] = existingArmyPower;
        }
        
        if (lastArmyPowerUpdate[player] != snapshotDay) {
            lastArmyPowerUpdate[player] = snapshotDay;
        }

        totalArmyPower -= (attackLoss + defenseLoss);
        clans.decreaseClanPower(player, attackLoss + defenseLoss);
    }

    function changePlayersArmyPowerTrio(address player, int attackChange, int defenseChange, int lootingChange) public {
        require(operator[msg.sender]);

        ArmyPower memory existingArmyPower = armyPowerSnapshots[player][lastArmyPowerUpdate[player]];
        uint256 snapshotDay = allocatedWarFundSnapshots.length;

        // Allow change to be positive or negative
        existingArmyPower.attack = uint80(int(existingArmyPower.attack) + attackChange);
        existingArmyPower.defense = uint80(int(existingArmyPower.defense) + defenseChange);
        existingArmyPower.looting = uint80(int(existingArmyPower.looting) + lootingChange);

        if (existingArmyPower.attack == 0 && existingArmyPower.defense == 0) { // Special case which tangles with "inactive day" snapshots (claiming divs)
            armyPowerZeroedSnapshots[player][snapshotDay] = true;
            delete armyPowerSnapshots[player][snapshotDay]; // 0
        } else {
            armyPowerSnapshots[player][snapshotDay] = existingArmyPower;
        }

        if (lastArmyPowerUpdate[player] != snapshotDay) {
            lastArmyPowerUpdate[player] = snapshotDay;
        }
        changeTotalArmyPower(player, attackChange, defenseChange);
    }

    function changeTotalArmyPower(address player, int attackChange, int defenseChange) internal {
        uint224 newTotal = uint224(int(totalArmyPower) + attackChange + defenseChange);

        if (newTotal > totalArmyPower) {
            clans.increaseClanPower(player, newTotal - totalArmyPower);
        } else if (newTotal < totalArmyPower) {
            clans.decreaseClanPower(player, totalArmyPower - newTotal);
        }
        totalArmyPower = newTotal;
    }

    // Allocate army power divs for the day (00:00 cron job)
    function snapshotDailyWarFunding() external {
        require(msg.sender == owner);
        require(now + 6 hours > nextSnapshotTime);

        totalArmyPowerSnapshots.push(totalArmyPower);
        allocatedWarFundSnapshots.push((gooBankroll * playerDivPercent) / 100);
        uint256 allocatedClanWarFund = (gooBankroll * clanDivPercent) / 100; // No daily snapshots needed for Clans (as below will also claim between the handful of clans)
        gooBankroll -= (gooBankroll * (playerDivPercent + clanDivPercent)) / 100;  // % of pool daily

        uint256 numClans = clans.totalSupply();
        uint256[] memory clanArmyPower = new uint256[](numClans);

        // Get total power from all clans
        uint256 todaysTotalClanPower;
        for (uint256 i = 1; i <= numClans; i++) {
            clanArmyPower[i-1] = clans.clanTotalArmyPower(i);
            todaysTotalClanPower += clanArmyPower[i-1];
        }

        // Distribute goo divs to clans based on their relative power
        for (i = 1; i <= numClans; i++) {
            clans.depositGoo((allocatedClanWarFund * clanArmyPower[i-1]) / todaysTotalClanPower, i);
        }

        nextSnapshotTime = now + 24 hours;
    }

    function claimWarFundDividends(uint256 startSnapshot, uint256 endSnapShot) external {
        require(startSnapshot <= endSnapShot);
        require(startSnapshot >= lastWarFundClaim[msg.sender]);
        require(endSnapShot < allocatedWarFundSnapshots.length);

        uint224 gooShare;
        ArmyPower memory previousArmyPower = armyPowerSnapshots[msg.sender][lastWarFundClaim[msg.sender] - 1]; // Underflow won't be a problem as armyPowerSnapshots[][0xffffffff] = 0;
        for (uint256 i = startSnapshot; i <= endSnapShot; i++) {

            // Slightly complex things by accounting for days/snapshots when user made no tx's
            ArmyPower memory armyPowerDuringSnapshot = armyPowerSnapshots[msg.sender][i];
            bool soldAllArmy = armyPowerZeroedSnapshots[msg.sender][i];
            if (!soldAllArmy && armyPowerDuringSnapshot.attack == 0 && armyPowerDuringSnapshot.defense == 0) {
                armyPowerDuringSnapshot = previousArmyPower;
            } else {
               previousArmyPower = armyPowerDuringSnapshot;
            }

            gooShare += (allocatedWarFundSnapshots[i] * (armyPowerDuringSnapshot.attack + armyPowerDuringSnapshot.defense)) / totalArmyPowerSnapshots[i];
        }


        ArmyPower memory endSnapshotArmyPower = armyPowerSnapshots[msg.sender][endSnapShot];
        if (endSnapshotArmyPower.attack == 0 && endSnapshotArmyPower.defense == 0 && !armyPowerZeroedSnapshots[msg.sender][endSnapShot] && (previousArmyPower.attack + previousArmyPower.defense) > 0) {
            armyPowerSnapshots[msg.sender][endSnapShot] = previousArmyPower; // Checkpoint for next claim
        }

        lastWarFundClaim[msg.sender] = endSnapShot + 1;

        (uint224 clanFee, uint224 leaderFee, address leader, uint224 referalFee, address referer) = clans.getPlayerFees(msg.sender);
        if (clanFee > 0) {
            clanFee = (gooShare * clanFee) / 100; // Convert from percent to goo
            leaderFee = (gooShare * leaderFee) / 100; // Convert from percent to goo
            clans.mintGoo(msg.sender, clanFee);
            goo.mintGoo(leaderFee, leader);
        }
        if (referer == address(0)) {
            referalFee = 0;
        } else if (referalFee > 0) {
            referalFee = (gooShare * referalFee) / 100; // Convert from percent to goo
            goo.mintGoo(referalFee, referer);
        }
        
        goo.mintGoo(gooShare - (clanFee + leaderFee + referalFee), msg.sender);
    }

    function getSnapshotDay() external view returns (uint256 snapshot) {
        snapshot = allocatedWarFundSnapshots.length;
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