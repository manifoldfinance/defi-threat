/**
 * Source Code first verified at https://etherscan.io on Thursday, March 21, 2019
 (UTC) */

pragma solidity ^0.4.24;

library SafeMath {

    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        if (_a == 0) {
            return 0;
        }
        uint256 c = _a * _b;
        require(c / _a == _b);

        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0);
        uint256 c = _a / _b;

        return c;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

        return c;
    }

    function mod(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b != 0);
        return _a % _b;
    }
}
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param _newOwner The address to transfer ownership to.
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param _newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public view returns (uint256);

    function balanceOf(address _owner) public view returns (uint256 balance);

    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract ReentrancyGuard {
    uint256 private guardCounter = 1;

    modifier noReentrant() {
        guardCounter += 1;
        uint256 localCounter = guardCounter;
        _;
        require(localCounter == guardCounter);
    }
}


interface tokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external;
}


contract ERC20Base is ERC20Interface, ReentrancyGuard {
    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor() public {}

    function() payable public {
        revert();
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balanceOf[_owner];
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowance[_owner][_spender];
    }

    function _transfer(address _from, address _to, uint256 _value) internal returns (bool success) {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        if (balanceOf[_to].add(_value) <= balanceOf[_to]) {
            revert();
        }

        uint256 previousBalances = balanceOf[_from].add(balanceOf[_to]);
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from].add(balanceOf[_to]) == previousBalances);

        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        return _transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        return _transfer(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
        allowance[msg.sender][_spender] = (
        allowance[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
        uint256 oldValue = allowance[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowance[msg.sender][_spender] = 0;
        } else {
            allowance[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) noReentrant public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }
}

contract OSEToken is Ownable, ERC20Base {
    bool public isTokenLocked;
    bool public isUseFreeze;
    //used when use freeze
    mapping(address => uint256) public frozenAccount;
    //used when token locked
    mapping(address => bool) public whitelist;

    event FrozenFunds(address indexed target, uint256 freezeAmount);

    constructor()
    ERC20Base()
    public
    {
        name = "OpenSecurities";
        symbol = "OSE";
        totalSupply = 1000000000 * 1 ether;
        isUseFreeze = true;
        isTokenLocked = true;
        balanceOf[msg.sender] = totalSupply;
        whitelist[msg.sender] = true;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    modifier tokenLock() {
        if (isTokenLocked) {
            require(whitelist[msg.sender], "account not in whitelist");
        }
        _;
    }

    function setLockToken(bool _lock) onlyOwner public {
        isTokenLocked = _lock;
    }

    function setUseFreeze(bool _useOrNot) onlyOwner public {
        isUseFreeze = _useOrNot;
    }

    function setWhitelist(address target, bool _is) onlyOwner public {
        whitelist[target] = _is;
    }

    function freezeAmount(address target, uint256 amountFreeze) onlyOwner public {
        frozenAccount[target] = amountFreeze;
        emit FrozenFunds(target, amountFreeze);
    }

    function isFrozen(address target) public view returns (uint256) {
        return frozenAccount[target];
    }

    function _transfer(address _from, address _to, uint256 _value) tokenLock internal returns (bool success) {
        require(balanceOf[_from] >= _value);

        if (balanceOf[_to].add(_value) <= balanceOf[_to]) {
            revert();
        }

        if (isUseFreeze == true) {
            require(balanceOf[_from].sub(_value) >= frozenAccount[_from]);
        }

        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);

        return true;
    }
}