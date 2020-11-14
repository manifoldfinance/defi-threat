/**
 * Source Code first verified at https://etherscan.io on Monday, March 25, 2019
 (UTC) */

pragma solidity ^0.5.0;

contract Sopow {

    event NewStake(address source, uint256 hash, uint256 value, uint256 target, uint payment);
    event NewMiner(address miner, uint256 hash, uint payment);
    event Status(uint min, uint256 target, uint block);
    event PaidOut(address miner, uint amount);

    address payable service = 0x935F545C5aA388B6846FB7A4c51ED1b180A4eFFF;

    //Set initial values
    uint min = 1 wei;
    uint finalBlock = 100000000;
    uint lastBlock = 7000000;
    address payable miner = 0x0000000000000000000000000000000000000000;
    uint256 target = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint256 total = 0;

    function getTargetAmount() public view returns(uint) {
        return min;
    }

    function getPayment() public view returns(uint) {
        uint _total = getPreviousBalance();
        return (_total / 2) + (_total / 4);
    }

    function getTarget() public view returns(uint) {
        return target;
    }

    function getMiner() public view returns(address) {
        return miner;
    }

    function getFinalBlock() public view returns(uint) {
        return finalBlock;
    }


    function getTotal() public view returns(uint) {
        return total;
    }

    // ---

    function getPreviousBalance() private view returns(uint) {
        return address(this).balance - msg.value;
    }

    function isFinished() private view returns(bool) {
        return block.number >= getFinalBlock();
    }

    function tooLate() private view returns(bool) {
        return block.number >= getFinalBlock() + 11000;
    }

    function work(uint _target, uint _total, uint _miner, uint _value) private pure returns(uint) {
        return uint256(keccak256(abi.encodePacked(_target, _total, _miner, _value))) - _value;
    }

    function getNextPayment() private view returns(uint) {
        uint _total = address(this).balance;
        return (_total / 2) + (_total / 4);
    }


    // ---

    function () external payable {
        if (msg.sender != tx.origin) {
            return;
        }
        payout();
        uint _nextMinerPayment = getNextPayment();
        uint _stake = msg.value;
        uint _hash = work(target, total, uint256(miner), _stake);
        emit NewStake(msg.sender, _hash, _stake, target, _nextMinerPayment);
        if (_stake < min) {
            return;
        }
        if (_hash < target) {
            target = _hash;
            miner = msg.sender;
            min = _stake;
            finalBlock = block.number + (block.number - lastBlock) + 42;
            if (finalBlock > (block.number + 11000)) {
                finalBlock =  block.number + 11000;
            }
            lastBlock = block.number;
            total += _stake;
            emit NewMiner(miner, target, _nextMinerPayment);
            emit Status(min, target, finalBlock);
        }
    }

    function payout() public {
        if (!isFinished()) {
            return;
        }
        // if nobody requested payout for more than 11000 blocks
        if (tooLate()) {
            service.transfer(getPreviousBalance() / 2);
            min = min / 2;
            target = 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
            lastBlock  = block.number - 11000;
            finalBlock = block.number + 11000;
            return;
        }
        uint _total = getPreviousBalance();
        uint _payment = getPayment();
        uint _fee = _total / 8;
        miner.transfer(_payment);
        service.transfer(_fee);
        emit PaidOut(miner, _payment);
        min = _total / 64;
        target = 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
        lastBlock  = block.number - 11000;
        finalBlock = block.number + 11000;
        total = 0;
        emit Status(min, target, finalBlock);
    }

}