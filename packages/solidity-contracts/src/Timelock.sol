/**
 * Source Code first verified at https://etherscan.io on Monday, April 29, 2019
 (UTC) */

pragma solidity 0.4.24;

interface ERC20Token {
    function transfer(address _to, uint256 _value) external returns (bool success);
    function balanceOf(address _owner) external view returns (uint256 balance);
}

contract Timelock {
    ERC20Token public token;
    address public beneficiary;
    uint256 public releaseTime;

    event TokenReleased(address beneficiary, uint256 amount);

    constructor(
        address _token,
        address _beneficiary,
        uint256 _releaseTime
    ) public {
        require(_releaseTime > now);
        require(_beneficiary != 0x0);
        token = ERC20Token(_token);
        beneficiary = _beneficiary;
        releaseTime = _releaseTime;
    }

    function release() public returns(bool success) {
        require(now >= releaseTime);
        uint256 amount = token.balanceOf(this);
        require(amount > 0);
        token.transfer(beneficiary, amount);
        emit TokenReleased(beneficiary, amount);
        return true;
    }
}