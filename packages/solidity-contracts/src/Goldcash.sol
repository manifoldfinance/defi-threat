pragma solidity ^0.4.25;


//import "./ownable.sol";
//import "./safemath.sol";
//import "./TokenERC20.sol";



import "./owned.sol";
import "./safemath.sol";
import "./erc20.sol";



contract Goldcash is owned, ERC20 {
    using SafeMath for uint256;
    //coin details
    string public name = "Goldcash";  
    string public symbol = "G";
    uint256 public totalSupply;
    address public contractAddress = this; 
    uint8 public decimals = 18;
    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    //ether exchg details
    uint256 public buyPriceEth = 1 finney;                                  // Buy price for Dentacoins
    uint256 public sellPriceEth = 1 finney;                                 // Sell price for Dentacoins
    uint256 public gasForGC = 5 finney;                                    // Eth from contract against GC to pay tx (10 times sellPriceEth)
    uint256 public GCForGas = 10;                                          // GC to contract against eth to pay tx
    uint256 public gasReserve = 1 ether;                                    // Eth amount that remains in the contract for gas and can't be sold
    uint256 public minBalanceForAccounts = 10 finney;                       // Minimal eth balance of sender and recipient


     /*
    constructor () public {
        //require(initialSupply > ownerSupply);
        totalSupply = uint256(1000).mul(10 ** uint256(decimals));  // Update total supply with the decimal amount
        //uint256 ownertotalSupply = ownerSupply.mul(10 ** uint256(decimals));
        //balanceOf[SlimeCoinAddress] = totalSupply.sub(ownertotalSupply);
        balanceOf[msg.sender] = totalSupply;
    }
    */
    constructor (uint256 initialSupply, uint256 ownerSupply) public owned(){
        require(initialSupply >= ownerSupply);
        totalSupply = initialSupply.mul(10 ** uint256(decimals));  // Update total supply with the decimal amount
        uint256 ownertotalSupply = ownerSupply.mul(10 ** uint256(decimals));
        balanceOf[contractAddress] = totalSupply.sub(ownertotalSupply);
        balanceOf[msg.sender] = ownertotalSupply;
    }
    event Withdraw(address indexed owner, uint256 withdrawal, uint256 time);
    function withdraw() public onlyOwner{
        address _owner = owner;
        _owner.transfer(address(this).balance);
        emit Withdraw(_owner, address(this).balance, now);
    }
    function set_sellPriceEth(uint256 _eth) public onlyOwner{
        require(_eth > 0);
        uint256 oldValue = sellPriceEth;
        sellPriceEth = _eth;
        emit chg_setting(owner, oldValue, sellPriceEth, "sellPriceEth", now);
    }
    function set_buyPriceEth(uint256 _eth) public onlyOwner{
        require(_eth > 0);
        uint256 oldValue = buyPriceEth;
        buyPriceEth = _eth;
        emit chg_setting(owner, oldValue, buyPriceEth, "buyPriceEth", now);
    }
    function set_GCForGas(uint256 _goldcash) public onlyOwner{
        require(_goldcash > 0);
        uint256 oldValue = GCForGas;
        GCForGas = _goldcash;
        emit chg_setting(owner, oldValue, GCForGas, "GCForGas", now);
    }
    event chg_setting(address indexed changer, uint256 oldValue, uint256 newValue, string indexed setting, uint256 time);
   

    /*
        For coin transaction implementing ERC20
    */
    function totalSupply() public view returns (uint256){
        return totalSupply;
    }
    function allowance(address _giver, address _spender) public view returns (uint256){
        allowance[_giver][_spender];
    }
    function balanceOf(address who) public view returns (uint256){
        return balanceOf[who];
    }
    //the transfer function core
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        // Check for overflows
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
    //user can transfer from an address that allowed
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    //user can transfer from their balance
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        emit noted_transfer(msg.sender, _to, _value, "", now);
        return true;
    }
    //transfer+note
    function notedTransfer (address _to, uint256 _value, string _note) public returns (bool success){
        _transfer(msg.sender, _to, _value);
        emit noted_transfer(msg.sender, _to, _value, _note, now);
        return true;
    }
    event noted_transfer(address indexed from, address indexed to, uint256 value, string note, uint256 time);
    //give allowance for transfer to a user (spender)
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    event ETH_transaction(address indexed source, address indexed aplicant, uint256 value, string indexed act, uint256 time);
    /*
        getting slimecoin by ether
    */
    function buyWithEther() public payable returns (uint amount) {
        require (buyPriceEth != 0 && msg.value >= buyPriceEth );             // Avoid dividing 0, sending small amounts and spam
        amount = msg.value.div(buyPriceEth);                                   // Calculate the amount of SlimeCoin
        uint256 totalAmount = amount.mul(10 ** uint256(decimals));
        require (balanceOf[this] > totalAmount);                                 // Check if it has enough to sell
        balanceOf[msg.sender] = balanceOf[msg.sender].add(totalAmount);       // Add the amount to buyer's balance
        balanceOf[this] = balanceOf[this].sub(totalAmount);                   // Subtract amount from SlimeCoin balance
        emit Transfer(this, msg.sender, totalAmount);                                 // Execute an event reflecting the change
        emit ETH_transaction(this, msg.sender, totalAmount, 'BuyFromEth', now);                                 // Execute an event reflecting the change
        return totalAmount;
    }
    /* User sells slimecoin and gets Ether */
    function sellToEther(uint256 amount) public returns (uint revenue) {
        require (sellPriceEth != 0 && amount >= GCForGas);                 // Avoid selling and spam
        require (balanceOf[msg.sender] >= amount);                           // Check if the sender has enough to sell
        revenue = amount.mul(sellPriceEth);                            // Revenue = eth that will be send to the user
        require ((address(this).balance).sub(revenue) >= gasReserve);             // Keep min amount of eth in contract to provide gas for transactions
        require (msg.sender.send(revenue)) ; 
        {
            balanceOf[this] = balanceOf[this].add(amount);               // Add the amount to Dentacoin balance
            balanceOf[msg.sender] = balanceOf[msg.sender].sub(amount);   // Subtract the amount from seller's balance
            emit Transfer(this, msg.sender, revenue);                            // Execute an event reflecting on the change
            emit ETH_transaction(this, msg.sender, revenue, 'SellToEth', now);                                 // Execute an event reflecting the change            
            return revenue;                                                 // End function and returns
        }
    }

}
