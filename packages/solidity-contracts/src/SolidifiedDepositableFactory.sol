/**
 * Source Code first verified at https://etherscan.io on Friday, April 26, 2019
 (UTC) */

pragma solidity 0.5.0;

contract SolidifiedDepositableFactoryI {
  function deployDepositableContract(address _userAddress, address _mainHub)
   public
   returns(address depositable);
}


contract SolidifiedDepositable {

  address public mainHub;
  address public userAddress;

  /**
    @dev Constructor functions
    @param _userAddress address The user address that will be credited in main hubDeployer
    @param _mainHub address The address of the main hub
  **/
  constructor(address _userAddress, address _mainHub)
  public
  {
    userAddress = _userAddress;
    mainHub = _mainHub;
  }


  /**
  @dev Fallback to receive ether and transfer to _mainHub
  **/
  function ()
    external
    payable {
    require(msg.value > 0, "Depositable:invalid amount");
    (bool success, bytes memory _) = mainHub.call.value(msg.value)(abi.encodeWithSignature("receiveDeposit(address)",userAddress));
    require(success, "Depositable:low level call has failed");
  }
}





contract SolidifiedDepositableFactory is SolidifiedDepositableFactoryI {

  /**
  @dev Deploys a new depoitable contract
  @param _userAddress address Address of the user
  @param _mainHub address Address of the main hub
  @return The address of the new contract
  **/
  function deployDepositableContract(address _userAddress, address _mainHub)
    public
    returns(address depositable){

      SolidifiedDepositable d = new SolidifiedDepositable(_userAddress, _mainHub);
      return address(d);
  }

}