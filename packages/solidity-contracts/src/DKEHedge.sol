/**
 * Source Code first verified at https://etherscan.io on Wednesday, May 8, 2019
 (UTC) */

pragma solidity ^0.4.17;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}


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
    require(msg.sender == owner);
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
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    require(token.approve(spender, value));
  }
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/**
 * @title DKE hedge contract
 */
contract DKEHedge is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for ERC20Basic;

  event Released(uint256 amount);
  event Revoked();

  // beneficiary of tokens after they are released
  address public beneficiary;
  // start timestamp
  uint256 public start;
  // mt (cd or qt)
  uint256 public mt;
  // released list
  uint256[] public released = new uint256[](39);

  /**
   * @dev DKE linear cycle release
   * @param _beneficiary address of the beneficiary to whom vested DKE are transferred
   * @param _mt MT，minimum value of 1
   */
  constructor(
    address _beneficiary,
    uint256 _mt
  )
    public
  {
    require(_beneficiary != address(0));
    // require(_mt >= 100000000000);
    require(_mt >= 100000000);

    beneficiary = _beneficiary;
    mt = _mt;
    start = block.timestamp;
  }

  /**
   * @notice Release record every day
   */
  function release(uint16 price) public onlyOwner {
    uint256 idx = getCycleIndex();
    // 39 days (39 * 24 * 3600) 3369600
    require(idx >= 1 && idx <= 39);

    // dke = mt / 39 * 0.13 / price
    uint256 dke = mt.mul(1300).div(39).div(price);
    released[idx.sub(1)] = dke;

    emit Released(dke);
  }

  /**
   * @notice release and revoke
   * @param token DKEToken address
   */
  function revoke(uint16 price, ERC20Basic token) public onlyOwner {
    uint256 income = getIncome(price);
    uint256 balance = token.balanceOf(this);
    if (balance <= income) {
      token.safeTransfer(beneficiary, balance);
    } else {
      token.safeTransfer(beneficiary, income);
      token.safeTransfer(owner, balance.sub(income));
    }

    emit Revoked();
  }

  /**
   * @dev get cycle index
   */
  function getCycleIndex() public view returns (uint256) {
    // 1 days （24 * 3600） 86400
    return block.timestamp.sub(start).div(1800);
  }

  /**
   * @dev get released list in 39 days
   */
  function getReleased() public view returns (uint256[]) {
    return released;
  }

  /**
   * @dev get income for DKE
   */
  function getIncome(uint16 price) public view returns (uint256) {
    uint256 idx = getCycleIndex();
    require(idx >= 39);

    uint256 origin = mt.mul(13).div(100);

    uint256 total = 0;

    for(uint8 i = 0; i < released.length; i++) {
      uint256 item = released[i];
      total = total.add(item);
    }

    uint256 current = total.mul(price).div(10000);
    if (current <= origin) {
      current = origin;
    } else {
      current = current.add(current.sub(origin).mul(5).div(100));
    }

    return current.mul(10000).div(price);
  }
}