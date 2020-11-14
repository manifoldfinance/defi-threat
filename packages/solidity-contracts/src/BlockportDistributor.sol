/**
 * Source Code first verified at https://etherscan.io on Monday, May 6, 2019
 (UTC) */

pragma solidity ^0.5.0;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

/**
 * @title BlockportDistributor
 * @dev This contract can be used to distribute ether to multiple addresses
 * at once. 
 */
contract BlockportDistributor {
    using SafeMath for uint256;

    event Distributed(address payable[] receivers, uint256 amount);

    /**
     * @dev Constructor
     */
    constructor () public {
    }

    /**
     * @dev payable fallback
     * dont accept pure ether: revert it.
     */
    function () external payable {
        revert();
    }

    /**
     * @dev distribute function, note that enough ether must be send (receivers.length * amount)
     * @param receivers Addresses who should all receive amount.
     * @param amount amount to distribute to each address, in wei.
     * @return bool success
     */
    function distribute(address payable[] calldata receivers, uint256 amount) external payable returns (bool success) {
        require(amount.mul(receivers.length) == msg.value);

        for (uint256 i = 0; i < receivers.length; i++) {
            receivers[i].transfer(amount);
        }
        emit Distributed(receivers, amount);
        return true;
    }
}