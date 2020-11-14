pragma solidity ^0.5.7;


// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
contract SafeMath {
    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
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
}

// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address payable token, bytes memory data) public;
}

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address payable public _owner;
    address payable private _newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        _owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == _owner);
        _;
    }

    function transferOwnership(address payable newOwner) public onlyOwner {
        _newOwner = newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == _newOwner);
        emit OwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
        _newOwner = address(0);
    }
}


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract RNBW5 is ERC20Interface, Owned, SafeMath {

    string public symbol;
    string public name;
    string public description;
    uint8 public decimals;
    uint private _startDate;
    uint private _endDate;
    uint private _bonusOneEnds;
    uint private _bonusTwoEnds;
    uint private _bonusThreeEnds;
    uint private _bonusFourEnds;
    uint private _bonusFiveEnds;
    
    uint256 private _softCap;
    uint256 private _hardCap;
    uint256 private _totalSupply;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowed;
    mapping(address => bool) _freezeState;

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor(
        address payable minter) public {

        _owner = minter;
        
        name   = "RNBW5 Token";
        description = "";
        symbol = "RNBW5";
        decimals = 18;
        _softCap =   22222000 * 1000000000000000000; //18 decimals
        _hardCap = 1481481000 * 1000000000000000000; //18 decimals
        
        _startDate = now;        
        _bonusOneEnds   = now + 4 weeks;
        _bonusTwoEnds   = now + 8 weeks;
        _bonusThreeEnds = now + 12 weeks;
        _bonusFourEnds  = now + 16 weeks;
        _bonusFiveEnds  = now + 20 weeks;
        _endDate = now + 24 weeks;
    }

    modifier IcoSuccessful {
        require(now >= _endDate);
        require(_totalSupply >= _softCap);
        _;
    }
    modifier IcoRunning {
        require(now <= _endDate);
        require(_totalSupply <= _hardCap);
        _;
    }

    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint) {
        return _totalSupply - _balances[address(0)];
    }

    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return _balances[tokenOwner];
    }
    
    function isFreezed(address tokenOwner) public view returns (bool freezed) {
        return _freezeState[tokenOwner];
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint256 tokens) public IcoSuccessful returns (bool success) {
        require(_freezeState[msg.sender] == false);
        
        _balances[msg.sender] = safeSub(_balances[msg.sender], tokens);
        _balances[to] = safeAdd(_balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public IcoSuccessful returns (bool success) {
        require( _freezeState[spender] == false);
        _allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    //
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public IcoSuccessful returns (bool success) {
        require( _freezeState[from] == false && _freezeState[to] == false);
        
        _balances[from] = safeSub(_balances[from], tokens);
        _allowed[from][msg.sender] = safeSub(_allowed[from][msg.sender], tokens);
        _balances[to] = safeAdd(_balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        require(_freezeState[spender] == false);
        return _allowed[tokenOwner][spender];
    }

    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account. The `spender` contract function
    // `receiveApproval(...)` is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes memory data) public IcoSuccessful returns (bool success) {
        require(_freezeState[spender] == false);
        _allowed[msg.sender][spender] = tokens;
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, _owner, data);
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // 1 rnbw Tokens per 1 finney
    // ------------------------------------------------------------------------
    function purchase() public IcoRunning payable {
    
        require(now >= _startDate && now <= _endDate);
        require(msg.value >= 500 finney);
        
        uint256 weiValue = msg.value;
        uint256 tokens = safeMul(weiValue, 1000);// 1 finney = 1000000000000000 wei
        uint256 ownerTokens = safeMul( safeDiv(tokens, 10), 3);
        
        if (now <= _bonusOneEnds) {
            tokens = safeMul( safeDiv(tokens, 10) , 15 );
        }
        if (now <= _bonusTwoEnds && now > _bonusOneEnds) {
            tokens = safeMul( safeDiv(tokens, 10) , 14 );
        }
        if (now <= _bonusThreeEnds && now > _bonusTwoEnds) {
            tokens = safeMul( safeDiv(tokens, 10) , 13 );
        }
        if (now <= _bonusFourEnds && now > _bonusThreeEnds) {
            tokens = safeMul( safeDiv(tokens, 10) , 12 );
        }
        if (now <= _bonusFiveEnds && now > _bonusFourEnds) {
            tokens = safeMul( safeDiv(tokens, 10) , 11 );
        }       
        _freezeState[msg.sender] = false;
        
        _balances[msg.sender] = safeAdd(_balances[msg.sender], tokens);        
        _totalSupply = safeAdd(_totalSupply, tokens);        
        emit Transfer(address(0), msg.sender, tokens);
        
        _balances[_owner] = safeAdd(_balances[_owner], ownerTokens);
        _totalSupply = safeAdd(ownerTokens, tokens);
        emit Transfer(address(0), _owner, ownerTokens);
    }
    
    function () payable external {
        purchase();
    }

    function withdraw() public onlyOwner returns (bool success) {
        _owner.transfer(address(this).balance);
        return true;
    }

    function freeze(address account) public onlyOwner returns (bool success) {
        require(account != _owner && account != address(0));
        _freezeState[account] = true;
        return true;
    }
    
    function unfreeze(address account) public onlyOwner returns (bool success) {
        require(account != _owner && account != address(0));
        _freezeState[account] = false;
        return true;
    }
   
    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(_owner, tokens);
    }
}
