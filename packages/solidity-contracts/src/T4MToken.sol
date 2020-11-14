pragma solidity ^0.5.6;

import "./ERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract T4MToken is ERC20, Ownable {

    using SafeMath for uint256;

    uint8 constant DECIMALS = 0;
    string constant NAME = "tap4menu";
    string constant SYMBOL = "T4M";

    // Addresses for initial allocation
    address constant PTO_ADDRESS = address(0x9b9E6813818b07175EF7877Fc10179C714AbAaE2);
    address constant TEAM_ADDRESS = address(0x200879763490c07bFaee4b4E47f9F07F4B7C1898);
    address constant RESERVE_ADDRESS = address(0xBBB38109De17A2e396E0f5344c6b8cE6A92A5cCd);
    address constant BOUNTY_ADDRESS = address(0x2d78e4Ed438a87CC0c4471D54019A93c26f3C9A1);
    address constant ADVISOR_LEGAL_ADDRESS = address(0x91801aD298F8d906bF1447F309BE948765C714Cd);
    address constant AIRDROP_ADDRESS = address(0xa9A331F9594cD5A9fd64F3A0Aa68c230c8715829);

    constructor() public {
        _mint(PTO_ADDRESS, 6000000);
        _mint(BOUNTY_ADDRESS, 1000000);
        _mint(AIRDROP_ADDRESS, 100000);
        _mintLocked(RESERVE_ADDRESS, 1000000, now + 856 days);
        _mintLocked(ADVISOR_LEGAL_ADDRESS, 400000, now + 491 days);
        _mintLocked(TEAM_ADDRESS, 1500000, now + 491 days);
    }

    /**
     * Burns token from sender account and decrease totalSupply
     */
    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }

    /**
     * Send ether from contract adress to owner
     */
    function sendEther(uint _value) public onlyOwner {
        msg.sender.transfer(_value);
    }

    /**
     * @return the name of the token.
     */
    function name() public pure returns (string memory) {
        return NAME;
    }
    /**
     * @return the symbol of the token.
     */
    function symbol() public pure returns (string memory) {
        return SYMBOL;
    }
    /**
     * @return the number of decimals of the token.
     */
    function decimals() public pure returns (uint8) {
        return DECIMALS;
    }

}