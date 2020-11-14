/**
 * Source Code first verified at https://etherscan.io on Wednesday, May 8, 2019
 (UTC) */

pragma solidity >=0.4.22 <0.6.0;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
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
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


/// Buy OurERC20 don't miss the oportunity
contract OurERC20 {

  using SafeMath for uint256;
  string _name;
  string _symbol;
  mapping (address => uint256) _balances;
  uint256 _totalSupply;
  uint8 private _decimals;
  event Transfer(address indexed from, address indexed to, uint tokens);
  
  constructor() public {
    _name = "HOLA";
    _symbol = "HL";
    _decimals = 0;
  }
  
  function decimals() public view returns(uint8) {
      return _decimals;
  }
  
  function totalSupply() public view returns (uint256) {
      return _totalSupply;
  }
  
  function name() public view returns (string memory) {
     return _name;
  }
  
  function symbol() public view returns (string memory) {
     return _symbol;
  }
  
  function mint(uint256 amount) public payable {
      require(msg.value == amount.mul(0.006 ether));
      _balances[msg.sender] = _balances[msg.sender].add(amount);
      _totalSupply = _totalSupply + amount;
  }
  
  function burn(uint256 amount) public {
      require(_balances[msg.sender] == amount);
      _balances[msg.sender] = _balances[msg.sender].sub(amount);
      msg.sender.transfer(amount.mul(0.006 ether));
      _totalSupply = _totalSupply - amount;
  }
  
  function transfer(address _to, uint256 value) public returns (bool success) {
      require(_balances[msg.sender] >= value);
      _balances[msg.sender] = _balances[msg.sender].sub(value);
      _balances[_to] = _balances[_to].add(value);
      emit Transfer(msg.sender, _to, value);      
      return true;
  }
  
  
  
  
  
  
}