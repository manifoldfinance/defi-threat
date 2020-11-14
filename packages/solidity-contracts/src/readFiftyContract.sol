/**
 * Source Code first verified at https://etherscan.io on Thursday, March 21, 2019
 (UTC) */

pragma solidity ^0.5.1;

contract FiftyContract {
	mapping (address => mapping (uint => mapping (uint => mapping (uint => treeNode)))) public treeChildren;
	mapping (address => mapping (uint => bool)) public currentNodes;
	mapping (address => mapping (uint => uint)) public nodeIDIndex;
	mapping (address => uint) public membership;
	struct treeNode {
		 address payable ethAddress; 
		 uint nodeType; 
		 uint nodeID;
	}
	uint public spread;
}
contract readFiftyContract{
	
	address public baseAddr = 0xEF78f662D8B85231e79aa657B96710129F34A961;
	FiftyContract bcontract = FiftyContract(baseAddr);
	
	function getCurrentTree(address r, uint t) public view returns(address[7] memory addrs){
		address[7] memory Adds;
		if(bcontract.nodeIDIndex(r,t) > (2 ** 32) -2 || !bcontract.currentNodes(r,t)) 
		    return Adds;
		uint cc=bcontract.nodeIDIndex(r,t) - 1;
		Adds[0]=r;
		uint8 spread = uint8(bcontract.spread());
		for (uint8 i=0; i < spread; i++) {
		    (address k,uint p,uint m) = bcontract.treeChildren(r,t,cc,i);
			if(p != 0){
				Adds[i+1]=k;
				for (uint8 a=0; a < spread; a++) {
				    (address L,uint q,uint n) = bcontract.treeChildren(k,p,m,a);    
					if(q != 0) Adds[i*2+a+3] = L;
				}
			}
		}
		return Adds;
	}
	function getMemberShip(address r) public view returns(uint){
		return bcontract.membership(r);
	}
}