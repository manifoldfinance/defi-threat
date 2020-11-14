/**
 * Source Code first verified at https://etherscan.io on Wednesday, April 17, 2019
 (UTC) */

pragma solidity >=0.5.0 <0.6.0;

/**
 * @title SafeMath for uint256
 * @dev Math operations with safety checks that throw on error
 */
library SafeMathUint256 {
    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath: Multiplier exception");
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b; // Solidity automatically throws when dividing by 0
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: Subtraction exception");
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a, "SafeMath: Addition exception");
        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: Modulo exception");
        return a % b;
    }

}

/**
 * @title SafeMath for uint8
 * @dev Math operations with safety checks that throw on error
 */
library SafeMathUint8 {
    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint8 a, uint8 b) internal pure returns (uint8 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath: Multiplier exception");
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint8 a, uint8 b) internal pure returns (uint8) {
        return a / b; // Solidity automatically throws when dividing by 0
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint8 a, uint8 b) internal pure returns (uint8) {
        require(b <= a, "SafeMath: Subtraction exception");
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint8 a, uint8 b) internal pure returns (uint8 c) {
        c = a + b;
        require(c >= a, "SafeMath: Addition exception");
        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint8 a, uint8 b) internal pure returns (uint8) {
        require(b != 0, "SafeMath: Modulo exception");
        return a % b;
    }

}

contract Ownership {
    address payable public owner;
    address payable public pendingOwner;

    event OwnershipTransferred (address indexed from, address indexed to);

    constructor () public
    {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require (msg.sender == owner, "Ownership: Access denied");
        _;
    }

    function transferOwnership (address payable _pendingOwner) public
        onlyOwner
    {
        pendingOwner = _pendingOwner;
    }

    function acceptOwnership () public
    {
        require (msg.sender == pendingOwner, "Ownership: Only new owner is allowed");

        emit OwnershipTransferred (owner, pendingOwner);

        owner = pendingOwner;
        pendingOwner = address(0);
    }

}

/**
 * @title Controllable contract
 * @dev Implementation of the controllable operations
 */
contract Controllable is Ownership {

    bool public stopped;
    mapping (address => bool) public freezeAddresses;

    event Paused();
    event Resumed();

    event FreezeAddress(address indexed addressOf);
    event UnfreezeAddress(address indexed addressOf);

    modifier onlyActive(address _sender) {
        require(!freezeAddresses[_sender], "Controllable: Not active");
        _;
    }

    modifier isUsable {
        require(!stopped, "Controllable: Paused");
        _;
    }

    function pause () public
        onlyOwner
    {
        stopped = true;
        emit Paused ();
    }
    
    function resume () public
        onlyOwner
    {
        stopped = false;
        emit Resumed ();
    }

    function freezeAddress(address _addressOf) public
        onlyOwner
        returns (bool)
    {
        if (!freezeAddresses[_addressOf]) {
            freezeAddresses[_addressOf] = true;
            emit FreezeAddress(_addressOf);
        }

        return true;
    }
	
    function unfreezeAddress(address _addressOf) public
        onlyOwner
        returns (bool)
    {
        if (freezeAddresses[_addressOf]) {
            delete freezeAddresses[_addressOf];
            emit UnfreezeAddress(_addressOf);
        }

        return true;
    }

}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic, Controllable {
    using SafeMathUint256 for uint256;

    mapping(address => uint256) balances;

    uint256 public totalSupply;

    constructor(uint256 _initialSupply) public
    {
        totalSupply = _initialSupply;

        if (0 < _initialSupply) {
            balances[msg.sender] = _initialSupply;
            emit Transfer(address(0), msg.sender, _initialSupply);
        }
    }

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public
        isUsable
        onlyActive(msg.sender)
        onlyActive(_to)
        returns (bool)
    {
        require(0 < _value, "BasicToken.transfer: Zero value");
        require(_value <= balances[msg.sender], "BasicToken.transfer: Insufficient fund");

        // SafeMath.sub will throw if there is not enough balance.
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
    function balanceOf(address _owner) public view
        returns (uint256 balance)
    {
        return balances[_owner];
    }

}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 */
contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;

    /**
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
    function transferFrom(address _from, address _to, uint256 _value) public
        isUsable
        onlyActive(msg.sender)
        onlyActive(_from)
        onlyActive(_to)
        returns (bool)
    {
        require(0 < _value, "StandardToken.transferFrom: Zero value");
        require(_value <= balances[_from], "StandardToken.transferFrom: Insufficient fund");
        require(_value <= allowed[_from][msg.sender], "StandardToken.transferFrom: Insufficient allowance");

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    *
    * Beware that changing an allowance with this method brings the risk that someone may use both the old
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
    function approve(address _spender, uint256 _value) public
        isUsable
        onlyActive(msg.sender)
        onlyActive(_spender)
        returns (bool)
    {
        require(0 < _value, "StandardToken.approve: Zero value");

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param _owner address The address which owns the funds.
    * @param _spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender.
    */
    function allowance(address _owner, address _spender) public view
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    /**
    * @dev Increase the amount of tokens that an owner allowed to a spender.
    *
    * approve should be called when allowed[_spender] == 0. To increment
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param _spender The address which will spend the funds.
    * @param _addedValue The amount of tokens to increase the allowance by.
    */
    function increaseApproval(address _spender, uint256 _addedValue) public
        isUsable
        onlyActive(msg.sender)
        onlyActive(_spender)
        returns (bool)
    {
        require(0 < _addedValue, "StandardToken.increaseApproval: Zero value");

        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
    * @dev Decrease the amount of tokens that an owner allowed to a spender.
    *
    * approve should be called when allowed[_spender] == 0. To decrement
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param _spender The address which will spend the funds.
    * @param _subtractedValue The amount of tokens to decrease the allowance by.
    */
    function decreaseApproval(address _spender, uint256 _subtractedValue) public
        isUsable
        onlyActive(msg.sender)
        onlyActive(_spender)
        returns (bool)
    {
        require(0 < _subtractedValue, "StandardToken.decreaseApproval: Zero value");

        uint256 oldValue = allowed[msg.sender][_spender];

        if (_subtractedValue > oldValue)
            allowed[msg.sender][_spender] = 0;
        else
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

contract ApprovalReceiver {
    function receiveApproval(address _from, uint256 _value, address _tokenContract, bytes calldata _extraData) external;
}

contract USDA is StandardToken {
    using SafeMathUint256 for uint256;

    bytes32 constant FREEZE_CODE_DEFAULT = 0x0000000000000000000000000000000000000000000000000000000000000000;

    event Freeze(address indexed from, uint256 value);
    event Unfreeze(address indexed from, uint256 value);

    event FreezeWithPurpose(address indexed from, uint256 value, bytes32 purpose);
    event UnfreezeWithPurpose(address indexed from, uint256 value, bytes32 purpose);

    string public name;
    string public symbol;
    uint8 public decimals;

    // Keep track total frozen balances
    mapping (address => uint256) public freezeOf;
    // Keep track sub total frozen balances
    mapping (address => mapping (bytes32 => uint256)) public freezes;

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _initialSupply) public
        BasicToken(_initialSupply)
    {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    /**
     * @dev Increase total supply (mint) to an address
     *
     * @param _value The amount of tokens to be mint
     * @param _to The address which will receive token
     */
    function increaseSupply(uint256 _value, address _to) external
        onlyOwner
        onlyActive(_to)
        returns (bool)
    {
        require(0 < _value, "StableCoin.increaseSupply: Zero value");

        totalSupply = totalSupply.add(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(address(0), _to, _value);
        return true;
    }

    /**
     * @dev Increase total supply (mint) to an address with deposit
     *
     * @param _value The amount of tokens to be mint
     * @param _to The address which will receive token
     * @param _deposit The amount of deposit
     */
    function increaseSupplyWithDeposit(uint256 _value, address _to, uint256 _deposit) external
        onlyOwner
        onlyActive(_to)
        returns (bool)
    {
        require(0 < _value, "StableCoin.increaseSupplyWithDeposit: Zero value");
        require(_deposit <= _value, "StableCoin.increaseSupplyWithDeposit: Insufficient deposit");

        totalSupply = totalSupply.add(_value);
        balances[_to] = balances[_to].add(_value);
        freezeWithPurposeCode(_to, _deposit, encodePacked("InitialDeposit"));
        emit Transfer(address(0), _to, _value.sub(_deposit));
        return true;
    }

    /**
     * @dev Decrease total supply (burn) from an address that gave allowance
     *
     * @param _value The amount of tokens to be burn
     * @param _from The address's token will be burn
     */
    function decreaseSupply(uint256 _value, address _from) external
        onlyOwner
        onlyActive(_from)
        returns (bool)
    {
        require(0 < _value, "StableCoin.decreaseSupply: Zero value");
        require(_value <= balances[_from], "StableCoin.decreaseSupply: Insufficient fund");
        require(_value <= allowed[_from][address(0)], "StableCoin.decreaseSupply: Insufficient allowance");

        totalSupply = totalSupply.sub(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][address(0)] = allowed[_from][address(0)].sub(_value);
        emit Transfer(_from, address(0), _value);
        return true;
    }
	
    /**
    * @dev Freeze holder balance
    *
    * @param _from The address which will be freeze
    * @param _value The amount of tokens to be freeze
    */
    function freeze(address _from, uint256 _value) external
        onlyOwner
        returns (bool)
    {
        require(_value <= balances[_from], "StableCoin.freeze: Insufficient fund");

        balances[_from] = balances[_from].sub(_value);
        freezeOf[_from] = freezeOf[_from].add(_value);
        freezes[_from][FREEZE_CODE_DEFAULT] = freezes[_from][FREEZE_CODE_DEFAULT].add(_value);
        emit Freeze(_from, _value);
        emit FreezeWithPurpose(_from, _value, FREEZE_CODE_DEFAULT);
        return true;
    }
	
    /**
    * @dev Freeze holder balance with purpose code
    *
    * @param _from The address which will be freeze
    * @param _value The amount of tokens to be freeze
    * @param _purpose The purpose of freeze
    */
    function freezeWithPurpose(address _from, uint256 _value, string calldata _purpose) external
        returns (bool)
    {
        return freezeWithPurposeCode(_from, _value, encodePacked(_purpose));
    }
	
    /**
    * @dev Freeze holder balance with purpose code
    *
    * @param _from The address which will be freeze
    * @param _value The amount of tokens to be freeze
    * @param _purposeCode The purpose code of freeze
    */
    function freezeWithPurposeCode(address _from, uint256 _value, bytes32 _purposeCode) public
        onlyOwner
        returns (bool)
    {
        require(_value <= balances[_from], "StableCoin.freezeWithPurposeCode: Insufficient fund");

        balances[_from] = balances[_from].sub(_value);
        freezeOf[_from] = freezeOf[_from].add(_value);
        freezes[_from][_purposeCode] = freezes[_from][_purposeCode].add(_value);
        emit Freeze(_from, _value);
        emit FreezeWithPurpose(_from, _value, _purposeCode);
        return true;
    }
	
    /**
    * @dev Unfreeze holder balance
    *
    * @param _from The address which will be unfreeze
    * @param _value The amount of tokens to be unfreeze
    */
    function unfreeze(address _from, uint256 _value) external
        onlyOwner
        returns (bool)
    {
        require(_value <= freezes[_from][FREEZE_CODE_DEFAULT], "StableCoin.unfreeze: Insufficient fund");

        freezeOf[_from] = freezeOf[_from].sub(_value);
        freezes[_from][FREEZE_CODE_DEFAULT] = freezes[_from][FREEZE_CODE_DEFAULT].sub(_value);
        balances[_from] = balances[_from].add(_value);
        emit Unfreeze(_from, _value);
        emit UnfreezeWithPurpose(_from, _value, FREEZE_CODE_DEFAULT);
        return true;
    }

    /**
    * @dev Unfreeze holder balance with purpose code
    *
    * @param _from The address which will be unfreeze
    * @param _value The amount of tokens to be unfreeze
    * @param _purpose The purpose of unfreeze
    */
    function unfreezeWithPurpose(address _from, uint256 _value, string calldata _purpose) external
        onlyOwner
        returns (bool)
    {
        return unfreezeWithPurposeCode(_from, _value, encodePacked(_purpose));
    }

    /**
    * @dev Unfreeze holder balance with purpose code
    *
    * @param _from The address which will be unfreeze
    * @param _value The amount of tokens to be unfreeze
    * @param _purposeCode The purpose code of unfreeze
    */
    function unfreezeWithPurposeCode(address _from, uint256 _value, bytes32 _purposeCode) public
        onlyOwner
        returns (bool)
    {
        require(_value <= freezes[_from][_purposeCode], "StableCoin.unfreezeWithPurposeCode: Insufficient fund");

        freezeOf[_from] = freezeOf[_from].sub(_value);
        freezes[_from][_purposeCode] = freezes[_from][_purposeCode].sub(_value);
        balances[_from] = balances[_from].add(_value);
        emit Unfreeze(_from, _value);
        emit UnfreezeWithPurpose(_from, _value, _purposeCode);
        return true;
    }

    /**
     * @dev Allocate allowance and perform contract call
     *
     * @param _spender The spender address
     * @param _value The allowance value
     * @param _extraData The function call data
     */
    function approveAndCall(address _spender, uint256 _value, bytes calldata _extraData) external
        isUsable
        returns (bool)
    {
        // Give allowance to spender (previous approved allowances will be clear)
        approve(_spender, _value);

        ApprovalReceiver(_spender).receiveApproval(msg.sender, _value, address(this), _extraData);
        return true;
    }

    function encodePacked(string memory s) internal pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(s));
    }

}