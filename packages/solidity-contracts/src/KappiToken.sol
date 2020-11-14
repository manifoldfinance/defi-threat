/**
 * Source Code first verified at https://etherscan.io on Monday, April 29, 2019
 (UTC) */

pragma solidity ^0.5.6;

contract ERC20 {
    function totalSupply() public view returns (uint supply);
    function balanceOf(address who) public view returns (uint value);
    function allowance(address owner, address spender) public view returns (uint remaining);

    function transfer(address to, uint value) public returns (bool ok);
    function transferFrom(address from, address to, uint value) public returns (bool ok);
    function approve(address spender, uint value) public returns (bool ok);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract KappiToken is ERC20{
    uint8 public constant decimals = 18;
    uint256 initialSupply = 10000000000*10**uint256(decimals);
    uint256 public constant initialPrice = 4 * 10**13; // 1 ETH / 25000 Kappi
    uint256 soldTokens = 0;
    uint256 public constant hardCap = 2000000000 * 10** uint256(decimals); // 20%
    uint public saleStart = 0;
    uint public saleFinish = 0;

    string public constant name = "Kappi Token";
    string public constant symbol = "KAPP";

    address payable constant teamAddress = address(0x65AAe2A7dd8f03DC80EeAD4be797255bC5804351);

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    event Burned(address from, uint256 value);

    function totalSupply() public view returns (uint256) {
        return initialSupply;
    }

    function balanceOf(address owner) public view returns (uint256 balance) {
        return balances[owner];
    }

    function allowance(address owner, address spender) public view returns (uint remaining) {
        return allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        if (balances[msg.sender] >= value && value > 0) {
            balances[msg.sender] -= value;
            balances[to] += value;
            emit Transfer(msg.sender, to, value);
            return true;
        } else {
            return false;
        }
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        if (balances[from] >= value && allowed[from][msg.sender] >= value && value > 0) {
            balances[to] += value;
            balances[from] -= value;
            allowed[from][msg.sender] -= value;
            emit Transfer(from, to, value);
            return true;
        } else {
            return false;
        }
    }

    function approve(address spender, uint256 value) public returns (bool success) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    constructor () public payable {
        balances[teamAddress] = initialSupply * 8 / 10;
        balances[address(this)] = initialSupply * 2 / 10;
        saleStart = 1557075600; // timestamp (06-05-2019)
        saleFinish = 1562346000; //timestamp (06-07-2019)
    }

    function () external payable {
        require(now > saleStart && now < saleFinish);
        require (msg.value>=10**18); // 1 ETH min
        require (soldTokens<hardCap);

        uint256 valueToPass = 10 ** uint256(decimals) * msg.value / initialPrice;
        soldTokens += valueToPass;

        if (balances[address(this)] >= valueToPass && valueToPass > 0) {
            balances[msg.sender] = balances[msg.sender] + valueToPass;
            balances[address(this)] = balances[address(this)] - valueToPass;
            emit Transfer(address(this), msg.sender, valueToPass);
        }
        teamAddress.transfer(msg.value);
    }

    function burnUnsold() public returns (bool success) {
        require(now > saleFinish);
        uint burningAmount = balances[address(this)];
        initialSupply -= burningAmount;
        balances[address(this)] = 0;
        emit Burned(address(this), burningAmount);
        return true;
    }
}