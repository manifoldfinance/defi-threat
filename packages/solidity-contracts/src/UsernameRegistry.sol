/**
 * Source Code first verified at https://etherscan.io on Thursday, May 9, 2019
 (UTC) */

/**
 * Source Code first verified at https://etherscan.io on Monday, April 15, 2019
 (UTC) */

pragma solidity ^0.5.8;

contract ERC20Interface {
    function balanceOf(address from) public view returns (uint256);
    function transferFrom(address from, address to, uint tokens) public returns (bool);
    function allowance(address owner, address spender) public view returns (uint256);
    function burn(uint256 amount) public;
}


contract UsernameRegistry {

event Register(address indexed _owner, bytes32 _name, bytes32 _userId);

ERC20Interface public manaToken;
uint256 public price = 100000000000000000000;
mapping (bytes32 => address) nameToAddress;
mapping (bytes32 => address) userIdToAddress;
mapping (address => bytes32) public name;
address public owner;

constructor(ERC20Interface _mana) public {
    manaToken = _mana;
    owner = msg.sender;
}

modifier onlyOwner {
    require(msg.sender == owner);
    _;
}

function registerUsername(address _targetAddress, bytes32 _name, bytes32 _userId) onlyOwner external {
    _requireBalance();
    require(isNameAvailable(_name), "The name was already taken");
    require(isUserIdAvailable(_userId), "The userId already has a name");
    
    manaToken.transferFrom(_targetAddress, address(this), price);
    manaToken.burn(price);

    nameToAddress[_name] = _targetAddress;
    userIdToAddress[_userId] = _targetAddress;
    name[_targetAddress] = _name;

    emit Register(_targetAddress, _userId, _name);
}

function isNameAvailable(bytes32 _name) public view returns (bool) {
    return nameToAddress[_name] == address(0);
}
function isUserIdAvailable(bytes32 _name) public view returns (bool) {
    return userIdToAddress[_name] == address(0);
}

// Lack of security (set only owner)
function setPrice(uint256 _price) onlyOwner public {
    price = _price;
}

function _requireBalance() internal view {
    require(
        manaToken.balanceOf(msg.sender) >= price,
        "Insufficient funds"
    );
    require(
        manaToken.allowance(msg.sender, address(this)) >= price,
        "The contract is not authorized to use MANA on sender behalf"
    );        
}
}