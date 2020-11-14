/**
 * Source Code first verified at https://etherscan.io on Sunday, May 5, 2019
 (UTC) */

pragma solidity ^0.4.25;

/**
 * 
 * World War Goo - Competitive Idle Game
 * 
 * https:/ethergoo.io
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

contract GooToken is ERC20 {
    using SafeMath for uint;
    using SafeMath224 for uint224;
    
    string public constant name  = "Vials of Goo";
    string public constant symbol = "GOO";
    uint8 public constant decimals = 12;
    uint224 public constant MAX_SUPPLY = 21000000 * (10 ** 12); // 21 million (to 12 szabo decimals)
    
    mapping(address => UserBalance) balances;
    mapping(address => mapping(address => uint256)) allowed;
    
    mapping(address => uint256) public gooProduction; // Store player's current goo production
    mapping(address => bool) operator;
    
    uint224 private totalGoo;
    uint256 public teamAllocation; // 10% reserve allocation towards exchange-listing negotiations, game costs, and ongoing community contests/aidrops
    address public owner; // Minor management of game
    bool public supplyCapHit; // No more production once we hit MAX_SUPPLY
    
    struct UserBalance {
        uint224 goo;
        uint32 lastGooSaveTime;
    }
    
    constructor() public {
        teamAllocation = MAX_SUPPLY / 10;
        owner = msg.sender;
    }
    
    function totalSupply() external view returns(uint) {
        return totalGoo;
    }
    
    function transfer(address to, uint256 tokens) external returns (bool) {
        updatePlayersGooInternal(msg.sender);
        
        require(tokens <= MAX_SUPPLY); // Prevent uint224 overflow
        uint224 amount = uint224(tokens); // Goo is uint224 but must comply to ERC20's uint256

        balances[msg.sender].goo = balances[msg.sender].goo.sub(amount);
        emit Transfer(msg.sender, to, amount);
        
        if (to == address(0)) { // Burn
            totalGoo -= amount;
        } else {
            balances[to].goo = balances[to].goo.add(amount);
        }
        return true;
    }
    
    function transferFrom(address from, address to, uint256 tokens) external returns (bool) {
        updatePlayersGooInternal(from);
        
        require(tokens <= MAX_SUPPLY); // Prevent uint224 overflow
        uint224 amount = uint224(tokens); // Goo is uint224 but must comply to ERC20's uint256
        
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(amount);
        balances[from].goo = balances[from].goo.sub(amount);
        emit Transfer(from, to, amount);
        
        if (to == address(0)) { // Burn
            totalGoo -= amount;
        } else {
            balances[to].goo = balances[to].goo.add(amount);
        }
        return true;
    }
    
    function unlockAllocation(uint224 amount, address recipient) external {
        require(msg.sender == owner);
        teamAllocation = teamAllocation.sub(amount); // Hard limit
        
        totalGoo += amount;
        balances[recipient].goo = balances[recipient].goo.add(amount);
        emit Transfer(address(0), recipient, amount);
    }
    
    function setOperator(address gameContract, bool isOperator) external {
        require(msg.sender == owner);
        operator[gameContract] = isOperator;
    }
    
    function approve(address spender, uint256 tokens) external returns (bool) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    
    function approveAndCall(address spender, uint256 tokens, bytes data) external returns (bool) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }
    
    function allowance(address tokenOwner, address spender) external view returns (uint256) {
        return allowed[tokenOwner][spender];
    }

    function recoverAccidentalTokens(address tokenAddress, uint256 tokens) external {
        require(msg.sender == owner);
        require(tokenAddress != address(this)); // Not Goo
        ERC20(tokenAddress).transfer(owner, tokens);
    }
    
    function balanceOf(address player) public constant returns(uint256) {
        return balances[player].goo + balanceOfUnclaimedGoo(player);
    }
    
    function balanceOfUnclaimedGoo(address player) internal constant returns (uint224 gooGain) {
        if (supplyCapHit) return;
        
        uint32 lastSave = balances[player].lastGooSaveTime;
        if (lastSave > 0 && lastSave < block.timestamp) {
            gooGain = uint224(gooProduction[player] * (block.timestamp - lastSave));
        }
        
        if (totalGoo + gooGain >= MAX_SUPPLY) {
            gooGain = MAX_SUPPLY - totalGoo;
        }
    }
    
    function mintGoo(uint224 amount, address player) external {
        if (supplyCapHit) return;
        require(operator[msg.sender]);
        
        uint224 minted = amount;
        if (totalGoo.add(amount) >= MAX_SUPPLY) {
            supplyCapHit = true;
            minted = MAX_SUPPLY - totalGoo;
        }

        balances[player].goo += minted;
        totalGoo += minted;
        emit Transfer(address(0), player, minted);
    }
    
    function updatePlayersGoo(address player) external {
        require(operator[msg.sender]);
        updatePlayersGooInternal(player);
    }
    
    function updatePlayersGooInternal(address player) internal {
        uint224 gooGain = balanceOfUnclaimedGoo(player);
        
        UserBalance memory balance = balances[player];
        if (gooGain > 0) {
            totalGoo += gooGain;
            if (!supplyCapHit && totalGoo == MAX_SUPPLY) {
                supplyCapHit = true;
            }
            
            balance.goo += gooGain;
            emit Transfer(address(0), player, gooGain);
        }
        
        if (balance.lastGooSaveTime < block.timestamp) {
            balance.lastGooSaveTime = uint32(block.timestamp); 
            balances[player] = balance;
        }
    }
    
    function updatePlayersGooFromPurchase(address player, uint224 purchaseCost) external {
        require(operator[msg.sender]);
        uint224 unclaimedGoo = balanceOfUnclaimedGoo(player);
        
        UserBalance memory balance = balances[player];
        balance.lastGooSaveTime = uint32(block.timestamp); 
        
        if (purchaseCost > unclaimedGoo) {
            uint224 gooDecrease = purchaseCost - unclaimedGoo;
            totalGoo -= gooDecrease;
            balance.goo = balance.goo.sub(gooDecrease);
            emit Transfer(player, address(0), gooDecrease);
        } else {
            uint224 gooGain = unclaimedGoo - purchaseCost;
            totalGoo += gooGain;
            balance.goo += gooGain;
            if (!supplyCapHit && totalGoo == MAX_SUPPLY) {
                supplyCapHit = true;
            }
            emit Transfer(address(0), player, gooGain);
        }
        balances[player] = balance;
    }
    
    function increasePlayersGooProduction(address player, uint256 increase) external {
        require(operator[msg.sender]);
        gooProduction[player] += increase;
    }
    
    function decreasePlayersGooProduction(address player, uint256 decrease) external {
        require(operator[msg.sender]);
        gooProduction[player] -= decrease;
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




library SafeMath224 {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint224 a, uint224 b) internal pure returns (uint224) {
    if (a == 0) {
      return 0;
    }
    uint224 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint224 a, uint224 b) internal pure returns (uint224) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint224 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint224 a, uint224 b) internal pure returns (uint224) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint224 a, uint224 b) internal pure returns (uint224) {
    uint224 c = a + b;
    assert(c >= a);
    return c;
  }
}