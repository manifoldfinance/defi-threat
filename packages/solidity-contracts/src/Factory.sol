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

// File: contracts/ens/AbstractENS.sol

pragma solidity ^0.5.0;

contract AbstractENS {
    function owner(bytes32 _node) public view returns(address);
    function resolver(bytes32 _node) public view returns(address);
    function ttl(bytes32 _node) public view returns(uint64);
    function setOwner(bytes32 _node, address _owner) public;
    function setSubnodeOwner(bytes32 _node, bytes32 _label, address _owner) public;
    function setResolver(bytes32 _node, address _resolver) public;
    function setTTL(bytes32 _node, uint64 _ttl) public;

    // Logged when the owner of a node assigns a new owner to a subnode.
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    // Logged when the owner of a node transfers ownership to a new account.
    event Transfer(bytes32 indexed node, address owner);

    // Logged when the resolver for a node changes.
    event NewResolver(bytes32 indexed node, address resolver);

    // Logged when the TTL of a node changes
    event NewTTL(bytes32 indexed node, uint64 ttl);
}

// File: contracts/ens/AbstractResolver.sol

pragma solidity ^0.5.0;

contract AbstractResolver {
    function supportsInterface(bytes4 _interfaceID) public view returns (bool);
    function addr(bytes32 _node) public view returns (address ret);
    function setAddr(bytes32 _node, address _addr) public;
    function hash(bytes32 _node) public view returns (bytes32 ret);
    function setHash(bytes32 _node, bytes32 _hash) public;
}

// File: contracts/misc/SingletonHash.sol

pragma solidity ^0.5.0;

contract SingletonHash {
    event HashConsumed(bytes32 indexed hash);

    /**
     * @dev Used hash accounting
     */
    mapping(bytes32 => bool) public isHashConsumed;

    /**
     * @dev Parameter can be used only once
     * @param _hash Single usage hash
     */
    function singletonHash(bytes32 _hash) internal {
        require(!isHashConsumed[_hash]);
        isHashConsumed[_hash] = true;
        emit HashConsumed(_hash);
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

// File: openzeppelin-solidity/contracts/access/roles/SignerRole.sol

pragma solidity ^0.5.0;


contract SignerRole {
    using Roles for Roles.Role;

    event SignerAdded(address indexed account);
    event SignerRemoved(address indexed account);

    Roles.Role private _signers;

    constructor () internal {
        _addSigner(msg.sender);
    }

    modifier onlySigner() {
        require(isSigner(msg.sender));
        _;
    }

    function isSigner(address account) public view returns (bool) {
        return _signers.has(account);
    }

    function addSigner(address account) public onlySigner {
        _addSigner(account);
    }

    function renounceSigner() public {
        _removeSigner(msg.sender);
    }

    function _addSigner(address account) internal {
        _signers.add(account);
        emit SignerAdded(account);
    }

    function _removeSigner(address account) internal {
        _signers.remove(account);
        emit SignerRemoved(account);
    }
}

// File: openzeppelin-solidity/contracts/cryptography/ECDSA.sol

pragma solidity ^0.5.0;

/**
 * @title Elliptic curve signature operations
 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
 * TODO Remove this library once solidity supports passing a signature to ecrecover.
 * See https://github.com/ethereum/solidity/issues/864
 */

library ECDSA {
    /**
     * @dev Recover signer address from a message by using their signature
     * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
     * @param signature bytes signature, the signature is generated using web3.eth.sign()
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }

    /**
     * toEthSignedMessageHash
     * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:"
     * and hash the result
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

// File: openzeppelin-solidity/contracts/drafts/SignatureBouncer.sol

pragma solidity ^0.5.0;



/**
 * @title SignatureBouncer
 * @author PhABC, Shrugs and aflesher
 * @dev SignatureBouncer allows users to submit a signature as a permission to
 * do an action.
 * If the signature is from one of the authorized signer addresses, the
 * signature is valid.
 * Note that SignatureBouncer offers no protection against replay attacks, users
 * must add this themselves!
 *
 * Signer addresses can be individual servers signing grants or different
 * users within a decentralized club that have permission to invite other
 * members. This technique is useful for whitelists and airdrops; instead of
 * putting all valid addresses on-chain, simply sign a grant of the form
 * keccak256(abi.encodePacked(`:contractAddress` + `:granteeAddress`)) using a
 * valid signer address.
 * Then restrict access to your crowdsale/whitelist/airdrop using the
 * `onlyValidSignature` modifier (or implement your own using _isValidSignature).
 * In addition to `onlyValidSignature`, `onlyValidSignatureAndMethod` and
 * `onlyValidSignatureAndData` can be used to restrict access to only a given
 * method or a given method with given parameters respectively.
 * See the tests in SignatureBouncer.test.js for specific usage examples.
 *
 * @notice A method that uses the `onlyValidSignatureAndData` modifier must make
 * the _signature parameter the "last" parameter. You cannot sign a message that
 * has its own signature in it so the last 128 bytes of msg.data (which
 * represents the length of the _signature data and the _signaature data itself)
 * is ignored when validating. Also non fixed sized parameters make constructing
 * the data in the signature much more complex.
 * See https://ethereum.stackexchange.com/a/50616 for more details.
 */
contract SignatureBouncer is SignerRole {
    using ECDSA for bytes32;

    // Function selectors are 4 bytes long, as documented in
    // https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector
    uint256 private constant _METHOD_ID_SIZE = 4;
    // Signature size is 65 bytes (tightly packed v + r + s), but gets padded to 96 bytes
    uint256 private constant _SIGNATURE_SIZE = 96;

    constructor () internal {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev requires that a valid signature of a signer was provided
     */
    modifier onlyValidSignature(bytes memory signature) {
        require(_isValidSignature(msg.sender, signature));
        _;
    }

    /**
     * @dev requires that a valid signature with a specifed method of a signer was provided
     */
    modifier onlyValidSignatureAndMethod(bytes memory signature) {
        require(_isValidSignatureAndMethod(msg.sender, signature));
        _;
    }

    /**
     * @dev requires that a valid signature with a specifed method and params of a signer was provided
     */
    modifier onlyValidSignatureAndData(bytes memory signature) {
        require(_isValidSignatureAndData(msg.sender, signature));
        _;
    }

    /**
     * @dev is the signature of `this + sender` from a signer?
     * @return bool
     */
    function _isValidSignature(address account, bytes memory signature) internal view returns (bool) {
        return _isValidDataHash(keccak256(abi.encodePacked(address(this), account)), signature);
    }

    /**
     * @dev is the signature of `this + sender + methodId` from a signer?
     * @return bool
     */
    function _isValidSignatureAndMethod(address account, bytes memory signature) internal view returns (bool) {
        bytes memory data = new bytes(_METHOD_ID_SIZE);
        for (uint i = 0; i < data.length; i++) {
            data[i] = msg.data[i];
        }
        return _isValidDataHash(keccak256(abi.encodePacked(address(this), account, data)), signature);
    }

    /**
        * @dev is the signature of `this + sender + methodId + params(s)` from a signer?
        * @notice the signature parameter of the method being validated must be the "last" parameter
        * @return bool
        */
    function _isValidSignatureAndData(address account, bytes memory signature) internal view returns (bool) {
        require(msg.data.length > _SIGNATURE_SIZE);

        bytes memory data = new bytes(msg.data.length - _SIGNATURE_SIZE);
        for (uint i = 0; i < data.length; i++) {
            data[i] = msg.data[i];
        }

        return _isValidDataHash(keccak256(abi.encodePacked(address(this), account, data)), signature);
    }

    /**
     * @dev internal function to convert a hash to an eth signed message
     * and then recover the signature and check it against the signer role
     * @return bool
     */
    function _isValidDataHash(bytes32 hash, bytes memory signature) internal view returns (bool) {
        address signer = hash.toEthSignedMessageHash().recover(signature);

        return signer != address(0) && isSigner(signer);
    }
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

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/misc/DutchAuction.sol

pragma solidity ^0.5.0;






/// @title Dutch auction contract - distribution of XRT tokens using an auction.
/// @author Stefan George - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a8dbdccdcec9c686cfcdc7dacfcde8cbc7c6dbcdc6dbd1db86c6cddc">[email protected]</a>>
/// @author Airalab - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="2f5d4a5c4a4e5d4c476f4e465d4e014346494a">[email protected]</a>> 
contract DutchAuction is SignatureBouncer, Ownable {
    using SafeERC20 for ERC20Burnable;

    /*
     *  Events
     */
    event BidSubmission(address indexed sender, uint256 amount);

    /*
     *  Constants
     */
    uint constant public WAITING_PERIOD = 0; // 1 days;

    /*
     *  Storage
     */
    ERC20Burnable public token;
    address public ambix;
    address payable public wallet;
    uint public maxTokenSold;
    uint public ceiling;
    uint public priceFactor;
    uint public startBlock;
    uint public endTime;
    uint public totalReceived;
    uint public finalPrice;
    mapping (address => uint) public bids;
    Stages public stage;

    /*
     *  Enums
     */
    enum Stages {
        AuctionDeployed,
        AuctionSetUp,
        AuctionStarted,
        AuctionEnded,
        TradingStarted
    }

    /*
     *  Modifiers
     */
    modifier atStage(Stages _stage) {
        // Contract on stage
        require(stage == _stage);
        _;
    }

    modifier isValidPayload() {
        require(msg.data.length == 4 || msg.data.length == 164);
        _;
    }

    modifier timedTransitions() {
        if (stage == Stages.AuctionStarted && calcTokenPrice() <= calcStopPrice())
            finalizeAuction();
        if (stage == Stages.AuctionEnded && now > endTime + WAITING_PERIOD)
            stage = Stages.TradingStarted;
        _;
    }

    /*
     *  Public functions
     */
    /// @dev Contract constructor function sets owner.
    /// @param _wallet Multisig wallet.
    /// @param _maxTokenSold Auction token balance.
    /// @param _ceiling Auction ceiling.
    /// @param _priceFactor Auction price factor.
    constructor(address payable _wallet, uint _maxTokenSold, uint _ceiling, uint _priceFactor)
        public
    {
        require(_wallet != address(0) && _ceiling > 0 && _priceFactor > 0);

        wallet = _wallet;
        maxTokenSold = _maxTokenSold;
        ceiling = _ceiling;
        priceFactor = _priceFactor;
        stage = Stages.AuctionDeployed;
    }

    /// @dev Setup function sets external contracts' addresses.
    /// @param _token Token address.
    /// @param _ambix Distillation cube address.
    function setup(ERC20Burnable _token, address _ambix)
        public
        onlyOwner
        atStage(Stages.AuctionDeployed)
    {
        // Validate argument
        require(_token != ERC20Burnable(0) && _ambix != address(0));

        token = _token;
        ambix = _ambix;

        // Validate token balance
        require(token.balanceOf(address(this)) == maxTokenSold);

        stage = Stages.AuctionSetUp;
    }

    /// @dev Starts auction and sets startBlock.
    function startAuction()
        public
        onlyOwner
        atStage(Stages.AuctionSetUp)
    {
        stage = Stages.AuctionStarted;
        startBlock = block.number;
    }

    /// @dev Calculates current token price.
    /// @return Returns token price.
    function calcCurrentTokenPrice()
        public
        timedTransitions
        returns (uint)
    {
        if (stage == Stages.AuctionEnded || stage == Stages.TradingStarted)
            return finalPrice;
        return calcTokenPrice();
    }

    /// @dev Returns correct stage, even if a function with timedTransitions modifier has not yet been called yet.
    /// @return Returns current auction stage.
    function updateStage()
        public
        timedTransitions
        returns (Stages)
    {
        return stage;
    }

    /// @dev Allows to send a bid to the auction.
    /// @param signature KYC approvement
    function bid(bytes calldata signature)
        external
        payable
        isValidPayload
        timedTransitions
        atStage(Stages.AuctionStarted)
        onlyValidSignature(signature)
        returns (uint amount)
    {
        require(msg.value > 0);
        amount = msg.value;

        address payable receiver = msg.sender;

        // Prevent that more than 90% of tokens are sold. Only relevant if cap not reached.
        uint maxWei = maxTokenSold * calcTokenPrice() / 10**9 - totalReceived;
        uint maxWeiBasedOnTotalReceived = ceiling - totalReceived;
        if (maxWeiBasedOnTotalReceived < maxWei)
            maxWei = maxWeiBasedOnTotalReceived;

        // Only invest maximum possible amount.
        if (amount > maxWei) {
            amount = maxWei;
            // Send change back to receiver address.
            receiver.transfer(msg.value - amount);
        }

        // Forward funding to ether wallet
        (bool success,) = wallet.call.value(amount)("");
        require(success);

        bids[receiver] += amount;
        totalReceived += amount;
        emit BidSubmission(receiver, amount);

        // Finalize auction when maxWei reached
        if (amount == maxWei)
            finalizeAuction();
    }

    /// @dev Claims tokens for bidder after auction.
    function claimTokens()
        public
        isValidPayload
        timedTransitions
        atStage(Stages.TradingStarted)
    {
        address receiver = msg.sender;
        uint tokenCount = bids[receiver] * 10**9 / finalPrice;
        bids[receiver] = 0;
        token.safeTransfer(receiver, tokenCount);
    }

    /// @dev Calculates stop price.
    /// @return Returns stop price.
    function calcStopPrice()
        view
        public
        returns (uint)
    {
        return totalReceived * 10**9 / maxTokenSold + 1;
    }

    /// @dev Calculates token price.
    /// @return Returns token price.
    function calcTokenPrice()
        view
        public
        returns (uint)
    {
        return priceFactor * 10**18 / (block.number - startBlock + 7500) + 1;
    }

    /*
     *  Private functions
     */
    function finalizeAuction()
        private
    {
        stage = Stages.AuctionEnded;
        finalPrice = totalReceived == ceiling ? calcTokenPrice() : calcStopPrice();
        uint soldTokens = totalReceived * 10**9 / finalPrice;

        if (totalReceived == ceiling) {
            // Auction contract transfers all unsold tokens to Ambix contract
            token.safeTransfer(ambix, maxTokenSold - soldTokens);
        } else {
            // Auction contract burn all unsold tokens
            token.burn(maxTokenSold - soldTokens);
        }

        endTime = now;
    }
}

// File: contracts/misc/SharedCode.sol

pragma solidity ^0.5.0;

// Inspired by https://github.com/GNSPS/2DProxy
library SharedCode {
    /**
     * @dev Create tiny proxy without constructor
     * @param _shared Shared code contract address
     */
    function proxy(address _shared) internal returns (address instance) {
        bytes memory code = abi.encodePacked(
            hex"603160008181600b9039f3600080808080368092803773",
            _shared, hex"5af43d828181803e808314603057f35bfd"
        );
        assembly {
            instance := create(0, add(code, 0x20), 60)
            if iszero(extcodesize(instance)) {
                revert(0, 0)
            }
        }
    }
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

// File: contracts/robonomics/interface/IValidator.sol

pragma solidity ^0.5.0;

/**
 * @dev Observing network contract interface
 */
contract IValidator {
    /**
     * @dev Be sure than address is really validator
     * @return true when validator address in argument
     */
    function isValidator(address _validator) external returns (bool);
}

// File: contracts/robonomics/Liability.sol

pragma solidity ^0.5.0;







contract Liability is ILiability {
    using ECDSA for bytes32;
    using SafeERC20 for XRT;
    using SafeERC20 for ERC20;

    address public factory;
    XRT     public xrt;

    function setup(XRT _xrt) external returns (bool) {
        require(factory == address(0));

        factory = msg.sender;
        xrt     = _xrt;

        return true;
    }

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
    )
        external
        returns (bool)
    {
        require(msg.sender == factory);
        require(block.number < _deadline);

        model        = _model;
        objective    = _objective;
        token        = _token;
        cost         = _cost;
        lighthouse   = _lighthouse;
        validator    = _validator;
        validatorFee = _validator_fee;

        demandHash = keccak256(abi.encodePacked(
            _model
          , _objective
          , _token
          , _cost
          , _lighthouse
          , _validator
          , _validator_fee
          , _deadline
          , IFactory(factory).nonceOf(_sender)
          , _sender
        ));

        promisee = demandHash
            .toEthSignedMessageHash()
            .recover(_signature);
        require(promisee == _sender);
        return true;
    }

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
    )
        external
        returns (bool)
    {
        require(msg.sender == factory);
        require(block.number < _deadline);
        require(keccak256(model) == keccak256(_model));
        require(keccak256(objective) == keccak256(_objective));
        require(_token == token);
        require(_cost == cost);
        require(_lighthouse == lighthouse);
        require(_validator == validator);

        lighthouseFee = _lighthouse_fee;

        offerHash = keccak256(abi.encodePacked(
            _model
          , _objective
          , _token
          , _cost
          , _validator
          , _lighthouse
          , _lighthouse_fee
          , _deadline
          , IFactory(factory).nonceOf(_sender)
          , _sender
        ));

        promisor = offerHash
            .toEthSignedMessageHash()
            .recover(_signature);
        require(promisor == _sender);
        return true;
    }

    function finalize(
        bytes calldata _result,
        bool  _success,
        bytes calldata _signature
    )
        external
        returns (bool)
    {
        require(msg.sender == lighthouse);
        require(!isFinalized);

        isFinalized = true;
        result      = _result;
        isSuccess   = _success;

        address resultSender = keccak256(abi.encodePacked(this, _result, _success))
            .toEthSignedMessageHash()
            .recover(_signature);

        if (validator == address(0)) {
            require(resultSender == promisor);
        } else {
            require(IValidator(validator).isValidator(resultSender));
            // Transfer validator fee when is set
            if (validatorFee > 0)
                xrt.safeTransfer(validator, validatorFee);

        }

        if (cost > 0)
            ERC20(token).safeTransfer(isSuccess ? promisor : promisee, cost);

        emit Finalized(isSuccess, result);
        return true;
    }
}

// File: contracts/robonomics/Factory.sol

pragma solidity ^0.5.0;











contract Factory is IFactory, SingletonHash {
    constructor(
        address _liability,
        address _lighthouse,
        DutchAuction _auction,
        AbstractENS _ens,
        XRT _xrt
    ) public {
        liabilityCode = _liability;
        lighthouseCode = _lighthouse;
        auction = _auction;
        ens = _ens;
        xrt = _xrt;
    }

    address public liabilityCode;
    address public lighthouseCode;

    using SafeERC20 for XRT;
    using SafeERC20 for ERC20;
    using SharedCode for address;

    /**
     * @dev Robonomics dutch auction contract
     */
    DutchAuction public auction;

    /**
     * @dev Ethereum name system
     */
    AbstractENS public ens;

    /**
     * @dev Robonomics network protocol token
     */
    XRT public xrt;

    /**
     * @dev SMMA filter with function: SMMA(i) = (SMMA(i-1)*(n-1) + PRICE(i)) / n
     * @param _prePrice PRICE[n-1]
     * @param _price PRICE[n]
     * @return filtered price
     */
    function smma(uint256 _prePrice, uint256 _price) internal pure returns (uint256) {
        return (_prePrice * (smmaPeriod - 1) + _price) / smmaPeriod;
    }

    /**
     * @dev SMMA filter period
     */
    uint256 private constant smmaPeriod = 1000;

    /**
     * @dev XRT emission value for utilized gas
     */
    function wnFromGas(uint256 _gas) public view returns (uint256) {
        // Just return wn=gas*150 when auction isn't finish
        if (auction.finalPrice() == 0)
            return _gas * 150;

        // Current gas utilization epoch
        uint256 epoch = totalGasConsumed / gasEpoch;

        // XRT emission with addition coefficient by gas utilzation epoch
        uint256 wn = _gas * 10**9 * gasPrice * 2**epoch / 3**epoch / auction.finalPrice();

        // Check to not permit emission decrease below wn=gas
        return wn < _gas ? _gas : wn;
    }

    modifier onlyLighthouse {
        require(isLighthouse[msg.sender]);

        _;
    }

    modifier gasPriceEstimate {
        gasPrice = smma(gasPrice, tx.gasprice);

        _;
    }

    function createLighthouse(
        uint256 _minimalStake,
        uint256 _timeoutInBlocks,
        string  calldata _name
    )
        external
        returns (ILighthouse lighthouse)
    {
        bytes32 LIGHTHOUSE_NODE
            // lighthouse.5.robonomics.eth
            = 0x8d6c004b56cbe83bbfd9dcbd8f45d1f76398267bbb130a4629d822abc1994b96;
        bytes32 hname = keccak256(bytes(_name));

        // Name reservation check
        bytes32 subnode = keccak256(abi.encodePacked(LIGHTHOUSE_NODE, hname));
        require(ens.resolver(subnode) == address(0));

        // Create lighthouse
        lighthouse = ILighthouse(lighthouseCode.proxy());
        require(Lighthouse(address(lighthouse)).setup(xrt, _minimalStake, _timeoutInBlocks));

        emit NewLighthouse(address(lighthouse), _name);
        isLighthouse[address(lighthouse)] = true;

        // Register subnode
        ens.setSubnodeOwner(LIGHTHOUSE_NODE, hname, address(this));

        // Register lighthouse address
        AbstractResolver resolver = AbstractResolver(ens.resolver(LIGHTHOUSE_NODE));
        ens.setResolver(subnode, address(resolver));
        resolver.setAddr(subnode, address(lighthouse));
    }

    function createLiability(
        bytes calldata _demand,
        bytes calldata _offer
    )
        external
        onlyLighthouse
        returns (ILiability liability)
    {
        // Create liability
        liability = ILiability(liabilityCode.proxy());
        require(Liability(address(liability)).setup(xrt));

        emit NewLiability(address(liability));

        // Parse messages
        (bool success, bytes memory returnData)
            = address(liability).call(abi.encodePacked(bytes4(0x48a984e4), _demand)); // liability.demand(...)
        require(success);
        singletonHash(liability.demandHash());
        nonceOf[liability.promisee()] += 1;

        (success, returnData)
            = address(liability).call(abi.encodePacked(bytes4(0x413781d2), _offer)); // liability.offer(...)
        require(success);
        singletonHash(liability.offerHash());
        nonceOf[liability.promisor()] += 1;

        // Check lighthouse
        require(isLighthouse[liability.lighthouse()]);

        // Transfer lighthouse fee to lighthouse worker directly
        if (liability.lighthouseFee() > 0)
            xrt.safeTransferFrom(liability.promisor(),
                                 tx.origin,
                                 liability.lighthouseFee());

        // Transfer liability security and hold on contract
        ERC20 token = ERC20(liability.token());
        if (liability.cost() > 0)
            token.safeTransferFrom(liability.promisee(),
                                   address(liability),
                                   liability.cost());

        // Transfer validator fee and hold on contract
        if (liability.validator() != address(0) && liability.validatorFee() > 0)
            xrt.safeTransferFrom(liability.promisee(),
                                 address(liability),
                                 liability.validatorFee());
     }

    function liabilityCreated(
        ILiability _liability,
        uint256 _gas
    )
        external
        onlyLighthouse
        gasPriceEstimate
        returns (bool)
    {
        address liability = address(_liability);
        totalGasConsumed         += _gas;
        gasConsumedOf[liability] += _gas;
        return true;
    }

    function liabilityFinalized(
        ILiability _liability,
        uint256 _gas
    )
        external
        onlyLighthouse
        gasPriceEstimate
        returns (bool)
    {
        address liability = address(_liability);
        totalGasConsumed         += _gas;
        gasConsumedOf[liability] += _gas;
        require(xrt.mint(tx.origin, wnFromGas(gasConsumedOf[liability])));
        return true;
    }
}