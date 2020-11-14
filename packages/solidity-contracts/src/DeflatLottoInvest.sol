/**
 * Source Code first verified at https://etherscan.io on Sunday, March 17, 2019
 (UTC) */

pragma solidity ^0.4.23;

interface token {
    function transfer(address receiver, uint amount) external;
    function balanceOf(address tokenOwner) constant external returns (uint balance);
}

contract DeflatLottoInvest {

  string public name = "DEFLAT LOTTO INVEST";
  string public symbol = "DEFTLI";
  string public prob = "Probability 1 of 10";
  string public comment = "Send 0.002 ETH to captalize DEFLAT and try to win 0.018 ETH, the prize is drawn when the accumulated balance reaches 0.02 ETH";

  //Send only 0.002 ether, other value will be rejected;
  //Bids below 0.002 ether generate very low DEFLAT returns when calling the sales contract due to the gas cost, so this is the minimum feasible bid.

  address[] internal playerPool;
  address public maincontract = address(0xe36584509F808f865BE1960aA459Ab428fA7A25b); //DEFLAT SALE CONTRACT;
  token public tokenReward = token(0xe1E0DB951844E7fb727574D7dACa68d1C5D1525b);// DEFLAT COIN CONTRACT;
  uint rounds = 10;
  uint quota = 0.002 ether;
  uint reward;
  event Payout(address from, address to, uint quantity);
  function () public payable {
    require(msg.value == quota);
    playerPool.push(msg.sender);
    if (playerPool.length >= rounds) {
      uint baserand = (block.number-1)+now+block.difficulty;
      uint winidx = uint(baserand)/10;
      winidx = baserand - (winidx*10);   
      address winner = playerPool[winidx];
      uint amount = address(this).balance;
      if (winner.send(amount)) { emit Payout(this, winner, amount);}
      reward = tokenReward.balanceOf(address(this))/((rounds+1)-playerPool.length);    
      if (reward > 0) { tokenReward.transfer(msg.sender, reward);}   
      playerPool.length = 0;                
    } 
    else {
       if (playerPool.length == 1) {
           if (maincontract.call.gas(200000).value(address(this).balance)()) { emit Payout(this, maincontract, quota);}
       }
       reward = tokenReward.balanceOf(address(this))/((rounds+1)-playerPool.length);    
       if (reward > 0) { tokenReward.transfer(msg.sender, reward); }
    } 
  }
}