/**
 * Source Code first verified at https://etherscan.io on Friday, April 5, 2019
 (UTC) */

pragma solidity ^0.4.25;

/**


					.----------------.  .----------------.  .----------------.  .----------------. 
					| .--------------. || .--------------. || .--------------. || .--------------. |
					| |  ____  ____  | || |     ____     | || |   _____      | || |  ________    | |
					| | |_   ||   _| | || |   .'    `.   | || |  |_   _|     | || | |_   ___ `.  | |
					| |   | |__| |   | || |  /  .--.  \  | || |    | |       | || |   | |   `. \ | |
					| |   |  __  |   | || |  | |    | |  | || |    | |   _   | || |   | |    | | | |
					| |  _| |  | |_  | || |  \  `--'  /  | || |   _| |__/ |  | || |  _| |___.' / | |
					| | |____||____| | || |   `.____.'   | || |  |________|  | || | |________.'  | |
					| |              | || |              | || |              | || |              | |
					| '--------------' || '--------------' || '--------------' || '--------------' |
					'----------------'  '----------------'  '----------------'  '----------------' 

 
*/


contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
	event Burn(address indexed _from, uint256 _value); 
}

contract OOOOOO {
    address public owner;
	address public Defaultaddress;
    constructor() public {
        owner = msg.sender;
    }

	modifier restricted {
        require(msg.sender == owner);
        _;
    }

}

contract Ldohtoken is ERC20Interface, OOOOOO {
	
    string 	public symbol;
    string 	public name;
    uint8 	public decimals;
    uint256 public _totalSupply;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint)) allowed;
	
	/*==============================
    =          CONSTRUCTOR         =
    ==============================*/  
	
    constructor() public {
        symbol = "HLD";
        name = "LDOH TOKEN";
        decimals = 18;
        _totalSupply = 20000000000000000000000000000;
		
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function transfer(address to, uint256 _value) public returns (bool success) {
		if (to == 0x0) revert();                               
		if (_value <= 0) revert(); 
        if (balances[msg.sender] < _value) revert();           		
        if (balances[to] + _value < balances[to]) revert(); 		
		
        balances[msg.sender] 		= sub(balances[msg.sender], _value);
        balances[to] 				= add(balances[to], _value);
        emit Transfer(msg.sender, to, _value);
        return true;
    }
	
    function approve(address spender, uint256 _value) public returns (bool success) {
		if (_value <= 0) revert(); 
        allowed[msg.sender][spender] = _value;
        emit Approval(msg.sender, spender, _value);
        return true;
    }

    function transferFrom(address from, address to, uint256 _value) public returns (bool success) {
		if (to == 0x0) revert();                                						
		if (_value <= 0) revert(); 
        if (balances[from] < _value) revert();                 					
        if (balances[to]  + _value < balances[to]) revert();  					
        if (_value > allowed[from][msg.sender]) revert();     						
		
        balances[from] 				= sub(balances[from], _value);
        allowed[from][msg.sender] 	= sub(allowed[from][msg.sender], _value);
        balances[to] 				= add(balances[to], _value);
        emit Transfer(from, to, _value);
        return true;
    }
	
	function burn(uint256 _value) public returns (bool success) {
        if (balances[msg.sender] < _value) revert();            						
		if (_value <= 0) revert(); 
        balances[msg.sender] 	= sub(balances[msg.sender], _value);                     
        _totalSupply 			= sub(_totalSupply, _value);
		
		
		ERC20Interface token = ERC20Interface(address(this));        
        token.transfer(Defaultaddress, _value);
		
        emit Burn(msg.sender, _value);
        return true;
    }


    function allowance(address TokenAddress, address spender) public constant returns (uint remaining) {
        return allowed[TokenAddress][spender];
    }
	
	function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }

    function balanceOf(address TokenAddress) public constant returns (uint balance) {
        return balances[TokenAddress];
		
    }
	
	
	/*==============================
    =           ADDITIONAL         =
    ==============================*/ 
	

    function () public payable {
    }
	
    function WithdrawEth() restricted public {
        require(address(this).balance > 0); 
		uint256 amount = address(this).balance;
        
        msg.sender.transfer(amount);
    }

    function TransferERC20Token(address tokenAddress, uint256 _value) public restricted returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, _value);
    }
	
	
	/*==============================
    =      SAFE MATH FUNCTIONS     =
    ==============================*/  	
	
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		if (a == 0) {
			return 0;
		}

		uint256 c = a * b; 
		require(c / a == b);
		return c;
	}
	
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b > 0); 
		uint256 c = a / b;
		return c;
	}
	
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b <= a);
		uint256 c = a - b;
		return c;
	}
	
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a);
		return c;
	}
	
}