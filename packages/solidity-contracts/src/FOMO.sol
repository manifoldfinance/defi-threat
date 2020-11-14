/**
 * Source Code first verified at https://etherscan.io on Friday, May 10, 2019
 (UTC) */

pragma solidity ^0.4.13;


contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract FOMO is ERC20,Ownable{
	using SafeMath for uint256;

	//the base info of the token
	string public constant name="FOMO";
	string public constant symbol="FMC";
	string public constant version = "1.0";
	uint256 public constant decimals = 18;
    uint256 public airdropSupply;
    
    address public admin;

	uint256 public MAX_SUPPLY=20000000*10**decimals;


    struct epoch  {
        uint256 endTime;
        uint256 amount;
    }


	mapping(address=>epoch[]) public lockEpochsMap;


    mapping(address => uint256) balances;
	mapping (address => mapping (address => uint256)) allowed;
	

	function FOMO(){
        airdropSupply=0;
		totalSupply = MAX_SUPPLY;
		balances[msg.sender] = MAX_SUPPLY;
		Transfer(0x0, msg.sender, MAX_SUPPLY);
	}

    function airdrop(address [] _holders,uint256 paySize) external
    	onlyOwner 
	{
        uint256 count = _holders.length;
        assert(paySize.mul(count) <= balanceOf(msg.sender));
        for (uint256 i = 0; i < count; i++) {
            transfer(_holders [i], paySize);
			airdropSupply = airdropSupply.add(paySize);
        }
    }

    function addIssue(uint256 amount) external
    {
		assert(msg.sender == owner||msg.sender == admin);
		if(msg.sender == owner){
			balances[msg.sender] = balances[msg.sender].add(amount);
			MAX_SUPPLY=MAX_SUPPLY.add(amount);
			Transfer(0x0, msg.sender, amount);
		}else if(msg.sender == admin){
			balances[msg.sender] = balances[msg.sender].add(amount);
			Transfer(0x0, msg.sender, amount);
		}
	}


	function () payable external
	{
	}


	function etherProceeds() external
		onlyOwner

	{
		if(!msg.sender.send(this.balance)) revert();
	}



	function lockBalance(address user, uint256 amount,uint256 endTime) external
		onlyOwner
	{
		 epoch[] storage epochs = lockEpochsMap[user];
		 epochs.push(epoch(endTime,amount));
	}


  	function transfer(address _to, uint256 _value) public  returns (bool)
 	{
		require(_to != address(0));
		//计算锁仓份额
		epoch[] epochs = lockEpochsMap[msg.sender];
		uint256 needLockBalance = 0;
		for(uint256 i;i<epochs.length;i++)
		{
			if( now < epochs[i].endTime )
			{
				needLockBalance=needLockBalance.add(epochs[i].amount);
			}
		}

		require(balances[msg.sender].sub(_value)>=needLockBalance);
		// SafeMath.sub will throw if there is not enough balance.
		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);
		Transfer(msg.sender, _to, _value);
		return true;
  	}

  	function balanceOf(address _owner) public constant returns (uint256 balance) 
  	{
		return balances[_owner];
  	}


  	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) 
  	{
		require(_to != address(0));


		epoch[] epochs = lockEpochsMap[_from];
		uint256 needLockBalance = 0;
		for(uint256 i;i<epochs.length;i++)
		{
			if( now < epochs[i].endTime )
			{
				needLockBalance = needLockBalance.add(epochs[i].amount);
			}
		}

		require(balances[_from].sub(_value)>=needLockBalance);
		uint256 _allowance = allowed[_from][msg.sender];

		balances[_from] = balances[_from].sub(_value);
		balances[_to] = balances[_to].add(_value);
		allowed[_from][msg.sender] = _allowance.sub(_value);
		Transfer(_from, _to, _value);
		return true;
  	}

  	function approve(address _spender, uint256 _value) public returns (bool) 
  	{
		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);
		return true;
  	}

  	function allowance(address _owner, address _spender) public constant returns (uint256 remaining) 
  	{
		return allowed[_owner][_spender];
  	}

    function setAdmin(address _admin) public onlyOwner{
        admin=_admin;
    }
	  
}