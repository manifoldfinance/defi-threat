/**
 * Source Code first verified at https://etherscan.io on Friday, March 22, 2019
 (UTC) */

pragma solidity ^0.4.24;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract DSAuthority {
    function canCall(address src, address dst, bytes4 sig) public constant returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner(address indexed owner);
}


contract DSAuth is DSAuthEvents{
    DSAuthority  public authority;

    address public  owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_) public auth {
        require(owner_ != address(0));
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_) public auth {
        authority = authority_;
        emit LogSetAuthority(authority);

    }

    modifier auth {
        assert(isAuthorized(msg.sender, msg.sig));
        _;
    }

    modifier authorized(bytes4 sig) {
        assert(isAuthorized(msg.sender, sig));
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
            return authority.canCall(src, this, sig);
        }

    }
}

contract DSNote {
    event LogNote(
        bytes4  indexed sig,
        address indexed guy,
        bytes32 indexed foo,
        bytes32 indexed bar,
        uint wad,
        bytes fax
    ) anonymous;

    modifier note {
        bytes32 foo;
        bytes32 bar;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
        }

        emit LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);
        _;
    }

}

contract DSStop is DSAuth, DSNote{
    bool public stopped;

    modifier stoppable {
        assert (!stopped);
        _;
    }

    function stop() public auth note {
        stopped = true;
    }

    function start() public auth note {
        stopped = false;
    }
}


library  DSMath {

    /* standard uint256 functions */

    function add(uint256 x, uint256 y) pure internal returns (uint256 z) {
        assert((z = x + y) >= x);
    }

    function sub(uint256 x, uint256 y) pure internal returns (uint256 z) {
        assert((z = x - y) <= x);
    }

    function mul(uint256 x, uint256 y) pure internal returns (uint256 z) {
        assert(y == 0 || (z = x * y) / y == x);
    }

    function div(uint256 x, uint256 y) pure internal returns (uint256 z) {
        z = x / y;
    }

    function min(uint256 x, uint256 y) pure internal returns (uint256 z) {
        return x <= y ? x : y;
    }

    function max(uint256 x, uint256 y) pure internal returns (uint256 z) {
        return x >= y ? x : y;
    }

    /* uint128 functions (h is for half) */

    function hadd(uint128 x, uint128 y) pure internal returns (uint128 z) {
        assert((z = x + y) >= x);
    }

    function hsub(uint128 x, uint128 y) pure internal returns (uint128 z) {
        assert((z = x - y) <= x);
    }

    function hmul(uint128 x, uint128 y) pure internal returns (uint128 z) {
        assert(y == 0 || (z = x * y) / y == x);
    }

    function hdiv(uint128 x, uint128 y) pure internal returns (uint128 z) {
        z = x / y;
    }

    function hmin(uint128 x, uint128 y) pure internal returns (uint128 z) {
        return x <= y ? x : y;
    }

    function hmax(uint128 x, uint128 y) pure internal returns (uint128 z) {
        return x >= y ? x : y;
    }


    /* int256 functions */

    function imin(int256 x, int256 y) pure internal returns (int256 z) {
        return x <= y ? x : y;
    }

    function imax(int256 x, int256 y) pure internal returns (int256 z) {
        return x >= y ? x : y;
    }

    /* WAD math */

    uint128 constant WAD = 10 ** 18;

    function wadd(uint128 x, uint128 y) pure internal returns (uint128) {
        return hadd(x, y);
    }

    function wsub(uint128 x, uint128 y) pure internal returns (uint128) {
        return hsub(x, y);
    }

    function wmul(uint128 x, uint128 y) pure internal returns (uint128 z) {
        z = cast(add(mul(uint256(x), y), WAD/2) / WAD);
    }

    function wdiv(uint128 x, uint128 y) pure internal returns (uint128 z) {
        z = cast(add(mul(uint256(x), WAD), y/2) / y);
    }

    function wmin(uint128 x, uint128 y) pure internal returns (uint128) {
        return hmin(x, y);
    }

    function wmax(uint128 x, uint128 y) pure internal returns (uint128) {
        return hmax(x, y);
    }

    /* RAY math */

    uint128 constant RAY = 10 ** 27;

    function radd(uint128 x, uint128 y) pure internal returns (uint128) {
        return hadd(x, y);
    }

    function rsub(uint128 x, uint128 y) pure internal returns (uint128) {
        return hsub(x, y);
    }

    function rmul(uint128 x, uint128 y) pure internal returns (uint128 z) {
        z = cast(add(mul(uint256(x), y), RAY/2) / RAY);
    }

    function rdiv(uint128 x, uint128 y) pure internal returns (uint128 z) {
        z = cast(add(mul(uint256(x), RAY), y/2) / y);
    }

    function rpow(uint128 x, uint64 n) pure internal returns (uint128 z) {
        z = n % 2 != 0 ? x : RAY;
        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);
            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }

    function rmin(uint128 x, uint128 y) pure internal returns (uint128) {
        return hmin(x, y);
    }

    function rmax(uint128 x, uint128 y) pure internal returns (uint128) {
        return hmax(x, y);
    }

    function cast(uint256 x) pure internal returns (uint128 z) {
        assert((z = uint128(x)) == x);
    }
}


contract BmsTokenBase is IERC20 {

    using DSMath for uint256;
    uint256 _supply;

    mapping (address => uint256) _balances;

    mapping (address => mapping (address => uint256)) _approvals;

    function totalSupply() public view returns (uint256) {
        return _supply;
    }

    function balanceOf(address src) public view returns (uint256) {
        return _balances[src];
    }

    function allowance(address src, address guy) public view returns (uint256) {
        return _approvals[src][guy];
    }

    function transfer(address dst, uint256 wad) public returns (bool) {
        assert(_balances[msg.sender] >= wad);
        _balances[msg.sender] = _balances[msg.sender].sub(wad);
        _balances[dst] =_balances[dst].add(wad);
        emit Transfer(msg.sender, dst, wad);
        return true;
    }

    function transferFrom(address src, address dst, uint256 wad) public returns (bool) {
        assert(_balances[src] >= wad);
        assert(_approvals[src][msg.sender] >= wad);
        _approvals[src][msg.sender] = _approvals[src][msg.sender].sub(wad);
        _balances[src] =_balances[src].sub(wad);
        _balances[dst] = _balances[dst].add(wad);
        emit Transfer(src, dst, wad);

        return true;
    }

    function approve(address guy, uint256 wad) public returns (bool) {
        _approvals[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

}



contract BmsCoinCore is BmsTokenBase, DSStop {
    bytes32 public symbol;
    bytes32 public name;
    uint256 public decimals = 18; // standard token precision. override to customize
  
    mapping(address=>uint256)  lockedBalance;
    uint256 internal constant INITIAL_SUPPLY = 100 * (10**6) * (10**18);

    event Burn(address indexed burner, uint256 value);
    event Lock(address indexed locker, uint256 value);
    event UnLock(address indexed unlocker, uint256 value);


    constructor() public{
        symbol = "BMS";
        name = "BMS";

        _balances[msg.sender] = INITIAL_SUPPLY;
        _supply =  INITIAL_SUPPLY;
    }

    //balance of locked
    function lockedOf(address _owner) public constant returns (uint256 balance) {
        return lockedBalance[_owner];
    }

    // transfer to and lock it
    function transferAndLock(address dst, uint256 _value) public returns (bool success) {
        require(dst != 0x0);
        require(_value <= _balances[msg.sender].sub(lockedBalance[msg.sender]));
        require(_value > 0);

        _balances[msg.sender] = _balances[msg.sender].sub(_value);

        lockedBalance[dst] = lockedBalance[dst].add(_value);
        _balances[dst] = _balances[dst].add(_value);

        emit Transfer(msg.sender, dst, _value);
        emit Lock(dst, _value);
        return true;
    }


    /**
    * @notice Transfers tokens held by lock.
    */
    function unlock(address dst, uint256 amount) public auth returns (bool success){
        uint256 maxAmount = lockedBalance[dst];
        require(amount > 0);
        require(amount <= maxAmount);

        uint256 remainAmount = maxAmount.sub(amount);
        lockedBalance[dst] = remainAmount;

        //emit Transfer(msg.sender, dst, amount);
        emit UnLock(dst, amount);

        return true;
    }

    function multisend( address[] dests, uint256[] values) public auth returns (uint256) {
        uint256 i = 0;
        while (i < dests.length) {
            transferAndLock(dests[i], values[i]);
            i += 1;
        }
        return(i);
    }

    function transfer(address dst, uint256 wad) public stoppable note returns (bool) {
        require(_balances[msg.sender].sub(lockedBalance[msg.sender]) >= wad);
        return super.transfer(dst, wad);
    }

    function transferFrom(
        address src, address dst, uint256 wad
    ) public stoppable note returns (bool) {
        require(_balances[src].sub(lockedBalance[src]) >= wad);
        return super.transferFrom(src, dst, wad);
    }

    function approve(address guy, uint256 wad) public stoppable note returns (bool) {
        return super.approve(guy, wad);
    }


    function push(address dst, uint256 wad) public returns (bool) {
        return transfer(dst, wad);
    }

    function pull(address src, uint256 wad) public returns (bool) {
        return transferFrom(src, msg.sender, wad);
    }
}