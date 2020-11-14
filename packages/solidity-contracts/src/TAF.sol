/**
 * Source Code first verified at https://etherscan.io on Thursday, March 14, 2019
 (UTC) */

pragma solidity >= 0.4.24 < 0.6.0;


/**
 * @title TAF token - Issued by PlusWisdom Corp.
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
 * @title Token implementation
 */
contract TAF is IERC20 {
    string public name = "TAF";
    string public symbol = "TAF";
    uint8 public decimals = 18;
    
    uint256 ieoAmount;
    uint256 teamAmount;
    
    uint256 _totalSupply;
    mapping(address => uint256) balances;

    address public owner;
    address public team;
    
    modifier isOwner {
        require(owner == msg.sender);
        _;
    }
    
    constructor() public {
        owner = msg.sender;
        team   = 0xAE119d147f52E1EbCbf4DE92f31CADa6b5b5ca02;
        require(owner != team);

        ieoAmount       = toWei(70000000);   //70,000,000
        teamAmount      = toWei(30000000);   //30,000,000
        _totalSupply    = toWei(100000000);  //100,000,000

        require(_totalSupply == ieoAmount + teamAmount );
        
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, balances[owner]);
        
        transfer(team, teamAmount);
        require(balances[owner] == ieoAmount);
    }
    
    function totalSupply() public constant returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address who) public view returns (uint256) {
        return balances[who];
    }
    
    function transfer(address to, uint256 value) public returns (bool success) {
        require(msg.sender != to);
        require(value > 0);
        
        require( balances[msg.sender] >= value );
        require( balances[to] + value >= balances[to] );    // prevent overflow

        if(msg.sender == team) {
            require(now >= 1585666800);     // 10M lock to 2020-04-01
            if(balances[msg.sender] - value < toWei(20000000))
                require(now >= 1617202800);     // 10M lock to 2021-04-01
            if(balances[msg.sender] - value < toWei(10000000))
                require(now >= 1648738800);     // 10M lock to 2022-04-01
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

    function balanceOfOwner() public view returns (uint256) {
        return balances[owner];
    }
    
    /** @dev private function
     */

    function toWei(uint256 value) private constant returns (uint256) {
        return value * (10 ** uint256(decimals));
    }
}