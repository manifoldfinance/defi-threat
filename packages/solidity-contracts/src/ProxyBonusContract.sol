/**
 * Source Code first verified at https://etherscan.io on Monday, April 29, 2019
 (UTC) */

pragma solidity 0.5.6;


contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "");
        owner = newOwner;
    }

}


contract Manageable is Ownable {
    mapping(address => bool) public listOfManagers;

    modifier onlyManager() {
        require(listOfManagers[msg.sender], "");
        _;
    }

    function addManager(address _manager) public onlyOwner returns (bool success) {
        if (!listOfManagers[_manager]) {
            require(_manager != address(0), "");
            listOfManagers[_manager] = true;
            success = true;
        }
    }

    function removeManager(address _manager) public onlyOwner returns (bool success) {
        if (listOfManagers[_manager]) {
            listOfManagers[_manager] = false;
            success = true;
        }
    }

    function getInfo(address _manager) public view returns (bool) {
        return listOfManagers[_manager];
    }
}

interface iHourlyGame {
    function buyBonusTickets(
        address _participant,
        uint _hourlyTicketsCount,
        uint _dailyTicketsCount,
        uint _weeklyTicketsCount,
        uint _monthlyTicketsCount,
        uint _yearlyTicketsCount,
        uint _jackPotTicketsCount,
        uint _superJackPotTicketsCount
    ) external payable;
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


contract ProxyBonusContract is Manageable {
    using SafeMath for uint;

    IERC20 public token;

    address hourlyGame;

    constructor (
        address _token,
        address _hourlyGame
    )
    public
    {
        require(_token != address(0));
        require(_hourlyGame != address(0), "");

        token = IERC20(_token);
        hourlyGame = _hourlyGame;
    }

    function buyTickets(address _participant, uint _luckyBacksAmount) public {
        require(_luckyBacksAmount > 0, "");
        require(token.transferFrom(msg.sender, address(this), _luckyBacksAmount), "");

        uint amount = _luckyBacksAmount.div(10**18);

        iHourlyGame(hourlyGame).buyBonusTickets(
            _participant,
            amount,
            amount,
            amount,
            amount,
            amount,
            amount,
            amount
        );
    }

    function changeToken(address _token) public onlyManager {
        token = IERC20(_token);
    }
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, ""); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "");

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "");
        return a % b;
    }
}