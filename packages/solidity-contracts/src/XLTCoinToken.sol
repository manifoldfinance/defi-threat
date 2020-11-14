import "./StandardToken.sol";

contract XLTCoinToken is StandardToken { 

    string public name;
    uint8 public decimals;
    string public symbol;

    constructor(uint256 _initialAmount, string _tokenName, uint8 _decimalUnits, string _tokenSymbol)  public{
        totalSupply = _initialAmount * 10 ** uint256(_decimalUnits);
        balances[msg.sender] = totalSupply;
        name = _tokenName; 
        decimals = _decimalUnits; 
        symbol = _tokenSymbol;
    }
    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }
    
    function burn(uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value && _value > 0);
        balances[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value && _value > 0);
        require(allowed[_from][msg.sender] >= _value);
        balances[_from] -= _value; 
        allowed[_from][msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(_from, _value);
        return true;
    }

    function freeze(uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value && _value > 0);
        balances[msg.sender] = balances[msg.sender] - _value; 
        freezes[msg.sender] = freezes[msg.sender] + _value;
        emit Freeze(msg.sender, _value);
        return true;
    }
	
    function unfreeze(uint256 _value) public returns (bool success) {
        require(freezes[msg.sender] >= _value && _value > 0);
        freezes[msg.sender] = freezes[msg.sender] -  _value;
	balances[msg.sender] = balances[msg.sender] + _value;
        emit Unfreeze(msg.sender, _value);
        return true;
    }
}