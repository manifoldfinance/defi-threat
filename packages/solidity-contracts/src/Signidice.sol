/**
 * Source Code first verified at https://etherscan.io on Thursday, April 25, 2019
 (UTC) */

pragma solidity ^0.5.7;

contract Signidice {

    function generateLuck(bytes memory _RSASign, uint256 _min, uint256 _max) public pure returns (bytes32 luck) {

        uint256 delta = (_max - _min + 1);

        uint256 lucky = uint256(keccak256(_RSASign));

        while (lucky >= (2 ** (256 - 1) / delta) * delta) {
            lucky = uint256(keccak256(abi.encodePacked(lucky)));
        }

        lucky = (lucky % (delta)) + _min;

        return bytes32(lucky);
    }

}