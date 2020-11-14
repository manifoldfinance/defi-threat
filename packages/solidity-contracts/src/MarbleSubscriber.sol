/**
 * Source Code first verified at https://etherscan.io on Wednesday, March 27, 2019
 (UTC) */

pragma solidity 0.5.2;
pragma experimental ABIEncoderV2;


contract IPolaris {
    struct Checkpoint {
        uint ethReserve;
        uint tokenReserve;
    }

    struct Medianizer {
        uint8 tail;
        uint pendingStartTimestamp;
        uint latestTimestamp;
        Checkpoint[] prices;
        Checkpoint[] pending;
        Checkpoint median;
    }
    function subscribe(address token) public payable;
    function unsubscribe(address token, uint amount) public returns (uint actualAmount);
    function getMedianizer(address token) public view returns (Medianizer memory);
    function getDestAmount(address src, address dest, uint srcAmount) public view returns (uint);
}


contract MarbleSubscriber {

    IPolaris public oracle;

    constructor(address _oracle) public {
        oracle = IPolaris(_oracle);
    }

    function subscribe(address asset) public payable returns (uint) {
        oracle.subscribe.value(msg.value)(asset);
    }

    function getDestAmount(address src, address dest, uint srcAmount) public view returns (uint) {
        return oracle.getDestAmount(src, dest, srcAmount);
    }

    function getMedianizer(address token) public view returns (IPolaris.Medianizer memory) {
        return oracle.getMedianizer(token);
    }
}