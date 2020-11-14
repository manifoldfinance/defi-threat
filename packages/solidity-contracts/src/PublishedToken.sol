/**
 * Source Code first verified at https://etherscan.io on Monday, April 8, 2019
 (UTC) */

pragma solidity >=0.4.22 <0.6.0;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; }

contract SafeMath {
    
    uint256 constant MAX_UINT256 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    function safeAdd(uint256 x, uint256 y) internal returns (uint256 z) {
        require(x <= MAX_UINT256 - y);
        return x + y;
    }

    function safeSub(uint256 x, uint256 y) internal returns (uint256 z) {
        require(x >= y);
        return x - y;
    }

    function safeMul(uint256 x, uint256 y) internal returns (uint256 z) {
        if (y == 0) {
            return 0;
        }
        require(x <= (MAX_UINT256 / y));
        return x * y;
    }
}

contract Owned {
    address public originalOwner;
    address public owner;

    constructor() public {
        originalOwner = msg.sender;
        owner = originalOwner;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != owner);
        owner = newOwner;
    }
}

contract TokenERC20 is SafeMath, Owned{

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public unitsOneEthCanBuy;
    bool public salerunning;
    uint256 public bonusinpercent;
    address payable fundsWallet;
    uint256 public totalEthInWei;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => bool) public frozenAccount;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burn(address indexed from, uint256 value);
    event FrozenFunds(address target, bool frozen);
    event Mint(address indexed _to, uint256 _value);

    function() payable external{
        totalEthInWei = totalEthInWei + msg.value;
        fundsWallet.transfer(msg.value); // ETH from msg.sender -> fundsWallet
        if(salerunning){
            uint256 amount = msg.value * (unitsOneEthCanBuy + (unitsOneEthCanBuy * bonusinpercent / 100));
            require(balanceOf[fundsWallet] >= amount);
            balanceOf[fundsWallet] = balanceOf[fundsWallet] - amount;
            balanceOf[msg.sender] = balanceOf[msg.sender] + amount;
            emit Transfer(fundsWallet, msg.sender, amount);
        }
    }

    /**
     * Setter for bonus of tokens user get for 1 ETH sending to contract
     */
    function setBonus(uint256 bonus)onlyOwner public returns (bool success){
        bonusinpercent = bonus;
        return true;
    }


    /**
     * Setter for amount of tokens user get for 1 ETH sending to contract
     */
    function setUnitsOneEthCanBuy(uint256 amount)onlyOwner public returns (bool success){
        unitsOneEthCanBuy = amount;
        return true;
    }

    /**
     * Setter for unlocking the sales (Send ETH, Get Token)
     */
    function salesactive(bool active)onlyOwner public returns (bool success){
        salerunning = active;
        return true;
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        require(!frozenAccount[_from]);                                     // Check if sender is frozen
        require(!frozenAccount[_to]);                                       // Check if recipient is frozen
        require (_to != address(0x0));                                      // Prevent transfer to 0x0 address. Use burn() instead
        require (balanceOf[_from] >= _value);                               // Check if the sender has enough
        require (safeAdd(balanceOf[_to], _value) >= balanceOf[_to]);        // Check for overflows
        uint previousBalances = safeAdd(balanceOf[_from], balanceOf[_to]);  // Save this for an assertion in the future
        balanceOf[_from] = safeSub(balanceOf[_from], _value);               // Subtract from the sender
        balanceOf[_to] = safeAdd(balanceOf[_to], _value);                   // Add the same to the recipient
        emit Transfer(_from, _to, _value);
        assert(safeAdd(balanceOf[_from], balanceOf[_to]) == previousBalances);      // Asserts are used to use static analysis to find bugs in your code. They should never fail
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
        allowance[_from][msg.sender] = safeSub(allowance[_from][msg.sender], _value);
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
    function approve(address _spender, uint256 _value) public returns (bool success) {
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
    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }


    /// @notice Create `mintedAmount` tokens and send it to `target`
    /// @param target Address to receive the tokens
    /// @param mintedAmount the amount of tokens it will receive
    function mintToken(address target, uint256 mintedAmount) onlyOwner public returns (bool success){
        totalSupply = safeAdd(totalSupply, mintedAmount);
        balanceOf[target] = safeAdd(balanceOf[target], mintedAmount);
        emit Mint(target, mintedAmount);
        return true;
    }

    /**
     * Destroy tokens
     *
     * Remove `burnAmount` tokens from the system irreversibly
     *
     * @param burnAmount the amount of money to burn
     */
    function burn(uint256 burnAmount) public returns (bool success) {
        require(balanceOf[msg.sender] >= burnAmount);                           // Check if the sender has enough
        totalSupply = safeSub(totalSupply, burnAmount);                         // Subtract from total supply
        balanceOf[msg.sender] = safeSub(balanceOf[msg.sender], burnAmount);     // Subtract from the sender
        emit Burn(msg.sender, burnAmount);
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
        require(balanceOf[_from] >= _value);                                  // Check if the targeted balance is enough
        totalSupply = safeSub(totalSupply, _value);                           // Update supply
        require(_value <= allowance[_from][msg.sender]);                      // Check allowance
        balanceOf[_from] = safeSub(balanceOf[_from], _value);                           // Subtract from the targeted balance
        allowance[_from][msg.sender] = safeSub(allowance[_from][msg.sender], _value);   // Subtract from the sender's allowance
        emit Burn(_from, _value);
        return true;
    }

    /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
    /// @param target Address to be frozen
    /// @param freeze either to freeze it or not
    function freezeAccount(address target, bool freeze) onlyOwner public returns (bool success) {
        frozenAccount[target] = freeze;                         // Freeze target address
        emit FrozenFunds(target, freeze);
        return true;
    }
    
    /// destroy the contract and reclaim the leftover funds.
    function kill() onlyOwner public returns (bool killed){
        selfdestruct(msg.sender);
        return true;
    }
}

contract PublishedToken is TokenERC20{
    uint256 tokenamount;
    
    /**
    * @dev Intialises token and all the necesary variable
    */
    constructor() public{
        name = "ARBITRAGE";
        symbol = "ARB";
        decimals = 18;
        tokenamount = 8910934;
        unitsOneEthCanBuy = 2500;
        salerunning = true;
        bonusinpercent = 0;

        fundsWallet = msg.sender;
        totalSupply = tokenamount * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
    }
}