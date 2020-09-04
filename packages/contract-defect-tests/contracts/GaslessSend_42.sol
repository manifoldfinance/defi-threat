pragma solidity ^0.4.2;

contract C { 
   function pay(uint n, address d){
    d.send(n);
  }
}

contract D1 {    
  uint public count = 0;
  
  function() payable {
    count = count+1;
  }
}

contract D2  {   
  function() payable {}
}

contract D3 {
  function a(){}
  function b(){}
  function c(){}
  function d(){}
  function e(){}
  function f(){}
  function g(){}
  function h(){}
  function i(){}
  function k(){}
  function j(){}
  function l(){}
  function m(){}
  function n(){}
  function o(){}
  function p(){}
  function q(){}
  function r(){}
  function s(){}
  function t(){}
  function u(){}
  function v(){}
  function w(){}
  function x(){}
  function y(){}
  function z(){}
  function() payable {}
}

