/**
 * Source Code first verified at https://etherscan.io on Monday, April 29, 2019
 (UTC) */

pragma solidity >=0.4.22 <0.6.0;

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract WhiteListed{
    mapping(address => bool)whitelist;
}

contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}

contract IziCoin is ERC20Interface, Owned, WhiteListed {
        
    using SafeMath for uint;
    
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    uint _totalSupply;
    
    string public symbol;
    string public  name;
    uint8 public decimals;
    
    constructor () public {
        symbol = "IZI";
        name = "IziCoin";
        decimals = 8;
        _totalSupply = 24606905043426990;
        balances[owner] = _totalSupply;
        whitelist[owner] = true;
        emit Transfer(address(0), owner, _totalSupply);
    }
    
    //ERC20
    function totalSupply() public view returns (uint){
        return _totalSupply.sub(balances[address(0)]);
    }
    
    function balanceOf(address tokenOwner) public view returns (uint balance){
        return balances[tokenOwner];
    }
    
    function allowance(address tokenOwner, address spender) public view returns (uint remaining){
        return allowed[tokenOwner][spender];        
    }
    
    function transfer(address to, uint tokens) public returns (bool success){
        require(balances[msg.sender] >= tokens &&
        tokens > 0 && 
        to != address(0x0) &&
        whitelist[msg.sender] &&
        whitelist[to]);
        executeTransfer(msg.sender,to, tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    
    function approve(address spender, uint tokens) public returns (bool success){
        require(balances[msg.sender] >= tokens &&
        whitelist[msg.sender] &&
        whitelist[spender]);
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
        
    }
    
    function transferFrom(address from, address to, uint tokens) public returns (bool success){
        require(balances[from] >= tokens &&
        allowed[from][msg.sender] >= tokens &&
        tokens > 0 && 
        to != address(0x0) &&
        whitelist[msg.sender] &&
        whitelist[to]);
        executeTransfer(from, to, tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    
    function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }
    
    //IziCoin
    function executeTransfer(address from,address to, uint tokens) private{
        uint previousBalances = balances[from] + balances[to];
        balances[from] = balances[from].sub(tokens);
        balances[to] = balances[to].add(tokens);
        assert((balances[from] + balances[to] == previousBalances) && (whitelist[from] && whitelist[to]));
    }
    
    function executeTransferWithTax(address from,address to, uint tokens, uint taxFee) private{
        uint previousBalances = balances[from] + balances[to];
        uint taxedTokens = tokens.sub(taxFee);
        balances[from] = balances[from].sub(tokens);
        balances[to] = balances[to].add(taxedTokens);
        if(from != owner){
           balances[owner] = balances[owner].add(taxFee); 
        }
        emit Transfer(from, to, taxedTokens);
        emit Transfer(from, owner, taxFee);
        assert((balances[from] + balances[to] == previousBalances.sub(taxFee)) && (whitelist[from] && whitelist[to]));
    }
    
    function mintIziCoins(uint tokenIncrease) public onlyOwner{
        require(tokenIncrease > 0);
        uint oldTotalSupply = _totalSupply;
        _totalSupply = _totalSupply.add(tokenIncrease);
        balances[owner] = balances[owner].add(tokenIncrease);
        assert(_totalSupply > oldTotalSupply);
    }
    
    function sendBatchTransaction(address[] memory from, address[] memory to, uint[] memory tokens, uint[] memory taxFee)public onlyOwner{
        for(uint i = 0; i < getCount(from); i++){
            executeTransferWithTax(from[i],to[i],tokens[i],taxFee[i]);
        }
    }
    
    //Whitelist
    function seeWhitelist(address whitelistUser) public view returns (bool){
        return whitelist[whitelistUser] == true;
    }
    
    function addBulkWhitelist(address[] memory whitelistUsers) public onlyOwner{
        for(uint i = 0; i < getCount(whitelistUsers); i++){
            whitelist[whitelistUsers[i]] = true;
        }
        return;
    }
    
    function removeBulkWhitelist(address[] memory whitelistUsers) public onlyOwner{
        for(uint i = 0; i < getCount(whitelistUsers); i++){
            whitelist[whitelistUsers[i]] = false;
        }
        return;
    }
    
    function getCount(address[] memory whitelistUsers) private pure returns(uint count) {
        return whitelistUsers.length;
    }
    
    //Fallback
    function () external payable {
        revert();
    }
    
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
    
}