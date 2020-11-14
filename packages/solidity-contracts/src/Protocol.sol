/**
 * Source Code first verified at https://etherscan.io on Thursday, April 25, 2019
 (UTC) */

pragma solidity ^0.5;

contract ERC20xVariables {
    address public creator;
    address public lib;

    uint256 constant public MAX_UINT256 = 2**256 - 1;
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowed;

    uint8 public constant decimals = 18;
    string public name;
    string public symbol;
    uint public totalSupply;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    event Created(address creator, uint supply);

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

contract ERC20x is ERC20xVariables {

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transferBalance(msg.sender, _to, _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(allowance >= _value);
        _transferBalance(_from, _to, _value);
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferToContract(address _to, uint256 _value, bytes memory data) public returns (bool) {
        _transferBalance(msg.sender, _to, _value);
        bytes4 sig = bytes4(keccak256("receiveTokens(address,uint256,bytes)"));
        (bool result,) = _to.call(abi.encodePacked(sig, msg.sender, _value, data));
        require(result);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function _transferBalance(address _from, address _to, uint _value) internal {
        require(balances[_from] >= _value);
        balances[_from] -= _value;
        balances[_to] += _value;
    }
}

contract BidderInterface {
    function receiveETH(address series, uint256 amount) public;
    function receiveUSD(address series, uint256 amount) public;
}

contract VariableSupplyToken is ERC20x {
    function grant(address to, uint256 amount) public returns (bool) {
        require(msg.sender == creator);
        require(balances[to] + amount >= amount);
        balances[to] += amount;
        totalSupply += amount;
        return true;
    }

    function burn(address from, uint amount) public returns (bool) {
        require(msg.sender == creator);
        require(balances[from] >= amount);
        balances[from] -= amount;
        totalSupply -= amount;
        return true;
    }
}

contract OptionToken is VariableSupplyToken {
    constructor(string memory _name, string memory _symbol) public {
        creator = msg.sender;
        name = _name;
        symbol = _symbol;
    }
}

contract Protocol {
    
    address public lib;
    ERC20x public usdERC20;
    ERC20x public protocolToken;

    // We use "flavor" because type is a reserved word in many programming languages
    enum Flavor {
        Call,
        Put
    }

    struct OptionSeries {
        uint expiration;
        Flavor flavor;
        uint strike;
    }

    uint public constant DURATION = 12 hours;
    uint public constant HALF_DURATION = DURATION / 2;

    mapping(address => uint) public openInterest;
    mapping(address => uint) public earlyExercised;
    mapping(address => uint) public totalInterest;
    mapping(address => mapping(address => uint)) public writers;
    mapping(address => OptionSeries) public seriesInfo;
    mapping(address => uint) public holdersSettlement;

    mapping(address => uint) public expectValue;
    bool isAuction;

    uint public constant ONE_MILLION = 1000000;

    // maximum token holder rights capped at 3.7% of total supply?
    // Why 3.7%?
    // I could make up some fancy explanation
    // and use the phrase "byzantine fault tolerance" somehow
    // Or I could just say that 3.7% allows for a total of 27 independent actors
    // that are all receiving the maximum benefit, and it solves all the other
    // issues of disincentivizing centralization and "rich get richer" mechanics, so I chose 27 'cause it just has a nice "decentralized" feel to it.
    // 21 would have been fine, as few as ten probably would have been ok 'cause people can just pool anyways
    // up to a thousand or so probably wouldn't have hurt either.
    // In the end it really doesn't matter as long as the game ends up being played fairly.

    // I'm sure someone will take my system and parameterize it differently at some point and bill it as a totally new product.
    uint public constant PREFERENCE_MAX = 0.037 ether;

    constructor(address _token, address _usd) public {
        lib = address(new VariableSupplyToken());
        protocolToken = ERC20x(_token);
        usdERC20 = ERC20x(_usd);
    }

    function() external payable {
        revert();
    }

    event SeriesIssued(address series);

    function issue(string memory name, string memory symbol, uint expiration, Flavor flavor, uint strike) public returns (address) {
        address series = address(new OptionToken(name, symbol));
        seriesInfo[series] = OptionSeries(expiration, flavor, strike);
        emit SeriesIssued(series);
        return series;
    }

    function open(address _series, uint amount) public payable returns (bool) {
        OptionSeries memory series = seriesInfo[_series];
        require(now < series.expiration);

        VariableSupplyToken(_series).grant(msg.sender, amount);

        if (series.flavor == Flavor.Call) {
            require(msg.value == amount);
        } else {
            require(msg.value == 0);
            uint escrow = amount * series.strike;
            require(escrow / amount == series.strike);
            escrow /= 1 ether;
            require(usdERC20.transferFrom(msg.sender, address(this), escrow));
        }
        
        openInterest[_series] += amount;
        totalInterest[_series] += amount;
        writers[_series][msg.sender] += amount;

        return true;
    }

    function close(address _series, uint amount) public returns (bool) {
        OptionSeries memory series = seriesInfo[_series];

        require(now < series.expiration);
        require(openInterest[_series] >= amount);
        VariableSupplyToken(_series).burn(msg.sender, amount);

        require(writers[_series][msg.sender] >= amount);
        writers[_series][msg.sender] -= amount;
        openInterest[_series] -= amount;
        totalInterest[_series] -= amount;
        
        if (series.flavor == Flavor.Call) {
            msg.sender.transfer(amount);
        } else {
            usdERC20.transfer(msg.sender, amount * series.strike / 1 ether);
        }
        return true;
    }
    
    function exercise(address _series, uint amount) public payable {
        OptionSeries memory series = seriesInfo[_series];

        require(now < series.expiration);
        require(openInterest[_series] >= amount);
        VariableSupplyToken(_series).burn(msg.sender, amount);

        uint usd = amount * series.strike;
        require(usd / amount == series.strike);
        usd /= 1 ether;

        openInterest[_series] -= amount;
        earlyExercised[_series] += amount;

        if (series.flavor == Flavor.Call) {
            msg.sender.transfer(amount);
            require(msg.value == 0);
            usdERC20.transferFrom(msg.sender, address(this), usd);
        } else {
            require(msg.value == amount);
            usdERC20.transfer(msg.sender, usd);
        }
    }
    
    function receive() public payable returns (bool) {
        require(expectValue[msg.sender] == msg.value);
        expectValue[msg.sender] = 0;
        return true;
    }

    function bid(address _series, uint amount) public payable returns (bool) {

        require(isAuction == false);
        isAuction = true;

        OptionSeries memory series = seriesInfo[_series];

        uint start = series.expiration;
        uint time = now + _timePreference(msg.sender);

        require(time > start);
        require(time < start + DURATION);

        uint elapsed = time - start;

        amount = _min(amount, openInterest[_series]);

        openInterest[_series] -= amount;

        uint offer;
        uint givGet;
        
        BidderInterface bidder = BidderInterface(msg.sender);

        if (series.flavor == Flavor.Call) {
            require(msg.value == 0);

            offer = (series.strike * DURATION) / elapsed;
            givGet = offer * amount / 1 ether;
            holdersSettlement[_series] += givGet - amount * series.strike / 1 ether;

            bool hasFunds = usdERC20.balanceOf(msg.sender) >= givGet && usdERC20.allowance(msg.sender, address(this)) >= givGet;

            if (hasFunds) {
                msg.sender.transfer(amount);
            } else {
                bidder.receiveETH(_series, amount);
            }

            require(usdERC20.transferFrom(msg.sender, address(this), givGet));
        } else {
            offer = (DURATION * 1 ether * 1 ether) / (series.strike * elapsed);
            givGet = (amount * 1 ether) / offer;

            holdersSettlement[_series] += amount * series.strike / 1 ether - givGet;
            usdERC20.transfer(msg.sender, givGet);

            if (msg.value == 0) {
                require(expectValue[msg.sender] == 0);
                expectValue[msg.sender] = amount;
                
                bidder.receiveUSD(_series, givGet);
                require(expectValue[msg.sender] == 0);
            } else {
                require(msg.value >= amount);
                msg.sender.transfer(msg.value - amount);
            }
        }

        isAuction = false;
        return true;
    }

    function redeem(address _series) public returns (bool) {
        OptionSeries memory series = seriesInfo[_series];

        require(now > series.expiration + DURATION);

        uint unsettledPercent = openInterest[_series] * 1 ether / totalInterest[_series];
        uint exercisedPercent = (totalInterest[_series] - openInterest[_series]) * 1 ether / totalInterest[_series];
        uint owed;

        if (series.flavor == Flavor.Call) {
            owed = writers[_series][msg.sender] * unsettledPercent / 1 ether;
            if (owed > 0) {
                msg.sender.transfer(owed);
            }

            owed = writers[_series][msg.sender] * exercisedPercent / 1 ether;
            owed = owed * series.strike / 1 ether;
            if (owed > 0) {
                usdERC20.transfer(msg.sender, owed);
            }
        } else {
            owed = writers[_series][msg.sender] * unsettledPercent / 1 ether;
            owed = owed * series.strike / 1 ether;
            if (owed > 0) {
                usdERC20.transfer(msg.sender, owed);
            }

            owed = writers[_series][msg.sender] * exercisedPercent / 1 ether;
            if (owed > 0) {
                msg.sender.transfer(owed);
            }
        }

        writers[_series][msg.sender] = 0;
        return true;
    }

    function settle(address _series) public returns (bool) {
        OptionSeries memory series = seriesInfo[_series];
        require(now > series.expiration + DURATION);

        uint bal = ERC20x(_series).balanceOf(msg.sender);
        VariableSupplyToken(_series).burn(msg.sender, bal);

        uint percent = bal * 1 ether / (totalInterest[_series] - earlyExercised[_series]);
        uint owed = holdersSettlement[_series] * percent / 1 ether;
        usdERC20.transfer(msg.sender, owed);
        return true;
    }

    function _timePreference(address from) public view returns (uint) {
        return (_unsLn(_preference(from) * 1000000 + 1 ether) * 171) / 1 ether;
    }

    function _preference(address from) public view returns (uint) {
        return _min(
            protocolToken.balanceOf(from) * 1 ether / protocolToken.totalSupply(),
            PREFERENCE_MAX
        );
    }

    function _min(uint a, uint b) pure public returns (uint) {
        if (a > b)
            return b;
        return a;
    }

    function _max(uint a, uint b) pure public returns (uint) {
        if (a > b)
            return a;
        return b;
    }
    
    function _unsLn(uint x) pure public returns (uint log) {
        log = 0;
        
        // not a true ln function, we can't represent the negatives
        if (x < 1 ether)
            return 0;

        while (x >= 1.5 ether) {
            log += 0.405465 ether;
            x = x * 2 / 3;
        }
        
        x = x - 1 ether;
        uint y = x;
        uint i = 1;

        while (i < 10) {
            log += (y / i);
            i = i + 1;
            y = y * x / 1 ether;
            log -= (y / i);
            i = i + 1;
            y = y * x / 1 ether;
        }
         
        return(log);
    }
}