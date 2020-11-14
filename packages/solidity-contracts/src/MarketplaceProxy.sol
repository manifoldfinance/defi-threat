/**
 * Source Code first verified at https://etherscan.io on Sunday, April 28, 2019
 (UTC) */

pragma solidity ^0.5.0;

contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
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

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
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

contract TokenInterface {
    function allowance(address, address) public returns (uint);
    function balanceOf(address) public returns (uint);
    function approve(address, uint) public;
    function transfer(address, uint) public returns (bool);
    function transferFrom(address, address, uint) public returns (bool);
    function deposit() public payable;
    function withdraw(uint) public;
}

contract PipInterface {
    function read() public returns (bytes32);
}

contract PepInterface {
    function peek() public returns (bytes32, bool);
}

contract VoxInterface {
    function par() public returns (uint);
}

contract TubInterface {
    event LogNewCup(address indexed lad, bytes32 cup);

    function open() public returns (bytes32);
    function join(uint) public;
    function exit(uint) public;
    function lock(bytes32, uint) public;
    function free(bytes32, uint) public;
    function draw(bytes32, uint) public;
    function wipe(bytes32, uint) public;
    function give(bytes32, address) public;
    function shut(bytes32) public;
    function bite(bytes32) public;
    function cups(bytes32) public returns (address, uint, uint, uint);
    function gem() public returns (TokenInterface);
    function gov() public returns (TokenInterface);
    function skr() public returns (TokenInterface);
    function sai() public returns (TokenInterface);
    function vox() public returns (VoxInterface);
    function ask(uint) public returns (uint);
    function mat() public returns (uint);
    function chi() public returns (uint);
    function ink(bytes32) public returns (uint);
    function tab(bytes32) public returns (uint);
    function rap(bytes32) public returns (uint);
    function per() public returns (uint);
    function pip() public returns (PipInterface);
    function pep() public returns (PepInterface);
    function tag() public returns (uint);
    function drip() public;
    function lad(bytes32 cup) public view returns (address);
}

contract DSGuard {
    function canCall(address src_, address dst_, bytes4 sig) public view returns (bool);

    function permit(bytes32 src, bytes32 dst, bytes32 sig) public;
    function forbid(bytes32 src, bytes32 dst, bytes32 sig) public;

    function permit(address src, address dst, bytes32 sig) public;
    function forbid(address src, address dst, bytes32 sig) public;

}

contract DSGuardFactory {
    function newGuard() public returns (DSGuard guard);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);
}

contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        public
        auth
    {
        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig));
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}

contract DSProxyInterface {
    function execute(bytes memory _code, bytes memory _data) public payable returns (address, bytes32);

    function execute(address _target, bytes memory _data) public payable returns (bytes32);

    function setCache(address _cacheAddr) public payable returns (bool);

    function owner() public returns (address);
}


contract ProxyRegistryInterface {
    function proxies(address _owner) public view returns(DSProxyInterface);
    function build(address) public returns (address);
}

contract Marketplace is DSAuth, DSMath {

    struct SaleItem {
        address payable owner;
        address payable proxy;
        uint discount;
        bool active;
    }
 
    mapping (bytes32 => SaleItem) public items;
    mapping (bytes32 => uint) public itemPos;
    bytes32[] public itemsArr;

    address public marketplaceProxy;

    // 2 decimal percision when defining the disocunt value
    uint public fee = 100; //1% fee

    // KOVAN
    // ProxyRegistryInterface public registry = ProxyRegistryInterface(0x64A436ae831C1672AE81F674CAb8B6775df3475C);
    // TubInterface public tub = TubInterface(0xa71937147b55Deb8a530C7229C442Fd3F31b7db2);
    
    // MAINNET
    ProxyRegistryInterface public registry = ProxyRegistryInterface(0x4678f0a6958e4D2Bc4F1BAF7Bc52E8F3564f3fE4);
    TubInterface public tub = TubInterface(0x448a5065aeBB8E423F0896E6c5D525C040f59af3);

    event OnSale(bytes32 indexed cup, address indexed proxy, address owner, uint discount);

    event Bought(bytes32 indexed cup, address indexed newLad, address indexed oldProxy,
                address oldOwner, uint discount);

    constructor(address _marketplaceProxy) public {
        marketplaceProxy = _marketplaceProxy;
    }

    /// @notice User calls this method to put a CDP on sale which he must own
    /// @dev Must be called by DSProxy contract in order to authorize for sale
    /// @param _cup Id of the CDP that is being put on sale
    /// @param _discount Discount of the original value, goes from 0 - 99% with 2 decimal percision
    function putOnSale(bytes32 _cup, uint _discount) public {
        require(isOwner(msg.sender, _cup), "msg.sender must be proxy which owns the cup");
        require(_discount < 10000 && _discount > 100, "can't have 100% discount and must be over 1%");
        require(tub.ink(_cup) > 0 && tub.tab(_cup) > 0, "must have collateral and debt to put on sale");
        require(!isOnSale(_cup), "can't put a cdp on sale twice");

        address payable owner = address(uint160(DSProxyInterface(msg.sender).owner()));

        items[_cup] = SaleItem({
            discount: _discount,
            proxy: msg.sender,
            owner: owner,
            active: true
        });

        itemsArr.push(_cup);
        itemPos[_cup] = itemsArr.length - 1;

        emit OnSale(_cup, msg.sender, owner, _discount);
    }

    /// @notice Any user can call this method to buy a CDP
    /// @dev This will fail if the CDP owner was changed
    /// @param _cup Id of the CDP you want to buy
    function buy(bytes32 _cup, address _newOwner) public payable {
        SaleItem storage item = items[_cup];

        require(item.active == true, "Check if cup is on sale");
        require(item.proxy == tub.lad(_cup), "The owner must stay the same");

        uint cdpPrice;
        uint feeAmount;

        (cdpPrice, feeAmount) = getCdpPrice(_cup);

        require(msg.value >= cdpPrice, "Check if enough ether is sent for this cup");

        item.active = false;

        // give the cup to the buyer, him becoming the lad that owns the cup
        DSProxyInterface(item.proxy).execute(marketplaceProxy, 
            abi.encodeWithSignature("give(bytes32,address)", _cup, _newOwner));

        item.owner.transfer(sub(cdpPrice, feeAmount)); // transfer money to the seller

        emit Bought(_cup, msg.sender, item.proxy, item.owner, item.discount);

        removeItem(_cup);

    }

    /// @notice Remove the CDP from the marketplace
    /// @param _cup Id of the CDP
    function cancel(bytes32 _cup) public {
        require(isOwner(msg.sender, _cup), "msg.sender must proxy which owns the cup");
        require(isOnSale(_cup), "only cancel cdps that are on sale");
        
        removeItem(_cup);
    }

    /// @notice A only owner functon which withdraws Eth balance
    function withdraw() public auth {
        msg.sender.transfer(address(this).balance);
    }

    /// @notice Calculates the price of the CDP given the discount and the fee
    /// @param _cup Id of the CDP
    /// @return It returns the price of the CDP and the amount needed for the contracts fee
    function getCdpPrice(bytes32 _cup) public returns(uint, uint) {
        SaleItem memory item = items[_cup];

        uint collateral = rmul(tub.ink(_cup), tub.per()); // collateral in Eth
        uint govFee = wdiv(rmul(tub.tab(_cup), rdiv(tub.rap(_cup), tub.tab(_cup))), uint(tub.pip().read()));
        uint debt = add(govFee, wdiv(tub.tab(_cup), uint(tub.pip().read()))); // debt in Eth

        uint difference = 0;

        if (item.discount > fee) {
            difference = sub(item.discount, fee);
        } else {
            difference = item.discount;
        }

        uint cdpPrice = mul(sub(collateral, debt), (sub(10000, difference))) / 10000;
        uint feeAmount = mul(sub(collateral, debt), fee) / 10000;

        return (cdpPrice, feeAmount);
    }

    /// @notice Used by front to fetch what is on sale
    /// @return Returns all CDP ids that are on sale and are not closed
    function getItemsOnSale() public view returns(bytes32[] memory arr) {
        uint n = 0;

        arr = new bytes32[](itemsArr.length);
        for (uint i = 0; i < itemsArr.length; ++i) {
            if (tub.lad(itemsArr[i]) != address(0)) {
                arr[n] = itemsArr[i];
                n++;
            }
        }

    }

    /// @notice Helper method to check if a CDP is on sale
    /// @return True|False depending if it is on sale
    function isOnSale(bytes32 _cup) public view returns (bool) {
        return items[_cup].active;
    }

    function removeItem(bytes32 _cup) internal {
        delete items[_cup];

        uint index = itemPos[_cup];
        itemsArr[index] = itemsArr[itemsArr.length - 1];

        itemPos[_cup] = 0;
        itemPos[itemsArr[itemsArr.length - 1]] = index;

        itemsArr.length--;
    }

    function isOwner(address _owner, bytes32 _cup) internal view returns(bool) {         
        require(tub.lad(_cup) == _owner);

        return true;
    }

}

/// @title MarketplaceProxy handles authorization and interaction with the Marketplace contract
contract MarketplaceProxy {
    // Kovan
    // address public constant TUB_ADDRESS = 0xa71937147b55Deb8a530C7229C442Fd3F31b7db2;
    // address public constant FACTORY_ADDRESS = 0xc72E74E474682680a414b506699bBcA44ab9a930;
    
    // Mainnet
    address public constant TUB_ADDRESS = 0x448a5065aeBB8E423F0896E6c5D525C040f59af3;
    address public constant FACTORY_ADDRESS = 0x5a15566417e6C1c9546523066500bDDBc53F88C7;

    ///@dev Called by the Marketplace contract, will give CDP only if you're authorized or CDP owner
    ///@param _cup CDP Id
    ///@param _newOwner Transfer the CDP to this address
    function give(bytes32 _cup, address _newOwner) public {
        TubInterface tub = TubInterface(TUB_ADDRESS);

        tub.give(_cup, _newOwner);
    }

    ///@dev Creates a new DSGuard for the user, authorizes the marketplace contract and puts on sale the cdp
    ///@param _cup CDP Id
    ///@param _discount 4 digit number representing a discount of CDP value (0-9999)
    ///@param _marketplace Address of the marketplace contract 
    function createAuthorizeAndSell(bytes32 _cup, uint _discount, address _marketplace, address _proxy) public {
        DSGuard guard = DSGuardFactory(FACTORY_ADDRESS).newGuard();
        DSAuth(_proxy).setAuthority(DSAuthority(address(guard)));

        guard.permit(_marketplace, _proxy, bytes4(keccak256("execute(address,bytes)")));

        Marketplace(_marketplace).putOnSale(_cup, _discount);
    }

    ///@dev If the user already own a DSGuard but isn't authorized, authorizes the marketplace contract and sell
    ///@param _cup CDP Id
    ///@param _discount 4 digit number representing a discount of CDP value (0-9999)
    ///@param _marketplace Address of the marketplace contract 
    function authorizeAndSell(bytes32 _cup, uint _discount, address _marketplace, address _proxy) public {
        DSGuard guard = DSGuard(address(DSAuth(_proxy).authority()));
        guard.permit(_marketplace, _proxy, bytes4(keccak256("execute(address,bytes)")));

        Marketplace(_marketplace).putOnSale(_cup, _discount);
    }

    ///@dev Put a cdp on sale, if the user already has a DSGuard and authorized it
    ///@param _cup CDP Id
    ///@param _discount 4 digit number representing a discount of CDP value (0-9999)
    ///@param _marketplace Address of the marketplace contract 
    function sell(bytes32 _cup, uint _discount, address _marketplace) public {
        Marketplace(_marketplace).putOnSale(_cup, _discount);
    }

    ///@dev Cancel a CDP on sale
    ///@param _cup CDP Id
    ///@param _marketplace Address of the marketplace contract 
    function cancel(bytes32 _cup, address _marketplace) public {
        Marketplace(_marketplace).cancel(_cup);
    }
}