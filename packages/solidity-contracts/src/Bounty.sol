/**
 * Source Code first verified at https://etherscan.io on Thursday, March 14, 2019
 (UTC) */

pragma solidity >=0.4.22 <0.6.0;
contract Bounty {
    uint public counter = 0;
    uint public currentNumber = 1;
    string internal base64this;
    mapping(address => bool) internal winners; 
    
    constructor(string memory _base64) public {
        base64this = _base64;
    }
    
    function claim(uint guessCurrentNumber, uint setNextNumber) public {
        require(counter < 10, "All prizes collected");
        require(winners[msg.sender] == false, "Cannot participate twice. But feel free to sybil us");
        require(currentNumber == guessCurrentNumber);
        currentNumber = setNextNumber;
        counter += 1;
        winners[msg.sender] = true;
    }
    
    function getPrize() public view returns (string memory){
        require(winners[msg.sender]);
        return base64this;
    }
    
}