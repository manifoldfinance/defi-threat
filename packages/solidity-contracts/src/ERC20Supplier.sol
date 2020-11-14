/**
 * Source Code first verified at https://etherscan.io on Wednesday, April 3, 2019
 (UTC) */

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

pragma solidity ^0.4.24;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.4.24;



/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: contracts/Ownable.sol

pragma solidity ^0.4.24;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner, "msg.sender not owner");
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0), "_newOwner == 0");
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: contracts/Pausable.sol

pragma solidity ^0.4.24;



/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused, "The contract is paused");
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused, "The contract is not paused");
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

// File: contracts/Destructible.sol

pragma solidity ^0.4.24;



/**
 * @title Destructible
 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.
 */
contract Destructible is Ownable {
  /**
   * @dev Transfers the current balance to the owner and terminates the contract.
   */
  function destroy() public onlyOwner {
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) public onlyOwner {
    selfdestruct(_recipient);
  }
}

// File: contracts/ERC20Supplier.sol

pragma solidity ^0.4.24;





interface TradingWallet {
  function depositERC20Token (address _token, uint256 _amount)
    external returns(bool);
}

interface TradingWalletMapping {
  function retrieveWallet(address userAccount)
    external returns(address walletAddress);
}

/**
 * @title ERC20Supplier.
 * @author Eidoo SAGL.
 * @dev Distribute a fixed amount of ERC20 based on a rate from a ERC20 reserve to a _receiver for ETH.
 * Received ETH are redirected to a wallet.
 */
contract ERC20Supplier is
  Pausable,
  Destructible
{
  using SafeMath for uint;

  ERC20 public token;
  TradingWalletMapping public tradingWalletMapping;

  address public wallet;
  address public reserve;

  uint public rate;
  uint public rateDecimals;
  uint public numberOfZeroesFromLastDigit;

  event LogWithdrawAirdrop(
    address indexed _from,
    address indexed _token,
    uint amount
  );
  event LogReleaseTokensTo(
    address indexed _from,
    address indexed _to,
    uint _amount
  );
  event LogSetWallet(address indexed _wallet);
  event LogSetReserve(address indexed _reserve);
  event LogSetToken(address indexed _token);
  event LogSetRate(uint _rate);
  event LogSetRateDecimals(uint _rateDecimals);
  event LogSetNumberOfZeroesFromLastDigit(
    uint _numberOfZeroesFromLastDigit
  );

  event LogSetTradingWalletMapping(address _tradingWalletMapping);
  event LogBuyForTradingWallet(
    address indexed _tradingWallet,
    address indexed _token,
    uint _amount
  );

  /**
   * @dev Contract constructor.
   * @param _wallet Where the received ETH are transfered.
   * @param _reserve From where the ERC20 token are sent to the purchaser.
   * @param _token Deployed ERC20 token address.
   * @param _rate Purchase rate, how many ERC20 for the given ETH.
   * @param _tradingWalletMappingAddress Trading wallet adress.
   * @param _rateDecimals Define the decimals precision for the given ERC20.
   * @param _numberOfZeroesFromLastDigit Define the number of last characters to transform in zero.
   */
  constructor(
    address _wallet,
    address _reserve,
    address _token,
    uint _rate,
    address _tradingWalletMappingAddress,
    uint _rateDecimals,
    uint _numberOfZeroesFromLastDigit
  )
    public
  {
    require(_wallet != address(0), "_wallet == address(0)");
    require(_reserve != address(0), "_reserve == address(0)");
    require(_token != address(0), "_token == address(0)");
    require(
      _tradingWalletMappingAddress != 0,
      "_tradingWalletMappingAddress == 0"
    );
    wallet = _wallet;
    reserve = _reserve;
    token = ERC20(_token);
    rate = _rate;
    tradingWalletMapping = TradingWalletMapping(_tradingWalletMappingAddress);
    rateDecimals = _rateDecimals;
    numberOfZeroesFromLastDigit = _numberOfZeroesFromLastDigit;
  }

  function() public payable {
    releaseTokensTo(msg.sender);
  }

  /**
   * @dev Set wallet.
   * @param _wallet Where the ETH are redirected.
   */
  function setWallet(address _wallet)
    public
    onlyOwner
    returns (bool)
  {
    require(_wallet != address(0), "_wallet == 0");
    require(_wallet != wallet, "_wallet == wallet");
    wallet = _wallet;
    emit LogSetWallet(wallet);
    return true;
  }

  /**
   * @dev Set ERC20 reserve.
   * @param _reserve Where ERC20 are stored.
   */
  function setReserve(address _reserve)
    public
    onlyOwner
    returns (bool)
  {
    require(_reserve != address(0), "_reserve == 0");
    require(_reserve != reserve, "_reserve == reserve");
    reserve = _reserve;
    emit LogSetReserve(reserve);
    return true;
  }

  /**
   * @dev Set ERC20 token.
   * @param _token ERC20 token address.
   */
  function setToken(address _token)
    public
    onlyOwner
    returns (bool)
  {
    require(_token != address(0), "_token == 0");
    require(_token != address(token), "_token == token");
    token = ERC20(_token);
    emit LogSetToken(token);
    return true;
  }

  /**
   * @dev Set rate.
   * @param _rate Multiplier, how many ERC20 for the given ETH.
   */
  function setRate(uint _rate)
    public
    onlyOwner
    returns (bool)
  {
    require(_rate != rate, "_rate == rate");
    require(_rate != 0, "_rate == 0");
    rate = _rate;
    emit LogSetRate(rate);
    return true;
  }

   /**
   * @dev Set rate precision.
   * @param _rateDecimals The precision to represent the quantity of ERC20.
   */
  function setRateDecimals(uint _rateDecimals)
    public
    onlyOwner
    returns (bool)
  {
    rateDecimals = _rateDecimals;
    emit LogSetRateDecimals(rateDecimals);
    return true;
  }

  /**
   * @dev Set truncate from position.
   * @param _numberOfZeroesFromLastDigit The position target (eg. 1254321000000000000 => 1254000000000000000 it's position tokenDecimal - 3).
   */
  function setNumberOfZeroesFromLastDigit(uint _numberOfZeroesFromLastDigit)
    public
    onlyOwner
    returns (bool)
  {
    numberOfZeroesFromLastDigit = _numberOfZeroesFromLastDigit;
    emit LogSetNumberOfZeroesFromLastDigit(numberOfZeroesFromLastDigit);
    return true;
  }

  /**
   * @dev Eventually withdraw airdropped token.
   * @param _token ERC20 address to be withdrawed.
   */
  function withdrawAirdrop(ERC20 _token)
    public
    onlyOwner
    returns(bool)
  {
    require(address(_token) != 0, "_token address == 0");
    require(
      _token.balanceOf(this) > 0,
      "dropped token balance == 0"
    );
    uint256 airdroppedTokenAmount = _token.balanceOf(this);
    _token.transfer(msg.sender, airdroppedTokenAmount);
    emit LogWithdrawAirdrop(msg.sender, _token, airdroppedTokenAmount);
    return true;
  }

  /**
   * @dev Set TradingWalletMapping contract instance address.
   * @param _tradingWalletMappingAddress It's actually the Eidoo Exchange SC address.
   */
  function setTradingWalletMappingAddress(
    address _tradingWalletMappingAddress
  )
    public
    onlyOwner
    returns(bool)
  {
    require(
      _tradingWalletMappingAddress != address(0),
      "_tradingWalletMappingAddress == 0");
    require(
      _tradingWalletMappingAddress != address(tradingWalletMapping),
      "_tradingWalletMappingAddress == tradingWalletMapping"
    );
    tradingWalletMapping = TradingWalletMapping(_tradingWalletMappingAddress);
    emit LogSetTradingWalletMapping(tradingWalletMapping);
    return true;
  }

  /**
   * @dev Function to deposit buyed tokens directly to an Eidoo trading wallet SC.
   */
  function buyForTradingWallet()
    public
    payable
    whenNotPaused
    returns(bool)
  {
    uint amount = getAmount(msg.value);
    address _tradingWallet = tradingWalletMapping.retrieveWallet(msg.sender);
    require(
      _tradingWallet != address(0),
      "no tradingWallet associated"
    );
    require(
      token.transferFrom(reserve, address(this), amount),
      "transferFrom reserve to ERC20Supplier failed"
    );
    if (token.allowance(address(this), _tradingWallet) != 0){
      require(
        token.approve(_tradingWallet, 0),
        "approve tradingWallet to zero failed"
      );
    }
    require(
      token.approve(_tradingWallet, amount),
      "approve tradingWallet failed"
    );
    emit LogBuyForTradingWallet(_tradingWallet, token, amount);
    wallet.transfer(msg.value);
    return TradingWallet(_tradingWallet).depositERC20Token(token, amount);
  }

  /**
   * @dev Function to truncate.
   * @param _amount The amount of ERC20 to truncate.
   * @param _numberOfZeroesFromLastDigit The position target (eg. 1254321000000000000 => 1254000000000000000 it's position tokenDecimal - 3).
   */
  function truncate(
    uint _amount,
    uint _numberOfZeroesFromLastDigit
  )
    public
    pure
    returns (uint)
  {
    return (_amount
      .div(10 ** _numberOfZeroesFromLastDigit))
      .mul(10 ** _numberOfZeroesFromLastDigit
    );
  }

  /**
   * @dev Function to calculate the number of tokens to receive.
   * @param _value The number of WEI to convert in ERC20.
   */
  function getAmount(uint _value)
    public
    view
    returns(uint)
  {
    uint amount = (_value.mul(rate).div(10 ** rateDecimals));
    uint result = truncate(amount, numberOfZeroesFromLastDigit);
    return result;
  }

  /**
   * @dev Release purchased ERC20 to the buyer.
   * @param _receiver Where the ERC20 are transfered.
   */
  function releaseTokensTo(address _receiver)
    internal
    whenNotPaused
    returns (bool)
  {
    uint amount = getAmount(msg.value);
    wallet.transfer(msg.value);
    require(
      token.transferFrom(reserve, _receiver, amount),
      "transferFrom reserve to _receiver failed"
    );
    return true;
  }
}