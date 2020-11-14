/**
 * Source Code first verified at https://etherscan.io on Thursday, March 14, 2019
 (UTC) */

pragma solidity ^0.5.0;

// Market API used to interract with augur, we only need to describe the
// functions we'll be using.
// cf https://github.com/AugurProject/augur-core/blob/master/source/contracts/reporting/IMarket.sol
interface IMarket {
    function isFinalized() external view returns (bool);
    function isInvalid() external view returns (bool);
    function getWinningPayoutNumerator(uint256 _outcome) external view returns (uint256);
    function getEndTime() external view returns (uint256);
}

contract CharityChallenge {

    event Received(address indexed sender, uint256 value);

    event Donated(address indexed npo, uint256 value);

    event Claimed(address indexed claimer, uint256 value);

    event SafetyHatchClaimed(address indexed claimer, uint256 value);

    address payable public contractOwner;

    // key is npo address, value is ratio
    mapping(address => uint8) public npoRatios;

    uint8 sumRatio;

    address payable[] public npoAddresses;

    address public marketAddress;

    IMarket market;

    uint256 public challengeEndTime;

    uint256 public challengeSafetyHatchTime1;

    uint256 public challengeSafetyHatchTime2;

    bool public isEventFinalizedAndValid;

    bool public hasChallengeAccomplished;

    bool private safetyHatchClaimSucceeded;

    mapping(address => uint256) public donorBalances;

    uint256 public donorCount;

    bool private mReentrancyLock = false;
    modifier nonReentrant() {
        require(!mReentrancyLock);
        mReentrancyLock = true;
        _;
        mReentrancyLock = false;
    }

    constructor(
        address payable _contractOwner,
        address payable[] memory _npoAddresses,
        uint8[] memory _ratios,
        address _marketAddress
    ) public
    {
        require(_npoAddresses.length == _ratios.length);
        uint length = _npoAddresses.length;
        contractOwner = _contractOwner;
        for (uint i = 0; i < length; i++) {
          address payable npo = _npoAddresses[i];
          npoAddresses.push(npo);
          npoRatios[npo] = _ratios[i];
          sumRatio += _ratios[i];
        }
        marketAddress = _marketAddress;
        market = IMarket(_marketAddress);
        challengeEndTime = market.getEndTime();
        challengeSafetyHatchTime1 = challengeEndTime + 26 weeks;
        challengeSafetyHatchTime2 = challengeSafetyHatchTime1 + 52 weeks;
        isEventFinalizedAndValid = false;
        hasChallengeAccomplished = false;
    }

    function() external payable {
        require(now <= challengeEndTime);
        require(msg.value > 0);
        if (donorBalances[msg.sender] == 0 && msg.value > 0) {
          donorCount++;
        }
        donorBalances[msg.sender] += msg.value;
        emit Received(msg.sender, msg.value);
    }

    function balanceOf(address _donorAddress) public view returns (uint256) {
        if (safetyHatchClaimSucceeded) {
            return 0;
        }
        return donorBalances[_donorAddress];
    }

    function finalize() nonReentrant external {
        require(now > challengeEndTime);
        require(now <= challengeSafetyHatchTime1);
        require(!isEventFinalizedAndValid);

        bool hasError;
        (hasChallengeAccomplished, hasError) = checkAugur();
        if (!hasError) {
            isEventFinalizedAndValid = true;
            if (hasChallengeAccomplished) {
                uint256 totalContractBalance = address(this).balance;
                uint length = npoAddresses.length;
                uint256 donatedAmount = 0;
                for (uint i = 0; i < length - 1; i++) {
                  address payable npo = npoAddresses[i];
                  uint8 ratio = npoRatios[npo];
                  uint256 amount = totalContractBalance * ratio / sumRatio;
                  donatedAmount += amount;
                  npo.transfer(amount);
                  emit Donated(npo, amount);
                }
                // Don't want to keep any amount in the contract
                uint256 remainingAmount = totalContractBalance - donatedAmount;
                address payable npo = npoAddresses[length - 1];
                npo.transfer(remainingAmount);
                emit Donated(npo, remainingAmount);
            }
        }
    }

    function getExpectedDonationAmount(address payable _npo) view external returns (uint256) {
      require(npoRatios[_npo] > 0);
      uint256 totalContractBalance = address(this).balance;
      uint8 ratio = npoRatios[_npo];
      uint256 amount = totalContractBalance * ratio / sumRatio;
      return amount;
    }

    function claim() nonReentrant external {
        require(now > challengeEndTime);
        require(isEventFinalizedAndValid || now > challengeSafetyHatchTime1);
        require(!hasChallengeAccomplished || now > challengeSafetyHatchTime1);
        require(balanceOf(msg.sender) > 0);

        uint256 claimedAmount = balanceOf(msg.sender);
        donorBalances[msg.sender] = 0;
        msg.sender.transfer(claimedAmount);
        emit Claimed(msg.sender, claimedAmount);
    }

    function safetyHatchClaim() external {
        require(now > challengeSafetyHatchTime2);
        require(msg.sender == contractOwner);

        uint totalContractBalance = address(this).balance;
        safetyHatchClaimSucceeded = true;
        contractOwner.transfer(address(this).balance);
        emit SafetyHatchClaimed(contractOwner, totalContractBalance);
    }

    function checkAugur() private view returns (bool happened, bool errored) {
        if (market.isFinalized()) {
            if (market.isInvalid()) {
                return (false, true);
            } else {
                uint256 no = market.getWinningPayoutNumerator(0);
                uint256 yes = market.getWinningPayoutNumerator(1);
                return (yes > no, false);
            }
        } else {
            return (false, true);
        }
    }
}