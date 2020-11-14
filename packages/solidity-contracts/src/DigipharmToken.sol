pragma solidity 0.4.24;

import './MintableToken.sol';
import './SafeMath.sol';

contract DigipharmToken is MintableToken {

    using SafeMath for uint256;
    string public name = "DIGIPHARM TOKEN";
    string public   symbol = "DPH";
    uint public   decimals = 18;
    bool public  TRANSFERS_ALLOWED = false;
    uint256 public MAX_TOTAL_SUPPLY = 100000000 * (10 **18);


    struct LockParams {
        uint256 TIME;
        address ADDRESS;
        uint256 AMOUNT;
    }

    LockParams[] public  locks;

    event Burn(address indexed burner, uint256 value);

    function burnFrom(uint256 _value, address victim) public onlyOwner canMint {
        require(_value <= balances[victim]);

        balances[victim] = balances[victim].sub(_value);
        totalSupply_ = totalSupply().sub(_value);

        emit Burn(victim, _value);
    }

    function burn(uint256 _value) public onlyOwner {
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply_ = totalSupply().sub(_value);

        emit Burn(msg.sender, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(TRANSFERS_ALLOWED || msg.sender == owner);
        require(canBeTransfered(_from, _value));

        return super.transferFrom(_from, _to, _value);
    }


    function lock(address _to, uint256 releaseTime, uint256 lockamount) public onlyOwner returns (bool) {

        LockParams memory lockdata;
        lockdata.TIME = releaseTime;
        lockdata.AMOUNT = lockamount;
        lockdata.ADDRESS = _to;

        locks.push(lockdata);

        return true;
    }

    function canBeTransfered(address addr, uint256 value) public view returns (bool){
        for (uint i=0; i<locks.length; i++) {
            if (locks[i].ADDRESS == addr){
                if ( value > balanceOf(addr).sub(locks[i].AMOUNT) && locks[i].TIME > now){

                    return false;
                }
            }
        }

        return true;
    }

    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        if (totalSupply_.add(_amount) > MAX_TOTAL_SUPPLY){
            return false;
        }

        return super.mint(_to, _amount);
    }


    function transfer(address _to, uint256 _value) public returns (bool){
        require(TRANSFERS_ALLOWED || msg.sender == owner);
        require(canBeTransfered(msg.sender, _value));

        return super.transfer(_to, _value);
    }

    function stopTransfers() public onlyOwner {
        TRANSFERS_ALLOWED = false;
    }

    function resumeTransfers() public onlyOwner {
        TRANSFERS_ALLOWED = true;
    }

}
