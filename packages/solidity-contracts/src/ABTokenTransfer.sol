/**
 * Source Code first verified at https://etherscan.io on Saturday, March 16, 2019
 (UTC) */

pragma solidity ^0.4.17;

contract Enums {
    enum ResultCode {
        SUCCESS,
        ERROR_CLASS_NOT_FOUND,
        ERROR_LOW_BALANCE,
        ERROR_SEND_FAIL,
        ERROR_NOT_OWNER,
        ERROR_NOT_ENOUGH_MONEY,
        ERROR_INVALID_AMOUNT
    }

    enum AngelAura { 
        Blue, 
        Yellow, 
        Purple, 
        Orange, 
        Red, 
        Green 
    }
}
contract AccessControl {
    address public creatorAddress;
    uint16 public totalSeraphims = 0;
    mapping (address => bool) public seraphims;

    bool public isMaintenanceMode = true;
 
    modifier onlyCREATOR() {
        require(msg.sender == creatorAddress);
        _;
    }

    modifier onlySERAPHIM() {
      
      require(seraphims[msg.sender] == true);
        _;
    }
    modifier isContractActive {
        require(!isMaintenanceMode);
        _;
    }
    
   // Constructor
    function AccessControl() public {
        creatorAddress = msg.sender;
    }
    

    function addSERAPHIM(address _newSeraphim) onlyCREATOR public {
        if (seraphims[_newSeraphim] == false) {
            seraphims[_newSeraphim] = true;
            totalSeraphims += 1;
        }
    }
    
    function removeSERAPHIM(address _oldSeraphim) onlyCREATOR public {
        if (seraphims[_oldSeraphim] == true) {
            seraphims[_oldSeraphim] = false;
            totalSeraphims -= 1;
        }
    }

    function updateMaintenanceMode(bool _isMaintaining) onlyCREATOR public {
        isMaintenanceMode = _isMaintaining;
    }

  
} 
contract IABToken is AccessControl {
 
 
    function balanceOf(address owner) public view returns (uint256);
    function totalSupply() external view returns (uint256) ;
    function ownerOf(uint256 tokenId) public view returns (address) ;
    function setMaxAngels() external;
    function setMaxAccessories() external;
    function setMaxMedals()  external ;
    function initAngelPrices() external;
    function initAccessoryPrices() external ;
    function setCardSeriesPrice(uint8 _cardSeriesId, uint _newPrice) external;
    function approve(address to, uint256 tokenId) public;
    function getRandomNumber(uint16 maxRandom, uint8 min, address privateAddress) view public returns(uint8) ;
    function tokenURI(uint256 _tokenId) public pure returns (string memory) ;
    function baseTokenURI() public pure returns (string memory) ;
    function name() external pure returns (string memory _name) ;
    function symbol() external pure returns (string memory _symbol) ;
    function getApproved(uint256 tokenId) public view returns (address) ;
    function setApprovalForAll(address to, bool approved) public ;
    function isApprovedForAll(address owner, address operator) public view returns (bool);
    function transferFrom(address from, address to, uint256 tokenId) public ;
    function safeTransferFrom(address from, address to, uint256 tokenId) public ;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public ;
    function _exists(uint256 tokenId) internal view returns (bool) ;
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) ;
    function _mint(address to, uint256 tokenId) internal ;
    function mintABToken(address owner, uint8 _cardSeriesId, uint16 _power, uint16 _auraRed, uint16 _auraYellow, uint16 _auraBlue, string memory _name, uint16 _experience, uint16 _oldId) public;
    function addABTokenIdMapping(address _owner, uint256 _tokenId) private ;
    function getPrice(uint8 _cardSeriesId) public view returns (uint);
    function buyAngel(uint8 _angelSeriesId) public payable ;
    function buyAccessory(uint8 _accessorySeriesId) public payable ;
    function getAura(uint8 _angelSeriesId) pure public returns (uint8 auraRed, uint8 auraYellow, uint8 auraBlue) ;
    function getAngelPower(uint8 _angelSeriesId) private view returns (uint16) ;
    function getABToken(uint256 tokenId) view public returns(uint8 cardSeriesId, uint16 power, uint16 auraRed, uint16 auraYellow, uint16 auraBlue, string memory name, uint16 experience, uint64 lastBattleTime, uint16 lastBattleResult, address owner, uint16 oldId);
    function setAuras(uint256 tokenId, uint16 _red, uint16 _blue, uint16 _yellow) external;
    function setName(uint256 tokenId,string memory namechange) public ;
    function setExperience(uint256 tokenId, uint16 _experience) external;
    function setLastBattleResult(uint256 tokenId, uint16 _result) external ;
    function setLastBattleTime(uint256 tokenId) external;
    function setLastBreedingTime(uint256 tokenId) external ;
    function setoldId(uint256 tokenId, uint16 _oldId) external;
    function getABTokenByIndex(address _owner, uint64 _index) view external returns(uint256) ;
    function _burn(address owner, uint256 tokenId) internal ;
    function _burn(uint256 tokenId) internal ;
    function _transferFrom(address from, address to, uint256 tokenId) internal ;
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) internal returns (bool);
    function _clearApproval(uint256 tokenId) private ;
}


contract IPetCardData is AccessControl, Enums {
    uint8 public totalPetCardSeries;    
    uint64 public totalPets;
    
    // write
    function createPetCardSeries(uint8 _petCardSeriesId, uint32 _maxTotal) onlyCREATOR public returns(uint8);
    function setPet(uint8 _petCardSeriesId, address _owner, string _name, uint8 _luck, uint16 _auraRed, uint16 _auraYellow, uint16 _auraBlue) onlySERAPHIM external returns(uint64);
    function setPetAuras(uint64 _petId, uint8 _auraRed, uint8 _auraBlue, uint8 _auraYellow) onlySERAPHIM external;
    function setPetLastTrainingTime(uint64 _petId) onlySERAPHIM external;
    function setPetLastBreedingTime(uint64 _petId) onlySERAPHIM external;
    function addPetIdMapping(address _owner, uint64 _petId) private;
    function transferPet(address _from, address _to, uint64 _petId) onlySERAPHIM public returns(ResultCode);
    function ownerPetTransfer (address _to, uint64 _petId)  public;
    function setPetName(string _name, uint64 _petId) public;

    // read
    function getPetCardSeries(uint8 _petCardSeriesId) constant public returns(uint8 petCardSeriesId, uint32 currentPetTotal, uint32 maxPetTotal);
    function getPet(uint _petId) constant public returns(uint petId, uint8 petCardSeriesId, string name, uint8 luck, uint16 auraRed, uint16 auraBlue, uint16 auraYellow, uint64 lastTrainingTime, uint64 lastBreedingTime, address owner);
    function getOwnerPetCount(address _owner) constant public returns(uint);
    function getPetByIndex(address _owner, uint _index) constant public returns(uint);
    function getTotalPetCardSeries() constant public returns (uint8);
    function getTotalPets() constant public returns (uint);
}

contract IAngelCardData is AccessControl, Enums {
    uint8 public totalAngelCardSeries;
    uint64 public totalAngels;

    
    // write
    // angels
    function createAngelCardSeries(uint8 _angelCardSeriesId, uint _basePrice,  uint64 _maxTotal, uint8 _baseAura, uint16 _baseBattlePower, uint64 _liveTime) onlyCREATOR external returns(uint8);
    function updateAngelCardSeries(uint8 _angelCardSeriesId, uint64 _newPrice, uint64 _newMaxTotal) onlyCREATOR external;
    function setAngel(uint8 _angelCardSeriesId, address _owner, uint _price, uint16 _battlePower) onlySERAPHIM external returns(uint64);
    function addToAngelExperienceLevel(uint64 _angelId, uint _value) onlySERAPHIM external;
    function setAngelLastBattleTime(uint64 _angelId) onlySERAPHIM external;
    function setAngelLastVsBattleTime(uint64 _angelId) onlySERAPHIM external;
    function setLastBattleResult(uint64 _angelId, uint16 _value) onlySERAPHIM external;
    function addAngelIdMapping(address _owner, uint64 _angelId) private;
    function transferAngel(address _from, address _to, uint64 _angelId) onlySERAPHIM public returns(ResultCode);
    function ownerAngelTransfer (address _to, uint64 _angelId)  public;
    function updateAngelLock (uint64 _angelId, bool newValue) public;
    function removeCreator() onlyCREATOR external;

    // read
    function getAngelCardSeries(uint8 _angelCardSeriesId) constant public returns(uint8 angelCardSeriesId, uint64 currentAngelTotal, uint basePrice, uint64 maxAngelTotal, uint8 baseAura, uint baseBattlePower, uint64 lastSellTime, uint64 liveTime);
    function getAngel(uint64 _angelId) constant public returns(uint64 angelId, uint8 angelCardSeriesId, uint16 battlePower, uint8 aura, uint16 experience, uint price, uint64 createdTime, uint64 lastBattleTime, uint64 lastVsBattleTime, uint16 lastBattleResult, address owner);
    function getOwnerAngelCount(address _owner) constant public returns(uint);
    function getAngelByIndex(address _owner, uint _index) constant public returns(uint64);
    function getTotalAngelCardSeries() constant public returns (uint8);
    function getTotalAngels() constant public returns (uint64);
    function getAngelLockStatus(uint64 _angelId) constant public returns (bool);
}

contract IAccessoryData is AccessControl, Enums {
    uint8 public totalAccessorySeries;    
    uint32 public totalAccessories;
    
 
    /*** FUNCTIONS ***/
    //*** Write Access ***//
    function createAccessorySeries(uint8 _AccessorySeriesId, uint32 _maxTotal, uint _price) onlyCREATOR public returns(uint8) ;
	function setAccessory(uint8 _AccessorySeriesId, address _owner) onlySERAPHIM external returns(uint64);
   function addAccessoryIdMapping(address _owner, uint64 _accessoryId) private;
	function transferAccessory(address _from, address _to, uint64 __accessoryId) onlySERAPHIM public returns(ResultCode);
    function ownerAccessoryTransfer (address _to, uint64 __accessoryId)  public;
    function updateAccessoryLock (uint64 _accessoryId, bool newValue) public;
    function removeCreator() onlyCREATOR external;
    
    //*** Read Access ***//
    function getAccessorySeries(uint8 _accessorySeriesId) constant public returns(uint8 accessorySeriesId, uint32 currentTotal, uint32 maxTotal, uint price) ;
	function getAccessory(uint _accessoryId) constant public returns(uint accessoryID, uint8 AccessorySeriesID, address owner);
	function getOwnerAccessoryCount(address _owner) constant public returns(uint);
	function getAccessoryByIndex(address _owner, uint _index) constant public returns(uint) ;
    function getTotalAccessorySeries() constant public returns (uint8) ;
    function getTotalAccessories() constant public returns (uint);
    function getAccessoryLockStatus(uint64 _acessoryId) constant public returns (bool);
}


contract ABTokenTransfer is AccessControl {
    // Addresses for other contracts ABTokenTransfer interacts with. 
  
    address public angelCardDataContract = 0x6D2E76213615925c5fc436565B5ee788Ee0E86DC;
    address public petCardDataContract = 0xB340686da996b8B3d486b4D27E38E38500A9E926;
    address public accessoryDataContract = 0x466c44812835f57b736ef9F63582b8a6693A14D0;
    address public ABTokenDataContract = 0xDC32FF5aaDA11b5cE3CAf2D00459cfDA05293F96;
 

    
    /*** DATA TYPES ***/


    struct Angel {
        uint64 angelId;
        uint8 angelCardSeriesId;
        address owner;
        uint16 battlePower;
        uint8 aura;
        uint16 experience;
        uint price;
        uint64 createdTime;
        uint64 lastBattleTime;
        uint64 lastVsBattleTime;
        uint16 lastBattleResult;
    }

    struct Pet {
        uint petId;
        uint8 petCardSeriesId;
        address owner;
        string name;
        uint8 luck;
        uint16 auraRed;
        uint16 auraYellow;
        uint16 auraBlue;
        uint64 lastTrainingTime;
        uint64 lastBreedingTime;
        uint price; 
        uint64 liveTime;
    }
    
     struct Accessory {
        uint16 accessoryId;
        uint8 accessorySeriesId;
        address owner;
    }


    // write functions
    function DataContacts(address _angelCardDataContract, address _petCardDataContract, address _accessoryDataContract, address _ABTokenDataContract) onlyCREATOR external {
        angelCardDataContract = _angelCardDataContract;
        petCardDataContract = _petCardDataContract;
        accessoryDataContract = _accessoryDataContract;
        ABTokenDataContract = _ABTokenDataContract;
     
      
    }
   
  function claimPet(uint64 petID) public {
       IPetCardData petCardData = IPetCardData(petCardDataContract);
       IABToken ABTokenData = IABToken(ABTokenDataContract);
       if ((petID <= 0) || (petID > petCardData.getTotalPets())) {revert();}
       Pet memory pet;
       (pet.petId,pet.petCardSeriesId,,pet.luck,pet.auraRed,pet.auraBlue,pet.auraYellow,,,pet.owner) = petCardData.getPet(petID);
       if ((msg.sender != pet.owner) && (seraphims[msg.sender] == false)) {revert();}
       //First burn the old pet by transfering to 0x0;
       petCardData.transferPet(pet.owner,0x0,petID);
       //finally create the new one. 
       ABTokenData.mintABToken(pet.owner,pet.petCardSeriesId + 23, pet.luck, pet.auraRed, pet.auraYellow, pet.auraBlue, pet.name,0, uint16(pet.petId));
  }
       
    function claimAccessory(uint64 accessoryID) public {
       IAccessoryData accessoryData = IAccessoryData(accessoryDataContract);
       IABToken ABTokenData = IABToken(ABTokenDataContract);
       if ((accessoryID <= 0) || (accessoryID > accessoryData.getTotalAccessories())) {revert();}
      Accessory memory accessory;
       (,accessory.accessorySeriesId,accessory.owner) = accessoryData.getAccessory(accessoryID);
       
       //First burn the old accessory by transfering to 0x0;
       // transfer function will revert if the accessory is still locked. 
       accessoryData.transferAccessory(accessory.owner,0x0,accessoryID);
       //finally create the new one. 
       ABTokenData.mintABToken(accessory.owner,accessory.accessorySeriesId + 42, 0, 0, 0, 0, "0",0, uint16(accessoryID));
  }
       
       function claimAngel(uint64 angelID) public {
       IAngelCardData angelCardData = IAngelCardData(angelCardDataContract);
       IABToken ABTokenData = IABToken(ABTokenDataContract);
       if ((angelID <= 0) || (angelID > angelCardData.getTotalAngels())) {revert();}
       Angel memory angel;
       (angel.angelId, angel.angelCardSeriesId, angel.battlePower, angel.aura, angel.experience,,,,,, angel.owner) = angelCardData.getAngel(angelID);
       
       //First burn the old angel by transfering to 0x0;
       //transfer will fail if card is locked. 
       angelCardData.transferAngel(angel.owner,0x0,angel.angelId);
       //finally create the new one.
       uint16 auraRed = 0;
       uint16 auraYellow = 0;
       uint16 auraBlue = 0;
       if (angel.aura == 1)  {auraBlue = 1;} //blue aura
       if (angel.aura == 2)  {auraYellow = 1;} //yellow Aura 
       if (angel.aura == 3)  {auraBlue = 1; auraRed = 1;} //purple Aura
       if (angel.aura == 4)  {auraYellow = 1; auraRed = 1;} //orange Aura  
       if (angel.aura == 5)  {auraRed = 1;} //red Aura
       if (angel.aura == 6)  {auraBlue = 1; auraYellow =1;} //green Aura
       ABTokenData.mintABToken(angel.owner,angel.angelCardSeriesId, angel.battlePower, auraRed, auraYellow, auraBlue,"0",0, uint16(angel.angelId));
  }
       
       
        
     
      function kill() onlyCREATOR external {
        selfdestruct(creatorAddress);
    }
}