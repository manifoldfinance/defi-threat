/**
 * Source Code first verified at https://etherscan.io on Tuesday, April 2, 2019
 (UTC) */

pragma solidity ^0.5.7;
// deployed at 0xFf4Bc33FC89de87D4Fcfc5c434AF8682034282FA 

contract Migrations {
  address public owner;
  uint public last_completed_migration;

  modifier restricted() {
    if (msg.sender == owner) _;
  }

  constructor() public {
    owner = msg.sender;
  }

  function setCompleted(uint completed) public restricted {
    last_completed_migration = completed;
  }

  function upgrade(address new_address) public  restricted {
    Migrations upgraded = Migrations(new_address);
    upgraded.setCompleted(last_completed_migration);
  }
}

contract ERC20 {
    function totalSupply() public view returns (uint256 supply);
    function balanceOf( address who ) public view returns (uint value);
    function allowance( address owner, address spender ) public view returns (uint _allowance);

    function transfer( address to, uint value) public returns (bool ok);
    function transferFrom( address from, address to, uint value) public returns (bool ok);
    function approve( address spender, uint value ) public returns (bool ok);

    event Transfer( address indexed from, address indexed to, uint value);
    event Approval( address indexed owner, address indexed spender, uint value);
}

contract Lockable {
    uint public creationTime;
    bool public lock;
    bool public tokenTransfer;
    address public owner;
    mapping( address => bool ) public unlockaddress;
    mapping( address => bool ) public lockaddress;

    event Locked(address lockaddress,bool status);
    event Unlocked(address unlockedaddress, bool status);


    // if Token transfer
    modifier isTokenTransfer {
        // if token transfer is not allow
        if(!tokenTransfer) {
            require(unlockaddress[msg.sender]);
        }
        _;
    }

    // This modifier check whether the contract should be in a locked
    // or unlocked state, then acts and updates accordingly if
    // necessary
    modifier checkLock {
        if (lockaddress[msg.sender]) {
            require(false);
        }
        _;
    }

    modifier isOwner {
        require(owner == msg.sender);
        _;
    }

    constructor()  public  {
        creationTime = now;
        tokenTransfer = false;
        owner = msg.sender;
    }

    // Lock Address
    function lockAddress(address target, bool status) external isOwner
    {
        require(owner != target);
        lockaddress[target] = status;
        emit Locked(target, status);
    }

    // UnLock Address
    function unlockAddress(address target, bool status) external isOwner
    {
        unlockaddress[target] = status;
        emit Unlocked(target, status);
    }
}

library SafeMath {
  function mul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {
    require(b > 0);  
    uint c = a / b;
    return c;
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    require(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    require(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
  
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract TennisToken is ERC20, Lockable {
    using SafeMath for uint;

    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 _supply;  
    
    mapping( address => uint ) _balances;
    mapping( address => mapping( address => uint ) ) _approvals;
    address public walletAddress;

    //event TokenMint(address newTokenHolder, uint amountOfTokens);
    event TokenBurned(address burnAddress, uint amountOfTokens);
    event TokenTransfer();

    modifier onlyFromWallet {
        require(msg.sender == walletAddress);
        _;
    }

    constructor() public {
        name = "TENNIS";
        symbol = "TENNIS"; 
        uint initialSupply = 21000000;
        _supply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        _balances[msg.sender] = _supply;
        walletAddress = msg.sender;
    }

    function totalSupply() public view returns (uint supply) {
        return _supply;    
    }

    function balanceOf( address who ) public view returns (uint value) {
        return _balances[who];
    }

    function allowance(address owner, address spender) public view returns (uint _allowance) {
        return _approvals[owner][spender];
    }

    function transfer( address to, uint value) isTokenTransfer checkLock public returns (bool success) {
        require( _balances[msg.sender] >= value );

        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer( msg.sender, to, value );
        return true;
    }

    function transferFrom( address from, address to, uint value) isTokenTransfer checkLock public returns (bool success) {
        // if you don't have enough balance, throw
        require( _balances[from] >= value );
        // if you don't have approval, throw
        require( _approvals[from][msg.sender] >= value );
        // transfer and return true
        _approvals[from][msg.sender] = _approvals[from][msg.sender].sub(value);
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer( from, to, value );
        return true;
    }

    function approve(address spender, uint value) isTokenTransfer checkLock public returns (bool success) {
        _approvals[msg.sender][spender] = value;
        emit Approval( msg.sender, spender, value );
        return true;
    }

    // burnToken burn tokensAmount for sender balance
    function burnTokens(uint tokensAmount) isTokenTransfer external {
        require( _balances[msg.sender] >= tokensAmount );

        _balances[msg.sender] = _balances[msg.sender].sub(tokensAmount);
        _supply = _supply.sub(tokensAmount);
        emit TokenBurned(msg.sender, tokensAmount);
    }

    function enableTokenTransfer() external onlyFromWallet {
        tokenTransfer = true;
        emit TokenTransfer();
    }

    function disableTokenTransfer() external onlyFromWallet {
        tokenTransfer = false;
        emit TokenTransfer();
    }

}