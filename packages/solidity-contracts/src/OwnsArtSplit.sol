/**
 * Source Code first verified at https://etherscan.io on Sunday, May 5, 2019
 (UTC) */

pragma solidity ^0.5.0;

contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}


contract Bank is DSMath {
  mapping(address => uint) public balances;

  function deposit() public payable returns (uint balance) {
    balances[msg.sender] = add(balances[msg.sender], msg.value);
    return balances[msg.sender];
  }

  function withdraw(uint amount) public returns (uint remainingBalance){
    require(min(amount,balances[msg.sender]) == amount);
    balances[msg.sender] = sub(balances[msg.sender],amount);
    msg.sender.transfer(amount);
    return balances[msg.sender];
  }

  function balance() view public returns (uint) {
    return balances[msg.sender];
  }
}


contract OwnsArtSplit is DSMath, Bank{
    struct Bundle{
        address owner;
        uint decayedTime;
    }
    //8 bits: exponent
    //124 bits: generation
    //124 bits: sibling
    uint public constant exponentMask    = 0xff00000000000000000000000000000000000000000000000000000000000000;
    uint public constant generationMask  = 0x00fffffffffffffffffffffffffffffff0000000000000000000000000000000;
    uint public constant siblingMask     = 0xff0000000000000000000000000000000fffffffffffffffffffffffffffffff;
    mapping(uint => Bundle) public bundleTable;
    
    //maps the bundle exponent to find sibling for that bundle size
    //next sibling for generation
    mapping(uint8 => mapping(uint128 => uint128)) public siblingTable;

    address public artist;
    uint public constant price = 0.01 ether;
    uint public constant resaleFee = 0.001 ether;
    uint public constant maxBundlesPerPurchase = 0xff;
    uint public constant maxBundleExponent = 16;
    uint public constant artDecayTime = 30 days;
    uint public constant itemsPerBundle = 10;
    
    bool private buyArtMutex = false;
    
    event LogPurchase(uint[] destroyedBundleID, uint[] createdBundleID1, uint[] createdBundleID2, uint decay, address buyer);
    event LogBundling(uint[] bundledIDs, uint newBundleID, uint decay, address bundler);
    event LogUnbundling(uint unbundledID, uint[] newBundleIDs, uint decay, address bundler);
    
    constructor() public {
        artist = msg.sender;
        bundleTable[0] = Bundle(msg.sender, now+artDecayTime);
        siblingTable[0][0] = 1;
    }
    
    function buyArtworkBundles(uint[] memory bundleIDs) public{
        require(min(bundleIDs.length,maxBundlesPerPurchase)==bundleIDs.length,"Cannot buy too many bundles at once.");
        uint8 numberOfBundles = uint8(bundleIDs.length);
        require(numberOfBundles != 0,"Must buy more than zero bundles.");
        
        uint[] memory createdBundleID1  = new uint[](numberOfBundles);
        uint[] memory createdBundleID2  = new uint[](numberOfBundles);
        
        require(!buyArtMutex,"Only one person can buy bundles at the same time. Try again later.");
        buyArtMutex = true;
        
        for (uint i=0; i<numberOfBundles; i++) {
            Bundle memory bundle = bundleTable[bundleIDs[i]];
            (uint128 generation, , uint8 exponent) = splitBundleID(bundleIDs[i]);
            require(testValidBundle(bundle),"Bundle is invalid. Check decaytime, existence.");
            require(bundle.owner != msg.sender,"Buyer cannot be same as current owner.");
            require(min(exponent,maxBundleExponent)==exponent,"Exponent cannot be too large");

            //sell old bundle
            uint multiplier = itemsPerBundle**uint(exponent);
            balances[msg.sender] = sub(balances[msg.sender],price*multiplier);
            balances[bundle.owner] = add(balances[bundle.owner],sub(price*multiplier,resaleFee*multiplier));
            balances[artist] = add(balances[artist],resaleFee*multiplier);
            
            //destroy old bundle
            delete bundleTable[bundleIDs[i]] ;//= bundle;
            
            //create two new bundles
            uint128 sibling = siblingTable[exponent][generation+1];
            uint bundleID1 = generateBundleID(generation+1,sibling,exponent);
            uint bundleID2 = generateBundleID(generation+1,sibling+1,exponent);
            Bundle memory newBundle = Bundle(msg.sender, add(now, artDecayTime));
            bundleTable[bundleID1] = newBundle;
            bundleTable[bundleID2] = newBundle;
            
            //save IDs for logging
            createdBundleID1[i] = bundleID1;
            createdBundleID2[i] = bundleID2;
            
            //update next sibling
            siblingTable[exponent][generation+1] = siblingTable[exponent][generation+1] + 2;
        }
        
        emit LogPurchase(bundleIDs,createdBundleID1,createdBundleID2,add(now,artDecayTime),msg.sender);
        
        buyArtMutex = false;
    }
    
    function bundling(uint[] memory bundleIDs) public{
        require(bundleIDs.length == itemsPerBundle);
        //prevent bundling that goes over maxBundleExponent
        (,,uint8 exponent) = splitBundleID(bundleIDs[0]);
        require(min(exponent,maxBundleExponent-1)==exponent);
        
        
        //deactivate and test old bundles
        uint soonestDecay = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
        for (uint i=0; i<itemsPerBundle; i++){
            Bundle memory bundle = bundleTable[bundleIDs[i]];
            (,,uint8 currentExponent) = splitBundleID(bundleIDs[i]);
            require(currentExponent == exponent,"All bundles must have the same exponent");
            require(testValidBundle(bundle),"Bundle is invalid. Check decaytime, existence.");
            require(bundle.owner == msg.sender, "Cannot bundle items sender does not own.");
            delete bundleTable[bundleIDs[i]];
            if(min(soonestDecay,bundle.decayedTime)==bundle.decayedTime){
                soonestDecay = bundle.decayedTime;
            }
        }
        
        //generate new bundle
        uint128 generation = 0;
        uint128 sibling = siblingTable[exponent+1][generation];
        uint newBundleID = generateBundleID(generation,sibling,exponent+1);
        bundleTable[newBundleID] = Bundle(msg.sender, soonestDecay);
        siblingTable[exponent+1][generation] = sibling + 1;
        
        emit LogBundling(bundleIDs,newBundleID,soonestDecay,msg.sender);
    }
    
    function unbundling(uint bundleID) public{
        (,,uint8 exponent) = splitBundleID(bundleID);
        require(min(exponent,maxBundleExponent)==exponent,"Exponent must be less than max.");
        require(min(exponent,0)!=exponent,"Bundle must have an exponent greater than 0.");
        Bundle memory bundle = bundleTable[bundleID];
        require(testValidBundle(bundle),"Bundle is invalid. Check decaytime, existence.");
        require(bundle.owner == msg.sender,"Can only unbundle items owned by sender.");
        Bundle memory newBundle = Bundle(msg.sender,bundle.decayedTime);
        uint[] memory newBundleIDs = new uint[](10);
        for (uint i=0; i<itemsPerBundle; i++){
            uint id = generateBundleID(0,siblingTable[exponent-1][0],exponent-1);
            bundleTable[id] = newBundle;
            newBundleIDs[i] = id;
            siblingTable[exponent-1][0] = siblingTable[exponent-1][0] + 1;
        }
        delete bundleTable[bundleID];
        
        emit LogUnbundling(bundleID,newBundleIDs,newBundle.decayedTime,msg.sender);
    }
    
    function splitBundleID(uint bundleID) pure public returns (uint128 generation, uint128 sibling, uint8 exponent){
        return(uint128((bundleID&generationMask)>>124),uint128((bundleID&siblingMask)),uint8((bundleID&exponentMask)>>248));
    }
    
    function generateBundleID(uint128 generation, uint128 sibling, uint8 exponent) pure public returns(uint bundleID){
        return (uint(generation) << 124) | uint(sibling) | (uint(exponent) << 248);
    }
    
    function testValidBundle(Bundle memory bundle) view private returns (bool){
        return 
            (bundle.decayedTime != 0) &&
            (!isDecayed(bundle.decayedTime));
    }

    function isDecayed(uint decayedTime) view public returns (bool){
        return (min(now,decayedTime) != now);
    }
}