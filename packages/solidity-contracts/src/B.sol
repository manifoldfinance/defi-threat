/**
 * Source Code first verified at https://etherscan.io on Monday, March 25, 2019
 (UTC) */

contract B {
    function getBlock() public view returns (uint256) {
        return block.timestamp;
    }
}