/**
 * Source Code first verified at https://etherscan.io on Tuesday, May 7, 2019
 (UTC) */

pragma solidity ^0.5.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {

    /**
    * @dev Bulkplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
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


interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; }

contract FIICToken is Ownable {
    using SafeMath for uint256;
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 0;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply;

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // accounts' lockFund property
    struct LockFund {
        uint256 amount;
        uint256 startTime;
        uint256 lockUnit;
        uint256 times;
        bool recyclable;
    }
    mapping (address => LockFund) public lockFunds;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This generates a public event on the blockchain that will notify clients
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    // lockFund event
    event LockTransfer(address indexed acc, uint256 amount, uint256 startTime, uint256 lockUnit, uint256 times);
    
    //  recycle token 
    event recycleToke(address indexed acc, uint256 amount, uint256 startTime);

    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor(
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        balanceOf[msg.sender] = totalSupply;                    // Give the creator all initial tokens
        name = tokenName;                                       // Set the name for display purposes
        symbol = tokenSymbol;                                   // Set the symbol for display purposes
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != address(0x0),"目的地址不能为空");
        
        require(_from != _to,"自己不能给自己转账");
        
        // if lock
        require(balanceOf[_from] - getLockedAmount(_from) >= _value,"转账的数量不能超过可用的数量");
        // Check for overflows
        require(balanceOf[_to] + _value > balanceOf[_to],"转账的数量有问题");
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);//"转账前后，两个地址总和不同"
        
        
    }

    function getLockedAmount(address _from) public view returns (uint256 lockAmount) {
        LockFund memory lockFund = lockFunds[_from];
        if(lockFund.amount > 0) {
            if(block.timestamp <= lockFund.startTime) {
                return lockFund.amount;
            }
            uint256 ap = lockFund.amount.div(lockFund.times);
            // uint256 ap = lockFund.amount / lockFund.times;
            // uint256 t = (block.timestamp - lockFund.startTime ) / lockFund.lockUnit;
            uint256 t = (block.timestamp.sub(lockFund.startTime)).div(lockFund.lockUnit);
//            uint256 t = (block.timestamp - lockFund.startTime) / (60 * 60 * 24) / lockFund.lockUnit;
            if(t < lockFund.times) {
                return lockFund.amount.sub(ap.mul(t));
            }
        }
        return 0;
    }
    
    function getReleaseAmount(address _from) public view returns (uint256 releaseAmount) {
       LockFund memory lockFund = lockFunds[_from];
        if(lockFund.amount > 0) {
            if(block.timestamp <= lockFund.startTime) {
                return 0;
            }
            uint256 ap = lockFund.amount / lockFund.times;
            uint256 t = (block.timestamp - lockFund.startTime) / lockFund.lockUnit;
            if(t>= lockFund.times){
                return lockFund.amount;
            }
            return ap * t;
        }
        return balanceOf[_from];
        
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` in behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }

    /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }

    /**
     * Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        emit Burn(_from, _value);
        return true;
    }

    /**
     * 锁仓的转账
     *
     * 从账户里给其他账户转锁仓的token，token按照一定的时间多次自动释放
     *
     * @param _lockAddress          接受锁仓token地址
     * @param _lockAmount           转账的总量
     * @param _startReleaseTime     释放起始的时间
     * @param _releaseInterval      释放的间隔时间
     * @param _releaseTimes         总共释放的次数
     * @param _recyclable           是否可回收，true为可以
     */
    function lockTransfer(address _lockAddress, uint256 _lockAmount, uint256 _startReleaseTime, uint256 _releaseInterval, uint256 _releaseTimes,bool _recyclable) onlyOwner public {
        // transfer token to _lockAddress
        _transfer(msg.sender, _lockAddress, _lockAmount);
        // add lockFund
        LockFund storage lockFund = lockFunds[_lockAddress];
        lockFund.amount = _lockAmount;
        lockFund.startTime = _startReleaseTime;
        lockFund.lockUnit = _releaseInterval;
        lockFund.times = _releaseTimes;
        lockFund.recyclable = _recyclable;

        emit LockTransfer(_lockAddress, _lockAmount, _startReleaseTime, _releaseInterval, _releaseTimes);
    }
    
    /**
     *
     * 将_lockAddress里的token回收
     *
     * @param _lockAddress          回收token的地址
     */
    function recycleRemainingToken(address _lockAddress) onlyOwner public{
        // 将计算还剩下的token数量
        LockFund storage lockFund = lockFunds[_lockAddress];
        require(lockFund.recyclable == true,"该地址不支持撤销操作");
        
        uint256 remaingCount = getLockedAmount(_lockAddress);
        
        // Check for overflows
        require(balanceOf[owner()] + remaingCount > balanceOf[owner()],"转账的数量有问题");
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[owner()] + balanceOf[_lockAddress];
        // Subtract from the sender
        balanceOf[_lockAddress] -= remaingCount;
        // Add the same to the recipient
        balanceOf[owner()] += remaingCount;
            
        lockFund.amount = 0;
        
        emit recycleToke(_lockAddress,remaingCount,block.timestamp);
        emit Transfer(_lockAddress, owner(), remaingCount);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[owner()] + balanceOf[_lockAddress] == previousBalances);//"转账前后，两个地址总和不同"
        
    }
}