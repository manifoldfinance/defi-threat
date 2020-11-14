pragma solidity ^0.5.0;

import './ERC20.sol';
import './ERC20Detailed.sol';

/**
 * @title Sparrow Options
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 * @author Zynesis <https://zynesis.com>
 */
contract SPO is ERC20, ERC20Detailed {
  uint8 private constant DECIMAL_PLACES = 18;
  uint256 private constant LECONTE = 10 ** uint256(DECIMAL_PLACES); // 1 SPO's base unit (similar to wei of Ether)
  uint256 public constant TOTAL_SUPPLY = 1400000000 * LECONTE; // 1.4 billion SPO

  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  constructor () public ERC20Detailed('Sparrow Options', 'SPO', DECIMAL_PLACES) {

    _mint(0x506c8fB175F87C99612D5Cb62BcdDF0490934A41, 140000000 * LECONTE); // Private Sale
    _mint(0xb1b129797cF79e750429A4c4FC793ce6A4D018F8, 100000000 * LECONTE); // Presale
    _mint(0x8C0dfbD4B2352CC0AF81AdcCB88F50e5baA201F4, 136000000 * LECONTE); // Public Sale
    _mint(0xa177fd7586e03013A4d205BAa6aE22A1Df8A84aa,  57000000 * LECONTE); // Bonus
    _mint(0xBa0a1e153a88fE140676B913cc988D27c02e44dB,  70000000 * LECONTE); // Advisors
    _mint(0xC4DB967C9592dE7f574Bc7ECA4Cbda069A77A385, 140000000 * LECONTE); // Founders
    _mint(0xF4B13a7E1Ae1dBe30a991feD1887d21305b7d605,  70000000 * LECONTE); // Employees
    _mint(0x883F593d0D38e7B0A86032853b1121f04a9b0b45, 337000000 * LECONTE); // Reserves
    _mint(0xcBfDB375A83Afd91756AfB3d740Be871A9652beF, 140000000 * LECONTE); // Marketing
    _mint(0xee08909103a90F955D9294d48f18CA6B49813534, 210000000 * LECONTE); // Partnership

    assert(totalSupply() == TOTAL_SUPPLY); // Ensure that exactly all total supply has been allocated
  }
}
