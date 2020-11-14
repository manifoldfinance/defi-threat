pragma solidity ^0.4.24;

import './SafeMath.sol';
import './Ownable.sol';

contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Multisend is Ownable {
    using SafeMath for uint256;

    uint256 public fee;
    uint256 public arrayLimit;
    
    event Transfer(address indexed _sender, address indexed _recipient, uint256 _amount);
    event Refund(uint256 _refund);
    event Payload(string _payload);
    event Withdraw(address _owner, uint256 _balance);

    constructor(uint256 _fee,uint256 _arrayLimit) public {
        fee = _fee; 
        arrayLimit = _arrayLimit;
    }
    
    function sendCoin(address[] recipients, uint256[] amounts, string payload) public payable {
        require(recipients.length == amounts.length);
        require(recipients.length <= arrayLimit);
        require((msg.data.length - 4) % 32 == 0);
        uint256 totalAmount = fee;
        for(uint256 i = 0; i < recipients.length; i++) {
            totalAmount = SafeMath.add(totalAmount, amounts[i]);
        }
        require(msg.value >= totalAmount);
        uint256 refund = SafeMath.sub(msg.value, totalAmount);
        for(i = 0; i < recipients.length; i++) {
            recipients[i].transfer(amounts[i]);
            emit Transfer(msg.sender, recipients[i],amounts[i]);
        }
        if (refund > 0) {
            msg.sender.transfer(refund);
            emit Refund(refund);
        }
        emit Payload(payload);
    }

    function sendToken(address token, address[] recipients, uint256[] amounts, string payload) public payable {
        require(msg.value >= fee);
        require(recipients.length == amounts.length);
        require(recipients.length <= arrayLimit);
        require((msg.data.length - 4) % 32 == 0);
        ERC20 erc20token = ERC20(token);
        for (uint256 i = 0; i < recipients.length; i++) {
            erc20token.transferFrom(msg.sender, recipients[i], amounts[i]);
        }
        uint256 refund = SafeMath.sub(msg.value, fee);
        if (refund > 0) {
            msg.sender.transfer(refund);
            emit Refund(refund);
        }
        emit Payload(payload);
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        owner.transfer(balance);
        emit Withdraw(owner, balance);
    }

    function setFee(uint256 _fee) public onlyOwner {
        fee = _fee;
    }

    function setArrayLimit(uint256 _arrayLimit) public onlyOwner {
        arrayLimit = _arrayLimit;
    }
}
