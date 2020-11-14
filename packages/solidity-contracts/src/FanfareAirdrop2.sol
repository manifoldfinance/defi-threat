/**
 * Source Code first verified at https://etherscan.io on Tuesday, March 19, 2019
 (UTC) */

pragma solidity ^0.4.11;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control 
 * functions, this simplifies the implementation of "user permissions". 
 */
contract Ownable {
  address public owner;

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

}


contract Token{
  function transfer(address to, uint value) external returns (bool);
}

contract FanfareAirdrop2 is Ownable {

    function multisend (address _tokenAddr, address[] _to, uint256[] _value) external
    
    returns (bool _success) {
        assert(_to.length == _value.length);
        assert(_to.length <= 150);
        // loop through to addresses and send value
        for (uint8 i = 0; i < _to.length; i++) {
                uint256 actualValue = _value[i] * 10**18;
                require((Token(_tokenAddr).transfer(_to[i], actualValue)) == true);
            }
            return true;
        }
}