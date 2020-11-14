/**
 * Source Code first verified at https://etherscan.io on Friday, March 15, 2019
 (UTC) */

pragma solidity ^0.5.0;



/**------------------------------------

LAVA Token Demutator

This is a Lava Middleman contract that can be the target of Lava Packets for ApproveAndCall.

This will unmutate lava tokens back to the master token.


------------------------------------*/



contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract MutationInterface {

    address public masterToken;

    function mutateTokens(address from, uint amount) public returns (bool);
    function unmutateTokens( uint amount) public returns (bool);
}


contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}


contract DeMutator{


    constructor() public {

    }

    /**
    * Do not allow ETH to enter
    */
     function() external payable
     {
         revert();
     }




    function _demutateTokens(address from, address token, uint tokens) internal returns (bool success) {

         address masterToken = MutationInterface(token).masterToken();

          //bring the preapproved tokens into the contracts possession
          require(ERC20Interface(token).transferFrom(from, address(this), tokens ));

          //mutate the tokens to the masterToken type
          require(MutationInterface(token).unmutateTokens(tokens));

          //send them to the owner
          require(ERC20Interface(masterToken).transfer(from, tokens ));

         return true;
     }

       /*
         Receive approval from ApproveAndCall() to mutate tokens.

         This method allows 0xBTC to be mutated into LAVA using a single method call.
       */
     function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public returns (bool success) {

        require(_demutateTokens( from,token,tokens ));

        return true;

     }







}