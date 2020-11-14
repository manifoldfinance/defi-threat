/**
 * Source Code first verified at https://etherscan.io on Wednesday, May 8, 2019
 (UTC) */

pragma solidity ^0.4.25;

 /*
  * @title: SafeMath
  * @dev: Helper contract functions to arithmatic operations safely.
  */
contract SafeMath {
    function Sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
    
        return c;
    }
    function Add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function Mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
}

 /*
  * @title: Token
  * @dev: Interface contract for ERC20 tokens
  */
contract Token {
      function totalSupply() public view returns (uint256 supply);
      function balanceOf(address _owner) public view returns (uint256 balance);
      function transfer(address _to, uint256 _value) public returns (bool success);
      function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
      function approve(address _spender, uint256 _value) public returns (bool success);
      function allowance(address _owner, address _spender) public view returns (uint256 remaining);
      event Transfer(address indexed _from, address indexed _to, uint256 _value);
      event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

 /*
  * @title: Staking
  * @author BlockBank (https://www.blockbank.co.kr)
  */
contract Staking is SafeMath
{
    // _prAddress: ERC20 contract address
    // msg.sender: owner && operator
    constructor(address _prAddress) public
    {
        owner = msg.sender;
        operator = owner;
        prAddress = _prAddress;
        isContractUse = true;
    }

    address public owner;
    // Functions with this modifier can only be executed by the owner
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    address public operator;
    // Functions with this modifier can only be executed by the operator
    modifier onlyOperator() {
        require(msg.sender == operator);
        _;
    }
    function transferOperator(address _operator) onlyOwner public {
        operator = _operator;
    }
    
    bool public isContractUse;
    // Functions with this modifier can only be executed when this contract is not abandoned
    modifier onlyContractUse {
        require(isContractUse == true);
        _;
    }
    
    function SetContractUse(bool _isContractUse) onlyOperator public{
        isContractUse = _isContractUse;
    }

    uint32 public lastAcccountId;
    mapping (uint32 => address) id_account;
    mapping (uint32 => bool) accountId_freeze;
    mapping (address => uint32) account_id;
    // Find or add account
    function FindOrAddAccount(address findAddress) private returns (uint32)
    {
        if (account_id[findAddress] == 0)
        {
            account_id[findAddress] = ++lastAcccountId;
            id_account[lastAcccountId] = findAddress;
        }
        return account_id[findAddress];
    }
    // Find or revert account
    function FindOrRevertAccount() private view returns (uint32)
    {
        uint32 accountId = account_id[msg.sender];
        require(accountId != 0);
        return accountId;
    }
    // Get account id of msg sender
    function GetMyAccountId() view public returns (uint32)
    {
        return account_id[msg.sender];
    }
    // Get account id of any users
    function GetAccountId(address account) view public returns (uint32)
    {
        return account_id[account];
    }
    // Freeze or unfreez of account
    function SetFreezeByAddress(bool isFreeze, address account) onlyOperator public
    {
        uint32 accountId = account_id[account];

        if (accountId != 0)
        {
            accountId_freeze[accountId] = isFreeze;
        }
    }
    function IsFreezeByAddress(address account) public view returns (bool)
    {
        uint32 accountId = account_id[account];
        
        if (accountId != 0)
        {
            return accountId_freeze[accountId];
        }
        return false;
    }

    // reserved: Balance held up in orderBook
    // available: Balance available for trade
    struct Balance
    {
        uint256 available;
        uint256 maturity;
    }

    struct ListItem
    {
        uint32 prev;
        uint32 next;
    }

    mapping (uint32 => Balance) AccountId_Balance;
    
    uint256 public totalBonus;
    address public prAddress;
    
    uint256 public interest6weeks; //bp
    uint256 public interest12weeks; //bp
    
    // set interst for each holding period: 6 / 12 weeks
    function SetInterest(uint256 _interest6weeks, uint256 _interest12weeks) onlyOperator public
    {
        interest6weeks = _interest6weeks;    
        interest12weeks = _interest12weeks;
    }
    
    // deposit bonus to pay interest
    function depositBonus(uint256 amount) onlyOwner public
    {
        require(Token(prAddress).transferFrom(msg.sender, this, amount));
        
        totalBonus = Add(totalBonus, amount);
    }
    
    // withdraw bonus to owner account
    function WithdrawBonus(uint256 amount) onlyOwner public
    {
        require(Token(prAddress).transfer(msg.sender, amount));
        totalBonus = Sub(totalBonus, amount);
    }

    // Deposit ERC20's for saving
    function storeToken6Weeks(uint256 amount) onlyContractUse public
    {
        uint32 accountId = FindOrAddAccount(msg.sender);
        require(accountId_freeze[accountId] == false);
        require(AccountId_Balance[accountId].available == 0);
        
        require(Token(prAddress).transferFrom(msg.sender, this, amount));
        
        uint256 interst = Mul(amount, interest6weeks) / 10000;
        
        totalBonus = Sub(totalBonus, interst);
        AccountId_Balance[accountId].available = Add(AccountId_Balance[accountId].available, amount + interst);
        AccountId_Balance[accountId].maturity = now + 6 weeks;
    }
    // Deposit ERC20's for saving
    function storeToken12Weeks(uint128 amount) onlyContractUse public
    {
        uint32 accountId = FindOrAddAccount(msg.sender);
        require(accountId_freeze[accountId] == false);
        require(AccountId_Balance[accountId].available == 0);
        
        require(Token(prAddress).transferFrom(msg.sender, this, amount));
        
        uint256 interst = Mul(amount, interest12weeks) / 10000;
        
        totalBonus = Sub(totalBonus, interst);
        AccountId_Balance[accountId].available = Add(AccountId_Balance[accountId].available, amount + interst);
        AccountId_Balance[accountId].maturity = now + 12 weeks;
    }
    // Withdraw ERC20's to personal addresstrue
    function withdrawToken() public
    {
        uint32 accountId = FindOrAddAccount(msg.sender);
        require(AccountId_Balance[accountId].maturity < now);
        uint256 amount = AccountId_Balance[accountId].available; 
        require(amount > 0);
        AccountId_Balance[accountId].available = 0;
        require(Token(prAddress).transfer(msg.sender, amount));
    }

    // Below two emergency functions will be never used in normal situations.
    // These function is only prepared for emergency case such as smart contract hacking Vulnerability or smart contract abolishment
    // Withdrawn fund by these function cannot belong to any operators or owners.
    // Withdrawn fund should be distributed to individual accounts having original ownership of withdrawn fund.
    
    function emergencyWithdrawalETH(uint256 amount) onlyOwner public
    {
        require(msg.sender.send(amount));
    }
    function emergencyWithdrawalToken(uint256 amount) onlyOwner public
    {
        Token(prAddress).transfer(msg.sender, amount);
    }

    function getMyBalance() view public returns (uint256 available, uint256 maturity)
    {
        uint32 accountId = FindOrRevertAccount();
        available = AccountId_Balance[accountId].available;
        maturity = AccountId_Balance[accountId].maturity;
    }
    
    function getTimeStamp() view public returns (uint256)
    {
        return now;
    }
}