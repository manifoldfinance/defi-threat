/**
 * Source Code first verified at https://etherscan.io on Thursday, May 9, 2019
 (UTC) */

pragma solidity 0.4.18;

library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract ERC20Interface {
    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) returns (bool success);
    // Get the account balance of another account with address _owner
    function balanceOf(address _owner) constant returns (uint256 balance);
}

contract MonLockupFund is Ownable {
    using SafeMath for uint256;
    ERC20Interface token;

    address public constant tokenAddress = 0x6242a2762F5a4DB46ef8132398CB6391519aBe21;
    address public wallet_A = 0xC7bac67FbE48a8e1A0d37e6d6F0d3e34582be40f;
    address public wallet_B = 0x2061cAC4460A3DE836728487e4A092b811b2fdA7;
    address public wallet_C = 0x60aF1A04244868abc812a8C854a62598E7f43Fcd;
    uint256 public lockupDate = 1557360000;
    uint256 public initLockupAmt = 150000000e18;

    function MonLockupFund () public {
        token = ERC20Interface(tokenAddress);
    }

    function setLockupAmt(uint256 _amt) public onlyOwner {
        initLockupAmt = _amt;
    }

    function setLockupDate(uint _date) public onlyOwner {
        lockupDate = _date;
    }

    function setWallet(address[] _dest) public onlyOwner {
        wallet_A = _dest[0];
        wallet_B = _dest[1];
        wallet_C = _dest[2];
    }

    function withdraw() public {
        uint256 currBalance = token.balanceOf(this);
        uint256 currLocking = getCurrLocking();

        require(currBalance > currLocking);
        uint256 available = currBalance.sub(currLocking);

        token.transfer(wallet_A, available.mul(60).div(100));
        token.transfer(wallet_B, available.mul(30).div(100));
        token.transfer(wallet_C, available.mul(10).div(100));
    }

    function getCurrLocking()
        public
		view
        returns (uint256)
	{
        uint256 diff = (now - lockupDate) / 2592000; // month diff
        uint256 partition = 30;

        if (diff >= partition) 
            return 0;
        else
            return initLockupAmt.mul(partition-diff).div(partition);
    }

    function close() public onlyOwner {
        selfdestruct(owner);
    }
}