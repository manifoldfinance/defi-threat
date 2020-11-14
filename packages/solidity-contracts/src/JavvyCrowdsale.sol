/**
 * Source Code first verified at https://etherscan.io on Thursday, May 9, 2019
 (UTC) */

pragma solidity ^0.4.24;


library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
            return 0;
        }

        c = _a * _b;
        assert(c / _a == _b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        // assert(_b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
        return _a / _b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        assert(_b <= _a);
        return _a - _b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        c = _a + _b;
        assert(c >= _a);
        return c;
    }
}

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
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
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

contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}

contract ERC20Basic {
    function totalSupply() public view returns (uint256);

    function balanceOf(address _who) public view returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
    function allowance(address _owner, address _spender)
    public view returns (uint256);

    function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

    function approve(address _spender, uint256 _value) public returns (bool);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeERC20 {
    function safeTransfer(
        ERC20Basic _token,
        address _to,
        uint256 _value
    )
    internal
    {
        require(_token.transfer(_to, _value));
    }

    function safeTransferFrom(
        ERC20 _token,
        address _from,
        address _to,
        uint256 _value
    )
    internal
    {
        require(_token.transferFrom(_from, _to, _value));
    }

    function safeApprove(
        ERC20 _token,
        address _spender,
        uint256 _value
    )
    internal
    {
        require(_token.approve(_spender, _value));
    }
}

contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) internal balances;

    uint256 internal totalSupply_;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**
    * @dev Transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_value <= balances[msg.sender]);
        require(_to != address(0));

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
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

}

contract StandardToken is ERC20, BasicToken {

    mapping(address => mapping(address => uint256)) internal allowed;


    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
    public
    returns (bool)
    {
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        require(_to != address(0));

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
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
    function allowance(
        address _owner,
        address _spender
    )
    public
    view
    returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the allowance by.
     */
    function increaseApproval(
        address _spender,
        uint256 _addedValue
    )
    public
    returns (bool)
    {
        allowed[msg.sender][_spender] = (
        allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseApproval(
        address _spender,
        uint256 _subtractedValue
    )
    public
    returns (bool)
    {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

contract DetailedERC20 is ERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;

    constructor(string _name, string _symbol, uint8 _decimals) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }
}

contract MultiSigWallet {
    uint constant public MAX_OWNER_COUNT = 50;

    event Confirmation(address indexed sender, uint indexed transactionId);
    event Revocation(address indexed sender, uint indexed transactionId);
    event Submission(uint indexed transactionId);
    event Execution(uint indexed transactionId);
    event ExecutionFailure(uint indexed transactionId);
    event Deposit(address indexed sender, uint value);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event RequirementChange(uint required);

    mapping(uint => Transaction) public transactions;
    mapping(uint => mapping(address => bool)) public confirmations;
    mapping(address => bool) public isOwner;

    address[] public owners;
    uint public required;
    uint public transactionCount;

    struct Transaction {
        address destination;
        uint value;
        bytes data;
        bool executed;
    }

    modifier onlyWallet() {
        require(msg.sender == address(this));
        _;
    }

    modifier ownerDoesNotExist(address owner) {
        require(!isOwner[owner]);
        _;
    }

    modifier ownerExists(address owner) {
        require(isOwner[owner]);
        _;
    }

    modifier transactionExists(uint transactionId) {
        require(transactions[transactionId].destination != 0);
        _;
    }

    modifier confirmed(uint transactionId, address owner) {
        require(confirmations[transactionId][owner]);
        _;
    }

    modifier notConfirmed(uint transactionId, address owner) {
        require(!confirmations[transactionId][owner]);
        _;
    }

    modifier notExecuted(uint transactionId) {
        require(!transactions[transactionId].executed);
        _;
    }

    modifier notNull(address _address) {
        require(_address != address(0));
        _;
    }

    modifier validRequirement(uint ownerCount, uint _required) {
        bool ownerValid = ownerCount <= MAX_OWNER_COUNT;
        bool ownerNotZero = ownerCount != 0;
        bool requiredValid = _required <= ownerCount;
        bool requiredNotZero = _required != 0;
        require(ownerValid && ownerNotZero && requiredValid && requiredNotZero);
        _;
    }

    /// @dev Fallback function allows to deposit ether.
    function() payable public {
        fallback();
    }

    function fallback() payable public {
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }

    /*
     * Public functions
     */
    /// @dev Contract constructor sets initial owners and required number of confirmations.
    /// @param _owners List of initial owners.
    /// @param _required Number of required confirmations.
    constructor(
        address[] _owners,
        uint _required
    ) public validRequirement(_owners.length, _required)
    {
        for (uint i = 0; i < _owners.length; i++) {
            require(!isOwner[_owners[i]] && _owners[i] != 0);
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        required = _required;
    }

    /// @dev Allows to add a new owner. Transaction has to be sent by wallet.
    /// @param owner Address of new owner.
    function addOwner(address owner)
    public
    onlyWallet
    ownerDoesNotExist(owner)
    notNull(owner)
    validRequirement(owners.length + 1, required)
    {
        isOwner[owner] = true;
        owners.push(owner);
        emit OwnerAddition(owner);
    }

    /// @dev Allows to remove an owner. Transaction has to be sent by wallet.
    /// @param owner Address of owner.
    function removeOwner(address owner)
    public
    onlyWallet
    ownerExists(owner)
    {
        isOwner[owner] = false;
        for (uint i = 0; i < owners.length - 1; i++)
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                break;
            }
        owners.length -= 1;
        if (required > owners.length)
            changeRequirement(owners.length);
        emit OwnerRemoval(owner);
    }

    /// @dev Allows to replace an owner with a new owner. Transaction has to be sent by wallet.
    /// @param owner Address of owner to be replaced.
    /// @param newOwner Address of new owner.
    function replaceOwner(address owner, address newOwner)
    public
    onlyWallet
    ownerExists(owner)
    ownerDoesNotExist(newOwner)
    {
        for (uint i = 0; i < owners.length; i++)
            if (owners[i] == owner) {
                owners[i] = newOwner;
                break;
            }
        isOwner[owner] = false;
        isOwner[newOwner] = true;
        emit OwnerRemoval(owner);
        emit OwnerAddition(newOwner);
    }

    /// @dev Allows to change the number of required confirmations. Transaction has to be sent by wallet.
    /// @param _required Number of required confirmations.
    function changeRequirement(uint _required)
    public
    onlyWallet
    validRequirement(owners.length, _required)
    {
        required = _required;
        emit RequirementChange(_required);
    }

    /// @dev Allows an owner to submit and confirm a transaction.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    /// @return Returns transaction ID.
    function submitTransaction(address destination, uint value, bytes data)
    public
    returns (uint transactionId)
    {
        transactionId = addTransaction(destination, value, data);
        confirmTransaction(transactionId);
    }

    /// @dev Allows an owner to confirm a transaction.
    /// @param transactionId Transaction ID.
    function confirmTransaction(uint transactionId)
    public
    ownerExists(msg.sender)
    transactionExists(transactionId)
    notConfirmed(transactionId, msg.sender)
    {
        confirmations[transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }

    /// @dev Allows an owner to revoke a confirmation for a transaction.
    /// @param transactionId Transaction ID.
    function revokeConfirmation(uint transactionId)
    public
    ownerExists(msg.sender)
    confirmed(transactionId, msg.sender)
    notExecuted(transactionId)
    {
        confirmations[transactionId][msg.sender] = false;
        emit Revocation(msg.sender, transactionId);
    }

    /// @dev Allows anyone to execute a confirmed transaction.
    /// @param transactionId Transaction ID.
    function executeTransaction(uint transactionId)
    public
    ownerExists(msg.sender)
    confirmed(transactionId, msg.sender)
    notExecuted(transactionId)
    {
        if (isConfirmed(transactionId)) {
            Transaction storage txn = transactions[transactionId];
            txn.executed = true;
            if (txn.destination.call.value(txn.value)(txn.data))
                emit Execution(transactionId);
            else {
                emit ExecutionFailure(transactionId);
                txn.executed = false;
            }
        }
    }

    /// @dev Returns the confirmation status of a transaction.
    /// @param transactionId Transaction ID.
    /// @return Confirmation status.
    function isConfirmed(uint transactionId) public view returns (bool) {
        uint count = 0;
        for (uint i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]])
                count += 1;
            if (count == required)
                return true;
        }
    }

    /*
     * Internal functions
     */
    /// @dev Adds a new transaction to the transaction mapping, if transaction does not exist yet.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    /// @return Returns transaction ID.
    function addTransaction(address destination, uint value, bytes data)
    internal
    notNull(destination)
    returns (uint transactionId)
    {
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination : destination,
            value : value,
            data : data,
            executed : false
            });
        transactionCount += 1;
        emit Submission(transactionId);
    }

    /*
     * Web3 call functions
     */
    /// @dev Returns number of confirmations of a transaction.
    /// @param transactionId Transaction ID.
    /// @return Number of confirmations.
    function getConfirmationCount(uint transactionId) public view returns (uint count) {
        for (uint i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]]) {
                count += 1;
            }
        }
    }

    /// @dev Returns total number of transactions after filers are applied.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return Total number of transactions after filters are applied.
    function getTransactionCount(
        bool pending,
        bool executed
    ) public view returns (uint count) {
        for (uint i = 0; i < transactionCount; i++) {
            if (pending &&
                !transactions[i].executed ||
                executed &&
                transactions[i].executed
            ) {
                count += 1;
            }
        }
    }

    /// @dev Returns list of owners.
    /// @return List of owner addresses.
    function getOwners() public view returns (address[]) {
        return owners;
    }

    /// @dev Returns array with owner addresses, which confirmed transaction.
    /// @param transactionId Transaction ID.
    /// @return Returns array of owner addresses.
    function getConfirmations(
        uint transactionId
    ) public view returns (address[] _confirmations) {
        address[] memory confirmationsTemp = new address[](owners.length);
        uint count = 0;
        uint i;
        for (i = 0; i < owners.length; i++)
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i = 0; i < count; i++)
            _confirmations[i] = confirmationsTemp[i];
    }

    /// @dev Returns list of transaction IDs in defined range.
    /// @param from Index start position of transaction array.
    /// @param to Index end position of transaction array.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return Returns array of transaction IDs.
    function getTransactionIds(
        uint from,
        uint to,
        bool pending,
        bool executed
    ) public view returns (uint[] _transactionIds) {
        uint[] memory transactionIdsTemp = new uint[](transactionCount);
        uint count = 0;
        uint i;
        for (i = 0; i < transactionCount; i++)
            if (pending &&
                !transactions[i].executed ||
                executed &&
                transactions[i].executed
            ) {
                transactionIdsTemp[count] = i;
                count += 1;
            }
        _transactionIds = new uint[](to - from);
        for (i = from; i < to; i++)
            _transactionIds[i - from] = transactionIdsTemp[i];
    }
}

contract JavvyMultiSig is MultiSigWallet {
    constructor(
        address[] _owners,
        uint _required
    )
    MultiSigWallet(_owners, _required)
    public {}
}

contract Config {
    uint256 public constant jvySupply = 333333333333333;
    uint256 public constant bonusSupply = 83333333333333;
    uint256 public constant saleSupply = 250000000000000;
    uint256 public constant hardCapUSD = 8000000;

    uint256 public constant preIcoBonus = 25;
    uint256 public constant minimalContributionAmount = 0.4 ether;

    function getStartPreIco() public view returns (uint256) {
        // solium-disable-next-line security/no-block-members
        uint256 _preIcoStartTime = block.timestamp + 1 minutes;
        return _preIcoStartTime;
    }

    function getStartIco() public view returns (uint256) {
        // uint256 _icoStartTime = 1543554000;
        // solium-disable-next-line security/no-block-members
        uint256 _icoStartTime = block.timestamp + 2 minutes;
        return _icoStartTime;
    }

    function getEndIco() public view returns (uint256) {
        // solium-disable-next-line security/no-block-members
        // uint256 _icoEndTime = block.timestamp + 50 days;
        // uint256 _icoEndTime = 1551416400;
        uint256 _icoEndTime = 1567209600;
        return _icoEndTime;
    }
}


contract JavvyToken is DetailedERC20, StandardToken, Ownable, Config {
    address public crowdsaleAddress;
    address public bonusAddress;
    address public multiSigAddress;

    constructor(
        string _name,
        string _symbol,
        uint8 _decimals
    ) public
    DetailedERC20(_name, _symbol, _decimals) {
        require(
            jvySupply == saleSupply + bonusSupply,
            "Sum of provided supplies is not equal to declared total Javvy supply. Check config!"
        );
        totalSupply_ = tokenToDecimals(jvySupply);
    }

    function initializeBalances(
        address _crowdsaleAddress,
        address _bonusAddress,
        address _multiSigAddress
    ) public
    onlyOwner() {
        crowdsaleAddress = _crowdsaleAddress;
        bonusAddress = _bonusAddress;
        multiSigAddress = _multiSigAddress;

        _initializeBalance(_crowdsaleAddress, saleSupply);
        _initializeBalance(_bonusAddress, bonusSupply);
    }

    function _initializeBalance(address _address, uint256 _supply) private {
        require(_address != address(0), "Address cannot be equal to 0x0!");
        require(_supply != 0, "Supply cannot be equal to 0!");
        balances[_address] = tokenToDecimals(_supply);
        emit Transfer(address(0), _address, _supply);
    }

    function tokenToDecimals(uint256 _amount) private pure returns (uint256){
        // NOTE for additional accuracy, we're using 6 decimal places in supply
        return _amount * (10 ** 12);
    }

    function getRemainingSaleTokens() external view returns (uint256) {
        return balanceOf(crowdsaleAddress);
    }

}

contract Escrow is Ownable {
    using SafeMath for uint256;

    event Deposited(address indexed payee, uint256 weiAmount);
    event Withdrawn(address indexed payee, uint256 weiAmount);

    mapping(address => uint256) private deposits;

    function depositsOf(address _payee) public view returns (uint256) {
        return deposits[_payee];
    }

    /**
    * @dev Stores the sent amount as credit to be withdrawn.
    * @param _payee The destination address of the funds.
    */
    function deposit(address _payee) public onlyOwner payable {
        uint256 amount = msg.value;
        deposits[_payee] = deposits[_payee].add(amount);

        emit Deposited(_payee, amount);
    }

    /**
    * @dev Withdraw accumulated balance for a payee.
    * @param _payee The address whose funds will be withdrawn and transferred to.
    */
    function withdraw(address _payee) public onlyOwner {
        uint256 payment = deposits[_payee];
        assert(address(this).balance >= payment);

        deposits[_payee] = 0;

        _payee.transfer(payment);

        emit Withdrawn(_payee, payment);
    }
}

contract ConditionalEscrow is Escrow {
    /**
    * @dev Returns whether an address is allowed to withdraw their funds. To be
    * implemented by derived contracts.
    * @param _payee The destination address of the funds.
    */
    function withdrawalAllowed(address _payee) public view returns (bool);

    function withdraw(address _payee) public {
        require(withdrawalAllowed(_payee));
        super.withdraw(_payee);
    }
}

contract RefundEscrow is Ownable, ConditionalEscrow {
    enum State {Active, Refunding, Closed}

    event Closed();
    event RefundsEnabled();

    State public state;
    address public beneficiary;

    /**
     * @dev Constructor.
     * @param _beneficiary The beneficiary of the deposits.
     */
    constructor(address _beneficiary) public {
        require(_beneficiary != address(0));
        beneficiary = _beneficiary;
        state = State.Active;
    }

    /**
     * @dev Stores funds that may later be refunded.
     * @param _refundee The address funds will be sent to if a refund occurs.
     */
    function deposit(address _refundee) public payable {
        require(state == State.Active);
        super.deposit(_refundee);
    }

    /**
     * @dev Allows for the beneficiary to withdraw their funds, rejecting
     * further deposits.
     */
    function close() public onlyOwner {
        require(state == State.Active);
        state = State.Closed;
        emit Closed();
    }

    /**
     * @dev Allows for refunds to take place, rejecting further deposits.
     */
    function enableRefunds() public onlyOwner {
        require(state == State.Active);
        state = State.Refunding;
        emit RefundsEnabled();
    }

    /**
     * @dev Withdraws the beneficiary's funds.
     */
    function beneficiaryWithdraw() public {
        require(state == State.Closed);
        beneficiary.transfer(address(this).balance);
    }

    /**
     * @dev Returns whether refundees can withdraw their deposits (be refunded).
     */
    function withdrawalAllowed(address _payee) public view returns (bool) {
        return state == State.Refunding;
    }
}

contract Crowdsale {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    // The token being sold
    ERC20 public token;

    // Address where funds are collected
    address public wallet;

    // How many token units a buyer gets per wei.
    // The rate is the conversion between wei and the smallest and indivisible token unit.
    // So, if you are using a rate of 1 with a DetailedERC20 token with 3 decimals called TOK
    // 1 wei will give you 1 unit, or 0.001 TOK.
    uint256 public rate;

    // Amount of wei raised
    uint256 public weiRaised;

    /**
     * Event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    /**
     * @param _rate Number of token units a buyer gets per wei
     * @param _wallet Address where collected funds will be forwarded to
     * @param _token Address of the token being sold
     */
    constructor(uint256 _rate, address _wallet, ERC20 _token) public {
        require(_rate > 0);
        require(_wallet != address(0));
        require(_token != address(0));

        rate = _rate;
        wallet = _wallet;
        token = _token;
    }

    // -----------------------------------------
    // Crowdsale external interface
    // -----------------------------------------

    /**
     * @dev fallback function ***DO NOT OVERRIDE***
     */
    function() external payable {
        buyTokens(msg.sender);
    }

    /**
     * @dev low level token purchase ***DO NOT OVERRIDE***
     * @param _beneficiary Address performing the token purchase
     */
    function buyTokens(address _beneficiary) public payable {

        uint256 weiAmount = msg.value;
        _preValidatePurchase(_beneficiary, weiAmount);

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);

        // update state
        weiRaised = weiRaised.add(weiAmount);

        _processPurchase(_beneficiary, tokens);
        emit TokenPurchase(
            msg.sender,
            _beneficiary,
            weiAmount,
            tokens
        );

        _updatePurchasingState(_beneficiary, weiAmount);

        _forwardFunds();
        _postValidatePurchase(_beneficiary, weiAmount);
    }

    // -----------------------------------------
    // Internal interface (extensible)
    // -----------------------------------------

    /**
     * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use `super` in contracts that inherit from Crowdsale to extend their validations.
     * Example from CappedCrowdsale.sol's _preValidatePurchase method:
     *   super._preValidatePurchase(_beneficiary, _weiAmount);
     *   require(weiRaised.add(_weiAmount) <= cap);
     * @param _beneficiary Address performing the token purchase
     * @param _weiAmount Value in wei involved in the purchase
     */
    function _preValidatePurchase(
        address _beneficiary,
        uint256 _weiAmount
    )
    internal
    {
        require(_beneficiary != address(0));
        require(_weiAmount != 0);
    }

    /**
     * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
     * @param _beneficiary Address performing the token purchase
     * @param _weiAmount Value in wei involved in the purchase
     */
    function _postValidatePurchase(
        address _beneficiary,
        uint256 _weiAmount
    )
    internal
    {
        // optional override
    }

    /**
     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
     * @param _beneficiary Address performing the token purchase
     * @param _tokenAmount Number of tokens to be emitted
     */
    function _deliverTokens(
        address _beneficiary,
        uint256 _tokenAmount
    )
    internal
    {
        token.safeTransfer(_beneficiary, _tokenAmount);
    }

    /**
     * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
     * @param _beneficiary Address receiving the tokens
     * @param _tokenAmount Number of tokens to be purchased
     */
    function _processPurchase(
        address _beneficiary,
        uint256 _tokenAmount
    )
    internal
    {
        _deliverTokens(_beneficiary, _tokenAmount);
    }

    /**
     * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
     * @param _beneficiary Address receiving the tokens
     * @param _weiAmount Value in wei involved in the purchase
     */
    function _updatePurchasingState(
        address _beneficiary,
        uint256 _weiAmount
    )
    internal
    {
        // optional override
    }

    /**
     * @dev Override to extend the way in which ether is converted to tokens.
     * @param _weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint256 _weiAmount)
    internal view returns (uint256)
    {
        return _weiAmount.mul(rate);
    }

    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds() internal {
        wallet.transfer(msg.value);
    }
}

contract CappedCrowdsale is Crowdsale {
    using SafeMath for uint256;

    uint256 public cap;

    /**
     * @dev Constructor, takes maximum amount of wei accepted in the crowdsale.
     * @param _cap Max amount of wei to be contributed
     */
    constructor(uint256 _cap) public {
        require(_cap > 0);
        cap = _cap;
    }

    /**
     * @dev Checks whether the cap has been reached.
     * @return Whether the cap was reached
     */
    function capReached() public view returns (bool) {
        return weiRaised >= cap;
    }

    /**
     * @dev Extend parent behavior requiring purchase to respect the funding cap.
     * @param _beneficiary Token purchaser
     * @param _weiAmount Amount of wei contributed
     */
    function _preValidatePurchase(
        address _beneficiary,
        uint256 _weiAmount
    )
    internal
    {
        super._preValidatePurchase(_beneficiary, _weiAmount);
        require(weiRaised.add(_weiAmount) <= cap);
    }

}

contract TimedCrowdsale is Crowdsale {
    using SafeMath for uint256;

    uint256 public openingTime;
    uint256 public closingTime;

    /**
     * @dev Reverts if not in crowdsale time range.
     */
    modifier onlyWhileOpen {
        // solium-disable-next-line security/no-block-members
        require(block.timestamp >= openingTime && block.timestamp <= closingTime);
        _;
    }

    /**
     * @dev Constructor, takes crowdsale opening and closing times.
     * @param _openingTime Crowdsale opening time
     * @param _closingTime Crowdsale closing time
     */
    constructor(uint256 _openingTime, uint256 _closingTime) public {
        // solium-disable-next-line security/no-block-members
        require(_openingTime >= block.timestamp);
        require(_closingTime >= _openingTime);

        openingTime = _openingTime;
        closingTime = _closingTime;
    }

    /**
     * @dev Checks whether the period in which the crowdsale is open has already elapsed.
     * @return Whether crowdsale period has elapsed
     */
    function hasClosed() public view returns (bool) {
        // solium-disable-next-line security/no-block-members
        return block.timestamp > closingTime;
    }

    /**
     * @dev Extend parent behavior requiring to be within contributing period
     * @param _beneficiary Token purchaser
     * @param _weiAmount Amount of wei contributed
     */
    function _preValidatePurchase(
        address _beneficiary,
        uint256 _weiAmount
    )
    internal
    onlyWhileOpen
    {
        super._preValidatePurchase(_beneficiary, _weiAmount);
    }

}

contract FinalizableCrowdsale is Ownable, TimedCrowdsale {
    using SafeMath for uint256;

    bool public isFinalized = false;

    event Finalized();

    /**
     * @dev Must be called after crowdsale ends, to do some extra finalization
     * work. Calls the contract's finalization function.
     */
    function finalize() public onlyOwner {
        require(!isFinalized);
        require(hasClosed());

        finalization();
        emit Finalized();

        isFinalized = true;
    }

    /**
     * @dev Can be overridden to add finalization logic. The overriding function
     * should call super.finalization() to ensure the chain of finalization is
     * executed entirely.
     */
    function finalization() internal {
    }

}

contract RefundableCrowdsale is FinalizableCrowdsale {
    using SafeMath for uint256;

    // minimum amount of funds to be raised in weis
    uint256 public goal;

    // refund escrow used to hold funds while crowdsale is running
    RefundEscrow private escrow;

    /**
     * @dev Constructor, creates RefundEscrow.
     * @param _goal Funding goal
     */
    constructor(uint256 _goal) public {
        require(_goal > 0);
        escrow = new RefundEscrow(wallet);
        goal = _goal;
    }

    /**
     * @dev Investors can claim refunds here if crowdsale is unsuccessful
     */
    function claimRefund() public {
        require(isFinalized);
        require(!goalReached());

        escrow.withdraw(msg.sender);
    }

    /**
     * @dev Checks whether funding goal was reached.
     * @return Whether funding goal was reached
     */
    function goalReached() public view returns (bool) {
        return weiRaised >= goal;
    }

    /**
     * @dev escrow finalization task, called when owner calls finalize()
     */
    function finalization() internal {
        if (goalReached()) {
            escrow.close();
            escrow.beneficiaryWithdraw();
        } else {
            escrow.enableRefunds();
        }

        super.finalization();
    }

    /**
     * @dev Overrides Crowdsale fund forwarding, sending funds to escrow.
     */
    function _forwardFunds() internal {
        escrow.deposit.value(msg.value)(msg.sender);
    }

}

contract JavvyCrowdsale is RefundableCrowdsale, CappedCrowdsale, Pausable, Config {
    uint256 public icoStartTime;
    address public transminingAddress;
    address public bonusAddress;
    uint256 private USDETHRate;

    mapping(address => bool) public blacklisted;

    JavvyToken token;

    enum Stage {
        NotStarted,
        PreICO,
        ICO,
        AfterICO
    }

    function getStage() public view returns (Stage) {
        // solium-disable-next-line security/no-block-members
        uint256 blockTime = block.timestamp;
        if (blockTime < openingTime) return Stage.NotStarted;
        if (blockTime < icoStartTime) return Stage.PreICO;
        if (blockTime < closingTime) return Stage.ICO;
        else return Stage.AfterICO;
    }

    constructor(
        uint256 _rate,
        JavvyMultiSig _wallet,
        JavvyToken _token,
    // Should be equal to cap = hardCapUSD * USDETHInitialRate;
    // 8000000 * 7692307692307692 = 61538461538461536000000
        uint256 _cap,
        uint256 _goal,
        address _bonusAddress,
        address[] _blacklistAddresses,
        uint256 _USDETHRate
    )
    Crowdsale(_rate, _wallet, _token)
    CappedCrowdsale(_cap)
    TimedCrowdsale(getStartPreIco(), getEndIco())
    RefundableCrowdsale(_goal)
    public {
        // require(_cap == _USDETHRate.mul(hardCapUSD), "Hard cap is not equal to formula");
        require(getStartIco() > block.timestamp, "ICO has to begin in the future");
        require(getEndIco() > block.timestamp, "ICO has to end in the future");
        require(_goal <= _cap, "Soft cap should be equal or smaller than hard cap");
        icoStartTime = getStartIco();
        bonusAddress = _bonusAddress;
        token = _token;
        for (uint256 i = 0; i < _blacklistAddresses.length; i++) {
            blacklisted[_blacklistAddresses[i]] = true;
        }
        setUSDETHRate(_USDETHRate);
        // TODO: Don't forgot about this when deploying
        // TODO: It's set to continue old ICO
        weiRaised = 46461161522138564065713;
    }

    function buyTokens(address _beneficiary) public payable {
        require(!blacklisted[msg.sender], "Sender is blacklisted");
        bool preallocated = false;
        uint256 preallocatedTokens = 0;

        _buyTokens(
            _beneficiary,
            msg.sender,
            msg.value,
            preallocated,
            preallocatedTokens
        );
    }

    function bulkPreallocate(address[] _owners, uint256[] _tokens, uint256[] _paid)
    public
    onlyOwner() {
        require(
            _owners.length == _tokens.length,
            "Lengths of parameter lists have to be equal"
        );
        require(
            _owners.length == _paid.length,
            "Lengths of parameter lists have to be equal"
        );
        for (uint256 i = 0; i < _owners.length; i++) {
            preallocate(_owners[i], _tokens[i], _paid[i]);
        }
    }

    function preallocate(address _owner, uint256 _tokens, uint256 _paid)
    public
    onlyOwner() {
        require(!blacklisted[_owner], "Address where tokens will be sent is blacklisted");
        bool preallocated = true;
        uint256 preallocatedTokens = _tokens;

        _buyTokens(
            _owner,
            _owner,
            _paid,
            preallocated,
            preallocatedTokens
        );
    }

    function setTransminingAddress(address _transminingAddress) public
    onlyOwner() {
        transminingAddress = _transminingAddress;
    }

    // Created for moving funds later to transmining address
    function moveTokensToTransmining(uint256 _amount) public
    onlyOwner() {
        uint256 remainingTokens = token.getRemainingSaleTokens();
        require(
            transminingAddress != address(0),
            "Transmining address must be set!"
        );
        require(
            remainingTokens >= _amount,
            "Balance of remaining tokens for sale is smaller than requested amount for trans-mining"
        );
        uint256 weiNeeded = cap - weiRaised;
        uint256 tokensNeeded = weiNeeded * rate;

        if (getStage() != Stage.AfterICO) {
            require(remainingTokens - _amount > tokensNeeded, "You need to leave enough tokens to reach hard cap");
        }
        _deliverTokens(transminingAddress, _amount, this);
    }

    function _buyTokens(
        address _beneficiary,
        address _sender,
        uint256 _value,
        bool _preallocated,
        uint256 _tokens
    ) internal
    whenNotPaused() {
        uint256 tokens;

        if (!_preallocated) {
            // pre validate params
            require(
                _value >= minimalContributionAmount,
                "Amount contributed should be greater than required minimal contribution"
            );
            require(_tokens == 0, "Not preallocated tokens should be zero");
            _preValidatePurchase(_beneficiary, _value);
        } else {
            require(_tokens != 0, "Preallocated tokens should be greater than zero");
            require(weiRaised.add(_value) <= cap, "Raised tokens should not exceed hard cap");
        }

        // calculate tokens
        if (!_preallocated) {
            tokens = _getTokenAmount(_value);
        } else {
            tokens = _tokens;
        }

        // increase wei
        weiRaised = weiRaised.add(_value);

        _processPurchase(_beneficiary, tokens, this);

        emit TokenPurchase(
            _sender,
            _beneficiary,
            _value,
            tokens
        );

        // transfer payment
        _updatePurchasingState(_beneficiary, _value);
        _forwardFunds();

        // post validate
        if (!_preallocated) {
            _postValidatePurchase(_beneficiary, _value);
        }
    }

    function _getBaseTokens(uint256 _value) internal view returns (uint256) {
        return _value.mul(rate);
    }

    function _getTokenAmount(uint256 _weiAmount)
    internal view returns (uint256) {
        uint256 baseTokens = _getBaseTokens(_weiAmount);
        if (getStage() == Stage.PreICO) {
            return baseTokens.mul(100 + preIcoBonus).div(100);
        } else {
            return baseTokens;
        }
    }

    function _processPurchase(
        address _beneficiary,
        uint256 _tokenAmount,
        address _sourceAddress
    ) internal {
        _deliverTokens(_beneficiary, _tokenAmount, _sourceAddress);
    }

    function _deliverTokens(
        address _beneficiary,
        uint256 _tokenAmount,
        address _sourceAddress
    ) internal {
        if (_sourceAddress == address(this)) {
            token.transfer(_beneficiary, _tokenAmount);
        } else {
            token.transferFrom(_sourceAddress, _beneficiary, _tokenAmount);
        }
    }

    function finalization() internal {
        require(
            transminingAddress != address(0),
            "Transmining address must be set!"
        );
        super.finalization();

        _deliverTokens(transminingAddress, token.getRemainingSaleTokens(), this);
    }

    function setUSDETHRate(uint256 _USDETHRate) public
    onlyOwner() {
        require(_USDETHRate > 0, "USDETH rate should not be zero");
        USDETHRate = _USDETHRate;
        cap = hardCapUSD.mul(USDETHRate);
    }
}