/**
 * Source Code first verified at https://etherscan.io on Sunday, April 14, 2019
 (UTC) */

library SafeMath {
  function mul(uint a, uint b) internal pure  returns (uint) {
    uint c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }
  function div(uint a, uint b) internal pure returns (uint) {
    require(b > 0);
    uint c = a / b;
    require(a == b * c + a % b);
    return c;
  }
  function sub(uint a, uint b) internal pure returns (uint) {
    require(b <= a);
    return a - b;
  }
  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    require(c >= a);
    return c;
  }
  function max64(uint64 a, uint64 b) internal  pure returns (uint64) {
    return a >= b ? a : b;
  }
  function min64(uint64 a, uint64 b) internal  pure returns (uint64) {
    return a < b ? a : b;
  }
  function max256(uint256 a, uint256 b) internal  pure returns (uint256) {
    return a >= b ? a : b;
  }
  function min256(uint256 a, uint256 b) internal  pure returns (uint256) {
    return a < b ? a : b;
  }
}


contract Ownable {
    address public owner;

    function Ownable() public{
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) onlyOwner public{
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address _owner) external view returns (uint256 balance);

}

contract TokenAirdroperFor5GT is Ownable{
    
    using SafeMath for uint;

    address public tokenAddress = 0xf82c9bbcc3b1407b494c8529256c2a8ea5dd8eb6;

    uint256 public limitPayValue = 0.1 ether;
  
    uint256 public airdropRate = 555;
    bool public airdropPaused = false;


    constructor(){}
     
    function () payable public{
        require(airdropPaused == false);
        require(msg.value == limitPayValue);
        require(owner.send(msg.value));
        require(IERC20(tokenAddress).transfer(msg.sender,airdropRate.mul(1 ether)));
    }
    function changeAirdropStatus(bool _airdropPaused) public onlyOwner{
        airdropPaused = _airdropPaused;
    }
    
    function withdraw(address _tokenAddress) public onlyOwner{
         if(_tokenAddress == address(0)){
          require(owner.send(address(this).balance));
          return;
      }
      IERC20 erc20 = IERC20(tokenAddress);
      uint256 balance = erc20.balanceOf(this);
      require(erc20.transfer(owner,balance));
    }

    
}