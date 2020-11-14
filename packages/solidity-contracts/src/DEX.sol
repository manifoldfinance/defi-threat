/**
 * Source Code first verified at https://etherscan.io on Thursday, March 14, 2019
 (UTC) */

pragma solidity ^0.4.25;

contract SafeMath {
  function Sub(uint128 a, uint128 b) pure public returns (uint128) {
    assert(b <= a);
    return a - b;
  }

  function Add(uint128 a, uint128 b) pure public returns (uint128) {
    uint128 c = a + b;
    assert(c>=a && c>=b);
    return c;
  }
}

contract Token { 
  function totalSupply() public view returns (uint256 supply);
  function balanceOf(address _owner) public view returns (uint256 balance);
  function transfer(address _to, uint256 _value) public returns (bool success);
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
  function approve(address _spender, uint256 _value) public returns (bool success);
  function allowance(address _owner, address _spender) public view returns (uint256 remaining);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract DEX is SafeMath
{
    uint32 public lastTransferId = 1;
    event NewDeposit(uint32 indexed prCode, uint32 indexed accountId, uint128 amount, uint64 timestamp, uint32 lastTransferId);
    event NewWithdraw(uint32 indexed prCode, uint32 indexed accountId, uint128 amount, uint64 timestamp, uint32 lastTransferId);
    uint32 public lastNewOrderId = 1;
    event NewOrder(uint32 indexed prTrade, uint32 indexed prBase, uint32 indexed accountId, uint32 id, bool isSell, uint80 price, uint104 qty, uint32 lastNewOrderId);
    event NewCancel(uint32 indexed prTrade, uint32 indexed prBase, uint32 indexed accountId, uint32 id, bool isSell, uint80 price, uint104 qt, uint32 lastNewOrderId);
    event NewBestBidAsk(uint32 indexed prTrade, uint32 indexed prBase, bool isBid, uint80 price);
    uint32 public lastTradeId = 1;
    event NewTrade(uint32 indexed prTrade, uint32 prBase, uint32 indexed bidId, uint32 indexed askId, uint32 accountIdBid, uint32 accountIdAsk, bool isSell, uint80 price, uint104 qty, uint32 lastTradeId, uint64 timestamp);
    
    uint256 public constant basePrice = 10000000000;
    uint80 public constant maxPrice = 10000000000000000000001;
    uint104 public constant maxQty = 1000000000000000000000000000001;
    uint128 public constant maxBalance = 1000000000000000000000000000000000001;
    bool public isContractUse;
    
    constructor() public
    {
        owner = msg.sender;
        operator = owner;
        AddOwner();
        AddProduct(18, 0x0);
        //lastProductId = 1; // productId == 1 -> ETH 0x0
        isContractUse = true;
    }
    
    address public owner;
    // Functions with this modifier can only be executed by the owner
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    address public operator;
    modifier onlyOperator() {
        require(msg.sender == operator);
        _;
    }
    function transferOperator(address _operator) onlyOwner public {
        operator = _operator;
    }
    
    modifier onlyExOwner()  {
        require(owner_id[msg.sender] != 0);
        _;
    }
    
    modifier onlyContractUse {
        require(isContractUse == true);
        _;
    }
    function SetIsContractUse(bool _isContractUse) onlyOperator public 
    {
        isContractUse = _isContractUse;
    }
    
    uint32 public lastOwnerId;
    uint256 public newOwnerFee;
    mapping (uint32 => address) id_owner;
    mapping (address => uint32) owner_id;
    mapping (uint32 => uint8) ownerId_takerFeeRateLocal;
    mapping (uint32 => uint32) ownerId_accountId;
    
    function DeleteOwner(uint32 orderId) onlyOperator public 
    {
        require(lastOwnerId >= orderId && orderId > 0);
        owner_id[id_owner[orderId]] = 0;
    }
    
    function AddOwner() public payable 
    {
        require(msg.value >= newOwnerFee);
        require(owner_id[msg.sender] == 0);
        
        owner_id[msg.sender] = ++lastOwnerId;
        id_owner[lastOwnerId] = msg.sender;
        
        ownerId_accountId[lastOwnerId] = FindOrAddAccount();
        prCode_AccountId_Balance[1][ownerId_accountId[1]].available += uint128(msg.value);
        //overflow safe: eth balance & trasnfer << 2^128
    }
    function SetOwnerFee(uint256 ownerFee) onlyOperator public
    {
        newOwnerFee = ownerFee;
    }
    function GetOwnerList() view public returns (address[] owners, uint32[] ownerIds)
    {
        owners = new address[](lastOwnerId);
        ownerIds = new uint32[](lastOwnerId);
        
        for (uint32 i = 1; i <= lastOwnerId; i++)
        {
            owners[i - 1] = id_owner[i];
            ownerIds[i - 1] = i;
        }
    }
    function setTakerFeeRateLocal(uint8 _takerFeeRate) public
    {
        require (_takerFeeRate <= 100);
        uint32 ownerId = owner_id[msg.sender];
        require(ownerId != 0);
        ownerId_takerFeeRateLocal[ownerId] = _takerFeeRate;//bp
    }
    function getTakerFeeRateLocal(uint32 ownerId) public view returns (uint8)/////
    {
        return ownerId_takerFeeRateLocal[ownerId];//bp
    }
    
    function airDrop(uint32 prCode, uint32[] accountIds, uint104[] qtys) public
    {
        require(owner_id[msg.sender] != 0);
        //uint32 ownerId = owner_id[msg.sender];
        uint32 accountId = FindOrRevertAccount();// ownerId_accountId[owner_id[msg.sender]];
        require(accountId_freeze[accountId] == false);
        uint256 n = accountIds.length;
        require(n == qtys.length);// && n <= 1000000);
        
        uint128 sum = 0;
        for (uint32 i = 0; i < n; i++)
        {
            sum += qtys[i];
        }
        
        prCode_AccountId_Balance[prCode][accountId].available = Sub(prCode_AccountId_Balance[prCode][accountId].available, sum); 
        
        for (i = 0; i < n; i++)
        {
            prCode_AccountId_Balance[prCode][accountIds[i]].available += qtys[i];
        }
    }
    
    struct ProductInfo
    {
        uint256 divider;
        bool isTradeBid;
        bool isTradeAsk;
        bool isDeposit;
        bool isWithdraw;
        uint32 ownerId;
        uint104 minQty;
    }
    
    uint32 public lastProductId;
    uint256 public newProductFee;
    mapping (uint32 => address) prCode_product;
    mapping (address => uint32) product_prCode;
    mapping (uint32 => ProductInfo) prCode_productInfo;
    function AddProduct(uint256 decimals, address product) payable onlyExOwner public
    {
        require(msg.value >= newProductFee);
        require(product_prCode[product] == 0);
        require(decimals <= 18);
        
        product_prCode[product] = ++lastProductId;  
        prCode_product[lastProductId] = product;
        
        ProductInfo memory productInfo;
        productInfo.divider = 10 ** decimals; // max = 10 ^ 18
        productInfo.ownerId = owner_id[msg.sender];
        //productInfo.isDeposit = isDeposit;
        prCode_productInfo[lastProductId] = productInfo;
        
        prCode_AccountId_Balance[1][ownerId_accountId[1]].available += uint128(msg.value);
    }
    function SetProductInfo(uint32 prCode, bool isTradeBid, bool isTradeAsk, bool isDeposit, bool isWithdraw, uint104 _minQty) public
    {
        ProductInfo storage prInfo = prCode_productInfo[prCode];
        
        require(msg.sender == operator || owner_id[msg.sender] == prInfo.ownerId );
        
        prInfo.isTradeBid = isTradeBid;
        prInfo.isTradeAsk = isTradeAsk;
        prInfo.isDeposit = isDeposit;
        prInfo.isWithdraw = isWithdraw;
        prInfo.minQty = _minQty;
    }/*
    function SetProductMinQty(uint32 prCode, uint104 _minQty) public
    {
        ProductInfo storage prInfo = prCode_productInfo[prCode];
        require(msg.sender == operator || owner_id[msg.sender] == prInfo.ownerId );
        
        prInfo.minQty = _minQty;
    }*/
    function SetProductFee(uint256 productFee) onlyOperator public
    {
        newProductFee = productFee;
    }
    function GetProductList() view public returns (address[] products, uint32[] productIds)
    {
        products = new address[](lastProductId);
        productIds = new uint32[](lastProductId);
        
        for (uint32 i = 1; i <= lastProductId; i++)
        {
            products[i - 1] = prCode_product[i];
            productIds[i - 1] = i;
        }
    }
    function GetProductInfo(address product) view public returns (uint32 prCode, uint256 divider, bool isTradeBid, bool isTradeAsk, bool isDeposit, bool isWithdraw, uint32 ownerId, uint104 minQty)
    {
        prCode = product_prCode[product];
        require(prCode != 0);
        
        divider = prCode_productInfo[prCode].divider;
        isTradeBid = prCode_productInfo[prCode].isTradeBid;
        isTradeAsk = prCode_productInfo[prCode].isTradeAsk;
        isDeposit = prCode_productInfo[prCode].isDeposit;
        isWithdraw = prCode_productInfo[prCode].isWithdraw;
        ownerId = prCode_productInfo[prCode].ownerId;
        minQty = prCode_productInfo[prCode].minQty;
    }/*
    function AcceptProduct(uint32 prCode, bool isTrade) onlyOperator public
    {
        prCode_productInfo[prCode].isTrade = isTrade;
    }*/
    
    uint32 public lastAcccountId;
    mapping (uint32 => uint8) id_announceLV; //0: None, 1: Trade, 2:Balance, 3:DepositWithdrawal, 4:OpenOrder
    mapping (uint32 => address) id_account;
    mapping (uint32 => bool) accountId_freeze;
    mapping (address => uint32) account_id;
    
    function FindOrAddAccount() private returns (uint32)
    {
        if (account_id[msg.sender] == 0)
        {
            account_id[msg.sender] = ++lastAcccountId;
            id_account[lastAcccountId] = msg.sender;
        }
        return account_id[msg.sender];
    }
    function FindOrRevertAccount() private view returns (uint32)
    {
        uint32 accountId = account_id[msg.sender];
        require(accountId != 0);
        return accountId;
    }
    /*
    function GetAccountList() view onlyOperator public returns (address[] owners)//, uint32[] Ids)// Delete Later`
    {
        owners = new address[](lastAcccountId);
        //Ids = new uint32[](lastAcccountId);
        
        for (uint32 i = 1; i <= lastAcccountId; i++)
        {
            owners[i - 1] = id_account[i];
            //Ids[i - 1] = i;
        }
    }*/
    function GetMyAccountId() view public returns (uint32)
    {
        return account_id[msg.sender];
    }
    function GetAccountId(address account) view public returns (uint32)
    {
        return account_id[account];
    }
    function GetMyAnnounceLV() view public returns (uint32)
    {
        return id_announceLV[account_id[msg.sender]];
    }
    function ChangeAnnounceLV(uint8 announceLV) public
    {
        id_announceLV[FindOrRevertAccount()] = announceLV;
    }
    function SetFreezeByAddress(bool isFreeze, address account) onlyOperator public
    {
        uint32 accountId = account_id[account];
        
        if (accountId != 0)
        {
            accountId_freeze[accountId] = isFreeze;
        }
    }
    
    struct Balance
    {
        uint128 reserved;
        uint128 available;
    }
    
    struct ListItem
    {
        uint32 prev;
        uint32 next;
    }
    
    struct OrderLink
    {
        //uint32 orderN;
        uint32 firstId;
        uint32 lastId;
        uint80 nextPrice;
        uint80 prevPrice;
        mapping (uint32 => ListItem) id_orderList;
    }
    
    struct Order
    {
        uint32 ownerId;
        uint32 accountId;
        uint32 prTrade;
        uint32 prBase;
        uint104 qty;
        uint80 price;
        bool isSell;
        //uint64 timestamp;
    }

    uint32 public lastOrderId;
    mapping (uint32 => Order) id_Order;
        
    struct OrderBook
    {
        uint8 tickSize;
        
        uint80 bestBidPrice;
        uint80 bestAskPrice;

        mapping (uint80 => OrderLink) bidPrice_Order;
        mapping (uint80 => OrderLink) askPrice_Order;
    }
    mapping (uint32 => mapping (uint32 => OrderBook)) basePID_tradePID_orderBook;
    function SetOrderBookTickSize(uint32 prTrade, uint32 prBase, uint8 _tickSize) onlyOperator public
    {
        basePID_tradePID_orderBook[prBase][prTrade].tickSize = _tickSize;
    }
    
    mapping (uint32 => mapping (uint32 => Balance)) prCode_AccountId_Balance;
    
    //trading fee
    uint8 public takerFeeRateMain;
    function setTakerFeeRateMain(uint8 _takerFeeRateMain) onlyOperator public
    {
        if (_takerFeeRateMain <= 100)
            takerFeeRateMain = _takerFeeRateMain;//bp
    }
    
    struct OpenOrder
    {
        uint32 startId;
        mapping(uint32 => ListItem) id_orderList;
    }
    mapping(uint32 => OpenOrder) accountId_OpenOrder;
    function AddOpenOrder(uint32 accountId, uint32 orderId) private
    {
        OpenOrder memory openOrder = accountId_OpenOrder[accountId];

        if (openOrder.startId != 0)
        {
            accountId_OpenOrder[accountId].id_orderList[openOrder.startId].prev = orderId;
            accountId_OpenOrder[accountId].id_orderList[orderId].next = openOrder.startId;
        }
        accountId_OpenOrder[accountId].startId = orderId;
    }
    function RemoveOpenOrder(uint32 accountId, uint32 orderId) private
    {
        OpenOrder memory openOrder = accountId_OpenOrder[accountId];

        uint32 nextId = accountId_OpenOrder[accountId].id_orderList[orderId].next;
        uint32 prevId = accountId_OpenOrder[accountId].id_orderList[orderId].prev;

        if (nextId != 0)
        {
            accountId_OpenOrder[accountId].id_orderList[nextId].prev = prevId;
        }

        if (prevId != 0)
        {
            accountId_OpenOrder[accountId].id_orderList[prevId].next = nextId;
        }
        
        if (openOrder.startId == orderId)
        {
            accountId_OpenOrder[accountId].startId = nextId;
        }
    }

    struct DWrecord
    {
        uint32 prCode;
        bool isDeposit;
        uint128 qty;
        uint64 timestamp;
    }
    
    struct DWrecords
    {
        uint32 N;
        mapping (uint32 => DWrecord) N_DWrecord;
    }
    mapping (uint32 => DWrecords) AccountId_DWrecords;
    function RecordDW(uint32 accountId, uint32 prCode, bool isDeposit, uint128 qty) private
    {
        //DWrecords storage dWrecords = AccountId_DWrecords[accountId];

        DWrecord memory dW;
        dW.isDeposit = isDeposit;
        dW.prCode = prCode;
        dW.qty = qty;
        dW.timestamp = uint64(now);

        AccountId_DWrecords[accountId].N_DWrecord[++AccountId_DWrecords[accountId].N] = dW;
        
        if (isDeposit == true)
            emit NewDeposit(prCode, accountId, qty, dW.timestamp, lastTransferId++);
        else 
            emit NewWithdraw(prCode, accountId, qty, dW.timestamp, lastTransferId++);
    }
    function GetDWrecords(uint32 N, uint32 accountId) view public returns (uint32[] prCode, bool[] isDeposit, uint128[] qty, uint64[] timestamp)
    {
        //require (id_announceLV[accountId] > 2 || accountId == account_id[msg.sender]);
        checkAnnounceLV(accountId, 3);
        
        DWrecords storage dWrecords = AccountId_DWrecords[accountId];
        uint32 n = dWrecords.N;
        
        if (n > N)
            n = N;
            
        prCode = new uint32[](n);
        isDeposit = new bool[](n);
        qty = new uint128[](n);
        timestamp = new uint64[](n);

        for (uint32 i = dWrecords.N; i > dWrecords.N - n; i--)
        {
            N = dWrecords.N - i;
            prCode[N] = dWrecords.N_DWrecord[i].prCode;//Bug0309
            isDeposit[N] = dWrecords.N_DWrecord[i].isDeposit;//Bug0309
            qty[N] = dWrecords.N_DWrecord[i].qty;//Bug0309
            timestamp[N] = dWrecords.N_DWrecord[i].timestamp;//Bug0309
        }
    }
    
/////////////////
    function depositETH() payable public
    {
        uint32 accountId = FindOrAddAccount();
        prCode_AccountId_Balance[1][accountId].available = Add(prCode_AccountId_Balance[1][accountId].available, uint128(msg.value));
        RecordDW(accountId, 1, true, uint104(msg.value));
    }

    function withdrawETH(uint104 amount) public
    {
        uint32 accountId = FindOrRevertAccount();
        require(accountId_freeze[accountId] == false);
        prCode_AccountId_Balance[1][accountId].available = Sub(prCode_AccountId_Balance[1][accountId].available, amount);
        require(msg.sender.send(amount));
        RecordDW(accountId, 1, false,  amount);
    }

    function depositWithdrawToken(uint128 amount, bool isDeposit, address prAddress) public
    {
        uint32 prCode = product_prCode[prAddress];
        require(amount < maxBalance && prCode != 0);
        uint32 accountId = FindOrAddAccount();
        require(accountId_freeze[accountId] == false);
        //require(accountId != 0);
        
        if (isDeposit == true)
        {
            require(prCode_productInfo[prCode].isDeposit == true);//Bug0310
            require(Token(prAddress).transferFrom(msg.sender, this, amount));
            prCode_AccountId_Balance[prCode][accountId].available = Add(prCode_AccountId_Balance[prCode][accountId].available, amount);
            require (prCode_AccountId_Balance[prCode][accountId].available < maxBalance);
        }
        else
        {
            require(prCode_productInfo[prCode].isWithdraw == true);//Bug0310
            prCode_AccountId_Balance[prCode][accountId].available = Sub(prCode_AccountId_Balance[prCode][accountId].available, amount);
            require(Token(prAddress).transfer(msg.sender, amount));    
        }
        RecordDW(accountId, prCode, isDeposit, amount);
    }
    
    function emergencyWithdrawal(uint32 prCode, uint256 amount) onlyOwner public
    {
        require (isContractUse == false);//Added
        if (prCode == 1)
            require(msg.sender.send(amount));
        else
            Token(prCode_product[prCode]).transfer(msg.sender, amount);
    }
 /*
    function withdrawToken(address prAddress, uint128 amount) public
    {        
        uint32 prCode = product_prCode[prAddress];
        require(amount < maxBalance && prCode != 0);
        uint32 accountId = account_id[msg.sender];
        require(accountId != 0);
        
        //Balance storage balance = prCode_AccountId_Balance[prCode][accountId];
        prCode_AccountId_Balance[prCode][accountId].available = SafeMath.Sub(prCode_AccountId_Balance[prCode][accountId].available, amount);
        require(Token(prAddress).transfer(msg.sender, amount));
        RecordDW(accountId, prCode, false, amount);
    }
    /*
    function withdrawToken(address prAddress, uint128 amount, address toAddress) public
    {        
        uint32 prCode = product_prCode[prAddress];
        require(amount < maxBalance && prCode != 0);
        
        uint32 accountId = account_id[msg.sender];
        require(accountId != 0);
        
        //Balance storage balance = prCode_AccountId_Balance[prCode][accountId];
        prCode_AccountId_Balance[prCode][accountId].available = SafeMath.Sub(prCode_AccountId_Balance[prCode][accountId].available, amount);
        require(Token(prAddress).transfer(toAddress, amount));
        RecordDW(accountId, prCode, false, amount);
    }*/
    /*
    uint32 public maxOrderN;
    function SetMaxOrderN(uint32 _maxOrderN) public onlyOwner
    {
        maxOrderN = _maxOrderN;
    }*/
    function GetNextTick(bool isAsk, uint80 price, uint8 n) public pure returns (uint80)
    {
        if (price > 0)
        {
            uint80 tick = GetTick(price, n);
    
            if (isAsk == true)
                return (((price - 1) / tick) + 1) * tick;
            else
                return (price / tick) * tick;
        }
        else
        {
            return price;
        }
    }
    
    function GetTick(uint80 price, uint8 n)  public pure returns  (uint80)
    {
        if (n < 1)
            n = 1;
        
        uint80 x = 1;
        
        for (uint8 i=1; i <= n / 2; i++)
        {
            x *= 10;
        }
        
        if (price < 10 * x)
            return 1;
        else
        {
            uint80 tick = 10000;
                
            uint80 priceTenPercent = price / 10 / x;
                
            while (priceTenPercent > tick)
            {
                tick *= 10;
            }
    
            while (priceTenPercent < tick)
            {
                tick /= 10;
            }
            
            if (n % 2 == 1)
            {
                if (price >= 50 * tick * x)
                {
                    tick *= 5;
                }
            }
            else
            {
                if (price < 50 * tick * x)
                {
                    tick *= 5;
                }
                else
                {
                    tick *= 10;
                }
                
            }
            
            return tick;
        }
    }
    /*
    function LimitOrders(uint32 orderN, uint32 ownerId, uint32[] prTrade, uint32[] prBase, bool[] isSell, uint80[] price, uint104[] qty) public returns (uint32[])
    {
        require(orderN <= 10 &&  orderN == prTrade.length && orderN == prBase.length && orderN == isSell.length && orderN == price.length && orderN == qty.length);
        
        uint32[] memory orderId = new uint32[](orderN);
        for (uint32 i = 0; i < orderN; i++)
        {
            orderId[i] = LimitOrder(ownerId, prTrade[i], prBase[i], isSell[i], price[i], qty[i]);
        }
        return orderId;
    }
    */
    function LimitOrder(uint32 ownerId, uint32 prTrade, uint32 prBase, bool isSell, uint80 price, uint104 qty) public onlyContractUse  returns  (uint32)
    {
        uint32 accountId = FindOrRevertAccount();
        require(accountId_freeze[accountId] == false);
        uint80 lastBestPrice;
        OrderBook storage orderBook = basePID_tradePID_orderBook[prBase][prTrade];
        require(price != 0 && price <= maxPrice && qty <= maxQty &&
            ((isSell == false && prCode_productInfo[prTrade].isTradeBid == true && prCode_productInfo[prBase].isTradeAsk == true) 
            || (isSell == true && prCode_productInfo[prTrade].isTradeAsk == true && prCode_productInfo[prBase].isTradeBid == true)) 
            && prCode_productInfo[prTrade].minQty <= qty);
        
        if (isSell == true)
        {
            price = GetNextTick(true, price, orderBook.tickSize);
            lastBestPrice = orderBook.bestAskPrice;
        }
        else
        {
            price = GetNextTick(false, price, orderBook.tickSize);
            lastBestPrice = orderBook.bestBidPrice;
        }
        
        Order memory order;
        order.ownerId = ownerId;
        order.isSell = isSell;
        order.prTrade = prTrade;
        order.prBase = prBase;
        order.accountId = accountId;
        order.price = price;
        order.qty = qty;
        //order.timestamp = uint64(now);
        
        require (IsPossibleLimit(order));
        
        emit NewOrder(order.prTrade, order.prBase, order.accountId, ++lastOrderId, order.isSell, order.price, order.qty, lastNewOrderId++);

        //uint104 tradedQty = matchOrder(orderBook, order, lastOrderId);
        //BalanceUpdateByLimitAfterTrade(order, qty, tradedQty);

        BalanceUpdateByLimitAfterTrade(order, qty, matchOrder(orderBook, order, lastOrderId));

        if (order.qty != 0)
        {
            uint80 priceNext;
            uint80 price0;
            
            if (isSell == true)
            {
                price0 = orderBook.bestAskPrice;
                if (price0 == 0)
                {
                    orderBook.askPrice_Order[price].prevPrice = 0;
                    orderBook.askPrice_Order[price].nextPrice = 0;
                    orderBook.bestAskPrice = price;
                }
                else if(price < price0)
                {
                    orderBook.askPrice_Order[price0].prevPrice = price;
                    orderBook.askPrice_Order[price].prevPrice = 0;
                    orderBook.askPrice_Order[price].nextPrice = price0;
                    orderBook.bestAskPrice = price;
                }
                else if (orderBook.askPrice_Order[price].firstId == 0)// .orderN == 0)
                {
                    priceNext = price0;
                    
                    while (priceNext != 0 && priceNext < price)
                    {
                        price0 = priceNext;
                        priceNext = orderBook.askPrice_Order[price0].nextPrice;
                    }
                    
                    orderBook.askPrice_Order[price0].nextPrice = price;
                    orderBook.askPrice_Order[price].prevPrice = price0;
                    orderBook.askPrice_Order[price].nextPrice = priceNext;
                    if (priceNext != 0)
                    {
                        orderBook.askPrice_Order[priceNext].prevPrice = price;
                    }
                }
                
                OrderLink storage orderLink = orderBook.askPrice_Order[price];
            }
            else
            {
                price0 = orderBook.bestBidPrice;
                if (price0 == 0)
                {
                    orderBook.bidPrice_Order[price].prevPrice = 0;
                    orderBook.bidPrice_Order[price].nextPrice = 0;
                    orderBook.bestBidPrice = price;
                }
                else if (price > price0)
                {
                    orderBook.bidPrice_Order[price0].prevPrice = price;
                    orderBook.bidPrice_Order[price].prevPrice = 0;
                    orderBook.bidPrice_Order[price].nextPrice = price0;
                    orderBook.bestBidPrice = price;
                }
                else if (orderBook.bidPrice_Order[price].firstId == 0)// .orderN == 0)
                {
                    priceNext = price0;

                    while (priceNext != 0 && priceNext > price)
                    {
                        price0 = priceNext;
                        priceNext = orderBook.bidPrice_Order[price0].nextPrice;
                    }
                    
                    orderBook.bidPrice_Order[price0].nextPrice = price;
                    orderBook.bidPrice_Order[price].prevPrice = price0;
                    orderBook.bidPrice_Order[price].nextPrice = priceNext;
                    if (priceNext != 0)
                    {
                        orderBook.bidPrice_Order[priceNext].prevPrice = price;
                    }
                }

                orderLink = orderBook.bidPrice_Order[price];
            }
            
            if (lastOrderId != 0)
            {
                orderLink.id_orderList[lastOrderId].prev = orderLink.lastId;// .firstID;
                if (orderLink.firstId != 0)
                {
                    orderLink.id_orderList[orderLink.lastId].next = lastOrderId;
                }
                else
                {
                    orderLink.id_orderList[lastOrderId].next = 0;
                    orderLink.firstId = lastOrderId;
                }
                orderLink.lastId = lastOrderId;
            }

            //orderLink.id_orderList.Add(id, listItem);
            //id_Order.Add(id, order);
            //orderLink.id_orderList[lastOrderId] = listItem;
            
            AddOpenOrder(accountId, lastOrderId);
            //orderLink.orderN += 1;
            id_Order[lastOrderId] = order;
            //emit NewHogaChange(prTrade, prBase, isSell, price);
            
        }

        if (isSell == true && lastBestPrice != orderBook.bestAskPrice)
        {
            emit NewBestBidAsk(prTrade, prBase, isSell, orderBook.bestAskPrice);
        }
        if (isSell == false && lastBestPrice != orderBook.bestBidPrice)
        {
            emit NewBestBidAsk(prTrade, prBase, isSell, orderBook.bestBidPrice);
        }
        
        return lastOrderId;
    }
    
    function BalanceUpdateByLimitAfterTrade(Order order, uint104 qty, uint104 tradedQty) private
    {
        uint32 ownerId = order.ownerId;
        uint32 accountId = order.accountId;
        uint32 prTrade = order.prTrade;
        uint32 prBase = order.prBase;
        uint80 price = order.price;
        uint104 orderQty = order.qty;
        
        //require(qty >= orderQty);// && tradedQty < maxQty);
        
        //Balance storage balance;
        uint32 prTemp;

        if (order.isSell)
        {
            Balance storage balance = prCode_AccountId_Balance[prTrade][accountId];
            balance.available = Sub(balance.available, qty);
            
            if (orderQty != 0)
                balance.reserved = Add(balance.reserved, orderQty);

            prTemp = prBase;
        }
        else
        {
            balance = prCode_AccountId_Balance[prBase][accountId];/////
            if (orderQty != 0)
            {
                uint256 temp = prCode_productInfo[prBase].divider * orderQty * price / basePrice / prCode_productInfo[prTrade].divider;
                require (temp < maxQty);
                balance.available = Sub(balance.available, tradedQty + uint104(temp));
                balance.reserved = Add(balance.reserved, uint104(temp));
            }
            else
            {
                balance.available = Sub(balance.available, tradedQty);///////
            }
            tradedQty = qty - orderQty;

            prTemp = prTrade;
        }
        if (tradedQty != 0)
        {
            uint104 takeFeeMain = tradedQty * takerFeeRateMain / 10000;
            uint104 takeFeeLocal = tradedQty * ownerId_takerFeeRateLocal[ownerId] / 10000;
            prCode_AccountId_Balance[prTemp][accountId].available += tradedQty - takeFeeMain - takeFeeLocal;
            prCode_AccountId_Balance[prTemp][ownerId_accountId[1]].available += takeFeeMain;
            prCode_AccountId_Balance[prTemp][ownerId_accountId[ownerId]].available += takeFeeLocal;
        }
    }

    function IsPossibleLimit(Order memory order) private view returns (bool)
    {
        if (order.isSell)
        {
            if (prCode_AccountId_Balance[order.prTrade][order.accountId].available >= order.qty)
                return true;
            else
                return false;
        }
        else
        {
            if (prCode_AccountId_Balance[order.prBase][order.accountId].available >= prCode_productInfo[order.prBase].divider * order.qty * order.price / basePrice / prCode_productInfo[order.prTrade].divider)
                return true;
            else
                return false;
        }
    }

    function matchOrder(OrderBook storage ob, Order memory order, uint32 id) private returns (uint104)//, OrderBook storage orderBook, Order order, uint32 id) private returns (uint104)
    {
        uint32 prTrade = order.prTrade;
        uint32 prBase = order.prBase; 
        uint80 tradePrice;

        if (order.isSell == true)
            tradePrice = ob.bestBidPrice;
        else
            tradePrice = ob.bestAskPrice;

        bool isBestPriceUpdate = false;

        //OrderLink storage orderLink;// = price_OrderLink[tradePrice];
        uint104 qtyBase = 0;
        //Order storage matchingOrder;
        uint104 tradeAmount;
        
        while (tradePrice != 0 && order.qty > 0 && ((order.isSell && order.price <= tradePrice) || (!order.isSell && order.price >= tradePrice)))
        {
            if (order.isSell == true)
                OrderLink storage orderLink = ob.bidPrice_Order[tradePrice];
            else
                orderLink = ob.askPrice_Order[tradePrice];
                
            uint32 orderId = orderLink.firstId;
            
            while (orderLink.firstId != 0 && orderId != 0 && order.qty != 0)
            {
                Order storage matchingOrder = id_Order[orderId];
                if (matchingOrder.qty >= order.qty)
                {
                    tradeAmount = order.qty;
                    matchingOrder.qty -= order.qty;
                    order.qty = 0;
                }
                else
                {
                    tradeAmount = matchingOrder.qty;
                    order.qty -= matchingOrder.qty;
                    matchingOrder.qty = 0;
                }
                
                qtyBase += BalanceUpdateByTradeCp(order, matchingOrder, tradeAmount);
                
                uint32 orderAccountID = order.accountId;

                if (order.isSell == true)
                    emit NewTrade(prTrade, prBase, orderId, id, matchingOrder.accountId, orderAccountID, true, tradePrice,  tradeAmount, lastTradeId++, uint64(now));
                else
                    emit NewTrade(prTrade, prBase, id, orderId, orderAccountID, matchingOrder.accountId, false, tradePrice,  tradeAmount, lastTradeId++, uint64(now));
                
                if (matchingOrder.qty != 0)
                {
                    //id_Order[tradePrice] = matchingOrder;
                    break;
                }
                else
                {
                    if (RemoveOrder(prTrade, prBase, matchingOrder.isSell, tradePrice, orderId) == true)
                    {
                        RemoveOpenOrder(matchingOrder.accountId, orderId);
                    }
                    orderId = orderLink.firstId;
                }
            }
            
            //emit NewHogaChange(prTrade, prBase, !order.isSell, tradePrice);

            if (orderLink.firstId == 0)// .orderN == 0)
            {
                tradePrice = orderLink.nextPrice;
                isBestPriceUpdate = true;
            }
        }
        
        if (isBestPriceUpdate == true)
        {
            if (order.isSell)
            {
                ob.bestBidPrice = tradePrice;
            }
            else
            {
                ob.bestAskPrice = tradePrice;
            }
            
            emit NewBestBidAsk(prTrade, prBase, !order.isSell, tradePrice);
        }

        return qtyBase;
    }
    
    function BalanceUpdateByTradeCp(Order order, Order matchingOrder, uint104 tradeAmount) private returns (uint104)
    {
        uint32 accountId = matchingOrder.accountId;
        uint32 prTrade = order.prTrade; 
        uint32 prBase = order.prBase; 
        require (tradeAmount < maxQty);
        uint256 qtyBase = prCode_productInfo[prBase].divider * tradeAmount * matchingOrder.price / basePrice / prCode_productInfo[prTrade].divider;
        require (qtyBase < maxQty);
        /*
        if (order.isSell == true)
        {
            prCode_AccountId_Balance[prTrade][accountId].available = SafeMath.Add(prCode_AccountId_Balance[prTrade][accountId].available, tradeAmount);
            prCode_AccountId_Balance[prBase][accountId].reserved = SafeMath.Sub(prCode_AccountId_Balance[prBase][accountId].reserved, uint104(qtyBase));
        }
        else
        {
            prCode_AccountId_Balance[prTrade][accountId].reserved = SafeMath.Sub(prCode_AccountId_Balance[prTrade][accountId].reserved, tradeAmount);
            prCode_AccountId_Balance[prBase][accountId].available = SafeMath.Add(prCode_AccountId_Balance[prBase][accountId].available, uint104(qtyBase));
        }
        */
        Balance storage balanceTrade = prCode_AccountId_Balance[prTrade][accountId];
        Balance storage balanceBase = prCode_AccountId_Balance[prBase][accountId];
        
        if (order.isSell == true)
        {
            balanceTrade.available = SafeMath.Add(balanceTrade.available, tradeAmount);
            balanceBase.reserved = SafeMath.Sub(balanceBase.reserved, uint104(qtyBase));
        }
        else
        {
            balanceTrade.reserved = SafeMath.Sub(balanceTrade.reserved, tradeAmount);
            balanceBase.available = SafeMath.Add(balanceBase.available, uint104(qtyBase));
        }

        return uint104(qtyBase);
    }
    
    function RemoveOrder(uint32 prTrade, uint32 prBase, bool isSell, uint80 price, uint32 id) private returns (bool)
    {
        OrderBook storage ob = basePID_tradePID_orderBook[prBase][prTrade];
        
        if (isSell == false)
        {
            OrderLink storage orderLink = ob.bidPrice_Order[price];
        }
        else
        {
            orderLink = ob.askPrice_Order[price];
        }
        
        if (id != 0)
        {
            ListItem memory removeItem = orderLink.id_orderList[id];
            if (removeItem.next != 0)
            {
                orderLink.id_orderList[removeItem.next].prev = removeItem.prev;
            }

            if (removeItem.prev != 0)
            {
                orderLink.id_orderList[removeItem.prev].next = removeItem.next;
            }

            if (id == orderLink.lastId)
            {
                orderLink.lastId = removeItem.prev;
            }
            
            if (id == orderLink.firstId)
            {
                orderLink.firstId = removeItem.next;
            }

            delete orderLink.id_orderList[id];

            if (orderLink.firstId == 0)
            {
                if (orderLink.nextPrice != 0)
                {
                    if (isSell == true)
                        OrderLink storage replaceLink = ob.askPrice_Order[orderLink.nextPrice];
                    else
                        replaceLink = ob.bidPrice_Order[orderLink.nextPrice];

                    replaceLink.prevPrice = orderLink.prevPrice;
                }
                if (orderLink.prevPrice != 0)
                {
                    if (isSell == true)
                        replaceLink = ob.askPrice_Order[orderLink.prevPrice];
                    else
                        replaceLink = ob.bidPrice_Order[orderLink.prevPrice];

                    replaceLink.nextPrice = orderLink.nextPrice;
                }

                if (price == ob.bestAskPrice)
                {
                    ob.bestAskPrice = orderLink.nextPrice;
                }
                if (price == ob.bestBidPrice)
                {
                    ob.bestBidPrice = orderLink.nextPrice;
                }
            }
            return true;
        }
        else    
        {
            return false;
        }
    }

    function cancelOrders(uint32[] id) public
    {
        for (uint32 i = 0; i < id.length; i++)
        {
            cancelOrder(id[i]);
        }
    }
    
    function cancelOrder(uint32 id) public returns (bool)
    {
        Order memory order = id_Order[id];
        uint32 accountId = account_id[msg.sender];
        require(order.accountId == accountId);
        
        uint32 prTrade = order.prTrade;
        uint32 prBase = order.prBase;
        bool isSell = order.isSell;
        uint80 price = order.price;
        uint104 qty = order.qty;
        
        if (RemoveOrder(prTrade, prBase, isSell, price, id) == false)
            return false;
        else
        {
            RemoveOpenOrder(accountId, id);
        }

        //Balance storage balance;
        
        if (isSell)
        {
            Balance storage balance = prCode_AccountId_Balance[prTrade][accountId];
            balance.available = SafeMath.Add(balance.available, qty);
            balance.reserved = SafeMath.Sub(balance.reserved, qty);
        }
        else
        {
            balance = prCode_AccountId_Balance[prBase][accountId];
            uint256 temp = prCode_productInfo[prBase].divider * qty * price / basePrice / prCode_productInfo[prTrade].divider;
            require (temp < maxQty);
            balance.available = SafeMath.Add(balance.available, uint104(temp));
            balance.reserved = SafeMath.Sub(balance.reserved, uint104(temp));
        }

        //RemoveOrder(prTrade, prBase, isSell, price, id);//, msg);
        //emit NewHogaChange(prTrade, prBase, isSell, order.price);
        
        emit NewCancel(prTrade, prBase, accountId, id, isSell, price, qty, lastNewOrderId++);
        return true;
    }
    function checkAnnounceLV(uint32 accountId, uint8 LV) private view
    {
        require(accountId == account_id[msg.sender] || id_announceLV[accountId] >= LV || msg.sender == operator || owner_id[msg.sender] != 0);
    }
    /*
    function getBalance(uint32[] prCode) view public returns (uint128[] available, uint128[] reserved)
    {
        (available, reserved) = getBalance(prCode, msg.sender);
    }
      */
    function getBalance(uint32[] prCode, uint32 accountId) view public returns (uint128[] available, uint128[] reserved)
    {
        if (accountId == 0)
            accountId = account_id[msg.sender];
        checkAnnounceLV(accountId, 2);
        
        uint256 n = prCode.length;
        available = new uint128[](n);
        reserved = new uint128[](n);
        
        for (uint32 i = 0; i < n; i++)
        {
            available[i] = prCode_AccountId_Balance[prCode[i]][accountId].available;
            reserved[i] = prCode_AccountId_Balance[prCode[i]][accountId].reserved;
        }
    }
    
    function getBalanceByProduct(uint32 prCode, uint128 minQty) view public returns (uint32[] accountId, uint128[] balanceSum)
    {
        require (owner_id[msg.sender] != 0 || msg.sender == operator);
        uint32 n = 0;
        for (uint32 i = 1; i <= lastAcccountId; i++)//Bug0319
        {
            if (prCode_AccountId_Balance[prCode][i].available + prCode_AccountId_Balance[prCode][i].reserved >= minQty)
                n++;
        }
        accountId = new uint32[](n);
        balanceSum = new uint128[](n);
        
        n = 0;
        uint128 temp;
        for (i = 1; i <= lastAcccountId; i++)//Bug0319
        {
            temp = prCode_AccountId_Balance[prCode][i].available + prCode_AccountId_Balance[prCode][i].reserved;
            if (temp >= minQty)//Bug0319
            {
                accountId[n] = i;
                balanceSum[n++] = temp;
            }
        }
    }
    
    function getOrderBookInfo(uint32[] prTrade, uint32 prBase) view public returns (uint80[] bestBidPrice, uint80[] bestAskPrice)
    {
        uint256 n = prTrade.length;
        //require(n == prBase.length);
        bestBidPrice = new uint80[](n);//prTrade.length);
        bestAskPrice = new uint80[](n);//prTrade.length);
        
        for (uint256 i = 0; i < n; i++)
        {
            OrderBook memory orderBook = basePID_tradePID_orderBook[prBase][prTrade[i]];// iCode_OrderBook[prCode];
            bestBidPrice[i] = orderBook.bestBidPrice;
            bestAskPrice[i] = orderBook.bestAskPrice;
        }
    }
    /*
    function getOrder(uint32[] id) view public returns (uint32[] prTrade, uint32[] prBase, bool[] sell, uint80[] price, uint104[] qty)
    {
        uint256 n = id.length;
        prTrade = new uint32[](n);
        prBase = new uint32[](n);
        sell = new bool[](n);
        price = new uint80[](n);
        qty = new uint104[](n);
        
        for (uint256 i = 0; i < n; i++)
        {
            Order memory order = id_Order[id[i]];
            prTrade[i] = order.prTrade;
            prBase[i] = order.prBase;
            sell[i] = order.isSell;
            price[i] = order.price;
            qty[i] = order.qty;
        }
    }
    */
    
    function getOrder(uint32 id) view public returns (uint32 prTrade, uint32 prBase, bool sell, uint80 price, uint104 qty, uint32 accountId)//, uint64 timestamp)
    {
        Order memory order = id_Order[id];
        
        accountId = order.accountId;
        checkAnnounceLV(accountId, 4);
        
        prTrade = order.prTrade;
        prBase = order.prBase;
        price = order.price;
        sell = order.isSell;
        qty = order.qty;
        //timestamp = order.timestamp;
    }
    
    function GetMyOrders(uint32 accountId) view public returns (uint32[] orderId, uint32[] prTrade, uint32[] prBase, bool[] sells, uint80[] prices, uint104[] qtys)//, uint64[] timestamp)
    {
        if (accountId == 0)
            accountId = account_id[msg.sender];
        
        checkAnnounceLV(accountId, 4);
        
        OpenOrder storage openOrder = accountId_OpenOrder[accountId];
     
        uint32 id = accountId_OpenOrder[accountId].startId;
        uint32 orderN = 0;
        while (id != 0)
        {
            id = openOrder.id_orderList[id].next;
            orderN++;
        }

        orderId = new uint32[](orderN);
        prTrade = new uint32[](orderN);
        prBase = new uint32[](orderN);
        qtys = new uint104[](orderN);
        prices = new uint80[](orderN);
        sells = new bool[](orderN);
        //timestamp = new uint64[](orderN);
        
        id = openOrder.startId;
        if (id != 0)
        {
            Order memory order;
            uint32 i = 0;
            while (id != 0)
            {
                order = id_Order[id];
                
                orderId[i] = id;
                prTrade[i] = order.prTrade;
                prBase[i] = order.prBase;
                qtys[i] = order.qty;
                prices[i] = order.price;
                sells[i++] = order.isSell;
                //timestamp[i++] = order.timestamp;

                id = openOrder.id_orderList[id].next;
            }
        }
    }
    
    function GetHogaDetail(uint32 prTrade, uint32 prBase, uint80 price, bool isSell) view public returns (uint32[] orderIds)
    {
        if (isSell == false)
        {
            OrderLink storage orderLink = basePID_tradePID_orderBook[prBase][prTrade].bidPrice_Order[price];
        }
        else if (isSell == true)
        {
            orderLink = basePID_tradePID_orderBook[prBase][prTrade].askPrice_Order[price];
        }
        else
        {
            return;
        }
        
        uint32 n = 0;
        uint32 id0 = orderLink.firstId;
        while (id0 != 0)
        {
            id0 = orderLink.id_orderList[id0].next;
            n++;
        }
        
        orderIds = new uint32[](n);
        n = 0;
        id0 = orderLink.firstId;
        while (id0 != 0)
        {
            orderIds[n++] = id0;
            id0 = orderLink.id_orderList[id0].next;
        }
    }
    
    function GetHoga(uint32 prTrade, uint32 prBase, uint32 hogaN) public view returns (uint80[] priceB, uint104[] volumeB, uint80[] priceA, uint104[] volumeA)
    {
        OrderBook storage ob = basePID_tradePID_orderBook[prBase][prTrade];
        
        (priceB, volumeB) = GetHoga(ob, hogaN, false);
        (priceA, volumeA) = GetHoga(ob, hogaN, true);
    }
    
    function GetHoga(OrderBook storage ob, uint32 hogaN, bool isSell) private view returns (uint80[] prices, uint104[] volumes)
    {
        prices = new uint80[](hogaN);
        volumes = new uint104[](hogaN);
        
        uint32 n;
        uint32 id0;
        uint80 price;
        uint104 sum;
        
        if (isSell == false)
            price = ob.bestBidPrice;
        else
            price = ob.bestAskPrice;// .bestBidPrice;
        
        if (price != 0)
        {
            n = 0;
            while (price != 0 && n < hogaN)
            {
                if (isSell == false)
                    OrderLink storage orderLink = ob.bidPrice_Order[price];
                else
                    orderLink = ob.askPrice_Order[price];
                
                id0 = orderLink.firstId;
                sum = 0;
                while (id0 != 0)
                {
                    sum += id_Order[id0].qty;
                    id0 = orderLink.id_orderList[id0].next;
                }
                prices[n] = price;
                volumes[n] = sum;
                price = orderLink.nextPrice;
                n++;
            }

            if (n > 0)
            {
                while (n < hogaN)
                {
                    if (isSell == true)
                        prices[n] = GetNextTick(true, prices[n - 1] + 1, ob.tickSize);
                    else
                        prices[n] = GetNextTick(false, prices[n - 1] - 1, ob.tickSize);
                    n++;
                }
            }
        }
    }
}