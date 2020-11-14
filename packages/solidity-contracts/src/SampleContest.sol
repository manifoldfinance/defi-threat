/**
 * Source Code first verified at https://etherscan.io on Thursday, May 9, 2019
 (UTC) */

// File: contracts/lib/ownership/Ownable.sol

pragma solidity ^0.4.24;

contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);

    /// @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
    constructor() public { owner = msg.sender; }

    /// @dev Throws if called by any contract other than latest designated caller
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /// @dev Allows the current owner to transfer control of the contract to a newOwner.
    /// @param newOwner The address to transfer ownership to.
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

// File: contracts/lib/token/FactoryTokenInterface.sol

pragma solidity ^0.4.24;


contract FactoryTokenInterface is Ownable {
    function balanceOf(address _owner) public view returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
    function approve(address _spender, uint256 _value) public returns (bool);
    function allowance(address _owner, address _spender) public view returns (uint256);
    function mint(address _to, uint256 _amount) public returns (bool);
    function burnFrom(address _from, uint256 _value) public;
}

// File: contracts/lib/token/TokenFactoryInterface.sol

pragma solidity ^0.4.24;


contract TokenFactoryInterface {
    function create(string _name, string _symbol) public returns (FactoryTokenInterface);
}

// File: contracts/lib/ownership/ZapCoordinatorInterface.sol

pragma solidity ^0.4.24;


contract ZapCoordinatorInterface is Ownable {
    function addImmutableContract(string contractName, address newAddress) external;
    function updateContract(string contractName, address newAddress) external;
    function getContractName(uint index) public view returns (string);
    function getContract(string contractName) public view returns (address);
    function updateAllDependencies() external;
}

// File: contracts/platform/bondage/BondageInterface.sol

pragma solidity ^0.4.24;

contract BondageInterface {
    function bond(address, bytes32, uint256) external returns(uint256);
    function unbond(address, bytes32, uint256) external returns (uint256);
    function delegateBond(address, address, bytes32, uint256) external returns(uint256);
    function escrowDots(address, address, bytes32, uint256) external returns (bool);
    function releaseDots(address, address, bytes32, uint256) external returns (bool);
    function returnDots(address, address, bytes32, uint256) external returns (bool success);
    function calcZapForDots(address, bytes32, uint256) external view returns (uint256);
    function currentCostOfDot(address, bytes32, uint256) public view returns (uint256);
    function getDotsIssued(address, bytes32) public view returns (uint256);
    function getBoundDots(address, address, bytes32) public view returns (uint256);
    function getZapBound(address, bytes32) public view returns (uint256);
    function dotLimit( address, bytes32) public view returns (uint256);
}

// File: contracts/platform/bondage/currentCost/CurrentCostInterface.sol

pragma solidity ^0.4.24;

contract CurrentCostInterface {
    function _currentCostOfDot(address, bytes32, uint256) public view returns (uint256);
    function _dotLimit(address, bytes32) public view returns (uint256);
    function _costOfNDots(address, bytes32, uint256, uint256) public view returns (uint256);
}

// File: contracts/platform/registry/RegistryInterface.sol

pragma solidity ^0.4.24;

contract RegistryInterface {
    function initiateProvider(uint256, bytes32) public returns (bool);
    function initiateProviderCurve(bytes32, int256[], address) public returns (bool);
    function setEndpointParams(bytes32, bytes32[]) public;
    function getEndpointParams(address, bytes32) public view returns (bytes32[]);
    function getProviderPublicKey(address) public view returns (uint256);
    function getProviderTitle(address) public view returns (bytes32);
    function setProviderParameter(bytes32, bytes) public;
    function setProviderTitle(bytes32) public;
    function clearEndpoint(bytes32) public;
    function getProviderParameter(address, bytes32) public view returns (bytes);
    function getAllProviderParams(address) public view returns (bytes32[]);
    function getProviderCurveLength(address, bytes32) public view returns (uint256);
    function getProviderCurve(address, bytes32) public view returns (int[]);
    function isProviderInitiated(address) public view returns (bool);
    function getAllOracles() external view returns (address[]);
    function getProviderEndpoints(address) public view returns (bytes32[]);
    function getEndpointBroker(address, bytes32) public view returns (address);
}

// File: contracts/lib/platform/SampleContest.sol

/*
Contest where users can bond to contestant curves which mint tokens( unbondabe*), 
winner decided by oracle
contract unbonds from loser curves
holders of winning token allowed to take share of reserve token(zap) which was unbonded from loser curves

Starting Contest:
    
    deploys with contest uninitialized: status = Uninitialized
    
    anyone can initialize new token:backed curve 
    
    owner initializes contest with oracle: status = Initialized

Ending Contest:
    
    owner calls close: status = ReadyToSettle
    
    oracle calls judge to set winning curve: status = Judged
    
    anyone calls settle, contest unbonds from losing curves: status = Settled
    
    holders of winnning token call redeem to retrieve their share of reserve token 
    based on their holding of winning token
    
    *holders of winning token can optionally unbond 
*/

contract SampleContest is Ownable {

    CurrentCostInterface currentCost;
    FactoryTokenInterface public reserveToken;
    ZapCoordinatorInterface public coord;
    TokenFactoryInterface public tokenFactory;
    BondageInterface bondage;

    enum ContestStatus { 
        Uninitialized,    //  
        Initialized,      // ready for buys
        ReadyToSettle,    // ready for judgement 
        Judged,           // winner determined 
        Settled,           // value of winning tokens determined 
        Canceled          // oracle did not respond in time
    }

    address public oracle;    // address of oracle who will choose the winner
    uint256 public ttl;    // time allowed before, close and judge. if time expired, allow unbond from all curves 
    uint256 public expired = 2**256 -1;    // time allowed before, close and judge. if time expired, allow unbond from all curves 
    bytes32 public winner;    // curve identifier of the winner 
    uint256 public winValue;  // final value of the winning token
    ContestStatus public status; //state of contest

    mapping(bytes32 => address) public curves; // map of endpoint specifier to token-backed dotaddress
    bytes32[] public curves_list; // array of endpoint specifiers

    mapping(address => uint8) public redeemed; // map of address redemption state
    address[] public redeemed_list;
    
    event DotTokenCreated(address tokenAddress);
    event Bonded(bytes32 indexed endpoint, uint256 indexed numDots, address indexed sender); 
    event Unbonded(bytes32 indexed endpoint, uint256 indexed numDots, address indexed sender);

    event Initialized(address indexed oracle);
    event Closed();
    event Judged(bytes32 winner);
    event Settled(uint256 winValue, uint256 winTokens); 
    event Reset();

    constructor(
        address coordinator, 
        address factory,
        uint256 providerPubKey,
        bytes32 providerTitle 
    ){
        coord = ZapCoordinatorInterface(coordinator); 
        reserveToken = FactoryTokenInterface(coord.getContract("ZAP_TOKEN"));
        //always allow bondage to transfer from wallet
        reserveToken.approve(coord.getContract("BONDAGE"), ~uint256(0));
        tokenFactory = TokenFactoryInterface(factory);

        RegistryInterface registry = RegistryInterface(coord.getContract("REGISTRY")); 
        registry.initiateProvider(providerPubKey, providerTitle);
        status = ContestStatus.Uninitialized;
    }

// contest lifecycle
 
    function initializeContest(
        address oracleAddress,
        uint256 _ttl
    ) onlyOwner public {
        require( status == ContestStatus.Uninitialized, "Contest already initialized");
        oracle = oracleAddress;
        ttl = _ttl;
        status = ContestStatus.Initialized;
        emit Initialized(oracle);
    }

    function close() onlyOwner {
        status = ContestStatus.ReadyToSettle; 
        expired = block.number + ttl; 
        emit Closed();
    }

    function judge(bytes32 endpoint) {
        require( status == ContestStatus.ReadyToSettle, "not closed" );
        require( msg.sender == oracle, "not oracle");
        winner = endpoint;
        status = ContestStatus.Judged;
        emit Judged(winner);
    }

    function settle() {
        require( status == ContestStatus.Judged, "winner not determined");

        bondage = BondageInterface(coord.getContract("BONDAGE"));
        uint256 dots;
        for( uint256 i = 0; i < curves_list.length; i++) {

            if(curves_list[i] != winner) {
                dots =  bondage.getDotsIssued(address(this), curves_list[i]);  
                if( dots > 0) {
                    bondage.unbond(address(this), curves_list[i], dots);                 
                }  
            }
        } 

        // how many winning dots    
        uint256 numWin =  bondage.getDotsIssued(address(this), winner);  
        // redeemable value of each dot token
        winValue = reserveToken.balanceOf(address(this)) / numWin;
        status = ContestStatus.Settled;
        emit Settled(winValue, numWin);
    }


    //TODO ensure all has been redeemed or enough time has elasped 
    function reset() public {
        require(msg.sender == oracle);
        require(status == ContestStatus.Settled || status == ContestStatus.Canceled, "contest not settled");
        if( status == ContestStatus.Canceled ) {
            require(reserveToken.balanceOf(address(this)) == 0, "funds remain");
        }

        delete redeemed_list;
        delete curves_list;
        status = ContestStatus.Initialized; 
        emit Reset();
    }

/// TokenDotFactory methods

    function initializeCurve(
        bytes32 endpoint, 
        bytes32 symbol, 
        int256[] curve
    ) public returns(address) {
        
        require(curves[endpoint] == 0, "Curve endpoint already exists or used in the past. Please choose new");
        
        RegistryInterface registry = RegistryInterface(coord.getContract("REGISTRY")); 
        require(registry.isProviderInitiated(address(this)), "Provider not intiialized");

        registry.initiateProviderCurve(endpoint, curve, address(this));
        curves[endpoint] = newToken(bytes32ToString(endpoint), bytes32ToString(symbol));
        curves_list.push(endpoint);        
        registry.setProviderParameter(endpoint, toBytes(curves[endpoint]));
        
        DotTokenCreated(curves[endpoint]);
        return curves[endpoint];
    }

    //whether this contract holds tokens or coming from msg.sender,etc
    function bond(bytes32 endpoint, uint numDots) public  {

        require( status == ContestStatus.Initialized, " contest not live"); 

        bondage = BondageInterface(coord.getContract("BONDAGE"));
        uint256 issued = bondage.getDotsIssued(address(this), endpoint);

        CurrentCostInterface cost = CurrentCostInterface(coord.getContract("CURRENT_COST"));
        uint256 numReserve = cost._costOfNDots(address(this), endpoint, issued + 1, numDots - 1);

        require(
            reserveToken.transferFrom(msg.sender, address(this), numReserve),
            "insufficient accepted token numDots approved for transfer"
        );

        reserveToken.approve(address(bondage), numReserve);
        bondage.bond(address(this), endpoint, numDots);
        FactoryTokenInterface(curves[endpoint]).mint(msg.sender, numDots);
        emit Bonded(endpoint, numDots, msg.sender);
    }

    //whether this contract holds tokens or coming from msg.sender,etc
    function unbond(bytes32 endpoint, uint numDots) public {

        require( status == ContestStatus.ReadyToSettle || status == ContestStatus.Settled, "not ready");

        bondage = BondageInterface(coord.getContract("BONDAGE"));
        uint issued = bondage.getDotsIssued(address(this), endpoint);

        //unbond dots
        bondage.unbond(address(this), winner, numDots);

        currentCost = CurrentCostInterface(coord.getContract("CURRENT_COST"));
        //get reserve value to send 
        uint reserveCost = currentCost._costOfNDots(address(this), endpoint, issued + 1 - numDots, numDots - 1);

        FactoryTokenInterface curveToken = FactoryTokenInterface(curves[endpoint]);

        if( status == ContestStatus.ReadyToSettle || status == ContestStatus.Canceled) {
            
            status = ContestStatus.Canceled;
            //oracle has taken too long to judge winner so unbonds will be allowed for all
            require(block.number > expired, "oracle query not expired.");
            require( status == ContestStatus.ReadyToSettle, "contest not ready to settle");

            //unbond dots
            bondage.unbond(address(this), endpoint, numDots);

            //burn dot backed token
            curveToken.burnFrom(msg.sender, numDots);

            require(reserveToken.transfer(msg.sender, reserveCost), "transfer failed");
            Unbonded(endpoint, numDots, msg.sender);
        }

        else {

            require( status == ContestStatus.Settled, " contest not settled"); 
            require(redeemed[msg.sender] == 0, "already redeeemed");
            require(winner==endpoint, "only winners can unbond for rewards"); 

            //reward user's winning tokens unbond value + share of losing curves reserve token proportional to winning token holdings
            uint reward = ( winValue * FactoryTokenInterface(getTokenAddress(winner)).balanceOf(msg.sender) ) + reserveCost;
            
            //burn user's unbonded tokens
            curveToken.burnFrom(msg.sender, numDots);

            reserveToken.transfer(msg.sender, reward);
            redeemed[msg.sender] = 1;

            emit Unbonded(winner, numDots, msg.sender);
        }
    }

    function newToken(
        string name,
        string symbol
    ) 
        public
        returns (address tokenAddress) 
    {
        FactoryTokenInterface token = tokenFactory.create(name, symbol);
        tokenAddress = address(token);
        return tokenAddress;
    }

    function getTokenAddress(bytes32 endpoint) public view returns(address) {
        RegistryInterface registry = RegistryInterface(coord.getContract("REGISTRY")); 
        return bytesToAddr(registry.getProviderParameter(address(this), endpoint));
    }

    // https://ethereum.stackexchange.com/questions/884/how-to-convert-an-address-to-bytes-in-solidity
    function toBytes(address x) public pure returns (bytes b) {
        b = new bytes(20);
        for (uint i = 0; i < 20; i++)
            b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));
    }

    //https://ethereum.stackexchange.com/questions/2519/how-to-convert-a-bytes32-to-string
    function bytes32ToString(bytes32 x) public pure returns (string) {
        bytes memory bytesString = new bytes(32);
        bytesString = abi.encodePacked(x);
        return string(bytesString);
    }

    //https://ethereum.stackexchange.com/questions/15350/how-to-convert-an-bytes-to-address-in-solidity
    function bytesToAddr (bytes b) public pure returns (address) {
        uint result = 0;
        for (uint i = b.length-1; i+1 > 0; i--) {
            uint c = uint(b[i]);
            uint to_inc = c * ( 16 ** ((b.length - i-1) * 2));
            result += to_inc;
        }
        return address(result);
    }
}