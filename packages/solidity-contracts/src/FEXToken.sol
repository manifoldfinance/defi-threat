/**
 * Source Code first verified at https://etherscan.io on Wednesday, April 3, 2019
 (UTC) */

pragma solidity ^0.4.24;

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract Owned {
    address public owner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
} 
/* import "./oraclizeAPI_0.5.sol"; */








contract ERC20 is ERC20Basic {
  // Optional token name
  string  public  name = "zeosX";
  string  public  symbol;
  uint256  public  decimals = 18; // standard token precision. override to customize
    
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}




/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
 
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;

  function multiTransfer(address[] _to,uint[] _value) public returns (bool);

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract BurnableToken is StandardToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    require(_value <= balances[msg.sender]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(burner, _value);
    emit Transfer(burner, address(0), _value);
  }
}




contract KYCVerification is Owned{
    
    mapping(address => bool) public kycAddress;
    
    event LogKYCVerification(address _kycAddress,bool _status);
    
    constructor () public {
        owner = msg.sender;
    }

    function updateVerifcationBatch(address[] _kycAddress,bool _status) onlyOwner public returns(bool)
    {
        for(uint tmpIndex = 0; tmpIndex < _kycAddress.length; tmpIndex++)
        {
            kycAddress[_kycAddress[tmpIndex]] = _status;
            emit LogKYCVerification(_kycAddress[tmpIndex],_status);
        }
        
        return true;
    }
    
    function updateVerifcation(address _kycAddress,bool _status) onlyOwner public returns(bool)
    {
        kycAddress[_kycAddress] = _status;
        
        emit LogKYCVerification(_kycAddress,_status);
        
        return true;
    }
    
    function isVerified(address _user) view public returns(bool)
    {
        return kycAddress[_user] == true; 
    }
}


contract FEXToken is Owned, BurnableToken {

    string public name = "SUREBANQA UTILITY TOKEN";
    string public symbol = "FEX";
    uint8 public decimals = 5;
    
    uint256 public initialSupply = 450000000 * (10 ** uint256(decimals));
    uint256 public totalSupply = 2100000000 * (10 ** uint256(decimals));
    uint256 public externalAuthorizePurchase = 0;
    
    mapping (address => bool) public frozenAccount;
    mapping(address => uint8) authorizedCaller;
    
    KYCVerification public kycVerification;
    bool public kycEnabled = true;

    /*  Fund Allocation  */
    uint allocatedEAPFund;
    uint allocatedAirdropAndBountyFund;
    uint allocatedMarketingFund;
    uint allocatedCoreTeamFund;
    uint allocatedTreasuryFund;
    
    uint releasedEAPFund;
    uint releasedAirdropAndBountyFund;
    uint releasedMarketingFund;
    uint releasedCoreTeamFund;
    uint releasedTreasuryFund;
    
    /* EAP Related Factors */
    uint8 EAPMilestoneReleased = 0; /* Total 4 Milestones , one milestone each year */
    uint8 EAPVestingPercent = 25; /* 25% */
    
    
    /* Core Team Related Factors */
    
    uint8 CoreTeamMilestoneReleased = 0; /* Total 4 Milestones , one milestone each quater */
    uint8 CoreTeamVestingPercent = 25; /* 25% */
    
    /* Distribution Address */
    address public EAPFundReceiver = 0xD89c58BedFf2b59fcDDAE3D96aC32D777fa00bF4;
    address public AirdropAndBountyFundReceiver = 0xE4bBCE2795e5C7fF4B7a40b91f7b611526B5613E;
    address public MarketingFundReceiver = 0xbe4c8660ed5709dF4172936743e6868F11686DBe;
    address public CoreTeamFundReceiver = 0x2c1Ab4B9E4dD402120ECe5DF08E35644d2efCd35;
    address public TreasuryFundReceiver = 0xeB81295b4e60e52c60206B0D12C13F82a36Ac9B6;
    
    /* Token Vesting Events*/
    
    event EAPFundReleased(address _receiver,uint _amount,uint _milestone);
    event CoreTeamFundReleased(address _receiver,uint _amount,uint _milestone);

    bool public initialFundDistributed;
    uint public tokenVestingStartedOn; 


    modifier onlyAuthCaller(){
        require(authorizedCaller[msg.sender] == 1 || msg.sender == owner);
        _;
    }
    
    modifier kycVerified(address _guy) {
      if(kycEnabled == true){
          if(kycVerification.isVerified(_guy) == false)
          {
              revert("KYC Not Verified");
          }
      }
      _;
    }
    
    modifier frozenVerified(address _guy) {
        if(frozenAccount[_guy] == true)
        {
            revert("Account is freeze");
        }
        _;
    }
    
    /* KYC related events */    
    event KYCMandateUpdate(bool _kycEnabled);
    event KYCContractAddressUpdate(KYCVerification _kycAddress);

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address target, bool frozen);
    
    /* Events */
    event AuthorizedCaller(address caller);
    event DeAuthorizedCaller(address caller);
    
    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor () public {
        
        owner = msg.sender;
        balances[0xBcd5B67aaeBb9765beE438e4Ce137B9aE2181898] = totalSupply;
        
        emit Transfer(address(0x0), address(this), totalSupply);
        emit Transfer(address(this), address(0xBcd5B67aaeBb9765beE438e4Ce137B9aE2181898), totalSupply);

        authorizedCaller[msg.sender] = 1;
        emit AuthorizedCaller(msg.sender);

        tokenVestingStartedOn = now;
        initialFundDistributed = false;
    }

    function initFundDistribution() public onlyOwner 
    {
        require(initialFundDistributed == false);
        
        /* Reserved for Airdrops/Bounty: 125 Million. */
        
        allocatedAirdropAndBountyFund = 125000000 * (10 ** uint256(decimals));
        _transfer(0xBcd5B67aaeBb9765beE438e4Ce137B9aE2181898,address(AirdropAndBountyFundReceiver),allocatedAirdropAndBountyFund);
        releasedAirdropAndBountyFund = allocatedAirdropAndBountyFund;
        
        /* Reserved for Marketing/Partnerships: 70 Million. */
        
        allocatedMarketingFund = 70000000 * (10 ** uint256(decimals));
        _transfer(0xBcd5B67aaeBb9765beE438e4Ce137B9aE2181898,address(MarketingFundReceiver),allocatedMarketingFund);
        releasedMarketingFund = allocatedMarketingFund;
        
        
        /* Reserved for EAPs/SLIPs : 125 Million released every year at the rate of 25% per yr. */
        
        allocatedEAPFund = 125000000 * (10 ** uint256(decimals));
        
        /* Core Team: 21 Million. Released quarterly at the rate of 25% of 21 Million per quarter.  */
        
        allocatedCoreTeamFund = 21000000 * (10 ** uint256(decimals));

        /* Treasury: 2.1 Million Time Locked for 24 months */
        
        allocatedTreasuryFund = 2100000 * (10 ** uint256(decimals));
        
        initialFundDistributed = true;
    }
    
    function updateKycContractAddress(KYCVerification _kycAddress) public onlyOwner returns(bool)
    {
      kycVerification = _kycAddress;
      emit KYCContractAddressUpdate(_kycAddress);
      return true;
    }

    function updateKycMandate(bool _kycEnabled) public onlyAuthCaller returns(bool)
    {
        kycEnabled = _kycEnabled;
        emit KYCMandateUpdate(_kycEnabled);
        return true;
    }
    
    /* authorize caller */
    function authorizeCaller(address _caller) public onlyOwner returns(bool) 
    {
        authorizedCaller[_caller] = 1;
        emit AuthorizedCaller(_caller);
        return true;
    }
    
    /* deauthorize caller */
    function deAuthorizeCaller(address _caller) public onlyOwner returns(bool) 
    {
        authorizedCaller[_caller] = 0;
        emit DeAuthorizedCaller(_caller);
        return true;
    }
    
    function () public payable {
        revert();
        // buy();
    }
    
    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
        require (balances[_from] > _value);                // Check if the sender has enough
        require (balances[_to].add(_value) > balances[_to]); // Check for overflow
        balances[_from] = balances[_from].sub(_value);                         // Subtract from the sender
        balances[_to] = balances[_to].add(_value);                           // Add the same to the recipient
        emit Transfer(_from, _to, _value);
    }

    /// @notice Create `mintedAmount` tokens and send it to `target`
    /// @param target Address to receive the tokens
    /// @param mintedAmount the amount of tokens it will receive
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balances[target] = balances[target].add(mintedAmount);
        totalSupply = totalSupply.add(mintedAmount);
        emit Transfer(0, this, mintedAmount);
        emit Transfer(this, target, mintedAmount);
    }
    
    /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
    /// @param target Address to be frozen
    /// @param freeze either to freeze it or not
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

    
    function purchaseToken(address _receiver, uint _tokens) onlyAuthCaller public {
        require(_tokens > 0);
        require(initialSupply > _tokens);
        
        initialSupply = initialSupply.sub(_tokens);
        _transfer(owner, _receiver, _tokens);              // makes the transfers
        externalAuthorizePurchase = externalAuthorizePurchase.add(_tokens);
    }
    
    /**
      * @dev transfer token for a specified address
      * @param _to The address to transfer to.
      * @param _value The amount to be transferred.
      */
    function transfer(address _to, uint256 _value) public kycVerified(msg.sender) frozenVerified(msg.sender) returns (bool) {
        _transfer(msg.sender,_to,_value);
        return true;
    }
    
    /*
        Please make sure before calling this function from UI, Sender has sufficient balance for 
        All transfers 
    */
    function multiTransfer(address[] _to,uint[] _value) public kycVerified(msg.sender) frozenVerified(msg.sender) returns (bool) {
        require(_to.length == _value.length, "Length of Destination should be equal to value");
        for(uint _interator = 0;_interator < _to.length; _interator++ )
        {
            _transfer(msg.sender,_to[_interator],_value[_interator]);
        }
        return true;    
    }


    /**
      * @dev Release Treasury Fund Time Locked for 24 months   
      *  Can only be called by authorized caller   
      */
    function releaseTreasuryFund() public onlyAuthCaller returns(bool)
    {
        require(now >= tokenVestingStartedOn.add(730 days));
        require(allocatedTreasuryFund > 0);
        require(releasedTreasuryFund <= 0);
        
        _transfer(address(this),TreasuryFundReceiver,allocatedTreasuryFund);   
        
        /* Complete funds are released */
        releasedTreasuryFund = allocatedTreasuryFund;
        
        return true;
    }
    

    /**
      * @dev Release EAPs/SLIPs Fund Time Locked releasable every year at the rate of 25% per yr   
      *  Can only be called by authorized caller   
      */
    function releaseEAPFund() public onlyAuthCaller returns(bool)
    {
        /* Only 4 Milestone are to be released */
        require(EAPMilestoneReleased <= 4);
        require(allocatedEAPFund > 0);
        require(releasedEAPFund <= allocatedEAPFund);
        
        uint toBeReleased = 0 ;
        
        if(now <= tokenVestingStartedOn.add(365 days))
        {
            toBeReleased = allocatedEAPFund.mul(EAPVestingPercent).div(100);
            EAPMilestoneReleased = 1;
        }
        else if(now <= tokenVestingStartedOn.add(730 days))
        {
            toBeReleased = allocatedEAPFund.mul(EAPVestingPercent).div(100);
            EAPMilestoneReleased = 2;
        }
        else if(now <= tokenVestingStartedOn.add(1095 days))
        {
            toBeReleased = allocatedEAPFund.mul(EAPVestingPercent).div(100);
            EAPMilestoneReleased = 3;
        }
        else if(now <= tokenVestingStartedOn.add(1460 days))
        {
            toBeReleased = allocatedEAPFund.mul(EAPVestingPercent).div(100);
            EAPMilestoneReleased = 4;
        }
        /* If release request sent beyond 4 years , release remaining amount*/
        else if(now > tokenVestingStartedOn.add(1460 days) && EAPMilestoneReleased != 4)
        {
            toBeReleased = allocatedEAPFund.sub(releasedEAPFund);
            EAPMilestoneReleased = 4;
        }
        else
        {
            revert();
        }
        
        if(toBeReleased > 0)
        {
            releasedEAPFund = releasedEAPFund.add(toBeReleased);
            _transfer(address(this),EAPFundReceiver,toBeReleased);
            
            emit EAPFundReleased(EAPFundReceiver,toBeReleased,EAPMilestoneReleased);
            
            return true;
        }
        else
        {
            revert();
        }
    }
    

    /**
      * @dev Release Core Team's Fund Time Locked releasable  quarterly at the rate of 25%    
      *  Can only be called by authorized caller   
      */
    function releaseCoreTeamFund() public onlyAuthCaller returns(bool)
    {
        /* Only 4 Milestone are to be released */
        require(CoreTeamMilestoneReleased <= 4);
        require(allocatedCoreTeamFund > 0);
        require(releasedCoreTeamFund <= allocatedCoreTeamFund);
        
        uint toBeReleased = 0 ;
        
        if(now <= tokenVestingStartedOn.add(90 days))
        {
            toBeReleased = allocatedCoreTeamFund.mul(CoreTeamVestingPercent).div(100);
            CoreTeamMilestoneReleased = 1;
        }
        else if(now <= tokenVestingStartedOn.add(180 days))
        {
            toBeReleased = allocatedCoreTeamFund.mul(CoreTeamVestingPercent).div(100);
            CoreTeamMilestoneReleased = 2;
        }
        else if(now <= tokenVestingStartedOn.add(270 days))
        {
            toBeReleased = allocatedCoreTeamFund.mul(CoreTeamVestingPercent).div(100);
            CoreTeamMilestoneReleased = 3;
        }
        else if(now <= tokenVestingStartedOn.add(360 days))
        {
            toBeReleased = allocatedCoreTeamFund.mul(CoreTeamVestingPercent).div(100);
            CoreTeamMilestoneReleased = 4;
        }
        /* If release request sent beyond 4 years , release remaining amount*/
        else if(now > tokenVestingStartedOn.add(360 days) && CoreTeamMilestoneReleased != 4)
        {
            toBeReleased = allocatedCoreTeamFund.sub(releasedCoreTeamFund);
            CoreTeamMilestoneReleased = 4;
        }
        else
        {
            revert();
        }
        
        if(toBeReleased > 0)
        {
            releasedCoreTeamFund = releasedCoreTeamFund.add(toBeReleased);
            _transfer(address(this),CoreTeamFundReceiver,toBeReleased);
            
            emit CoreTeamFundReleased(CoreTeamFundReceiver,toBeReleased,CoreTeamMilestoneReleased);
            
            return true;
        }
        else
        {
            revert();
        }
        
    }
}