/**
 * Source Code first verified at https://etherscan.io on Tuesday, May 7, 2019
 (UTC) */

pragma solidity >= 0.4.24 < 0.6.0;

/**
 * @title KACHA token - Issued by KACHA.
 * created by <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b8d2d0d9d696d3cfd7d6f8dfd5d9d1d496dbd7d5">[email protected]</a>
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
contract KACHA is IERC20 {
    string public name = "KACHA Token";
    string public symbol = "KACHA";
    uint8 public decimals = 18;
    
    uint256 _totalSupply;
    mapping(address => uint256) balances;

    address public owner;


    modifier isOwner {
        require(owner == msg.sender);
        _;
    }
    
    constructor() public {
        owner = msg.sender;

        _totalSupply    = toWei(2000000000);  //2,000,000,000


        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, balances[owner]);
        
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
    
    function toWei(uint256 value) private constant returns (uint256) {
        return value * (10 ** uint256(decimals));
    }
}