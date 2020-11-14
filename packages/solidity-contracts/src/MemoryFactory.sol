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
contract MemoryFactory {

	address public administrator;
    uint256 public factoryTotal;
    // player info
    mapping(address => Player) public players;
    // minigame info
    mapping(address => bool)   public miniGames; 
   
    struct Player {
        uint256 level;
        uint256 updateTime;
        uint256 levelUp;
        mapping(uint256 => uint256) programs;
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
    function setFactoryToal(uint256 _value) public onlyContractsMiniGame
    {
        factoryTotal = _value;
    }
    function updateFactory(address _addr, uint256 _levelUp, uint256 _time) public onlyContractsMiniGame
    {
        require(players[_addr].updateTime <= now);

        Player storage p = players[_addr];
        p.updateTime     = _time;
        p.levelUp        = _levelUp;
    }
    function setFactoryLevel(address _addr, uint256 _value) public 
    {
        require(msg.sender == administrator || miniGames[msg.sender] == true);
        Player storage p = players[_addr];
        p.level = _value;
    }
    function updateLevel(address _addr) public
    {
        Player storage p = players[_addr];

        if (p.updateTime <= now && p.level < p.levelUp) p.level = p.levelUp;
    }
    //--------------------------------------------------------------------------
    // PROGRAM
    //--------------------------------------------------------------------------
    function addProgram(address _addr, uint256 _idx, uint256 _program) public onlyContractsMiniGame
    {
        Player storage p = players[_addr];
        p.programs[uint256(_idx)] += _program;
    }
    function subProgram(address _addr, uint256 _idx, uint256 _program) public onlyContractsMiniGame
    {
        Player storage p = players[_addr];
     
        require(p.programs[uint256(_idx)] >= _program);

        p.programs[uint256(_idx)] -= _program;
    }
    //--------------------------------------------------------------------------
    // CALL DATA
    //--------------------------------------------------------------------------
    function getData(address _addr) public view returns(uint256 _level,uint256 _updateTime, uint256[] _programs) 
    {
        Player memory p = players[_addr];
        _level      = getLevel(_addr);
        _updateTime = p.updateTime;
        _programs   = getPrograms(_addr);
    }
    function getLevel(address _addr) public view returns(uint256 _level)
    {
        Player memory p = players[_addr];
        _level = p.level;
        if (p.updateTime <= now && _level < p.levelUp) _level = p.levelUp;
    }
    function getPrograms(address _addr) public view returns(uint256[])
    {
        Player storage p = players[_addr];
        uint256[] memory _programs = new uint256[](factoryTotal);
        
        for(uint256 idx = 0; idx < factoryTotal; idx++) {
            _programs[idx] = p.programs[idx];
        }
        return _programs;
    }
}