/**
 * Source Code first verified at https://etherscan.io on Sunday, May 5, 2019
 (UTC) */

pragma solidity ^0.4.25;

/**
 * 
 * World War Goo - Competitive Idle Game
 * 
 * https://ethergoo.io
 * 
 */
 
 interface ERC20 {
    function totalSupply() external constant returns (uint);
    function balanceOf(address tokenOwner) external constant returns (uint balance);
    function allowance(address tokenOwner, address spender) external constant returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function approveAndCall(address spender, uint tokens, bytes data) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

interface ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) external;
}

contract WoodMaterial is ERC20 {
    using SafeMath for uint;
    
    string public constant name  = "Goo Material - Wood";
    string public constant symbol = "WOOD";
    uint8 public constant decimals = 0;
    
    uint256 public totalSupply;
    address owner; // Minor management
    
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping(address => bool) operator;
    
    constructor() public {
        owner = msg.sender;
    }
    
    function setOperator(address gameContract, bool isOperator) external {
        require(msg.sender == owner);
        operator[gameContract] = isOperator;
    }

    function totalSupply() external view returns (uint) {
        return totalSupply.sub(balances[address(0)]);
    }
    
    function balanceOf(address tokenOwner) external view returns (uint256) {
        return balances[tokenOwner];
    }
    
    function transfer(address to, uint tokens) external returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    
    function transferFrom(address from, address to, uint tokens) external returns (bool) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
    
    function approve(address spender, uint tokens) external returns (bool) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    
    function approveAndCall(address spender, uint tokens, bytes data) external returns (bool) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }
    
    function allowance(address tokenOwner, address spender) external view returns (uint256) {
        return allowed[tokenOwner][spender];
    }

    function recoverAccidentalTokens(address tokenAddress, uint tokens) external {
        require(msg.sender == owner);
        require(tokenAddress != address(this));
        ERC20(tokenAddress).transfer(owner, tokens);
    }
    
    function mintWood(uint256 amount, address player) external {
        require(operator[msg.sender]);
        balances[player] += amount;
        totalSupply += amount;
        emit Transfer(address(0), player, amount);
    }
    
    function burn(uint256 amount, address player) public {
        require(operator[msg.sender]);
        balances[player] = balances[player].sub(amount);
        totalSupply = totalSupply.sub(amount);
        emit Transfer(player, address(0), amount);
    }
}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}