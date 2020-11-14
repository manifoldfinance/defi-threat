/**
 * Source Code first verified at https://etherscan.io on Monday, March 25, 2019
 (UTC) */

pragma solidity ^0.5.2;

/**                 ,
                   dM
                   MMr
                  4MMML                  .
                  MMMMM.                xf
  .              "M6MMM               .MM-
   Mh..          +MM5MMM            .MMMM
   .MMM.         .MMMMML.          MMMMMh
    )MMMh.        MM5MMM         MMMMMMM
     3MMMMx.     'MMM3MMf      xnMMMMMM"
     '*MMMMM      MMMMMM.     nMMMMMMP"
       *MMMMMx    "MMM5M\    .MMMMMMM=
        *MMMMMh   "MMMMM"   JMMMMMMP
          MMMMMM   GMMMM.  dMMMMMM            .
           MMMMMM  "MMMM  .MMMMM(        .nnMP"
..          *MMMMx  MMM"  dMMMM"    .nnMMMMM*
 "MMn...     'MMMMr 'MM   MMM"   .nMMMMMMM*"
  "4MMMMnn..   *MMM  MM  MMP"  .dMMMMMMM""
    ^MMMMMMMMx.  *ML "M .M*  .MMMMMM**"
       *PMMMMMMhn. *x > M  .MMMM**""
          ""**MMMMhx/.h/ .=*"
                   .3P"%....
    [cannavest] nP"     "*MMnx
 */

library SafeMath {
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract ERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;
    uint256 private _totalSupply;
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    
    string public constant name = "Cannavest I";
    string public constant symbol = "CVI";
    uint8 public constant decimals = 18;
    
    address owner;
    bool minting;
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    modifier currentlyMinting() {
        require(minting);
        _;
    }
    
    constructor() public {
        owner = msg.sender;
        minting = true;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address account, address spender) public view returns (uint256) {
        return _allowed[account][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }
    
    function mint(address to, uint256 value) public onlyOwner currentlyMinting returns (bool) {
        _mint(to, value);
        return true;
    }
    
    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }
    
    function burnFrom(address from, uint256 value) public {
        _burnFrom(from, value);
    }
    
    function endMinting() onlyOwner public {
        minting = false;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address account, address spender, uint256 value) internal {
        require(spender != address(0));
        require(account != address(0));

        _allowed[account][spender] = value;
        emit Approval(account, spender, value);
    }

    function _burnFrom(address account, uint256 value) internal {
        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
    }
}