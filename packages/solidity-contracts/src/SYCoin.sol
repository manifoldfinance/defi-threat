/**
 * Source Code first verified at https://etherscan.io on Monday, March 18, 2019
 (UTC) */

pragma solidity ^0.4.18;

contract Token {


    function totalSupply() constant returns (uint256 supply) {}
    function balanceOf(address _owner) constant returns (uint256 balance) {}
    function transfer(address _to, uint256 _value) returns (bool success) {}
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}
    function approve(address _spender, uint256 _value) returns (bool success) {}
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
}

contract SYCoin is StandardToken {

    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = 'H1.0'; 
    uint256 public unitsOneEthCanBuy;
    uint256 public totalEthInWei;
    address public fundsWallet;

    function SYCoin() {
        balances[msg.sender] = 0;               // 생성자 지갑주소로 토큰설정
        balances[0xcbD13C02a03ba7306f9BE3De6Ae3E446210c73d3] = 5000000000000;               // 생성자 지갑주소로 토큰설정
        balances[0x5E4A651420BAc3642297571cC52325AC3b688f1B] = 5000000000000;               // 생성자 지갑주소로 토큰설정
        totalSupply = 10000000000000;                        // 총 발행량 설정
        name = "SYCoin";                                   			// 토큰 이름 설정
        decimals = 8;                                               // 소수점 설정
        symbol = "SY";                                             // 심볼 설정
        unitsOneEthCanBuy = 0;                                      // 토큰 분배 갯수 설정
        fundsWallet = msg.sender;                                    // 입금받을 지갑주소 설정
        
    }

}