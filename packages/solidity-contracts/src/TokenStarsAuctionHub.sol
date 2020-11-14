/**
 * Source Code first verified at https://etherscan.io on Thursday, April 4, 2019
 (UTC) */

// File: soltsice/contracts/MultiOwnable.sol

pragma solidity ^0.4.18;

/*
 * A minimum multisig wallet interface. Compatible with MultiSigWallet by Gnosis.
 */
contract WalletBasic {
    function isOwner(address owner) public returns (bool);
}

/**
 * @dev MultiOwnable contract.
 */
contract MultiOwnable {
    
    WalletBasic public wallet;
    
    event MultiOwnableWalletSet(address indexed _contract, address indexed _wallet);

    function MultiOwnable 
        (address _wallet)
        public
    {
        wallet = WalletBasic(_wallet);
        MultiOwnableWalletSet(this, wallet);
    }

    /** Check if a caller is the MultiSig wallet. */
    modifier onlyWallet() {
        require(wallet == msg.sender);
        _;
    }

    /** Check if a caller is one of the current owners of the MultiSig wallet or the wallet itself. */
    modifier onlyOwner() {
        require (isOwner(msg.sender));
        _;
    }

    function isOwner(address _address) 
        public
        constant
        returns(bool)
    {
        // NB due to lazy eval wallet could be a normal address and isOwner won't be called if the first condition is met
        return wallet == _address || wallet.isOwner(_address);
    }


    /* PAUSABLE with upause callable only by wallet */ 

    bool public paused = false;

    event Pause();
    event Unpause();

    /**
    * @dev Modifier to make a function callable only when the contract is not paused.
    */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is paused.
    */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
    * @dev called by any MSW owner to pause, triggers stopped state
    */
    function pause() 
        onlyOwner
        whenNotPaused 
        public 
    {
        paused = true;
        Pause();
    }

    /**
    * @dev called by the MSW (all owners) to unpause, returns to normal state
    */
    function unpause() 
        onlyWallet
        whenPaused
        public
    {
        paused = false;
        Unpause();
    }
}

// File: soltsice/contracts/BotManageable.sol

pragma solidity ^0.4.18;


/**
 * @dev BotManaged contract provides a modifier isBot and methods to enable/disable bots.
 */
contract BotManageable is MultiOwnable {
    uint256 constant MASK64 = 18446744073709551615;

    // NB packing saves gas even in memory due to stack size
    // struct StartEndTimeLayout {
    //     uint64 startTime;
    //     uint64 endTime;
    // }

    /**
     * Bot addresses and their start/end times (two uint64 timestamps)
     */
    mapping (address => uint128) internal botsStartEndTime;

    event BotsStartEndTimeChange(address indexed _botAddress, uint64 _startTime, uint64 _endTime);

    function BotManageable 
        (address _wallet)
        public
        MultiOwnable(_wallet)
    { }

    /** Check if a caller is an active bot. */
    modifier onlyBot() {
        require (isBot(msg.sender));
        _;
    }

    /** Check if a caller is an active bot or an owner or the wallet. */
    modifier onlyBotOrOwner() {
        require (isBot(msg.sender) || isOwner(msg.sender));
        _;
    }

    /** Enable bot address. */
    function enableBot(address _botAddress)
        onlyWallet()
        public 
    {
        uint128 botLifetime = botsStartEndTime[_botAddress];
        // cannot re-enable existing bot
        require((botLifetime >> 64) == 0 && (botLifetime & MASK64) == 0);
        botLifetime |= uint128(now) << 64;
        botsStartEndTime[_botAddress] = botLifetime;
        BotsStartEndTimeChange(_botAddress, uint64(botLifetime >> 64), uint64(botLifetime & MASK64));
    }

    /** Disable bot address. */
    function disableBot(address _botAddress, uint64 _fromTimeStampSeconds)
        onlyOwner()
        public 
    {
        uint128 botLifetime = botsStartEndTime[_botAddress];
        // bot must have been enabled previously and not disabled before
        require((botLifetime >> 64) > 0 && (botLifetime & MASK64) == 0);
        botLifetime |= uint128(_fromTimeStampSeconds);
        botsStartEndTime[_botAddress] = botLifetime;
        BotsStartEndTimeChange(_botAddress, uint64(botLifetime >> 64), uint64(botLifetime & MASK64));
    }

    /** Operational contracts call this method to check if a caller is an approved bot. */
    function isBot(address _botAddress) 
        public
        constant
        returns(bool)
    {
        return isBotAt(_botAddress, uint64(now));
    }

    // truffle-contract doesn't like method overloading, use a different name

    function isBotAt(address _botAddress, uint64 _atTimeStampSeconds) 
        public
        constant 
        returns(bool)
    {
        uint128 botLifetime = botsStartEndTime[_botAddress];
        if ((botLifetime >> 64) == 0 || (botLifetime >> 64) > _atTimeStampSeconds) {
            return false;
        }
        if ((botLifetime & MASK64) == 0) {
            return true;
        }
        if (_atTimeStampSeconds < (botLifetime & MASK64)) {
            return true;
        }
        return false;
    }
}

// File: zeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

// File: contracts/Auction.sol

pragma solidity ^0.4.18;



contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function transfer(address to, uint256 value) public returns (bool);
}

contract AuctionHub is BotManageable {
    using SafeMath for uint256;

    /*
     *  Data structures
     */
    
    struct TokenBalance {
        address token;
        uint256 value;
    }

    struct TokenRate {
        uint256 value;
        uint256 decimals;
    }

    struct BidderState {
        uint256 etherBalance;
        uint256 tokensBalanceInEther;
        //uint256 managedBid;
        TokenBalance[] tokenBalances;        
        uint256 etherBalanceInUsd; // (decimals = 2)
        uint256 tokensBalanceInUsd; // (decimals = 2)
        //uint256 managedBidInUsd;
    }

    struct ActionState {
        uint256 endSeconds; // end time in Unix seconds, 1514160000 for Dec 25, 2017 (need to double check!)
        uint256 maxTokenBidInEther; // максимальная ставка токенов в эфире. Думаю убрать это ограничение.
        uint256 minPrice; // минимальная цена лота в WEI
        
        uint256 highestBid; 
        
        // next 5 fields should be packed into one 32-bytes slot
        address highestBidder;
        //uint64 highestManagedBidder;
        //bool allowManagedBids;
        bool cancelled;
        bool finalized;        

        uint256 maxTokenBidInUsd; // max token bid in usd (decimals = 2)
        uint256 highestBidInUsd; // highest bid in usd (decimals = 2)
        address highestBidderInUsd; // highest bidder address in usd (decimals = 2)
        //uint64 highestManagedBidderInUsd; // highest manage bid in usd

        mapping(address => BidderState) bidderStates;

        bytes32 item;       
    }

    /*
     *  Storage
     */
    mapping(address => ActionState) public auctionStates;
    mapping(address => TokenRate) public tokenRates;    
    // ether rate in usd
    uint256 public etherRate;

    /*
     *  Events
     */

    event NewAction(address indexed auction, string item);
    event Bid(address indexed auction, address bidder, uint256 totalBidInEther, uint256 indexed tokensBidInEther, uint256 totalBidInUsd, uint256 indexed tokensBidInUsd);
    event TokenBid(address indexed auction, address bidder, address token, uint256 numberOfTokens);
    //event ManagedBid(address indexed auction, uint64 bidder, uint256 bid, address knownManagedBidder);
    //event NewHighestBidder(address indexed auction, address bidder, uint64 managedBidder, uint256 totalBid);
    event NewHighestBidder(address indexed auction, address bidder, uint256 totalBid);
    //event NewHighestBidderInUsd(address indexed auction, address bidder, uint64 managedBidderInUsd, uint256 totalBidInUsd);
    event NewHighestBidderInUsd(address indexed auction, address bidder, uint256 totalBidInUsd);
    event TokenRateUpdate(address indexed token, uint256 rate);
    event EtherRateUpdate(uint256 rate); // in usdt
    event Withdrawal(address indexed auction, address bidder, uint256 etherAmount, uint256 tokensBidInEther);
    event Charity(address indexed auction, address bidder, uint256 etherAmount, uint256 tokensAmount); // not used
    //event Finalized(address indexed auction, address highestBidder, uint64 highestManagedBidder, uint256 amount);
    event Finalized(address indexed auction, address highestBidder, uint256 amount);
    event FinalizedInUsd(address indexed auction, address highestBidderInUsd, uint256 amount);
    event FinalizedTokenTransfer(address indexed auction, address token, uint256 tokensBidInEther);
    event FinalizedEtherTransfer(address indexed auction, uint256 etherAmount);
    event ExtendedEndTime(address indexed auction, uint256 newEndtime);
    event Cancelled(address indexed auction);

    /*
     *  Modifiers
     */

    modifier onlyActive {
        // NB this modifier also serves as check that an auction exists (otherwise endSeconds == 0)
        ActionState storage auctionState = auctionStates[msg.sender];
        require (now < auctionState.endSeconds && !auctionState.cancelled);
        _;
    }

    modifier onlyBeforeEnd {
        // NB this modifier also serves as check that an auction exists (otherwise endSeconds == 0)
        ActionState storage auctionState = auctionStates[msg.sender];
        require (now < auctionState.endSeconds);
        _;
    }

    modifier onlyAfterEnd {
        ActionState storage auctionState = auctionStates[msg.sender];
        require (now > auctionState.endSeconds && auctionState.endSeconds > 0);
        _;
    }

    modifier onlyNotCancelled {
        ActionState storage auctionState = auctionStates[msg.sender];
        require (!auctionState.cancelled);
        _;
    }

    /*modifier onlyAllowedManagedBids {
        ActionState storage auctionState = auctionStates[msg.sender];
        require (auctionState.allowManagedBids);
        _;
    }*/

    /*
     * _rates are per big token (e.g. Ether vs. wei), i.e. number of wei per [number of tokens]*[10 ** decimals]
     */
    function AuctionHub 
        (address _wallet, address[] _tokens, uint256[] _rates, uint256[] _decimals, uint256 _etherRate)
        public
        BotManageable(_wallet)
    {
        // make sender a bot to avoid an additional step
        botsStartEndTime[msg.sender] = uint128(now) << 64;

        require(_tokens.length == _rates.length);
        require(_tokens.length == _decimals.length);

        // save initial token list
        for (uint i = 0; i < _tokens.length; i++) {
            require(_tokens[i] != 0x0);
            require(_rates[i] > 0);
            ERC20Basic token = ERC20Basic(_tokens[i]);
            tokenRates[token] = TokenRate(_rates[i], _decimals[i]);
            emit TokenRateUpdate(token, _rates[i]);
        }

        // save ether rate in usd
        require(_etherRate > 0);
        etherRate = _etherRate;
        emit EtherRateUpdate(_etherRate);
    }

    function stringToBytes32(string memory source) returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

    function createAuction(
        uint _endSeconds, 
        uint256 _maxTokenBidInEther,
        uint256 _minPrice,
        string _item
        //bool _allowManagedBids
    )
        onlyBot
        public
        returns (address)
    {
        require (_endSeconds > now);
        require(_maxTokenBidInEther <= 1000 ether);
        require(_minPrice > 0);

        Auction auction = new Auction(this);

        ActionState storage auctionState = auctionStates[auction];

        auctionState.endSeconds = _endSeconds;
        auctionState.maxTokenBidInEther = _maxTokenBidInEther;
        // пока не используется в коде
        auctionState.maxTokenBidInUsd = _maxTokenBidInEther.mul(etherRate).div(10 ** 2);
        auctionState.minPrice = _minPrice;
        //auctionState.allowManagedBids = _allowManagedBids;
        string memory item = _item;
        auctionState.item = stringToBytes32(item);

        emit NewAction(auction, _item);
        return address(auction);
    }

    function () 
        payable
        public
    {
        throw;
        // It's charity!
        // require(wallet.send(msg.value));
        // Charity(0x0, msg.sender, msg.value, 0);
    }

    function bid(address _bidder, uint256 _value, address _token, uint256 _tokensNumber)
        // onlyActive - inline check to reuse auctionState variable
        public
        returns (bool isHighest, bool isHighestInUsd)
    {
        ActionState storage auctionState = auctionStates[msg.sender];
        // same as onlyActive modifier, but we already have a variable here
        require (now < auctionState.endSeconds && !auctionState.cancelled);

        BidderState storage bidderState = auctionState.bidderStates[_bidder];
        
        uint256 totalBid;
        uint256 totalBidInUsd;

        if (_tokensNumber > 0) {
            (totalBid, totalBidInUsd) = tokenBid(msg.sender, _bidder,  _token, _tokensNumber);
        }else {
            require(_value > 0);

            // NB if current token bid == 0 we still could have previous token bids
            (totalBid, totalBidInUsd) = (bidderState.tokensBalanceInEther, bidderState.tokensBalanceInUsd);
        }

        uint256 etherBid = bidderState.etherBalance + _value;
        // error "CompilerError: Stack too deep, try removing local variables"
        
        bidderState.etherBalance = etherBid;      

        //totalBid = totalBid + etherBid + bidderState.managedBid;
        totalBid = totalBid + etherBid;
        //totalBidInUsd = totalBidInUsd + etherBidInUsd + bidderState.managedBidInUsd;
        

        if (totalBid > auctionState.highestBid && totalBid >= auctionState.minPrice) {
            auctionState.highestBid = totalBid;
            auctionState.highestBidder = _bidder;
            //auctionState.highestManagedBidder = 0;
            emit NewHighestBidder(msg.sender, _bidder, totalBid);
            if ((auctionState.endSeconds - now) < 1800) {
                /*uint256 newEnd = now + 1800;
                auctionState.endSeconds = newEnd;
                ExtendedEndTime(msg.sender, newEnd);*/
                //uint256 newEnd = now + 1800;
                // убираем увеличение времени аукциона на 30 мин. при высокой ставки в Ether
                /*auctionState.endSeconds = now + 1800;
                ExtendedEndTime(msg.sender, auctionState.endSeconds);*/
            }
            isHighest = true;
        }

        /*    
        uint256 etherBidInUsd = bidderState.etherBalanceInUsd + _value.mul(etherRate);
        bidderState.etherBalanceInUsd = etherBidInUsd;
        totalBidInUsd = totalBidInUsd + etherBidInUsd;*/
        uint256 etherBidInUsd = bidderState.etherBalanceInUsd + _value.mul(etherRate).div(10 ** 2);
        bidderState.etherBalanceInUsd = etherBidInUsd;
        totalBidInUsd = totalBidInUsd + etherBidInUsd;

        if (totalBidInUsd > auctionState.highestBidInUsd && totalBidInUsd >= auctionState.minPrice.mul(etherRate).div(10 ** 2)) {
            auctionState.highestBidInUsd = totalBidInUsd;
            auctionState.highestBidderInUsd = _bidder;
            //auctionState.highestManagedBidderInUsd = 0;
            emit NewHighestBidderInUsd(msg.sender, _bidder, totalBidInUsd);
            if ((auctionState.endSeconds - now) < 1800) {
                //uint256 newEndUsd = now + 1800;
                //auctionState.endSeconds = newEndUsd;
                //ExtendedEndTime(msg.sender, newEndUsd);
                //uint256 newEndUsd = now + 1800;
                auctionState.endSeconds = now + 1800;
                emit ExtendedEndTime(msg.sender, auctionState.endSeconds);
            }
            isHighestInUsd = true;
        }

        emit Bid(msg.sender, _bidder, totalBid, totalBid - etherBid, totalBidInUsd, totalBidInUsd - etherBidInUsd);        

        return (isHighest, isHighestInUsd);
    }

    function tokenBid(address _auction, address _bidder, address _token, uint256 _tokensNumber)
        internal
        returns (uint256 tokenBid, uint256 tokenBidInUsd)
    {
        // NB actual token transfer happens in auction contracts, which owns both ether and tokens
        // This Hub contract is for accounting

        ActionState storage auctionState = auctionStates[_auction];
        BidderState storage bidderState = auctionState.bidderStates[_bidder];
        
        uint256 totalBid = bidderState.tokensBalanceInEther;
        uint256 totalBidInUsd = bidderState.tokensBalanceInUsd;

        TokenRate storage tokenRate = tokenRates[_token];
        require(tokenRate.value > 0);

        // find token index
        uint256 index = bidderState.tokenBalances.length;
        for (uint i = 0; i < index; i++) {
            if (bidderState.tokenBalances[i].token == _token) {
                index = i;
                break;
            }
        }

        // array was empty/token not found - push empty to the end
        if (index == bidderState.tokenBalances.length) {
            bidderState.tokenBalances.push(TokenBalance(_token, _tokensNumber));
        } else {
            // safe math is already in transferFrom
            bidderState.tokenBalances[index].value += _tokensNumber;
        }
        
        //totalBid = totalBid + _tokensNumber.mul(tokenRate.value).div(10 ** tokenRate.decimals);
        
        totalBid = calcTokenTotalBid(totalBid, _token, _tokensNumber);
        //totalBidInUsd = totalBidInUsd + _tokensNumber.mul(tokenRate.value).mul(etherRate).div(10 ** 2).div(10 ** tokenRate.decimals);
        
        totalBidInUsd = calcTokenTotalBidInUsd(totalBidInUsd, _token, _tokensNumber);

        // !Note! зачем тут ограничивать макс ставку токена эфиром
        //require(totalBid <= auctionState.maxTokenBidInEther);

        bidderState.tokensBalanceInEther = totalBid;
        bidderState.tokensBalanceInUsd = totalBidInUsd;

        //TokenBid(_auction, _bidder, _token, _tokensNumber);
        //emit TokenBid(_auction, _bidder, _token, _tokensNumber, _tokensNumber.mul(tokenRate.value).div(10 ** tokenRate.decimals), _tokensNumber.mul(tokenRate.value).mul(etherRate).div(10 ** 2).div(10 ** tokenRate.decimals));
        emit TokenBid(_auction, _bidder, _token, _tokensNumber);
        return (totalBid, totalBidInUsd);
    }

    function calcTokenTotalBid(uint256 totalBid, address _token, uint256 _tokensNumber)
        internal
        //returns(uint256 _totalBid, uint256 _bidInEther){
        returns(uint256 _totalBid){
            TokenRate storage tokenRate = tokenRates[_token];
            // tokenRate.value is for a whole/big token (e.g. ether vs. wei) but _tokensNumber is in small/wei tokens, need to divide by decimals
            uint256 bidInEther = _tokensNumber.mul(tokenRate.value).div(10 ** tokenRate.decimals);
            //totalBid = totalBid + _tokensNumber.mul(tokenRate.value).div(10 ** tokenRate.decimals);
            totalBid += bidInEther;
            //return (totalBid, bidInEther);
            return totalBid;
        }
    
    function calcTokenTotalBidInUsd(uint256 totalBidInUsd, address _token, uint256 _tokensNumber)
        internal
        returns(uint256 _totalBidInUsd){
            TokenRate storage tokenRate = tokenRates[_token];
            uint256 bidInUsd = _tokensNumber.mul(tokenRate.value).mul(etherRate).div(10 ** 2).div(10 ** tokenRate.decimals);
            //totalBidInUsd = totalBidInUsd + _tokensNumber.mul(tokenRate.value).mul(etherRate).div(10 ** 2).div(10 ** tokenRate.decimals);
            totalBidInUsd += bidInUsd;
            return totalBidInUsd;
        }
   
    function totalDirectBid(address _auction, address _bidder)
        view
        public
        returns (uint256 _totalBid)
    {
        ActionState storage auctionState = auctionStates[_auction];
        BidderState storage bidderState = auctionState.bidderStates[_bidder];
        return bidderState.tokensBalanceInEther + bidderState.etherBalance;
    }

    function totalDirectBidInUsd(address _auction, address _bidder)
        view
        public
        returns (uint256 _totalBidInUsd)
    {
        ActionState storage auctionState = auctionStates[_auction];
        BidderState storage bidderState = auctionState.bidderStates[_bidder];
        return bidderState.tokensBalanceInUsd + bidderState.etherBalanceInUsd;
    }

    function setTokenRate(address _token, uint256 _tokenRate)
        onlyBot
        public
    {
        TokenRate storage tokenRate = tokenRates[_token];
        require(tokenRate.value > 0);
        tokenRate.value = _tokenRate;
        emit TokenRateUpdate(_token, _tokenRate);
    }

    function setEtherRate(uint256 _etherRate)
        onlyBot
        public
    {        
        require(_etherRate > 0);
        etherRate = _etherRate;
        emit EtherRateUpdate(_etherRate);
    }

    function withdraw(address _bidder)
        public
        returns (bool success)
    {
        ActionState storage auctionState = auctionStates[msg.sender];
        BidderState storage bidderState = auctionState.bidderStates[_bidder];

        bool sent; 

        // anyone could withdraw at any time except the highest bidder
        // if cancelled, the highest bidder could withdraw as well
        //require((_bidder != auctionState.highestBidder) || auctionState.cancelled);
        require((_bidder != auctionState.highestBidderInUsd) || auctionState.cancelled);
        uint256 tokensBalanceInEther = bidderState.tokensBalanceInEther;
        uint256 tokensBalanceInUsd = bidderState.tokensBalanceInUsd;
        if (bidderState.tokenBalances.length > 0) {
            for (uint i = 0; i < bidderState.tokenBalances.length; i++) {
                uint256 tokenBidValue = bidderState.tokenBalances[i].value;
                if (tokenBidValue > 0) {
                    bidderState.tokenBalances[i].value = 0;
                    sent = Auction(msg.sender).sendTokens(bidderState.tokenBalances[i].token, _bidder, tokenBidValue);
                    require(sent);
                }
            }
            bidderState.tokensBalanceInEther = 0;
            bidderState.tokensBalanceInUsd = 0;
        } else {
            require(tokensBalanceInEther == 0);
        }

        uint256 etherBid = bidderState.etherBalance;
        if (etherBid > 0) {
            bidderState.etherBalance = 0;
            bidderState.etherBalanceInUsd = 0;
            sent = Auction(msg.sender).sendEther(_bidder, etherBid);
            require(sent);
        }

        emit Withdrawal(msg.sender, _bidder, etherBid, tokensBalanceInEther);
        
        return true;
    }

    function finalize()
        // onlyNotCancelled - inline check to reuse auctionState variable
        // onlyAfterEnd - inline check to reuse auctionState variable
        public
        returns (bool)
    {
        ActionState storage auctionState = auctionStates[msg.sender];
        // same as onlyNotCancelled+onlyAfterEnd modifiers, but we already have a variable here
        require (!auctionState.finalized && now > auctionState.endSeconds && auctionState.endSeconds > 0 && !auctionState.cancelled);

        // если есть хоть одна ставка
        if (auctionState.highestBidder != address(0)) {
            bool sent; 
            BidderState storage bidderState = auctionState.bidderStates[auctionState.highestBidder];
            uint256 tokensBalanceInEther = bidderState.tokensBalanceInEther;
            uint256 tokensBalanceInUsd = bidderState.tokensBalanceInUsd;
            if (bidderState.tokenBalances.length > 0) {
                for (uint i = 0; i < bidderState.tokenBalances.length; i++) {
                    uint256 tokenBid = bidderState.tokenBalances[i].value;
                    if (tokenBid > 0) {
                        bidderState.tokenBalances[i].value = 0;
                        sent = Auction(msg.sender).sendTokens(bidderState.tokenBalances[i].token, wallet, tokenBid);
                        require(sent);
                        emit FinalizedTokenTransfer(msg.sender, bidderState.tokenBalances[i].token, tokenBid);
                    }
                }
                bidderState.tokensBalanceInEther = 0;
                bidderState.tokensBalanceInUsd = 0;
            } else {
                require(tokensBalanceInEther == 0);
            }
            
            uint256 etherBid = bidderState.etherBalance;
            if (etherBid > 0) {
                bidderState.etherBalance = 0;
                bidderState.etherBalanceInUsd = 0;
                sent = Auction(msg.sender).sendEther(wallet, etherBid);
                require(sent);
                emit FinalizedEtherTransfer(msg.sender, etherBid);
            }
        }

        auctionState.finalized = true;
        emit Finalized(msg.sender, auctionState.highestBidder, auctionState.highestBid);
        emit FinalizedInUsd(msg.sender, auctionState.highestBidderInUsd, auctionState.highestBidInUsd);

        return true;
    }

    function cancel()
        // onlyActive - inline check to reuse auctionState variable
        public
        returns (bool success)
    {
        ActionState storage auctionState = auctionStates[msg.sender];
        // same as onlyActive modifier, but we already have a variable here
        require (now < auctionState.endSeconds && !auctionState.cancelled);

        auctionState.cancelled = true;
        emit Cancelled(msg.sender);
        return true;
    }

}


contract Auction {

    AuctionHub public owner;

    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }

    modifier onlyBot {
        require(owner.isBot(msg.sender));
        _;
    }

    modifier onlyNotBot {
        require(!owner.isBot(msg.sender));
        _;
    }

    function Auction(
        address _owner
    ) 
        public 
    {
        require(_owner != address(0x0));
        owner = AuctionHub(_owner);
    }

    function () 
        payable
        public
    {
        owner.bid(msg.sender, msg.value, 0x0, 0);
    }

    function bid(address _token, uint256 _tokensNumber)
        payable
        public
        returns (bool isHighest, bool isHighestInUsd)
    {
        if (_token != 0x0 && _tokensNumber > 0) {
            require(ERC20Basic(_token).transferFrom(msg.sender, this, _tokensNumber));
        }
        return owner.bid(msg.sender, msg.value, _token, _tokensNumber);
    }   

    function sendTokens(address _token, address _to, uint256 _amount)
        onlyOwner
        public
        returns (bool)
    {
        return ERC20Basic(_token).transfer(_to, _amount);
    }

    function sendEther(address _to, uint256 _amount)
        onlyOwner
        public
        returns (bool)
    {
        return _to.send(_amount);
    }

    function withdraw()
        public
        returns (bool success)
    {
        return owner.withdraw(msg.sender);
    }

    function finalize()
        onlyBot
        public
        returns (bool)
    {
        return owner.finalize();
    }

    function cancel()
        onlyBot
        public
        returns (bool success)
    {
        return  owner.cancel();
    }

    function totalDirectBid(address _bidder)
        public
        view
        returns (uint256)
    {
        return owner.totalDirectBid(this, _bidder);
    }

    function totalDirectBidInUsd(address _bidder)
        public
        view
        returns (uint256)
    {
        return owner.totalDirectBidInUsd(this, _bidder);
    }

    function maxTokenBidInEther()
        public
        view
        returns (uint256)
    {
        //var (,maxTokenBidInEther,,,,,,,,,,,) = owner.auctionStates(this);
        //var (endSeconds,maxTokenBidInEther,minPrice,highestBid,highestBidder,allowManagedBids,cancelled,finalized,maxTokenBidInUsd,highestBidInUsd,highestBidderInUsd,bidderStates) = owner.auctionStates(this);
        //(endSeconds,maxTokenBidInEther,minPrice,highestBid,highestBidder,cancelled,finalized,maxTokenBidInUsd,highestBidInUsd,highestBidderInUsd,item) = owner.auctionStates(this);
        var (,maxTokenBidInEther,,,,,,,,,) = owner.auctionStates(this);
        return maxTokenBidInEther;
    }

    function maxTokenBidInUsd()
        public
        view
        returns (uint256)
    {
        //var (,,,,,,,,,,maxTokenBidInUsd,,) = owner.auctionStates(this);
        var (endSeconds,maxTokenBidInEther,minPrice,highestBid,highestBidder,cancelled,finalized,maxTokenBidInUsd,highestBidInUsd,highestBidderInUsd,item) = owner.auctionStates(this);
        return maxTokenBidInUsd;
    }

    function endSeconds()
        public
        view
        returns (uint256)
    {
        //var (endSeconds,,,,,,,,,) = owner.auctionStates(this);
        //(endSeconds,maxTokenBidInEther,minPrice,highestBid,highestBidder,cancelled,finalized,maxTokenBidInUsd,highestBidInUsd,highestBidderInUsd,item) = owner.auctionStates(this);
        var (endSeconds,,,,,,,,,,) = owner.auctionStates(this);
        return endSeconds;
    }

    function item()
        public
        view
        returns (string)
    {
        var (endSeconds,maxTokenBidInEther,minPrice,highestBid,highestBidder,cancelled,finalized,maxTokenBidInUsd,highestBidInUsd,highestBidderInUsd,item) = owner.auctionStates(this);
        //var (endSeconds,maxTokenBidInEther,minPrice,highestBid,highestBidder,allowManagedBids,cancelled,finalized,maxTokenBidInUsd,highestBidInUsd,highestBidderInUsd,bidderStates,item) = owner.auctionStates(this);
        bytes memory bytesArray = new bytes(32);
        for (uint256 i; i < 32; i++) {
            bytesArray[i] = item[i];
            }
        return string(bytesArray);
    }

    function minPrice()
        public
        view
        returns (uint256)
    {
        //var (,,minPrice,,,,,,,) = owner.auctionStates(this);
        var (endSeconds,maxTokenBidInEther,minPrice,highestBid,highestBidder,cancelled,finalized,maxTokenBidInUsd,highestBidInUsd,highestBidderInUsd,item) = owner.auctionStates(this);
        return minPrice;
    }

    function cancelled()
        public
        view
        returns (bool)
    {
        //var (,,,,,,cancelled,,,) = owner.auctionStates(this);
        var (endSeconds,maxTokenBidInEther,minPrice,highestBid,highestBidder,cancelled,finalized,maxTokenBidInUsd,highestBidInUsd,highestBidderInUsd,item) = owner.auctionStates(this);
        return cancelled;
    }

    function finalized()
        public
        view
        returns (bool)
    {
        //var (,,,,,,,finalized,,) = owner.auctionStates(this);
        var (endSeconds,maxTokenBidInEther,minPrice,highestBid,highestBidder,cancelled,finalized,maxTokenBidInUsd,highestBidInUsd,highestBidderInUsd,item) = owner.auctionStates(this);
        return finalized;
    }

    function highestBid()
        public
        view
        returns (uint256)
    {
        //var (,,,highestBid,,,,,,,,,) = owner.auctionStates(this);
        var (endSeconds,maxTokenBidInEther,minPrice,highestBid,highestBidder,cancelled,finalized,maxTokenBidInUsd,highestBidInUsd,highestBidderInUsd,item) = owner.auctionStates(this);
        // ,,,,,,,,,,,,
        // ,,,highestBid,,,,,,,,,
        return highestBid;
    }

    function highestBidInUsd()
        public
        view
        returns (uint256)
    {
        //var (,,,,,,,,,,,highestBidInUsd,) = owner.auctionStates(this);
        var (endSeconds,maxTokenBidInEther,minPrice,highestBid,highestBidder,cancelled,finalized,maxTokenBidInUsd,highestBidInUsd,highestBidderInUsd,item) = owner.auctionStates(this);
        // ,,,,,,,,,,,,
        return highestBidInUsd;
    }

    function highestBidder()
        public
        view
        returns (address)
    {
        //var (,,,,highestBidder,,,,,) = owner.auctionStates(this);
        //var (,,,,highestBidder,,,,,,,,) = owner.auctionStates(this);
        var (endSeconds,maxTokenBidInEther,minPrice,highestBid,highestBidder,cancelled,finalized,maxTokenBidInUsd,highestBidInUsd,highestBidderInUsd,item) = owner.auctionStates(this);
        // ,,,,highestBidder,,,,,,,,
        return highestBidder;
    }

    
    function highestBidderInUsd()
        public
        view
        returns (address)
    {
        //var (,,,,highestBidder,,,,,) = owner.auctionStates(this);
        //var (,,,,,,,,,,,,highestBidderInUsd) = owner.auctionStates(this);
        var (endSeconds,maxTokenBidInEther,minPrice,highestBid,highestBidder,cancelled,finalized,maxTokenBidInUsd,highestBidInUsd,highestBidderInUsd,item) = owner.auctionStates(this);
        // ,,,,,,,,,,,,
        return highestBidderInUsd;
    }

    /*function highestManagedBidder()
        public
        view
        returns (uint64)
    {
        //var (,,,,,highestManagedBidder,,,,) = owner.auctionStates(this);
        var (,,,,,highestManagedBidder,,,,,,,) = owner.auctionStates(this);
        // ,,,,,highestManagedBidder,,,,,,,
        return highestManagedBidder;
    }*/


    /*function allowManagedBids()
        public
        view
        returns (bool)
    {
        //var (,,,,,,allowManagedBids,,,) = owner.auctionStates(this);
        var (endSeconds,maxTokenBidInEther,minPrice,highestBid,highestBidder,allowManagedBids,cancelled,finalized,maxTokenBidInUsd,highestBidInUsd,highestBidderInUsd,bidderStates) = owner.auctionStates(this);
        return allowManagedBids;
    }*/


    // mapping(address => uint256) public etherBalances;
    // mapping(address => uint256) public tokenBalances;
    // mapping(address => uint256) public tokenBalancesInEther;
    // mapping(address => uint256) public managedBids;
    
    // bool allowManagedBids;
}

// File: contracts/TokenStarsAuction.sol

pragma solidity ^0.4.18;


contract TokenStarsAuctionHub is AuctionHub {
    //real
    address public ACE = 0x06147110022B768BA8F99A8f385df11a151A9cc8;
    //renkeby
    //address public ACE = 0xa0813ad2e1124e0779dc04b385f5229776dcbba8;
    //real
    address public TEAM = 0x1c79ab32C66aCAa1e9E81952B8AAa581B43e54E7;
    // rinkeby
    //address public TEAM = 0x10b882e7da9ef31ef6e0e9c4c5457dfaf8dd9a24;
    //address public wallet = 0x963dF7904cF180aB2C033CEAD0be8687289f05EC;
    address public wallet = 0x0C9b07209750BbcD1d1716DA52B591f371eeBe77;//
    address[] public tokens = [ACE, TEAM];
    // ACE = 0.01 ETH; 
    // TEAM = 0,002 ETH
    uint256[] public rates = [10000000000000000, 2000000000000000];
    uint256[] public decimals = [0, 4];
    // ETH = $138.55
    uint256 public etherRate = 13855;

    function TokenStarsAuctionHub()
        public
        AuctionHub(wallet, tokens, rates, decimals, etherRate)
    {
    }

    function createAuction(
        address _wallet,
        uint _endSeconds, 
        uint256 _maxTokenBidInEther,
        uint256 _minPrice,
        string _item
        //bool _allowManagedBids
    )
        onlyBot
        public
        returns (address)
    {
        require (_endSeconds > now);
        require(_maxTokenBidInEther <= 1000 ether);
        require(_minPrice > 0);

        Auction auction = new TokenStarsAuction(this);

        ActionState storage auctionState = auctionStates[auction];

        auctionState.endSeconds = _endSeconds;
        auctionState.maxTokenBidInEther = _maxTokenBidInEther;
        auctionState.minPrice = _minPrice;
        //auctionState.allowManagedBids = _allowManagedBids;
        string memory item = _item;
        auctionState.item = stringToBytes32(item);

        NewAction(auction, _item);
        return address(auction);
    }
}

contract TokenStarsAuctionHubMock is AuctionHub {
    uint256[] public rates = [2400000000000000, 2400000000000000];
    uint256[] public decimals = [0, 4];
    uint256 public etherRate = 13855;

    function TokenStarsAuctionHubMock(address _wallet, address[] _tokens)
        public
        AuctionHub(_wallet, _tokens, rates, decimals, etherRate)
    {
    }

    function createAuction(
        uint _endSeconds, 
        uint256 _maxTokenBidInEther,
        uint256 _minPrice,
        string _item
        //bool _allowManagedBids
    )
        onlyBot
        public
        returns (address)
    {
        require (_endSeconds > now);
        require(_maxTokenBidInEther <= 1000 ether);
        require(_minPrice > 0);

        Auction auction = new TokenStarsAuction(this);

        ActionState storage auctionState = auctionStates[auction];

        auctionState.endSeconds = _endSeconds;
        auctionState.maxTokenBidInEther = _maxTokenBidInEther;
        auctionState.maxTokenBidInUsd = _maxTokenBidInEther.mul(etherRate).div(10 ** 2);
        auctionState.minPrice = _minPrice;
        //auctionState.allowManagedBids = _allowManagedBids;
        string memory item = _item;
        auctionState.item = stringToBytes32(item);

        NewAction(auction, _item);
        return address(auction);
    }
}

contract TokenStarsAuction is Auction {
        
    function TokenStarsAuction(
        address _owner) 
        public
        Auction(_owner)
    {
        
    }

    function bidAce(uint256 _tokensNumber)
        payable
        public
        returns (bool isHighest, bool isHighestInUsd)
    {
        return super.bid(TokenStarsAuctionHub(owner).ACE(), _tokensNumber);
    }

    function bidTeam(uint256 _tokensNumber)
        payable
        public
        returns (bool isHighest, bool isHighestInUsd)
    {
        return super.bid(TokenStarsAuctionHub(owner).TEAM(), _tokensNumber);
    }
}