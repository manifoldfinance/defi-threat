/**
 * Source Code first verified at https://etherscan.io on Tuesday, April 16, 2019
 (UTC) */

pragma solidity ^0.5.7;

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
  address public owner;

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }
}

contract HUBRISSTAKE is Ownable {
  ERC20 public token;
  uint256 public principle;
  uint256 public totalReward;
  uint public startDay;
  uint public duration;
  bool public isClaimed;

  constructor(ERC20 _token, address _owner, uint256 _principle, uint256 _totalReward, uint _duration) public {
    uint today = block.timestamp / 24 hours;
    token = _token;
    owner = _owner;
    principle = _principle;
    totalReward = _totalReward;
    startDay = today;
    duration = _duration;
    isClaimed = false;
  }

  function accumulatedReward() public view returns (uint256) {
    if (isClaimed) return 0;
    uint today = block.timestamp / 24 hours;
    uint durationElapsed = today - startDay;
    if ( durationElapsed > duration ) {
        durationElapsed = duration;
    }
    return totalReward * durationElapsed / duration;
  }

  function isReadyToClaim() public view returns (bool) {
    uint today = block.timestamp / 24 hours;
    if (today < (startDay + duration)) return false;
    if (isClaimed) return false;
    return true;
  }

  function claim() public {
    assert(isReadyToClaim());
    token.transfer(owner, principle + totalReward);
    isClaimed = true;
  }

}

contract HUBRISSTAKING is Ownable {
  ERC20 public token;
  mapping (uint => uint256) public threshold;
  mapping (uint => uint256) public rewardPerTenThousand;
  mapping (address => HUBRISSTAKE[]) public stakes;

  constructor(ERC20 _token) public {
    token = _token;
    threshold[1] = 150000E18;
    threshold[3] = 600000E18;
    threshold[6] = 1500000E18;
    threshold[12] = 2500000E18;
    rewardPerTenThousand[1] = 50;
    rewardPerTenThousand[3] = 20;
    rewardPerTenThousand[6] = 450;
    rewardPerTenThousand[12] = 1100;
  }

  function setThresholdAndReward(uint256 threshold_1Month, uint256 reward_1month, uint256 threshold_3Month, uint256 reward_3month, uint256 threshold_6Month, uint256 reward_6month, uint256 threshold_12Month, uint256 reward_12month) public onlyOwner {
    threshold[1] = threshold_1Month;
    threshold[3] = threshold_3Month;
    threshold[6] = threshold_6Month;
    threshold[12] = threshold_12Month;
    rewardPerTenThousand[1] = reward_1month;
    rewardPerTenThousand[3] = reward_3month;
    rewardPerTenThousand[6] = reward_6month;
    rewardPerTenThousand[12] = reward_12month;
  }

  function stake(uint256 _principle, uint months) public returns (HUBRISSTAKE) {
    uint duration = months * 30;
    uint256 totalReward;
    assert((months == 1) || (months == 3) || (months == 6) || (months == 12));
    assert(_principle >= threshold[months]);
    totalReward = _principle * rewardPerTenThousand[months] / 10000;
    HUBRISSTAKE stakeObj = new HUBRISSTAKE(token, msg.sender, _principle, totalReward, duration);
    token.transferFrom(msg.sender, address(stakeObj), _principle);
    token.transfer(address(stakeObj), totalReward);
    stakes[msg.sender].push(stakeObj);
    return stakeObj;
  }

  function totalPrinciple(address _owner) public view returns (uint256) {
    uint256 result = 0;
    for (uint i = 0; i < stakes[_owner].length; i++) {
      if (!stakes[_owner][i].isClaimed()) {
        result += stakes[_owner][i].principle();
      }
    }
    return result;
  }


  function accumulatedReward(address _owner) public view returns (uint256) {
    uint256 result = 0;
    for (uint i = 0; i < stakes[_owner].length; i++) {
      if (!stakes[_owner][i].isClaimed()) {
        result += stakes[_owner][i].accumulatedReward();
      }
    }
    return result;
  }

  function isReadyToClaim(address _owner) public view returns (bool) {
    for (uint i = 0; i < stakes[_owner].length; i++) {
      if (stakes[_owner][i].isReadyToClaim()) {
        return true;
      }
    }
    return false;
  }

  function claim() public {
    bool isAtLeastOneClaimed = false;
    for (uint i = 0; i < stakes[msg.sender].length; i++) {
      if (stakes[msg.sender][i].isReadyToClaim()) {
        stakes[msg.sender][i].claim();
        isAtLeastOneClaimed = true;
      }
    }
    assert(isAtLeastOneClaimed);
  }

  function getStakes(address _owner) public view returns (HUBRISSTAKE[] memory) {
    return stakes[_owner];
  }

}