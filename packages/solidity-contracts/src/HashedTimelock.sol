/**
 * Source Code first verified at https://etherscan.io on Wednesday, April 24, 2019
 (UTC) */

//                                               __                __                                                            
//                                              |  \              |  \                                                           
//   _______  __   __   __   ______    ______  _| $$_     ______  | $$   __   ______   _______       ______    ______    ______  
//  /       \|  \ |  \ |  \ |      \  /      \|   $$ \   /      \ | $$  /  \ /      \ |       \     |      \  /      \  /      \ 
// |  $$$$$$$| $$ | $$ | $$  \$$$$$$\|  $$$$$$\\$$$$$$  |  $$$$$$\| $$_/  $$|  $$$$$$\| $$$$$$$\     \$$$$$$\|  $$$$$$\|  $$$$$$\
//  \$$    \ | $$ | $$ | $$ /      $$| $$  | $$ | $$ __ | $$  | $$| $$   $$ | $$    $$| $$  | $$    /      $$| $$  | $$| $$  | $$
//  _\$$$$$$\| $$_/ $$_/ $$|  $$$$$$$| $$__/ $$ | $$|  \| $$__/ $$| $$$$$$\ | $$$$$$$$| $$  | $$ __|  $$$$$$$| $$__/ $$| $$__/ $$
// |       $$ \$$   $$   $$ \$$    $$| $$    $$  \$$  $$ \$$    $$| $$  \$$\ \$$     \| $$  | $$|  \\$$    $$| $$    $$| $$    $$
//  \$$$$$$$   \$$$$$\$$$$   \$$$$$$$| $$$$$$$    \$$$$   \$$$$$$  \$$   \$$  \$$$$$$$ \$$   \$$ \$$ \$$$$$$$| $$$$$$$ | $$$$$$$ 
//                                   | $$                                                                    | $$      | $$      
//                                   | $$                                                                    | $$      | $$      
//                                    \$$                                                                     \$$       \$$      
// https://swaptoken.app

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.2;

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

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.2;

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/HashedTimelock.sol

pragma solidity 0.5.3;



/**
 * @title Hashed Timelock Contracts (HTLCs) on Ethereum ETH.
 *
 * This contract provides a way to create and keep HTLCs for ETH.
 *
 * See HashedTimelockERC20.sol for a contract that provides the same functions 
 * for ERC20 tokens.
 *
 * Protocol:
 *
 *  1) newContract(receiver, hashlock, timelock) - a sender calls this to create
 *      a new HTLC and gets back a 32 byte contract id
 *  2) withdraw(contractId, preimage) - once the receiver knows the preimage of
 *      the hashlock hash they can claim the ETH with this function
 *  3) refund() - after timelock has expired and if the receiver did not 
 *      withdraw funds the sender / creater of the HTLC can get their ETH 
 *      back with this function.
 */
contract HashedTimelock {

    using SafeMath for uint256;

    event LogHTLCNew(
        bytes32 indexed contractId,
        address indexed sender,
        address indexed receiver,
        uint amount,
        uint timelock
    );
    event LogHTLCWithdraw(bytes32 indexed contractId, bytes32 preimage);
    event LogHTLCRefund(bytes32 indexed contractId);

    struct LockContract {
        address payable sender;
        address payable receiver;
        uint amount;
        uint timelock; // UNIX timestamp seconds - locked UNTIL this time
        bool withdrawn;
        bool refunded;
        bytes32 preimage;
    }

    modifier fundsSent() {
        require(msg.value > 0, "msg.value must be > 0");
        _;
    }
    modifier futureTimelock(uint _time) {
        // only requirement is the timelock time is after the last blocktime (now).
        // probably want something a bit further in the future then this.
        // but this is still a useful sanity check:
        require(_time > now + 1 hours, "timelock time must be in the future");
        _;
    }
    modifier contractExists(bytes32 _contractId) {
        require(haveContract(_contractId), "contractId does not exist");
        _;
    }
    modifier hashlockMatches(bytes32 _contractId, bytes32 _x) {
        require(
            _contractId == keccak256(abi.encodePacked(_x)),
            "hashlock hash does not match"
        );
        _;
    }
    modifier withdrawable(bytes32 _contractId) {
        require(contracts[_contractId].withdrawn == false, "withdrawable: already withdrawn");
        require(contracts[_contractId].refunded == false, "withdrawable: already refunded");
        _;
    }
    modifier refundable(bytes32 _contractId) {
        require(contracts[_contractId].sender == msg.sender, "refundable: not sender");
        require(contracts[_contractId].refunded == false, "refundable: already refunded");
        require(contracts[_contractId].withdrawn == false, "refundable: already withdrawn");
        require(contracts[_contractId].timelock <= now, "refundable: timelock not yet passed");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "you are not an owner");
        _;
    }

    mapping (bytes32 => LockContract) contracts;
    uint256 public feePercent; // 5 == 0.05 %
    uint oneHundredPercent = 10000; // 100 %
    address payable public owner;
    uint feeToWithdraw;

    constructor(address payable _owner, uint256 _feePercent) public {
        feePercent = _feePercent;
        owner = _owner;
    }

    function setFeePercent(uint256 _feePercent) external onlyOwner {
        require(_feePercent < oneHundredPercent.div(2), "should be less than 50%");
        feePercent = _feePercent;
    }
    /**
     * @dev Sender sets up a new hash time lock contract depositing the ETH and 
     * providing the reciever lock terms.
     *
     * @param _receiver Receiver of the ETH.
     * @param _hashlock A sha-2 sha256 hash hashlock.
     * @param _timelock UNIX epoch seconds time that the lock expires at. 
     *                  Refunds can be made after this time.
     */
    function newContract(address payable _receiver, bytes32 _hashlock, uint _timelock)
        external
        payable
        fundsSent
        futureTimelock(_timelock)
    {
        uint256 swapValue = msg.value.mul(oneHundredPercent).div(oneHundredPercent.add(feePercent));
        uint feeValue = msg.value.sub(swapValue);
        feeToWithdraw = feeValue.add(feeToWithdraw);

        // Reject if a contract already exists with the same parameters. The
        // sender must change one of these parameters to create a new distinct 
        // contract.
        if (haveContract(_hashlock)) {
            revert("contract exist");
        }

        contracts[_hashlock] = LockContract(
            msg.sender,
            _receiver,
            swapValue,
            _timelock,
            false,
            false,
            0x0
        );

        emit LogHTLCNew(
            _hashlock,
            msg.sender,
            _receiver,
            swapValue,
            _timelock
        );
    }

    /**
     * @dev Called by the receiver once they know the preimage of the hashlock.
     * This will transfer the locked funds to their address.
     *
     * @param _contractId Id of the HTLC.
     * @param _preimage sha256(_preimage) should equal the contract hashlock.
     * @return bool true on success
     */
    function withdraw(bytes32 _contractId, bytes32 _preimage)
        external
        contractExists(_contractId)
        hashlockMatches(_contractId, _preimage)
        withdrawable(_contractId)
        returns (bool)
    {
        LockContract storage c = contracts[_contractId];
        c.preimage = _preimage;
        c.withdrawn = true;
        c.receiver.transfer(c.amount);
        emit LogHTLCWithdraw(_contractId, _preimage);
        return true;
    }

    /**
     * @dev Called by the sender if there was no withdraw AND the time lock has
     * expired. This will refund the contract amount.
     *
     * @param _contractId Id of HTLC to refund from.
     * @return bool true on success
     */
    function refund(bytes32 _contractId)
        external
        contractExists(_contractId)
        refundable(_contractId)
        returns (bool)
    {
        LockContract storage c = contracts[_contractId];
        c.refunded = true;
        c.sender.transfer(c.amount);
        emit LogHTLCRefund(_contractId);
        return true;
    }

    function claimTokens(address _token) external onlyOwner {
        if (_token == address(0)) {
            owner.transfer(feeToWithdraw);
            return;
        }
        IERC20 erc20token = IERC20(_token);
        uint256 balance = erc20token.balanceOf(address(this));
        erc20token.transfer(owner, balance);
    }

    /**
     * @dev Get contract details.
     * @param _contractId HTLC contract id
     * @return All parameters in struct LockContract for _contractId HTLC
     */
    function getContract(bytes32 _contractId)
        public
        view
        returns (
            address sender,
            address receiver,
            uint amount,
            uint timelock,
            bool withdrawn,
            bool refunded,
            bytes32 preimage
        )
    {
        if (haveContract(_contractId) == false)
            return (address(0), address(0), 0, 0, false, false, 0);
        LockContract storage c = contracts[_contractId];
        return (c.sender, c.receiver, c.amount, c.timelock,
            c.withdrawn, c.refunded, c.preimage);
    }

    /**
     * @dev Is there a contract with id _contractId.
     * @param _contractId Id into contracts mapping.
     */
    function haveContract(bytes32 _contractId)
        public
        view
        returns (bool exists)
    {
        exists = (contracts[_contractId].sender != address(0));
    }

}