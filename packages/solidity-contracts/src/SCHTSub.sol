/**
 * Source Code first verified at https://etherscan.io on Wednesday, March 27, 2019
 (UTC) */

pragma solidity ^0.4.21;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
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
  address public ctOwner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == ctOwner);
    _;
  }

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
   */
  function Ownable() public {
    ctOwner = msg.sender;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(ctOwner, newOwner);
    ctOwner = newOwner;
  }
}

contract MasterRule is Ownable {
  address public masterAddr;

  function setMasterAddr(address _newMasterAddr) public onlyOwner {
    masterAddr = _newMasterAddr;
  }

  /**
   * @dev Throws if called by any contract other than the Master-Contract address that has been set.
   */
  modifier onlyMaster() {
    require(msg.sender == masterAddr);
    _;
  }
}

contract SCHToken {
  function setBalanceForAddr(address _addr, uint256 _value) public;
  function balanceOf(address _owner) public view returns (uint256 balance);
  function incrementStage() public;
  function getCurrentStageSpent() public view returns (uint256);
  function setCurrentStageSpent(uint256 _value) public;
  function totalSupply() public view returns (uint256);
  function getTotalSpent() public view returns (uint256);
  function setTotalSpent(uint256 _value) public; 
  function getCurrentCap() public view returns (uint256);
  function setCurrentCap(uint256 _value) public;
  function allowance(address _owner, address _spender) public view returns (uint256);
  function setAllowance(address _owner, address _spender, uint256 _value) public;
  function addAddrToIndex(address _addr) public;
}

contract SCHTSub is MasterRule {

  using SafeMath for uint256;

  function transfer(address _to, uint256 _value, address origin) public onlyMaster returns (bool) {
    require(_to != address(0));
    require(origin == ctOwner);

    SCHToken mc = SCHToken(masterAddr);
    require(mc.getCurrentStageSpent().add(_value) <= mc.getCurrentCap());

    uint256 from_balance = mc.balanceOf(origin);
    require(_value <= from_balance);

    mc.setBalanceForAddr(origin, from_balance.sub(_value));
    mc.setBalanceForAddr(_to, mc.balanceOf(_to).add(_value));
    mc.addAddrToIndex(_to);
    mc.setCurrentStageSpent(mc.getCurrentStageSpent().add(_value));
    return true;
  }

  function transferFromTo(address _from, address _to, uint256 _value, address origin) public onlyMaster returns (bool) {
    require(_from != address(0));
    require(_to != address(0));
    require(origin == ctOwner);

    SCHToken mc = SCHToken(masterAddr);

    uint256 from_balance = mc.balanceOf(_from);
    require(_value <= from_balance);

    mc.setBalanceForAddr(_from, from_balance.sub(_value));
    mc.setBalanceForAddr(_to, mc.balanceOf(_to).add(_value));
    return true;
  }

  function changeStage(uint256 _stageCapValue) public onlyMaster {
    SCHToken mc = SCHToken(masterAddr);
    uint256 totalSPent = mc.getTotalSpent();
    require(totalSPent.add(_stageCapValue)<=mc.totalSupply());
    uint256  balanceFromLast = mc.getCurrentCap().sub(mc.getCurrentStageSpent());
    mc.incrementStage();
    mc.setCurrentCap(_stageCapValue.add(balanceFromLast));
    mc.setTotalSpent(_stageCapValue.add(totalSPent));
    mc.setCurrentStageSpent(0);
  }

  function approve(address _spender, uint256 _value, address origin) public onlyMaster returns (bool) {
    require(origin == ctOwner);
    SCHToken mc = SCHToken(masterAddr);
    mc.setAllowance(origin, _spender, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value, address origin) public onlyMaster returns (bool) {
    require(_to != address(0));
    require(origin == ctOwner);

    SCHToken mc = SCHToken(masterAddr);

    uint256 from_balance = mc.balanceOf(_from);
    uint256 allowance_value = mc.allowance(_from,_to);

    require(_value <= from_balance);
    require(_value <= allowance_value);

    mc.setBalanceForAddr(_from, from_balance.sub(_value));
    mc.setBalanceForAddr(_to, mc.balanceOf(_to).add(_value));
    mc.addAddrToIndex(_to);

    mc.setAllowance(_from, _to, allowance_value.sub(_value));
    return true;
  }

  function increaseApproval(address _spender, uint _addedValue, address origin) public onlyMaster returns (bool) {
    require(origin == ctOwner);
    SCHToken mc = SCHToken(masterAddr);
    mc.setAllowance(origin, _spender, mc.allowance(origin, _spender).add(_addedValue));
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue, address origin) public onlyMaster returns (bool) {
    require(origin == ctOwner);
    SCHToken mc = SCHToken(masterAddr);
    uint256 oldValue = mc.allowance(origin,_spender);
    if (_subtractedValue >= oldValue) {
      mc.setAllowance(origin, _spender, 0);
    } else {
      mc.setAllowance(origin, _spender, oldValue.sub(_subtractedValue));
    }
    return true;
  }
}