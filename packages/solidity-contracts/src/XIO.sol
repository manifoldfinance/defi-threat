/**
 * Source Code first verified at https://etherscan.io on Thursday, March 21, 2019
 (UTC) */

pragma solidity ^0.4.25;

contract XIO {
    uint private k = 1000000000000000000;
    
    string public name = 'XIO';
    string public symbol = 'XIO';
    uint8 public decimals = 18;
    uint public totalSupply = 1000000000 * k;
    uint public createdAt = block.number;
    uint public lastMiningAt;
    uint public unconfirmedTxs;

    address private lastSender;
    address private lastOrigin;
    
    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => uint256) public successesOf;
    mapping (address => uint256) public failsOf;
    mapping (address => mapping (address => uint256)) public allowance;
    
    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    // This generates a public event on the blockchain that will notify clients
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
    
    event Mine(address indexed from, uint256 value, uint256 number, uint256 rollUnder);
    event Dice(address indexed from, uint256 bet, uint256 prize, uint256 number, uint256 rollUnder);
    
    uint private seed;
 
    modifier notContract() {
        lastSender = msg.sender;
        lastOrigin = tx.origin;
        require(lastSender == lastOrigin);
        _;
    }
    
    // uint256 to bytes32
    function toBytes(uint256 x) internal pure returns (bytes b) {
        b = new bytes(32);
        assembly {
            mstore(add(b, 32), x)
        }
    }
    
    // returns a pseudo-random number
    function random(uint lessThan) internal returns (uint) {
        seed += block.timestamp + uint(msg.sender);
        return uint(sha256(toBytes(uint(blockhash(block.number - 1)) + seed))) % lessThan;
    }
    
    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor() public {
        balanceOf[msg.sender] = totalSupply;
    }
    
    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
        
        unconfirmedTxs++;
    }
    
    /* Send coins */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }
    
    /* Transfer tokens from other address */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
    
    /* Set allowance for other address */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    /* Burn tokens */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }
    
    function issue(uint256 _value) internal {
        balanceOf[msg.sender] += _value;
        totalSupply += _value;
        emit Transfer(0, this, _value);
        emit Transfer(this, msg.sender, _value);
    }
    
    function getReward() public view returns (uint) {
        uint pow = (block.number - createdAt) / 864000;
        if (pow > 25) {
            return 0;
        }
        return 50 * k / 2 ** pow;
    }
    
    function canMine(address _user) public view returns (bool) {
        return balanceOf[_user] * 10000 / totalSupply > 0;
    }
    
    function dice(uint rollUnder, uint amount) public notContract {
        require(rollUnder >= 2 && rollUnder <= 97);
        require(balanceOf[msg.sender] >= amount);
        
        uint number = random(100);
        if (number < rollUnder) {
            uint prize = amount * 98 / rollUnder;
            issue(prize - amount);
            emit Dice(msg.sender, amount, prize, number, rollUnder);
        } else {
            burn(amount);
            emit Dice(msg.sender, amount, 0, number, rollUnder);
        }
    }
    
    function mine() public notContract {
        uint minedHashRel = random(65536);
        uint balanceRel = balanceOf[msg.sender] * 10000 / totalSupply;
        if (balanceRel > 0) {
            uint rollUnder = (block.number - lastMiningAt) * balanceRel;
            if (minedHashRel < rollUnder) {
                uint reward = getReward() + unconfirmedTxs * k;
                issue(reward);
                emit Mine(msg.sender, reward, minedHashRel, rollUnder);
                successesOf[msg.sender]++;
                
                lastMiningAt = block.number;
                unconfirmedTxs = 0;
            } else {
                emit Transfer(this, msg.sender, 0);
                emit Mine(msg.sender, 0, minedHashRel, rollUnder);
                failsOf[msg.sender]++;
            }
        } else {
            revert();
        }
    }
}