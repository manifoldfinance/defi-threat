/**
 * Source Code first verified at https://etherscan.io on Friday, April 19, 2019
 (UTC) */

pragma solidity ^0.4.24;

contract ERC20 {
    function totalSupply() public view returns (uint supply);
    function balanceOf( address who ) public view returns (uint value);
    function allowance( address owner, address spender ) public view returns (uint _allowance);
    function transfer( address to, uint value) public returns (bool ok);
    function transferFrom( address from, address to, uint value) public returns (bool ok);
    function approve( address spender, uint value ) public returns (bool ok);
}

contract WETH {
    function deposit() public payable;
    function withdraw(uint wad) public;

    function approve(address guy, uint wad) public returns (bool); 
    function transfer(address dst, uint wad) public returns (bool);
    function transferFrom(address src, address dst, uint wad) public returns (bool);
} 

contract UNISWAP {
    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) public payable returns (uint256);
    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) public returns(uint256);
}

contract Ownable {
    address public owner;

    constructor ()
        public
    {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "ONLY_CONTRACT_OWNER"
        );
        _;
    }

    function transferOwnership(address newOwner)
        public
        onlyOwner
    {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

contract UniswapWrapper is Ownable{

    address public uniswapExchangeAddress;
    address public tradeTokenAddress;
    address public officalWethAddress;

    function() public payable{}

    constructor(address exchangeAddress, address tokenAddress, address wethAddress)
      public
    {
        uniswapExchangeAddress = exchangeAddress;
        tradeTokenAddress = tokenAddress;
        officalWethAddress = wethAddress;
    }

    function approve(address token, address proxy)
      public
      onlyOwner
    {
        uint256 MAX_UINT = 2 ** 256 - 1;
        require(ERC20(token).approve(proxy, MAX_UINT), "Approve failed");
    }

    function withdrawETH(uint256 amount)
        public
        onlyOwner
    {
        owner.transfer(amount);
    }

    function withdrawToken(address token, uint256 amount)
        public
        onlyOwner
    {
      require(ERC20(token).transfer(owner, amount), "Withdraw token failed");
    }

    function buyToken(uint256 minTokenAmount, uint256 ethPay, uint256 deadline)
      public
      onlyOwner
    {
      require(WETH(officalWethAddress).transferFrom(msg.sender, this, ethPay), "Transfer weth failed");
      WETH(officalWethAddress).withdraw(ethPay);
      uint256 tokenBought = UNISWAP(uniswapExchangeAddress).ethToTokenSwapInput.value(ethPay)(minTokenAmount, deadline);
      ERC20(tradeTokenAddress).transfer(owner, tokenBought);
    }

    function sellToken(uint256 minEthAmount, uint256 tokenAmount, uint256 deadline)
      public
      onlyOwner
    {
      require(ERC20(tradeTokenAddress).transferFrom(msg.sender, this, tokenAmount), "Transfer token failed");
      uint256 ethBought = UNISWAP(uniswapExchangeAddress).tokenToEthSwapInput(tokenAmount, minEthAmount, deadline);
      WETH(officalWethAddress).deposit.value(ethBought)();
      WETH(officalWethAddress).transfer(msg.sender, ethBought);
    }
}