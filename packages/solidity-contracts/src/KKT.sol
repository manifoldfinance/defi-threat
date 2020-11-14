/**
 * Source Code first verified at https://etherscan.io on Tuesday, April 16, 2019
 (UTC) */

pragma solidity >= 0.4.24 < 0.6.0;


/**
 * @title KAKI token - Issued by KAKI.
 * created by <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="88e2e0e9e6a6e3ffe7e6c8efe5e9e1e4a6ebe7e5">[email protected]</a>
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
contract KKT is IERC20 {
    string public name = "KAKI Token";
    string public symbol = "KKT";
    uint8 public decimals = 18;
    
    uint256 ieoAmount;
    uint256 offlineAmount;
    uint256 teamAmount;
    uint256 companyAmount;
    uint256 devAmount;
    
    uint256 _totalSupply;
    mapping(address => uint256) balances;

    address public owner;
    address public team;
    address public company;
    address public dev;
    
    modifier isOwner {
        require(owner == msg.sender);
        _;
    }
    
    constructor() public {
        owner = msg.sender;
        team   = 0xD27834E193CAf736c102B9704Dd0ba6cF8591f24;
        company   = 0x5472EF7BfA566f7e088dBD096ae35275bF135d62;
        dev   = 0x3A2f9223Bf7eEb1aF5F525C7702D67C43b5CBAc9;

        require(owner != team);
        require(owner != company);
        require(owner != dev);

        ieoAmount       = toWei(5000000000);   // 5,000,000,000
        offlineAmount   = toWei(5000000000);   // 5,000,000,000
        teamAmount      = toWei(4000000000);   // 4,000,000,000
        companyAmount   = toWei(4000000000);   // 4,000,000,000
        devAmount       = toWei(2000000000);   // 4,000,000,000
        _totalSupply    = toWei(20000000000);  //20,000,000,000

        require(_totalSupply == ieoAmount + offlineAmount + teamAmount + companyAmount + devAmount );
        
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, balances[owner]);
        
        transfer(team, teamAmount);
        transfer(company, companyAmount);
        transfer(dev, devAmount);
        require(balances[owner] == ieoAmount+offlineAmount);
    }
    
    function totalSupply() public constant returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address who) public view returns (uint256) {
        return balances[who];
    }
    
    function transfer(address to, uint256 value) public returns (bool success) {
        require(msg.sender != to);
        //require(msg.sender != owner);   // owner is not free to transfer
        require(to != owner);
        require(value > 0);
        
        require( balances[msg.sender] >= value );
        require( balances[to] + value >= balances[to] );    // prevent overflow

        if(msg.sender == team) {
            require(now >= 1561248000);     // 10M lock to 2019-06-23
        }

        if(msg.sender == company) {
            require(now >= 1574467200);     // 10M lock to 2019-11-23
        }

        if(msg.sender == dev) {
            require(now >= 1566518400);     // 10M lock to 2019-08-23
        }

        if (to == address(0) || to == address(0x1) || to == address(0xdead)) {
             _totalSupply -= value;
        }


        balances[msg.sender] -= value;
        balances[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function burnCoins(uint256 value) public {
        require(msg.sender != owner);   // owner can't burn any coin
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