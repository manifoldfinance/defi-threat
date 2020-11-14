/**
 * Source Code first verified at https://etherscan.io on Wednesday, March 27, 2019
 (UTC) */

/**
     *-------------------------------------
     *        --EARTHBI--
     *-------------------------------------
     * --ERC20 COMPATIBLE TOKEN
     * --ETHEREUM BLOCKCHAIN
     * --Name: ERA
     * --Symbol: ERA
     * --Total Supply: 955 MLN (max supply)
     * --Decimal: 18
     * ------------------------------------
     * --Created by CRYPTODIAMOND SRL
     * --Property of Bio Valore World S.p.A - Società Benefit
     */

pragma solidity ^0.4.25;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != 0x0); //s
        owner = newOwner;
    }
}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract BioValue is owned{
    
    using SafeMath for uint; //SafeMath library
    
    uint private nReceivers;
    
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;
    uint256 public burned;
    uint public percentage = 25; //x100 | 25(default) it can be change
    
    mapping (address => bool) public receiversBioValueAddr;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event NewPercentageSetted(address indexed from, uint newPercentage);
    event NewReceiver(address indexed from, address indexed _ricevente); //s
    
    /**
     * Costruttore
     *
     * Inizializzo nel costruttore i dati del token.
     */
    constructor(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol,
        address _ricevente
    ) public {
        require(_ricevente != 0x0); //s
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;  
        name = tokenName;
        symbol = tokenSymbol;
        nReceivers=1; //s
        receiversBioValueAddr[_ricevente] = true;
        burned = 0;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    function setNewReceiverAddr(address _ricevente) onlyOwner public{
        require(_ricevente != 0x0);
        require(existReceiver(_ricevente) != true);
        
        receiversBioValueAddr[_ricevente] = true;
        nReceivers++;
        emit NewReceiver(msg.sender, _ricevente); //notifico su blockchain che è stato settato un nuovo ricevente
    }
    
    function removeReceiverAddr(address _ricevente) onlyOwner public{
        require(_ricevente != 0x0);
        require(existReceiver(_ricevente) != false); //l'indirizzo deve esistere per essere rimosso
        receiversBioValueAddr[_ricevente] = false;
    }
    
    function setNewPercentage(uint _newPercentage) onlyOwner public{ //solo il proprietario
        require(_newPercentage <= 100);
        require(_newPercentage >= 0);
        percentage = _newPercentage;
        emit NewPercentageSetted(msg.sender, _newPercentage); //notifico su blockchain l'avvenuta modifica della percentuale
    }


    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    function _calcPercentage(uint _value, uint _percentage) internal constant returns(uint){
        return (_value.mul(_percentage)).div(100); //s
    }
    
    function _burnPercentageAndTransfer(uint _value, address _sender, address _to) internal {
        uint toBurn = _calcPercentage(_value, percentage);
        approve(_sender, toBurn);
        burnFrom(_sender, toBurn);
        _transfer(_sender, _to, _value.sub(toBurn));
    }
    
    function existReceiver(address _ricevente) public constant returns(bool){
        return receiversBioValueAddr[_ricevente];
    }
    
    function getReceiversNumber() public constant returns(uint){
        return nReceivers;
    }
    
    function transfer(address _to, uint256 _value) public {
        require(_to != address(this)); //s
        if (existReceiver(_to)){
            _burnPercentageAndTransfer(_value, msg.sender, _to);
        }
        else{
            _transfer(msg.sender, _to, _value);
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);  
        balanceOf[msg.sender] -= _value; 
        totalSupply -= _value;
        burned += _value; //contenitore dei token bruciati;
        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                
        require(_value <= allowance[_from][msg.sender]);    
        balanceOf[_from] -= _value;                         
        allowance[_from][msg.sender] -= _value;             
        totalSupply -= _value;
        burned += _value;
        emit Burn(_from, _value);
        return true;
    }
}

contract BioValueToken is owned, BioValue {

    mapping (address => bool) public frozenAccount;

    event FrozenFunds(address target, bool frozen); //notifico il "congelamento"

    constructor(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol,
        address _ricevente
    ) BioValue(initialSupply, tokenName, tokenSymbol, _ricevente) public {}

    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                               
        require (balanceOf[_from] >= _value);               
        require (balanceOf[_to] + _value > balanceOf[_to]); 
        require(!frozenAccount[_from]);                     
        require(!frozenAccount[_to]);                       
        balanceOf[_from] -= _value;                         
        balanceOf[_to] += _value;                           
        emit Transfer(_from, _to, _value);
    }

    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

}