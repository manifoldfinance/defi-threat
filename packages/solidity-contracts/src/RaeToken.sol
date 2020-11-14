pragma solidity 0.5.7;

import "./ERC20Detailed.sol";
import "./ERC20Burnable.sol";
import "./ERC20Capped.sol";
import "./ERC20Pausable.sol";


/**
@dev RaeToken Contract
requirements:
 - address that deployed RaeToken can pause contract and release pauseRole in future
 - address that deployed RaeToken has mintRole and can release mintRole in future
 - RaeMintContract has mintRole after deployment
 - totalSupply is capped at 34 million RAE = 34000000 RAE, or 34000000e18 ROK (1 RAE = 1e18 ROK)
 - every 1700 _mintPeriods _mintAmount is halved
 - _mintAmount starts at 10000 RAE = 10000e18 ROK
 - halveEvery can never be changed
 */
contract RaeToken is ERC20Detailed, ERC20Capped, ERC20Burnable, ERC20Pausable {
    uint256 private _mintAmount = 216000e18;
    uint256 private _mintPeriods = 0;
    uint256 private _totalInPeriod = 0;
    uint256 constant private _halveEvery = 1700; // halve mint amount every 1700 mint periods
    mapping (address => uint256) private _balances;

    constructor(string memory name, string memory symbol, uint8 decimals, uint256 cap)
        ERC20Burnable()
        ERC20Mintable()
        ERC20Capped(cap)
        ERC20Detailed(name, symbol, decimals)
        ERC20Pausable()
        ERC20()
    public 
    {
        _mint(msg.sender, 84000e18);
    }

    /**
    * @dev perform a minting period
    * requirements:
    * - addresses.length == values.length != 0
    * - only addresses with minter role should be able to call this function
    * - totalSent == _mintAmount
    * - every time this function returns successfully (true) _mintPeriods is incremented by 1
    * - every 1700 _mintPeriods _mintAmount is halved. e.g. when _mintPeriods = 1700 then _mintAmount = 5000e18
    * - addresses[i] is minted values[i], accepatable to have duplicate addresses
    @param addresses array of addresses where amount minted to addresses[i] is values[i]
    @param values array of token amounts that add up to _mintAmount
     */
    function mintBulk(address[] calldata addresses, uint256[] calldata values) external whenNotPaused onlyMinter returns (bool) {
        
        require(addresses.length > 0);
        require(addresses.length == values.length);

        for(uint256 i = 0; i < addresses.length; ++i) {
            _totalInPeriod = _totalInPeriod.add(values[i]);
            _mint(addresses[i], values[i]);
        }
        require(_totalInPeriod <= _mintAmount);
        if( _totalInPeriod == _mintAmount) _updateMintParams();

        return true;
    }


    function period() external view returns (uint256){
        return _mintPeriods;
    }

    function mintAmount() external view returns (uint256){
        return _mintAmount;
    }

    function _updateMintParams() internal returns (bool) {
        // first period is for 216,000 RAE, after this will go to 10000 RAE until decay
        if(_mintPeriods == 0) _mintAmount = 10000e18;

        // increment period
        _mintPeriods = _mintPeriods.add(1);

        // decay if _mintPeriods is 1700, 3400, 5100, etc. Target for 1 mint per day
        if(_mintPeriods % _halveEvery == 0) _mintAmount = _mintAmount.div(2);

        // reset the _totalInPeriod to 0
        _totalInPeriod = 0;

        return true;
    }

    function remainingInPeriod() external view returns (uint256) {
        return _mintAmount - _totalInPeriod;
    }

    function totalInPeriod() external view returns (uint256) {
        return _totalInPeriod;
    }

    /**
    @dev do not allow mint during pause
     */
    function mint(address to, uint256 value) public whenNotPaused onlyMinter returns (bool) {
        //super.mint(to, value);
        revert();
    }

    /**
    @dev do not allow burn during pause
     */
    function burn(uint256 value) public whenNotPaused {
        super.burn(value);
    }

    function burnFrom(address from, uint256 value) public whenNotPaused {
        super.burnFrom(from, value);
    }

}