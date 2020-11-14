/**
 * Source Code first verified at https://etherscan.io on Friday, May 3, 2019
 (UTC) */

pragma solidity ^0.4.18;


contract Contract1 {

	mapping (uint8 => mapping (address => bool)) public something;

	function settrue(uint8 x, address a){
		something[x][a] = true;
	}
	function setfalse(uint8 x, address a){
		something[x][a] = false;
	}
}



contract Contract2 {

    Contract1 public original;
  
  	mapping (uint16 => mapping (address => uint8)) public something;

    // コンストラクタ
    function Contract2(address c) public {
        original = Contract1(c);
    }


	function test(uint8 x, address a){
		if(original.something(uint8(x),a))
			something[x][a] = 1;
		else
			something[x][a] = 2;
	}
}