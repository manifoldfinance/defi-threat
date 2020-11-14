/**
 * Source Code first verified at https://etherscan.io on Thursday, May 9, 2019
 (UTC) */

pragma solidity 0.5.7;
pragma experimental ABIEncoderV2;


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract IRegistry {
    function add(address who) public;
}


contract IUniswapExchange {
    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 timestamp) public payable returns (uint256);
}


contract IGovernance {
    function proposeWithFeeRecipient(address feeRecipient, address target, bytes memory data) public returns (uint);
    function proposalFee() public view returns (uint);
}


/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath::mul: Integer overflow");

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath::div: Invalid divisor zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath::sub: Integer underflow");
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath::add: Integer overflow");

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath::mod: Invalid divisor zero");
        return a % b;
    }
}


/**
 * @title HumanityApplicant
 * @dev Convenient interface for applying to the Humanity registry.
 */
contract HumanityApplicant {
    using SafeMath for uint;

    IGovernance public governance;
    IRegistry public registry;
    IERC20 public humanity;

    constructor(IGovernance _governance, IRegistry _registry, IERC20 _humanity) public {
        governance = _governance;
        registry = _registry;
        humanity = _humanity;
        humanity.approve(address(governance), uint(-1));
    }

    function applyFor(address who) public returns (uint) {
        uint fee = governance.proposalFee();
        uint balance = humanity.balanceOf(address(this));
        if (fee > balance) {
            require(humanity.transferFrom(msg.sender, address(this), fee.sub(balance)), "HumanityApplicant::applyFor: Transfer failed");
        }
        bytes memory data = abi.encodeWithSelector(registry.add.selector, who);
        return governance.proposeWithFeeRecipient(msg.sender, address(registry), data);
    }

}


/**
 * @title PayableHumanityApplicant
 * @dev Convenient interface for applying to the Humanity registry using Ether.
 */
contract PayableHumanityApplicant is HumanityApplicant {

    IUniswapExchange public exchange;

    constructor(IGovernance _governance, IRegistry _registry, IERC20 _humanity, IUniswapExchange _exchange) public
        HumanityApplicant(_governance, _registry, _humanity)
    {
        exchange = _exchange;
    }

    function () external payable {}

    function applyWithEtherFor(address who) public payable returns (uint) {
        // Exchange Ether for Humanity tokens
        uint fee = governance.proposalFee();
        exchange.ethToTokenSwapOutput.value(msg.value)(fee, block.timestamp);

        // Apply to the registry
        uint proposalId = applyFor(who);

        // Refund any remaining balance
        msg.sender.send(address(this).balance);

        return proposalId;
    }

}


/**
 * @title TwitterHumanityApplicant
 * @dev Convenient interface for applying to the Humanity registry using Twitter as proof of identity.
 */
contract TwitterHumanityApplicant is PayableHumanityApplicant {

    event Apply(uint indexed proposalId, address indexed applicant, string username);

    constructor(
        IGovernance _governance,
        IRegistry _registry,
        IERC20 _humanity,
        IUniswapExchange _exchange
    ) public
        PayableHumanityApplicant(_governance, _registry, _humanity, _exchange) {}

    function applyWithTwitter(string memory username) public returns (uint) {
        return applyWithTwitterFor(msg.sender, username);
    }

    function applyWithTwitterFor(address who, string memory username) public returns (uint) {
        uint proposalId = applyFor(who);
        emit Apply(proposalId, who, username);
        return proposalId;
    }

    function applyWithTwitterUsingEther(string memory username) public payable returns (uint) {
        return applyWithTwitterUsingEtherFor(msg.sender, username);
    }

    function applyWithTwitterUsingEtherFor(address who, string memory username) public payable returns (uint) {
        uint proposalId = applyWithEtherFor(who);
        emit Apply(proposalId, who, username);
        return proposalId;
    }

}