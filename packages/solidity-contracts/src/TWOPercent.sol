/**
 * Source Code first verified at https://etherscan.io on Thursday, May 2, 2019
 (UTC) */

pragma solidity >=0.4.21;


library sMath {
    function multiply(uint256 a, uint256 b) internal pure returns(uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }


    function division(uint256 a, uint256 b) internal pure returns(uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }


    function subtract(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }


    function plus(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


contract owned {
    address public owner;
    address public crowdOwner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
    
    function transferCrowdOwner(address newCrowdOwner) onlyOwner public {
        crowdOwner = newCrowdOwner;
    }
}

/**
 * @title ERC20
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20 {
    function totalSupply() public view returns(uint256);
    function balanceOf(address who) public view returns(uint256);
    function transfer(address to, uint256 value) public returns(bool);
    function allowance(address owner, address spender) public view returns(uint256);
    function transferFrom(address from, address to, uint256 value) public returns(bool);
    function approve(address spender, uint256 value) public returns(bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */


contract StandardToken is ERC20{
    using sMath
    for uint256;

    mapping(address => uint256) balances;
    mapping(address => uint256) balances_crowd;
    mapping(address => mapping(address => uint256)) internal allowed;
    uint256 totalSupply_;


    function totalSupply() public view returns(uint256) {
        return totalSupply_;
    }

    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != address(0x0));
        require(balances[_from] >= _value);
        require(balances[_to].plus(_value) > balances[_to]);
        uint previousBalances = balances[_from].plus(balances[_to]);
        balances[_from] = balances[_from].subtract(_value);
        balances[_to] = balances[_to].plus(_value);
        emit Transfer(_from, _to, _value);
        assert(balances[_from].plus(balances[_to]) == previousBalances);
    }

    function transfer(address _to, uint256 _value) public returns(bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOfDef(address _owner) public view returns(uint256 balance) {
        return balances[_owner];
    }
     
    function balanceOf(address _owner) public view returns(uint256 balance) {
        return balances[_owner].plus(balances_crowd[_owner]);
    }
    
    function balanceOfCrowd(address _owner) public view returns(uint256 balance) {
        return balances_crowd[_owner];
    }

    function allowance(address _owner, address _spender) public view returns(uint256) {
        return allowed[_owner][_spender];
    }


    function increaseApproval(address _spender, uint _addedValue) public returns(bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].plus(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns(bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.subtract(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}

/**
 * @title 2Percent
 */

contract TWOPercent is StandardToken, owned {
    uint public INITIAL_SUPPLY = 2500000000;
	string public name = 'TWOPercent';
	string public symbol = 'TPCT';
	uint public decimals = 18;
    

    bool public frozenAll = false;

    mapping(address => bool) public frozenAccount;

    event FrozenFunds(address target, bool frozen);
    event FrozenAll(bool stop);
    event Burn(address indexed from, uint256 value);
    event LockEvent(address from, address to, uint startLock, uint endLock, uint256 value);
    event Aborted();
    
    struct transForAddr {
        address fromAddr;
        address toAddr;
        uint8 sendFlag ; // 1 send, 0 receive
        uint256 amount;
        uint256 balances;
        uint256 balance_crowd;
        uint regdate;
    }
    
    struct lockForAddr {
        uint startLock;
        uint endLock;
    }
    
    mapping(address => transForAddr[]) transForAddrs;
    mapping(address => lockForAddr) lockForAddrs;
    
    
    function setLockForAddr(address _address, uint _startLock, uint _endLock) onlyOwner public {
        lockForAddrs[_address] = lockForAddr(_startLock, _endLock);
    }
    
    function getLockForAddr(address _address)  public view returns (uint, uint) {
        lockForAddr storage _lockForAddr = lockForAddrs[_address];
        return (_lockForAddr.startLock, _lockForAddr.endLock);
    }
    
    function getLockStartForAddr(address _address)  public view returns (uint) {
        lockForAddr storage _lockForAddr = lockForAddrs[_address];
        return _lockForAddr.startLock;
    }
    
    function getLockEndForAddr(address _address)  public view returns (uint) {
        lockForAddr storage _lockForAddr = lockForAddrs[_address];
        return _lockForAddr.endLock;
    }


    constructor() public {
        
        totalSupply_ = INITIAL_SUPPLY * 10 ** uint256(decimals);
        balances[msg.sender] = totalSupply_;
        
        emit Transfer(address(0x0), msg.sender, totalSupply_);
    }
    
    
    function transForAddrsCnt(address _address) public view returns (uint) {
        return transForAddrs[_address].length;
    }
    

    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != address(0x0)); // Prevent transfer to 0x0 address. Use burn() instead
        //require(balances[_from] >= _value); 
        require(balances[_from].plus(balances_crowd[_from]) >= _value); 
        require(balances[_to].plus(_value) >= balances[_to]); 
        require(!frozenAccount[_from]); 
        require(!frozenAccount[_to]); 
        require(!frozenAll); 

        if(balances[_from] >= _value) {
            balances[_from] = balances[_from].subtract(_value);    
        } else {
            if(getLockStartForAddr(_from) > 0) {
            
                uint kstNow = now + 32400;
                
                if(!(getLockStartForAddr(_from) < kstNow &&  kstNow < getLockEndForAddr(_from))) {
                    uint firstValue = _value.subtract(balances[_from]);
                    uint twiceValue = _value.subtract(firstValue);
                    
                    balances_crowd[_from] = balances_crowd[_from].subtract(firstValue);
                    balances[_from] = balances[_from].subtract(twiceValue);
                }else {
                    emit LockEvent(_from, _to, getLockStartForAddr(_from), getLockEndForAddr(_from), _value);
                    emit Aborted();
                    //emit Transfer(_from, _to, _value);
                    return;
                }
            }else {
                emit LockEvent(_from, _to, getLockStartForAddr(_from), getLockEndForAddr(_from), _value);
                emit Aborted();
                //emit Transfer(_from, _to, _value);
                return;
            }
        }
        
        if(msg.sender == crowdOwner)  balances_crowd[_to] = balances_crowd[_to].plus(_value);
        else balances[_to] = balances[_to].plus(_value);
        
        // addTransForAddrs(_from, _to, 1, _value, balances[_from], balances_crowd[_from]);
        // addTransForAddrs(_to, _from, 0, _value, balances[_to], balances_crowd[_to]);        
        
        emit Transfer(_from, _to, _value);
    }

    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balances[target] = balances[target].plus(mintedAmount);
        totalSupply_ = totalSupply_.plus(mintedAmount);
        emit Transfer(address(0), address(this), mintedAmount);
        emit Transfer(address(this), target, mintedAmount);
    }

    function burn(uint256 _value) public returns(bool success) {
        require(balances[msg.sender] >= _value); // Check if the sender has enough
        balances[msg.sender] = balances[msg.sender].subtract(_value); // Subtract from the sender
        totalSupply_ = totalSupply_.subtract(_value); // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }

    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

    function frozenAllChange(bool stop) onlyOwner public {
        frozenAll = stop;
        emit FrozenAll(frozenAll);
    }
        
    // function addTransForAddrs(address _fromAddr, address _toAddr, uint8 _status, uint256 _amount, uint256 _balances, uint256 _balances_crowd) internal {
    //     transForAddrs[_fromAddr].push(transForAddr(_fromAddr, _toAddr, _status, _amount, _balances, _balances_crowd, now));
    // }
    
    // function getTransForAddrs(address _address, uint256 _index) onlyOwner public view returns (address, address, uint8, uint256, uint256, uint256, uint) {
    //     if(_index > 0) require(transForAddrsCnt(_address) >= _index.subtract(1));
        
    //     transForAddr storage _transForAddr = transForAddrs[_address][_index];
    //     return (_transForAddr.fromAddr, _transForAddr.toAddr, _transForAddr.sendFlag, _transForAddr.amount, _transForAddr.balances, _transForAddr.balance_crowd, _transForAddr.regdate);
    // }  
    
    
    // function getTransForAddrsAll(address _address) onlyOwner public view returns (address[] memory, uint8[] memory, uint256[] memory, uint256[] memory, uint256[] memory, uint[] memory) {
    //     address[] memory _addressTwo = new address[](transForAddrs[_address].length);
    //     uint8[] memory _status = new uint8[](transForAddrs[_address].length);
    //     uint256[] memory _amount = new uint256[](transForAddrs[_address].length);
    //     uint256[] memory _balances = new uint256[](transForAddrs[_address].length);
    //     uint256[] memory _balances_crowd = new uint256[](transForAddrs[_address].length);
    //     uint[] memory _regdate = new uint[](transForAddrs[_address].length);
     
    //     for(uint i = 0; i < transForAddrs[_address].length; i++){
    //       // _addressOne[i] = transForAddrs[_address][i].fromAddr;
    //         _addressTwo[i] = transForAddrs[_address][i].toAddr;            
    //         _status[i] = transForAddrs[_address][i].sendFlag;
    //         _amount[i] = transForAddrs[_address][i].amount;
    //         _balances[i] = transForAddrs[_address][i].balances;
    //         _balances_crowd[i] = transForAddrs[_address][i].balance_crowd;
    //         _regdate[i] = transForAddrs[_address][i].regdate;
    //     }
        
    //     return ( _addressTwo, _status, _amount, _balances, _balances_crowd, _regdate);
    // }
    
    function approve(address _spender, uint256 _value) public returns(bool) {
        require(!frozenAccount[_spender]); 
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        require(!frozenAccount[_from]); 
        require(!frozenAccount[_to]); 

        balances[_from] = balances[_from].subtract(_value);
        balances[_to] = balances[_to].plus(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].subtract(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
}