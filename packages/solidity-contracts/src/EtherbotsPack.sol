/**
 * Source Code first verified at https://etherscan.io on Friday, March 15, 2019
 (UTC) */

pragma solidity ^0.5.0;


library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

library SafeMath64 {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint64 a, uint64 b) internal pure returns (uint64 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint64 a, uint64 b) internal pure returns (uint64) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint64 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint64 a, uint64 b) internal pure returns (uint64) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint64 a, uint64 b) internal pure returns (uint64 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

interface EBInterface {
    
    function owns(address, uint) external returns (bool);

    function getPartById(uint) external returns (
        uint32 tokenId, 
        uint8 partType, 
        uint8 partSubType,  
        uint8 rarity, 
        uint8 element,
        uint32 battlesLastDay, 
        uint32 experience, 
        uint32 forgeTime, 
        uint32 battlesLastReset
    );
}

interface EBMarketplace {

    function getAuction(uint id) external returns (address, uint, uint, uint, uint);
 
}

contract Ownable {

    address payable public owner;

    constructor() public {
        owner = msg.sender;
    }

    function setOwner(address payable _owner) public onlyOwner {
        owner = _owner;
    }

    function getOwner() public view returns (address payable) {
        return owner;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "must be owner to call this function");
        _;
    }

}

contract ICards {

    enum Rarity {
        Common, Rare, Epic, Legendary, Mythic
    }

    function getRandomCard(Rarity rarity, uint16 random) public view returns (uint16);
    function createCard(address user, uint16 proto, uint16 purity) public returns (uint);


}

contract Pack {

    enum Type {
        Rare, Epic, Legendary, Shiny
    }

}

contract RarityProvider {

    ICards cards;

    constructor(ICards _cards) public {
        cards = _cards;
    }

    struct RandomnessComponents {
        uint random;
        uint32 rarity;
        uint16 quality;
        uint16 purity;
        uint16 proto;
    }

    // return 'length' bytes of 'num' starting at 'start'
    function extract(uint num, uint length, uint start) internal pure returns (uint) {
        return (((1 << (length * 8)) - 1) & (num >> ((start - 1) * 8)));
    }

    // divides the random seed into components
    function getComponents(
        uint cardIndex, uint rand
    ) internal pure returns (
        RandomnessComponents memory
    ) {
        uint random = uint(keccak256(abi.encodePacked(cardIndex, rand)));
        return RandomnessComponents({
            random: random,
            rarity: uint32(extract(random, 4, 10) % 1000000),
            quality: uint16(extract(random, 2, 4) % 1000),
            purity: uint16(extract(random, 2, 6) % 1000),
            proto: uint16(extract(random, 2, 8) % (2**16-1))
        });
    }

    function getCardDetails(Pack.Type packType, uint cardIndex, uint result) internal view returns (uint16, uint16) {
        if (packType == Pack.Type.Shiny) {
            return _getShinyCardDetails(cardIndex, result);
        } else if (packType == Pack.Type.Legendary) {
            return _getLegendaryCardDetails(cardIndex, result);
        } else if (packType == Pack.Type.Epic) {
            return _getEpicCardDetails(cardIndex, result);
        }
        return _getRareCardDetails(cardIndex, result);
    }

    function _getShinyCardDetails(uint cardIndex, uint result) internal view returns (uint16 proto, uint16 purity) {
        
        RandomnessComponents memory rc = getComponents(cardIndex, result); 

        ICards.Rarity rarity;

        if (cardIndex == 4) {
            rarity = _getLegendaryPlusRarity(rc.rarity);
            purity = _getShinyPurityBase(rc.quality) + rc.purity;
        } else if (cardIndex == 3) {
            rarity = _getRarePlusRarity(rc.rarity);
            purity = _getPurityBase(rc.quality) + rc.purity;
        } else {
            rarity = _getCommonPlusRarity(rc.rarity);
            purity = _getPurityBase(rc.quality) + rc.purity;
        }
        proto = cards.getRandomCard(rarity, rc.proto);
        return (proto, purity);
    }

    function _getLegendaryCardDetails(uint cardIndex, uint result) internal view returns (uint16 proto, uint16 purity) {
        
        RandomnessComponents memory rc = getComponents(cardIndex, result);

        ICards.Rarity rarity;

        if (cardIndex == 4) {
            rarity = _getLegendaryPlusRarity(rc.rarity);
        } else if (cardIndex == 3) {
            rarity = _getRarePlusRarity(rc.rarity);
        } else {
            rarity = _getCommonPlusRarity(rc.rarity);
        }

        purity = _getPurityBase(rc.quality) + rc.purity;
    
        proto = cards.getRandomCard(rarity, rc.proto);

        return (proto, purity);
    } 


    function _getEpicCardDetails(uint cardIndex, uint result) internal view returns (uint16 proto, uint16 purity) {
        
        RandomnessComponents memory rc = getComponents(cardIndex, result);

        ICards.Rarity rarity;

        if (cardIndex == 4) {
            rarity = _getEpicPlusRarity(rc.rarity);
        } else {
            rarity = _getCommonPlusRarity(rc.rarity);
        }

        purity = _getPurityBase(rc.quality) + rc.purity;
    
        proto = cards.getRandomCard(rarity, rc.proto);

        return (proto, purity);
    } 

    function _getRareCardDetails(uint cardIndex, uint result) internal view returns (uint16 proto, uint16 purity) {

        RandomnessComponents memory rc = getComponents(cardIndex, result);

        ICards.Rarity rarity;

        if (cardIndex == 4) {
            rarity = _getRarePlusRarity(rc.rarity);
        } else {
            rarity = _getCommonPlusRarity(rc.rarity);
        }

        purity = _getPurityBase(rc.quality) + rc.purity;
    
        proto = cards.getRandomCard(rarity, rc.proto);
        return (proto, purity);
    }  


    function _getCommonPlusRarity(uint32 rand) internal pure returns (ICards.Rarity) {
        if (rand == 999999) {
            return ICards.Rarity.Mythic;
        } else if (rand >= 998345) {
            return ICards.Rarity.Legendary;
        } else if (rand >= 986765) {
            return ICards.Rarity.Epic;
        } else if (rand >= 924890) {
            return ICards.Rarity.Rare;
        } else {
            return ICards.Rarity.Common;
        }
    }

    function _getRarePlusRarity(uint32 rand) internal pure returns (ICards.Rarity) {
        if (rand == 999999) {
            return ICards.Rarity.Mythic;
        } else if (rand >= 981615) {
            return ICards.Rarity.Legendary;
        } else if (rand >= 852940) {
            return ICards.Rarity.Epic;
        } else {
            return ICards.Rarity.Rare;
        } 
    }

    function _getEpicPlusRarity(uint32 rand) internal pure returns (ICards.Rarity) {
        if (rand == 999999) {
            return ICards.Rarity.Mythic;
        } else if (rand >= 981615) {
            return ICards.Rarity.Legendary;
        } else {
            return ICards.Rarity.Epic;
        }
    }

    function _getLegendaryPlusRarity(uint32 rand) internal pure returns (ICards.Rarity) {
        if (rand == 999999) {
            return ICards.Rarity.Mythic;
        } else {
            return ICards.Rarity.Legendary;
        } 
    }

    // store purity and shine as one number to save users gas
    function _getPurityBase(uint16 randOne) internal pure returns (uint16) {
        if (randOne >= 998) {
            return 3000;
        } else if (randOne >= 988) {
            return 2000;
        } else if (randOne >= 938) {
            return 1000;
        }
        return 0;
    }

    function _getShinyPurityBase(uint16 randOne) internal pure returns (uint16) {
        if (randOne >= 998) {
            return 3000;
        } else if (randOne >= 748) {
            return 2000;
        } else {
            return 1000;
        }
    }

    function getShine(uint16 purity) public pure returns (uint8) {
        return uint8(purity / 1000);
    }

}

contract EtherbotsPack is Ownable, RarityProvider {

    using SafeMath for uint256;
    using SafeMath64 for uint64;

    // fired after user purchases count packs, producing purchase with id 
    event ClaimMade(uint indexed id, address user, uint count);
    // fired after the callback transaction is successful, replaces RandomnessReceived
    event CallbackMade(uint indexed id, address indexed user, uint count, uint randomness);
    // fired after a recommit for a purchase
    event Recommit(uint indexed id, address indexed user, uint count);
    // fired after a card is activated, replaces PacksOpened
    event CardActivated(uint indexed claimID, uint cardIndex, uint indexed cardID, uint16 proto, uint16 purity);

    // Rex, Arcane Sphere, Pyrocannon, Aetherrust, Magic Missile Launcher, Firewall
    uint16[] commons = [400, 413, 414, 421, 427, 428]; 
    // Banisher, Daemonbot, Nethersaur, Trident
    uint16[] rares = [389, 415, 416, 422]; 
    // Golden Sabre, Howler Golem, Hasty Trade
    uint16[] epics = [424, 425, 426]; 
    // Iron Horse, Chest
    uint16[] legendaries = [382, 420]; 
    // Golden Golem
    uint16 exclusive = 417;

    uint public commitLag = 0;
    uint16 public activationLimit = 40;
    uint16 public multiplier = 4;

    struct Claim {
        uint randomness;
        uint[] state;
        address user;
        uint64 commit;
        uint16 count;
        uint16[3] exCounts;
        uint16[3] counts;        
    }

    mapping(uint => bool) public claimed;

    // TODO: should this be public?
    Claim[] public claims;

    EBInterface public eb; 
    EBMarketplace public em; 

    constructor(ICards _cards, EBInterface _eb, EBMarketplace _em) RarityProvider(_cards) public payable {
        eb = _eb;
        em = _em;
    }

    function setCommitLag(uint lag) public onlyOwner {
        require(commitLag < 100, "can't have a commit lag of >100 blocks");
        commitLag = lag;
    }

    function setActivationLimit(uint16 _limit) public onlyOwner {
        activationLimit = _limit;
    }

    function claimParts(uint[] memory parts) public {
        
        require(parts.length > 0, "must submit some parts");
        require(parts.length <= 1000, "must submit <=1000 parts per purchase");
        require(parts.length % 4 == 0, "must submit a multiple of 4 parts at a time");
        require(parts.length == uint16(parts.length), "must fit into a uint16");

        require(ownsOrAuctioning(parts), "user must control all parts");
        require(canBeClaimed(parts), "at least one part was already claimed");

        uint packs = parts.length.div(4).mul(multiplier);

        Claim memory claim = Claim({ 
            user: msg.sender,
            count: uint16(packs),
            randomness: 0,
            commit: getCommitBlock(),
            exCounts: [uint16(0), 0, 0],
            counts: [uint16(0), 0, 0],
            state: new uint256[](getStateSize(packs))
        });

        uint8 partType;
        uint8 subType;
        uint8 rarity;

        for (uint i = 0; i < parts.length; i++) {
            (, partType, subType, rarity, , , , ,) = eb.getPartById(parts[i]);
            require(rarity > 0, "invalid rarity");
            // rarity is (1, 2, 3)
            if (isExclusive(partType, subType)) {
                claim.exCounts[rarity-1] += multiplier;
            } else {
                claim.counts[rarity-1] += multiplier;
            }
        }

        uint id = claims.push(claim) - 1;

        emit ClaimMade(id, msg.sender, parts.length);
    }

    function ownsOrAuctioning(uint[] memory parts) public returns (bool) {
        for (uint i = 0; i < parts.length; i++) {
            uint id = parts[i];
            if (!eb.owns(msg.sender, id)) {
                address seller;
                // returns an active auction 
                // will revert if inactive - this is fine, they don't own it then
                (seller, , , , ) = em.getAuction(id);
                if (seller != msg.sender) {
                    return false;
                }
            }
        }
        return true;
    }

    function canBeClaimed(uint[] memory parts) public returns (bool) {
        for (uint i = 0; i < parts.length; i++) {
            uint id = parts[i];
            if (claimed[id]) {
                return false;
            }
            claimed[id] = true;
        }
        return true;
    }

    function getCounts(uint id) public view returns (uint16[3] memory counts, uint16[3] memory exCounts) {
        Claim memory c = claims[id];
        return (c.counts, c.exCounts);
    }

    function callback(uint id) public {

        Claim storage c = claims[id];

        require(c.randomness == 0, "can only callback once");
        require(uint64(block.number) > c.commit, "cannot callback before commit");
        require(c.commit.add(uint64(256)) >= block.number, "must recommit");

        bytes32 bhash = blockhash(c.commit);
        require(uint(bhash) != 0, "blockhash must not be zero");

        c.randomness = uint(keccak256(abi.encodePacked(id, bhash, address(this))));

        emit CallbackMade(id, c.user, c.count, c.randomness);
    }

    function recommit(uint id) public {
        Claim storage c = claims[id];
        require(c.randomness == 0, "randomness already set");
        require(block.number >= c.commit.add(uint64(256)), "no need to recommit");
        c.commit = getCommitBlock();
        emit Recommit(id, c.user, c.count);
    }

    function predictPacks(uint id) external view returns (uint16[] memory protos, uint16[] memory purities) {

        Claim memory c = claims[id];

        require(c.randomness != 0, "randomness not yet set");

        uint result = c.randomness;

        uint cardCount = uint(c.count).mul(5);

        purities = new uint16[](cardCount);
        protos = new uint16[](cardCount);

        for (uint i = 0; i < cardCount; i++) {
            (protos[i], purities[i]) = getCard(c, i, result);
        }

        return (protos, purities);
    }

    function getCommitBlock() internal view returns (uint64) {
        return uint64(block.number.add(commitLag));
    }

    function getStateSize(uint count) public pure returns (uint) {
        return count.mul(5).sub(1).div(256).add(1);
    }

    function isExclusive(uint partType, uint partSubType) public pure returns (bool) {
        // checks whether the part is a lambo or AP
        return (partType == 3) && (partSubType == 14 || partSubType == 16);
    }

    function getCard(Claim memory c, uint index, uint result) internal view returns (uint16 proto, uint16 purity) {

        RandomnessComponents memory rc = getComponents(index, result);

        uint16 progress = c.exCounts[0];

        if (progress > index) {
            proto = exclusive;
            purity = _getPurityBase(rc.quality) + rc.purity;
            return (proto, purity);
        }

        progress += c.exCounts[1];
        if (progress > index) {
            proto = exclusive;
            // will be a random shadow
            purity = _getPurityBase(940) + rc.purity;
            return (proto, purity);
        } 

        progress += c.exCounts[2];
        if (progress > index) {
            proto = exclusive;
            // will be a random gold
            purity = _getPurityBase(990) + rc.purity;
            return (proto, purity);
        }

        progress += c.counts[0];
        if (progress > index) {
            proto = getRandomCard(rc.rarity, rc.proto);
            purity = _getPurityBase(rc.quality) + rc.purity;
            return (proto, purity);
        }

        progress += c.counts[1];
        if (progress > index) {
            proto = getRandomCard(rc.rarity, rc.proto);
            // will be a random shadow
            purity = _getPurityBase(940) + rc.purity;
            return (proto, purity);
        } 

        progress += c.counts[2];
        if (progress > index) {
            proto = getRandomCard(rc.rarity, rc.proto);
            // will be a random gold
            purity = _getPurityBase(990) + rc.purity;
            return (proto, purity);
        }

        // 5 cards for 4 parts --> left over cards just get base stats
        proto = getRandomCard(rc.rarity, rc.proto);
        purity = _getPurityBase(rc.quality) + rc.purity;

        return (proto, purity);
    }  

    function getRandomCard(uint32 rarityRandom, uint16 protoRandom) internal view returns (uint16) {
        // adjusted from normal probabilities to ensure more appropriate distribution of cards
        if (rarityRandom >= 970000) {
            return legendaries[protoRandom % legendaries.length];
        } else if (rarityRandom >= 890000) {
            return epics[protoRandom % epics.length];
        } else if (rarityRandom >= 670000) {
            return rares[protoRandom % rares.length];
        } else {
            return commons[protoRandom % commons.length];
        }
    }

    function activateMultiple(uint[] memory pIDs, uint[] memory cardIndices) 
        public returns (uint[] memory ids, uint16[] memory protos, uint16[] memory purities) {
        uint len = pIDs.length;
        require(len > 0, "can't activate no cards");
        require(len <= activationLimit, "can't activate more than the activation limit");
        require(len == cardIndices.length, "must have the same length");
        ids = new uint[](len);
        protos = new uint16[](len);
        purities = new uint16[](len);
        for (uint i = 0; i < len; i++) {
            (ids[i], protos[i], purities[i]) = activate(pIDs[i], cardIndices[i]);
        }
        return (ids, protos, purities);
    }

    function activate(uint claimID, uint cardIndex) public returns (uint id, uint16 proto, uint16 purity) {
        Claim storage c = claims[claimID];
        
        require(c.randomness != 0, "must have been a callback");
        uint cardCount = uint(c.count).mul(5);
        require(cardIndex < cardCount, "not a valid card index");
        uint bit = getStateBit(claimID, cardIndex);
        // can only activate each card once
        require(bit == 0, "card has already been activated");
        uint x = cardIndex.div(256);
        uint pos = cardIndex % 256;
        // mark the card as activated by flipping the relevant bit
        c.state[x] ^= uint(1) << pos;
        // create the card
        (proto, purity) = getCard(c, cardIndex, c.randomness);
        id = cards.createCard(c.user, proto, purity);
        emit CardActivated(claimID, cardIndex, id, proto, purity);
        return (id, proto, purity);
    }

    function isActivated(uint purchaseID, uint cardIndex) public view returns (bool) {
        return getStateBit(purchaseID, cardIndex) != 0;
    }

    function getStateBit(uint claimID, uint cardIndex) public view returns (uint) {
        Claim memory c = claims[claimID];
        uint x = cardIndex.div(256);
        uint slot = c.state[x];
        uint pos = cardIndex % 256;
        uint bit = (slot >> pos) & uint(1);
        return bit;
    }

}