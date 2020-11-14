/**
 * Source Code first verified at https://etherscan.io on Monday, May 6, 2019
 (UTC) */

// File: @gnosis.pm/util-contracts/contracts/Proxy.sol

pragma solidity ^0.5.2;

/// @title Proxied - indicates that a contract will be proxied. Also defines storage requirements for Proxy.
/// @author Alan Lu - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="76171a171836111819051f0558061b">[email protected]</a>>
contract Proxied {
    address public masterCopy;
}

/// @title Proxy - Generic proxy contract allows to execute all transactions applying the code of a master contract.
/// @author Stefan George - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c1b2b5a4a7a0af81a6afaeb2a8b2efb1ac">[email protected]</a>>
contract Proxy is Proxied {
    /// @dev Constructor function sets address of master copy contract.
    /// @param _masterCopy Master copy address.
    constructor(address _masterCopy) public {
        require(_masterCopy != address(0), "The master copy is required");
        masterCopy = _masterCopy;
    }

    /// @dev Fallback function forwards all transactions and returns all received return data.
    function() external payable {
        address _masterCopy = masterCopy;
        assembly {
            calldatacopy(0, 0, calldatasize)
            let success := delegatecall(not(0), _masterCopy, 0, calldatasize, 0, 0)
            returndatacopy(0, 0, returndatasize)
            switch success
                case 0 {
                    revert(0, returndatasize)
                }
                default {
                    return(0, returndatasize)
                }
        }
    }
}

// File: contracts/DutchExchangeProxy.sol

pragma solidity ^0.5.2;



contract DutchExchangeProxy is Proxy {
    constructor(address _masterCopy) public Proxy(_masterCopy) {}
}