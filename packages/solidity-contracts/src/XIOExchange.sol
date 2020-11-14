/**
 * Source Code first verified at https://etherscan.io on Thursday, March 21, 2019
 (UTC) */

pragma solidity ^0.4.25;

contract Token {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    uint8 public decimals;
}

contract XIOExchange {
    struct Order {
        address creator;
        bool buy;
        uint price;
        uint amount;
    }

    Order[] public orders;
    uint public orderCount;

    address public XIO;

    event PlaceSell(address indexed user, uint price, uint amount, uint id);
    event PlaceBuy(address indexed user, uint price, uint amount, uint id);
    event FillOrder(uint indexed id, address indexed user, uint amount);
    event CancelOrder(uint indexed id);

    constructor(address _XIO) public {
        XIO = _XIO;
    }

    function safeAdd(uint a, uint b) private pure returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }
    
    function safeSub(uint a, uint b) private pure returns (uint) {
        assert(b <= a);
        return a - b;
    }
    
    function safeMul(uint a, uint b) private pure returns (uint) {
        if (a == 0) {
          return 0;
        }
        
        uint c = a * b;
        assert(c / a == b);
        return c;
    }
    
    function safeIDiv(uint a, uint b) private pure returns (uint) {
        uint c = a / b;
        assert(b * c == a);
        return c;
    }
    
    function calcAmountTrx(uint price, uint amount) internal pure returns (uint) {
        return safeIDiv(safeMul(price, amount), 1000000000000000000);
    }

    function placeBuy(uint price, uint amount) external payable {
        require(price > 0 && amount > 0 && msg.value == calcAmountTrx(price, amount));
        orders.push(Order({
            creator: msg.sender,
            buy: true,
            price: price,
            amount: amount
        }));
        emit PlaceBuy(msg.sender, price, amount, orderCount);
        orderCount++;
    }
    
    function placeSell(uint price, uint amount) external {
        require(price > 0 && amount > 0);
        Token(XIO).transferFrom(msg.sender, this, amount);
        orders.push(Order({
            creator: msg.sender,
            buy: false,
            price: price,
            amount: amount
        }));
        emit PlaceSell(msg.sender, price, amount, orderCount);
        orderCount++;
    }
    
    function fillOrder(uint id, uint amount) external payable {
        require(id < orders.length);
        require(amount > 0);
        require(orders[id].creator != msg.sender);
        require(orders[id].amount >= amount);
        if (orders[id].buy) {
            require(msg.value == 0);
            
            /* send tokens from sender to creator */
            Token(XIO).transferFrom(msg.sender, orders[id].creator, amount);
            
            /* send Ether to sender */
            msg.sender.transfer(calcAmountTrx(orders[id].price, amount));
        } else {
            uint trxAmount = calcAmountTrx(orders[id].price, amount);
            require(msg.value == trxAmount);
            
            /* send tokens to sender */
            Token(XIO).transfer(msg.sender, amount);
            
            /* send Ether from sender to creator */
            orders[id].creator.transfer(trxAmount);
        }
        if (orders[id].amount == amount) {
            delete orders[id];
        } else {
            orders[id].amount -= amount;
        }
        emit FillOrder(id, msg.sender, amount);
    }
    
    function cancelOrder(uint id) external {
        require(id < orders.length);
        require(orders[id].creator == msg.sender);
        require(orders[id].amount > 0);
        if (orders[id].buy) {
            /* return Ether */
            msg.sender.transfer(calcAmountTrx(orders[id].price, orders[id].amount));
        } else {
            /* return tokens */
            Token(XIO).transfer(msg.sender, orders[id].amount);
        }
        delete orders[id];
        emit CancelOrder(id);
    }
}