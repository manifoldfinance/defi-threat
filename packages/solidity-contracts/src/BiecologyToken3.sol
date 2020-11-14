/**
 * Source Code first verified at https://etherscan.io on Wednesday, April 17, 2019
 (UTC) */

pragma solidity ^0.5.0;

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
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 *
 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
 * all accounts just by listening to said events. Note that this isn't required by the specification, and other
 * compliant implementations may not do it.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
    * @dev Transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }
}


/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

contract BiecologyToken3 is ERC20, ERC20Detailed {
    using SafeMath for uint256;
    uint256 private constant totalBIB= 390000000 * (10 ** 18); // Total amount of BIB tokens
    uint256 private constant INITIAL_SUPPLY = 30000000 * (10 ** 18); // Initial circulation quantity
    uint private constant FIRST_YEAR_PERCENTAGE = 110; // Monthly Increase Percentage in the First Year
    uint private constant SECOND_YEAR_PERCENTAGE = 106; // Monthly Increase Percentage in the Second Year
    uint private constant THIRD_YEAR_PERCENTAGE = 103;  // Monthly Increase Percentage in the Third Year
    uint private constant FOURTH_YEAR_PERCENTAGE = 103; // Monthly Increase Percentage in the Fourth Year
    uint private constant FIFTH_YEAR_PERCENTAGE = 103;  // Monthly Increase Percentage in the Fifth Year
    uint256 public quantity = 0; // Current circulation
    
    mapping(address => uint256) balances;
    // Owner of this contract
    address public owner;

    uint public startTime;

    mapping(uint=>uint) monthsTimestamp;

    uint[] fibseries;

    uint operatingTime;

    constructor () public ERC20Detailed("Bi ecology Token", "BIB", 18) {
        _mint(msg.sender, totalBIB);
        owner = msg.sender;
        balances[owner] = totalBIB;
        quantity = 0;
        startTime = 1556215200;  // 2019.4.26 02:00:00 
    }



    function runQuantityBIB(address _to) public {
        require(msg.sender == owner, "Not contract owner");
        require(totalBIB > quantity, "Release stop");

        if(quantity == 0){
            transfer(_to, INITIAL_SUPPLY);
            quantity = INITIAL_SUPPLY;
            balances[owner] = balances[owner] - INITIAL_SUPPLY;
            balances[_to] = INITIAL_SUPPLY;
        }
        if(block.timestamp > startTime) {
            operatingTime = block.timestamp - startTime;
            uint256 CURRENCY_BIB = 0;
            uint256 currentPrecentage = 100;
            uint256 lastMonthCoin = 0;
            for (uint i = 1; i <= 50; i++){ // Circular month
                    if(i<=12) { 
                        currentPrecentage = FIRST_YEAR_PERCENTAGE; 
                    }
                    else if(i>12 && i<=24){
                        currentPrecentage = SECOND_YEAR_PERCENTAGE;
                    }
                    else if(i>24 && i<=36){
                        currentPrecentage = THIRD_YEAR_PERCENTAGE;
                    }
                    else if(i>36 && i<=48){
                        currentPrecentage = FOURTH_YEAR_PERCENTAGE;
                    }
                    else{
                        currentPrecentage = FIFTH_YEAR_PERCENTAGE;
                    }
                
                
                    if(i * 30 * (60*60*24) > operatingTime){
                        uint256 diffDays = 0;
                        uint256 diffTime = operatingTime - ((i-1) * 30 * (60*60*24));
                        for (uint256 j = 1; j <= 30; j++){
                            if(diffTime < j * (60*60*24)){
                                diffDays = j;
                                break;
                            }
                        }
                        if(i == 1){
                            lastMonthCoin = INITIAL_SUPPLY;
                            if(operatingTime>0 && diffDays != 0){
                                CURRENCY_BIB = (lastMonthCoin * currentPrecentage / 100 - lastMonthCoin) * diffDays / 30;
                                CURRENCY_BIB = lastMonthCoin + CURRENCY_BIB;
                            }
                            else {
                                CURRENCY_BIB = INITIAL_SUPPLY;
                            }
                            lastMonthCoin = lastMonthCoin * currentPrecentage / 100;
                        }
                        else{
                            CURRENCY_BIB = (lastMonthCoin * currentPrecentage / 100 - lastMonthCoin) * diffDays / 30;
                            CURRENCY_BIB = lastMonthCoin + CURRENCY_BIB;
                            lastMonthCoin = lastMonthCoin * currentPrecentage / 100;
                        }
                        // Cycle to less than the release date to the present day to get circulation
                        break;
                    }
                    else {
                        if(lastMonthCoin == 0){
                            lastMonthCoin = INITIAL_SUPPLY;
                        }
                        lastMonthCoin = lastMonthCoin * currentPrecentage / 100;
                    }
                // }
            }
            if(totalBIB >= CURRENCY_BIB){
                uint256 bib = CURRENCY_BIB - quantity;
                quantity = CURRENCY_BIB;
                if(bib > 0){
                    transfer(_to, bib);
                    balances[owner] = balances[owner].sub(bib);
                    balances[_to] = balances[_to].add(bib);
                }
            }
            else {
                uint256 bib = totalBIB - quantity;
                if(bib > 0)
                {
                    quantity = totalBIB;
                    transfer(_to, bib);
                    balances[owner] = balances[owner] - bib;
                    balances[_to] =   balances[_to] + bib;
                }
                
            }
        }
        
    }

}