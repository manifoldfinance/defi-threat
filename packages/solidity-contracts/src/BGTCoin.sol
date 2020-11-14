/**
 * Source Code first verified at https://etherscan.io on Thursday, May 9, 2019
 (UTC) */

pragma solidity >= 0.4.24 < 0.6.0;


/**
 * @title BGT - BlockChain Game Coin
 */

/**
 * @title ERC20 Standard Interface
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title BGTCoin implementation
 */
contract BGTCoin is IERC20 {
    string public name = "BGT";
    string public symbol = "BGT";
    uint8 public decimals = 18;
    
    uint256 evtAmount;
    uint256 opAmount;
    uint256 teamAmount;
    uint256 swapAmount;
    
    uint256 _totalSupply;
    mapping(address => uint256) balances;

    // Admin Address
    address public owner;
    address public master;
    address public op;
    address public team;
    
    modifier isOwner {
        require(owner == msg.sender);
        _;
    }
    
    constructor() public {
        owner = msg.sender;
        master = 0x9878250B79D39706253fE4989aD931184fdb32Be;
        op     = 0xF6bE0E75d6D10F13d649d6a91cd664Bf54b6e361;
        team   = 0xF8AB18e6DA1871DBB615163d9d6417aae903D6c1;
        require(owner != op);
        require(owner != team);

        evtAmount      = toWei(957166416);   //957,166,416
        opAmount       = toWei(2000000000);  //2,000,000,000
        teamAmount     = toWei(3000000000);  //3,000,000,000
        swapAmount     = toWei(2758599987);  //2,758,599,987
        _totalSupply   = toWei(8715766403);  //8,715,766,403

        require(_totalSupply == evtAmount + opAmount + teamAmount + swapAmount);
        
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, balances[owner]);
        
        transfer(master, evtAmount);
        transfer(master, swapAmount);
        transfer(op, opAmount);
        transfer(team, teamAmount);
        require(balances[owner] == 0);
    }
    
    function totalSupply() public constant returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address who) public view returns (uint256) {
        return balances[who];
    }
    
    function transfer(address to, uint256 value) public returns (bool success) {
        require(msg.sender != to);
        require(to != owner);
        require(value > 0);
        
        require( balances[msg.sender] >= value );
        require( balances[to] + value >= balances[to] );    // prevent overflow

        if(msg.sender == team) {
            require(now >= 1577631599);     // 100% lock to 2019-12-30
        }

        balances[msg.sender] -= value;
        balances[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function burnCoins(uint256 value) public {
        require(balances[msg.sender] >= value);
        require(_totalSupply >= value);
        
        balances[msg.sender] -= value;
        _totalSupply -= value;

        emit Transfer(msg.sender, address(0), value);
    }

    function opBalance() public view returns (uint256) {
        return balances[op];
    }
    
    /** @dev private function
     */

    function toWei(uint256 value) private constant returns (uint256) {
        return value * (10 ** uint256(decimals));
    }
}