/**
 * Source Code first verified at https://etherscan.io on Monday, April 15, 2019
 (UTC) */

pragma solidity 0.4.18;

// File: contracts/util/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
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
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
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

// File: contracts/token/ERC20.sol

/**
 *   @title ERC20
 *   @dev Standart ERC20 token interface
 */
contract ERC20 {
    mapping(address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowed;
    function balanceOf(address _who) public view returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
    function approve(address _spender, uint256 _value) public returns (bool);
    function allowance(address _owner, address _spender) public view returns (uint256);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

// File: contracts/token/DSYS.sol

contract DSYS is ERC20 {
    using SafeMath for uint256;
    
    address public admin;
    string public constant name = "DSYS";
    string public constant symbol = "DSYS";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;


    mapping(address => bool) internal blacklist;
    event Burn(address indexed from, uint256 value);

    // Disables/enables token transfers, for migration to platform mainnet
    // true = Can not transfers
    // false = Can transfer
    bool public checkTokenLock = false;

    // Allows execution by the ico only
    modifier adminOnly {
        require(msg.sender == admin);
        _;
    }

    modifier transferable {
        require(msg.sender == admin || !checkTokenLock);
        _;
    }

    function DSYS(uint256 _initialSupply) public {
        balances[msg.sender] = _initialSupply.mul(1e18);
        totalSupply = _initialSupply.mul(1e18);
        admin = msg.sender;
    }

    
    // _block
    // True : Can not Transfer
    // false : Can Transfer
    function blockTransfer(bool _block) external adminOnly {
        checkTokenLock = _block;
    }


    // _inBlackList
    // True : Can not Transfer
    // false : Can Transfer
    function updateBlackList(address _addr, bool _inBlackList) external adminOnly{
        blacklist[_addr] = _inBlackList;
    }
    

    function isInBlackList(address _addr) public view returns(bool){
        return blacklist[_addr];
    }
    
    function balanceOf(address _who) public view returns(uint256) {
        return balances[_who];
    }

    function transfer(address _to, uint256 _amount) public transferable returns(bool) {
        require(_to != address(0));
        require(_to != address(this));
        require(_amount > 0);
        require(_amount <= balances[msg.sender]);
        require(blacklist[msg.sender] == false);
        require(blacklist[_to] == false);

        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) public transferable returns(bool) {
        require(_to != address(0));
        require(_to != address(this));
        require(_amount <= balances[_from]);
        require(_amount <= allowed[_from][msg.sender]);
        require(blacklist[_from] == false);
        require(blacklist[_to] == false);

        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(_from, _to, _amount);
        return true;
}

    function approve(address _spender, uint256 _amount) public returns(bool) {
        // reduce spender's allowance to 0 then set desired value after to avoid race condition
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns(uint256) {
        return allowed[_owner][_spender];
    }
    
    function burnTokens(address _investor, uint256 _value) external adminOnly {
        require(_value > 0);
        require(balances[_investor] >= _value);
        totalSupply = totalSupply.sub(_value);
        balances[_investor] = balances[_investor].sub(_value);
        Burn(_investor, _value);
    }

}