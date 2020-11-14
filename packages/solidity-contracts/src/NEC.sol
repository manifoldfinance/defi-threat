/**
 * Source Code first verified at https://etherscan.io on Monday, May 6, 2019
 (UTC) */

pragma solidity 0.4.26;

contract IMigrationContract {
    function migrate(address addr, uint256 nas) public returns (bool success);
}

/* safe calculate */
contract SafeMath {
    function safeAdd(uint256 x, uint256 y) internal pure returns(uint256) {
        uint256 z = x + y;
        assert((z >= x) && (z >= y));
        return z;
    }
    function safeSubtract(uint256 x, uint256 y) internal pure returns(uint256) {
        assert(x >= y);
        uint256 z = x - y;
        return z;
    }
    function safeMult(uint256 x, uint256 y) internal pure returns(uint256) {
        uint256 z = x * y;
        assert((x == 0)||(z/x == y));
        return z;
    }
}

// token interface properties and methods
contract Token {
    uint256 public totalSupply;
    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


/*  ERC 20 token */
contract StandardToken is Token {

    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

// the new contact coind main
contract NEC is StandardToken, SafeMath {

    // metadata
    string  public constant name = "New Energy Coin";
    string  public constant symbol = "NEC";
    uint256 public constant decimals = 18;
    string  public version = "1.0";

    // contracts
    address public ethFundDeposit;          // ETH address
    address public newContractAddr;         // token update address

    // crowdsale parameters
    bool    public isFunding;                // change status to true
    uint256 public fundingStartBlock;
    uint256 public fundingStopBlock;

    uint256 public currentSupply;           // solding tokens count
    uint256 public tokenRaised = 0;         // all sold token
    uint256 public tokenMigrated = 0;     // all transfered token
    uint256 public tokenExchangeRate = 100000;             // 1000  contract coin to 1 ETH
    uint256 public constant initialSupply = 500000000;  // total supply of this contract

    // events
    event AllocateToken(address indexed _to, uint256 _value);   // private transfer token;
    event IssueToken(address indexed _to, uint256 _value);      // issue token;
    event IncreaseSupply(uint256 _value);
    event DecreaseSupply(uint256 _value);
    event Migrate(address indexed _to, uint256 _value);

    // change unit
    function formatDecimals(uint256 _value) internal pure returns (uint256 ) {
        return _value * 10 ** decimals;
    }

    // constructor
    constructor() public
    {
        initializeSaleWalletAddress();
        isFunding = false;                           // change status
        fundingStartBlock = 0;
        fundingStopBlock = 0;

        currentSupply = formatDecimals(initialSupply);
        totalSupply = formatDecimals(initialSupply);
        balances[msg.sender] = totalSupply;
        if(currentSupply > totalSupply) revert();
    }
    
    function initializeSaleWalletAddress() private {
        ethFundDeposit = 0x54ED20e3Aefc01cAf7CB536a9F49186caF2A6251;
    }

    modifier isOwner()  { require(msg.sender == ethFundDeposit); _; }

    ///  set token exchange
    function setTokenExchangeRate(uint256 _tokenExchangeRate) isOwner external {
        if (_tokenExchangeRate == 0) revert();
        if (_tokenExchangeRate == tokenExchangeRate) revert();

        tokenExchangeRate = _tokenExchangeRate;
    }

    /// @dev overflow token
    function increaseSupply (uint256 _value) isOwner external {
        uint256 value = formatDecimals(_value);
        if (value + currentSupply > totalSupply) revert();
        currentSupply = safeAdd(currentSupply, value);
        emit IncreaseSupply(value);
    }

    /// @dev missed token
    function decreaseSupply (uint256 _value) isOwner external {
        uint256 value = formatDecimals(_value);
        if (value + tokenRaised > currentSupply) revert();

        currentSupply = safeSubtract(currentSupply, value);
        emit DecreaseSupply(value);
    }

    ///  start exceptions
    function startFunding (uint256 _fundingStartBlock, uint256 _fundingStopBlock) isOwner external {
        if (isFunding) revert();
        if (_fundingStartBlock >= _fundingStopBlock) revert();
        if (block.number >= _fundingStartBlock) revert();

        fundingStartBlock = _fundingStartBlock;
        fundingStopBlock = _fundingStopBlock;
        isFunding = true;
    }

    ///  close exceptions
    function stopFunding() isOwner external {
        if (!isFunding) revert();
        isFunding = false;
    }

    /// new contract address
    function setMigrateContract(address _newContractAddr) isOwner external {
        if (_newContractAddr == newContractAddr) revert();
        newContractAddr = _newContractAddr;
    }

    /// new contract address for owner
    function changeOwner(address _newFundDeposit) isOwner() external {
        if (_newFundDeposit == address(0x0)) revert();
        ethFundDeposit = _newFundDeposit;
    }

    // migrate to Contract address
    function migrate() external {
        if(isFunding) revert();
        if(newContractAddr == address(0x0)) revert();

        uint256 tokens = balances[msg.sender];
        if (tokens == 0) revert();

        balances[msg.sender] = 0;
        tokenMigrated = safeAdd(tokenMigrated, tokens);

        IMigrationContract newContract = IMigrationContract(newContractAddr);
        if (!newContract.migrate(msg.sender, tokens)) revert();

        emit Migrate(msg.sender, tokens);               // log it
    }

    // tansfer eth
    function transferETH() isOwner external {
        if (address(this).balance == 0) revert();
        if (!ethFundDeposit.send(address(this).balance)) revert();
    }

    //  let Contract token allocate to the address
    function allocateToken (address _addr, uint256 _eth) isOwner external {
        if (_eth == 0) revert();
        if (_addr == address(0x0)) revert();

        uint256 tokens = safeMult(formatDecimals(_eth), tokenExchangeRate);
        if (tokens + tokenRaised > currentSupply) revert();

        tokenRaised = safeAdd(tokenRaised, tokens);
        balances[_addr] += tokens;

        emit AllocateToken(_addr, tokens);  // log token record
    }

    // buy token
    function () payable public{
        if (!isFunding) revert();
        if (msg.value == 0) revert();

        if (block.number < fundingStartBlock) revert();
        if (block.number > fundingStopBlock) revert();

        uint256 tokens = safeMult(msg.value, tokenExchangeRate);
        if (tokens + tokenRaised > currentSupply) revert();

        tokenRaised = safeAdd(tokenRaised, tokens);
        balances[msg.sender] += tokens;

        emit IssueToken(msg.sender, tokens);  // log record
    }
}