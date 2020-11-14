/**
 * Source Code first verified at https://etherscan.io on Monday, March 18, 2019
 (UTC) */

pragma solidity ^0.5.1;

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
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require((value == 0) || (token.allowance(msg.sender, spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        require(token.approve(spender, newAllowance));
    }
}
/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e694838b8589a6d4">[email protected]</a>?.com>, Eenae <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="40212c25382539002d293822393425336e292f">[email protected]</a>>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

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
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale,
 * allowing investors to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conform
 * the base architecture for crowdsales. They are *not* intended to be modified / overridden.
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override
 * the methods to add functionality. Consider using 'super' where appropriate to concatenate
 * behavior.
 */
contract Crowdsale is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    // The token being sold
    IERC20 private _token;
    // start ICO
    uint256 public _startStage1;
    uint256 public _startStage2;
    // Address where funds are collected
    address payable private _wallet;
    uint256 public _maxPay;
    uint256 public _minPay;

    // How many token units a buyer gets per wei.
    // The rate is the conversion between wei and the smallest and indivisible token unit.
    // So, if you are using a rate of 1 with a ERC20Detailed token with 3 decimals called TOK
    // 1 wei will give you 1 unit, or 0.001 TOK.
    // token - EUR
    uint256 private _rate; // 6 decimals

    // Amount of wei raised
    uint256 private _weiRaised;     
    //whitelist
    mapping (address => uint32) public whitelist;
    //for startStage2
    uint256   _totalNumberPayments = 0;
    uint256   _numberPaidPayments = 0;
    mapping(uint256 => address)  _paymentAddress;
    mapping(uint256 => uint256)  _paymentDay;
    mapping(uint256 => uint256)   _paymentValue;
    mapping(uint256 => uint256)   _totalAmountDay;
    mapping(uint256 => uint8)   _paymentFlag;
    uint256 public  _amountTokensPerDay;
    /**
     * Event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    constructor () public {
        _startStage1 = 1553083200;
        _startStage2 = 1554379201;
        _rate = 285;
        _wallet = 0x68A924EA85c96e74A05cf12465cB53702a560811;
        _token = IERC20(0xC0D766017141dd4866738C1e704Be6feDc97B904);
        _amountTokensPerDay = 2000000000000000000000000;
        _maxPay = 1 * 100 ether;
        _minPay = 1 * 200000000000000000;

        require(_rate > 0);
        require(_wallet != address(0));
        require(address(_token) != address(0));
        require(_startStage2 > _startStage1 + 15 * 1 days);
    }
    //  1 - allow, 0 - denied 
    function setWhiteList(address _address, uint32 _flag) public onlyOwner  {
      whitelist[_address] = _flag;
    }
    // 1 - allow
    function addAddressToWhiteList(address[] memory _addr) public onlyOwner {
      for(uint256 i = 0; i < _addr.length; i++) {
       whitelist[_addr[i]] = 1;
      }
    }
    // 0 - denied 
    function subAddressToWhiteList(address[] memory _addr) public onlyOwner {
      for(uint256 i = 0; i < _addr.length; i++) {
        whitelist[_addr[i]] = 0;
      }
    } 
    
    function setRate(uint256 rate) public onlyOwner  {
        _rate = rate;
    } 
    function setMaxPay(uint256 maxPay) public onlyOwner  {
        _maxPay = maxPay;
    }     
    function setMinPay(uint256 minPay) public onlyOwner  {
        _minPay = minPay;
    }      
    function _returnTokens(address wallet, uint256 value) public onlyOwner {
        _token.transfer(wallet, value);
    }  
    /**
     * @dev fallback function ***DO NOT OVERRIDE***
     * Note that other contracts will transfer fund with a base gas stipend
     * of 2300, which is not enough to call buyTokens. Consider calling
     * buyTokens directly when purchasing tokens from a contract.
     */
    function () external payable {
        buyTokens(msg.sender);
    }

    /**
     * @return the token being sold.
     */
    function token() public view returns (IERC20) {
        return _token;
    }

    /**
     * @return the address where funds are collected.
     */
    function wallet() public view returns (address payable) {
        return _wallet;
    }

    /**
     * @return the number of token units a buyer gets per wei.
     */
    function rate() public view returns (uint256) {
        return _rate;
    }

    /**
     * @return the amount of wei raised.
     */
    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }

    /**
     * @dev low level token purchase ***DO NOT OVERRIDE***
     * This function has a non-reentrancy guard, so it shouldn't be called by
     * another `nonReentrant` function.
     * @param beneficiary Recipient of the token purchase
     */
    function buyTokens(address beneficiary) public nonReentrant payable {
        uint256 weiAmount;
        uint256 tokens;
        
        weiAmount = msg.value;
        
        _preValidatePurchase(beneficiary, weiAmount);   
      
        if (now >= _startStage1 && now < _startStage2){
          require(whitelist[msg.sender] == 1);
          // calculate token amount to be created
          tokens = _getTokenAmount(weiAmount);

          // update state
          _weiRaised = _weiRaised.add(weiAmount);

          _processPurchase(beneficiary, tokens);
          emit TokensPurchased(msg.sender, beneficiary, weiAmount, tokens);

          _forwardFunds();
        }
        if (now >= _startStage2 && now < _startStage2 + 272 * 1 days){
          _totalNumberPayments = _totalNumberPayments + 1; 
          _paymentAddress[_totalNumberPayments] = msg.sender;
          _paymentValue[_totalNumberPayments] = msg.value;
          _paymentDay[_totalNumberPayments] = _getDayNumber();
          _totalAmountDay[_getDayNumber()] = _totalAmountDay[_getDayNumber()] + msg.value;
          _forwardFunds();
        }
        
    }
    function makePayment(uint256 numberPayments) public onlyOwner{
        address addressParticipant;
        uint256 paymentValue;
        uint256 dayNumber; 
        uint256 totalPaymentValue;
        uint256 tokensAmount;
        if (numberPayments > _totalNumberPayments.sub(_numberPaidPayments)){
          numberPayments = _totalNumberPayments.sub(_numberPaidPayments);  
        }
        uint256 startNumber = _numberPaidPayments.add(1);
        uint256 endNumber = _numberPaidPayments.add(numberPayments);
        for (uint256 i = startNumber; i <= endNumber; ++i) {
          if (_paymentFlag[i] != 1){
            dayNumber = _paymentDay[i];
            if (_getDayNumber() > dayNumber){   
              addressParticipant = _paymentAddress[i];
              paymentValue = _paymentValue[i];
              totalPaymentValue = _totalAmountDay[dayNumber];
              tokensAmount = _amountTokensPerDay.mul(paymentValue).div(totalPaymentValue);
              _token.safeTransfer(addressParticipant, tokensAmount);
              _paymentFlag[i] = 1;
              _numberPaidPayments = _numberPaidPayments + 1;
            }
          }
        }    
    }
    /**
     * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met.
     * Use `super` in contracts that inherit from Crowdsale to extend their validations.
     * Example from CappedCrowdsale.sol's _preValidatePurchase method:
     *     super._preValidatePurchase(beneficiary, weiAmount);
     *     require(weiRaised().add(weiAmount) <= cap);
     * @param beneficiary Address performing the token purchase
     * @param weiAmount Value in wei involved in the purchase
     */ 
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        require(beneficiary != address(0));
        require(weiAmount != 0);
        require(weiAmount >= _minPay); 
        require(weiAmount <= _maxPay);
        require(now >= _startStage1 && now <= _startStage2 + 272 * 1 days);
        
    }
    function _getAmountUnpaidPayments() public view returns (uint256){
        return _totalNumberPayments.sub(_numberPaidPayments);
    }    
    function _getDayNumber() internal view returns (uint256){
        return ((now.add(1 days)).sub(_startStage2)).div(1 days);
    }

    /**
     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends
     * its tokens.
     * @param beneficiary Address performing the token purchase
     * @param tokenAmount Number of tokens to be emitted
     */
    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {
        _token.safeTransfer(beneficiary, tokenAmount);
    }

    /**
     * @dev Executed when a purchase has been validated and is ready to be executed. Doesn't necessarily emit/send
     * tokens.
     * @param beneficiary Address receiving the tokens
     * @param tokenAmount Number of tokens to be purchased
     */
    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {
        _deliverTokens(beneficiary, tokenAmount);
    }

    /**
     * @dev Override to extend the way in which ether is converted to tokens.
     * @param weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        // tokensAmount = weiAmount.mul(_rateETHEUR).mul(10000).div(_rate);
       // return weiAmount.mul(_rate);
           uint256 bonus;
    if (now >= _startStage1 && now < _startStage1 + 5 * 1 days){
      bonus = 20;    
    }
    if (now >= _startStage1 + 5 * 1 days && now < _startStage1 + 10 * 1 days){
      bonus = 10;    
    }   
    if (now >= _startStage1 + 10 * 1 days && now < _startStage1 + 15 * 1 days){
      bonus = 0;    
    }       
      return weiAmount.mul(1000000).div(_rate) + (weiAmount.mul(1000000).mul(bonus).div(_rate)).div(100);
    }

    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds() internal {
        _wallet.transfer(msg.value);
    }
}