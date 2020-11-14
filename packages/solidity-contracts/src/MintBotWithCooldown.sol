/**
 * Source Code first verified at https://etherscan.io on Friday, May 10, 2019
 (UTC) */

pragma solidity ^0.5.0;

interface IBlockCitiesCreator {
    function createBuilding(
        uint256 _exteriorColorway,
        uint256 _backgroundColorway,
        uint256 _city,
        uint256 _building,
        uint256 _base,
        uint256 _body,
        uint256 _roof,
        uint256 _special,
        address _architect
    ) external returns (uint256 _tokenId);
}

contract MintBotWithCooldown {
    IBlockCitiesCreator _blockCitiesContract;
    uint _lastRan;
    address _owner;
    uint constant _cooldownInHours = 5;
    
    
    constructor (address nftContractAddress) public
    {
        _blockCitiesContract = IBlockCitiesCreator(nftContractAddress);
        _lastRan = now - _cooldownInHours * 1 hours;
        _owner = msg.sender;
    }
    
    function createBuilding(
        uint256 _exteriorColorway,
        uint256 _backgroundColorway,
        uint256 _city,
        uint256 _building,
        uint256 _base,
        uint256 _body,
        uint256 _roof,
        uint256 _special,
        address _architect
    )
    
    public isOwner cooldownSatisfied returns (uint256 _tokenId)
    {
        require(_special > 1000009);
        _lastRan = now;
        return _blockCitiesContract.createBuilding(
            _exteriorColorway,
            _backgroundColorway,
            _city,
            _building,
            _base,
            _body,
            _roof,
            _special,
            _architect
        );
    }
    
    function cooledDown() public view returns (bool)
    {
        return now >= _lastRan + _cooldownInHours * 1 hours;
    }
    
    modifier cooldownSatisfied() {
        require(cooledDown());
        _;
    }
    
    modifier isOwner() {
        require(msg.sender == _owner);
        _;
    }
}