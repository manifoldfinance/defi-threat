/**
 * Source Code first verified at https://etherscan.io on Thursday, March 21, 2019
 (UTC) */

pragma solidity ^0.4.25;

contract Promise{
    string public vow;
    address public promisor;
    address public beneficiary;
    uint public deposit;
    uint public endDate;
    address[3] public judges;

    uint[3] public signedByJudge;
    bool public signedByPromisor;

    uint[3] public votedFoul;
    uint public foulVotes = 0;
    uint[3] public votedShy;
    uint public shyVotes = 0;
    uint[3] public votedSuccess;
    uint public successVotes = 0;

    bool public sentMoney = false;

    constructor(address _promisor, string _vow, uint _deposit, uint _endDate, address[3] _judges, address _beneficiary) public{
        promisor = _promisor;
        vow = _vow;
        deposit = _deposit;
        endDate = _endDate;
        judges = _judges;
        beneficiary = _beneficiary;
    }

    function judgeSigns(uint _number) public{
        require(msg.sender == judges[_number]);
        signedByJudge[_number] = 1;
    }

    function promisorSigns() payable public{
        require(msg.sender == promisor);
        require(signedByJudge[0] == 1);
        require(signedByJudge[1] == 1);
        require(signedByJudge[2] == 1);
        require(!signedByPromisor);
        require(msg.value == deposit);

        signedByPromisor = true;
    }

    function voteFoul(uint _number) public{
        require(signedByPromisor);
        require(msg.sender == judges[_number]);
        require(votedFoul[_number] != 1);
        require(votedShy[_number] != 1);
        require(votedSuccess[_number] != 1);

        foulVotes = foulVotes + 1;
        votedFoul[_number] = 1;
        if((foulVotes >= 2) && !sentMoney){
          beneficiary.transfer(deposit);
          sentMoney = true;
        }
    }

    function voteShyOfCondition(uint _number) public{
        require(signedByPromisor);
        require(msg.sender == judges[_number]);
        require(votedShy[_number] != 1);
        require(votedFoul[_number] != 1);

        shyVotes = shyVotes + 1;
        votedShy[_number] = 1;
        if((shyVotes >= 2) && !sentMoney){
          promisor.transfer(deposit);
          sentMoney = true;
        }
    }

    function voteSuccess(uint _number) public{
        require(signedByPromisor);
        require(msg.sender == judges[_number]);
        require(votedSuccess[_number] != 1);
        require(votedFoul[_number] != 1);

        successVotes = successVotes + 1;
        votedSuccess[_number] = 1;
        if((successVotes >= 2) && !sentMoney){
          promisor.transfer(deposit);
          sentMoney = true;
        }
    }

    function selfDestruct() public{
      require(sentMoney);
      require(now >= (endDate+432000));

      selfdestruct(msg.sender);
    }
}