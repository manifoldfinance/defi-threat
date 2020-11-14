/**
 * Source Code first verified at https://etherscan.io on Sunday, April 21, 2019
 (UTC) */

pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }
    uint256 c = a * b;
    require(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0);
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;
    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

library BnsLib {
  struct TopLevelDomain {
    uint price;
    uint lastUpdate;
    bool min;
    bool exists;
  }

  struct Domain {
    address owner;
    bool allowSubdomains;
    string content;
    mapping(string => string) domainStorage;
    mapping(address => bool) approvedForSubdomain;
  }

  function hasOnlyDomainLevelCharacters(bytes memory self) internal pure returns (bool) {
    /* [9-0] [a-z] [-] */
    for(uint i; i<self.length; i++) {
      bytes1 char = self[i];
      if (! (
        (char >= 0x30 && char <= 0x39) ||
        (char >= 0x61 && char <= 0x7A) ||
        (char == 0x2d)
      )) return false;
    }
    return true;
  }

  function join(bytes memory self, bytes memory addStr, bytes1 delimiter) 
  internal pure returns (bytes memory) {
    /* Allow [0-9] [a-z] [-] Make [A-Z] lowercase */
    uint retSize = self.length + addStr.length + 1;
    bytes memory ret = new bytes(retSize);
    for (uint i = 0; i < self.length; i ++) ret[i] = self[i];
    ret[self.length] = delimiter;
    for (uint x = 0; x < addStr.length; x ++) {
      ret[self.length + x + 1] = addStr[x];
    }
    return bytes(ret);
  }

  function toLowercase(string memory self, bool allowDecimal, bool allowAt) 
  internal pure returns (bytes memory) {
    bytes memory s1 = bytes(self);
    bytes memory ret = new bytes(s1.length);
    for (uint i = 0; i < s1.length; i ++) {
      require(
        (s1[i] >= 0x30 && s1[i] <= 0x39) || // 0-9
        (s1[i] >= 0x41 && s1[i] <= 0x5A) || // A-Z
        (s1[i] >= 0x61 && s1[i] <= 0x7A) || // a-z
        (s1[i] == 0x2d || s1[i] == 0x5f ) ||
        (allowDecimal && s1[i] == 0x2e) ||
        (allowAt && s1[i] == 0x40), // -  _
        "Invalid character."
      );
      if (s1[i] >= 0x41 && s1[i] <= 0x5A) ret[i] = bytes1(uint8(s1[i]) + 32);
      else ret[i] = s1[i];
    }
    return ret;
  }
}

contract BetterNameService {
  using BnsLib for *;
  using SafeMath for uint;


  constructor() public {
    createTopLevelDomain("bns");
    creat0r = msg.sender;
  }

  
  address creat0r;  
  uint updateAfter = 15000; // target around 1 update per day
  uint minPrice = 10000000000000000; // 0.01 eth

  mapping(bytes => BnsLib.TopLevelDomain) internal tldPrices;
  mapping(bytes => BnsLib.Domain) domains; // domain and subdomain owners
  mapping(address => bytes[]) public ownedDomains;


  function withdraw(uint amount) public {
    require(msg.sender == creat0r, "Only the creat0r can call that.");
    msg.sender.transfer(amount);
  }

  function balanceOf() public view returns (uint) {
    return address(this).balance;
  }



/*----------------<BEGIN MODIFIERS>----------------*/
  function tldExists(bytes memory tld) public view returns (bool) {
    return tldPrices[tld].exists;
  }

  function tldNotExists(bytes memory tld) public view returns (bool) {
    return !tldPrices[tld].exists;
  }

  modifier domainExists(bytes memory domain) {
    require(
      domains[domain].owner != address(0) &&
      domains[domain].owner != address(0x01),
      "Domain does not exist"
    );
    _;
  }

  modifier domainNotExists(bytes memory domain) {
    require(domains[domain].owner == address(0), "Domain exists");
    _;
  }

  modifier onlyDomainOwner(bytes memory domain) {
    require(msg.sender == domains[domain].owner, "Not domain owner");
    _;
  }

  modifier onlyAllowed(bytes memory domain) {
    require(
      domains[domain].allowSubdomains ||
      domains[domain].owner == msg.sender ||
      domains[domain].approvedForSubdomain[msg.sender],
      "User not approved for domain"
    );
    _;
  }

  function requireOwner(bytes memory domain, address addr) internal {
    require(domains[domain].owner == addr, "Not domain owner.");
  }
/*----------------</END MODIFIERS>----------------*/



/*----------------<BEGIN EVENTS>----------------*/
  event TopLevelDomainCreated(bytes32 indexed tldHash, bytes tld);
  event TopLevelDomainPriceUpdated(bytes32 indexed tldHash, bytes tld, uint price);

  event DomainRegistered(bytes32 indexed domainHash, 
  bytes domain, address owner, 
  address registeredBy, bool open);

  event SubdomainDeleted(bytes32 indexed subdomainHash, 
  bytes subdomain, address deletedBy);

  event DomainRegistrationOpened(bytes32 indexed domainHash, bytes domain);
  event DomainRegistrationClosed(bytes32 indexed domainHash, bytes domain);

  event ApprovedForDomain(bytes32 indexed domainHash, bytes domain, address indexed approved);
  event DisapprovedForDomain(bytes32 indexed domainHash, 
  bytes domain, address indexed disapproved);

  event ContentUpdated(bytes32 indexed domainHash, bytes domain, string content);
/*----------------</END EVENTS>----------------*/



/*----------------<BEGIN VIEW FUNCTIONS>----------------*/
  function reverseLookup(address owner) public view returns (string[] memory) {
    bytes[] memory ownedB = ownedDomains[owner];
    string[] memory _owned = new string[](ownedB.length);
    for (uint i = 0; i < ownedB.length; i++) {
      _owned[i] = string(ownedB[i]);
    }
    return _owned;
  }

  function getTldPrice(string memory _tld) public view returns (uint) {
    bytes memory tld = _tld.toLowercase(false, false);
    return tldPrices[tld].min ? minPrice : tldPrices[tld].price;
  }

  function expectedTldPrice(bytes memory tld) public view returns (uint) {
    if (tldPrices[tld].min) return minPrice;
    uint blockCount = block.number.sub(tldPrices[tld].lastUpdate);
    if (blockCount >= updateAfter) {
      uint updatesDue = blockCount.div(updateAfter);
      uint newPrice = tldPrices[tld].price.mul(750**updatesDue).div(1000**updatesDue);
      if (newPrice <= minPrice) return minPrice;
      return newPrice;
    }
    return tldPrices[tld].price;
  }
  function getDomainOwner(string memory domain) public view returns (address) {
    return domains[domain.toLowercase(true, true)].owner;
  }

  function isPublicDomainRegistrationOpen(string memory domain) public view returns (bool) {
    return domains[domain.toLowercase(true, true)].allowSubdomains;
  }
  
  function isApprovedToRegister(string memory domain, address addr) 
  public view returns (bool) {
    return domains[domain.toLowercase(true, true)].allowSubdomains || 
      domains[domain.toLowercase(true, true)].owner == addr || 
      domains[domain.toLowercase(true, true)].approvedForSubdomain[addr];
  }

  function isDomainDeleted(string memory domain) public view returns(bool) {
    return domains[domain.toLowercase(true, true)].owner == address(0x01);
  }

  function getContent(string memory domain) public view returns (string memory) {
    return domains[domain.toLowercase(true, true)].content;
  }


  /*<BEGIN STORAGE FUNCTIONS>*/
  function getDomainStorageSingle(string memory domain, string memory key) 
  public view returns (string memory) {
    return domains[domain.toLowercase(true, true)].domainStorage[key];
  }

  function getDomainStorageMany(string memory _domain, string[] memory keys) 
  public view returns (string[2][]) {
    bytes memory domain = _domain.toLowercase(true, true);
    string[2][] memory results = new string[2][](keys.length);
    for(uint i = 0; i < keys.length; i++) {
      string memory key = keys[i];
      results[i] = [key, domains[domain].domainStorage[key]];
    }
    return results;
  }
  /*</END STORAGE FUNCTIONS>*/
/*----------------</END VIEW FUNCTIONS>----------------*/



/*----------------<BEGIN PRICE FUNCTIONS>----------------*/
  function returnRemainder(uint price) internal {
    if (msg.value > price) msg.sender.transfer(msg.value.sub(price));
  }

  function updateTldPrice(bytes memory tld) public returns (uint) {
    if (!tldPrices[tld].min) {
      // tld price has not reached the minimum price
      uint price = expectedTldPrice(tld);
      if (price != tldPrices[tld].price) {
        if (price == minPrice) {
          tldPrices[tld].min = true;
          tldPrices[tld].price = 0;
          tldPrices[tld].lastUpdate = 0;
        } else {
          tldPrices[tld].price = price;
          tldPrices[tld].lastUpdate = block.number.sub((block.number.sub(tldPrices[tld].lastUpdate)).mod(updateAfter));
        }
        emit TopLevelDomainPriceUpdated(keccak256(abi.encode(tld)), tld, price);
      }
      return price;
    }
    else return minPrice;
  }
/*----------------</END PRICE FUNCTIONS>----------------*/



/*----------------<BEGIN DOMAIN REGISTRATION FUNCTIONS>----------------*/
  /*<BEGIN TLD FUNCTIONS>*/
  function createTopLevelDomain(string memory _tld) 
  public {
    bytes memory tld = _tld.toLowercase(false, false);
    require(!tldPrices[tld].exists, "TLD exists");
    tldPrices[tld] = BnsLib.TopLevelDomain({
      price: 5000000000000000000,
      lastUpdate: block.number,
      exists: true,
      min: false
    });
    emit TopLevelDomainCreated(keccak256(abi.encode(tld)), tld);
  }
  /*</END TLD FUNCTIONS>*/


  /*<BEGIN INTERNAL REGISTRATION FUNCTIONS>*/
  function _register(bytes memory domain, address owner, bool open) 
  internal domainNotExists(domain) {
    domains[domain].owner = owner;
    emit DomainRegistered(keccak256(abi.encode(domain)), domain, owner, msg.sender, open);
    if (open) domains[domain].allowSubdomains = true;
    ownedDomains[owner].push(domain);
  }

  function _registerDomain(string memory _domain, string memory _tld, bool open) 
  internal {
    bytes memory tld = _tld.toLowercase(false, false);
    require(tldExists(tld), "TLD does not exist");
    bytes memory domain = _domain.toLowercase(false, false);
    uint price = updateTldPrice(tld);
    require(msg.value >= price, "Insufficient price.");
    _register(domain.join(tld, 0x40), msg.sender, open);
    returnRemainder(price);
  }

  function _registerSubdomain(
    bytes memory subdomain, bytes memory domain, address owner, bool open) 
  internal domainExists(domain) onlyAllowed(domain) {
    _register(subdomain.join(domain, 0x2e), owner, open);
  }
  /*</END INTERNAL REGISTRATION FUNCTIONS>*/


  /*<BEGIN REGISTRATION OVERLOADS>*/
  function registerDomain(string memory domain, bool open) public payable {
    _registerDomain(domain, "bns", open);
  }

  function registerDomain(string memory domain, string memory tld, bool open) public payable {
    _registerDomain(domain, tld, open);
  }
  /*</END REGISTRATION OVERLOADS>*/


  /*<BEGIN SUBDOMAIN REGISTRATION OVERLOADS>*/
  function registerSubdomain(string memory _subdomain, string memory _domain, bool open) public {
    bytes memory subdomain = _subdomain.toLowercase(false, false);
    bytes memory domain = _domain.toLowercase(true, true);
    _registerSubdomain(subdomain, domain, msg.sender, open);
  }

  function registerSubdomainAsDomainOwner(
    string memory _subdomain, string memory _domain, address subdomainOwner) 
  public {
    bytes memory domain = _domain.toLowercase(true, true);
    requireOwner(domain, msg.sender);
    bytes memory subdomain = _subdomain.toLowercase(false, false);
    _registerSubdomain(subdomain, domain, subdomainOwner, false);
  }
  /*</END SUBDOMAIN REGISTRATION OVERLOADS>*/
/*----------------</END DOMAIN REGISTRATION FUNCTIONS>----------------*/



/*----------------<BEGIN DOMAIN MANAGEMENT FUNCTIONS>----------------*/
  function transferDomain(string memory _domain, address recipient) public {
    bytes memory domain = _domain.toLowercase(true, true);
    requireOwner(domain, msg.sender);
    domains[domain].owner = recipient;
  }

  /*<BEGIN CONTENT HASH FUNCTIONS>*/
  function setContent(string memory _domain, string memory content) 
  public {
    bytes memory domain = _domain.toLowercase(true, true);
    requireOwner(domain, msg.sender);
    domains[domain].content = content;
    emit ContentUpdated(keccak256(abi.encode(domain)), domain, content);
  }

  function deleteContent(string memory _domain) public {
    bytes memory domain = _domain.toLowercase(true, true);
    requireOwner(domain, msg.sender);
    delete domains[domain].content;
    emit ContentUpdated(keccak256(abi.encode(domain)), domain, domains[domain].content);
  }
  /*</END CONTENT HASH FUNCTIONS>*/


  /*<BEGIN APPROVAL FUNCTIONS>*/
  function approveForSubdomain(string memory _domain, address user) public {
    bytes memory domain = _domain.toLowercase(true, true);
    requireOwner(domain, msg.sender);
    domains[domain].approvedForSubdomain[user] = true;
    emit ApprovedForDomain(keccak256(abi.encode(domain)), domain, user);
  }

  function disapproveForSubdomain(string memory _domain, address user) 
  public {
    bytes memory domain = _domain.toLowercase(true, true);
    requireOwner(domain, msg.sender);
    domains[domain].approvedForSubdomain[user] = false;
    emit DisapprovedForDomain(keccak256(abi.encode(domain)), domain, user);
  }
  /*</END APPROVAL FUNCTIONS>*/


  /*<BEGIN DELETION FUNCTIONS>*/
  function _deleteDomain(bytes memory domain) internal {
    domains[domain].owner = address(0x01);
    emit SubdomainDeleted(keccak256(abi.encode(domain)), domain, msg.sender);
  }

  function deleteDomain(string memory _domain) public {
    bytes memory domain = _domain.toLowercase(true, true);
    requireOwner(domain, msg.sender);
    _deleteDomain(domain);
  }

  function deleteSubdomainAsDomainOwner(string memory _subdomain, string memory _domain) 
  public {
    bytes memory domain = _domain.toLowercase(true, true);
    bytes memory subdomain = _subdomain.toLowercase(false, false);
    requireOwner(domain, msg.sender);
    _deleteDomain(subdomain.join(domain, 0x2e));
  }
  /*</END DELETION FUNCTIONS>*/


  /*<BEGIN RESTRICTION FUNCTIONS>*/
  function openPublicDomainRegistration(string memory _domain) public {
    bytes memory domain = _domain.toLowercase(true, true);
    requireOwner(domain, msg.sender);
    domains[domain].allowSubdomains = true;
    emit DomainRegistrationOpened(keccak256(abi.encode(domain)), domain);
  }

  function closePublicDomainRegistration(string memory _domain) public {
    bytes memory domain = _domain.toLowercase(true, true);
    requireOwner(domain, msg.sender);
    domains[domain].allowSubdomains = false;
    emit DomainRegistrationClosed(keccak256(abi.encode(domain)), domain);
  }
  /*</END RESTRICTION FUNCTIONS>*/


  /*<BEGIN STORAGE FUNCTIONS>*/
  function setDomainStorageSingle(string memory _domain, string memory key, string memory value) 
  public {
    bytes memory domain = _domain.toLowercase(true, true);
    requireOwner(domain, msg.sender);
    domains[domain].domainStorage[key] = value;
  }

  function setDomainStorageMany(string memory _domain, string[2][] memory kvPairs) 
  public {
    bytes memory domain = _domain.toLowercase(true, true);
    requireOwner(domain, msg.sender);
    for(uint i = 0; i < kvPairs.length; i++) {
      domains[domain].domainStorage[kvPairs[i][0]] = kvPairs[i][1];
    }
  }
  /*</END STORAGE FUNCTIONS>*/
/*----------------</END DOMAIN MANAGEMENT FUNCTIONS>----------------*/
}