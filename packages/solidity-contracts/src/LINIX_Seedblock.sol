/**
 * Source Code first verified at https://etherscan.io on Wednesday, April 17, 2019
 (UTC) */

pragma solidity ^0.5.7;
//LNSB token can be swapped with LNX when LNX ends its sale. 
//LNSB token has 1:1 ratio with LNX token
//total number of LNSB is 2,625,000 = 2,500,000(regular sale amount) + 125,000(bonus sale amount)
//LNSB token is bound to transaction hash ( 0x15c8982c85033ef01fe55abefd5f5544b9960777ffd80d178bf9839cfccc814c ) and transaction hash (0x52f28919791119b2a9fcef828618f4e9df3302ae596f997902503d47ef940cd7 )
//transfer of regular sale amount = 0x15c8982c85033ef01fe55abefd5f5544b9960777ffd80d178bf9839cfccc814c
//transfer of bonus sale amount = 0x52f28919791119b2a9fcef828618f4e9df3302ae596f997902503d47ef940cd7
//bound LNX token is owned by seedblock( 0xbCaA9Fb04aBBCD5C39f7681028bdbd597E0d12fD ) until LINIX ends its sale. 
//if "Owner_master" of LNSB token is not equal to "Owner_master" of LNX token, the certain token cannot be swapped with LNX token.

library SafeMath{
  	function mul(uint256 a, uint256 b) internal pure returns (uint256)
    	{
		uint256 c = a * b;
		assert(a == 0 || c / a == b);

		return c;
  	}

  	function div(uint256 a, uint256 b) internal pure returns (uint256)
	{
		uint256 c = a / b;

		return c;
  	}

  	function sub(uint256 a, uint256 b) internal pure returns (uint256)
	{
		assert(b <= a);

		return a - b;
  	}

  	function add(uint256 a, uint256 b) internal pure returns (uint256)
	{
		uint256 c = a + b;
		assert(c >= a);

		return c;
  	}
}

contract Ownable
{
  	address public Owner_master;
  	address public Owner_creator;
  	address public Owner_manager;

  	event ChangeOwner_master(address indexed _from, address indexed _to);
  	event ChangeOwner_creator(address indexed _from, address indexed _to);
  	event ChangeOwner_manager(address indexed _from, address indexed _to);

  	modifier onlyOwner_master{ 
          require(msg.sender == Owner_master);	_; 	}
  	modifier onlyOwner_creator{ 
          require(msg.sender == Owner_creator); _; }
  	modifier onlyOwner_manager{ 
          require(msg.sender == Owner_manager); _; }
  	constructor() public { 
          Owner_master = msg.sender; }
  	
    
    
    
    
    
    function transferOwnership_master(address _to) onlyOwner_master public{
        	require(_to != Owner_master);
        	require(_to != Owner_creator);
        	require(_to != Owner_manager);
        	require(_to != address(0x0));

		address from = Owner_master;
  	    	Owner_master = _to;
  	    
  	    	emit ChangeOwner_master(from, _to);}

  	function transferOwner_creator(address _to) onlyOwner_master public{
	        require(_to != Owner_master);
        	require(_to != Owner_creator);
        	require(_to != Owner_manager);
	        require(_to != address(0x0));

		address from = Owner_creator;        
	    	Owner_creator = _to;
        
    		emit ChangeOwner_creator(from, _to);}

  	function transferOwner_manager(address _to) onlyOwner_master public{
	        require(_to != Owner_master);
	        require(_to != Owner_creator);
        	require(_to != Owner_manager);
	        require(_to != address(0x0));
        	
		address from = Owner_manager;
    		Owner_manager = _to;
        
	    	emit ChangeOwner_manager(from, _to);}
}

contract Helper
{
    event Transfer( address indexed _from, address indexed _to, uint _value);
    event Approval( address indexed _owner, address indexed _spender, uint _value);
    
    function totalSupply() view public returns (uint _supply);
    function balanceOf( address _who ) public view returns (uint _value);
    function transfer( address _to, uint _value) public returns (bool _success);
    function approve( address _spender, uint _value ) public returns (bool _success);
    function allowance( address _owner, address _spender ) public view returns (uint _allowance);
    function transferFrom( address _from, address _to, uint _value) public returns (bool _success);
}

contract LINIX_Seedblock is Helper, Ownable
{
    using SafeMath for uint;
    
    string public name;
    string public symbol;
    uint public decimals;
    
    uint constant private zeroAfterDecimal = 10**18;
    
    uint constant public maxSupply             = 2625000 * zeroAfterDecimal;
    
    uint constant public maxSupply_SeedBlock        =   2625000 * zeroAfterDecimal;

    
    uint public issueToken_Total;
    
    uint public issueToken_SeedBlock;
    
    uint public burnTokenAmount;
    
    mapping (address => uint) public balances;
    mapping (address => mapping ( address => uint )) public approvals;

    bool public tokenLock = true;
    bool public saleTime = true;
    uint public endSaleTime = 0;
    
    event Burn(address indexed _from, uint _value);
    
    event Issue_SeedBlock(address indexed _to, uint _tokens);
    
    event TokenUnLock(address indexed _to, uint _tokens);

    
    constructor() public
    {
        name        = "LNXSB";
        decimals    = 18;
        symbol      = "LNSB";
        
        issueToken_Total      = 0;
        
        issueToken_SeedBlock     = 0;

        
        require(maxSupply == maxSupply_SeedBlock);

    }
    
    // ERC - 20 Interface -----

    function totalSupply() view public returns (uint) {
        return issueToken_Total;}
    
    function balanceOf(address _who) view public returns (uint) {
        uint balance = balances[_who];
        
        return balance;}
    
    function transfer(address _to, uint _value) public returns (bool) {
        require(isTransferable() == true);
        require(balances[msg.sender] >= _value);
        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        
        emit Transfer(msg.sender, _to, _value);
        
        return true;}
    
    function approve(address _spender, uint _value) public returns (bool){
        require(isTransferable() == true);
        require(balances[msg.sender] >= _value);
        
        approvals[msg.sender][_spender] = _value;
        
        emit Approval(msg.sender, _spender, _value);
        
        return true; }
    
    function allowance(address _owner, address _spender) view public returns (uint) {
        return approvals[_owner][_spender];}

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        require(isTransferable() == true);
        require(balances[_from] >= _value);
        require(approvals[_from][msg.sender] >= _value);
        
        approvals[_from][msg.sender] = approvals[_from][msg.sender].sub(_value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to]  = balances[_to].add(_value);
        
        emit Transfer(_from, _to, _value);
        
        return true;}
    
    // -----
    
    // Issue Function -----


    function issue_noVesting_Public(address _to, uint _value) onlyOwner_creator public
    {
        uint tokens = _value * zeroAfterDecimal;
        require(maxSupply_SeedBlock >= issueToken_SeedBlock.add(tokens));
        
        balances[_to] = balances[_to].add(tokens);
        
        issueToken_Total = issueToken_Total.add(tokens);
        issueToken_SeedBlock = issueToken_SeedBlock.add(tokens);
        
        emit Issue_SeedBlock(_to, tokens);
    }    
    
       // Lock Function -----
    
    function isTransferable() private view returns (bool)
    {
        if(tokenLock == false)
        {
            return true;
        }
        else if(msg.sender == Owner_manager)
        {
            return true;
        }
        
        return false;
    }
    
    function setTokenUnlock() onlyOwner_manager public
    {
        require(tokenLock == true);
        require(saleTime == false);
        
        tokenLock = false;
    }
    
    function setTokenLock() onlyOwner_manager public
    {
        require(tokenLock == false);
        
        tokenLock = true;
    }
    
    // -----
    
    // ETC / Burn Function -----
    
    function () payable external
    {
        revert();
    }
    
    function endSale() onlyOwner_manager public
    {
        require(saleTime == true);
        
        saleTime = false;
        
        uint time = now;
        
        endSaleTime = time;
        
    }
    
    function withdrawTokens(address _contract, uint _decimals, uint _value) onlyOwner_manager public
    {

        if(_contract == address(0x0))
        {
            uint eth = _value.mul(10 ** _decimals);
            msg.sender.transfer(eth);
        }
        else
        {
            uint tokens = _value.mul(10 ** _decimals);
            Helper(_contract).transfer(msg.sender, tokens);
            
            emit Transfer(address(0x0), msg.sender, tokens);
        }
    }
    
    function burnToken(uint _value) onlyOwner_manager public
    {
        uint tokens = _value * zeroAfterDecimal;
        
        require(balances[msg.sender] >= tokens);
        
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        
        burnTokenAmount = burnTokenAmount.add(tokens);
        issueToken_Total = issueToken_Total.sub(tokens);
        
        emit Burn(msg.sender, tokens);
    }
    
    function close() onlyOwner_master public
    {
        selfdestruct(msg.sender);
    }
    
    // -----
}