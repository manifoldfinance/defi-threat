/**
 * Source Code first verified at https://etherscan.io on Wednesday, March 20, 2019
 (UTC) */

pragma solidity ^0.4.21;

//Decalre all functions to use in Token Smart Contract
contract EIP20Interface {
    
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public view returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    // solhint-disable-next-line no-simple-event-func-name
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


//Main Token Code Starts from here
contract uptrennd is EIP20Interface {
    
    
    //Code To Set onlyOwner
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
        modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    //Code to Transfer the Ownership
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        uint _value = balances[msg.sender];
        balances[msg.sender] -= _value;
        balances[newOwner] += _value;
        emit Transfer(msg.sender, newOwner, _value);
    }

    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public TokenPrice;

    string public name;                   
    uint256 public decimals;                
    string public symbol;                 

    //function to depoly the smart contract with functionality
    function uptrennd(
        uint256 _initialAmount,
        string _tokenName,
        uint256 _decimalUnits,
        string _tokenSymbol,
        uint256 _price
    ) public {
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        totalSupply = _initialAmount;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
        owner = msg.sender;
        TokenPrice = _price;
    }
    
    //Funtion to Set The Token Price
    function setPrice(uint256 _price) onlyOwner public returns(bool success){
        TokenPrice =  _price;
        return true;
    }

    //Transfer Function for the Tokens!
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value); 
        return true;
    }
    
    //User can purchase token using this method
    function purchase(address _to, uint256 _value) public payable returns (bool success) {
       
        uint amount = msg.value/TokenPrice;
        require(balances[owner] >= amount);
        require(_value == amount);
        balances[owner] -= amount;
        balances[_to] += amount;
        emit Transfer(owner, _to, amount); 
        return true;
    }

    //Admin can give rights to the user to transfer token on his behafe.
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value); 
        return true;
    }

    //To check the token balcance in his account.
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    //TO approve the user to Transfer the token on admin behafe.
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); 
        return true;
    }

    //To allow the user to get the permission to tranfer the token.
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    
    //Code To Burn the token starts from here.
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        totalSupply = totalSupply - value;
        balances[account] = balances[account] - value;
        emit Transfer(account, address(0), value);
    }
   
    //Admin functionality to burn number of tokens.
    function burn(uint256 value) onlyOwner public {
        _burn(msg.sender, value);
    }

    //User functionality to burn the token from his account.
    function burnFrom(address to, uint256 value) public returns (bool success) {
        require(balances[msg.sender] >= value);
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, address(0), value); //solhint-disable-line indent, no-unused-vars
        return true;
    }
}