/**
 * Source Code first verified at https://etherscan.io on Tuesday, April 16, 2019
 (UTC) */

pragma solidity ^0.4.25;

// ----------------------------------------------------------------------------
// 'btcc' token contract
//
// Symbol      : BTCC
// Name        : BTCCREDIT Token
// Total supply: 300000000
// Decimals    : 18
// 
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a, "Sum should be greater then any one digit");
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a, "Right side value should be less than left side");
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b, "Multiplied result should not be zero");
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0, "Divisible value should be greater than zero");
        c = a / b;
    }
}


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event FrozenFunds(address indexed target, bool frozen);
    event Burn(address indexed from, uint256 value);
    event Debug(bool destroyed);

}


// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
//
// Borrowed from MiniMeToken
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "You are not owner");
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner, "You are not owner");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract BTCCToken is ERC20Interface, Owned, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;
    uint private _distributedTokenCount;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    mapping(address => bool) public frozenAccount;

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        symbol = "BTCC";
        name = "BTCCREDIT Token";
        decimals = 18;
        _totalSupply = 300000000 * (10 ** uint(decimals)); //300 million
    }

    function distributeTokens(address _address,  uint _amount) public onlyOwner returns (bool) {
        
        uint total = safeAdd(_distributedTokenCount, _amount);
        require (total <= _totalSupply, "Distributed Tokens exceeded Total Suuply");
        balances[_address] = safeAdd(balances[_address], _amount);

        _distributedTokenCount = safeAdd(_distributedTokenCount, _amount);
        
        emit Transfer (address(0), _address, _amount);
        return true;
    }

    // ------------------------------------------------------------------------
    // Distributed Token Count
    // ------------------------------------------------------------------------
    function distributedTokenCount() public view onlyOwner returns (uint) {
        return _distributedTokenCount;
    }

    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint) {
        return _totalSupply - balances[address(0)];
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account tokenOwner
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to to account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        require(!frozenAccount[msg.sender], "Account is frozen"); // If account is frozen, it'll not allow : Fix - 1
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for spender to transferFrom(...) tokens
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces 
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Transfer tokens from the from account to the to account
    // 
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the from account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        require(!frozenAccount[from], "Sender account is frozen"); // Check's if from account is frozen or not : Fix - 2
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
    
    // ------------------------------------------------------------------------
    // Mint tokens 
    // 
    // Increase the total supply
    // - assign the newly minted tokens to target address
    // - token count to be added in total suuply - mintedAmount
    // ------------------------------------------------------------------------    
    function mintToken(address _target, uint256 _mintedAmount) public onlyOwner {
        require(!frozenAccount[_target], "Account is frozen");
        balances[_target] = safeAdd(balances[_target], _mintedAmount);
        _totalSupply = safeAdd(_totalSupply, _mintedAmount);

        emit Transfer(0, this, _mintedAmount);
        emit Transfer(this, _target, _mintedAmount);
    }

    function freezeAccount(address _target, bool _freeze) public onlyOwner {
        frozenAccount[_target] = _freeze;
        emit FrozenFunds(_target, _freeze);
    }


    // Burn tokens
    function burn(uint256 _burnedAmount) public returns (bool success) {
        require(balances[msg.sender] >= _burnedAmount, "Not enough balance");
        balances[msg.sender] = safeSub(balances[msg.sender], _burnedAmount);
        _totalSupply = safeSub(_totalSupply, _burnedAmount);
        emit Burn(msg.sender, _burnedAmount);
        return true;
    }

    function burnFrom(address _from, uint256 _burnedAmount) public returns (bool success) {
        require(balances[_from] >= _burnedAmount, "Not enough balance");
        require(_burnedAmount <= allowed[_from][msg.sender], "Amount not allowed");

        balances[_from] = safeSub(balances[_from], _burnedAmount);
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _burnedAmount);        
        _totalSupply = safeSub(_totalSupply, _burnedAmount);
        
        emit Burn(_from, _burnedAmount);
        return true;
    }

    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for spender to transferFrom(...) tokens
    // from the token owner's account. The spender contract function
    // receiveApproval(...) is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }


    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert("Reverted the wrongly deposited ETH");
    }


    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
    
    function destroyContract() public onlyOwner {
        emit Debug(true);
        selfdestruct(this);
    }
}