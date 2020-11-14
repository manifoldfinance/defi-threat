/**
 * Source Code first verified at https://etherscan.io on Monday, March 18, 2019
 (UTC) */

pragma solidity ^0.4.25;

/*
* CryptoMiningWar - Build your own empire on Blockchain
* Author: InspiGames
* Website: https://cryptominingwar.github.io/
*/
interface MiniGameInterface {
    function isContractMiniGame() external pure returns( bool _isContractMiniGame );
}
contract MemoryArena {

	address public administrator;
    // player info
    mapping(address => Player) public players;
    // minigame info
    mapping(address => bool)   public miniGames; 
   
    struct Player {
        uint256 virusDef;
        uint256 nextTimeAtk;
        uint256 endTimeUnequalledDef;
        uint256 nextTimeArenaBonus;
        uint256 bonusPoint; // win atk +1; if bonus point equal 3 => send bonus to player and reset bonus point
    }
    modifier isAdministrator()
    {
        require(msg.sender == administrator);
        _;
    }
    modifier onlyContractsMiniGame() 
    {
        require(miniGames[msg.sender] == true);
        _;
    }
    constructor() public {
        administrator = msg.sender;
    }
    function () public payable
    {
        
    }
    function isMemoryArenaContract() public pure returns(bool)
    {
        return true;
    }
    function upgrade(address addr) public isAdministrator
    {
        selfdestruct(addr);
    }
    //--------------------------------------------------------------------------
    // SETTING CONTRACT MINI GAME 
    //--------------------------------------------------------------------------
    function setContractMiniGame(address _addr) public isAdministrator 
    {
        MiniGameInterface MiniGame = MiniGameInterface( _addr );
        if( MiniGame.isContractMiniGame() == false ) { revert(); }

        miniGames[_addr] = true;
    }
    function removeContractMiniGame(address _addr) public isAdministrator
    {
        miniGames[_addr] = false;
    }
    //--------------------------------------------------------------------------
    // FACTORY 
    //--------------------------------------------------------------------------
    function setVirusDef(address _addr, uint256 _value) public onlyContractsMiniGame
    {
        players[_addr].virusDef = _value;
    }
    function setNextTimeAtk(address _addr, uint256 _value) public onlyContractsMiniGame
    {
        players[_addr].nextTimeAtk = _value;
    }
    function setEndTimeUnequalledDef(address _addr, uint256 _value) public onlyContractsMiniGame
    {
        players[_addr].endTimeUnequalledDef = _value;
    }
    function setNextTimeArenaBonus(address _addr, uint256 _value) public onlyContractsMiniGame
    {
        players[_addr].nextTimeArenaBonus = _value;
    }
    function setBonusPoint(address _addr, uint256 _value) public onlyContractsMiniGame
    {
        players[_addr].bonusPoint = _value;
    }
    //--------------------------------------------------------------------------
    // CALL DATA
    //--------------------------------------------------------------------------
    function getData(address _addr) public view returns(uint256 virusDef, uint256 nextTimeAtk, uint256 endTimeUnequalledDef, uint256 nextTimeArenaBonus, uint256 bonusPoint) 
    {
        Player memory p = players[_addr];
        virusDef             = p.virusDef;
        nextTimeAtk          = p.nextTimeAtk;
        endTimeUnequalledDef = p.endTimeUnequalledDef;
        nextTimeArenaBonus   = p.nextTimeArenaBonus;
        bonusPoint           = p.bonusPoint;
    }
}