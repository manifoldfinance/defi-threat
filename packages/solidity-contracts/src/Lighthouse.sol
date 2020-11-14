/**
 * Source Code first verified at https://etherscan.io on Wednesday, April 17, 2019
 (UTC) */

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

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

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

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

// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol

pragma solidity ^0.5.0;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require((value == 0) || (token.allowance(address(this), spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        require(token.approve(spender, newAllowance));
    }
}

// File: contracts/robonomics/interface/ILighthouse.sol

pragma solidity ^0.5.0;

/**
 * @title Robonomics lighthouse contract interface
 */
contract ILighthouse {
    /**
     * @dev Provider going online
     */
    event Online(address indexed provider);

    /**
     * @dev Provider going offline
     */
    event Offline(address indexed provider);

    /**
     * @dev Active robonomics provider
     */
    event Current(address indexed provider, uint256 indexed quota);

    /**
     * @dev Robonomics providers list
     */
    address[] public providers;

    /**
     * @dev Count of robonomics providers on this lighthouse
     */
    function providersLength() public view returns (uint256)
    { return providers.length; }

    /**
     * @dev Provider stake distribution
     */
    mapping(address => uint256) public stakes;

    /**
     * @dev Minimal stake to get one quota
     */
    uint256 public minimalStake;

    /**
     * @dev Silence timeout for provider in blocks
     */
    uint256 public timeoutInBlocks;

    /**
     * @dev Block number of last transaction from current provider
     */
    uint256 public keepAliveBlock;

    /**
     * @dev Round robin provider list marker
     */
    uint256 public marker;

    /**
     * @dev Current provider quota
     */
    uint256 public quota;

    /**
     * @dev Get quota of provider
     */
    function quotaOf(address _provider) public view returns (uint256)
    { return stakes[_provider] / minimalStake; }

    /**
     * @dev Increase stake and get more quota,
     *      one quota - one transaction in round
     * @param _value in wn
     * @notice XRT should be approved before call this 
     */
    function refill(uint256 _value) external returns (bool);

    /**
     * @dev Decrease stake and get XRT back
     * @param _value in wn
     */
    function withdraw(uint256 _value) external returns (bool);

    /**
     * @dev Create liability smart contract assigned to this lighthouse
     * @param _demand ABI-encoded demand message
     * @param _offer ABI-encoded offer message
     * @notice Only current provider can call it
     */
    function createLiability(
        bytes calldata _demand,
        bytes calldata _offer
    ) external returns (bool);

    /**
     * @dev Finalize liability smart contract assigned to this lighthouse
     * @param _liability smart contract address
     * @param _result report of work
     * @param _success work success flag
     * @param _signature work signature
     */
    function finalizeLiability(
        address _liability,
        bytes calldata _result,
        bool _success,
        bytes calldata _signature
    ) external returns (bool);
}

// File: contracts/robonomics/interface/ILiability.sol

pragma solidity ^0.5.0;

/**
 * @title Standard liability smart contract interface
 */
contract ILiability {
    /**
     * @dev Liability termination signal
     */
    event Finalized(bool indexed success, bytes result);

    /**
     * @dev Behaviour model multihash
     */
    bytes public model;

    /**
     * @dev Objective ROSBAG multihash
     * @notice ROSBAGv2 is used: http://wiki.ros.org/Bags/Format/2.0 
     */
    bytes public objective;

    /**
     * @dev Report ROSBAG multihash 
     * @notice ROSBAGv2 is used: http://wiki.ros.org/Bags/Format/2.0 
     */
    bytes public result;

    /**
     * @dev Payment token address
     */
    address public token;

    /**
     * @dev Liability cost
     */
    uint256 public cost;

    /**
     * @dev Lighthouse fee in wn
     */
    uint256 public lighthouseFee;

    /**
     * @dev Validator fee in wn
     */
    uint256 public validatorFee;

    /**
     * @dev Robonomics demand message hash
     */
    bytes32 public demandHash;

    /**
     * @dev Robonomics offer message hash
     */
    bytes32 public offerHash;

    /**
     * @dev Liability promisor address
     */
    address public promisor;

    /**
     * @dev Liability promisee address
     */
    address public promisee;

    /**
     * @dev Lighthouse assigned to this liability
     */
    address public lighthouse;

    /**
     * @dev Liability validator address
     */
    address public validator;

    /**
     * @dev Liability success flag
     */
    bool public isSuccess;

    /**
     * @dev Liability finalization status flag
     */
    bool public isFinalized;

    /**
     * @dev Deserialize robonomics demand message
     * @notice It can be called by factory only
     */
    function demand(
        bytes   calldata _model,
        bytes   calldata _objective,

        address _token,
        uint256 _cost,

        address _lighthouse,

        address _validator,
        uint256 _validator_fee,

        uint256 _deadline,
        address _sender,
        bytes   calldata _signature
    ) external returns (bool);

    /**
     * @dev Deserialize robonomics offer message
     * @notice It can be called by factory only
     */
    function offer(
        bytes   calldata _model,
        bytes   calldata _objective,
        
        address _token,
        uint256 _cost,

        address _validator,

        address _lighthouse,
        uint256 _lighthouse_fee,

        uint256 _deadline,
        address _sender,
        bytes   calldata _signature
    ) external returns (bool);

    /**
     * @dev Finalize liability contract
     * @param _result Result data hash
     * @param _success Set 'true' when liability has success result
     * @param _signature Result signature: liability address, result and success flag signed by promisor
     * @notice It can be called by assigned lighthouse only
     */
    function finalize(
        bytes calldata _result,
        bool  _success,
        bytes calldata _signature
    ) external returns (bool);
}

// File: contracts/robonomics/interface/IFactory.sol

pragma solidity ^0.5.0;



/**
 * @title Robonomics liability factory interface
 */
contract IFactory {
    /**
     * @dev New liability created 
     */
    event NewLiability(address indexed liability);

    /**
     * @dev New lighthouse created
     */
    event NewLighthouse(address indexed lighthouse, string name);

    /**
     * @dev Lighthouse address mapping
     */
    mapping(address => bool) public isLighthouse;

    /**
     * @dev Nonce accounting
     */
    mapping(address => uint256) public nonceOf;

    /**
     * @dev Total GAS utilized by Robonomics network
     */
    uint256 public totalGasConsumed = 0;

    /**
     * @dev GAS utilized by liability contracts
     */
    mapping(address => uint256) public gasConsumedOf;

    /**
     * @dev The count of consumed gas for switch to next epoch 
     */
    uint256 public constant gasEpoch = 347 * 10**10;

    /**
     * @dev Current gas price in wei
     */
    uint256 public gasPrice = 10 * 10**9;

    /**
     * @dev XRT emission value for consumed gas
     * @param _gas Gas consumed by robonomics program
     */
    function wnFromGas(uint256 _gas) public view returns (uint256);

    /**
     * @dev Create lighthouse smart contract
     * @param _minimalStake Minimal stake value of XRT token (one quota price)
     * @param _timeoutInBlocks Max time of lighthouse silence in blocks
     * @param _name Lighthouse name,
     *              example: 'my-name' will create 'my-name.lighthouse.4.robonomics.eth' domain
     */
    function createLighthouse(
        uint256 _minimalStake,
        uint256 _timeoutInBlocks,
        string calldata _name
    ) external returns (ILighthouse);

    /**
     * @dev Create robot liability smart contract
     * @param _demand ABI-encoded demand message
     * @param _offer ABI-encoded offer message
     * @notice This method is for lighthouse contract use only
     */
    function createLiability(
        bytes calldata _demand,
        bytes calldata _offer
    ) external returns (ILiability);

    /**
     * @dev Is called after liability creation
     * @param _liability Liability contract address
     * @param _start_gas Transaction start gas level
     * @notice This method is for lighthouse contract use only
     */
    function liabilityCreated(ILiability _liability, uint256 _start_gas) external returns (bool);

    /**
     * @dev Is called after liability finalization
     * @param _liability Liability contract address
     * @param _start_gas Transaction start gas level
     * @notice This method is for lighthouse contract use only
     */
    function liabilityFinalized(ILiability _liability, uint256 _start_gas) external returns (bool);
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.5.0;



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

// File: openzeppelin-solidity/contracts/access/Roles.sol

pragma solidity ^0.5.0;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

// File: openzeppelin-solidity/contracts/access/roles/MinterRole.sol

pragma solidity ^0.5.0;


contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol

pragma solidity ^0.5.0;



/**
 * @title ERC20Mintable
 * @dev ERC20 minting logic
 */
contract ERC20Mintable is ERC20, MinterRole {
    /**
     * @dev Function to mint tokens
     * @param to The address that will receive the minted tokens.
     * @param value The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address to, uint256 value) public onlyMinter returns (bool) {
        _mint(to, value);
        return true;
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol

pragma solidity ^0.5.0;


/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract ERC20Burnable is ERC20 {
    /**
     * @dev Burns a specific amount of tokens.
     * @param value The amount of token to be burned.
     */
    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }

    /**
     * @dev Burns a specific amount of tokens from the target address and decrements allowance
     * @param from address The address which you want to send tokens from
     * @param value uint256 The amount of token to be burned
     */
    function burnFrom(address from, uint256 value) public {
        _burnFrom(from, value);
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol

pragma solidity ^0.5.0;


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

// File: contracts/robonomics/XRT.sol

pragma solidity ^0.5.0;




contract XRT is ERC20Mintable, ERC20Burnable, ERC20Detailed {
    constructor(uint256 _initial_supply) public ERC20Detailed("Robonomics", "XRT", 9) {
        _mint(msg.sender, _initial_supply);
    }
}

// File: contracts/robonomics/Lighthouse.sol

pragma solidity ^0.5.0;





contract Lighthouse is ILighthouse {
    using SafeERC20 for XRT;

    IFactory public factory;
    XRT      public xrt;

    function setup(XRT _xrt, uint256 _minimalStake, uint256 _timeoutInBlocks) external returns (bool) {
        require(factory == IFactory(0) && _minimalStake > 0 && _timeoutInBlocks > 0);

        minimalStake    = _minimalStake;
        timeoutInBlocks = _timeoutInBlocks;
        factory         = IFactory(msg.sender);
        xrt             = _xrt;

        return true;
    }

    /**
     * @dev Providers index, started from 1
     */
    mapping(address => uint256) public indexOf;

    function refill(uint256 _value) external returns (bool) {
        xrt.safeTransferFrom(msg.sender, address(this), _value);

        if (stakes[msg.sender] == 0) {
            require(_value >= minimalStake);
            providers.push(msg.sender);
            indexOf[msg.sender] = providers.length;
            emit Online(msg.sender);
        }

        stakes[msg.sender] += _value;
        return true;
    }

    function withdraw(uint256 _value) external returns (bool) {
        require(stakes[msg.sender] >= _value);

        stakes[msg.sender] -= _value;
        xrt.safeTransfer(msg.sender, _value);

        // Drop member with zero quota
        if (quotaOf(msg.sender) == 0) {
            uint256 balance = stakes[msg.sender];
            stakes[msg.sender] = 0;
            xrt.safeTransfer(msg.sender, balance);
            
            uint256 senderIndex = indexOf[msg.sender] - 1;
            uint256 lastIndex = providers.length - 1;
            if (senderIndex < lastIndex)
                providers[senderIndex] = providers[lastIndex];

            providers.length -= 1;
            indexOf[msg.sender] = 0;

            emit Offline(msg.sender);
        }
        return true;
    }

    function keepAliveTransaction() internal {
        if (timeoutInBlocks < block.number - keepAliveBlock) {
            // Set up the marker according to provider index
            marker = indexOf[msg.sender];

            // Thransaction sender should be a registered provider
            require(marker > 0 && marker <= providers.length);

            // Allocate new quota
            quota = quotaOf(providers[marker - 1]);

            // Current provider signal
            emit Current(providers[marker - 1], quota);
        }

        // Store transaction sending block
        keepAliveBlock = block.number;
    }

    function quotedTransaction() internal {
        // Don't premit transactions without providers on board
        require(providers.length > 0);

        // Zero quota guard
        // XXX: When quota for some reasons is zero, DoS will be preverted by keepalive transaction
        require(quota > 0);

        // Only provider with marker can to send transaction
        require(msg.sender == providers[marker - 1]);

        // Consume one quota for transaction sending
        if (quota > 1) {
            quota -= 1;
        } else {
            // Step over marker
            marker = marker % providers.length + 1;

            // Allocate new quota
            quota = quotaOf(providers[marker - 1]);

            // Current provider signal
            emit Current(providers[marker - 1], quota);
        }
    }

    function startGas() internal view returns (uint256 gas) {
        // the total amount of gas the tx is DataFee + TxFee + ExecutionGas
        // ExecutionGas
        gas = gasleft();
        // TxFee
        gas += 21000;
        // DataFee
        for (uint256 i = 0; i < msg.data.length; ++i)
            gas += msg.data[i] == 0 ? 4 : 68;
    }

    function createLiability(
        bytes calldata _demand,
        bytes calldata _offer
    )
        external
        returns (bool)
    {
        // Gas with estimation error
        uint256 gas = startGas() + 4887;

        keepAliveTransaction();
        quotedTransaction();

        ILiability liability = factory.createLiability(_demand, _offer);
        require(liability != ILiability(0));
        require(factory.liabilityCreated(liability, gas - gasleft()));
        return true;
    }

    function finalizeLiability(
        address _liability,
        bytes calldata _result,
        bool _success,
        bytes calldata _signature
    )
        external
        returns (bool)
    {
        // Gas with estimation error
        uint256 gas = startGas() + 22335;

        keepAliveTransaction();
        quotedTransaction();

        ILiability liability = ILiability(_liability);
        require(factory.gasConsumedOf(_liability) > 0);
        require(liability.finalize(_result, _success, _signature));
        require(factory.liabilityFinalized(liability, gas - gasleft()));
        return true;
    }
}