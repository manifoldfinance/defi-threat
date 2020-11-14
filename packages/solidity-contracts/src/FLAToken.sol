/**
 * Source Code first verified at https://etherscan.io on Wednesday, May 8, 2019
 (UTC) */

pragma solidity 0.5.7;
// ----------------------------------------------------------------------------
// 'FLT' 'FLAToken' token contract
//
// Symbol            : FLT
// Name              : FLAToken
// Total supply      : 75,000,00.000000000000000000
// Decimals          : 18
//
// The real cryptocurrency :D
//
// (c) FLAToken 2019. The MIT Licence.
// ----------------------------------------------------------------------------

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function mul(uint a, uint b) internal pure returns (uint c) {
        if(a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b);
    }

    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }

    function mod(uint a, uint b) internal pure returns (uint c) {
        require(b != 0);
        c = a % b;
    }
}

contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}

contract Owned {
    address payable public owner;
    address payable public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);

        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract FLAToken is ERC20Interface, Owned {
    using SafeMath for uint;

    string public symbol;
    string public name;
    string public version = 'FLT1.0';
    uint8 public decimals;
    uint public tokenSold;
    uint _totalSupply;
    uint _unitsOneEthCanBuy;
    uint _bonusEachTarget;
    uint _bonusAmount;
    bool _salesOpen;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    struct Topic {
        address sender;
        string argument;
        uint likes;
        uint dislikes;
        bool isValue;
    }
    uint _tokensToSendTopic;

    mapping(bytes32 => Topic) topics;
    bytes32[] topicsList;

    event Upvote(bytes32 topicKey, uint likes);
    event Downvote(bytes32 topicKey, uint dislikes);
    event NewTopic(bytes32 topicKey);

    constructor() public {
        symbol = "FLT";
        name = "FLAToken";
        decimals = 18;
        _totalSupply = 75000000 * 10**uint(decimals);
        _unitsOneEthCanBuy = 3750;
        _tokensToSendTopic = 1 * 10**uint(decimals);
        _bonusEachTarget = 1000000000000000000; //1 ETH
        _bonusAmount = 100 * 10**uint(decimals);
        tokenSold = 0;
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
        _salesOpen = true;
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function availableSupply() public view returns (uint) {
        return balances[owner];
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    function unitsOneEthCanBuy() public view returns (uint) {
        return _calculateUnitsOneEthCanBuy();
    }

    function setUnitsOneEthCanBuy(uint tokens) public onlyOwner {
        _unitsOneEthCanBuy = tokens;
    }

    function _calculateUnitsOneEthCanBuy() private view returns (uint tokens){
        if(tokenSold > 60000000 * 10**uint(decimals)) {
            return 500;
        } else if (tokenSold > 45000000 * 10**uint(decimals)) {
            return 1500;
        } else if (tokenSold > 30000000 * 10**uint(decimals)) {
            return 2500;
        } else if (tokenSold > 15000000 * 10**uint(decimals)) {
            return 3000;
        }

        return _unitsOneEthCanBuy;
    }

    function closeICO() public onlyOwner {
        _salesOpen = false;
        balances[owner] = 0;
    }

    function transfer(address to, uint tokens) public returns (bool success) {
        require(tokens > 0);

        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);

        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        require((tokens == 0) || (allowed[msg.sender][spender] == 0));

        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);

        return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        require(tokens > 0);

        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[from] = balances[from].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);

        return true;
    }

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);

        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }

    function buy() external payable {
        require(msg.value > 0 && _salesOpen);

        uint amount = msg.value.mul(_calculateUnitsOneEthCanBuy());
        if(msg.value >= _bonusEachTarget) {
            amount = amount.add(_bonusAmount.mul(msg.value.div(_bonusEachTarget)));
        }
        require(amount > 0 && balances[owner] >= amount);

        balances[owner] = balances[owner].sub(amount);
        balances[msg.sender] = balances[msg.sender].add(amount);

        tokenSold = tokenSold.add(amount);

        emit Transfer(owner, msg.sender, amount);

        owner.transfer(msg.value);
    }

    function () external payable {
        revert();
    }

    function newTopic(bytes32 topicKey, string memory argument) public returns(bool success) {
        require(!topics[topicKey].isValue);

        balances[msg.sender] = balances[msg.sender].sub(_tokensToSendTopic);
        balances[owner] = balances[owner].add(_tokensToSendTopic);

        emit Transfer(msg.sender, owner, _tokensToSendTopic);

        topics[topicKey].argument = argument;
        topics[topicKey].sender = msg.sender;
        topics[topicKey].likes = 0;
        topics[topicKey].dislikes = 0;
        topics[topicKey].isValue = true;

        topicsList.push(topicKey);

        emit NewTopic(topicKey);

        return true;
    }

    function getTopic(bytes32 topicKey) public view returns (string memory argument, address sender, uint likes, uint dislikes) {
        Topic memory t = topics[topicKey];
        require(t.isValue);

        return(t.argument, t.sender, t.likes, t.dislikes);
    }

     function getTopicsCount() public view returns (uint topicsCount) {
        return topicsList.length;
    }

    function getTopicAtIndex(uint row) public view returns (bytes32 key, string memory arg, address sender, uint likes, uint dislikes) {
        Topic memory t = topics[topicsList[row]];
        require(t.isValue);

        return(topicsList[row], t.argument, t.sender, t.likes, t.dislikes);
    }

    function upvote(bytes32 topicKey, uint tokens) public returns (bool success) {
        require(tokens > 0);

        Topic storage t = topics[topicKey];
        require(t.isValue && t.sender != msg.sender);

        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[t.sender] = balances[t.sender].add(tokens);

        emit Transfer(msg.sender, t.sender, tokens);

        t.likes = t.likes.add(tokens);

        emit Upvote(topicKey, t.likes);

        return true;
    }

    function downvote(bytes32 topicKey, uint tokens) public returns (bool success) {
        require(tokens > 0);

        Topic storage t = topics[topicKey];
        require(t.isValue && t.sender != msg.sender);

        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[t.sender] = balances[t.sender].add(tokens);

        emit Transfer(msg.sender, t.sender, tokens);

        t.dislikes = t.dislikes.add(tokens);

        emit Downvote(topicKey, t.dislikes);

        return true;
    }
}