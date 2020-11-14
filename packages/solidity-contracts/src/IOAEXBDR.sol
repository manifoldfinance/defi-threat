/**
 * Source Code first verified at https://etherscan.io on Tuesday, April 30, 2019
 (UTC) */

pragma solidity 0.5.4;


library SafeMath {

    uint256 constant internal MAX_UINT = 2 ** 256 - 1; // max uint256

    /**
     * @dev Multiplies two numbers, reverts on overflow.
     */
    function mul(uint256 _a, uint256 _b) internal pure returns(uint256) {
        if (_a == 0) {
            return 0;
        }
        require(MAX_UINT / _a >= _b);
        return _a * _b;
    }

    /**
     * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 _a, uint256 _b) internal pure returns(uint256) {
        require(_b != 0);
        return _a / _b;
    }

    /**
     * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 _a, uint256 _b) internal pure returns(uint256) {
        require(_b <= _a);
        return _a - _b;
    }

    /**
     * @dev Adds two numbers, reverts on overflow.
     */
    function add(uint256 _a, uint256 _b) internal pure returns(uint256) {
        require(MAX_UINT - _a >= _b);
        return _a + _b;
    }

}

interface AbcInterface {
    function decimals() external view returns (uint8);
    function tokenFallback(address _from, uint _value, bytes calldata _data) external;
    function transfer(address _to, uint _value) external returns (bool);
}
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () public {
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
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
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


contract StandardToken {
    using SafeMath for uint256;

    mapping(address => uint256) internal balances;

    mapping(address => mapping(address => uint256)) internal allowed;

    uint256 public totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Gets the balance of the specified address.
     * @param _owner The address to query the balance of.
     * @return An uint256 representing the value owned by the passed address.
     */
    function balanceOf(address _owner) public view returns(uint256) {
        return balances[_owner];
    }

    /**
     * @dev Function to check the value of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the value of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public view returns(uint256) {
        return allowed[_owner][_spender];
    }

    /**
     * @dev Transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The value to be transferred.
     */
    function transfer(address _to, uint256 _value) public returns(bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified value of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The value of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns(bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the value of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Increase the value of tokens that an owner allowed to a spender.
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _addedValue The value of tokens to increase the allowance by.
     */
    function increaseApproval(address _spender, uint256 _addedValue) public returns(bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     * @dev Decrease the value of tokens that an owner allowed to a spender.
     * approve should be called when allowed[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The value of tokens to decrease the allowance by.
     */
    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns(bool) {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0));
        totalSupply = totalSupply.sub(value);
        balances[account] = balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Internal function that burns an value of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * @param account The account whose tokens will be burnt.
     * @param value The value that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
        // this function needs to emit an event with the updated approval.
        allowed[account][msg.sender] = allowed[account][msg.sender].sub(value);
        _burn(account, value);
    }

}


contract BurnableToken is StandardToken {

    /**
     * @dev Burns a specific value of tokens.
     * @param value The value of token to be burned.
     */
    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }

    /**
     * @dev Burns a specific value of tokens from the target address and decrements allowance
     * @param from address The address which you want to send tokens from
     * @param value uint256 The value of token to be burned
     */
    function burnFrom(address from, uint256 value) public {
        _burnFrom(from, value);
    }
}


/**
 * @title Pausable token
 * @dev ERC20 modified with pausable transfers.
 */
contract PausableToken is StandardToken, Pausable {
    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        return super.approve(spender, value);
    }

    function increaseApproval(address spender, uint256 addedValue) public whenNotPaused returns (bool success) {
        return super.increaseApproval(spender, addedValue);
    }

    function decreaseApproval(address spender, uint256 subtractedValue) public whenNotPaused returns (bool success) {
        return super.decreaseApproval(spender, subtractedValue);
    }
}

contract LockableToken is PausableToken {
	struct LockInfo {
		uint256 amount;
		uint256 releaseTime;
	}

	mapping(address => LockInfo[]) public lockDetail;
	mapping(address => uint256) public transferLocked;

	event LockToken(address indexed benefit, uint256 amount, uint256 releasetime);
	event ReleaseToken(address indexed benefit, uint256 amount);
	
	/**
     * @dev Transfers and locks tokens.
     * @param to The address to transfer to.
     * @param value The value to be transferred.
     * @param lockdays The days of locking tokens.
     */
	function transferAndLock(address to, uint256 value, uint256 lockdays) public whenNotPaused returns (bool) {
		release(msg.sender);
		require(to != address(0) && value != 0 && lockdays != 0);
		uint256 _releaseTime = now.add(lockdays.mul(1 days));
		lockDetail[to].push(LockInfo({amount:value, releaseTime:_releaseTime}));
		balances[msg.sender] = balances[msg.sender].sub(value);
		transferLocked[to] = transferLocked[to].add(value);
		emit Transfer(msg.sender, to, value);
		emit LockToken(to, value, _releaseTime);
		return true;
	}

	/**
     * @dev Rewrites function transfer, release tokens before transferring.
     */
    function transfer(address to, uint256 value) public returns (bool) {
		release(msg.sender);
        return super.transfer(to, value);
    }

	/**
     * @dev Rewrites function transferFrom, release tokens before transferring.
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        release(from);
        return super.transferFrom(from, to, value);
    }

	/**
     * @dev release tokens.
     */
	function release(address benefit) public whenNotPaused {
		uint256 len = lockDetail[benefit].length;
		if( len == 0) return;
		uint256 totalReleasable = 0;
		for(uint256 i = 0; i < len; i = i.add(1)){
			LockInfo memory tmp = lockDetail[benefit][i];
			if(tmp.releaseTime != 0 && now >= tmp.releaseTime){
				totalReleasable = totalReleasable.add(tmp.amount);
				delete lockDetail[benefit][i];
			}
		}
		if(totalReleasable == 0) return;
		balances[benefit] = balances[benefit].add(totalReleasable);
		transferLocked[benefit] = transferLocked[benefit].sub(totalReleasable);
		if(transferLocked[benefit] == 0)
		delete lockDetail[benefit];
		emit ReleaseToken(benefit, totalReleasable);

	}

	/**
     * @dev Calculates the amount of releasable tokens.
     */
	function releasableTokens(address benefit) public view returns(uint256) {
		uint256 len = lockDetail[benefit].length;
		if( len == 0) return 0;
		uint256 releasable = 0;
		for(uint256 i = 0; i < len; i = i.add(1)){
			LockInfo memory tmp = lockDetail[benefit][i];
			if(tmp.releaseTime != 0 && now >= tmp.releaseTime){
				releasable = releasable.add(tmp.amount);
			}
		}	
		return releasable;	
	}
}

contract Token is LockableToken, BurnableToken {
    string public name; // name of Token
    string public symbol; // symbol of Token
    uint8 public decimals;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }
}

contract IOAEXBDR is Token {
    struct Trx {
        bool executed;
        address from;
        uint256 value;
        address[] signers;
    }

    mapping(address => bool) public isSigner;
    mapping(uint256 => Trx) public exchangeTrx;
    address public AbcInstance;  // address of AbcToken
    uint256 public requestSigners = 2;  // BDR => Abc need signers number
    uint256 public applyCounts = 0;  // Sequence of exchange request
    mapping(address => uint256) public exchangeLock;

    event SetSigner(address indexed signer,bool isSigner);  // emit when add/remove signer
    event ApplyExchangeToken(address indexed from,uint256 value,uint256 trxSeq);  // emit when exchange successful
    event ConfirmTrx(address indexed signer,uint256 indexed trxSeq);  // emit when signer confirmed exchange request
    event CancleConfirmTrx(address indexed signer,uint256 indexed trxSeq);  // emit when signer cancles confirmed exchange request
    event CancleExchangeRequest(address indexed signer,uint256 indexed trxSeq);  // emit when signer/requester cancles exchange request
    event TokenExchange(address indexed from,uint256 value,bool AbcExchangeBDR); // emit when Abc <=> Bdr,true:Abc => BDR,false:BDR => abc
    event Mint(address indexed target,uint256 value);

    modifier onlySigner() {
        require(isSigner[msg.sender]);
        _;
    }
    /**
     * @dev initialize token info
     * @param _name string The name of token
     * @param _symbol string The symbol of token
     * @param _decimals uint8 The decimals of token
     */
    constructor(string memory _name, string memory _symbol, uint8 _decimals) Token(_name,_symbol,_decimals) public {
    }

    /**
     * @dev rewrite transfer function，user can't transfer token to AbcToken's address directly
     */
    function transfer(address _to,uint256 _value) public returns (bool success) {
        require(_to != AbcInstance,"can't transfer to AbcToken address directly");
        return super.transfer(_to,_value);
    }

    /**
     * @dev rewrite transferFrom function，user can't transfer token to AbcToken's address directly
     */
    function transferFrom(address _from, address _to,uint256 _value) public returns (bool success) {
        require(_to != AbcInstance,"can't transfer to AbcToken address directly");
        return super.transferFrom(_from,_to,_value);
    }

    /**
     * @dev rewrite transferAndLock function，user can't transfer token to AbcToken's address directly
     */
    function transferAndLock(address _to, uint256 _value, uint256 _lockdays) public returns (bool success) {
        require(_to != AbcInstance,"can't transfer to AbcToken address directly");
        return super.transferAndLock(_to,_value,_lockdays);
    }   

    /**
     * @dev set AbcToken's address
     */
    function setAbcInstance(address _abc) public onlyOwner {
        require(_abc != address(0));
        AbcInstance = _abc;
    }

    /**
     * @dev add/remove signers
     * @param _signers address[] The array of signers to add/remove
     * @param _addSigner bool true:add signers,false:remove:signers
     */
    function setSigners(address[] memory _signers,bool _addSigner) public onlyOwner {
        for(uint256 i = 0;i< _signers.length;i++){
            require(_signers[i] != address(0));
            isSigner[_signers[i]] = _addSigner;
            emit SetSigner(_signers[i],_addSigner);
        }
    }

    /**
     * @dev set the number of exchange request in order to execute
     * @param _requestSigners uint256 The number of signers
     */
    function setrequestSigners(uint256 _requestSigners) public onlyOwner {
        require(_requestSigners != 0);
        requestSigners = _requestSigners;
    }

    /**
     * @dev check whether the signer confirmed this exchange request
     */
    function isConfirmer(uint256 _trxSeq,address _signer) public view returns (bool) {
        require(exchangeTrx[_trxSeq].from != address(0),"trxSeq not exist");
        for(uint256 i = 0;i < exchangeTrx[_trxSeq].signers.length;i++){
            if(exchangeTrx[_trxSeq].signers[i] == _signer){
                return true;
            }
        }
        return false;
    }

    /**
     * @dev get how many signers that confirmed this exchange request
     */
    function getConfirmersLengthOfTrx(uint256 _trxSeq) public view returns (uint256) {
        return exchangeTrx[_trxSeq].signers.length;
    }

    /**
     * @dev get signers's address that confirmed this exchange request
     * @param _trxSeq uint256 the Sequence of exchange request
     * @param _index uint256 the index of signers
     */
    function getConfirmerOfTrx(uint256 _trxSeq,uint256 _index) public view returns (address) {
        require(_index < getConfirmersLengthOfTrx(_trxSeq),"out of range");
        return exchangeTrx[_trxSeq].signers[_index];
    }

    /**
     * @dev apply BDR exchange Abc
     * @param _value uint256 amount of BDR to exchange
     * @return uint256 the sequence of exchange request
     */
    function applyExchangeToken(uint256 _value) public whenNotPaused returns (uint256) {
        uint256 trxSeq = applyCounts;
        require(exchangeTrx[trxSeq].from == address(0),"trxSeq already exist");
        require(balances[msg.sender] >= _value);
        exchangeTrx[trxSeq].executed = false;
        exchangeTrx[trxSeq].from = msg.sender;
        exchangeTrx[trxSeq].value = _value;
        applyCounts = applyCounts.add(1);
        balances[address(this)] = balances[address(this)].add(_value);
        balances[exchangeTrx[trxSeq].from] = balances[exchangeTrx[trxSeq].from].sub(_value);
        exchangeLock[exchangeTrx[trxSeq].from] = exchangeLock[exchangeTrx[trxSeq].from].add(_value);
        emit ApplyExchangeToken(exchangeTrx[trxSeq].from,exchangeTrx[trxSeq].value,trxSeq);
        emit Transfer(msg.sender,address(this),_value);
        return trxSeq;
    }

    /**
     * @dev signer confirms one exchange request
     * @param _trxSeq uint256 the Sequence of exchange request
     */
    function confirmExchangeTrx(uint256 _trxSeq) public onlySigner {
        require(exchangeTrx[_trxSeq].from != address(0),"_trxSeq not exist");
        require(exchangeTrx[_trxSeq].signers.length < requestSigners,"trx already has enough signers");
        require(exchangeTrx[_trxSeq].executed == false,"trx already executed");
        require(isConfirmer(_trxSeq, msg.sender) == false,"signer already confirmed");
        exchangeTrx[_trxSeq].signers.push(msg.sender);
        emit ConfirmTrx(msg.sender, _trxSeq);
    }

    /**
     * @dev signer cancel confirmed exchange request
     * @param _trxSeq uint256 the Sequence of exchange request
     */
    function cancelConfirm(uint256 _trxSeq) public onlySigner {
        require(exchangeTrx[_trxSeq].from != address(0),"_trxSeq not exist");
        require(isConfirmer(_trxSeq, msg.sender),"Signer didn't confirm");
        require(exchangeTrx[_trxSeq].executed == false,"trx already executed");
        uint256 len = exchangeTrx[_trxSeq].signers.length;
        for(uint256 i = 0;i < len;i++){
            if(exchangeTrx[_trxSeq].signers[i] == msg.sender){
                exchangeTrx[_trxSeq].signers[i] = exchangeTrx[_trxSeq].signers[len.sub(1)] ;
                exchangeTrx[_trxSeq].signers.length --;
                break;
            }
        }
        emit CancleConfirmTrx(msg.sender,_trxSeq);
    }

    /**
     * @dev signer cancel exchange request
     * @param _trxSeq uint256 the Sequence of exchange request
     */
    function cancleExchangeRequest(uint256 _trxSeq) public {
        require(exchangeTrx[_trxSeq].from != address(0),"_trxSeq not exist");
        require(exchangeTrx[_trxSeq].executed == false,"trx already executed");
        require(isSigner[msg.sender] || exchangeTrx[_trxSeq].from == msg.sender);
        balances[address(this)] = balances[address(this)].sub(exchangeTrx[_trxSeq].value);
        balances[exchangeTrx[_trxSeq].from] = balances[exchangeTrx[_trxSeq].from].add(exchangeTrx[_trxSeq].value);
        exchangeLock[exchangeTrx[_trxSeq].from] = exchangeLock[exchangeTrx[_trxSeq].from].sub(exchangeTrx[_trxSeq].value);
        delete exchangeTrx[_trxSeq];
        emit CancleExchangeRequest(msg.sender,_trxSeq);
        emit Transfer(address(this),exchangeTrx[_trxSeq].from,exchangeTrx[_trxSeq].value);
    }

    /**
     * @dev execute exchange request which confirmed by enough signers
     * @param _trxSeq uint256 the Sequence of exchange request
     */
    function executeExchangeTrx(uint256 _trxSeq) public whenNotPaused{
        address from = exchangeTrx[_trxSeq].from;
        uint256 value = exchangeTrx[_trxSeq].value;
        require(from != address(0),"trxSeq not exist");
        require(exchangeTrx[_trxSeq].executed == false,"trxSeq has executed");
        require(exchangeTrx[_trxSeq].signers.length >= requestSigners);
        require(from == msg.sender|| isSigner[msg.sender]);
        require(value <= balances[address(this)]);
        _burn(address(this), value);
        exchangeLock[from] = exchangeLock[from].sub(value);
        exchangeTrx[_trxSeq].executed = true;
        AbcInterface(AbcInstance).tokenFallback(from,value,bytes(""));
        emit TokenExchange(exchangeTrx[_trxSeq].from,exchangeTrx[_trxSeq].value,false);
    }

    /**
     * @dev exchange Abc token to BDR token,only AbcInstance can invoke this function
     */
    function tokenFallback(address _from, uint _value, bytes memory) public {
        require(msg.sender == AbcInstance);
        require(_from != address(0));
        require(_value > 0);
        uint256 exchangeAmount = _value.mul(10**uint256(decimals)).div(10**uint256(AbcInterface(AbcInstance).decimals()));
        _mint(_from, exchangeAmount);
        emit Transfer(address(0x00),_from,exchangeAmount);
        emit TokenExchange(_from,_value,true);
    }

    /**
     * @dev mint BDR token
     */
    function _mint(address target, uint256 value ) internal {
        balances[target] = balances[target].add(value);
        totalSupply = totalSupply.add(value);
        emit Mint(target,value);
    }
}