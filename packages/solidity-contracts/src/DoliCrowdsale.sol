/**
 * Source Code first verified at https://etherscan.io on Sunday, March 24, 2019
 (UTC) */

pragma solidity 0.4.25;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant public returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function transferFrom(address from, address to, uint256 value) public returns (bool);
}

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
    
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  function transfer(address _to, uint256 _value) public returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
	balances[_to] = balances[_to].add(_value);
	emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant public returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) public  returns (bool) {
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 
  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {
    
  event Mint(address indexed to, uint256 amount);
  
  event MintFinished();

  bool public mintingFinished = false;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }


  function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner public returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
  
}

contract Doli is MintableToken {
    
    string public constant name = "DOLI Token";
    
    string public constant symbol = "DOLI";
    
    uint32 public constant decimals = 18;

}


contract DoliCrowdsale is Ownable {
    
    using SafeMath for uint;
    
    uint restrictedPercent;

    address restrictedAccount;

    Doli public token = new Doli();

    uint startDate;
	
	uint endDate;
    
    uint period2;
	
	uint period3;
	
	uint period4;
	
    uint rate;
   
    uint hardcap;
    
   

    constructor() public payable {
	
        restrictedAccount = 0x023770c61B9372be44bDAB41f396f8129C14c377;
        restrictedPercent = 40;
        rate = 100000000000000000000;
        startDate = 1553385600;
	    period2 = 1557446400;
		period3 = 1561420800;
		period4 = 1565395200;
		endDate = 1569369600;

        hardcap = 500000000000000000000000000;
       
    }
    modifier saleIsOn() {
    	require(now > startDate && now < endDate);
    	_;
    }
	
	modifier isUnderHardCap() {
        require(token.totalSupply() <= hardcap);
        _;
    }
    
    function finishMinting() public onlyOwner {
        uint issuedTokenSupply = token.totalSupply();
        uint restrictedTokens = issuedTokenSupply.mul(restrictedPercent).div(100 - restrictedPercent);
        token.mint(restrictedAccount, restrictedTokens);
        token.finishMinting();
    }
        
    /** value - amount in EURO! */
    function createTokens(address customer, uint256 value) onlyOwner saleIsOn public {
        
        uint256 tokens;
        uint bonusRate = 10;
        if (customer==owner) {
          revert();  
        }
        if(now >= startDate &&  now < period2) {
          bonusRate = 7;
        } else 
		if(now >= period2 &&  now < period3) {
          bonusRate = 8;
        } else 
		if(now >= period3 &&  now < period4) {
          bonusRate = 9;
        } if(now >= period4 &&  now < endDate) {
          bonusRate = 10;
        }
		tokens = value.mul(1 ether).mul(10).div(bonusRate); 
		token.mint(owner, tokens);
		token.transferFrom(owner, customer, tokens); 
    }
    
    function getTokensCount() public constant returns(uint256){
       return token.totalSupply().div(1 ether); }

    function getBalance(address customer) onlyOwner public constant returns(uint256){
       return token.balanceOf(customer).div(1 ether); }
	   
     function() external payable  onlyOwner {
       revert();}
}