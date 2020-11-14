/**
 * Source Code first verified at https://etherscan.io on Thursday, April 4, 2019
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

	/*==============================
    =        TOKEN CONTRACT        =
    ==============================*/  

contract HLD{
	
	address EthereumNodes; 
	
    constructor() public { 
        EthereumNodes = msg.sender;
    }
    modifier restricted() {
        require(msg.sender == EthereumNodes);
        _;
    } 

	uint256 public totalSupply					= 20000000000; 
	string 	public constant tokenName 			= "HOLD";  
	uint8 	public constant decimalUnits 		= 18;  
	string 	public tokenSymbol					= "HLD"; 

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
	mapping (address => uint256) public freezeOf;
    mapping (address => mapping (address => uint256)) public allowance;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(
		  address indexed _from,
		  address indexed _to,
		  uint256 _value
	);
    
    /* This notifies clients about the amount burn */
    event Burn(
		  address indexed _from,
		  uint256 _value
	);    
	
	/* This notifies clients about the amount frozen */
    event Freeze(
		  address indexed _from,
		  uint256 _value
	);   	
	/* This notifies clients about the amount unfrozen */
    event Unfreeze(
		  address indexed _from,
		  uint256 _value
	);  

	// can accept ether
    function () public payable {  
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) public{
        if (_to == 0x0) revert();                               		// Prevent transfer to 0x0 address. Use burn() instead
		if (_value <= 0) revert(); 
		
        if (balanceOf[msg.sender] < _value) revert();           		// Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) revert(); 		// Check for overflows
        
        balanceOf[msg.sender]   = sub(balanceOf[msg.sender], _value);   // Subtract from the sender
        balanceOf[_to]          = add(balanceOf[_to], _value);         	// Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   			// Notify anyone listening that this transfer took place
        emit Transfer(msg.sender, _to, _value);
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
		if (_value <= 0) revert(); 
        allowance[msg.sender][_spender] = _value;
        return true;
    }
       

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (_to == 0x0) revert();                                						// Prevent transfer to 0x0 address. Use burn() instead
		if (_value <= 0) revert(); 
        if (balanceOf[_from] < _value) revert();                 						// Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) revert();  						// Check for overflows
        if (_value > allowance[_from][msg.sender]) revert();     						// Check allowance
        balanceOf[_from] = sub(balanceOf[_from], _value);                           	// Subtract from the sender
        balanceOf[_to] = add(balanceOf[_to], _value);                             		// Add the same to the recipient
        allowance[_from][msg.sender] = sub(allowance[_from][msg.sender], _value);
        Transfer(_from, _to, _value);
        return true;
    }

    function burn(uint256 _value) public returns (bool success) {
        if (balanceOf[msg.sender] < _value) revert();            						// Check if the sender has enough
		if (_value <= 0) revert(); 
        balanceOf[msg.sender] = sub(balanceOf[msg.sender], _value);                     // Subtract from the sender
        totalSupply = sub(totalSupply,_value);                                			// Updates totalSupply
        Burn(msg.sender, _value);
        return true;
    }
	
	function freeze(uint256 _value) public returns (bool success) {
        if (balanceOf[msg.sender] < _value) revert();            						// Check if the sender has enough
		if (_value <= 0) revert(); 
        balanceOf[msg.sender] = sub(balanceOf[msg.sender], _value);                     // Subtract from the sender
        freezeOf[msg.sender] = add(freezeOf[msg.sender], _value);                       // Updates totalSupply
        Freeze(msg.sender, _value);
        return true;
    }
	
	function unfreeze(uint256 _value) public returns (bool success) {
        if (freezeOf[msg.sender] < _value) revert();            						// Check if the sender has enough
		if (_value <= 0) revert(); 
        freezeOf[msg.sender] = sub(freezeOf[msg.sender], _value);                      	// Subtract from the sender
		balanceOf[msg.sender] = add(balanceOf[msg.sender], _value);
        Unfreeze(msg.sender, _value);
        return true;
    }
	
	// transfer balance to nodes
    function WithdrawEth() restricted public {
        require(address(this).balance > 0); 
		uint256 amount = address(this).balance;
        
        msg.sender.transfer(amount);
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