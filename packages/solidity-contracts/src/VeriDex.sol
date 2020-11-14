/**
 * Source Code first verified at https://etherscan.io on Monday, March 18, 2019
 (UTC) */

pragma solidity ^0.5.0;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
 
interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}








/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
 
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
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




/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
 
contract Ownable {
    address internal _owner;

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
        require(isOwner());
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
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
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
        require(newOwner != address(0),"You can't transfer the ownership to this account");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Remote is Ownable, IERC20 {
    using SafeMath for uint;

    IERC20 internal _remoteToken;
    address internal _remoteContractAddress;

    uint _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }

    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    //
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    /**
    @dev approveSpenderOnDex
    This is only needed if you put the funds in the Dex contract address, and then need to withdraw them
    Avoid this, by not putting funds in there that you need to get back.
    @param spender The address that will be used to withdraw from the Dex.
    @param value The amount of tokens to approve.
    @return success
     */
    function approveSpenderOnDex (address spender, uint256 value) 
        external onlyOwner returns (bool success) {
        // NOTE Approve the spender on the Dex address
        _remoteToken.approve(spender, value);     
        success = true;
    }

   /** 
    @dev remoteTransferFrom This allows the admin to withdraw tokens from the contract, using an 
    allowance that has been previously set. 
    @param from address to take the tokens from (allowance)
    @param to the recipient to give the tokens to
    @param value the amount in tokens to send
    @return bool
    */
    function remoteTransferFrom (address from, address to, uint256 value) external onlyOwner returns (bool) {
        return _remoteTransferFrom(from, to, value);
    }

    /**
    @dev setRemoteContractAddress
    @param remoteContractAddress The remote contract's address
    @return success
     */
    function setRemoteContractAddress (address remoteContractAddress)
        external onlyOwner returns (bool success) {
        _remoteContractAddress = remoteContractAddress;        
        _remoteToken = IERC20(_remoteContractAddress);
        success = true;
    }

    function remoteBalanceOf(address owner) external view returns (uint256) {
        return _remoteToken.balanceOf(owner);
    }

    function remoteTotalSupply() external view returns (uint256) {
        return _remoteToken.totalSupply();
    }

    /** */
    function remoteAllowance (address owner, address spender) external view returns (uint256) {
        return _remoteToken.allowance(owner, spender);
    }

    /**
    @dev remoteBalanceOfDex Return tokens from the balance of the Dex contract.
    @return balance
     */
    function remoteBalanceOfDex () external view onlyOwner 
        returns(uint256 balance) {
        balance = _remoteToken.balanceOf(address(this));
    }

    /**
    @dev remoteAllowanceOnMyAddress Check contracts allowance on the users address.
    @return allowance
     */
    function remoteAllowanceOnMyAddress () public view
        returns(uint256 myRemoteAllowance) {
        myRemoteAllowance = _remoteToken.allowance(msg.sender, address(this));
    } 

    /** 
    @dev _remoteTransferFrom This allows contract to withdraw tokens from an address, using an 
    allowance that has been previously set. 
    @param from address to take the tokens from (allowance)
    @param to the recipient to give the tokens to
    @param value the amount in tokens to send
    @return bool
    */
    function _remoteTransferFrom (address from, address to, uint256 value) internal returns (bool) {
        return _remoteToken.transferFrom(from, to, value);
    }

}

contract Dex is Remote {

    event TokensPurchased(address owner, uint256 amountOfTokens, uint256 amountOfWei);
    event TokensSold(address owner, uint256 amountOfTokens, uint256 amountOfWei);
    event TokenPricesSet(uint256 sellPrice, uint256 buyPrice);
    
    address internal _dexAddress;

    uint256 public sellPrice = 200000000000;
    uint256 public buyPrice = 650000000000;
    /// @notice Allow users to buy tokens for `newBuyPrice` eth and sell tokens for `newSellPrice` eth
    /// @param newSellPrice Price the users can sell to the contract
    /// @param newBuyPrice Price users can buy from the contract
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) public onlyOwner returns (bool success) {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;

        emit TokenPricesSet(sellPrice, buyPrice);
        success = true;
    }

    function topUpEther() external payable {
        // allow payable function to top up the contract
        // without buying tokens.
    }
    
    function _purchaseToken (address sender, uint256 amountOfWei) internal returns (bool success) {
        
        uint256 amountOfTokens = buyTokenExchangeAmount(amountOfWei);
        
        uint256 dexTokenBalance = _remoteToken.balanceOf(_dexAddress);
        require(dexTokenBalance >= amountOfTokens, "The VeriDex does not have enough tokens for this purchase.");

        _remoteToken.transfer(sender, amountOfTokens);

        emit TokensPurchased(sender, amountOfTokens, amountOfWei);
        success = true;
    }

    /** 
    @dev dexRequestTokensFromUser This allows the contract to transferFrom the user to 
    the contract using allowance that has been previously set. 
    // User must have an allowance already. If the user sends tokens to the address, 
    // Then the admin must transfer manually.
    @return string Message
    */
    function dexRequestTokensFromUser () external returns (bool success) {

        // calculate remote allowance given to the contract on the senders address
        // completed via the wallet
        uint256 amountAllowed = _remoteToken.allowance(msg.sender, _dexAddress);

        require(amountAllowed > 0, "No allowance has been set.");        
        
        uint256 amountBalance = _remoteToken.balanceOf(msg.sender);

        require(amountBalance >= amountAllowed, "Your balance must be equal or more than your allowance");
        
        uint256 amountOfWei = sellTokenExchangeAmount(amountAllowed);

        uint256 dexWeiBalance = _dexAddress.balance;

        uint256 dexTokenBalance = _remoteToken.balanceOf(_dexAddress);

        require(dexWeiBalance >= amountOfWei, "Dex balance must be equal or more than your allowance");

        _remoteTransferFrom(msg.sender, _dexAddress, amountAllowed);

        _remoteToken.approve(_dexAddress, dexTokenBalance.add(amountAllowed));  
 
        // Send Ether back to user
        msg.sender.transfer(amountOfWei);

        emit TokensSold(msg.sender, amountAllowed, amountOfWei);
        success = true;
    }
 
    /**
    @dev etherBalance: Returns value of the ether in contract.
    @return tokensOut
     */
    function etherBalance() public view returns (uint256 etherValue) {
        etherValue = _dexAddress.balance;
    }

    /**
    @dev etherBalance: Returns value of the ether in contract.
    @return tokensOut
     */
    function withdrawBalance() public onlyOwner returns (bool success) {
        msg.sender.transfer(_dexAddress.balance);
        success = true;
    }

    /**
    @dev buyTokenExchangeAmount: Returns value of the reward. Does not allocate reward.
    @param numberOfWei The number of ether in wei
    @return tokensOut
     */
    function buyTokenExchangeAmount(uint256 numberOfWei) public view returns (uint256 tokensOut) {
        tokensOut = numberOfWei.mul(10**18).div(buyPrice);
    }

    /**
    @dev sellTokenExchangeAmount: Returns value of the reward. Does not allocate reward.
    @param numberOfTokens The number of tokens
    @return weiOut
     */
    function sellTokenExchangeAmount(uint256 numberOfTokens) public view returns (uint256 weiOut) {
        weiOut = numberOfTokens.mul(sellPrice).div(10**18);
    }
 
}

/**
 * @title VeriDex
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 */

contract VeriDex is Dex {
    
    // User should not send tokens directly to the address

    string public symbol;
    string public  name;
    uint8 public decimals;
    /**
     * @dev Constructior to set up treasury and remote address.
     */
    constructor ( address remoteContractAddress)
        public  {
        symbol = "VRDX";
        name = "VeriDex";
        decimals = 18;
        _totalSupply = 20000000000 * 10**uint(decimals);
        _remoteContractAddress = remoteContractAddress;
        _remoteToken = IERC20(_remoteContractAddress);
        _dexAddress = address(this);
        balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
    }

    function() external payable {
        // If Ether is sent to this address, send tokens.
        require(_purchaseToken(msg.sender, msg.value), "Validation on purchase failed.");
    }
 
    /**
     * @dev adminDoDestructContract
     */ 
    function adminDoDestructContract() external onlyOwner { 
        selfdestruct(msg.sender);
    }

    /**
    * @dev dexDetails
    * @return address dexAddress
    * @return address remoteContractAddress
     */ 
    function dexDetails() external view returns (
        address dexAddress,  
        address remoteContractAddress) {
        dexAddress = _dexAddress;
        remoteContractAddress = _remoteContractAddress;
    }

}