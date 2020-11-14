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

interface ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) external;
}


contract Clans is ERC721, ApproveAndCallFallBack {
    using SafeMath for uint256;

    GooToken constant goo = GooToken(0xdf0960778c6e6597f197ed9a25f12f5d971da86c);
    Army constant army = Army(0x98278eb74b388efd4d6fc81dd3f95b642ce53f2b);
    WWGClanCoupons constant clanCoupons = WWGClanCoupons(0xe9fe4e530ebae235877289bd978f207ae0c8bb25); // For minting clans to initial owners (prelaunch buyers)

    string public constant name = "Goo Clan";
    string public constant symbol = "GOOCLAN";
    uint224 numClans;
    address owner; // Minor management

    // ERC721 stuff
    mapping (uint256 => address) public tokenOwner;
    mapping (uint256 => address) public tokenApprovals;
    mapping (address => uint256[]) public ownedTokens;
    mapping(uint256 => uint256) public ownedTokensIndex;

    mapping(address => UserClan) public userClan;
    mapping(uint256 => uint224) public clanFee;
    mapping(uint256 => uint224) public leaderFee;
    mapping(uint256 => uint256) public clanMembers;
    mapping(uint256 => mapping(uint256 => uint224)) public clanUpgradesOwned;
    mapping(uint256 => uint256) public clanGoo;
    mapping(uint256 => address) public clanToken; // i.e. BNB
    mapping(uint256 => uint256) public baseTokenDenomination; // base value for token gains i.e. 0.000001 BNB
    mapping(uint256 => uint256) public clanTotalArmyPower;

    mapping(uint256 => uint224) public referalFee; // If invited to a clan how much % of player's divs go to referer
    mapping(address => mapping(uint256 => address)) public clanReferer; // Address of who invited player to each clan

    mapping(uint256 => Upgrade) public upgradeList;
    mapping(address => bool) operator;

    struct UserClan {
        uint224 clanId;
        uint32 clanJoinTime;
    }

    struct Upgrade {
        uint256 upgradeId;
        uint224 gooCost;
        uint224 upgradeGain;
        uint256 upgradeClass;
        uint256 prerequisiteUpgrade;
    }

    // Events
    event JoinedClan(uint256 clanId, address player, address referer);
    event LeftClan(uint256 clanId, address player);

    constructor() public {
        owner = msg.sender;
    }

    function setOperator(address gameContract, bool isOperator) external {
        require(msg.sender == owner);
        operator[gameContract] = isOperator;
    }

    function totalSupply() external view returns (uint256) {
        return numClans;
    }

    function balanceOf(address player) public view returns (uint256) {
        return ownedTokens[player].length;
    }

    function ownerOf(uint256 clanId) external view returns (address) {
        return tokenOwner[clanId];
    }

    function exists(uint256 clanId) public view returns (bool) {
        return tokenOwner[clanId] != address(0);
    }

    function approve(address to, uint256 clanId) external {
        require(tokenOwner[clanId] == msg.sender);
        tokenApprovals[clanId] = to;
        emit Approval(msg.sender, to, clanId);
    }

    function getApproved(uint256 clanId) external view returns (address) {
        return tokenApprovals[clanId];
    }

    function tokensOf(address player) external view returns (uint256[] tokens) {
         return ownedTokens[player];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        require(tokenApprovals[tokenId] == msg.sender || tokenOwner[tokenId] == msg.sender);

        joinClanPlayer(to, uint224(tokenId), 0); // uint224 won't overflow due to tokenOwner check in removeTokenFrom()
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
        uint256 lastTokenIndex = ownedTokens[from].length.sub(1);
        uint256 lastToken = ownedTokens[from][lastTokenIndex];

        ownedTokens[from][tokenIndex] = lastToken;
        ownedTokens[from][lastTokenIndex] = 0;

        ownedTokens[from].length--;
        ownedTokensIndex[tokenId] = 0;
        ownedTokensIndex[lastToken] = tokenIndex;
    }

    function addTokenTo(address to, uint256 tokenId) internal {
        require(ownedTokens[to].length == 0); // Can't own multiple clans
        tokenOwner[tokenId] = to;
        ownedTokensIndex[tokenId] = ownedTokens[to].length;
        ownedTokens[to].push(tokenId);
    }

    function updateClanFees(uint224 newClanFee, uint224 newLeaderFee, uint224 newReferalFee, uint256 clanId) external {
        require(msg.sender == tokenOwner[clanId]);
        require(newClanFee <= 25); // 25% max fee
        require(newReferalFee <= 10); // 10% max refs
        require(newLeaderFee <= newClanFee); // Clan gets fair cut
        clanFee[clanId] = newClanFee;
        leaderFee[clanId] = newLeaderFee;
        referalFee[clanId] = newReferalFee;
    }

    function getPlayerFees(address player) external view returns (uint224 clansFee, uint224 leadersFee, address leader, uint224 referalsFee, address referer) {
        uint256 usersClan = userClan[player].clanId;
        clansFee = clanFee[usersClan];
        leadersFee = leaderFee[usersClan];
        leader = tokenOwner[usersClan];
        referalsFee = referalFee[usersClan];
        referer = clanReferer[player][usersClan];
    }

    function getPlayersClanUpgrade(address player, uint256 upgradeClass) external view returns (uint224 upgradeGain) {
        upgradeGain = upgradeList[clanUpgradesOwned[userClan[player].clanId][upgradeClass]].upgradeGain;
    }

    function getClanUpgrade(uint256 clanId, uint256 upgradeClass) external view returns (uint224 upgradeGain) {
        upgradeGain = upgradeList[clanUpgradesOwned[clanId][upgradeClass]].upgradeGain;
    }

    // Convienence function
    function getClanDetailsForAttack(address player, address target) external view returns (uint256 clanId, uint256 targetClanId, uint224 playerLootingBonus) {
        clanId = userClan[player].clanId;
        targetClanId = userClan[target].clanId;
        playerLootingBonus = upgradeList[clanUpgradesOwned[clanId][3]].upgradeGain; // class 3 = looting bonus
    }

    function joinClan(uint224 clanId, address referer) external {
        require(exists(clanId));
        joinClanPlayer(msg.sender, clanId, referer);
    }

    // Allows smarter invites/referals in future
    function joinClanFromInvite(address player, uint224 clanId, address referer) external {
        require(operator[msg.sender]);
        joinClanPlayer(player, clanId, referer);
    }

    function joinClanPlayer(address player, uint224 clanId, address referer) internal {
        require(ownedTokens[player].length == 0); // Owners can't join

        (uint80 attack, uint80 defense,) = army.getArmyPower(player);

        // Leave old clan
        UserClan memory existingClan = userClan[player];
        if (existingClan.clanId > 0) {
            clanMembers[existingClan.clanId]--;
            clanTotalArmyPower[existingClan.clanId] -= (attack + defense);
            emit LeftClan(existingClan.clanId, player);
        }

        if (referer != address(0) && referer != player) {
            require(userClan[referer].clanId == clanId);
            clanReferer[player][clanId] = referer;
        }

        existingClan.clanId = clanId;
        existingClan.clanJoinTime = uint32(now);

        clanMembers[clanId]++;
        clanTotalArmyPower[clanId] += (attack + defense);
        userClan[player] = existingClan;
        emit JoinedClan(clanId, player, referer);
    }

    function leaveClan() external {
        require(ownedTokens[msg.sender].length == 0); // Owners can't leave

        UserClan memory usersClan = userClan[msg.sender];
        require(usersClan.clanId > 0);

        (uint80 attack, uint80 defense,) = army.getArmyPower(msg.sender);
        clanTotalArmyPower[usersClan.clanId] -= (attack + defense);

        clanMembers[usersClan.clanId]--;
        delete userClan[msg.sender];
        emit LeftClan(usersClan.clanId, msg.sender);

        // Cannot leave if player has unclaimed divs (edge case for clan fee abuse)
        require(attack + defense == 0 || army.lastWarFundClaim(msg.sender) == army.getSnapshotDay());
        require(usersClan.clanJoinTime + 24 hours < now);
    }

    function mintClan(address recipient, uint224 referalPercent, address clanTokenAddress, uint256 baseTokenReward) external {
        require(operator[msg.sender]);
        require(ERC20(clanTokenAddress).totalSupply() > 0);

        numClans++;
        uint224 clanId = numClans; // Starts from clanId 1

        // Add recipient to clan
        joinClanPlayer(recipient, clanId, 0);

        require(tokenOwner[clanId] == address(0));
        addTokenTo(recipient, clanId);
        emit Transfer(address(0), recipient, clanId);

        // Store clan token
        clanToken[clanId] = clanTokenAddress;
        baseTokenDenomination[clanId] = baseTokenReward;
        referalFee[clanId] = referalPercent;

        // Burn clan coupons from owner (prelaunch event)
        if (clanCoupons.totalSupply() > 0) {
            clanCoupons.burnCoupon(recipient, clanId);
        }
    }

    function addUpgrade(uint256 id, uint224 gooCost, uint224 upgradeGain, uint256 upgradeClass, uint256 prereq) external {
        require(operator[msg.sender]);
        upgradeList[id] = Upgrade(id, gooCost, upgradeGain, upgradeClass, prereq);
    }

    // Incase an existing token becomes invalid (i.e. migrates away)
    function updateClanToken(uint256 clanId, address newClanToken, bool shouldRetrieveOldTokens) external {
        require(msg.sender == owner);
        require(ERC20(newClanToken).totalSupply() > 0);

        if (shouldRetrieveOldTokens) {
            ERC20(clanToken[clanId]).transferFrom(this, owner, ERC20(clanToken[clanId]).balanceOf(this));
        }

        clanToken[clanId] = newClanToken;
    }

    // Incase need to tweak/balance attacking rewards (i.e. token moons so not viable to restock at current level)
    function updateClanTokenGain(uint256 clanId, uint256 baseTokenReward) external {
        require(msg.sender == owner);
        baseTokenDenomination[clanId] = baseTokenReward;
    }


    // Clan member goo deposits
    function receiveApproval(address player, uint256 amount, address, bytes) external {
        uint256 clanId = userClan[player].clanId;
        require(exists(clanId));
        require(msg.sender == address(goo));

        ERC20(msg.sender).transferFrom(player, address(0), amount);
        clanGoo[clanId] += amount;
    }

    function buyUpgrade(uint224 upgradeId) external {
        uint256 clanId = userClan[msg.sender].clanId;
        require(msg.sender == tokenOwner[clanId]);

        Upgrade memory upgrade = upgradeList[upgradeId];
        require (upgrade.upgradeId > 0); // Valid upgrade

        uint256 upgradeClass = upgrade.upgradeClass;
        uint256 latestOwned = clanUpgradesOwned[clanId][upgradeClass];
        require(latestOwned < upgradeId); // Haven't already purchased
        require(latestOwned >= upgrade.prerequisiteUpgrade); // Own prequisite

        // Clan discount
        uint224 upgradeDiscount = clanUpgradesOwned[clanId][0]; // class 0 = upgrade discount
        uint224 reducedUpgradeCost = upgrade.gooCost - ((upgrade.gooCost * upgradeDiscount) / 100);

        clanGoo[clanId] = clanGoo[clanId].sub(reducedUpgradeCost);
        army.depositSpentGoo(reducedUpgradeCost); // Transfer to goo bankroll

        clanUpgradesOwned[clanId][upgradeClass] = upgradeId;
    }

    // Goo from divs etc.
    function depositGoo(uint256 amount, uint256 clanId) external {
        require(operator[msg.sender]);
        require(exists(clanId));
        clanGoo[clanId] += amount;
    }


    function increaseClanPower(address player, uint256 amount) external {
        require(operator[msg.sender]);

        uint256 clanId = userClan[player].clanId;
        if (clanId > 0) {
            clanTotalArmyPower[clanId] += amount;
        }
    }

    function decreaseClanPower(address player, uint256 amount) external {
        require(operator[msg.sender]);

        uint256 clanId = userClan[player].clanId;
        if (clanId > 0) {
            clanTotalArmyPower[clanId] -= amount;
        }
    }


    function stealGoo(address attacker, uint256 playerClanId, uint256 enemyClanId, uint80 lootingPower) external returns(uint256) {
        require(operator[msg.sender]);

        uint224 enemyGoo = uint224(clanGoo[enemyClanId]);
        uint224 enemyGooStolen = (lootingPower > enemyGoo) ? enemyGoo : lootingPower;

        clanGoo[enemyClanId] = clanGoo[enemyClanId].sub(enemyGooStolen);

        uint224 clansShare = (enemyGooStolen * clanFee[playerClanId]) / 100;
        uint224 referersFee = referalFee[playerClanId];
        address referer = clanReferer[attacker][playerClanId];

        if (clansShare > 0 || (referersFee > 0 && referer != address(0))) {
            uint224 leaderShare = (enemyGooStolen * leaderFee[playerClanId]) / 100;

            uint224 refsShare;
            if (referer != address(0)) {
                refsShare = (enemyGooStolen * referersFee) / 100;
                goo.mintGoo(refsShare, referer);
            }

            clanGoo[playerClanId] += clansShare;
            goo.mintGoo(leaderShare, tokenOwner[playerClanId]);
            goo.mintGoo(enemyGooStolen - (clansShare + leaderShare + refsShare), attacker);
        } else {
            goo.mintGoo(enemyGooStolen, attacker);
        }
        return enemyGooStolen;
    }


    function rewardTokens(address attacker, uint256 playerClanId, uint80 lootingPower) external returns(uint256) {
        require(operator[msg.sender]);

        uint256 amount = baseTokenDenomination[playerClanId] * lootingPower;
        ERC20(clanToken[playerClanId]).transfer(attacker, amount);
        return amount;

    }

    // Daily clan dividends
    function mintGoo(address player, uint256 amount) external {
        require(operator[msg.sender]);
        clanGoo[userClan[player].clanId] += amount;
    }

}

contract ERC20 {
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    function transfer(address to, uint tokens) external returns (bool success);
    function totalSupply() external constant returns (uint);
    function balanceOf(address tokenOwner) external constant returns (uint balance);
}

contract GooToken {
    function mintGoo(uint224 amount, address player) external;
    function updatePlayersGooFromPurchase(address player, uint224 purchaseCost) external;
}

contract Army {
    mapping(address => uint256) public lastWarFundClaim; // Days (snapshot number)
    function depositSpentGoo(uint224 amount) external;
    function getArmyPower(address player) external view returns (uint80, uint80, uint80);
    function getSnapshotDay() external view returns (uint256 snapshot);
}

contract WWGClanCoupons {
    function totalSupply() external view returns (uint256);
    function burnCoupon(address clanOwner, uint256 tokenId) external;
}

contract ERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes data) external returns(bytes4);
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