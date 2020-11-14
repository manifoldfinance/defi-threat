/**
 * Source Code first verified at https://etherscan.io on Sunday, April 14, 2019
 (UTC) */

pragma solidity ^0.4.24; contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    } function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
} contract Bank is DSMath { mapping(address => uint) public balances;
  event LogDepositMade(address accountAddress, uint amount); function deposit() public payable returns (uint balance) {
    balances[msg.sender] = add(balances[msg.sender], msg.value);
    emit LogDepositMade(msg.sender, msg.value);
    return balances[msg.sender];
  } function withdraw(uint amount) public returns (uint remainingBalance){
    require(min(amount,balances[msg.sender]) == amount);
    balances[msg.sender] = sub(balances[msg.sender],amount);
    msg.sender.transfer(amount);
    return balances[msg.sender];
  } 

function balance() view public returns (uint) {
    return balances[msg.sender];
  }
} contract OwnsArt is DSMath, Bank{
  address public artist;
  address public artOwner;
  uint public price;
  uint public resaleFee;
  uint public constant maxFlatIncreaseAmount = 0.01 ether;
  uint public constant maxPercentIncreaseAmount = 10;

  event LogArtBought(address purchaserAddress, uint price, uint resalePrice);

  bool private buyArtMutex = false;

  constructor() public {
    artist = msg.sender;
    artOwner = msg.sender;
    price = 0.01 ether;
    resaleFee = 0 ether;
    emit LogArtBought(msg.sender,0 ether,price);
  } function buyArt(uint maxBid, uint resalePrice) public returns (uint){
    require(msg.sender != artOwner);
    require(max(maxBid,price) == maxBid);
    require(min(maxBid,balances[msg.sender]) == maxBid);
    require(min(resalePrice,maxResalePrice()) == resalePrice);

    require(!buyArtMutex);
    buyArtMutex = true;


    balances[msg.sender] = sub(balances[msg.sender],price);
    balances[artOwner] = add(balances[artOwner],sub(price,resaleFee));
    balances[artist] = add(balances[artist],resaleFee);
    artOwner = msg.sender; if(min(resalePrice,price)==resalePrice){
      resaleFee = 0 ether;
    } else{
      resaleFee = rdiv(sub(resalePrice,price),2*RAY);
    }

    emit LogArtBought(msg.sender,price,resalePrice);
    price = resalePrice;

    buyArtMutex = false;
    return balances[msg.sender];
  } function maxResalePrice() view public returns (uint){
    return add(add(rdiv(mul(price,maxPercentIncreaseAmount),100*RAY),price),maxFlatIncreaseAmount);
  }
}