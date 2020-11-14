/**
 * Source Code first verified at https://etherscan.io on Thursday, April 25, 2019
 (UTC) */

contract Administrable {
    using SafeMath for uint256;
    mapping (address => bool) private admins;
    uint256 private _nAdmin;
    uint256 private _nLimit;

    event Activated(address indexed admin);
    event Deactivated(address indexed admin);

    /**
     * @dev The Administrable constructor sets the original `admin` of the contract to the sender
     * account. The initial limit amount of admin is 2.
     */
    constructor() internal {
        _setAdminLimit(2);
        _activateAdmin(msg.sender);
    }

    function isAdmin() public view returns(bool) {
        return admins[msg.sender];
    }

    /**
     * @dev Throws if called by non-admin.
     */
    modifier onlyAdmin() {
        require(isAdmin(), "sender not admin");
        _;
    }

    function activateAdmin(address admin) external onlyAdmin {
        _activateAdmin(admin);
    }

    function deactivateAdmin(address admin) external onlyAdmin {
        _safeDeactivateAdmin(admin);
    }

    function setAdminLimit(uint256 n) external onlyAdmin {
        _setAdminLimit(n);
    }

    function _setAdminLimit(uint256 n) internal {
        require(_nLimit != n, "same limit");
        _nLimit = n;
    }

    /**
     * @notice The Amount of admin should be bounded by _nLimit.
     */
    function _activateAdmin(address admin) internal {
        require(admin != address(0), "invalid address");
        require(_nAdmin < _nLimit, "too many admins existed");
        require(!admins[admin], "already admin");
        admins[admin] = true;
        _nAdmin = _nAdmin.add(1);
        emit Activated(admin);
    }

    /**
     * @notice At least one admin should exists.
     */
    function _safeDeactivateAdmin(address admin) internal {
        require(_nAdmin > 1, "admin should > 1");
        _deactivateAdmin(admin);
    }

    function _deactivateAdmin(address admin) internal {
        require(admins[admin], "not admin");
        admins[admin] = false;
        _nAdmin = _nAdmin.sub(1);
        emit Deactivated(admin);
    }
}

library ErrorHandler {
    function errorHandler(bytes memory ret) internal pure {
        if (ret.length > 0) {
            byte ec = abi.decode(ret, (byte));
            if (ec != 0x00)
                revert(byteToHexString(ec));
        }
    }

    function byteToHexString(byte data) internal pure returns (string memory ret) {
        bytes memory ec = bytes("0x00");
        byte dataL = data & 0x0f;
        byte dataH = data >> 4;
        if (dataL < 0x0a)
            ec[3] = byte(uint8(ec[3]) + uint8(dataL));
        else
            ec[3] = byte(uint8(ec[3]) + uint8(dataL) + 0x27);
        if (dataH < 0x0a)
            ec[2] = byte(uint8(ec[2]) + uint8(dataH));
        else
            ec[2] = byte(uint8(ec[2]) + uint8(dataH) + 0x27);

        return string(ec);
    }
}

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
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
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

library Address {
    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

contract Proxy is Ownable {
    using Address for address;

    // keccak256 hash of "dinngo.proxy.implementation"
    bytes32 private constant IMPLEMENTATION_SLOT =
        0x3b2ff02c0f36dba7cc1b20a669e540b974575f04ef71846d482983efb03bebb4;

    event Upgraded(address indexed implementation);

    constructor(address implementation) internal {
        assert(IMPLEMENTATION_SLOT == keccak256("dinngo.proxy.implementation"));
        _setImplementation(implementation);
    }

    /**
     * @notice Upgrade the implementation contract. Can only be triggered
     * by the owner. Emits the Upgraded event.
     * @param implementation The new implementation address.
     */
    function upgrade(address implementation) external onlyOwner {
        _setImplementation(implementation);
        emit Upgraded(implementation);
    }

    /**
     * @dev Set the implementation address in the storage slot.
     * @param implementation The new implementation address.
     */
    function _setImplementation(address implementation) internal {
        require(implementation.isContract(),
            "Implementation address should be a contract address"
        );
        bytes32 slot = IMPLEMENTATION_SLOT;

        assembly {
            sstore(slot, implementation)
        }
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _implementation() internal view returns (address implementation) {
        bytes32 slot = IMPLEMENTATION_SLOT;

        assembly {
            implementation := sload(slot)
        }
    }
}

contract TimelockUpgradableProxy is Proxy {
    // keccak256 hash of "dinngo.proxy.registration"
    bytes32 private constant REGISTRATION_SLOT =
        0x90215db359d12011b32ff0c897114c39e26956599904ee846adb0dd49f782e97;
    // keccak256 hash of "dinngo.proxy.time"
    bytes32 private constant TIME_SLOT =
        0xe89d1a29650bdc8a918bc762afb8ef07e10f6180e461c3fc305f9f142e5591e6;
    uint256 private constant UPGRADE_TIME = 14 days;

    event UpgradeAnnounced(address indexed implementation, uint256 time);

    constructor() internal {
        assert(REGISTRATION_SLOT == keccak256("dinngo.proxy.registration"));
        assert(TIME_SLOT == keccak256("dinngo.proxy.time"));
    }

    /**
     * @notice Register the implementation address as the candidate contract
     * to be upgraded. Emits the UpgradeAnnounced event.
     * @param implementation The implementation contract address to be registered.
     */
    function register(address implementation) external onlyOwner {
        _registerImplementation(implementation);
        emit UpgradeAnnounced(implementation, _time());
    }

    /**
     * @dev Overload the function in contract Proxy.
     * @notice Upgrade the implementation contract.
     * @param implementation The new implementation contract.
     */
    function upgrade(address implementation) external {
        require(implementation == _registration());
        upgradeAnnounced();
    }

    /**
     * @notice Upgrade the implementation contract to the announced address.
     * Emits the Upgraded event.
     */
    function upgradeAnnounced() public onlyOwner {
        require(now >= _time());
        _setImplementation(_registration());
        emit Upgraded(_registration());
    }

    /**
     * @dev Register the imeplemtation address to the registation slot. Record the
     * valid time by adding the UPGRADE_TIME to the registration time to the time slot.
     * @param implementation The implemetation address to be registered.
     */
    function _registerImplementation(address implementation) internal {
        require(implementation.isContract(),
            "Implementation address should be a contract address"
        );
        uint256 time = now + UPGRADE_TIME;

        bytes32 implSlot = REGISTRATION_SLOT;
        bytes32 timeSlot = TIME_SLOT;

        assembly {
            sstore(implSlot, implementation)
            sstore(timeSlot, time)
        }
    }

    /**
     * @dev Return the valid time of registered implementation address.
     */
    function _time() internal view returns (uint256 time) {
        bytes32 slot = TIME_SLOT;

        assembly {
            time := sload(slot)
        }
    }

    /**
     * @dev Return the registered implementation address.
     */
    function _registration() internal view returns (address implementation) {
        bytes32 slot = REGISTRATION_SLOT;

        assembly {
            implementation := sload(slot)
        }
    }
}

contract DinngoProxy is Ownable, Administrable, TimelockUpgradableProxy {
    using ErrorHandler for bytes;

    uint256 public processTime;

    mapping (address => mapping (address => uint256)) public balances;
    mapping (bytes32 => uint256) public orderFills;
    mapping (uint256 => address payable) public userID_Address;
    mapping (uint256 => address) public tokenID_Address;
    mapping (address => uint256) public userRanks;
    mapping (address => uint256) public tokenRanks;
    mapping (address => uint256) public lockTimes;

    /**
     * @dev User ID 0 is the management wallet.
     * Token ID 0 is ETH (address 0). Token ID 1 is DGO.
     * @param dinngoWallet The main address of dinngo
     * @param dinngoToken The contract address of DGO
     */
    constructor(
        address payable dinngoWallet,
        address dinngoToken,
        address impl
    ) Proxy(impl) public {
        processTime = 90 days;
        userID_Address[0] = dinngoWallet;
        userRanks[dinngoWallet] = 255;
        tokenID_Address[0] = address(0);
        tokenID_Address[1] = dinngoToken;
    }

    /**
     * @dev All ether directly sent to contract will be refunded
     */
    function() external payable {
        revert();
    }

    /**
     * @notice Add the address to the user list. Event AddUser will be emitted
     * after execution.
     * @dev Record the user list to map the user address to a specific user ID, in
     * order to compact the data size when transferring user address information
     * @param id The user id to be assigned
     * @param user The user address to be added
     */
    function addUser(uint256 id, address user) external onlyAdmin {
        (bool ok,) = _implementation().delegatecall(
            abi.encodeWithSignature("addUser(uint256,address)", id, user)
        );
        require(ok);
    }

    /**
     * @notice Remove the address from the user list.
     * @dev The user rank is set to 0 to remove the user.
     * @param user The user address to be added
     */
    function removeUser(address user) external onlyAdmin {
        (bool ok,) = _implementation().delegatecall(
            abi.encodeWithSignature("removeUser(address)", user)
        );
        require(ok);
    }

    /**
     * @notice Update the rank of user. Can only be called by owner.
     * @param user The user address
     * @param rank The rank to be assigned
     */
    function updateUserRank(address user, uint256 rank) external onlyAdmin {
        (bool ok,) = _implementation().delegatecall(
            abi.encodeWithSignature("updateUserRank(address,uint256)",user, rank)
        );
        require(ok);
    }

    /**
     * @notice Add the token to the token list. Event AddToken will be emitted
     * after execution.
     * @dev Record the token list to map the token contract address to a specific
     * token ID, in order to compact the data size when transferring token contract
     * address information
     * @param id The token id to be assigned
     * @param token The token contract address to be added
     */
    function addToken(uint256 id, address token) external onlyOwner {
        (bool ok,) = _implementation().delegatecall(
            abi.encodeWithSignature("addToken(uint256,address)", id, token)
        );
        require(ok);
    }

    /**
     * @notice Remove the token to the token list.
     * @dev The token rank is set to 0 to remove the token.
     * @param token The token contract address to be removed.
     */
    function removeToken(address token) external onlyOwner {
        (bool ok,) = _implementation().delegatecall(
            abi.encodeWithSignature("removeToken(address)", token)
        );
        require(ok);
    }

    /**
     * @notice Update the rank of token. Can only be called by owner.
     * @param token The token contract address.
     * @param rank The rank to be assigned.
     */
    function updateTokenRank(address token, uint256 rank) external onlyOwner {
        (bool ok,) = _implementation().delegatecall(
            abi.encodeWithSignature("updateTokenRank(address,uint256)", token, rank)
        );
        require(ok);
    }

    function activateAdmin(address admin) external onlyOwner {
        _activateAdmin(admin);
    }

    function deactivateAdmin(address admin) external onlyOwner {
        _safeDeactivateAdmin(admin);
    }

    /**
     * @notice Force-deactivate allows owner to deactivate admin even there will be
     * no admin left. Should only be executed under emergency situation.
     */
    function forceDeactivateAdmin(address admin) external onlyOwner {
        _deactivateAdmin(admin);
    }

    function setAdminLimit(uint256 n) external onlyOwner {
        _setAdminLimit(n);
    }

    /**
     * @notice The deposit function for ether. The ether that is sent with the function
     * call will be deposited. The first time user will be added to the user list.
     * Event Deposit will be emitted after execution.
     */
    function deposit() external payable {
        (bool ok,) = _implementation().delegatecall(abi.encodeWithSignature("deposit()"));
        require(ok);
    }

    /**
     * @notice The deposit function for tokens. The first time user will be added to
     * the user list. Event Deposit will be emitted after execution.
     * @param token Address of the token contract to be deposited
     * @param amount Amount of the token to be depositied
     */
    function depositToken(address token, uint256 amount) external {
        (bool ok,) = _implementation().delegatecall(
            abi.encodeWithSignature("depositToken(address,uint256)", token, amount)
        );
        require(ok);
    }

    /**
     * @notice The withdraw function for ether. Event Withdraw will be emitted
     * after execution. User needs to be locked before calling withdraw.
     * @param amount The amount to be withdrawn.
     */
    function withdraw(uint256 amount) external {
        (bool ok,) = _implementation().delegatecall(
            abi.encodeWithSignature("withdraw(uint256)", amount)
        );
        require(ok);
    }

    /**
     * @notice The withdraw function for tokens. Event Withdraw will be emitted
     * after execution. User needs to be locked before calling withdraw.
     * @param token The token contract address to be withdrawn.
     * @param amount The token amount to be withdrawn.
     */
    function withdrawToken(address token, uint256 amount) external {
        (bool ok,) = _implementation().delegatecall(
            abi.encodeWithSignature("withdrawToken(address,uint256)", token, amount)
        );
        require(ok);
    }

    /**
     * @notice The withdraw function that can only be triggered by owner.
     * Event Withdraw will be emitted after execution.
     * @param withdrawal The serialized withdrawal data
     */
    function withdrawByAdmin(bytes calldata withdrawal) external onlyAdmin {
        (bool ok, bytes memory ret) = _implementation().delegatecall(
            abi.encodeWithSignature("withdrawByAdmin(bytes)", withdrawal)
        );
        require(ok);
        ret.errorHandler();
    }

    /**
     * @notice The settle function for orders. First order is taker order and the followings
     * are maker orders.
     * @param orders The serialized orders.
     */
    function settle(bytes calldata orders) external onlyAdmin {
        (bool ok, bytes memory ret) = _implementation().delegatecall(
            abi.encodeWithSignature("settle(bytes)", orders)
        );
        require(ok);
        ret.errorHandler();
    }

    /**
     * @notice The migrate function that can only be triggered by admin.
     * @param migration The serialized migration data
     */
    function migrateByAdmin(bytes calldata migration) external onlyAdmin {
        (bool ok, bytes memory ret) = _implementation().delegatecall(
            abi.encodeWithSignature("migrateByAdmin(bytes)", migration)
        );
        require(ok);
        ret.errorHandler();
    }

    /**
     * @notice Announce lock of the sender
     */
    function lock() external {
        (bool ok,) = _implementation().delegatecall(abi.encodeWithSignature("lock()"));
        require(ok);
    }

    /**
     * @notice Unlock the sender
     */
    function unlock() external {
        (bool ok,) = _implementation().delegatecall(abi.encodeWithSignature("unlock()"));
        require(ok);
    }

    /**
     * @notice Change the processing time of locking the user address
     */
    function changeProcessTime(uint256 time) external onlyOwner {
        (bool ok,) = _implementation().delegatecall(
            abi.encodeWithSignature("changeProcessTime(uint256)", time)
        );
        require(ok);
    }
}