/**
 * Source Code first verified at https://etherscan.io on Saturday, March 16, 2019
 (UTC) */

pragma solidity >=0.4.22 <0.6.0;


contract Orders {

  event LogNewSellOrder(bytes3 indexed currency, address sellorder);
  event LogNewBuyOrder(bytes3 indexed currency, address buyorder);
  event LogRemoveSellOrder(address indexed sellorder);
  event LogRemoveBuyOrder(address indexed buyorder);   
  function newSellOrder(bytes3 curr, uint price) public payable {
    require(msg.value/price >= 10000);
    Sell_eth newselleth = (new Sell_eth).value(msg.value)(price, msg.sender, address(this));
    emit LogNewSellOrder(curr, address(newselleth));    
  }

  function newBuyOrder(bytes3 curr, uint price) public payable {
    require(msg.value/price >= 5000);
    Buy_eth newbuyeth =(new Buy_eth).value(msg.value)(price, msg.sender, address(this));
    emit LogNewBuyOrder(curr, address(newbuyeth));
  }

  function removeSellOrder() public {  
    emit LogRemoveSellOrder(msg.sender);
  }

  function removeBuyOrder() public {
    emit LogRemoveBuyOrder(msg.sender);
  }

  function() external {revert();}
}

contract Sell_eth {
    Orders orders;
    uint weiForSale;
    uint price; //wei per smallest currency unit (eg. cent)
    address payable seller;
    mapping(address => uint) sales;
    uint8 pending;
    modifier onlySeller() {require(msg.sender == seller);  _;}

    event LogNewWeiForSale(uint wei_for_sale);
    event LogNewPrice(uint nprice);
    event LogSalePending(address indexed _seller, address indexed _buyer, uint value, uint _price);
    event LogCashReceived(address indexed _buyer, address indexed _seller);

    constructor(uint _price, address payable _seller, address _orders) public payable {
        orders = Orders(_orders);
        seller = _seller;
        price = _price;
        pending = 0;
        weiForSale = msg.value / 2;
    }
    
    function buy() payable public {
        require(sales[msg.sender] == 0);
        require(msg.value > 0 && msg.value <= weiForSale && (msg.value/price)%5000 == 0);
        sales[msg.sender] = msg.value;
        weiForSale -= msg.value;
        pending += 1;
        emit LogNewWeiForSale(weiForSale);
        emit LogSalePending(seller, msg.sender, msg.value, price);
    }

    function confirmReceived(address payable _buyer) public  onlySeller {
        require(sales[_buyer] > 0 && pending > 0);
        uint amt = sales[_buyer];
        sales[_buyer] = 0;
        _buyer.transfer(2*amt);
        pending -= 1;
        emit LogCashReceived(_buyer, seller);
	weiForSale += amt/2;
	emit LogNewWeiForSale(weiForSale); 
    }

    function addEther() public onlySeller payable {
        weiForSale += msg.value/2;
        emit LogNewWeiForSale(weiForSale);
    }

    function changePrice(uint new_price) public onlySeller {
        price = new_price;
        emit LogNewPrice(price);
    }
    
    function retr_funds() public onlySeller payable {
        require(pending == 0);
        orders.removeSellOrder();
        selfdestruct(address(seller));
    }
    
    function get_vars() view public returns(uint, uint) {
        return (weiForSale, price);
    }

    function is_party() view public returns(string memory) {
        if (sales[msg.sender] > 0) return "buyer";
        else if (seller == msg.sender) return "seller";
    }

    function has_pending() view public returns(bool) {
	if (pending > 0) return true;
    }
}

contract Buy_eth {
    Orders orders;
    uint weiToBuy;
    uint price; //wei per smallest currency unit (eg. cent)   
    address payable buyer;
    mapping(address => uint) sales;
    uint8 pending;
    modifier onlyBuyer() {require(msg.sender == buyer);  _;}
    
    event LogNewWeiToBuy(uint wei_to_buy);
    event LogNewPrice(uint nprice);
    event LogSalePending(address indexed _buyer, address indexed _seller, uint value, uint _price);
    event LogCashReceived(address indexed _seller, address indexed _buyer);

    constructor(uint _price, address payable _buyer, address _orders) public payable {
        orders = Orders(_orders);
        buyer = _buyer;
        price = _price;
        pending = 0;
        weiToBuy = msg.value;
    }
    function sell() public payable {
        require(sales[msg.sender] == 0);
        require(msg.value > 0 && msg.value/2 <= weiToBuy && (msg.value/price)%10000 == 0); 
        uint amt = msg.value/2;
        sales[msg.sender] = amt;
        weiToBuy -= amt;
        pending += 1;
        emit LogSalePending(buyer, msg.sender, amt, price);
        emit LogNewWeiToBuy(weiToBuy);
    }

    function confirmReceived() public payable {
        require(sales[msg.sender] > 0 && pending > 0);
        uint amt = sales[msg.sender];
        sales[msg.sender] = 0;
        msg.sender.transfer(amt);
        emit LogCashReceived(msg.sender, buyer);
        weiToBuy += 2*amt;
        pending -= 1;
        emit LogNewWeiToBuy(weiToBuy);
    }
    
    function retreive_eth(uint vol) public onlyBuyer payable {  
        require(vol <= weiToBuy-price*5000);
        weiToBuy -= vol;
        buyer.transfer(vol);
        emit LogNewWeiToBuy(weiToBuy);
    }

    function changePrice(uint new_price) public onlyBuyer {
        price = new_price;
        emit LogNewPrice(price);
    }

    function terminate_contract() public onlyBuyer payable {
        require(pending == 0);
        orders.removeBuyOrder();
        selfdestruct(buyer);
    }

    function get_vars() view public returns(uint,uint) {
        return (weiToBuy, price);
    }

    function is_party() view public returns(string memory) {
        if (buyer == msg.sender) return "buyer";
        else if (sales[msg.sender] > 0) return "seller";
    }

    function has_pending() view public returns(bool) {
	if (pending > 0) return true;
    }
}