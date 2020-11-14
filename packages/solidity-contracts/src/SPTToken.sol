/**
 * Source Code first verified at https://etherscan.io on Thursday, May 2, 2019
 (UTC) */

pragma solidity ^0.5.8;
// @notice SECURITY TOKEN CONTRACT
// @dev ERC-1404 with ERC-20 with ERC223 protection Token Standard Compliant
// @author Geoffrey Tipton at AEN
// ----------------------------------------------------------------------------
// Deployed by : Geoffrey Tipton
// Symbol      : SMPT
// Name        : Smart Pharma Token
// Total supply: 1,000,000,000
// Decimals    : 8
//
// (c) AENCOIN. The MIT Licence.
// ----------------------------------------------------------------------------
// THE SMPT TOKENS HAVE NOT BEEN REGISTERED UNDER THE U.S. SECURITIES ACT OF
// 1933, AS AMENDED (THE　“SECURITIES ACT”).  THE SMPT TOKENS WERE ISSUED IN
// A TRANSACTION EXEMPT FROM THE REGISTRATION REQUIREMENTS OF THE SECURITIES
// ACT PURSUANT TO REGULATION S PROMULGATED UNDER IT.  THE SMPT TOKENS MAY NOT
// BE OFFERED OR SOLD IN THE UNITED STATES UNLESS REGISTERED UNDER THE SECURITIES
// ACT OR AN EXEMPTION FROM REGISTRATION IS AVAILABLE.  TRANSFERS OF THE SMPT
// TOKENS MAY NOT BE MADE EXCEPT IN ACCORDANCE WITH THE PROVISIONS OF REGULATION S,
// PURSUANT TO REGISTRATION UNDER THE SECURITIES ACT, OR PURSUANT TO AN AVAILABLE
// EXEMPTION FROM REGISTRATION.  FURTHER, HEDGING TRANSACTIONS WITH REGARD TO THE
// SMPT TOKENS MAY NOT BE CONDUCTED UNLESS IN COMPLIANCE WITH THE SECURITIES ACT.
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b; require(c >= a,"Can not add Negative Values"); }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a, "Result can not be negative"); c = a - b;  }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b; require(a == 0 || c / a == b,"Dived by Zero protection"); }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0,"Devide by Zero protection"); c = a / b; }
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) public view returns (uint256 balance);
    function allowance(address owner, address spender) public view returns (uint remaining);
    function transfer(address to, uint value) public returns (bool success);
    function approve(address spender, uint value) public returns (bool success);
    function transferFrom(address from, address to, uint value) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC1404 is ERC20Interface {
    function detectTransferRestriction (address from, address to, uint256 value) public view returns (uint8);
    function messageForTransferRestriction (uint8 restrictionCode) public view returns (string memory);
}

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address internal newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public { //Only on contract creation
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only the contract owner can execute this function");
        _;
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() external {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract Managed is Owned {
    mapping (address => bool) public managers;


    modifier onlyManager () {
        require(managers[msg.sender], "Only managers may perform this action");
        _;
    }

    function addManager (address managerAddress) public onlyOwner {
        managers[managerAddress] = true;
    }

    function removeManager (address managerAddress) external onlyOwner {
        managers[managerAddress] = false;
    }
}

/* ----------------------------------------------------------------------------
 * Contract function to manage the white list
 * Byte operation to control function of the whitelist,
 * and prevent duplicate address entries. simple example
 * whiteList[add] = 0000 = 0x00 = Not allowed to do either
 * whiteList[add] = 0001 = 0x01 = Allowed to receive
 * whiteList[add] = 0010 = 0x02 = Allowed to send
 * whiteList[add] = 0011 = 0x03 = Allowed to Send and Receive
 * whiteList[add] = 0100 = 0x04 = Frozen not allowed to do either
 *----------------------------------------------------------------------------
 */
contract Whitelist is Managed {
    mapping(address => bytes1) public whiteList;
    bytes1 internal listRule;
    bytes1 internal constant WHITELISTED_CAN_RX_CODE = 0x01;  // binary for 0001
    bytes1 internal constant WHITELISTED_CAN_TX_CODE = 0x02;  // binary for 0010
    bytes1 internal constant WHITELISTED_FREEZE_CODE = 0x04;  // binary for 0100

    function frozen(address _account) public view returns (bool){ //If account is flagged to freeze return true
        return (WHITELISTED_FREEZE_CODE == (whiteList[_account] & WHITELISTED_FREEZE_CODE)); // 10 & 11 = True
    }

    function addToSendAllowed(address _to) external onlyManager {
        whiteList[_to] = whiteList[_to] | WHITELISTED_CAN_TX_CODE; // just add the code 1
    }

    function addToReceiveAllowed(address _to) external onlyManager {
        whiteList[_to] = whiteList[_to] | WHITELISTED_CAN_RX_CODE; // just add the code 2
    }

    function removeFromSendAllowed(address _to) public onlyManager {
        if (WHITELISTED_CAN_TX_CODE == (whiteList[_to] & WHITELISTED_CAN_TX_CODE))  { //check code 4 so it does toggle when recalled
            whiteList[_to] = whiteList[_to] ^ WHITELISTED_CAN_TX_CODE; // xor the code to remove the flag
        }
    }

    function removeFromReceiveAllowed(address _to) public onlyManager {
        if (WHITELISTED_CAN_RX_CODE == (whiteList[_to] & WHITELISTED_CAN_RX_CODE))  {
            whiteList[_to] = whiteList[_to] ^ WHITELISTED_CAN_RX_CODE;
        }
    }

    function removeFromBothSendAndReceiveAllowed (address _to) external onlyManager {
        removeFromSendAllowed(_to);
        removeFromReceiveAllowed(_to);
    }

    /*  this overides the individual whitelisting and manager positions so a
        frozen account can not be unfrozen by a lower level manager
    */
    function freeze(address _to) external onlyOwner {
        whiteList[_to] = whiteList[_to] | WHITELISTED_FREEZE_CODE; // 4 [0100]
    }

    function unFreeze(address _to) external onlyOwner {
        if (WHITELISTED_FREEZE_CODE == (whiteList[_to] & WHITELISTED_FREEZE_CODE )) { //Already UnFrozen
            whiteList[_to] = whiteList[_to] ^ WHITELISTED_FREEZE_CODE; // 4 [0100]
        }
    }

    /*    WhitlistRule defines what the rules are for the white listing.
          0x00 = No rule
          0x01 = Receiver must be Listed
          0x10 = Sender must be listed
          0x11 = Both must be listed
    */
    function setWhitelistRule(byte _newRule) external onlyOwner {
        listRule = _newRule;
    }
    function getWhitelistRule() external view returns (byte){
        return listRule;
    }
}

// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and an initial fixed supply
contract SPTToken is ERC1404, Owned, Whitelist {
    using SafeMath for uint;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;
    uint8 internal restrictionCheck;

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) allowed;


    // ------------------------------------------------------------------------
    // Constructor
    constructor() public {
        symbol = "SMPT";
        name = "Smart Pharma Token";
        decimals = 8;
        _totalSupply = 100000000000000000;
        balances[msg.sender] = _totalSupply;
        managers[msg.sender] = true;
        listRule = 0x00; //Receiver does not need to be whitelisted.
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    modifier transferAllowed(address _from, address _to, uint256 _amount ) {
        require(!frozen(_to) && !frozen(_from), "One of the Accounts are Frozen");  //If not frozen go check
        if ((listRule & WHITELISTED_CAN_TX_CODE) != 0) { // if whitelist send rul applies then must be set
            require(WHITELISTED_CAN_TX_CODE == (whiteList[_from] & WHITELISTED_CAN_TX_CODE), "Sending Account is not whitelisted"); // 10 & 11 = true
        }
        if ((listRule & WHITELISTED_CAN_RX_CODE) != 0) { //if whitelist to receive is required, then check,
            require(WHITELISTED_CAN_RX_CODE == (whiteList[_to] & WHITELISTED_CAN_RX_CODE),"Receiving Account is not Whitelisted"); // 01 & 11 = True
        }
        _;
    }

    // ------------------------------------------------------------------------
    // Total supply minus any lost tokens to the zero address (Potential burn)
    function totalSupply() external view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }

    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    function balanceOf(address owner) public view returns (uint256) {
        return balances[owner];
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // function transfer(address _to, uint _tokens)  public receiveAllowed(_to)  returns (bool success) {
    function transfer(address _to, uint _value)  public transferAllowed(msg.sender, _to, _value) returns (bool) {
        require((_to != address(0)) && (_to != address(this))); // Do not allow transfer to 0x0 or the token contract itself
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    function approve(address spender, uint value) public transferAllowed(msg.sender, spender, value) returns (bool) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    function transferFrom(address _from, address _to, uint _value) public transferAllowed(_from, _to, _value) returns (bool) {
        // function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        require((_to != address(0)) && (_to != address(this))); // Do not allow transfer to 0x0 or the token contract itself
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /* ------------------------------------------------------------------------
     * Returns the amount of tokens approved by the owner that can be
     * transferred to the spender's account
    */
    function allowance(address owner, address spender) public view returns (uint) {
        return allowed[owner][spender];
    }

    /* ------------------------------------------------------------------------
     * don't accept ETH
     */
    function () payable external {
        revert();
    }

    /* ------------------------------------------------------------------------
     * @This is a security over ride function that allows error correction.
     * Owner can transfer out any accidentally sent tokens
     * Call the contract address with the token address, which pretends to be the sender
     * The receiving address is the caller of the contract.
     */
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }

    /* ------------------------------------------------------------------------
     * The following functions are for 1404 interface compliance, to detect
     * a transaction is allowed before sending, to save gas and obtain a clear Message
    */
    function detectTransferRestriction (address _from, address _to, uint256 _value) public view returns (uint8 restrictionCode)
    {
        restrictionCode = 0; // No restrictions
        if ( WHITELISTED_CAN_TX_CODE == (listRule & WHITELISTED_CAN_TX_CODE) ) { //Can Send rule applies
            if (!(WHITELISTED_CAN_TX_CODE == (whiteList[_to] & WHITELISTED_CAN_TX_CODE)) ) { //True if allowed to send
                restrictionCode += 1; // Send is not allowed
            }
        }
        if (WHITELISTED_CAN_RX_CODE == (listRule & WHITELISTED_CAN_RX_CODE)){ // Can Receive Rule applied
            if (!(WHITELISTED_CAN_RX_CODE == (whiteList[_from] & WHITELISTED_CAN_RX_CODE))) {
                restrictionCode += 2; // Receive is not allowed
            }
        }
        if ((WHITELISTED_FREEZE_CODE == (whiteList[_from] & WHITELISTED_FREEZE_CODE)) ) { // Added to Frozen
            restrictionCode += 4; // Sender is Frozen
        }
        if ((WHITELISTED_FREEZE_CODE == (whiteList[_to] & WHITELISTED_FREEZE_CODE)) ) { // Added to Frozen
            restrictionCode += 8; // Receiver is Frozen
        }

        if (balanceOf(_from) < _value) {
            restrictionCode += 16; // Send has insufficient balance
        }

        return restrictionCode;
    }

    /* ------------------------------------------------------------------------------------
    * helper function to return a human readable message for the detectTransferRestriction
    */
    function messageForTransferRestriction (uint8 _restrictionCode) public view returns (string memory _message) {
        _message = "Transfer Allowed";  // default and when is zero
        if (_restrictionCode >= 16) {
            _message = "Insufficient Balance to send";
        } else if (_restrictionCode >= 8) {
            _message = "To Account is Frozen, contact provider";
        } else if (_restrictionCode >= 4) {
            _message = "From Account is Frozen, contact provider";
        } else if (_restrictionCode >= 3) {
            _message = "Both Sending and receiving address has not been KYC Approved";
        } else if (_restrictionCode >= 2) {
            _message = "Receiving address has not been KYC Approved";
        } else if (_restrictionCode >= 1) {
            _message = "Sending address has not been KYC Approved";
        }
        return _message;
    }
}