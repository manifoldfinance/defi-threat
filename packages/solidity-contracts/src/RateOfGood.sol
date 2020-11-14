/**
 * Source Code first verified at https://etherscan.io on Thursday, April 25, 2019
 (UTC) */

pragma solidity ^0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

/**
 * @title Destructible
 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.
 */
contract Destructible is Ownable {

  constructor() public payable { }

  /**
   * @dev Transfers the current balance to the owner and terminates the contract.
   */
  function destroy() onlyOwner public {
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) onlyOwner public {
    selfdestruct(_recipient);
  }
}

contract RateOfGood is Destructible {

    int256 inKindRoG = 0;
    int256 volunteerRoG = 0;
    int256 deliveryRoG = 0;
    int256 fundRaisingRoG = 0;

    /**
     * @dev event for when the in kind donation rog is set
     * @param value the new value to set
     */
    event EventSetInKindRateOfGood(int256 value);

    /**
     * @dev event for when the volunteer rog is set
     * @param value the new value to set
     */
    event EventSetVolunteerRateOfGood(int256 value);

    /**
     * @dev event for when the delivery rog is set
     * @param value the new value to set
     */
    event EventSetDeliveryRateOfGood(int256 value);

    /**
     * @dev event for when the fund raising rog is set
     * @param value the new value to set
     */
    event EventSetFundRaisingRateOfGood(int256 value);

    /**
     * @dev sets the in kind rog
     * @param _value the new value to set
     */
    function setInKindRoG(int256 _value) public onlyOwner returns (bool) {
        inKindRoG = _value;

        emit EventSetInKindRateOfGood(_value);

        return true;
    }

    /**
     * @dev gets the in kind rog
     */
    function getInKindRoG() public view returns (int256) {
        return inKindRoG * (10 ** 16);
    }

    /**
     * @dev sets the volunteer rog
     * @param _value the new value to set
     */
    function setVolunteerRoG(int256 _value) public onlyOwner returns (bool) {
        volunteerRoG = _value;

        emit EventSetVolunteerRateOfGood(_value);

        return true;
    }

    /**
     * @dev gets the volunteer rog
     */
    function getVolunteerRoG() public view returns (int256) {
        return volunteerRoG * (10 ** 16);
    }

    /**
     * @dev sets the delivery rog
     * @param _value the new value to set
     */
    function setDeliveryRoG(int256 _value) public onlyOwner returns (bool) {
        deliveryRoG = _value;

        emit EventSetDeliveryRateOfGood(_value);

        return true;
    }

    /**
     * @dev gets the delivery rog
     */
    function getDeliveryRoG() public view returns (int256) {
        return deliveryRoG * (10 ** 16);
    }

    /**
     * @dev sets the fund raising rog
     * @param _value the new value to set
     */
    function setFundRaisingRoG(int256 _value) public onlyOwner returns (bool) {
        fundRaisingRoG = _value;

        emit EventSetFundRaisingRateOfGood(_value);

        return true;
    }

    /**
     * @dev gets the fund raising rog
     */
    function getFundRaisingRoG() public view returns (int256) {
        return fundRaisingRoG * (10 ** 16);
    }
}