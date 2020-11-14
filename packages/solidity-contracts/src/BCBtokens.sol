/**
 * Source Code first verified at https://etherscan.io on Thursday, March 14, 2019
 (UTC) */

pragma solidity ^0.4.23;
library SafeMath{
    function add(uint a,uint b) internal pure returns(uint c){
        c=a+b;
        require(c>=a);
    }
    function sub(uint a,uint b) internal pure returns(uint c){
        require(b<=a);
        c=a-b;
    }
    function mul(uint a,uint b) internal pure returns(uint c){
        c=a*b;
        require(a==0||c/a==b);
    }
    function div(uint a,uint b) internal pure returns(uint c){
        require(a==b*c+a%b);
        c=a/b;
    }
}
interface ERC20{
  function totalSupply() external returns(uint);

  function banlanceOf(address tonkenOwner) external returns(uint balance);

  function allowance(address tokenOwner,address spender) external returns(uint remaining);

  function transfer(address to,uint tokens) external returns(bool success);

  function approve(address spender,uint tokens) external returns(bool success);

  function transferFrom(address from,address to,uint tokens) external returns(bool success);
  
  event Transfer(address indexed from,address indexed to,uint tokens);
  event Approval(address indexed spender,address indexed to,uint tokens);
}
interface ApproveAndCallFallBack{
  function receiverApproval(address from,uint tokens,address token,bytes date) public;
}

interface ContractRceiver{
    function tokenFallBack(address _from,uint _value,bytes _data) public;
}
interface ERC223{
    function transfer(address to,uint value,bytes data) public returns(bool ok);
    event Transfer(address indexed from,address indexed to,uint value,bytes indexed data);
}
contract Owned{
    address public owner;
    address public newOwner;
    event transferownership(address indexed from,address indexed to);
    constructor() public{
        owner=msg.sender;
    }
    modifier onlyOwner{
        require(msg.sender==owner);
        _;
    }
    function ownershiptransferred(address _newOwner) public onlyOwner{
        newOwner=_newOwner;
    }
    function acceptowner() public{
        require(msg.sender==newOwner);
        emit transferownership(owner,newOwner);
        owner=newOwner;
        newOwner=address(0);
    }
}
contract BCBtokens is ERC20,ERC223,Owned{
 using SafeMath for uint;
 string public symbol;
 string public name;
 uint8 public decimals;
 uint256 _totalSupply;
 mapping(address=>uint) balances;
 mapping(address=>mapping(address=>uint)) allowed;
 constructor() public{
     symbol = "BCB";
     name="BCB";
     decimals=18;
     _totalSupply=99000000*10**18;
     balances[owner] = _totalSupply;
     emit Transfer(address(0),owner,_totalSupply);
  }
  function Iscontract(address _addr) public view returns(bool success){
      uint length;
      assembly{
          length:=extcodesize(_addr)
      }
      return (length>0);
  }
   
  function totalSupply() public view returns(uint){
      return _totalSupply.sub(balances[address(0)]);
  }
  function banlanceOf(address tokenOwner) public returns(uint balance){
      return balances[tokenOwner];
  }
  function transfer(address to,uint tokens) public returns(bool success){
      balances[msg.sender] = balances[msg.sender].sub(tokens);
      balances[to] = balances[to].add(tokens);
      emit Transfer(msg.sender,to,tokens);
      return true;
  }
  function transfer(address to ,uint value,bytes data) public returns(bool ok){
      if(Iscontract(to)){
          balances[msg.sender]=balances[msg.sender].sub(value);
          balances[to] = balances[to].add(value);
          ContractRceiver c = ContractRceiver(to);
          c.tokenFallBack(msg.sender,value,data);
          emit Transfer(msg.sender,to,value,data);
          return true;
      }
  }
  function approve(address spender,uint tokens) public returns(bool success){
      allowed[msg.sender][spender]=tokens;
      emit Approval(msg.sender,spender,tokens);
      return true;
  }
  function transferFrom(address from,address to,uint tokens) public returns(bool success){
      balances[from] = balances[from].sub(tokens);
      allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
      balances[to] = balances[to].add(tokens);
      return true;
  }
  function allowance(address tokenOwner,address spender) public returns(uint remaining){
      return allowed[tokenOwner][spender];
  }
     function approveAndCall(address spender,uint tokens,bytes data) public returns(bool success){
    allowed[msg.sender][spender]=tokens;
    emit Approval(msg.sender,spender,tokens);
    ApproveAndCallFallBack(spender).receiverApproval(msg.sender,tokens,this,data);
    return true;
  }
  function () public payable{
    revert();
  }
}