/**
 * Source Code first verified at https://etherscan.io on Wednesday, May 1, 2019
 (UTC) */

pragma solidity ^0.4.18;
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() {
        owner = msg.sender;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract usingEthereumV2Erc20Consts {
    uint constant TOKEN_DECIMALS = 18;
    uint8 constant TOKEN_DECIMALS_UINT8 = 18;
    uint constant TOKEN_DECIMAL_MULTIPLIER = 10 ** TOKEN_DECIMALS;

    uint constant TEAM_TOKENS =   0 * TOKEN_DECIMAL_MULTIPLIER;
    uint constant BOUNTY_TOKENS = 0 * TOKEN_DECIMAL_MULTIPLIER;
    uint constant PREICO_TOKENS = 0 * TOKEN_DECIMAL_MULTIPLIER;
    uint constant MINIMAL_PURCHASE = 0.00001 ether;

    address constant TEAM_ADDRESS = 0x78cd8f794686ee8f6644447e961ef52776edf0cb;
    address constant BOUNTY_ADDRESS = 0xff823588500d3ecd7777a1cfa198958df4deea11;
    address constant PREICO_ADDRESS = 0xff823588500d3ecd7777a1cfa198958df4deea11;
    address constant COLD_WALLET = 0x439415b03708bde585856b46666f34b65af6a5c3;

    string constant TOKEN_NAME = "Ethereum V2 Erc20";
    bytes32 constant TOKEN_SYMBOL = "ETH20";
}
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping (address => uint256) balances;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) returns (bool) {
        require(_to != address(0));

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) allowed;


    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
        require(_to != address(0));

        var _allowance = allowed[_from][msg.sender];

        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
        // require (_value <= _allowance);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) returns (bool) {

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     */
    function increaseApproval(address _spender, uint _addedValue) returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        }
        else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {
    event Mint(address indexed to, uint256 amount);

    event MintFinished();

    bool public mintingFinished = false;


    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(0x0, _to, _amount);
        return true;
    }

    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting() onlyOwner returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }
}

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is StandardToken {

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value > 0);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }
}

contract EthereumV2Erc20 is usingEthereumV2Erc20Consts, MintableToken, BurnableToken {
    /**
     * @dev Pause token transfer. After successfully finished crowdsale it becomes true.
     */
    bool public paused = false;
    /**
     * @dev Accounts who can transfer token even if paused. Works only during crowdsale.
     */
    mapping(address => bool) excluded;

    function name() constant public returns (string _name) {
        return TOKEN_NAME;
    }

    function symbol() constant public returns (bytes32 _symbol) {
        return TOKEN_SYMBOL;
    }

    function decimals() constant public returns (uint8 _decimals) {
        return TOKEN_DECIMALS_UINT8;
    }

    function crowdsaleFinished() onlyOwner {
        paused = false;
        finishMinting();
    }

    function addExcluded(address _toExclude) onlyOwner {
        excluded[_toExclude] = true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
        require(!paused || excluded[_from]);
        return super.transferFrom(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) returns (bool) {
        require(!paused || excluded[msg.sender]);
        return super.transfer(_to, _value);
    }

    /**
     * @dev Burn tokens from the specified address.
     * @param _from     address The address which you want to burn tokens from.
     * @param _value    uint    The amount of tokens to be burned.
     */
    function burnFrom(address _from, uint256 _value) returns (bool) {
        require(_value > 0);
        var allowance = allowed[_from][msg.sender];
        balances[_from] = balances[_from].sub(_value);
        totalSupply = totalSupply.sub(_value);
        allowed[_from][msg.sender] = allowance.sub(_value);
        Burn(_from, _value);
        return true;
    }
}
contract EthereumV2Erc20RateProviderI {
    /**
     * @dev Calculate actual rate using the specified parameters.
     * @param buyer     Investor (buyer) address.
     * @param totalSold Amount of sold tokens.
     * @param amountWei Amount of wei to purchase.
     * @return ETH to Token rate.
     */
    function getRate(address buyer, uint totalSold, uint amountWei) public constant returns (uint);

    /**
     * @dev rate scale (or divider), to support not integer rates.
     * @return Rate divider.
     */
    function getRateScale() public constant returns (uint);

    /**
     * @return Absolute base rate.
     */
    function getBaseRate() public constant returns (uint);
}

contract EthereumV2Erc20RateProvider is usingEthereumV2Erc20Consts, EthereumV2Erc20RateProviderI, Ownable {
    // rate calculate accuracy
    uint constant RATE_SCALE = 1;
    // Start time: Human time (GMT): Sunday, May 5, 2019 5:05:05 PM
    // End time: Human time (GMT): Saturday, May 5, 2029 5:05:05 PM
    
    // Guaranteed by 100% ETH. 
    // Contract to buy 100% token to burn off. 
    // Service fee 2%. 98% of the funds were bought back by all contracts and then burned.
    
    uint constant STEP_9 =         50000 * TOKEN_DECIMAL_MULTIPLIER;           // Start from  0.00001      to  1.49 ETH         Price 100000 ETH20 = 1 ETH
    uint constant STEP_8 =        150000 * TOKEN_DECIMAL_MULTIPLIER;         // Continue the next 0.5        - 2.99 ETH         Price  99000 ETH20 = 1 ETH
    uint constant STEP_7 =       1150000 * TOKEN_DECIMAL_MULTIPLIER;         // Continue the next 1.5       - 19.99 ETH         Price  90000 ETH20 = 1 ETH
    uint constant STEP_6 =      11150000 * TOKEN_DECIMAL_MULTIPLIER;        // Continue the next 11.5      - 199.99 ETH         Price  50000 ETH20 = 1 ETH
    uint constant STEP_5 =     111150000 * TOKEN_DECIMAL_MULTIPLIER;       // Continue the next 111.5     - 1999.99 ETH         Price  10000 ETH20 = 1 ETH
    uint constant STEP_4 =    1111150000 * TOKEN_DECIMAL_MULTIPLIER;      // Continue the next 1111.5    - 19999.99 ETH         Price   1000 ETH20 = 1 ETH
    uint constant STEP_3 =   11111150000 * TOKEN_DECIMAL_MULTIPLIER;     // Continue the next 11111.5   - 199999.99 ETH         Price    100 ETH20 = 1 ETH
    uint constant STEP_2 =  111111150000 * TOKEN_DECIMAL_MULTIPLIER;    // Continue the next 111111.5  - 1999999.99 ETH         Price     10 ETH20 = 1 ETH
    uint constant STEP_1 = 2000000000000 * TOKEN_DECIMAL_MULTIPLIER;   // Continue the next 1111111.99 -19999999.99 ETH         Price      1 ETH20 = 1 ETH
    
    uint constant RATE_9 =   100000 * RATE_SCALE; // Price increases 0 %                       // Redemption price 98 %  Buy back burned
    uint constant RATE_8 =    99000 * RATE_SCALE; // Price increases 1 %                       // Redemption price 98 %  Buy back burned
    uint constant RATE_7 =    90000 * RATE_SCALE; // Price increases 10 %                      // Redemption price 98 %  Buy back burned
    uint constant RATE_6 =    50000 * RATE_SCALE; // Price increases 100 % Increase by 2 times // Redemption price 98 %  Buy back burned
    uint constant RATE_5 =    10000 * RATE_SCALE; // Price increases by 10 times               // Redemption price 98 %  Buy back burned
    uint constant RATE_4 =    1000 * RATE_SCALE; // Price Increase by   100 times              // Redemption price 98 %  Buy back burned
    uint constant RATE_3 =    100 * RATE_SCALE; // Price increase by    1000  times            // Redemption price 98 %  Buy back burned
    uint constant RATE_2 =    10 * RATE_SCALE; // Price increase by     10000 times            // Redemption price 98 %  Buy back burned
    uint constant RATE_1 =    1 * RATE_SCALE; // Price increase by      100000 times            // Redemption price 98 %  Buy back burned
    
    
    uint constant BASE_RATE = 0 * RATE_SCALE;                                             // 1 ETH = 1 ETH20.  Standard price 0 %

    struct ExclusiveRate {
        // be careful, accuracies this about 1 minutes
        uint32 workUntil;
        // exclusive rate or 0
        uint rate;
        // rate bonus percent, which will be divided by 1000 or 0
        uint16 bonusPercent1000;
        // flag to check, that record exists
        bool exists;
    }

    mapping(address => ExclusiveRate) exclusiveRate;

    function getRateScale() public constant returns (uint) {
        return RATE_SCALE;
    }

    function getBaseRate() public constant returns (uint) {
        return BASE_RATE;
    }
    

    function getRate(address buyer, uint totalSold, uint amountWei) public constant returns (uint) {
        uint rate;
        // apply sale
        if (totalSold < STEP_9) {
            rate = RATE_9;
        }
        else if (totalSold < STEP_8) {
            rate = RATE_8;
        }
        else if (totalSold < STEP_7) {
            rate = RATE_7;
        }
        else if (totalSold < STEP_6) {
            rate = RATE_6;
        }
        else if (totalSold < STEP_5) {
            rate = RATE_5;
        }
        else if (totalSold < STEP_4) {
            rate = RATE_4;
        }
        else if (totalSold < STEP_3) {
            rate = RATE_3;
        }
        else if (totalSold < STEP_2) {
            rate = RATE_2;
        }
        else if (totalSold < STEP_1) {
            rate = RATE_1;
        }
        else {
            rate = BASE_RATE;
        }
    // apply bonus for amount
        if (amountWei >= 100000 ether) {
            rate += rate * 0 / 100;
        }
        else if (amountWei >= 10000 ether) {
            rate += rate * 0 / 100;
        }
        else if (amountWei >= 1000 ether) {
            rate += rate * 0 / 100;
        }
        else if (amountWei >= 100 ether) {
            rate += rate * 0 / 100;
        }
        else if (amountWei >= 10 ether) {
            rate += rate * 0 / 100;
        }
        else if (amountWei >= 1 ether) {
            rate += rate * 0 / 1000;
        }

        ExclusiveRate memory eRate = exclusiveRate[buyer];
        if (eRate.exists && eRate.workUntil >= now) {
            if (eRate.rate != 0) {
                rate = eRate.rate;
            }
            rate += rate * eRate.bonusPercent1000 / 1000;
        }
        return rate;
    }

    function setExclusiveRate(address _investor, uint _rate, uint16 _bonusPercent1000, uint32 _workUntil) onlyOwner {
        exclusiveRate[_investor] = ExclusiveRate(_workUntil, _rate, _bonusPercent1000, true);
    }

    function removeExclusiveRate(address _investor) onlyOwner {
        delete exclusiveRate[_investor];
    }
}
/**
 * @title Crowdsale 
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 *
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet 
 * as they arrive.
 */
contract Crowdsale {
    using SafeMath for uint;

    // The token being sold
    MintableToken public token;

    // start and end timestamps where investments are allowed (both inclusive)
    uint32 internal startTime;
    uint32 internal endTime;

    // address where funds are collected
    address public wallet;

    // amount of raised money in wei
    uint public weiRaised;

    /**
     * @dev Amount of already sold tokens.
     */
    uint public soldTokens;

    /**
     * @dev Maximum amount of tokens to mint.
     */
    uint internal hardCap;

    /**
     * event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint value, uint amount);

    function Crowdsale(uint _startTime, uint _endTime, uint _hardCap, address _wallet) {
        require(_endTime >= _startTime);
        require(_wallet != 0x0);
        require(_hardCap > 0);

        token = createTokenContract();
        startTime = uint32(_startTime);
        endTime = uint32(_endTime);
        hardCap = _hardCap;
        wallet = _wallet;
    }

    // creates the token to be sold.
    // override this method to have crowdsale of a specific mintable token.
    function createTokenContract() internal returns (MintableToken) {
        return new MintableToken();
    }

    /**
     * @dev this method might be overridden for implementing any sale logic.
     * @return Actual rate.
     */
    function getRate(uint amount) internal constant returns (uint);

    function getBaseRate() internal constant returns (uint);

    /**
     * @dev rate scale (or divider), to support not integer rates.
     * @return Rate divider.
     */
    function getRateScale() internal constant returns (uint) {
        return 1;
    }

    // fallback function can be used to buy tokens
    function() payable {
        buyTokens(msg.sender, msg.value);
    }

    // low level token purchase function
    function buyTokens(address beneficiary, uint amountWei) internal {
        require(beneficiary != 0x0);

        // total minted tokens
        uint totalSupply = token.totalSupply();

        // actual token minting rate (with considering bonuses and discounts)
        uint actualRate = getRate(amountWei);
        uint rateScale = getRateScale();

        require(validPurchase(amountWei, actualRate, totalSupply));

        // calculate token amount to be created
        uint tokens = amountWei.mul(actualRate).div(rateScale);

        // update state
        weiRaised = weiRaised.add(amountWei);
        soldTokens = soldTokens.add(tokens);

        token.mint(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, amountWei, tokens);

        forwardFunds(amountWei);
    }

    // send ether to the fund collection wallet
    // override to create custom fund forwarding mechanisms
    function forwardFunds(uint amountWei) internal {
        wallet.transfer(amountWei);
    }

    /**
     * @dev Check if the specified purchase is valid.
     * @return true if the transaction can buy tokens
     */
    function validPurchase(uint _amountWei, uint _actualRate, uint _totalSupply) internal constant returns (bool) {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = _amountWei != 0;
        bool hardCapNotReached = _totalSupply <= hardCap;

        return withinPeriod && nonZeroPurchase && hardCapNotReached;
    }

    /**
     * @dev Because of discount hasEnded might be true, but validPurchase returns false.
     * @return true if crowdsale event has ended
     */
    function hasEnded() public constant returns (bool) {
        return now > endTime || token.totalSupply() > hardCap;
    }

    /**
     * @return true if crowdsale event has started
     */
    function hasStarted() public constant returns (bool) {
        return now >= startTime;
    }
}

contract FinalizableCrowdsale is Crowdsale, Ownable {
    using SafeMath for uint256;

    bool public isFinalized = false;

    event Finalized();

    function FinalizableCrowdsale(uint _startTime, uint _endTime, uint _hardCap, address _wallet)
            Crowdsale(_startTime, _endTime, _hardCap, _wallet) {
    }

    /**
     * @dev Must be called after crowdsale ends, to do some extra finalization
     * work. Calls the contract's finalization function.
     */
    function finalize() onlyOwner notFinalized {
        require(hasEnded());

        finalization();
        Finalized();

        isFinalized = true;
    }

    /**
     * @dev Can be overriden to add finalization logic. The overriding function
     * should call super.finalization() to ensure the chain of finalization is
     * executed entirely.
     */
    function finalization() internal {
    }

    modifier notFinalized() {
        require(!isFinalized);
        _;
    }
}

contract EthereumV2Erc20Crowdsale is usingEthereumV2Erc20Consts, FinalizableCrowdsale {
    EthereumV2Erc20RateProviderI public rateProvider;

    function EthereumV2Erc20Crowdsale(
            uint _startTime,
            uint _endTime,
            uint _hardCapTokens
    )
            FinalizableCrowdsale(_startTime, _endTime, _hardCapTokens * TOKEN_DECIMAL_MULTIPLIER, COLD_WALLET) {

        token.mint(TEAM_ADDRESS, TEAM_TOKENS);
        token.mint(BOUNTY_ADDRESS, BOUNTY_TOKENS);
        token.mint(PREICO_ADDRESS, PREICO_TOKENS);

        EthereumV2Erc20(token).addExcluded(TEAM_ADDRESS);
        EthereumV2Erc20(token).addExcluded(BOUNTY_ADDRESS);
        EthereumV2Erc20(token).addExcluded(PREICO_ADDRESS);

        EthereumV2Erc20RateProvider provider = new EthereumV2Erc20RateProvider();
        provider.transferOwnership(owner);
        rateProvider = provider;
    }

    /**
     * @dev override token creation to integrate with MyWill token.
     */
    function createTokenContract() internal returns (MintableToken) {
        return new EthereumV2Erc20();
    }

    /**
     * @dev override getRate to integrate with rate provider.
     */
    function getRate(uint _value) internal constant returns (uint) {
        return rateProvider.getRate(msg.sender, soldTokens, _value);
    }

    function getBaseRate() internal constant returns (uint) {
        return rateProvider.getRate(msg.sender, soldTokens, MINIMAL_PURCHASE);
    }

    /**
     * @dev override getRateScale to integrate with rate provider.
     */
    function getRateScale() internal constant returns (uint) {
        return rateProvider.getRateScale();
    }

    /**
     * @dev Admin can set new rate provider.
     * @param _rateProviderAddress New rate provider.
     */
    function setRateProvider(address _rateProviderAddress) onlyOwner {
        require(_rateProviderAddress != 0);
        rateProvider = EthereumV2Erc20RateProviderI(_rateProviderAddress);
    }

    /**
     * @dev Admin can move end time.
     * @param _endTime New end time.
     */
    function setEndTime(uint _endTime) onlyOwner notFinalized {
        require(_endTime > startTime);
        endTime = uint32(_endTime);
    }

    function setHardCap(uint _hardCapTokens) onlyOwner notFinalized {
        require(_hardCapTokens * TOKEN_DECIMAL_MULTIPLIER > hardCap);
        hardCap = _hardCapTokens * TOKEN_DECIMAL_MULTIPLIER;
    }

    function setStartTime(uint _startTime) onlyOwner notFinalized {
        require(_startTime < endTime);
        startTime = uint32(_startTime);
    }

    function addExcluded(address _address) onlyOwner notFinalized {
        EthereumV2Erc20(token).addExcluded(_address);
    }

    function validPurchase(uint _amountWei, uint _actualRate, uint _totalSupply) internal constant returns (bool) {
        if (_amountWei < MINIMAL_PURCHASE) {
            return false;
        }
        return super.validPurchase(_amountWei, _actualRate, _totalSupply);
    }

    function finalization() internal {
        super.finalization();
        token.finishMinting();
        EthereumV2Erc20(token).crowdsaleFinished();
        token.transferOwnership(owner);
    }
}


/**
 * @title Proxy
 * @dev Implements delegation of calls to other contracts, with proper
 * forwarding of return values and bubbling of failures.
 * It defines a fallback function that delegates all calls to the address
 * returned by the abstract _implementation() internal function.
 */
contract Proxy {
    /**
     * @dev Fallback function.
     * Implemented entirely in `_fallback`.
     */
    function () payable external {
        _fallback();
    }

    /**
     * @return The Address of the implementation.
     */
    function _implementation() internal view returns (address);

    /**
     * @dev Delegates execution to an implementation contract.
     * This is a low level function that doesn't return to its internal call site.
     * It will return to the external caller whatever the implementation returns.
     * @param implementation Address to delegate.
     */
    function _delegate(address implementation) internal {
        assembly {
        // Copy msg.data. We take full control of memory in this inline assembly
        // block because it will not return to Solidity code. We overwrite the
        // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize)

        // Call the implementation.
        // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)

        // Copy the returned data.
            returndatacopy(0, 0, returndatasize)

            switch result
            // delegatecall returns 0 on error.
            case 0 { revert(0, returndatasize) }
            default { return(0, returndatasize) }
        }
    }

    /**
     * @dev Function that is run as the first thing in the fallback function.
     * Can be redefined in derived contracts to add functionality.
     * Redefinitions must call super._willFallback().
     */
    function _willFallback() internal {
    }

    /**
     * @dev fallback implementation.
     * Extracted to enable manual triggering.
     */
    function _fallback() internal {
        _willFallback();
        _delegate(_implementation());
    }
}

// File: contracts/zeppelin/AddressUtils.sol

/**
 * Utility library of inline functions on addresses
 */
library AddressUtils {

    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param addr address to check
     * @return whether the target address is a contract
     */
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solium-disable-next-line security/no-inline-assembly
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

}




contract Token {
    bytes32 public standard;
    bytes32 public name;
    bytes32 public symbol;
    uint256 public totalSupply;
    uint8 public decimals;
    bool public allowTransactions;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    function transfer(address _to, uint256 _value) returns (bool success);
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
}

contract Promotion {
    mapping(address => address[]) public referrals; // mapping of affiliate address to referral addresses
    mapping(address => address) public affiliates; // mapping of referrals addresses to affiliate addresses
    mapping(address => bool) public admins; // mapping of admin accounts
    string[] public affiliateList;
    address public owner;

    function setOwner(address newOwner);
    function setAdmin(address admin, bool isAdmin) public;
    function assignReferral (address affiliate, address referral) public;

    function getAffiliateCount() returns (uint);
    function getAffiliate(address refferal) public returns (address);
    function getReferrals(address affiliate) public returns (address[]);
}

contract TokenList {
    function isTokenInList(address tokenAddress) public constant returns (bool);
}


contract BTC20Exchange {
    function assert(bool assertion) {
        if (!assertion) throw;
    }
    function safeMul(uint a, uint b) returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeSub(uint a, uint b) returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) returns (uint) {
        uint c = a + b;
        assert(c>=a && c>=b);
        return c;
    }
    address public owner;
    mapping (address => uint256) public invalidOrder;

    event SetOwner(address indexed previousOwner, address indexed newOwner);
    modifier onlyOwner {
        assert(msg.sender == owner);
        _;
    }
    function setOwner(address newOwner) onlyOwner {
        SetOwner(owner, newOwner);
        owner = newOwner;
    }
    function getOwner() returns (address out) {
        return owner;
    }
    function invalidateOrdersBefore(address user, uint256 nonce) onlyAdmin {
        if (nonce < invalidOrder[user]) throw;
        invalidOrder[user] = nonce;
    }

    mapping (address => mapping (address => uint256)) public tokens; //mapping of token addresses to mapping of account balances

    mapping (address => bool) public admins;
    mapping (address => uint256) public lastActiveTransaction;
    mapping (bytes32 => uint256) public orderFills;
    address public feeAccount;
    uint256 public feeAffiliate; // percentage times (1 ether)
    uint256 public inactivityReleasePeriod;
    mapping (bytes32 => bool) public traded;
    mapping (bytes32 => bool) public withdrawn;
    uint256 public makerFee; // fraction * 1 ether
    uint256 public takerFee; // fraction * 1 ether
    uint256 public affiliateFee; // fraction as proportion of 1 ether
    uint256 public makerAffiliateFee; // wei deductible from makerFee
    uint256 public takerAffiliateFee; // wei deductible form takerFee

    mapping (address => address) public referrer;  // mapping of user addresses to their referrer addresses

    address public affiliateContract;
    address public tokenListContract;


    enum Errors {
        INVLID_PRICE,           // Order prices don't match
        INVLID_SIGNATURE,       // Signature is invalid
        TOKENS_DONT_MATCH,      // Maker/taker tokens don't match
        ORDER_ALREADY_FILLED,   // Order was already filled
        GAS_TOO_HIGH            // Too high gas fee
    }

    //event Order(address tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, uint256 expires, uint256 nonce, address user, uint8 v, bytes32 r, bytes32 s);
    //event Cancel(address tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, uint256 expires, uint256 nonce, address user, uint8 v, bytes32 r, bytes32 s);
    event Trade(
        address takerTokenBuy, uint256 takerAmountBuy,
        address takerTokenSell, uint256 takerAmountSell,
        address maker, address indexed taker,
        uint256 makerFee, uint256 takerFee,
        uint256 makerAmountTaken, uint256 takerAmountTaken,
        bytes32 indexed makerOrderHash, bytes32 indexed takerOrderHash
    );
    event Deposit(address indexed token, address indexed user, uint256 amount, uint256 balance, address indexed referrerAddress);
    event Withdraw(address indexed token, address indexed user, uint256 amount, uint256 balance, uint256 withdrawFee);
    event FeeChange(uint256 indexed makerFee, uint256 indexed takerFee, uint256 indexed affiliateFee);
    //event AffiliateFeeChange(uint256 newAffiliateFee);
    event LogError(uint8 indexed errorId, bytes32 indexed makerOrderHash, bytes32 indexed takerOrderHash);
    event CancelOrder(
        bytes32 indexed cancelHash,
        bytes32 indexed orderHash,
        address indexed user,
        address tokenSell,
        uint256 amountSell,
        uint256 cancelFee
    );

    function setInactivityReleasePeriod(uint256 expiry) onlyAdmin returns (bool success) {
        if (expiry > 1000000) throw;
        inactivityReleasePeriod = expiry;
        return true;
    }

    function Exchange(address feeAccount_, uint256 makerFee_, uint256 takerFee_, uint256 affiliateFee_, address affiliateContract_, address tokenListContract_) {
        owner = msg.sender;
        feeAccount = feeAccount_;
        inactivityReleasePeriod = 100000;
        makerFee = makerFee_;
        takerFee = takerFee_;
        affiliateFee = affiliateFee_;



        makerAffiliateFee = safeMul(makerFee, affiliateFee_) / (1 ether);
        takerAffiliateFee = safeMul(takerFee, affiliateFee_) / (1 ether);

        affiliateContract = affiliateContract_;
        tokenListContract = tokenListContract_;
    }

    function setFees(uint256 makerFee_, uint256 takerFee_, uint256 affiliateFee_) onlyOwner {
        require(makerFee_ < 10 finney && takerFee_ < 10 finney);
        require(affiliateFee_ > affiliateFee);
        makerFee = makerFee_;
        takerFee = takerFee_;
        affiliateFee = affiliateFee_;
        makerAffiliateFee = safeMul(makerFee, affiliateFee_) / (1 ether);
        takerAffiliateFee = safeMul(takerFee, affiliateFee_) / (1 ether);

        FeeChange(makerFee, takerFee, affiliateFee_);
    }

    function setAdmin(address admin, bool isAdmin) onlyOwner {
        admins[admin] = isAdmin;
    }

    modifier onlyAdmin {
        if (msg.sender != owner && !admins[msg.sender]) throw;
        _;
    }

    function() external {
        throw;
    }

    function depositToken(address token, uint256 amount, address referrerAddress) {
        //require(EthermiumTokenList(tokenListContract).isTokenInList(token));
        if (referrerAddress == msg.sender) referrerAddress = address(0);
        if (referrer[msg.sender] == address(0x0))   {
            if (referrerAddress != address(0x0) && Promotion(affiliateContract).getAffiliate(msg.sender) == address(0))
            {
                referrer[msg.sender] = referrerAddress;
                Promotion(affiliateContract).assignReferral(referrerAddress, msg.sender);
            }
            else
            {
                referrer[msg.sender] = Promotion(affiliateContract).getAffiliate(msg.sender);
            }
        }
        tokens[token][msg.sender] = safeAdd(tokens[token][msg.sender], amount);
        lastActiveTransaction[msg.sender] = block.number;
        if (!Token(token).transferFrom(msg.sender, this, amount)) throw;
        Deposit(token, msg.sender, amount, tokens[token][msg.sender], referrer[msg.sender]);
    }

    function deposit(address referrerAddress) payable {
        if (referrerAddress == msg.sender) referrerAddress = address(0);
        if (referrer[msg.sender] == address(0x0))   {
            if (referrerAddress != address(0x0) && Promotion(affiliateContract).getAffiliate(msg.sender) == address(0))
            {
                referrer[msg.sender] = referrerAddress;
                Promotion(affiliateContract).assignReferral(referrerAddress, msg.sender);
            }
            else
            {
                referrer[msg.sender] = Promotion(affiliateContract).getAffiliate(msg.sender);
            }
        }
        tokens[address(0)][msg.sender] = safeAdd(tokens[address(0)][msg.sender], msg.value);
        lastActiveTransaction[msg.sender] = block.number;
        Deposit(address(0), msg.sender, msg.value, tokens[address(0)][msg.sender], referrer[msg.sender]);
    }

    function withdraw(address token, uint256 amount) returns (bool success) {
        if (safeSub(block.number, lastActiveTransaction[msg.sender]) < inactivityReleasePeriod) throw;
        if (tokens[token][msg.sender] < amount) throw;
        tokens[token][msg.sender] = safeSub(tokens[token][msg.sender], amount);
        if (token == address(0)) {
            if (!msg.sender.send(amount)) throw;
        } else {
            if (!Token(token).transfer(msg.sender, amount)) throw;
        }
        Withdraw(token, msg.sender, amount, tokens[token][msg.sender], 0);
    }

    function adminWithdraw(address token, uint256 amount, address user, uint256 nonce, uint8 v, bytes32 r, bytes32 s, uint256 feeWithdrawal) onlyAdmin returns (bool success) {
        bytes32 hash = keccak256(this, token, amount, user, nonce);
        if (withdrawn[hash]) throw;
        withdrawn[hash] = true;
        if (ecrecover(keccak256("\x19Ethereum Signed Message:\n32", hash), v, r, s) != user) throw;
        if (feeWithdrawal > 50 finney) feeWithdrawal = 50 finney;
        if (tokens[token][user] < amount) throw;
        tokens[token][user] = safeSub(tokens[token][user], amount);
        tokens[address(0)][user] = safeSub(tokens[address(0x0)][user], feeWithdrawal);
        //tokens[token][feeAccount] = safeAdd(tokens[token][feeAccount], safeMul(feeWithdrawal, amount) / 1 ether);
        tokens[address(0)][feeAccount] = safeAdd(tokens[address(0)][feeAccount], feeWithdrawal);

        //amount = safeMul((1 ether - feeWithdrawal), amount) / 1 ether;
        if (token == address(0)) {
            if (!user.send(amount)) throw;
        } else {
            if (!Token(token).transfer(user, amount)) throw;
        }
        lastActiveTransaction[user] = block.number;
        Withdraw(token, user, amount, tokens[token][user], feeWithdrawal);
    }

    function balanceOf(address token, address user) constant returns (uint256) {
        return tokens[token][user];
    }

    struct OrderPair {
        uint256 makerAmountBuy;
        uint256 makerAmountSell;
        uint256 makerNonce;
        uint256 takerAmountBuy;
        uint256 takerAmountSell;
        uint256 takerNonce;
        uint256 takerGasFee;

        address makerTokenBuy;
        address makerTokenSell;
        address maker;
        address takerTokenBuy;
        address takerTokenSell;
        address taker;

        bytes32 makerOrderHash;
        bytes32 takerOrderHash;
    }

    struct TradeValues {
        uint256 qty;
        uint256 invQty;
        uint256 makerAmountTaken;
        uint256 takerAmountTaken;
        address makerReferrer;
        address takerReferrer;
    }




    function trade(
        uint8[2] v,
        bytes32[4] rs,
        uint256[7] tradeValues,
        address[6] tradeAddresses
    ) onlyAdmin returns (uint filledTakerTokenAmount)
    {

        /* tradeValues
          [0] makerAmountBuy
          [1] makerAmountSell
          [2] makerNonce
          [3] takerAmountBuy
          [4] takerAmountSell
          [5] takerNonce
          [6] takerGasFee

          tradeAddresses
          [0] makerTokenBuy
          [1] makerTokenSell
          [2] maker
          [3] takerTokenBuy
          [4] takerTokenSell
          [5] taker
        */

        OrderPair memory t  = OrderPair({
            makerAmountBuy  : tradeValues[0],
            makerAmountSell : tradeValues[1],
            makerNonce      : tradeValues[2],
            takerAmountBuy  : tradeValues[3],
            takerAmountSell : tradeValues[4],
            takerNonce      : tradeValues[5],
            takerGasFee     : tradeValues[6],

            makerTokenBuy   : tradeAddresses[0],
            makerTokenSell  : tradeAddresses[1],
            maker           : tradeAddresses[2],
            takerTokenBuy   : tradeAddresses[3],
            takerTokenSell  : tradeAddresses[4],
            taker           : tradeAddresses[5],

            makerOrderHash  : keccak256(this, tradeAddresses[0], tradeValues[0], tradeAddresses[1], tradeValues[1], tradeValues[2], tradeAddresses[2]),
            takerOrderHash  : keccak256(this, tradeAddresses[3], tradeValues[3], tradeAddresses[4], tradeValues[4], tradeValues[5], tradeAddresses[5])
        });

        //bytes32 makerOrderHash = keccak256(this, tradeAddresses[0], tradeValues[0], tradeAddresses[1], tradeValues[1], tradeValues[2], tradeAddresses[2]);
        //bytes32 makerOrderHash = §
        if (ecrecover(keccak256("\x19Ethereum Signed Message:\n32", t.makerOrderHash), v[0], rs[0], rs[1]) != t.maker)
        {
            LogError(uint8(Errors.INVLID_SIGNATURE), t.makerOrderHash, t.takerOrderHash);
            return 0;
        }
        //bytes32 takerOrderHash = keccak256(this, tradeAddresses[3], tradeValues[3], tradeAddresses[4], tradeValues[4], tradeValues[5], tradeAddresses[5]);
        //bytes32 takerOrderHash = keccak256(this, t.takerTokenBuy, t.takerAmountBuy, t.takerTokenSell, t.takerAmountSell, t.takerNonce, t.taker);
        if (ecrecover(keccak256("\x19Ethereum Signed Message:\n32", t.takerOrderHash), v[1], rs[2], rs[3]) != t.taker)
        {
            LogError(uint8(Errors.INVLID_SIGNATURE), t.makerOrderHash, t.takerOrderHash);
            return 0;
        }

        if (t.makerTokenBuy != t.takerTokenSell || t.makerTokenSell != t.takerTokenBuy)
        {
            LogError(uint8(Errors.TOKENS_DONT_MATCH), t.makerOrderHash, t.takerOrderHash);
            return 0;
        } // tokens don't match

        if (t.takerGasFee > 1 finney)
        {
            LogError(uint8(Errors.GAS_TOO_HIGH), t.makerOrderHash, t.takerOrderHash);
            return 0;
        } // takerGasFee too high



        if (!(
        (t.makerTokenBuy != address(0x0) && safeMul(t.makerAmountSell, 5 finney) / t.makerAmountBuy >= safeMul(t.takerAmountBuy, 5 finney) / t.takerAmountSell)
        ||
        (t.makerTokenBuy == address(0x0) && safeMul(t.makerAmountBuy, 5 finney) / t.makerAmountSell <= safeMul(t.takerAmountSell, 5 finney) / t.takerAmountBuy)
        ))
        {
            LogError(uint8(Errors.INVLID_PRICE), t.makerOrderHash, t.takerOrderHash);
            return 0; // prices don't match
        }

        TradeValues memory tv = TradeValues({
            qty                 : 0,
            invQty              : 0,
            makerAmountTaken    : 0,
            takerAmountTaken    : 0,
            makerReferrer       : referrer[t.maker],
            takerReferrer       : referrer[t.taker]
        });

        if (tv.makerReferrer == address(0x0)) tv.makerReferrer = feeAccount;
        if (tv.takerReferrer == address(0x0)) tv.takerReferrer = feeAccount;



        // maker buy, taker sell
        if (t.makerTokenBuy != address(0x0))
        {


            tv.qty = min(safeSub(t.makerAmountBuy, orderFills[t.makerOrderHash]), safeSub(t.takerAmountSell, safeMul(orderFills[t.takerOrderHash], t.takerAmountSell) / t.takerAmountBuy));
            if (tv.qty == 0)
            {
                LogError(uint8(Errors.ORDER_ALREADY_FILLED), t.makerOrderHash, t.takerOrderHash);
                return 0;
            }

            tv.invQty = safeMul(tv.qty, t.makerAmountSell) / t.makerAmountBuy;

            tokens[t.makerTokenSell][t.maker]           = safeSub(tokens[t.makerTokenSell][t.maker],           tv.invQty);
            tv.makerAmountTaken                         = safeSub(tv.qty, safeMul(tv.qty, makerFee) / (1 ether));
            tokens[t.makerTokenBuy][t.maker]            = safeAdd(tokens[t.makerTokenBuy][t.maker],            tv.makerAmountTaken);
            tokens[t.makerTokenBuy][tv.makerReferrer]   = safeAdd(tokens[t.makerTokenBuy][tv.makerReferrer],   safeMul(tv.qty,    makerAffiliateFee) / (1 ether));

            tokens[t.takerTokenSell][t.taker]           = safeSub(tokens[t.takerTokenSell][t.taker],           tv.qty);
            tv.takerAmountTaken                         = safeSub(safeSub(tv.invQty, safeMul(tv.invQty, takerFee) / (1 ether)), safeMul(tv.invQty, t.takerGasFee) / (1 ether));
            tokens[t.takerTokenBuy][t.taker]            = safeAdd(tokens[t.takerTokenBuy][t.taker],            tv.takerAmountTaken);
            tokens[t.takerTokenBuy][tv.takerReferrer]   = safeAdd(tokens[t.takerTokenBuy][tv.takerReferrer],   safeMul(tv.invQty, takerAffiliateFee) / (1 ether));

            tokens[t.makerTokenBuy][feeAccount]     = safeAdd(tokens[t.makerTokenBuy][feeAccount],      safeMul(tv.qty,    safeSub(makerFee, makerAffiliateFee)) / (1 ether));
            tokens[t.takerTokenBuy][feeAccount]     = safeAdd(tokens[t.takerTokenBuy][feeAccount],      safeAdd(safeMul(tv.invQty, safeSub(takerFee, takerAffiliateFee)) / (1 ether), safeMul(tv.invQty, t.takerGasFee) / (1 ether)));


            orderFills[t.makerOrderHash]            = safeAdd(orderFills[t.makerOrderHash], tv.qty);
            orderFills[t.takerOrderHash]            = safeAdd(orderFills[t.takerOrderHash], safeMul(tv.qty, t.takerAmountBuy) / t.takerAmountSell);
            lastActiveTransaction[t.maker]          = block.number;
            lastActiveTransaction[t.taker]          = block.number;

            Trade(
                t.takerTokenBuy, tv.qty,
                t.takerTokenSell, tv.invQty,
                t.maker, t.taker,
                makerFee, takerFee,
                tv.makerAmountTaken , tv.takerAmountTaken,
                t.makerOrderHash, t.takerOrderHash
            );
            return tv.qty;
        }
        // maker sell, taker buy
        else
        {

            tv.qty = min(safeSub(t.makerAmountSell,  safeMul(orderFills[t.makerOrderHash], t.makerAmountSell) / t.makerAmountBuy), safeSub(t.takerAmountBuy, orderFills[t.takerOrderHash]));
            if (tv.qty == 0)
            {
                LogError(uint8(Errors.ORDER_ALREADY_FILLED), t.makerOrderHash, t.takerOrderHash);
                return 0;
            }

            tv.invQty = safeMul(tv.qty, t.makerAmountBuy) / t.makerAmountSell;

            tokens[t.makerTokenSell][t.maker]           = safeSub(tokens[t.makerTokenSell][t.maker],           tv.qty);
            tv.makerAmountTaken                         = safeSub(tv.invQty, safeMul(tv.invQty, makerFee) / (1 ether));
            tokens[t.makerTokenBuy][t.maker]            = safeAdd(tokens[t.makerTokenBuy][t.maker],            tv.makerAmountTaken);
            tokens[t.makerTokenBuy][tv.makerReferrer]   = safeAdd(tokens[t.makerTokenBuy][tv.makerReferrer],   safeMul(tv.invQty, makerAffiliateFee) / (1 ether));

            tokens[t.takerTokenSell][t.taker]           = safeSub(tokens[t.takerTokenSell][t.taker],           tv.invQty);
            tv.takerAmountTaken                         = safeSub(safeSub(tv.qty,    safeMul(tv.qty, takerFee) / (1 ether)), safeMul(tv.qty, t.takerGasFee) / (1 ether));
            tokens[t.takerTokenBuy][t.taker]            = safeAdd(tokens[t.takerTokenBuy][t.taker],            tv.takerAmountTaken);
            tokens[t.takerTokenBuy][tv.takerReferrer]   = safeAdd(tokens[t.takerTokenBuy][tv.takerReferrer],   safeMul(tv.qty,    takerAffiliateFee) / (1 ether));

            tokens[t.makerTokenBuy][feeAccount]     = safeAdd(tokens[t.makerTokenBuy][feeAccount],      safeMul(tv.invQty, safeSub(makerFee, makerAffiliateFee)) / (1 ether));
            tokens[t.takerTokenBuy][feeAccount]     = safeAdd(tokens[t.takerTokenBuy][feeAccount],      safeAdd(safeMul(tv.qty,    safeSub(takerFee, takerAffiliateFee)) / (1 ether), safeMul(tv.qty, t.takerGasFee) / (1 ether)));

            orderFills[t.makerOrderHash]            = safeAdd(orderFills[t.makerOrderHash], tv.invQty);
            orderFills[t.takerOrderHash]            = safeAdd(orderFills[t.takerOrderHash], tv.qty); //safeMul(qty, tradeValues[takerAmountBuy]) / tradeValues[takerAmountSell]);

            lastActiveTransaction[t.maker]          = block.number;
            lastActiveTransaction[t.taker]          = block.number;

            Trade(
                t.takerTokenBuy, tv.qty,
                t.takerTokenSell, tv.invQty,
                t.maker, t.taker,
                makerFee, takerFee,
                tv.makerAmountTaken , tv.takerAmountTaken,
                t.makerOrderHash, t.takerOrderHash
            );
            return tv.qty;
        }
    }

    function batchOrderTrade(
        uint8[2][] v,
        bytes32[4][] rs,
        uint256[7][] tradeValues,
        address[6][] tradeAddresses
    )
    {
        for (uint i = 0; i < tradeAddresses.length; i++) {
            trade(
                v[i],
                rs[i],
                tradeValues[i],
                tradeAddresses[i]
            );
        }
    }

    function cancelOrder(
		/*
		[0] orderV
		[1] cancelV
		*/
	    uint8[2] v,

		/*
		[0] orderR
		[1] orderS
		[2] cancelR
		[3] cancelS
		*/
	    bytes32[4] rs,

		/*
		[0] orderAmountBuy
		[1] orderAmountSell
		[2] orderNonce
		[3] cancelNonce
		[4] cancelFee
		*/
		uint256[5] cancelValues,

		/*
		[0] orderTokenBuy
		[1] orderTokenSell
		[2] orderUser
		[3] cancelUser
		*/
		address[4] cancelAddresses
    ) public onlyAdmin {
        // Order values should be valid and signed by order owner
        bytes32 orderHash = keccak256(
	        this, cancelAddresses[0], cancelValues[0], cancelAddresses[1],
	        cancelValues[1], cancelValues[2], cancelAddresses[2]
        );
        require(ecrecover(keccak256("\x19Ethereum Signed Message:\n32", orderHash), v[0], rs[0], rs[1]) == cancelAddresses[2]);

        // Cancel action should be signed by cancel's initiator
        bytes32 cancelHash = keccak256(this, orderHash, cancelAddresses[3], cancelValues[3]);
        require(ecrecover(keccak256("\x19Ethereum Signed Message:\n32", cancelHash), v[1], rs[2], rs[3]) == cancelAddresses[3]);

        // Order owner should be same as cancel's initiator
        require(cancelAddresses[2] == cancelAddresses[3]);

        // Do not allow to cancel already canceled or filled orders
        require(orderFills[orderHash] != cancelValues[0]);

        // Limit cancel fee
        if (cancelValues[4] > 6 finney) {
            cancelValues[4] = 6 finney;
        }

        // Take cancel fee
        // This operation throw an error if fee amount is more than user balance
        tokens[address(0)][cancelAddresses[3]] = safeSub(tokens[address(0)][cancelAddresses[3]], cancelValues[4]);

        // Cancel order by filling it with amount buy value
        orderFills[orderHash] = cancelValues[0];

        // Emit cancel order
        CancelOrder(cancelHash, orderHash, cancelAddresses[3], cancelAddresses[1], cancelValues[1], cancelValues[4]);
    }

    function min(uint a, uint b) private pure returns (uint) {
        return a < b ? a : b;
    }
}




/**
 * @title Token
 * @dev Token interface necessary for working with tokens within the exchange contract.
 */
contract IToken {
    /// @return total amount of tokens
    function totalSupply() public constant returns (uint256 supply);

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    uint public decimals;
    string public name;
}

pragma solidity ^0.4.17;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library LSafeMath {

    uint256 constant WAD = 1 ether;
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        if (c / a == b)
            return c;
        revert();
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b > 0) { 
            uint256 c = a / b;
            return c;
        }
        revert();
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b <= a)
            return a - b;
        revert();
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        if (c >= a) 
            return c;
        revert();
    }

    function wmul(uint a, uint b) internal pure returns (uint256) {
        return add(mul(a, b), WAD / 2) / WAD;
    }

    function wdiv(uint a, uint b) internal pure returns (uint256) {
        return add(mul(a, WAD), b / 2) / b;
    }
}

/**
 * @title Coinchangex
 * @dev This is the main contract for the Coinchangex exchange.
 */
contract Tokenchange {
  
  using LSafeMath for uint;
  
  struct SpecialTokenBalanceFeeTake {
      bool exist;
      address token;
      uint256 balance;
      uint256 feeTake;
  }
  
  uint constant private MAX_SPECIALS = 10;

  /// Variables
  address public admin; // the admin address
  address public feeAccount; // the account that will receive fees
  uint public feeTake; // percentage times (1 ether)
  bool private depositingTokenFlag; // True when Token.transferFrom is being called from depositToken
  mapping (address => mapping (address => uint)) public tokens; // mapping of token addresses to mapping of account balances (token=0 means Ether)
  mapping (address => mapping (bytes32 => uint)) public orderFills; // mapping of user accounts to mapping of order hashes to uints (amount of order that has been filled)
  SpecialTokenBalanceFeeTake[] public specialFees;
  

  /// Logging Events
  event Cancel(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s);
  event Trade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, address get, address give);
  event Deposit(address token, address user, uint amount, uint balance);
  event Withdraw(address token, address user, uint amount, uint balance);

  /// This is a modifier for functions to check if the sending user address is the same as the admin user address.
  modifier isAdmin() {
      require(msg.sender == admin);
      _;
  }

  /// Constructor function. This is only called on contract creation.
  function Coinchangex(address admin_, address feeAccount_, uint feeTake_) public {
    admin = admin_;
    feeAccount = feeAccount_;
    feeTake = feeTake_;
    depositingTokenFlag = false;
  }

  /// The fallback function. Ether transfered into the contract is not accepted.
  function() public {
    revert();
  }

  /// Changes the official admin user address. Accepts Ethereum address.
  function changeAdmin(address admin_) public isAdmin {
    require(admin_ != address(0));
    admin = admin_;
  }

  /// Changes the account address that receives trading fees. Accepts Ethereum address.
  function changeFeeAccount(address feeAccount_) public isAdmin {
    feeAccount = feeAccount_;
  }

  /// Changes the fee on takes. Can only be changed to a value less than it is currently set at.
  function changeFeeTake(uint feeTake_) public isAdmin {
    // require(feeTake_ <= feeTake);
    feeTake = feeTake_;
  }
  
  // add special promotion fee
  function addSpecialFeeTake(address token, uint256 balance, uint256 feeTake) public isAdmin {
      uint id = specialFees.push(SpecialTokenBalanceFeeTake(
          true,
          token,
          balance,
          feeTake
      ));
  }
  
  // chnage special promotion fee
  function chnageSpecialFeeTake(uint id, address token, uint256 balance, uint256 feeTake) public isAdmin {
      require(id < specialFees.length);
      specialFees[id] = SpecialTokenBalanceFeeTake(
          true,
          token,
          balance,
          feeTake
      );
  }
  
    // remove special promotion fee
   function removeSpecialFeeTake(uint id) public isAdmin {
       if (id >= specialFees.length) revert();

        uint last = specialFees.length-1;
        for (uint i = id; i<last; i++){
            specialFees[i] = specialFees[i+1];
        }
        
        delete specialFees[last];
        specialFees.length--;
  } 
  
  //return total count promotion fees
  function TotalSpecialFeeTakes() public constant returns(uint)  {
      return specialFees.length;
  }
  
  
  ////////////////////////////////////////////////////////////////////////////////
  // Deposits, Withdrawals, Balances
  ////////////////////////////////////////////////////////////////////////////////

  /**
  * This function handles deposits of Ether into the contract.
  * Emits a Deposit event.
  * Note: With the payable modifier, this function accepts Ether.
  */
  function deposit() public payable {
    tokens[0][msg.sender] = tokens[0][msg.sender].add(msg.value);
    Deposit(0, msg.sender, msg.value, tokens[0][msg.sender]);
  }

  /**
  * This function handles withdrawals of Ether from the contract.
  * Verifies that the user has enough funds to cover the withdrawal.
  * Emits a Withdraw event.
  * @param amount uint of the amount of Ether the user wishes to withdraw
  */
  function withdraw(uint amount) public {
    require(tokens[0][msg.sender] >= amount);
    tokens[0][msg.sender] = tokens[0][msg.sender].sub(amount);
    msg.sender.transfer(amount);
    Withdraw(0, msg.sender, amount, tokens[0][msg.sender]);
  }

  /**
  * This function handles deposits of Ethereum based tokens to the contract.
  * Does not allow Ether.
  * If token transfer fails, transaction is reverted and remaining gas is refunded.
  * Emits a Deposit event.
  * Note: Remember to call Token(address).approve(this, amount) or this contract will not be able to do the transfer on your behalf.
  * @param token Ethereum contract address of the token or 0 for Ether
  * @param amount uint of the amount of the token the user wishes to deposit
  */
  function depositToken(address token, uint amount) public {
    require(token != 0);
    depositingTokenFlag = true;
    require(IToken(token).transferFrom(msg.sender, this, amount));
    depositingTokenFlag = false;
    tokens[token][msg.sender] = tokens[token][msg.sender].add(amount);
    Deposit(token, msg.sender, amount, tokens[token][msg.sender]);
 }

  /**
  * This function provides a fallback solution as outlined in ERC223.
  * If tokens are deposited through depositToken(), the transaction will continue.
  * If tokens are sent directly to this contract, the transaction is reverted.
  * @param sender Ethereum address of the sender of the token
  * @param amount amount of the incoming tokens
  * @param data attached data similar to msg.data of Ether transactions
  */
  function tokenFallback( address sender, uint amount, bytes data) public returns (bool ok) {
      if (depositingTokenFlag) {
        // Transfer was initiated from depositToken(). User token balance will be updated there.
        return true;
      } else {
        // Direct ECR223 Token.transfer into this contract not allowed, to keep it consistent
        // with direct transfers of ECR20 and ETH.
        revert();
      }
  }
  
  /**
  * This function handles withdrawals of Ethereum based tokens from the contract.
  * Does not allow Ether.
  * If token transfer fails, transaction is reverted and remaining gas is refunded.
  * Emits a Withdraw event.
  * @param token Ethereum contract address of the token or 0 for Ether
  * @param amount uint of the amount of the token the user wishes to withdraw
  */
  function withdrawToken(address token, uint amount) public {
    require(token != 0);
    require(tokens[token][msg.sender] >= amount);
    tokens[token][msg.sender] = tokens[token][msg.sender].sub(amount);
    require(IToken(token).transfer(msg.sender, amount));
    Withdraw(token, msg.sender, amount, tokens[token][msg.sender]);
  }

  /**
  * Retrieves the balance of a token based on a user address and token address.
  * @param token Ethereum contract address of the token or 0 for Ether
  * @param user Ethereum address of the user
  * @return the amount of tokens on the exchange for a given user address
  */
  function balanceOf(address token, address user) public constant returns (uint) {
    return tokens[token][user];
  }

  ////////////////////////////////////////////////////////////////////////////////
  // Trading
  ////////////////////////////////////////////////////////////////////////////////

  /**
  * Facilitates a trade from one user to another.
  * Requires that the transaction is signed properly, the trade isn't past its expiration, and all funds are present to fill the trade.
  * Calls tradeBalances().
  * Updates orderFills with the amount traded.
  * Emits a Trade event.
  * Note: tokenGet & tokenGive can be the Ethereum contract address.
  * Note: amount is in amountGet / tokenGet terms.
  * @param tokenGet Ethereum contract address of the token to receive
  * @param amountGet uint amount of tokens being received
  * @param tokenGive Ethereum contract address of the token to give
  * @param amountGive uint amount of tokens being given
  * @param expires uint of block number when this order should expire
  * @param nonce arbitrary random number
  * @param user Ethereum address of the user who placed the order
  * @param v part of signature for the order hash as signed by user
  * @param r part of signature for the order hash as signed by user
  * @param s part of signature for the order hash as signed by user
  * @param amount uint amount in terms of tokenGet that will be "buy" in the trade
  */
  function trade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount) public {
    bytes32 hash = sha256(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce);
    require((
      (ecrecover(keccak256("\x19Ethereum Signed Message:\n32", hash), v, r, s) == user) &&
      block.number <= expires &&
      orderFills[user][hash].add(amount) <= amountGet
    ));
    tradeBalances(tokenGet, amountGet, tokenGive, amountGive, user, amount);
    orderFills[user][hash] = orderFills[user][hash].add(amount);
    Trade(tokenGet, amount, tokenGive, amountGive.mul(amount) / amountGet, user, msg.sender);
  }

  /**
  * This is a private function and is only being called from trade().
  * Handles the movement of funds when a trade occurs.
  * Takes fees.
  * Updates token balances for both buyer and seller.
  * Note: tokenGet & tokenGive can be the Ethereum contract address.
  * Note: amount is in amountGet / tokenGet terms.
  * @param tokenGet Ethereum contract address of the token to receive
  * @param amountGet uint amount of tokens being received
  * @param tokenGive Ethereum contract address of the token to give
  * @param amountGive uint amount of tokens being given
  * @param user Ethereum address of the user who placed the order
  * @param amount uint amount in terms of tokenGet that will be "buy" in the trade
  */
  function tradeBalances(address tokenGet, uint amountGet, address tokenGive, uint amountGive, address user, uint amount) private {
    
    uint256 feeTakeXfer = calculateFee(amount);
    
    tokens[tokenGet][msg.sender] = tokens[tokenGet][msg.sender].sub(amount.add(feeTakeXfer));
    tokens[tokenGet][user] = tokens[tokenGet][user].add(amount);
    tokens[tokenGet][feeAccount] = tokens[tokenGet][feeAccount].add(feeTakeXfer);
    tokens[tokenGive][user] = tokens[tokenGive][user].sub(amountGive.mul(amount).div(amountGet));
    tokens[tokenGive][msg.sender] = tokens[tokenGive][msg.sender].add(amountGive.mul(amount).div(amountGet));
  }
  
  //calculate fee including special promotions
  function calculateFee(uint amount) private constant returns(uint256)  {
    uint256 feeTakeXfer = 0;
    
    uint length = specialFees.length;
    bool applied = false;
    for(uint i = 0; length > 0 && i < length; i++) {
        SpecialTokenBalanceFeeTake memory special = specialFees[i];
        if(special.exist && special.balance <= tokens[special.token][msg.sender]) {
            applied = true;
            feeTakeXfer = amount.mul(special.feeTake).div(1 ether);
            break;
        }
        if(i >= MAX_SPECIALS)
            break;
    }
    
    if(!applied)
        feeTakeXfer = amount.mul(feeTake).div(1 ether);
    
    
    return feeTakeXfer;
  }

  /**
  * This function is to test if a trade would go through.
  * Note: tokenGet & tokenGive can be the Ethereum contract address.
  * Note: amount is in amountGet / tokenGet terms.
  * @param tokenGet Ethereum contract address of the token to receive
  * @param amountGet uint amount of tokens being received
  * @param tokenGive Ethereum contract address of the token to give
  * @param amountGive uint amount of tokens being given
  * @param expires uint of block number when this order should expire
  * @param nonce arbitrary random number
  * @param user Ethereum address of the user who placed the order
  * @param v part of signature for the order hash as signed by user
  * @param r part of signature for the order hash as signed by user
  * @param s part of signature for the order hash as signed by user
  * @param amount uint amount in terms of tokenGet that will be "buy" in the trade
  * @param sender Ethereum address of the user taking the order
  * @return bool: true if the trade would be successful, false otherwise
  */
  function testTrade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount, address sender) public constant returns(bool) {
    if (!(
      tokens[tokenGet][sender] >= amount &&
      availableVolume(tokenGet, amountGet, tokenGive, amountGive, expires, nonce, user, v, r, s) >= amount
      )) { 
      return false;
    } else {
      return true;
    }
  }

  /**
  * This function checks the available volume for a given order.
  * Note: tokenGet & tokenGive can be the Ethereum contract address.
  * @param tokenGet Ethereum contract address of the token to receive
  * @param amountGet uint amount of tokens being received
  * @param tokenGive Ethereum contract address of the token to give
  * @param amountGive uint amount of tokens being given
  * @param expires uint of block number when this order should expire
  * @param nonce arbitrary random number
  * @param user Ethereum address of the user who placed the order
  * @param v part of signature for the order hash as signed by user
  * @param r part of signature for the order hash as signed by user
  * @param s part of signature for the order hash as signed by user
  * @return uint: amount of volume available for the given order in terms of amountGet / tokenGet
  */
  function availableVolume(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s) public constant returns(uint) {
    bytes32 hash = sha256(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce);
    if (!(
      (ecrecover(keccak256("\x19Ethereum Signed Message:\n32", hash), v, r, s) == user) &&
      block.number <= expires
      )) {
      return 0;
    }
    uint[2] memory available;
    available[0] = amountGet.sub(orderFills[user][hash]);
    available[1] = tokens[tokenGive][user].mul(amountGet) / amountGive;
    if (available[0] < available[1]) {
      return available[0];
    } else {
      return available[1];
    }
  }

  /**
  * This function checks the amount of an order that has already been filled.
  * Note: tokenGet & tokenGive can be the Ethereum contract address.
  * @param tokenGet Ethereum contract address of the token to receive
  * @param amountGet uint amount of tokens being received
  * @param tokenGive Ethereum contract address of the token to give
  * @param amountGive uint amount of tokens being given
  * @param expires uint of block number when this order should expire
  * @param nonce arbitrary random number
  * @param user Ethereum address of the user who placed the order
  * @param v part of signature for the order hash as signed by user
  * @param r part of signature for the order hash as signed by user
  * @param s part of signature for the order hash as signed by user
  * @return uint: amount of the given order that has already been filled in terms of amountGet / tokenGet
  */
  function amountFilled(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s) public constant returns(uint) {
    bytes32 hash = sha256(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce);
    return orderFills[user][hash];
  }

  /**
  * This function cancels a given order by editing its fill data to the full amount.
  * Requires that the transaction is signed properly.
  * Updates orderFills to the full amountGet
  * Emits a Cancel event.
  * Note: tokenGet & tokenGive can be the Ethereum contract address.
  * @param tokenGet Ethereum contract address of the token to receive
  * @param amountGet uint amount of tokens being received
  * @param tokenGive Ethereum contract address of the token to give
  * @param amountGive uint amount of tokens being given
  * @param expires uint of block number when this order should expire
  * @param nonce arbitrary random number
  * @param v part of signature for the order hash as signed by user
  * @param r part of signature for the order hash as signed by user
  * @param s part of signature for the order hash as signed by user
  * @return uint: amount of the given order that has already been filled in terms of amountGet / tokenGet
  */
  function cancelOrder(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, uint8 v, bytes32 r, bytes32 s) public {
    bytes32 hash = sha256(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce);
    require ((ecrecover(keccak256("\x19Ethereum Signed Message:\n32", hash), v, r, s) == msg.sender));
    orderFills[msg.sender][hash] = amountGet;
    Cancel(tokenGet, amountGet, tokenGive, amountGive, expires, nonce, msg.sender, v, r, s);
  }

  
  /**
  * This function handles deposits of Ether into the contract, but allows specification of a user.
  * Note: This is generally used in migration of funds.
  * Note: With the payable modifier, this function accepts Ether.
  */
  function depositForUser(address user) public payable {
    require(user != address(0));
    require(msg.value > 0);
    tokens[0][user] = tokens[0][user].add(msg.value);
  }
  
  /**
  * This function handles deposits of Ethereum based tokens into the contract, but allows specification of a user.
  * Does not allow Ether.
  * If token transfer fails, transaction is reverted and remaining gas is refunded.
  * Note: This is generally used in migration of funds.
  * Note: Remember to call Token(address).approve(this, amount) or this contract will not be able to do the transfer on your behalf.
  * @param token Ethereum contract address of the token
  * @param amount uint of the amount of the token the user wishes to deposit
  */
  function depositTokenForUser(address token, uint amount, address user) public {
    require(token != address(0));
    require(user != address(0));
    require(amount > 0);
    depositingTokenFlag = true;
    require(IToken(token).transferFrom(msg.sender, this, amount));
    depositingTokenFlag = false;
    tokens[token][user] = tokens[token][user].add(amount);
  }
  
}