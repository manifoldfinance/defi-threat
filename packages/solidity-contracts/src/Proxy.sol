/**
 * Source Code first verified at https://etherscan.io on Wednesday, March 20, 2019
 (UTC) */

pragma solidity ^0.5.3;

// counter.market smart contracts:
//  1) Proxy (this one) - delegatecalls into current exchange code, maintains storage of exchange state
//  2) Registry - stores information on the latest exchange contract version and user approvals
//  3) Treasury - takes custody of funds, moves them between token accounts, authorizing exchange code via Registry

// Getting current code address is the only thing Proxy needs from Registry.
interface RegistryInterface {
    function getExchangeContract() external view returns (address);
}

// Counter contracts are deployed at predefined addresses which can be hardcoded.
contract FixedAddress {
    address constant ProxyAddress = 0x1234567896326230a28ee368825D11fE6571Be4a;
    address constant TreasuryAddress = 0x12345678979f29eBc99E00bdc5693ddEa564cA80;
    address constant RegistryAddress = 0x12345678982cB986Dd291B50239295E3Cb10Cdf6;

    function getRegistry() internal pure returns (RegistryInterface) {
        return RegistryInterface(RegistryAddress);
    }
}

contract Proxy is FixedAddress {

  function () external payable {
      // Query current code version from Registry.
      address _impl = getRegistry().getExchangeContract();

      // Typical implementation of proxied delegatecall with RETURNDATASIZE/RETURNDATACOPY.
      // Quick refresher:
      //     delegatecall uses code from other contract, yet operates on Proxy storage,
      //     which means the latter is preserved between code upgrades.
      assembly {
          let ptr := mload(0x40)
          calldatacopy(ptr, 0, calldatasize)
          let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
          let size := returndatasize
          returndatacopy(ptr, 0, size)

          switch result
          case 0 { revert(ptr, size) }
          default { return(ptr, size) }
      }
  }

}