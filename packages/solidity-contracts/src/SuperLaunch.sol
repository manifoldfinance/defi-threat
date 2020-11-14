/**
 * Source Code first verified at https://etherscan.io on Tuesday, May 7, 2019
 (UTC) */

pragma solidity ^0.5.0;

interface PriceWatcherI
{
    function getUSDcentsPerETH() external view returns (uint256 _USDcentsPerETH);
}


contract PriceWatcherPlaceholder is PriceWatcherI
{
    function getUSDcentsPerETH() external view returns (uint256 _USDcentsPerETH)
    {
        return 12345; // $123.45 per ETH
    }
}

contract SuperLaunch
{
    // Constants
    uint256 public TOKEN_PRICE_USD_CENTS;
    uint256 public totalSupply;
    uint256 public AMOUNT_OF_FREE_TOKENS;
    address payable public root;
    address payable public bank;
    uint256 public REFERRER_COMMISSION_PERCENTAGE;
    uint256 public ROOT_COMMISSION_PERCENTAGE;
    PriceWatcherI public priceWatcher;

    // State variables
    mapping(address => uint256) private balances;
    address[] public participants;
    mapping(address => address payable) public address_to_referrer;
    mapping(address => address[]) public address_to_referrals;

    constructor(address _priceWatcherContract, uint256 _tokenPriceUSDcents, uint256 _totalSupply, uint256 _amountOfFreeTokens, address payable _root, address payable _bank, uint256 _referrerCommissionPercentage, uint256 _rootCommissionPercentage) public
    {
        if (_priceWatcherContract == address(0x0))
        {
            priceWatcher = new PriceWatcherPlaceholder();
        }
        else
        {
            priceWatcher = PriceWatcherI(_priceWatcherContract);
        }

        TOKEN_PRICE_USD_CENTS = _tokenPriceUSDcents;
        totalSupply = _totalSupply;
        AMOUNT_OF_FREE_TOKENS = _amountOfFreeTokens;
        root = _root;
        bank = _bank;
        REFERRER_COMMISSION_PERCENTAGE = _referrerCommissionPercentage;
        ROOT_COMMISSION_PERCENTAGE = _rootCommissionPercentage;

        // The root address is its own referrer
        address_to_referrer[root] = root;

        // Mint all the tokens and assign them to the root address
        balances[root] = totalSupply;
        emit Transfer(address(0x0), root, totalSupply);
    }

    function getTokenPriceETH() public view returns (uint256)
    {
        // Fetch the current ETH exchange rate
        uint256 USDcentsPerETH = priceWatcher.getUSDcentsPerETH();

        // Use the exchange rate to calculate the current token price in ETH
        return (1 ether) * TOKEN_PRICE_USD_CENTS / USDcentsPerETH;
    }

    function buyTokens(address payable _referrer) external payable
    {
        uint256 tokensBought;
        uint256 totalValueOfTokensBought;

        uint256 tokenPriceWei = getTokenPriceETH();

        // If there are still free tokens available
        if (participants.length < AMOUNT_OF_FREE_TOKENS)
        {
            tokensBought = 1;
            totalValueOfTokensBought = 0;

            // Only 1 free token per address
            require(address_to_referrer[msg.sender] == address(0x0));
        }

        // If there are no free tokens available
        else
        {
            tokensBought = msg.value / tokenPriceWei;

            // Limit the bought tokens to the amount of tokens still for sale
            if (tokensBought > balances[root])
            {
                tokensBought = balances[root];
            }

            totalValueOfTokensBought = tokensBought * tokenPriceWei;
        }

        // If 0 tokens are being purchased, cancel this transaction
        require(tokensBought > 0);

        // Return the change
        msg.sender.transfer(msg.value - totalValueOfTokensBought);

        // If we haven't seen this buyer before
        if (address_to_referrer[msg.sender] == address(0x0))
        {
            // Referrer must have owned at least 1 token
            require(address_to_referrer[_referrer] != address(0x0));

            // Add them to the particpants list and the referral tree
            address_to_referrer[msg.sender] = _referrer;
            address_to_referrals[_referrer].push(msg.sender);
            participants.push(msg.sender);
        }

        // If we have seen this buyer before
        else
        {
            // Referrer must be the same as their previous referrer
            require(_referrer == address_to_referrer[msg.sender]);
        }

        // Transfer the bought tokens from root to the buyer
        balances[root] -= tokensBought;
        balances[msg.sender] += tokensBought;
        emit Transfer(root, msg.sender, tokensBought);

        // Transfer commission to the referrer
        uint256 commissionForReferrer = totalValueOfTokensBought * REFERRER_COMMISSION_PERCENTAGE / 100;
        _referrer.transfer(commissionForReferrer);

        // Transfer commission to the root
        uint256 commissionForRoot = totalValueOfTokensBought * ROOT_COMMISSION_PERCENTAGE / 100;
        root.transfer(commissionForRoot);

        // Transfer the remaining ETH to the bank
        bank.transfer(totalValueOfTokensBought - commissionForReferrer - commissionForRoot);
    }

    function amountOfReferralsMade(address _byReferrer) external view returns (uint256)
    {
        return address_to_referrals[_byReferrer].length;
    }

    function amountOfTokensForSale() external view returns (uint256)
    {
        return balances[root];
    }

    function amountOfFreeTokensAvailable() external view returns (uint256)
    {
        if (participants.length < AMOUNT_OF_FREE_TOKENS)
        {
            return AMOUNT_OF_FREE_TOKENS - participants.length;
        }
        else
        {
            return 0;
        }
    }

    // ERC20 implementation
    string public constant name = "SuperLaunch";
    string public constant symbol = "SLX";
    uint8 public constant decimals = 0;

    mapping (address => mapping (address => uint256)) private allowed;

    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event Approval(address indexed _owner, address indexed _spender, uint256 _amount);

    function balanceOf(address _who) external view returns (uint256)
    {
        return balances[_who];
    }
    function allowance(address _owner, address _spender) external view returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    function transfer(address _to, uint256 _amount) external returns (bool)
    {
        require(balances[msg.sender] >= _amount);
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool)
    {
        require(allowed[_from][msg.sender] >= _amount);
        require(balances[_from] >= _amount);
        allowed[_from][msg.sender] -= _amount;
        balances[_from] -= _amount;
        balances[_to] += _amount;
        emit Transfer(_from, _to, _amount);
        emit Approval(_from, msg.sender, allowed[_from][msg.sender]);
        return true;
    }
    function approve(address _spender, uint256 _amount) external returns (bool)
    {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    function increaseAllowance(address _spender, uint256 _addedAmount) public returns (bool)
    {
        require(allowed[msg.sender][_spender] + _addedAmount >= _addedAmount);
        allowed[msg.sender][_spender] += _addedAmount;
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    function decreaseAllowance(address _spender, uint256 _subtractedAmount) public returns (bool)
    {
        require(allowed[msg.sender][_spender] >= _subtractedAmount);
        allowed[msg.sender][_spender] -= _subtractedAmount;
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}