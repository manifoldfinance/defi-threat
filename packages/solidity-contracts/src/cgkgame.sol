/**
 * Source Code first verified at https://etherscan.io on Friday, March 22, 2019
 (UTC) */

pragma solidity ^0.4.25;

contract owned {
    address public owner;
    mapping (address => bool) public owners;
    
    constructor() public {
        owner = msg.sender;
        owners[msg.sender] = true;
    }
    
    modifier zeus {
        require(msg.sender == owner);
        _;
    }

    modifier athena {
        require(owners[msg.sender] == true);
        _;
    }

    function addOwner(address _newOwner) zeus public {
        owners[_newOwner] = true;
    }
    
    function removeOwner(address _oldOwner) zeus public {
        owners[_oldOwner] = false;
    }
    
    function transferOwnership(address newOwner) public zeus {
        owner = newOwner;
        owners[newOwner] = true;
        owners[owner] = false;
    }
}


contract cgkgame is owned {
    
    mapping (string => string) cards;

    function saveCard(string _gameid, string _cards) athena public {
        cards[_gameid] = _cards;
    }
    
    function getCard(string _gameid) view public returns (string) {
        return cards[_gameid];
    }
    
}