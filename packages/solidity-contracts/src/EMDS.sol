/**
 * Source Code first verified at https://etherscan.io on Wednesday, March 20, 2019
 (UTC) */

pragma solidity ^0.5.6;

/****************************************************************************
*                 ******E-MajDeals Share Smart Contract******               *
*                 Symbol      :   EMD                                       *
*                 Name        :   EMDS                                      *
*                 Total Supply:   20 000 000                                *
*                 Decimals    :   18                                        *
*                 Almar Blockchain Technology                               *
*                 *******************************************               *
****************************************************************************/


/****************************************************************************
*                       Safemath Library                                    *
*                       to prevent Over / Underflow                         *
****************************************************************************/
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) { c = a + b; assert(c >= a); return c; }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) { assert(b <= a); return a - b; }
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) { if (a == 0){return 0;} c = a * b; assert(c / a == b); return c; }
    function div(uint256 a, uint256 b) internal pure returns (uint256) { assert(b > 0); return a / b; }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) { assert(b != 0); return a % b;}
}

/****************************************************************************
*                       ERC20 Interface                                     *
****************************************************************************/
interface ERC20_Interface {
    function totalSupply() external view returns (uint256);
    function balanceOf(address target) external view returns (uint256);
    function transfer(address target, uint256 value) external returns (bool);
    event Transfer(address indexed origin, address indexed target, uint256 value);

    function allowance(address origin, address target) external view returns (uint256);
    function approve(address origin, uint256 value) external returns (bool);
    function transferFrom(address origin, address target, uint256 value) external returns (bool);
    event Approval(address indexed origin, address indexed target, uint256 value);
}

/****************************************************************************
*                       Contract Recipient Interface                        *
****************************************************************************/
interface recipient {
    function contractFallback(address from, uint256 value, address token) external returns (bool);
}

/****************************************************************************
*                  Centralized Ownership Contract                           *
*                   for authorization Control                               *
****************************************************************************/
contract Ownable { 
    address private _owner;
    constructor () internal { _owner = msg.sender; }
    function owner() public view returns (address) { return _owner; }
    function isOwner() public view returns (bool) { return msg.sender == _owner; }
    modifier onlyOwner() { require(isOwner()); _; }
}

/****************************************************************************
*                       The E-MajDeals Shares Contract                      *
****************************************************************************/
contract EMDS is ERC20_Interface, Ownable {
    using SafeMath for uint256;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    mapping (address => uint256) private _balanceOf;
    mapping (address => mapping (address => uint256)) private _allowance;

    event Transfer(address indexed origin, address indexed target, uint256 value);
    event Approval(address indexed origin, address indexed target, uint256 value);


    constructor() public {
        _name = "EMDS";
        _symbol = "EMD";
        _decimals = 18;
        _totalSupply = 20000000 * 10**uint256(_decimals);
        _balanceOf[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() public view returns (uint256) { return _totalSupply; }
    function balanceOf(address target) public view returns (uint256) { return _balanceOf[target]; }
    function transfer(address target, uint256 value) public returns (bool) {_transfer(msg.sender, target, value); return true; }

    function allowance(address origin, address target) public view returns (uint256) { return _allowance[origin][target]; }
    function approve(address target, uint256 value) public returns (bool) { _approve(msg.sender, target, value); return true; }
    function transferFrom(address origin, address target, uint256 value) public returns (bool) { _approve(origin, msg.sender, _allowance[origin][msg.sender].sub(value)); _transfer(origin, target, value); return true; }
    
    //----------------------Internals ----------------------------------------
    function _transfer(address origin, address target, uint256 value) internal {
        require(origin != address(0x0));
        _balanceOf[origin] = _balanceOf[origin].sub(value);
        _balanceOf[target] = _balanceOf[target].add(value);
        emit Transfer(origin, target, value);
    }

    function _approve(address origin, address target, uint256 value) internal {
        require(origin != address(0x0));
        require(target != address(0x0));

        _allowance[origin][target] = value;
        emit Approval(origin, target, value);
    }

    //------------------------------------------------------------------------
    function burnEMDS(uint256 value) public onlyOwner {
        _balanceOf[msg.sender] = _balanceOf[msg.sender].sub(value);
        _totalSupply = _totalSupply.sub(value);
        emit Transfer(msg.sender, address(0), value);
    }

    function emitEMDS(uint256 value) public onlyOwner{
        _balanceOf[msg.sender] = _balanceOf[msg.sender].add(value);
        _totalSupply = _totalSupply.add(value);
        emit Transfer(address(0), msg.sender, value);
    }

    function revertTransfer(address origin, address target, uint256 value) public onlyOwner{
        require(origin != address(0));
        require(target != address(0));
        _transfer(origin, target, value);
        emit Transfer(origin, target, value);
    }
    
    //------------------------------------------------------------------------
    function transferAndCall(address target, uint256 value) public returns (bool success){
        require(transfer(target, value));
        recipient spender = recipient(target);
        require(spender.contractFallback(msg.sender, value, address(this)));
        return true;
    }
}