/**
 * Source Code first verified at https://etherscan.io on Wednesday, March 20, 2019
 (UTC) */

pragma solidity ^0.4.23;


/**
 * @title User Owned Proxy
 */
contract UserProxy {

    /**
     * @dev execute authorised calls via delegate call
     * @param _target logic proxy address
     * @param _data delegate call data
     */
    function execute(address _target, bytes _data) public payable returns (bytes response) {
        require(_target != address(0), "user-proxy-target-address-required");
        assembly {
            let succeeded := delegatecall(sub(gas, 5000), _target, add(_data, 0x20), mload(_data), 0, 0)
            let size := returndatasize

            response := mload(0x40)
            mstore(0x40, add(response, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(response, size)
            returndatacopy(add(response, 0x20), 0, size)

            switch iszero(succeeded)
                case 1 {
                    // throw if delegatecall failed
                    revert(add(response, 0x20), size)
                }
        }
    }

}