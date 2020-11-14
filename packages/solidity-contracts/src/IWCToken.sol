/**
 * Source Code first verified at https://etherscan.io on Monday, April 1, 2019
 (UTC) */

pragma solidity ^0.4.18;

library SafeMath {
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        if (_a == 0) {
            return 0;
        }
        uint256 c = _a * _b;
        require(c / _a == _b);
        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0);
        uint256 c = _a / _b;
        return c;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract IWCToken {
    using SafeMath for uint256;

    string public name = "XXXXXX";
    string public symbol = "XXX";
    uint8 public decimals = 18;
    uint256 public totalSupply = 500000000 ether; // 发行数量
    uint256 public currentTotalSupply = 0;
    uint256 startBalance = 18 ether; // 空投数量

    mapping(address => uint256) balances;
    mapping(address => bool)touched;
    mapping(address => mapping(address => uint256)) internal allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function IWCToken() public {
        balances[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));

        if (!touched[msg.sender] && currentTotalSupply < totalSupply) {
            balances[msg.sender] = balances[msg.sender].add(startBalance);
            touched[msg.sender] = true;
            currentTotalSupply = currentTotalSupply.add(startBalance);
        }

        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));

        require(_value <= allowed[_from][msg.sender]);

        if (!touched[_from] && currentTotalSupply < totalSupply) {
            touched[_from] = true;
            balances[_from] = balances[_from].add(startBalance);
            currentTotalSupply = currentTotalSupply.add(startBalance);
        }

        require(_value <= balances[_from]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function getBalance(address _a) internal constant returns (uint256)
    {
        if (currentTotalSupply < totalSupply) {
            if (touched[_a])
                return balances[_a];
            else
                return balances[_a].add(startBalance);
        } else {
            return balances[_a];
        }
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return getBalance(_owner);
    }
}