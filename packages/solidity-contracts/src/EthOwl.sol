pragma solidity 0.5.7;

import "./Ownable.sol";

contract EthOwl is Ownable {
  uint256 public price = 1e17;

  event Hoot(address addr, string endpoint);

  function adjustPrice(uint256 _price) public onlyOwner {
    price = _price;
  }

  function purchase(address _addr, string memory _endpoint) public payable {
    require(msg.value >= price);
    emit Hoot(_addr, _endpoint);
  }

  function withdraw() public onlyOwner {
    msg.sender.transfer(address(this).balance);
  }
}
