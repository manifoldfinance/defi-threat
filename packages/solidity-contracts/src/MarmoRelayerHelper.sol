/**
 * Source Code first verified at https://etherscan.io on Thursday, April 4, 2019
 (UTC) */

pragma solidity ^0.5.7;

interface MarmoStork {
    function reveal(address _signer) external payable;
    function marmoOf(address _signer) external view;
    function hash() external view returns (bytes32);
}

interface Marmo {
    function relayedBy(bytes32 _id) external view returns (address _relayer);
    function relay(
        address _implementation,
        bytes calldata _data,
        bytes calldata _signature
    ) external;
}

contract MarmoRelayerHelper {
    bytes1 private constant CREATE2_PREFIX = byte(0xff);
    bytes32 private hash;

    MarmoStork public stork;

    constructor(MarmoStork _stork) public {
        hash = _stork.hash();
        stork = _stork;
    }

    // Calculates the Marmo wallet for a given signer
    // the wallet contract will be deployed in a deterministic manner
    function _marmoOf(address _signer) internal view returns (address) {
        // CREATE2 address
        return address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        CREATE2_PREFIX,
                        stork,
                        bytes32(uint256(_signer)),
                        hash
                    )
                )
            )
        );
    }
    
    function _isNotContract(address _address) internal view returns (bool v) {
        assembly {
            v := iszero(extcodesize(_address))
        }
    }
    
    function wasRelayed(
        address _signer,
        bytes32 _id
    ) external view returns (bool) {
        Marmo marmo = Marmo(_marmoOf(_signer));

        if (_isNotContract(address(marmo))) {
            return false;
        }
        
        return marmo.relayedBy(_id) != address(0);
    }
    
    function depsReady(
        bytes calldata _data
    ) external view returns (bool) {
        // Retrieve inputs from data
        (bytes memory dependency) = abi.decode(_data, (bytes));
        return _checkDependency(dependency);
    }
    
    function revealAndRelay(
        address _signer,
        address _implementation,
        bytes calldata _data,
        bytes calldata _signature
    ) external {
        Marmo marmo = Marmo(_marmoOf(_signer));

        if (_isNotContract(address(marmo))) {
            stork.reveal(_signer);
        }
        
        marmo.relay(
            _implementation,
            _data,
            _signature
        );
    }
    
    // internal
    
    // The dependency is a 'staticcall' to a 'target'
    //  when the call succeeds and it does not return false, the dependency is satisfied.
    // [160 bits (target) + n bits (data)]
    function _checkDependency(bytes memory _dependency) internal view returns (bool result) {
        if (_dependency.length == 0) {
            result = true;
        } else {
            assembly {
                let response := mload(0x40)
                let success := staticcall(
                    gas,
                    mload(add(_dependency, 20)),
                    add(52, _dependency),
                    sub(mload(_dependency), 20),
                    response,
                    32
                )

                result := and(gt(success, 0), gt(mload(response), 0))
            }
        }
    }
}