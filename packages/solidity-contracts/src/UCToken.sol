/**
 * Source Code first verified at https://etherscan.io on Thursday, March 14, 2019
 (UTC) */

pragma solidity ^0.4.24;

/**
 * Utility library of inline functions on addresses
 */
library AddressUtilsLib {

    /**
    * Returns whether there is code in the target address
    * @dev This function will return false if invoked during the constructor of a contract,
    *  as the code is not actually created until after the constructor finishes.
    * @param _addr address address to check
    * @return bool whether there is code in the target address
    */
    function isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }

        return size > 0;
    }
    
}

pragma solidity ^0.4.24;
contract ERC20Basic {
    /**
    * @dev 传输事件
    */
    event Transfer(address indexed _from,address indexed _to,uint256 value);

    //发送总量  
    uint256 public  totalSupply;

    /**
    *@dev 获取名称
     */
    function name() public view returns (string);

    /**
    *@dev 获取代币符号
     */
    function symbol() public view returns (string);

    /**
    *@dev 支持几位小数
     */
    function decimals() public view returns (uint8);

    /**
    *@dev 获取发行量
     */
    function totalSupply() public view returns (uint256){
        return totalSupply;
    }

    /**
    * @dev 获取余额
    */
    function balanceOf(address _owner) public view returns (uint256);

    /**
    * @dev 转移代币
    * @param _to 转移地址
    * @param _value 数量
    */
    function transfer(address _to, uint256 _value) public returns (bool);
}

pragma solidity ^0.4.24;

contract ERC20 is ERC20Basic {
    /**
    * @dev 授予事件
    */
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

     /**
    * @dev 查看_owner地址还可以调用_spender地址多少代币
    * @param _owner 当前
    * @param _spender 地址
    * @return uint256 可调用的代币数
    */
    function allowance(address _owner, address _spender) public view returns (uint256);

    /**
    * @dev approve批准之后，当前帐号从_from账户转移_value代币
    * @param _from 账户转移
    * @param _to 转移地址
    * @param _value 数量
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

    /**
    * @dev 授权地批准_spender账户从自己的账户转移_value个代币
    * @param _spender 授权地址
    * @param _value 授权数量
    */
    function approve(address _spender, uint256 _value) public returns (bool);
}

pragma solidity ^0.4.24;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor() public {
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
    * @param _newOwner The address to transfer ownership to.
    */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        emit    OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

pragma solidity ^0.4.24;


/**
 * Math operations with safety checks
 */
library SafeMathLib {

    /**
    * @dev uint256乘法
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    /**
    * @dev 除法
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(0==b);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev 减法运算
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev 加法运算
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    /**
    * @dev 64bit最大数
    */
    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    /**
    * @dev 64bit最小数
    */
    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    /**
    * @dev uint256最大数
    */
    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
    * @dev uint256最小数
    */
    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

pragma solidity ^0.4.24;

/**
 * @title Basic token
 */
contract BasicToken is ERC20Basic {
    //SafeMathLib接口
    using SafeMathLib for uint256;
    using AddressUtilsLib for address;
    
    //余额地址
    mapping(address => uint256) public balances;

    /**
    * @dev 指定地址传输
    * @param _from 传送地址
    * @param _to 传送地址
    * @param _value 传送数量
    */
    function _transfer(address _from,address _to, uint256 _value) public returns (bool){
        require(!_from.isContract());
        require(!_to.isContract());
        require(0 < _value);
        require(balances[_from] >= _value);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
    * @dev 指定地址传输
    * @param _to 传送地址
    * @param _value 传送数量
    */
    function transfer(address _to, uint256 _value) public returns (bool){
        return   _transfer(msg.sender,_to,_value);
    }

    

    /**
    * @dev 查询地址余额
    * @param _owner 查询地址 
    * @return uint256 返回余额
    */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

}

pragma solidity ^0.4.24;

contract UCBasic is ERC20,BasicToken{
    //
    mapping (address => mapping (address => uint256)) allowed;


    /**
    * @dev approve批准之后，调用transferFrom函数来转移token
    * @param _from 当前用户token
    * @param _to 转移地址
    * @param _value 数量
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool){
        //检测传输值是否为空
        require(0 < _value);
        //检测地址是否有效
        require(address(0) != _from && address(0) != _to);
        //检测是否有余额可以支付
        require(allowed[_from][msg.sender] >= _value);
        //检测账户余额是否够用
        require(balances[_from] >= _value);
        //检测地址是否有效
        require(!_from.isContract());
        //检测地址是否有效
        require(!_to.isContract());

        //余额
        uint256 _allowance = allowed[_from][msg.sender];

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
    * @dev 批准另一个人address来交易指定的代币
    * @dev 0 address 表示没有授权的地址
    * @dev 给定的时间内，一个token只能有一个批准的地址
    * @dev 只有token的持有者或者授权的操作人才可以调用
    * @param _spender 指定的地址
    * @param _value uint256 可用余额
    */
    function approve(address _spender, uint256 _value) public returns (bool){
        require(address(0) != _spender);
        require(!_spender.isContract());
        require(msg.sender != _spender);
        require(0 != _value);

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

   /**
    * @dev 查看_owner地址还可以调用_spender地址多少代币
    * @param _owner 当前
    * @param _spender 地址
    * @return uint256 可调用的代币数
    */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        //检测地址是否有效
        require(!_owner.isContract());
        //检测地址是否有效
        require(!_spender.isContract());

        return allowed[_owner][_spender];
    }
}

pragma solidity ^0.4.24;

contract UCToken is UCBasic,Ownable{
    using SafeMathLib for uint256;
    //名称
    string constant public tokenName = "STOCK";
    //标识
    string constant public tokenSymbol = "STO";
    //发行量30亿
    uint256 constant public totalTokens = 30*10000*10000;
    //小数位
    uint8 constant public  totalDecimals = 18;   
    //版本号
    string constant private version = "20180908";
    //接收以太坊地址
    address private wallet;

    constructor() public {
        totalSupply = totalTokens*10**uint256(totalDecimals);
        balances[msg.sender] = totalSupply;
        wallet = msg.sender;
    }

    /**
    *@dev 获取名称
     */
    function name() public view returns (string){
        return tokenName;
    }

    /**
    *@dev 获取代币符号
     */
    function symbol() public view returns (string){
        return tokenSymbol;
    }

    /**
    *@dev 支持几位小数
     */
    function decimals() public view returns (uint8){
        return totalDecimals;
    }
}