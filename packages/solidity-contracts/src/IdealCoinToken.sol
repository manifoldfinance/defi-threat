pragma solidity ^0.5.7;

import "ERC20.sol";
import "ERC20Detailed.sol";

contract IdealCoinToken is ERC20, ERC20Detailed {
    uint8 public constant DECIMALS = 18;
    uint256 public constant INITIAL_SUPPLY = 2200000000 * (10 ** uint256(DECIMALS));

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public ERC20Detailed("IdealCoin", "IDEAL", DECIMALS) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}