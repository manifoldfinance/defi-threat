/**
 * Source Code first verified at https://etherscan.io on Sunday, March 24, 2019
 (UTC) */

pragma solidity ^0.4.22;

// File: contracts/library/SafeMath.sol

/**
 * @title Safe Math
 *
 * @dev Library for safe mathematical operations.
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;

        return c;
    }

    function minus(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);

        return a - b;
    }

    function plus(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);

        return c;
    }
}

// File: contracts/token/ERC20Token.sol

/**
 * @dev The standard ERC20 Token contract base.
 */
contract ERC20Token {
    uint256 public totalSupply;  /* shorthand for public function and a property */
    
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

// File: contracts/component/TokenSafe.sol

/**
 * @title TokenSafe
 *
 * @dev Abstract contract that serves as a base for the token safes. It is a multi-group token safe, where each group
 *      has it's own release time and multiple accounts with locked tokens.
 */
contract TokenSafe {
    using SafeMath for uint;

    // The ERC20 token contract.
    ERC20Token token;

    struct Group {
        // The release date for the locked tokens
        // Note: Unix timestamp fits in uint32, however block.timestamp is uint256
        uint256 releaseTimestamp;
        // The total remaining tokens in the group.
        uint256 remaining;
        // The individual account token balances in the group.
        mapping (address => uint) balances;
    }

    // The groups of locked tokens
    mapping (uint8 => Group) public groups;

    /**
     * @dev The constructor.
     *
     * @param _token The address of the Fabric Token (fundraiser) contract.
     */
    constructor(address _token) public {
        token = ERC20Token(_token);
    }

    /**
     * @dev The function initializes a group with a release date.
     *
     * @param _id Group identifying number.
     * @param _releaseTimestamp Unix timestamp of the time after which the tokens can be released
     */
    function init(uint8 _id, uint _releaseTimestamp) internal {
        require(_releaseTimestamp > 0, "TokenSafe group release timestamp is not set");
        
        Group storage group = groups[_id];
        group.releaseTimestamp = _releaseTimestamp;
    }

    /**
     * @dev Add new account with locked token balance to the specified group id.
     *
     * @param _id Group identifying number.
     * @param _account The address of the account to be added.
     * @param _balance The number of tokens to be locked.
     */
    function add(uint8 _id, address _account, uint _balance) internal {
        Group storage group = groups[_id];
        group.balances[_account] = group.balances[_account].plus(_balance);
        group.remaining = group.remaining.plus(_balance);
    }

    /**
     * @dev Allows an account to be released if it meets the time constraints of the group.
     *
     * @param _id Group identifying number.
     * @param _account The address of the account to be released.
     */
    function release(uint8 _id, address _account) public {
        Group storage group = groups[_id];
        require(now >= group.releaseTimestamp, "Group funds are not released yet");
        
        uint tokens = group.balances[_account];
        require(tokens > 0, "The account is empty or non-existent");
        
        group.balances[_account] = 0;
        group.remaining = group.remaining.minus(tokens);
        
        if (!token.transfer(_account, tokens)) {
            revert("Token transfer failed");
        }
    }
}

// File: contracts/token/StandardToken.sol

/**
 * @title Standard Token
 *
 * @dev The standard abstract implementation of the ERC20 interface.
 */
contract StandardToken is ERC20Token {
    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals;

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    /**
     * @dev The constructor assigns the token name, symbols and decimals.
     */
    constructor(string _name, string _symbol, uint8 _decimals) internal {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    /**
     * @dev Get the balance of an address.
     *
     * @param _address The address which's balance will be checked.
     *
     * @return The current balance of the address.
     */
    function balanceOf(address _address) public view returns (uint256 balance) {
        return balances[_address];
    }

    /**
     * @dev Checks the amount of tokens that an owner allowed to a spender.
     *
     * @param _owner The address which owns the funds allowed for spending by a third-party.
     * @param _spender The third-party address that is allowed to spend the tokens.
     *
     * @return The number of tokens available to `_spender` to be spent.
     */
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
     * @dev Give permission to `_spender` to spend `_value` number of tokens on your behalf.
     * E.g. You place a buy or sell order on an exchange and in that example, the 
     * `_spender` address is the address of the contract the exchange created to add your token to their 
     * website and you are `msg.sender`.
     *
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     *
     * @return Whether the approval process was successful or not.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    /**
     * @dev Transfers `_value` number of tokens to the `_to` address.
     *
     * @param _to The address of the recipient.
     * @param _value The number of tokens to be transferred.
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        executeTransfer(msg.sender, _to, _value);

        return true;
    }

    /**
     * @dev Allows another contract to spend tokens on behalf of the `_from` address and send them to the `_to` address.
     *
     * @param _from The address which approved you to spend tokens on their behalf.
     * @param _to The address where you want to send tokens.
     * @param _value The number of tokens to be sent.
     *
     * @return Whether the transfer was successful or not.
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_value <= allowed[_from][msg.sender], "Insufficient allowance");

        allowed[_from][msg.sender] = allowed[_from][msg.sender].minus(_value);
        executeTransfer(_from, _to, _value);

        return true;
    }

    /**
     * @dev Internal function that this reused by the transfer functions
     */
    function executeTransfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Invalid transfer to address zero");
        require(_value <= balances[_from], "Insufficient account balance");

        balances[_from] = balances[_from].minus(_value);
        balances[_to] = balances[_to].plus(_value);

        emit Transfer(_from, _to, _value);
    }
}

// File: contracts/token/MintableToken.sol

/**
 * @title Mintable Token
 *
 * @dev Allows the creation of new tokens.
 */
contract MintableToken is StandardToken {
    /// @dev The only address allowed to mint coins
    address public minter;

    /// @dev Indicates whether the token is still mintable.
    bool public mintingDisabled = false;

    /**
     * @dev Event fired when minting is no longer allowed.
     */
    event MintingDisabled();

    /**
     * @dev Allows a function to be executed only if minting is still allowed.
     */
    modifier canMint() {
        require(!mintingDisabled, "Minting is disabled");
        _;
    }

    /**
     * @dev Allows a function to be called only by the minter
     */
    modifier onlyMinter() {
        require(msg.sender == minter, "Only the minter address can mint");
        _;
    }

    /**
     * @dev The constructor assigns the minter which is allowed to mind and disable minting
     */
    constructor(address _minter) internal {
        minter = _minter;
    }

    /**
    * @dev Creates new `_value` number of tokens and sends them to the `_to` address.
    *
    * @param _to The address which will receive the freshly minted tokens.
    * @param _value The number of tokens that will be created.
    */
    function mint(address _to, uint256 _value) public onlyMinter canMint {
        totalSupply = totalSupply.plus(_value);
        balances[_to] = balances[_to].plus(_value);

        emit Transfer(0x0, _to, _value);
    }

    /**
    * @dev Disable the minting of new tokens. Cannot be reversed.
    *
    * @return Whether or not the process was successful.
    */
    function disableMinting() public onlyMinter canMint {
        mintingDisabled = true;
       
        emit MintingDisabled();
    }
}

// File: contracts/trait/HasOwner.sol

/**
 * @title HasOwner
 *
 * @dev Allows for exclusive access to certain functionality.
 */
contract HasOwner {
    // The current owner.
    address public owner;

    // Conditionally the new owner.
    address public newOwner;

    /**
     * @dev The constructor.
     *
     * @param _owner The address of the owner.
     */
    constructor(address _owner) public {
        owner = _owner;
    }

    /** 
     * @dev Access control modifier that allows only the current owner to call the function.
     */
    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    /**
     * @dev The event is fired when the current owner is changed.
     *
     * @param _oldOwner The address of the previous owner.
     * @param _newOwner The address of the new owner.
     */
    event OwnershipTransfer(address indexed _oldOwner, address indexed _newOwner);

    /**
     * @dev Transfering the ownership is a two-step process, as we prepare
     * for the transfer by setting `newOwner` and requiring `newOwner` to accept
     * the transfer. This prevents accidental lock-out if something goes wrong
     * when passing the `newOwner` address.
     *
     * @param _newOwner The address of the proposed new owner.
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
 
    /**
     * @dev The `newOwner` finishes the ownership transfer process by accepting the
     * ownership.
     */
    function acceptOwnership() public {
        require(msg.sender == newOwner, "Only the newOwner can accept ownership");

        emit OwnershipTransfer(owner, newOwner);

        owner = newOwner;
    }
}

// File: contracts/fundraiser/AbstractFundraiser.sol

contract AbstractFundraiser {
    /// The ERC20 token contract.
    ERC20Token public token;

    /**
     * @dev The event fires every time a new buyer enters the fundraiser.
     *
     * @param _address The address of the buyer.
     * @param _ethers The number of ethers funded.
     * @param _tokens The number of tokens purchased.
     */
    event FundsReceived(address indexed _address, uint _ethers, uint _tokens);


    /**
     * @dev The initialization method for the token
     *
     * @param _token The address of the token of the fundraiser
     */
    function initializeFundraiserToken(address _token) internal
    {
        token = ERC20Token(_token);
    }

    /**
     * @dev The default function which is executed when someone sends funds to this contract address.
     */
    function() public payable {
        receiveFunds(msg.sender, msg.value);
    }

    /**
     * @dev this overridable function returns the current conversion rate for the fundraiser
     */
    function getConversionRate() public view returns (uint256);

    /**
     * @dev checks whether the fundraiser passed `endTime`.
     *
     * @return whether the fundraiser has ended.
     */
    function hasEnded() public view returns (bool);

    /**
     * @dev Create and sends tokens to `_address` considering amount funded and `conversionRate`.
     *
     * @param _address The address of the receiver of tokens.
     * @param _amount The amount of received funds in ether.
     */
    function receiveFunds(address _address, uint256 _amount) internal;
    
    /**
     * @dev It throws an exception if the transaction does not meet the preconditions.
     */
    function validateTransaction() internal view;
    
    /**
     * @dev this overridable function makes and handles tokens to buyers
     */
    function handleTokens(address _address, uint256 _tokens) internal;

    /**
     * @dev this overridable function forwards the funds (if necessary) to a vault or directly to the beneficiary
     */
    function handleFunds(address _address, uint256 _ethers) internal;

}

// File: contracts/fundraiser/BasicFundraiser.sol

/**
 * @title Basic Fundraiser
 *
 * @dev An abstract contract that is a base for fundraisers. 
 * It implements a generic procedure for handling received funds:
 * 1. Validates the transaction preconditions
 * 2. Calculates the amount of tokens based on the conversion rate.
 * 3. Delegate the handling of the tokens (mint, transfer or create)
 * 4. Delegate the handling of the funds
 * 5. Emit event for received funds
 */
contract BasicFundraiser is HasOwner, AbstractFundraiser {
    using SafeMath for uint256;

    // The number of decimals for the token.
    uint8 constant DECIMALS = 18;  // Enforced

    // Decimal factor for multiplication purposes.
    uint256 constant DECIMALS_FACTOR = 10 ** uint256(DECIMALS);

    // The start time of the fundraiser - Unix timestamp.
    uint256 public startTime;

    // The end time of the fundraiser - Unix timestamp.
    uint256 public endTime;

    // The address where funds collected will be sent.
    address public beneficiary;

    // The conversion rate with decimals difference adjustment,
    // When converion rate is lower than 1 (inversed), the function calculateTokens() should use division
    uint256 public conversionRate;

    // The total amount of ether raised.
    uint256 public totalRaised;

    /**
     * @dev The event fires when the number of token conversion rate has changed.
     *
     * @param _conversionRate The new number of tokens per 1 ether.
     */
    event ConversionRateChanged(uint _conversionRate);

    /**
     * @dev The basic fundraiser initialization method.
     *
     * @param _startTime The start time of the fundraiser - Unix timestamp.
     * @param _endTime The end time of the fundraiser - Unix timestamp.
     * @param _conversionRate The number of tokens create for 1 ETH funded.
     * @param _beneficiary The address which will receive the funds gathered by the fundraiser.
     */
    function initializeBasicFundraiser(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _conversionRate,
        address _beneficiary
    )
        internal
    {
        require(_endTime >= _startTime, "Fundraiser's end is before its start");
        require(_conversionRate > 0, "Conversion rate is not set");
        require(_beneficiary != address(0), "The beneficiary is not set");

        startTime = _startTime;
        endTime = _endTime;
        conversionRate = _conversionRate;
        beneficiary = _beneficiary;
    }

    /**
     * @dev Sets the new conversion rate
     *
     * @param _conversionRate New conversion rate
     */
    function setConversionRate(uint256 _conversionRate) public onlyOwner {
        require(_conversionRate > 0, "Conversion rate is not set");

        conversionRate = _conversionRate;

        emit ConversionRateChanged(_conversionRate);
    }

    /**
     * @dev Sets The beneficiary of the fundraiser.
     *
     * @param _beneficiary The address of the beneficiary.
     */
    function setBeneficiary(address _beneficiary) public onlyOwner {
        require(_beneficiary != address(0), "The beneficiary is not set");

        beneficiary = _beneficiary;
    }

    /**
     * @dev Create and sends tokens to `_address` considering amount funded and `conversionRate`.
     *
     * @param _address The address of the receiver of tokens.
     * @param _amount The amount of received funds in ether.
     */
    function receiveFunds(address _address, uint256 _amount) internal {
        validateTransaction();

        uint256 tokens = calculateTokens(_amount);
        require(tokens > 0, "The transaction results in zero tokens");

        totalRaised = totalRaised.plus(_amount);
        handleTokens(_address, tokens);
        handleFunds(_address, _amount);

        emit FundsReceived(_address, msg.value, tokens);
    }

    /**
     * @dev this overridable function returns the current conversion rate multiplied by the conversion rate factor
     */
    function getConversionRate() public view returns (uint256) {
        return conversionRate;
    }

    /**
     * @dev this overridable function that calculates the tokens based on the ether amount
     */
    function calculateTokens(uint256 _amount) internal view returns(uint256 tokens) {
        tokens = _amount.mul(getConversionRate());
    }

    /**
     * @dev It throws an exception if the transaction does not meet the preconditions.
     */
    function validateTransaction() internal view {
        require(msg.value != 0, "Transaction value is zero");
        require(now >= startTime && now < endTime, "The fundraiser is not active");
    }

    /**
     * @dev checks whether the fundraiser passed `endtime`.
     *
     * @return whether the fundraiser is passed its deadline or not.
     */
    function hasEnded() public view returns (bool) {
        return now >= endTime;
    }
}

// File: contracts/token/StandardMintableToken.sol

contract StandardMintableToken is MintableToken {
    constructor(address _minter, string _name, string _symbol, uint8 _decimals)
        StandardToken(_name, _symbol, _decimals)
        MintableToken(_minter)
        public
    {
    }
}

// File: contracts/fundraiser/MintableTokenFundraiser.sol

/**
 * @title Fundraiser With Mintable Token
 */
contract MintableTokenFundraiser is BasicFundraiser {
    /**
     * @dev The initialization method that creates a new mintable token.
     *
     * @param _name Token name
     * @param _symbol Token symbol
     * @param _decimals Token decimals
     */
    function initializeMintableTokenFundraiser(string _name, string _symbol, uint8 _decimals) internal {
        token = new StandardMintableToken(
            address(this), // The fundraiser is the token minter
            _name,
            _symbol,
            _decimals
        );
    }

    /**
     * @dev Mint the specific amount tokens
     */
    function handleTokens(address _address, uint256 _tokens) internal {
        MintableToken(token).mint(_address, _tokens);
    }
}

// File: contracts/fundraiser/IndividualCapsFundraiser.sol

/**
 * @title Fundraiser with individual caps
 *
 * @dev Allows you to set a hard cap on your fundraiser.
 */
contract IndividualCapsFundraiser is BasicFundraiser {
    uint256 public individualMinCap;
    uint256 public individualMaxCap;
    uint256 public individualMaxCapTokens;


    event IndividualMinCapChanged(uint256 _individualMinCap);
    event IndividualMaxCapTokensChanged(uint256 _individualMaxCapTokens);

    /**
     * @dev The initialization method.
     *
     * @param _individualMinCap The minimum amount of ether contribution per address.
     * @param _individualMaxCap The maximum amount of ether contribution per address.
     */
    function initializeIndividualCapsFundraiser(uint256 _individualMinCap, uint256 _individualMaxCap) internal {
        individualMinCap = _individualMinCap;
        individualMaxCap = _individualMaxCap;
        individualMaxCapTokens = _individualMaxCap * conversionRate;
    }

    function setConversionRate(uint256 _conversionRate) public onlyOwner {
        super.setConversionRate(_conversionRate);

        if (individualMaxCap == 0) {
            return;
        }
        
        individualMaxCapTokens = individualMaxCap * _conversionRate;

        emit IndividualMaxCapTokensChanged(individualMaxCapTokens);
    }

    function setIndividualMinCap(uint256 _individualMinCap) public onlyOwner {
        individualMinCap = _individualMinCap;

        emit IndividualMinCapChanged(individualMinCap);
    }

    function setIndividualMaxCap(uint256 _individualMaxCap) public onlyOwner {
        individualMaxCap = _individualMaxCap;
        individualMaxCapTokens = _individualMaxCap * conversionRate;

        emit IndividualMaxCapTokensChanged(individualMaxCapTokens);
    }

    /**
     * @dev Extends the transaction validation to check if the value is higher than the minimum cap.
     */
    function validateTransaction() internal view {
        super.validateTransaction();
        require(
            msg.value >= individualMinCap,
            "The transaction value does not pass the minimum contribution cap"
        );
    }

    /**
     * @dev We validate the new amount doesn't surpass maximum contribution cap
     */
    function handleTokens(address _address, uint256 _tokens) internal {
        require(
            individualMaxCapTokens == 0 || token.balanceOf(_address).plus(_tokens) <= individualMaxCapTokens,
            "The transaction exceeds the individual maximum cap"
        );

        super.handleTokens(_address, _tokens);
    }
}

// File: contracts/fundraiser/GasPriceLimitFundraiser.sol

/**
 * @title GasPriceLimitFundraiser
 *
 * @dev This fundraiser allows to set gas price limit for the participants in the fundraiser
 */
contract GasPriceLimitFundraiser is HasOwner, BasicFundraiser {
    uint256 public gasPriceLimit;

    event GasPriceLimitChanged(uint256 gasPriceLimit);

    /**
     * @dev This function puts the initial gas limit
     */
    function initializeGasPriceLimitFundraiser(uint256 _gasPriceLimit) internal {
        gasPriceLimit = _gasPriceLimit;
    }

    /**
     * @dev This function allows the owner to change the gas limit any time during the fundraiser
     */
    function changeGasPriceLimit(uint256 _gasPriceLimit) public onlyOwner {
        gasPriceLimit = _gasPriceLimit;

        emit GasPriceLimitChanged(_gasPriceLimit);
    }

    /**
     * @dev The transaction is valid if the gas price limit is lifted-off or the transaction meets the requirement
     */
    function validateTransaction() internal view {
        require(gasPriceLimit == 0 || tx.gasprice <= gasPriceLimit, "Transaction exceeds the gas price limit");

        return super.validateTransaction();
    }
}

// File: contracts/fundraiser/ForwardFundsFundraiser.sol

/**
 * @title Forward Funds to Beneficiary Fundraiser
 *
 * @dev This contract forwards the funds received to the beneficiary.
 */
contract ForwardFundsFundraiser is BasicFundraiser {
    /**
     * @dev Forward funds directly to beneficiary
     */
    function handleFunds(address, uint256 _ethers) internal {
        // Forward the funds directly to the beneficiary
        beneficiary.transfer(_ethers);
    }
}

// File: contracts/fundraiser/PresaleFundraiser.sol

/**
 * @title PresaleFundraiser
 *
 * @dev This is the standard fundraiser contract which allows
 * you to raise ETH in exchange for your tokens.
 */
contract PresaleFundraiser is MintableTokenFundraiser {
    /// @dev The token hard cap for the pre-sale
    uint256 public presaleSupply;

    /// @dev The token hard cap for the pre-sale
    uint256 public presaleMaxSupply;

    /// @dev The start time of the pre-sale (Unix timestamp).
    uint256 public presaleStartTime;

    /// @dev The end time of the pre-sale (Unix timestamp).
    uint256 public presaleEndTime;

    /// @dev The conversion rate for the pre-sale
    uint256 public presaleConversionRate;

    /**
     * @dev The initialization method.
     *
     * @param _startTime The timestamp of the moment when the pre-sale starts
     * @param _endTime The timestamp of the moment when the pre-sale ends
     * @param _conversionRate The conversion rate during the pre-sale
     */
    function initializePresaleFundraiser(
        uint256 _presaleMaxSupply,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _conversionRate
    )
        internal
    {
        require(_endTime >= _startTime, "Pre-sale's end is before its start");
        require(_conversionRate > 0, "Conversion rate is not set");

        presaleMaxSupply = _presaleMaxSupply;
        presaleStartTime = _startTime;
        presaleEndTime = _endTime;
        presaleConversionRate = _conversionRate;
    }

    /**
     * @dev Internal funciton that helps to check if the pre-sale is active
     */
    
    function isPresaleActive() internal view returns (bool) {
        return now < presaleEndTime && now >= presaleStartTime;
    }
    /**
     * @dev this function different conversion rate while in presale
     */
    function getConversionRate() public view returns (uint256) {
        if (isPresaleActive()) {
            return presaleConversionRate;
        }
        return super.getConversionRate();
    }

    /**
     * @dev It throws an exception if the transaction does not meet the preconditions.
     */
    function validateTransaction() internal view {
        require(msg.value != 0, "Transaction value is zero");
        require(
            now >= startTime && now < endTime || isPresaleActive(),
            "Neither the pre-sale nor the fundraiser are currently active"
        );
    }

    function handleTokens(address _address, uint256 _tokens) internal {
        if (isPresaleActive()) {
            presaleSupply = presaleSupply.plus(_tokens);
            require(
                presaleSupply <= presaleMaxSupply,
                "Transaction exceeds the pre-sale maximum token supply"
            );
        }

        super.handleTokens(_address, _tokens);
    }

}

// File: contracts/fundraiser/TieredFundraiser.sol

/**
 * @title TieredFundraiser
 *
 * @dev A fundraiser that improves the base conversion precision to allow percent bonuses
 */

contract TieredFundraiser is BasicFundraiser {
    // Conversion rate factor for better precision.
    uint256 constant CONVERSION_RATE_FACTOR = 100;

    /**
      * @dev Define conversion rates based on the tier start and end date
      */
    function getConversionRate() public view returns (uint256) {
        return super.getConversionRate().mul(CONVERSION_RATE_FACTOR);
    }

    /**
     * @dev this overridable function that calculates the tokens based on the ether amount
     */
    function calculateTokens(uint256 _amount) internal view returns(uint256 tokens) {
        return super.calculateTokens(_amount).div(CONVERSION_RATE_FACTOR);
    }

    /**
     * @dev this overridable function returns the current conversion rate factor
     */
    function getConversionRateFactor() public pure returns (uint256) {
        return CONVERSION_RATE_FACTOR;
    }
}

// File: contracts/Fundraiser.sol

/**
 * @title TIMEToken
 */

contract TIMEToken is MintableToken {
    constructor(address _minter)
        StandardToken(
            "TIME",   // Token name
            "TM", // Token symbol
            18  // Token decimals
        )
        
        MintableToken(_minter)
        public
    {
    }
}



/**
 * @title TIMETokenSafe
 */

contract TIMETokenSafe is TokenSafe {
  constructor(address _token)
    TokenSafe(_token)
    public
  {
    
    // Group "Core Team Members Safe"
    init(
      1, // Group Id
      1553734800 // Release date = 2019-03-28 01:00 UTC
    );
    add(
      1, // Group Id
      0xf245e9C0e1B25A0d2b91544361DDc285339A6873,  // Token Safe Entry Address
      840000000000000000000000  // Allocated tokens
    );
  }
}



/**
 * @title TIMETokenFundraiser
 */

contract TIMETokenFundraiser is MintableTokenFundraiser, PresaleFundraiser, IndividualCapsFundraiser, ForwardFundsFundraiser, TieredFundraiser, GasPriceLimitFundraiser {
    TIMETokenSafe public tokenSafe;

    constructor()
        HasOwner(msg.sender)
        public
    {
        token = new TIMEToken(
        
        address(this)  // The fundraiser is the minter
        );

        tokenSafe = new TIMETokenSafe(token);
        MintableToken(token).mint(address(tokenSafe), 840000000000000000000000);

        initializeBasicFundraiser(
            1553731200, // Start date = 2019-03-28 00:00 UTC
            1893455940,  // End date = 2029-12-31 23:59 UTC
            1, // Conversion rate = 1 TM per 1 ether
            0xaC4F9BE57419Aed5e71739Cd22a0cf2da4c90Fe4     // Beneficiary
        );

        initializeIndividualCapsFundraiser(
            (0 ether), // Minimum contribution
            (0 ether)  // Maximum individual cap
        );

        initializeGasPriceLimitFundraiser(
            3000000000000000 // Gas price limit in wei
        );

        initializePresaleFundraiser(
            2400000000000000000000000,
            1553558400, // Start = 2019-03-26 00:00 UTC
            1553731140,   // End = 2019-03-27 23:59 UTC
            1
        );

        

        

        
    }
    
    /**
      * @dev Define conversion rates based on the tier start and end date
      */
    function getConversionRate() public view returns (uint256) {
        uint256 rate = super.getConversionRate();
        if (now >= 1553731200 && now < 1556495940)
            return rate.mul(105).div(100);
        

        return rate;
    }

    /**
      * @dev Fundraiser with mintable token allows the owner to mint through the Fundraiser contract
      */
    function mint(address _to, uint256 _value) public onlyOwner {
        MintableToken(token).mint(_to, _value);
    }

    /**
      * @dev Irreversibly disable minting
      */
    function disableMinting() public onlyOwner {
        MintableToken(token).disableMinting();
    }
    
}