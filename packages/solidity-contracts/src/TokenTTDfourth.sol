/**
 * Source Code first verified at https://etherscan.io on Thursday, March 21, 2019
 (UTC) */

pragma solidity ^0.4.22;

contract TokenTTDfourth {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public cfoOfTokenTTDfourth;
    
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => bool) public frozenAccount;
    
    event Transfer (address indexed from, address indexed to, uint256 value);
    event Approval (address indexed owner, address indexed spender, uint256 value);
    event MintToken (address to, uint256 mintvalue);
    event MeltToken (address from, uint256 meltvalue);
    event FreezeEvent (address target, bool result);
    
    constructor (
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
        ) public {
            cfoOfTokenTTDfourth = msg.sender;
            totalSupply = initialSupply * 10 ** uint256(decimals);
            balanceOf[msg.sender] = totalSupply;
            name = tokenName;
            symbol = tokenSymbol;
        }
    
    modifier onlycfo {
        require (msg.sender == cfoOfTokenTTDfourth);
        _;
    }
    
    function _transfer (address _from, address _to, uint _value) internal {
        require (_to != address(0x0));
        require (balanceOf[_from] >= _value);
        require (balanceOf[_to] + _value >= balanceOf[_to]);
        require (!frozenAccount[_from]);
        require (!frozenAccount[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer (_from, _to, _value);
        assert (balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
    
    function transfer (address _to, uint256 _value) public returns (bool success) {
        _transfer (msg.sender, _to, _value);
        return true;
    }
    
    function transferFrom (address _from, address _to, uint256 _value) public returns (bool success) {
        require (_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _transfer (_from, _to, _value);
        return true;
    }
    
    function approve (address _spender, uint256 _value) public returns (bool success) {
        require (_spender != address(0x0));
        require (_value > 0);
        allowance[msg.sender][_spender] = _value;
        emit Approval (msg.sender, _spender, _value);
        return true;
    }
    
    function appointNewcfo (address newcfo) onlycfo public {
        require (newcfo != address(0x0));
        require (newcfo != cfoOfTokenTTDfourth);
        cfoOfTokenTTDfourth = newcfo;
    }
    
    function mintToken (address target, uint256 amount) onlycfo public {
        require (target != address(0x0));
        require (amount > 0);
        balanceOf[target] += amount;
        totalSupply += amount;
        emit MintToken (target, amount);
    }
    
    function meltToken (address target, uint256 amount) onlycfo public {
        require (target != address(0x0));
        require (amount <= balanceOf[target]);
        balanceOf[target] -= amount;
        totalSupply -= amount;
        emit MeltToken (target, amount);
    }
    
    function freezeAccount (address target, bool freeze) onlycfo public {
        require (target != address(0x0));
        frozenAccount[target] = freeze;
        emit FreezeEvent (target, freeze);
    }
}