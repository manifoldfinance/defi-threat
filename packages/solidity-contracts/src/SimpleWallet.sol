/**
 * Source Code first verified at https://etherscan.io on Tuesday, April 2, 2019
 (UTC) */

pragma solidity >=0.4.22 <0.6.0;

interface ERC20Interface {
    function transfer(address _to, uint256 _value) external returns (bool success);
    function balanceOf(address _owner) external view returns (uint256 balance);
}

contract SimpleWallet {

    function flushTokens(address _tokenContractAddress,address _collectorAddress) public  {
        ERC20Interface instance = ERC20Interface(_tokenContractAddress);
        address forwarderAddress = address(this);
        uint256 forwarderBalance = instance.balanceOf(forwarderAddress);
        if (forwarderBalance == 0) {
            return;
        }
        require(instance.transfer(_collectorAddress, forwarderBalance));

    }
    
}