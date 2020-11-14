pragma solidity ^0.5.8;

import "./SafeMath.sol";
import "./BaseToken.sol";

contract EggToken is BaseToken
{
    using SafeMath for uint256;

    // MARK: strings for error message.
    string constant public ERROR_NOT_MANDATED = 'Reason: Not mandated.';

    // MARK: for token information.
    string constant public name    = 'Egg';
    string constant public symbol  = 'EGG';
    string constant public version = '1.0.0';

    mapping (address => bool) public mandates;

    // MARK: events
    event TransferByMandate(address indexed from, address indexed to, uint256 value);
    event ReferralDrop(address indexed from, address indexed to1, uint256 value1, address indexed to2, uint256 value2);
    event UpdatedMandate(address indexed from, bool mandate);

    constructor() public
    {
        totalSupply = 3000000000 * E18;
        balances[msg.sender] = totalSupply;
    }

    // MARK: functions for view data
    function transferByMandate(address _from, address _to, uint256 _value, address _sale, uint256 _fee) external onlyWhenNotStopped onlyMaster returns (bool)
    {
        require(_from != address(0), ERROR_ADDRESS_NOT_VALID);
        require(_sale != address(0), ERROR_ADDRESS_NOT_VALID);
        require(_value > 0, ERROR_VALUE_NOT_VALID);
        require(balances[_from] >= _value + _fee, ERROR_BALANCE_NOT_ENOUGH);
        require(mandates[_from], ERROR_NOT_MANDATED);
        require(!isLocked(_from, _value), ERROR_LOCKED);

        balances[_from] = balances[_from].sub(_value + _fee);
        balances[_to]  = balances[_to].add(_value);

        if(_fee > 0)
        {
            balances[_sale] = balances[_sale].add(_fee);
        }

        emit TransferByMandate(_from, _to, _value);
        return true;
    }

    function referralDrop2(address _to, uint256 _value, address _sale, uint256 _fee) external onlyWhenNotStopped returns (bool)
    {
        require(_to != address(0), ERROR_ADDRESS_NOT_VALID);
        require(_sale != address(0), ERROR_ADDRESS_NOT_VALID);
        require(_value > 0, ERROR_VALUE_NOT_VALID);
        require(balances[msg.sender] >= _value + _fee, ERROR_BALANCE_NOT_ENOUGH);
        require(!isLocked(msg.sender, _value + _fee), ERROR_LOCKED);

        balances[msg.sender] = balances[msg.sender].sub(_value + _fee);
        balances[_to] = balances[_to].add(_value);

        if(_fee > 0)
        {
            balances[_sale] = balances[_sale].add(_fee);
        }

        emit ReferralDrop(msg.sender, _to, _value, address(0), 0);
        return true;
    }

    function referralDrop3(address _to1, uint256 _value1, address _to2, uint256 _value2, address _sale, uint256 _fee) external onlyWhenNotStopped returns (bool)
    {
        require(_to1 != address(0), ERROR_ADDRESS_NOT_VALID);
        require(_to2 != address(0), ERROR_ADDRESS_NOT_VALID);
        require(_sale != address(0), ERROR_ADDRESS_NOT_VALID);
        require(_value1 > 0, ERROR_VALUE_NOT_VALID);
        require(_value2 > 0, ERROR_VALUE_NOT_VALID);
        require(balances[msg.sender] >= _value1 + _value2 + _fee);
        require(!isLocked(msg.sender, _value1 + _value2 + _fee), ERROR_LOCKED);

        balances[msg.sender] = balances[msg.sender].sub(_value1 + _value2 + _fee);
        balances[_to1] = balances[_to1].add(_value1);
        balances[_to2] = balances[_to2].add(_value2);

        if(_fee > 0)
        {
            balances[_sale] = balances[_sale].add(_fee);
        }

        emit ReferralDrop(msg.sender, _to1, _value1, _to2, _value2);
        return true;
    }

    // MARK: utils for transfer authentication
    function updateMandate(bool _value) external onlyWhenNotStopped returns (bool)
    {
        mandates[msg.sender] = _value;
        emit UpdatedMandate(msg.sender, _value);
        return true;
    }
}