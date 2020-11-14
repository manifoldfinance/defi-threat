pragma solidity ^0.5.7;

import "./ERC20.sol";
import "./ERC20Detailed.sol";

contract AweCoin is ERC20, ERC20Detailed {
    uint8 public constant DECIMALS = 0;
    uint256 public constant INITIAL_SUPPLY = 10000000000 * (10 ** uint256(DECIMALS));

    constructor () public ERC20Detailed("AweCoin", "AWE", DECIMALS) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}
