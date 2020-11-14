/**
 * Source Code first verified at https://etherscan.io on Monday, April 15, 2019
 (UTC) */

pragma solidity ^0.4.24;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address internal _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    _owner = msg.sender;
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}


contract HYIPRETHPRO441 is Ownable{
    using SafeMath for uint256;
    
    mapping (address => uint256) public investedETH;
    mapping (address => uint256) public lastInvest;
    mapping (address => uint256) public lastWithdraw;
    
    mapping (address => uint256) public affiliateCommision;
    
    address public dev = address(0xB5f6a633992cC9BF735974c3E09B5849c7633E2f);
    address public promoter1 = address(0xcF8Fd8bA33A341130B5662Ba4cDee8de61366DF0);
    address public promoter2 = address(0xB5f6a633992cC9BF735974c3E09B5849c7633E2f);
    
    address public lastPotWinner;
    
    uint256 public pot = 0;
    uint256 public maxpot = 3000000000000000000;
    uint256 public launchtime = 1554822000;
    uint256 public maxwithdraw = SafeMath.div(87, 10);
    uint256 maxprofit = SafeMath.div(44, 10);
   
    
    
    event PotWinner(address indexed beneficiary, uint256 amount );
    
    constructor () public {
        _owner = address(0xB5f6a633992cC9BF735974c3E09B5849c7633E2f);
    }
    
    
      mapping(address => uint256) public userWithdrawals;
    mapping(address => uint256[]) public userSequentialDeposits;
    
    function maximumProfitUser() public view returns(uint256){ 
        return getInvested() * maxprofit;
    }
    
    function getTotalNumberOfDeposits() public view returns(uint256){
        return userSequentialDeposits[msg.sender].length;
    }
    
    function() public payable{ }
    
    
    
      function investETH(address referral) public payable {
      require(now >= launchtime);
      require(msg.value >= 0.1 ether);
      uint256 timelimit = SafeMath.sub(now, launchtime);
      
      
      if(timelimit < 1728000 && getProfit(msg.sender) > 0){
          reinvestProfit();
        }
        
      if(timelimit > 1728000 && getProfit(msg.sender) > 0){
            
             uint256 profit = getProfit(msg.sender);
             lastInvest[msg.sender] = now;
             lastWithdraw[msg.sender] = now;
             userWithdrawals[msg.sender] += profit;
             msg.sender.transfer(profit);
 
           
        }
       
        
        amount = msg.value;
        uint256 commision = amount.mul(9).div(100);
        uint256 commision1 = amount.mul(8).div(100);
        uint256 _pot = amount.mul(3).div(100);
        pot = pot.add(_pot);
        uint256 amount = amount;
        
        
        dev.transfer(commision1);
        promoter1.transfer(commision1);
       
        
        if(referral != msg.sender && referral != 0x1 && referral != promoter1){
            affiliateCommision[referral] = SafeMath.add(affiliateCommision[referral], commision);
        }
        
        //affiliateCommision[dev] = SafeMath.add(affiliateCommision[dev], commision);
        
        
        investedETH[msg.sender] = investedETH[msg.sender].add(amount);
        lastInvest[msg.sender] = now;
        userSequentialDeposits[msg.sender].push(amount);
        if(pot >= maxpot){
            uint256 winningReward = pot;
            msg.sender.transfer(winningReward);
            lastPotWinner = msg.sender;
            emit PotWinner(msg.sender, winningReward);
            pot = 0;
             }
       
    }
    
 
    
    function withdraw() public{
        uint256 profit = getProfit(msg.sender);
        uint256 timelimit = SafeMath.sub(now, launchtime);
        uint256 maximumProfit = maximumProfitUser();
        uint256 availableProfit = maximumProfit - userWithdrawals[msg.sender];
        uint256 maxwithdrawlimit = SafeMath.div(SafeMath.mul(maxwithdraw, investedETH[msg.sender]), 100);
       

        require(profit > 0);
        require(timelimit >= 1728000);
       
        lastInvest[msg.sender] = now;
        lastWithdraw[msg.sender] = now;
       
       
       
        if(profit < availableProfit){
        
        if(profit < maxwithdrawlimit){
        userWithdrawals[msg.sender] += profit;
        msg.sender.transfer(profit);
        }
        else if(profit >= maxwithdrawlimit){
        uint256 PartPayment = maxwithdrawlimit;
        uint256 finalprofit = SafeMath.sub(profit, PartPayment);
        userWithdrawals[msg.sender] += profit;
        msg.sender.transfer(PartPayment);
        investedETH[msg.sender] = SafeMath.add(investedETH[msg.sender], finalprofit);
        } 
          
        }
        
        else if(profit >= availableProfit && userWithdrawals[msg.sender] < maximumProfit){
            uint256 finalPartialPayment = availableProfit;
            if(finalPartialPayment < maxwithdrawlimit){
            userWithdrawals[msg.sender] = 0;
            investedETH[msg.sender] = 0;
            delete userSequentialDeposits[msg.sender];
            msg.sender.transfer(finalPartialPayment);
            }
             else if(finalPartialPayment >= maxwithdrawlimit){
             
        uint256 finalPartPayment = maxwithdrawlimit;
        uint256 finalprofits = SafeMath.sub(finalPartialPayment, finalPartPayment);
        userWithdrawals[msg.sender] += finalPartialPayment;
        msg.sender.transfer(finalPartPayment);
        investedETH[msg.sender] = SafeMath.add(investedETH[msg.sender], finalprofits);
        
        
             }
        }
    
        
    }
   
    function getProfitFromSender() public view returns(uint256){
        return getProfit(msg.sender);
    }

    function getProfit(address customer) public view returns(uint256){
        uint256 secondsPassed = SafeMath.sub(now, lastInvest[customer]);
        uint256 profit = SafeMath.div(SafeMath.mul(secondsPassed, investedETH[customer]), 985010);
        uint256 maximumProfit = maximumProfitUser();
        uint256 availableProfit = maximumProfit - userWithdrawals[msg.sender];

        if(profit > availableProfit && userWithdrawals[msg.sender] < maximumProfit){
            profit = availableProfit;
        }
        
        uint256 bonus = getBonus();
        if(bonus == 0){
            return profit;
        }
        return SafeMath.add(profit, SafeMath.div(SafeMath.mul(profit, bonus), 100));
    }
    
    function getBonus() public view returns(uint256){
        uint256 invested = getInvested();
        if(invested >= 0.1 ether && 4 ether >= invested){
            return 0;
        }else if(invested >= 4.01 ether && 7 ether >= invested){
            return 20;
        }else if(invested >= 7.01 ether && 10 ether >= invested){
            return 40;
        }else if(invested >= 10.01 ether && 15 ether >= invested){
            return 60;
        }else if(invested >= 15.01 ether){
            return 99;
        }
    }
    
    function reinvestProfit() public {
        uint256 profit = getProfit(msg.sender);
        require(profit > 0);
        lastInvest[msg.sender] = now;
        userWithdrawals[msg.sender] += profit;
        investedETH[msg.sender] = SafeMath.add(investedETH[msg.sender], profit);
    } 
 
   
    function getAffiliateCommision() public view returns(uint256){
        return affiliateCommision[msg.sender];
    }
    
    function withdrawAffiliateCommision() public {
        require(affiliateCommision[msg.sender] > 0);
        uint256 commision = affiliateCommision[msg.sender];
        affiliateCommision[msg.sender] = 0;
        msg.sender.transfer(commision);
    }
    
    function getInvested() public view returns(uint256){
        return investedETH[msg.sender];
    }
    
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
    
    function max(uint256 a, uint256 b) private pure returns (uint256) {
        return a > b ? a : b;
    }
    
    function updatePromoter1(address _address) external onlyOwner {
        require(_address != address(0x0));
        promoter1 = _address;
    }
    
    function updatePromoter2(address _address) external onlyOwner {
        require(_address != address(0x0));
        promoter2 = _address;
    }
    
    
    
    
     function updateMaxpot(uint256 _Maxpot) external onlyOwner {
        maxpot = _Maxpot;
    }
    
     function updateLaunchtime(uint256 _Launchtime) external onlyOwner {
        launchtime = _Launchtime;
    }
   

        /**
  *  function random() internal view returns (bool) {
        uint maxRange = 2**(8* 7);
        for(uint8 a = 0 ; a < 8; a++){
            uint randomNumber = uint( keccak256(abi.encodePacked(msg.sender,blockhash(block.number), block.timestamp )) ) % maxRange;
           if ((randomNumber % 13) % 19 == 0){
             return true;
                break;
            }
        }
        return false;    
    }  */
    
}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}