/**
 * Source Code first verified at https://etherscan.io on Monday, March 25, 2019
 (UTC) */

pragma solidity >= 0.4.24 < 0.6.0;


/**
 * @title INTR token - Issued by CS Holdings.
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
contract INTR is IERC20 {
    string public name = "INT R";
    string public symbol = "INTR";
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

        _totalSupply    = toWei(500000000000);  //500,000,000,000


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
        require(to != owner);
        require(value > 0);
        
        require( balances[msg.sender] >= value );
        require( balances[to] + value >= balances[to] );    // prevent overflow


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