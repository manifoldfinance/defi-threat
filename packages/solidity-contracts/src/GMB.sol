/**
 * Source Code first verified at https://etherscan.io on Thursday, April 25, 2019
 (UTC) */

pragma solidity ^0.4.20;


contract Variable
{
  string public name;
  string public symbol;
  uint256 public decimals;
  uint256 public totalSupply;
  address public owner;
  address public watchdog;

  uint256 internal _decimals;
  uint256 internal startingTime;
  uint256 internal closingTime;
  bool internal transferLock;
  bool internal depositLock;
  mapping (address => bool) public allowedAddress;
  mapping (address => bool) public blockedAddress;
  mapping (address => uint256) public tempLockedAddress;

  mapping (address => uint256) public balanceOf;

  constructor() public
  {
    name = "GMB";
    symbol = "GMB";
    decimals = 18;
    _decimals = 10 ** uint256(decimals);
    totalSupply = _decimals * 5000000000;
    startingTime = 0;// 18.01.01 00:00:00 1514732400;
    closingTime = 0;// 18.12.31 23.59.59 1546268399;
    transferLock = true;
    depositLock = true;
    owner =  msg.sender;
    balanceOf[owner] = totalSupply;
    allowedAddress[owner] = true;
    watchdog = 0xC124570F91c00105bF8ccD56c03405997918fbd8;
  }
}

contract Modifiers is Variable
{
  address public newWatchdog;
  address public newOwner;

  modifier isOwner
  {
    assert(owner == msg.sender);
    _;
  }

  modifier isValidAddress
  {
    assert(0x0 != msg.sender);
    _;
  }

  modifier isWatchdog
  {
    assert(watchdog == msg.sender);
    _;
  }

  function transferOwnership(address _newOwner) public isWatchdog
  {
      newOwner = _newOwner;
  }

  function transferOwnershipWatchdog(address _newWatchdog) public isOwner
  {
      newWatchdog = _newWatchdog;
  }

  function acceptOwnership() public isOwner
  {
      require(newOwner != 0x0);
      owner = newOwner;
      newOwner = address(0);
  }

  function acceptOwnershipWatchdog() public isWatchdog
  {
      require(newWatchdog != 0x0);
      watchdog = newWatchdog;
      newWatchdog = address(0);
  }
}

contract Event
{
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Deposit(address indexed sender, uint256 amount , string status);
  event TokenBurn(address indexed from, uint256 value);
  event TokenAdd(address indexed from, uint256 value);
  event Set_TimeStamp(uint256 ICO_startingTime, uint256 ICO_closingTime);
  event BlockedAddress(address blockedAddress);
  event TempLockedAddress(address tempLockAddress, uint256 unlockTime);
}

contract manageAddress is Variable, Modifiers, Event
{
  function add_allowedAddress(address _address) public isOwner
  {
    allowedAddress[_address] = true;
  }

  function add_blockedAddress(address _address) public isOwner
  {
    require(_address != owner);
    blockedAddress[_address] = true;
    emit BlockedAddress(_address);
  }

  function delete_allowedAddress(address _address) public isOwner
  {
    require(_address != owner);
    allowedAddress[_address] = false;
  }

  function delete_blockedAddress(address _address) public isOwner
  {
    blockedAddress[_address] = false;
  }
}

contract Admin is Variable, Modifiers, Event
{
  function admin_transferFrom(address _from, uint256 _value) public isOwner returns(bool success)
  {
    require(balanceOf[_from] >= _value);
    require(balanceOf[owner] + (_value ) >= balanceOf[owner]);
    balanceOf[_from] -= _value;
    balanceOf[owner] += _value;
    emit Transfer(_from, owner, _value);
    return true;
  }
  function admin_tokenBurn(uint256 _value) public isOwner returns(bool success)
  {
    require(balanceOf[msg.sender] >= _value);
    balanceOf[msg.sender] -= _value;
    totalSupply -= _value;
    emit TokenBurn(msg.sender, _value);
    return true;
  }
  function admin_tokenAdd(uint256 _value) public isOwner returns(bool success)
  {
    balanceOf[msg.sender] += _value;
    totalSupply += _value;
    emit TokenAdd(msg.sender, _value);
    return true;
  }
  function admin_renewLockedAddress(address _address, uint256 _unlockTime) public isOwner returns(bool success)
  {
    tempLockedAddress[_address] = _unlockTime;
    emit TempLockedAddress(_address, _unlockTime);
    return true;
  }
}

contract Get is Variable, Modifiers
{
  function get_tokenTime() public view returns(uint256 start, uint256 stop)
  {
    return (startingTime, closingTime);
  }
  function get_transferLock() public view returns(bool)
  {
    return transferLock;
  }
  function get_depositLock() public view returns(bool)
  {
    return depositLock;
  }
}

contract Set is Variable, Modifiers, Event
{
  function setTimeStamp(uint256 _startingTime,uint256 _closingTime) public isOwner returns(bool success)
  {
    startingTime = _startingTime;
    closingTime = _closingTime;

    emit Set_TimeStamp(_startingTime, _closingTime);
    return true;
  }
  function setTransferLock(bool _transferLock) public isOwner returns(bool success)
  {
    transferLock = _transferLock;
    return true;
  }
  function setDepositLock(bool _depositLock) public isOwner returns(bool success)
  {
    depositLock = _depositLock;
    return true;
  }
  function setTimeStampStatus(uint256 _startingTime, uint256 _closingTime) public isOwner returns(bool success)
  {
    startingTime = _startingTime;
    closingTime = _closingTime;
    emit Set_TimeStamp(startingTime,closingTime);
    return true;
  }
}

contract GMB is Variable, Event, Get, Set, Admin, manageAddress
{
  using safeMath for uint256;

  function() payable public
  {
    revert();
  }
  function transfer(address _to, uint256 _value) public isValidAddress
  {
    require(allowedAddress[msg.sender] || transferLock == false);
    require(tempLockedAddress[msg.sender] < block.timestamp);
    require(!blockedAddress[msg.sender] && !blockedAddress[_to]);
    require(balanceOf[msg.sender] >= _value);
    require((balanceOf[_to].add(_value)) >= balanceOf[_to]);
    balanceOf[msg.sender] -= _value;
    balanceOf[_to] += _value;
    emit Transfer(msg.sender, _to, _value);
  }
}

library safeMath
{
  function mul(uint256 a, uint256 b) internal pure returns (uint256)
  {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256)
  {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}