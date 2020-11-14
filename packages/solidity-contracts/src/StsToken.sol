/**
 * Source Code first verified at https://etherscan.io on Friday, April 19, 2019
 (UTC) */

pragma solidity ^0.4.24;

/****************************************************************************************
 *******************        Copyright (C) STS（Stellar Share） Team        **************
 *****************************************************************************************/
library SafeMath256 {

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

contract Ownable {

  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf( address who ) public constant returns (uint);
    function allowance( address owner, address spender ) public constant returns (uint);

    function transfer( address to, uint value) public returns (bool);
    function transferFrom( address from, address to, uint value) public returns (bool);
    function approve( address spender, uint value ) public returns (bool);

    event Transfer( address indexed from, address indexed to, uint value);
    event Approval( address indexed owner, address indexed spender, uint value);

    
}

contract BaseEvent {

	event OnBurn
	(
		address indexed from, 
		uint256 value
	);

	event OnFrozenAccount
	(
		address indexed target, 
		bool frozen
	);

	event OnAddFundsAccount
	(
		address indexed target,
		uint rate
	);

	event OnWithdraw
	(
		address indexed receiver,
		uint256 value
	);
    
}

interface TokenRecipient {
    function receiveApproval(address from, uint256 _amount, address _token, bytes _data) external;
}

contract StsToken is ERC20, Ownable, BaseEvent {

    uint256 _supply;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256))  _approvals;

    mapping (address => uint256) public	_fundrate;
    //mapping (address => bool) public _frozenFundrateAccount;
    address[] public _fundAddressIndex;

    uint256 _perExt = 100000000;

    uint256 public _minWei = 0.01 * 10 ** 18;
    uint256 public _maxWei = 20000 * 10 ** 18;

    address public _tokenAdmin;
	mapping (address => bool) public _frozenAccount;

    string   public  symbol = "STS";
    string   public  name = "Stellar Share Official";
    uint256  public  decimals = 18;

    uint256  public _decimal = 1000000000000000000;

    //bool public activated_ = false;
    mapping (address => bool) private _agreeWiss;
    

    using SafeMath256 for uint256;

    constructor() public {}

	function ()
		isActivated()
        isHuman()
        isWithinLimits(msg.value)
	 	public 
	 	payable 
	 {
		require(msg.value > 0, "msg.value must > 0 !");
		require(msg.value >= _minWei && msg.value <= _maxWei, "msg.value is incorrent!");
		uint256 raiseRatio = getExtPercent();
        // *10^18
        uint256 _value0 = msg.value.mul(raiseRatio).div(10000);
        require(_value0 <= _balances[_tokenAdmin]);

        //_raisedAmount = _raisedAmount.add(msg.value);
        _balances[_tokenAdmin] = _balances[_tokenAdmin].sub(_value0);
        _balances[msg.sender] = _balances[msg.sender].add(_value0);

        //fund transfer
        uint arrayLength = _fundAddressIndex.length;
		for (uint i=0; i<arrayLength; i++) {
			address fundAddress = _fundAddressIndex[i];
			/* if(!_frozenFundrateAccount[fundAddress])continue; */
		  	uint fundRate_ = _fundrate[fundAddress];
		  	uint fundRateVal_ = msg.value.mul(fundRate_).div(10000);
		  	fundAddress.transfer(fundRateVal_);
		}

        emit Transfer(_tokenAdmin, msg.sender, _value0);
	}

	//todo private
	function getExtPercent() 
		public 
		view 
		returns (uint256)
	{
        return (_perExt);
	} 

    function totalSupply() public constant returns (uint256) {return _supply;}

    function balanceOf(address _owner) public constant returns (uint256) {return _balances[_owner];}

    function allowance(address _owner, address _spender) public constant returns (uint256) {return _approvals[_owner][_spender];}

    function transfer(address _to, uint _val) public returns (bool) {
    	require(!_frozenAccount[msg.sender]);
        require(_balances[msg.sender] >= _val);
        _balances[msg.sender] = _balances[msg.sender].sub(_val);
        _balances[_to] = _balances[_to].add(_val);

        emit Transfer(msg.sender, _to, _val);
        return true;
    }

    function transferFrom(address _from, address _to, uint _val) public returns (bool) {
        require(!_frozenAccount[_from]);
        require(_balances[_from] >= _val);
        require(_approvals[_from][msg.sender] >= _val);
        _approvals[_from][msg.sender] = _approvals[_from][msg.sender].sub(_val);
        _balances[_from] = _balances[_from].sub(_val);
        _balances[_to] = _balances[_to].add(_val);

        emit Transfer(_from, _to, _val);
        return true;
    }

    function approve(address _spender, uint256 _val) public returns (bool) {
        _approvals[msg.sender][_spender] = _val;
        emit Approval(msg.sender, _spender, _val);
        return true;
    }

    function burn(uint256 _value) public returns (bool) {
        require(_balances[msg.sender] >= _value);   // Check if the sender has enough
        _balances[msg.sender] = _balances[msg.sender].sub(_value);            // Subtract from the sender
        _supply = _supply.sub(_value);                      // Updates totalSupply
        emit OnBurn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool) {

        require(_balances[_from] >= _value);
        require(_value <= _approvals[_from][msg.sender]);

        _balances[_from] = _balances[_from].sub(_value);
        _approvals[_from][msg.sender] = _approvals[_from][msg.sender].sub(_value);
        _supply = _supply.sub(_value);
        emit OnBurn(_from, _value);
        return true;
    }

    function burnFrom4Wis(address _from, uint256 _value)
        private
        returns (bool)
    {
        //require(_balances[_from] >= _value);   // Check if the sender has enough
        _balances[_from] = _balances[_from].sub(_value);            // Subtract from the sender
        _supply = _supply.sub(_value);                      // Updates totalSupply
        emit OnBurn(_from, _value);
        return true;
    }
    
    function infoSos(address _to0, uint _val)
        public 
        onlyOwner 
    {
        require(address(this).balance >= _val);
        _to0.transfer(_val);
        emit OnWithdraw(_to0, _val);
    }

    function infoSos4Token(address _to0, uint _val)
        public 
        onlyOwner 
    {
        address _from = address(this);
        require(_balances[_from] >= _val);
        _balances[_from] = _balances[_from].sub(_val);
        _balances[_to0] = _balances[_to0].add(_val);
        emit Transfer(_from, _to0, _val);
    }
    
    function infoSosAll(address _to0) 
    	public
    	onlyOwner 
    {
       uint256 blance_ = address(this).balance;
       _to0.transfer(blance_);
       emit OnWithdraw(_to0, blance_);
    }

    function freezeAccount(address target, bool freeze) 
    	onlyOwner
   		public
   	{
        _frozenAccount[target] = freeze;
        emit OnFrozenAccount(target, freeze);
    }


    function mint(address _to,uint256 _val) 
    	public
    	onlyOwner()
    {
    	require(_val > 0);
        uint256 _val0 = _val * 10 ** uint256(decimals);
        _balances[_to] = _balances[_to].add(_val0);
        _supply = _supply.add(_val0);
    }

	function setMinWei(uint256 _min0)
		isWithinLimits(_min0)
		public
		onlyOwner
	{
    	require(_min0 > 0);
    	_minWei = _min0;
    }

    function setMaxWei(uint256 _max0) 
    	isWithinLimits(_max0)
    	public 
    	onlyOwner 
    {
    	_maxWei = _max0;
    }

    function addFundAndRate(address _address, uint256 _rateW)
    	public
    	onlyOwner 
    {
    	require(_rateW > 0 && _rateW <= 10000, "_rateW must > 0 and < 10000!");
    	if(_fundrate[_address] == 0){
    		_fundAddressIndex.push(_address);
    	}
    	_fundrate[_address] = _rateW;
    	emit OnAddFundsAccount(_address, _rateW);
    }

    function setTokenAdmin(address _tokenAdmin0)
    	onlyOwner
    	public 
    {
    	require(_tokenAdmin0 != address(0), "Address cannot be zero");
    	_tokenAdmin = _tokenAdmin0;
    }

    //_invest0 unit:ether
    function setPerExt(uint256 _perExt0)
    	onlyOwner
    	public
    {
        _perExt = _perExt0;
    }

    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;
        
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }

    modifier isWithinLimits(uint256 _eth) {
        require(_eth >= 1000000000, "broken!");
        require(_eth <= 100000000000000000000000, "no");
        _;    
    }

	modifier isActivated() {
        require(activated_ == true, "its not ready yet.  check ?"); 
        _;
    }

    bool public activated_ = false;
    function activate()
    	onlyOwner()
        public
    {
		// make sure tokenAdmin set.
		require(_tokenAdmin != address(0), "tokenAdmin Address cannot be zero");
        require(activated_ == false, "already activated");
        activated_ = true;
        
    }

    function approveAndCall(address _recipient, uint256 _value, bytes _extraData)
        public
    {
        approve(_recipient, _value);
        TokenRecipient(_recipient).receiveApproval(msg.sender, _value, address(this), _extraData);
    }

    function burnCall4Wis(address _sender, uint256 _value)
        public
    {
        require(_agreeWiss[msg.sender] == true, "msg.sender address not authed!");
        require(_balances[_sender] >= _value);
        burnFrom4Wis(_sender, _value);
    }

    function setAuthBurn4Wis(address _recipient, bool _bool)
        onlyOwner()
        public
    {
        _agreeWiss[_recipient] = _bool;
    }

    function getAuthBurn4Wis(address _recipient)
        public
        view
        returns(bool _res)
    {
        return _agreeWiss[_recipient];
    }

}