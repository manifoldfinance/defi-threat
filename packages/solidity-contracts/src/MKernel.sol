/**
 * Source Code first verified at https://etherscan.io on Thursday, April 18, 2019
 (UTC) */

pragma solidity 0.4.24;

contract DSAuthority {
    function canCall(address src, address dst, bytes4 sig) public view returns (bool);
}


contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}


contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        public
        auth
    {
        authority = authority_;
        emit LogSetAuthority(authority);
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig), "DSAuth::_ SENDER_NOT_AUTHORIZED");
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, this, sig);
        }
    }
}


contract Proxy {

    // masterCopy always needs to be first declared variable, to ensure that it is at the same location in the contracts to which calls are delegated.
    address masterCopy;

    /// @dev Constructor function sets address of master copy contract.
    /// @param _masterCopy Master copy address.
    constructor(address _masterCopy)
        public
    {
        require(_masterCopy != 0, "Invalid master copy address provided");
        masterCopy = _masterCopy;
    }

    /// @dev Fallback function forwards all transactions and returns all received return data.
    function ()
        external
        payable
    {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            let masterCopy := and(sload(0), 0xffffffffffffffffffffffffffffffffffffffff)
            calldatacopy(0, 0, calldatasize())
            let success := delegatecall(gas, masterCopy, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            if eq(success, 0) { revert(0, returndatasize()) }
            return(0, returndatasize())
        }
    }

    function implementation()
        public
        view
        returns (address)
    {
        return masterCopy;
    }

    function proxyType()
        public
        pure
        returns (uint256)
    {
        return 2;
    }
}


contract ErrorUtils {

    event LogError(string methodSig, string errMsg);
    event LogErrorWithHintBytes32(bytes32 indexed bytes32Value, string methodSig, string errMsg);
    event LogErrorWithHintAddress(address indexed addressValue, string methodSig, string errMsg);

}


contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    // custom : not in original DSMath, putting it here for consistency, copied from SafeMath
    function div(uint x, uint y) internal pure returns (uint z) {
        z = x / y;
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}


contract SelfAuthorized {
    modifier authorized() {
        require(msg.sender == address(this), "Method can only be called from this contract");
        _;
    }
}


contract DSNote {
    event LogNote(
        bytes4   indexed  sig,
        address  indexed  guy,
        bytes32  indexed  foo,
        bytes32  indexed  bar,
        uint              wad,
        bytes             fax
    ) anonymous;

    modifier note {
        bytes32 foo;
        bytes32 bar;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
        }

        emit LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);

        _;
    }
}


contract Utils {

    modifier addressValid(address _address) {
        require(_address != address(0), "Utils::_ INVALID_ADDRESS");
        _;
    }

}


contract WETH9 {
    string public name     = "Wrapped Ether";
    string public symbol   = "WETH";
    uint8  public decimals = 18;

    event  Approval(address indexed _owner, address indexed _spender, uint _value);
    event  Transfer(address indexed _from, address indexed _to, uint _value);
    event  Deposit(address indexed _owner, uint _value);
    event  Withdrawal(address indexed _owner, uint _value);

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;

    function() public payable {
        deposit();
    }

    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        Deposit(msg.sender, msg.value);
    }

    function withdraw(uint wad) public {
        require(balanceOf[msg.sender] >= wad);
        balanceOf[msg.sender] -= wad;
        msg.sender.transfer(wad);
        Withdrawal(msg.sender, wad);
    }

    function totalSupply() public view returns (uint) {
        return this.balance;
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        Transfer(src, dst, wad);

        return true;
    }
}


contract DateTime {
    /*
        *  Date and Time utilities for ethereum contracts
        *
        */
    struct _DateTime {
        uint16 year;
        uint8 month;
        uint8 day;
        uint8 hour;
        uint8 minute;
        uint8 second;
        uint8 weekday;
    }

    uint constant DAY_IN_SECONDS = 86400;
    uint constant YEAR_IN_SECONDS = 31536000;
    uint constant LEAP_YEAR_IN_SECONDS = 31622400;

    uint constant HOUR_IN_SECONDS = 3600;
    uint constant MINUTE_IN_SECONDS = 60;

    uint16 constant ORIGIN_YEAR = 1970;

    function isLeapYear(uint16 year) public pure returns (bool) {
        if (year % 4 != 0) {
            return false;
        }
        if (year % 100 != 0) {
            return true;
        }
        if (year % 400 != 0) {
            return false;
        }
        return true;
    }

    function leapYearsBefore(uint year) public pure returns (uint) {
        year -= 1;
        return year / 4 - year / 100 + year / 400;
    }

    function getDaysInMonth(uint8 month, uint16 year) public pure returns (uint8) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            return 31;
        }
        else if (month == 4 || month == 6 || month == 9 || month == 11) {
            return 30;
        }
        else if (isLeapYear(year)) {
            return 29;
        }
        else {
            return 28;
        }
    }

    function parseTimestamp(uint timestamp) internal pure returns (_DateTime dt) {
        uint secondsAccountedFor = 0;
        uint buf;
        uint8 i;

        // Year
        dt.year = getYear(timestamp);
        buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
        secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

        // Month
        uint secondsInMonth;
        for (i = 1; i <= 12; i++) {
            secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
            if (secondsInMonth + secondsAccountedFor > timestamp) {
                dt.month = i;
                break;
            }
            secondsAccountedFor += secondsInMonth;
        }

        // Day
        for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
            if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                dt.day = i;
                break;
            }
            secondsAccountedFor += DAY_IN_SECONDS;
        }

        // Hour
        dt.hour = getHour(timestamp);

        // Minute
        dt.minute = getMinute(timestamp);

        // Second
        dt.second = getSecond(timestamp);

        // Day of week.
        dt.weekday = getWeekday(timestamp);
    }

    function getYear(uint timestamp) public pure returns (uint16) {
        uint secondsAccountedFor = 0;
        uint16 year;
        uint numLeapYears;

        // Year
        year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
        numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
        secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

        while (secondsAccountedFor > timestamp) {
            if (isLeapYear(uint16(year - 1))) {
                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
            }
            else {
                secondsAccountedFor -= YEAR_IN_SECONDS;
            }
            year -= 1;
        }
        return year;
    }

    function getMonth(uint timestamp) public pure returns (uint8) {
        return parseTimestamp(timestamp).month;
    }

    function getDay(uint timestamp) public pure returns (uint8) {
        return parseTimestamp(timestamp).day;
    }

    function getHour(uint timestamp) public pure returns (uint8) {
        return uint8((timestamp / 60 / 60) % 24);
    }

    function getMinute(uint timestamp) public pure returns (uint8) {
        return uint8((timestamp / 60) % 60);
    }

    function getSecond(uint timestamp) public pure returns (uint8) {
        return uint8(timestamp % 60);
    }

    function getWeekday(uint timestamp) public pure returns (uint8) {
        return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
    }

    function toTimestamp(uint16 year, uint8 month, uint8 day) public pure returns (uint timestamp) {
        return toTimestamp(year, month, day, 0, 0, 0);
    }

    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) public pure returns (uint timestamp) {
        return toTimestamp(year, month, day, hour, 0, 0);
    }

    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) public pure returns (uint timestamp) {
        return toTimestamp(year, month, day, hour, minute, 0);
    }

    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) public pure returns (uint timestamp) {
        uint16 i;

        // Year
        for (i = ORIGIN_YEAR; i < year; i++) {
            if (isLeapYear(i)) {
                timestamp += LEAP_YEAR_IN_SECONDS;
            }
            else {
                timestamp += YEAR_IN_SECONDS;
            }
        }

        // Month
        uint8[12] memory monthDayCounts;
        monthDayCounts[0] = 31;
        if (isLeapYear(year)) {
            monthDayCounts[1] = 29;
        }
        else {
            monthDayCounts[1] = 28;
        }
        monthDayCounts[2] = 31;
        monthDayCounts[3] = 30;
        monthDayCounts[4] = 31;
        monthDayCounts[5] = 30;
        monthDayCounts[6] = 31;
        monthDayCounts[7] = 31;
        monthDayCounts[8] = 30;
        monthDayCounts[9] = 31;
        monthDayCounts[10] = 30;
        monthDayCounts[11] = 31;

        for (i = 1; i < month; i++) {
            timestamp += DAY_IN_SECONDS * monthDayCounts[i - 1];
        }

        // Day
        timestamp += DAY_IN_SECONDS * (day - 1);

        // Hour
        timestamp += HOUR_IN_SECONDS * (hour);

        // Minute
        timestamp += MINUTE_IN_SECONDS * (minute);

        // Second
        timestamp += second;

        return timestamp;
    }
}


interface ERC20 {

    function name() external view returns(string);
    function symbol() external view returns(string);
    function decimals() external view returns(uint8);
    function totalSupply() external view returns (uint);

    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract MasterCopy is SelfAuthorized {
  // masterCopy always needs to be first declared variable, to ensure that it is at the same location as in the Proxy contract.
  // It should also always be ensured that the address is stored alone (uses a full word)
    address masterCopy;

  /// @dev Allows to upgrade the contract. This can only be done via a Safe transaction.
  /// @param _masterCopy New contract address.
    function changeMasterCopy(address _masterCopy)
        public
        authorized
    {
        // Master copy address cannot be null.
        require(_masterCopy != 0, "Invalid master copy address provided");
        masterCopy = _masterCopy;
    }
}


contract Config is DSNote, DSAuth, Utils {

    WETH9 public weth9;
    mapping (address => bool) public isAccountHandler;
    mapping (address => bool) public isAdmin;
    address[] public admins;
    bool public disableAdminControl = false;
    
    event LogAdminAdded(address indexed _admin, address _by);
    event LogAdminRemoved(address indexed _admin, address _by);

    constructor() public {
        admins.push(msg.sender);
        isAdmin[msg.sender] = true;
    }

    modifier onlyAdmin(){
        require(isAdmin[msg.sender], "Config::_ SENDER_NOT_AUTHORIZED");
        _;
    }

    function setWETH9
    (
        address _weth9
    ) 
        public
        auth
        note
        addressValid(_weth9) 
    {
        weth9 = WETH9(_weth9);
    }

    function setAccountHandler
    (
        address _accountHandler,
        bool _isAccountHandler
    )
        public
        auth
        note
        addressValid(_accountHandler)
    {
        isAccountHandler[_accountHandler] = _isAccountHandler;
    }

    function toggleAdminsControl() 
        public
        auth
        note
    {
        disableAdminControl = !disableAdminControl;
    }

    function isAdminValid(address _admin)
        public
        view
        returns (bool)
    {
        if(disableAdminControl) {
            return true;
        } else {
            return isAdmin[_admin];
        }
    }

    function getAllAdmins()
        public
        view
        returns(address[])
    {
        return admins;
    }

    function addAdmin
    (
        address _admin
    )
        external
        note
        onlyAdmin
        addressValid(_admin)
    {   
        require(!isAdmin[_admin], "Config::addAdmin ADMIN_ALREADY_EXISTS");

        admins.push(_admin);
        isAdmin[_admin] = true;

        emit LogAdminAdded(_admin, msg.sender);
    }

    function removeAdmin
    (
        address _admin
    ) 
        external
        note
        onlyAdmin
        addressValid(_admin)
    {   
        require(isAdmin[_admin], "Config::removeAdmin ADMIN_DOES_NOT_EXIST");
        require(msg.sender != _admin, "Config::removeAdmin ADMIN_NOT_AUTHORIZED");

        isAdmin[_admin] = false;

        for (uint i = 0; i < admins.length - 1; i++) {
            if (admins[i] == _admin) {
                admins[i] = admins[admins.length - 1];
                admins.length -= 1;
                break;
            }
        }

        emit LogAdminRemoved(_admin, msg.sender);
    }
}


library ECRecovery {

    function recover(bytes32 _hash, bytes _sig)
        internal
        pure
    returns (address)
    {
        bytes32 r;
        bytes32 s;
        uint8 v;

        if (_sig.length != 65) {
            return (address(0));
        }

        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(_hash, v, r, s);
        }
    }

    function toEthSignedMessageHash(bytes32 _hash)
        internal
        pure
    returns (bytes32)
    {
        return keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)
        );
    }
}


contract Utils2 {
    using ECRecovery for bytes32;
    
    function _recoverSigner(bytes32 _hash, bytes _signature) 
        internal
        pure
        returns(address _signer)
    {
        return _hash.toEthSignedMessageHash().recover(_signature);
    }

}


contract DSThing is DSNote, DSAuth, DSMath {

    function S(string s) internal pure returns (bytes4) {
        return bytes4(keccak256(s));
    }

}


contract DSStop is DSNote, DSAuth {

    bool public stopped = false;

    modifier whenNotStopped {
        require(!stopped, "DSStop::_ FEATURE_STOPPED");
        _;
    }

    modifier whenStopped {
        require(stopped, "DSStop::_ FEATURE_NOT_STOPPED");
        _;
    }

    function stop() public auth note {
        stopped = true;
    }
    function start() public auth note {
        stopped = false;
    }

}


contract Account is MasterCopy, DSNote, Utils, Utils2, ErrorUtils {

    address[] public users;
    mapping (address => bool) public isUser;
    mapping (bytes32 => bool) public actionCompleted;

    WETH9 public weth9;
    Config public config;
    bool public isInitialized = false;

    event LogTransferBySystem(address indexed token, address indexed to, uint value, address by);
    event LogTransferByUser(address indexed token, address indexed to, uint value, address by);
    event LogUserAdded(address indexed user, address by);
    event LogUserRemoved(address indexed user, address by);
    event LogImplChanged(address indexed newImpl, address indexed oldImpl);

    modifier initialized() {
        require(isInitialized, "Account::_ ACCOUNT_NOT_INITIALIZED");
        _;
    }

    modifier notInitialized() {
        require(!isInitialized, "Account::_ ACCOUNT_ALREADY_INITIALIZED");
        _;
    }

    modifier userExists(address _user) {
        require(isUser[_user], "Account::_ INVALID_USER");
        _;
    }

    modifier userDoesNotExist(address _user) {
        require(!isUser[_user], "Account::_ USER_DOES_NOT_EXISTS");
        _;
    }

    modifier onlyAdmin() {
        require(config.isAdminValid(msg.sender), "Account::_ INVALID_ADMIN_ACCOUNT");
        _;
    }

    modifier onlyHandler(){
        require(config.isAccountHandler(msg.sender), "Account::_ INVALID_ACC_HANDLER");
        _;
    }

    function init(address _user, address _config)
        public 
        notInitialized
    {
        users.push(_user);
        isUser[_user] = true;
        config = Config(_config);
        weth9 = config.weth9();
        isInitialized = true;
    }
    
    function getAllUsers() public view returns (address[]) {
        return users;
    }

    function balanceFor(address _token) public view returns (uint _balance){
        _balance = ERC20(_token).balanceOf(this);
    }
    
    function transferBySystem
    (   
        address _token,
        address _to,
        uint _value
    ) 
        external 
        onlyHandler
        note 
        initialized
    {
        require(ERC20(_token).balanceOf(this) >= _value, "Account::transferBySystem INSUFFICIENT_BALANCE_IN_ACCOUNT");
        ERC20(_token).transfer(_to, _value);

        emit LogTransferBySystem(_token, _to, _value, msg.sender);
    }
    
    function transferByUser
    (   
        address _token,
        address _to,
        uint _value,
        uint _salt,
        bytes _signature
    )
        external
        addressValid(_to)
        note
        initialized
        onlyAdmin
    {
        bytes32 actionHash = _getTransferActionHash(_token, _to, _value, _salt);

        if(actionCompleted[actionHash]) {
            emit LogError("Account::transferByUser", "ACTION_ALREADY_PERFORMED");
            return;
        }

        if(ERC20(_token).balanceOf(this) < _value){
            emit LogError("Account::transferByUser", "INSUFFICIENT_BALANCE_IN_ACCOUNT");
            return;
        }

        address signer = _recoverSigner(actionHash, _signature);

        if(!isUser[signer]) {
            emit LogError("Account::transferByUser", "SIGNER_NOT_AUTHORIZED_WITH_ACCOUNT");
            return;
        }

        actionCompleted[actionHash] = true;
        
        if (_token == address(weth9)) {
            weth9.withdraw(_value);
            _to.transfer(_value);
        } else {
            require(ERC20(_token).transfer(_to, _value), "Account::transferByUser TOKEN_TRANSFER_FAILED");
        }

        emit LogTransferByUser(_token, _to, _value, signer);
    }

    function addUser
    (
        address _user,
        uint _salt,
        bytes _signature
    )
        external 
        note 
        addressValid(_user)
        userDoesNotExist(_user)
        initialized
        onlyAdmin
    {   
        bytes32 actionHash = _getUserActionHash(_user, "ADD_USER", _salt);
        if(actionCompleted[actionHash])
        {
            emit LogError("Account::addUser", "ACTION_ALREADY_PERFORMED");
            return;
        }

        address signer = _recoverSigner(actionHash, _signature);

        if(!isUser[signer]) {
            emit LogError("Account::addUser", "SIGNER_NOT_AUTHORIZED_WITH_ACCOUNT");
            return;
        }

        actionCompleted[actionHash] = true;

        users.push(_user);
        isUser[_user] = true;

        emit LogUserAdded(_user, signer);
    }

    function removeUser
    (
        address _user,
        uint _salt,
        bytes _signature
    ) 
        external
        note
        userExists(_user) 
        initialized
        onlyAdmin
    {   
        bytes32 actionHash = _getUserActionHash(_user, "REMOVE_USER", _salt);

        if(actionCompleted[actionHash]) {
            emit LogError("Account::removeUser", "ACTION_ALREADY_PERFORMED");
            return;
        }

        address signer = _recoverSigner(actionHash, _signature);
        
        if(users.length == 1){
            emit LogError("Account::removeUser",  "ACC_SHOULD_HAVE_ATLEAST_ONE_USER");
            return;
        }
        
        if(!isUser[signer]){
            emit LogError("Account::removeUser", "SIGNER_NOT_AUTHORIZED_WITH_ACCOUNT");
            return;
        }
        
        actionCompleted[actionHash] = true;

        // should delete value from isUser map? delete isUser[_user]?
        isUser[_user] = false;
        for (uint i = 0; i < users.length - 1; i++) {
            if (users[i] == _user) {
                users[i] = users[users.length - 1];
                users.length -= 1;
                break;
            }
        }

        emit LogUserRemoved(_user, signer);
    }

    function _getTransferActionHash
    ( 
        address _token,
        address _to,
        uint _value,
        uint _salt
    ) 
        internal
        view
        returns (bytes32)
    {
        return keccak256(
            abi.encodePacked(
                address(this),
                _token,
                _to,
                _value,
                _salt
            )
        );
    }

    function _getUserActionHash
    ( 
        address _user,
        string _action,
        uint _salt
    ) 
        internal
        view
        returns (bytes32)
    {
        return keccak256(
            abi.encodePacked(
                address(this),
                _user,
                _action,
                _salt
            )
        );
    }

    // to directly send ether to contract
    function() external payable {
        require(msg.data.length == 0 && msg.value > 0, "Account::fallback INVALID_ETHER_TRANSFER");

        if(msg.sender != address(weth9)){
            weth9.deposit.value(msg.value)();
        }
    }

    function changeImpl
    (
        address _to,
        uint _salt,
        bytes _signature
    )
        external 
        note 
        addressValid(_to)
        initialized
        onlyAdmin
    {   
        bytes32 actionHash = _getUserActionHash(_to, "CHANGE_ACCOUNT_IMPLEMENTATION", _salt);
        if(actionCompleted[actionHash])
        {
            emit LogError("Account::changeImpl", "ACTION_ALREADY_PERFORMED");
            return;
        }

        address signer = _recoverSigner(actionHash, _signature);

        if(!isUser[signer]) {
            emit LogError("Account::changeImpl", "SIGNER_NOT_AUTHORIZED_WITH_ACCOUNT");
            return;
        }

        actionCompleted[actionHash] = true;

        address oldImpl = masterCopy;
        this.changeMasterCopy(_to);
        
        emit LogImplChanged(_to, oldImpl);
    }

}


contract AccountFactory is DSStop, Utils {
    Config public config;
    mapping (address => bool) public isAccount;
    mapping (address => address[]) public userToAccounts;
    address[] public accounts;

    address public accountMaster;

    constructor
    (
        Config _config, 
        address _accountMaster
    ) 
    public 
    {
        config = _config;
        accountMaster = _accountMaster;
    }

    event LogAccountCreated(address indexed user, address indexed account, address by);

    modifier onlyAdmin() {
        require(config.isAdminValid(msg.sender), "AccountFactory::_ INVALID_ADMIN_ACCOUNT");
        _;
    }

    function setConfig(Config _config) external note auth addressValid(_config) {
        config = _config;
    }

    function setAccountMaster(address _accountMaster) external note auth addressValid(_accountMaster) {
        accountMaster = _accountMaster;
    }

    function newAccount(address _user)
        public
        note
        onlyAdmin
        addressValid(config)
        addressValid(accountMaster)
        whenNotStopped
        returns 
        (
            Account _account
        ) 
    {
        address proxy = new Proxy(accountMaster);
        _account = Account(proxy);
        _account.init(_user, config);

        accounts.push(_account);
        userToAccounts[_user].push(_account);
        isAccount[_account] = true;

        emit LogAccountCreated(_user, _account, msg.sender);
    }
    
    function batchNewAccount(address[] _users) public note onlyAdmin {
        for (uint i = 0; i < _users.length; i++) {
            newAccount(_users[i]);
        }
    }

    function getAllAccounts() public view returns (address[]) {
        return accounts;
    }

    function getAccountsForUser(address _user) public view returns (address[]) {
        return userToAccounts[_user];
    }

}


contract Escrow is DSNote, DSAuth {

    event LogTransfer(address indexed token, address indexed to, uint value);
    event LogTransferFromAccount(address indexed account, address indexed token, address indexed to, uint value);

    function transfer
    (
        address _token,
        address _to,
        uint _value
    )
        public
        note
        auth
    {
        require(ERC20(_token).transfer(_to, _value), "Escrow::transfer TOKEN_TRANSFER_FAILED");
        emit LogTransfer(_token, _to, _value);
    }

    function transferFromAccount
    (
        address _account,
        address _token,
        address _to,
        uint _value
    )
        public
        note
        auth
    {   
        Account(_account).transferBySystem(_token, _to, _value);
        emit LogTransferFromAccount(_account, _token, _to, _value);
    }

}

// issue with deploying multiple instances of same type in truffle, hence the following two contracts
contract KernelEscrow is Escrow {

}

contract ReserveEscrow is Escrow {
    
}


contract Reserve is DSStop, DSThing, Utils, Utils2, ErrorUtils {

    Escrow public escrow;
    AccountFactory public accountFactory;
    DateTime public dateTime;
    Config public config;
    uint public deployTimestamp;

    string constant public VERSION = "1.0.0";

    uint public TIME_INTERVAL = 1 days;
    //uint public TIME_INTERVAL = 1 hours;
    
    constructor
    (
        Escrow _escrow,
        AccountFactory _accountFactory,
        DateTime _dateTime,
        Config _config
    ) 
    public 
    {
        escrow = _escrow;
        accountFactory = _accountFactory;
        dateTime = _dateTime;
        config = _config;
        deployTimestamp = now - (4 * TIME_INTERVAL);
    }

    function setEscrow(Escrow _escrow) 
        public 
        note 
        auth
        addressValid(_escrow)
    {
        escrow = _escrow;
    }

    function setAccountFactory(AccountFactory _accountFactory) 
        public 
        note 
        auth
        addressValid(_accountFactory)
    {
        accountFactory = _accountFactory;
    }

    function setDateTime(DateTime _dateTime) 
        public 
        note 
        auth
        addressValid(_dateTime)
    {
        dateTime = _dateTime;
    }

    function setConfig(Config _config) 
        public 
        note 
        auth
        addressValid(_config)
    {
        config = _config;
    }

    struct Order {
        address account;
        address token;
        address byUser;
        uint value;
        uint duration;
        uint expirationTimestamp;
        uint salt;
        uint createdTimestamp;
        bytes32 orderHash;
    }

    bytes32[] public orders;
    mapping (bytes32 => Order) public hashToOrder;
    mapping (bytes32 => bool) public isOrder;
    mapping (address => bytes32[]) public accountToOrders;
    mapping (bytes32 => bool) public cancelledOrders;

    // per day
    mapping (uint => mapping(address => uint)) public deposits;
    mapping (uint => mapping(address => uint)) public withdrawals;
    mapping (uint => mapping(address => uint)) public profits;
    mapping (uint => mapping(address => uint)) public losses;

    mapping (uint => mapping(address => uint)) public reserves;
    mapping (address => uint) public lastReserveRuns;

    mapping (address => mapping(address => uint)) public surplus;

    mapping (bytes32 => CumulativeRun) public orderToCumulative;

    struct CumulativeRun {
        uint timestamp;
        uint value;
    }

    modifier onlyAdmin() {
        require(config.isAdminValid(msg.sender), "Reserve::_ INVALID_ADMIN_ACCOUNT");
        _;
    }

    event LogOrderCreated(
        bytes32 indexed orderHash,
        address indexed account,
        address indexed token,
        address byUser,
        uint value,
        uint expirationTimestamp
    );

    event LogOrderCancelled(
        bytes32 indexed orderHash,
        address indexed by
    );

    event LogReserveValuesUpdated(
        address indexed token, 
        uint indexed updatedTill,
        uint reserve,
        uint profit,
        uint loss
    );

    event LogOrderCumulativeUpdated(
        bytes32 indexed orderHash,
        uint updatedTill,
        uint value
    );

    event LogRelease(
        address indexed token,
        address indexed to,
        uint value,
        address by
    );

    event LogLock(
        address indexed token,
        address indexed from,
        uint value,
        uint profit,
        uint loss,
        address by
    );

    event LogLockSurplus(
        address indexed forToken, 
        address indexed token,
        address from,
        uint value
    );

    event LogTransferSurplus(
        address indexed forToken,
        address indexed token,
        address to, 
        uint value
    );
    
    function createOrder
    (
        address[3] _orderAddresses,
        uint[3] _orderValues,
        bytes _signature
    ) 
        public
        note
        onlyAdmin
        whenNotStopped
    {
        Order memory order = _composeOrder(_orderAddresses, _orderValues);
        address signer = _recoverSigner(order.orderHash, _signature);

        if(signer != order.byUser){
            emit LogErrorWithHintBytes32(order.orderHash, "Reserve::createOrder", "SIGNER_NOT_ORDER_CREATOR");
            return;
        }
        
        if(isOrder[order.orderHash]){
            emit LogErrorWithHintBytes32(order.orderHash, "Reserve::createOrder", "ORDER_ALREADY_EXISTS");
            return;
        }

        if(!accountFactory.isAccount(order.account)){
            emit LogErrorWithHintBytes32(order.orderHash, "Reserve::createOrder", "INVALID_ORDER_ACCOUNT");
            return;
        }

        if(!Account(order.account).isUser(signer)){
            emit LogErrorWithHintBytes32(order.orderHash, "Reserve::createOrder", "SIGNER_NOT_AUTHORIZED_WITH_ACCOUNT");
            return;
        }
                
        if(!_isOrderValid(order)) {
            emit LogErrorWithHintBytes32(order.orderHash, "Reserve::createOrder", "INVALID_ORDER_PARAMETERS");
            return;
        }

        if(ERC20(order.token).balanceOf(order.account) < order.value){
            emit LogErrorWithHintBytes32(order.orderHash, "Reserve::createOrder", "INSUFFICIENT_BALANCE_IN_ACCOUNT");
            return;
        }

        escrow.transferFromAccount(order.account, order.token, address(escrow), order.value);
        
        orders.push(order.orderHash);
        hashToOrder[order.orderHash] = order;
        isOrder[order.orderHash] = true;
        accountToOrders[order.account].push(order.orderHash);

        uint dateTimestamp = _getDateTimestamp(now);

        deposits[dateTimestamp][order.token] = add(deposits[dateTimestamp][order.token], order.value);
        
        orderToCumulative[order.orderHash].timestamp = _getDateTimestamp(order.createdTimestamp);
        orderToCumulative[order.orderHash].value = order.value;

        emit LogOrderCreated(
            order.orderHash,
            order.account,
            order.token,
            order.byUser,
            order.value,
            order.expirationTimestamp
        );
    }

    function cancelOrder
    (
        bytes32 _orderHash,
        bytes _signature
    )
        external
        note
        onlyAdmin
    {   
        if(!isOrder[_orderHash]) {
            emit LogErrorWithHintBytes32(_orderHash,"Reserve::createOrder", "ORDER_DOES_NOT_EXIST");
            return;
        }

        if(cancelledOrders[_orderHash]){
            emit LogErrorWithHintBytes32(_orderHash,"Reserve::createOrder", "ORDER_ALREADY_CANCELLED");
            return;
        }

        Order memory order = hashToOrder[_orderHash];

        bytes32 cancelOrderHash = _generateActionOrderHash(_orderHash, "CANCEL_RESERVE_ORDER");
        address signer = _recoverSigner(cancelOrderHash, _signature);
        
        if(!Account(order.account).isUser(signer)){
            emit LogErrorWithHintBytes32(_orderHash,"Reserve::createOrder", "SIGNER_NOT_AUTHORIZED_WITH_ACCOUNT");
            return;
        }
        
        doCancelOrder(order);
    }
    
    function processOrder
    (
        bytes32 _orderHash
    ) 
        external 
        note
        onlyAdmin
    {
        if(!isOrder[_orderHash]) {
            emit LogErrorWithHintBytes32(_orderHash,"Reserve::processOrder", "ORDER_DOES_NOT_EXIST");
            return;
        }

        if(cancelledOrders[_orderHash]){
            emit LogErrorWithHintBytes32(_orderHash,"Reserve::processOrder", "ORDER_ALREADY_CANCELLED");
            return;
        }

        Order memory order = hashToOrder[_orderHash];

        if(now > _getDateTimestamp(order.expirationTimestamp)) {
            doCancelOrder(order);
        } else {
            emit LogErrorWithHintBytes32(order.orderHash, "Reserve::processOrder", "ORDER_NOT_EXPIRED");
        }
    }

    function doCancelOrder(Order _order) 
        internal
    {   
        uint valueToTransfer = orderToCumulative[_order.orderHash].value;

        if(ERC20(_order.token).balanceOf(escrow) < valueToTransfer){
            emit LogErrorWithHintBytes32(_order.orderHash, "Reserve::doCancel", "INSUFFICIENT_BALANCE_IN_ESCROW");
            return;
        }

        uint nowDateTimestamp = _getDateTimestamp(now);
        cancelledOrders[_order.orderHash] = true;
        withdrawals[nowDateTimestamp][_order.token] = add(withdrawals[nowDateTimestamp][_order.token], valueToTransfer);

        escrow.transfer(_order.token, _order.account, valueToTransfer);
        emit LogOrderCancelled(_order.orderHash, msg.sender);
    }

    function release(address _token, address _to, uint _value) 
        external
        note
        auth
    {   
        require(ERC20(_token).balanceOf(escrow) >= _value, "Reserve::release INSUFFICIENT_BALANCE_IN_ESCROW");
        escrow.transfer(_token, _to, _value);
        emit LogRelease(_token, _to, _value, msg.sender);
    }

    // _value includes profit/loss as well
    function lock(address _token, address _from, uint _value, uint _profit, uint _loss)
        external
        note
        auth
    {   
        require(!(_profit == 0 && _loss == 0), "Reserve::lock INVALID_PROFIT_LOSS_VALUES");
        require(ERC20(_token).balanceOf(_from) >= _value, "Reserve::lock INSUFFICIENT_BALANCE");
            
        if(accountFactory.isAccount(_from)) {
            escrow.transferFromAccount(_from, _token, address(escrow), _value);
        } else {
            Escrow(_from).transfer(_token, address(escrow), _value);
        }
        
        uint dateTimestamp = _getDateTimestamp(now);

        if (_profit > 0){
            profits[dateTimestamp][_token] = add(profits[dateTimestamp][_token], _profit);
        } else if (_loss > 0) {
            losses[dateTimestamp][_token] = add(losses[dateTimestamp][_token], _loss);
        }

        emit LogLock(_token, _from, _value, _profit, _loss, msg.sender);
    }

    // to lock collateral if cannot be liquidated e.g. not enough reserves in kyber
    function lockSurplus(address _from, address _forToken, address _token, uint _value) 
        external
        note
        auth
    {
        require(ERC20(_token).balanceOf(_from) >= _value, "Reserve::lockSurplus INSUFFICIENT_BALANCE_IN_ESCROW");

        Escrow(_from).transfer(_token, address(escrow), _value);
        surplus[_forToken][_token] = add(surplus[_forToken][_token], _value);

        emit LogLockSurplus(_forToken, _token, _from, _value);
    }

    // to transfer surplus collateral out of the system to trade on other platforms and put back in terms of 
    // principal to reserve manually using an account or surplus escrow
    // should work in tandem with lock method when transferring back principal
    function transferSurplus(address _to, address _forToken, address _token, uint _value) 
        external
        note
        auth
    {
        require(ERC20(_token).balanceOf(escrow) >= _value, "Reserve::transferSurplus INSUFFICIENT_BALANCE_IN_ESCROW");
        require(surplus[_forToken][_token] >= _value, "Reserve::transferSurplus INSUFFICIENT_SURPLUS");

        surplus[_forToken][_token] = sub(surplus[_forToken][_token], _value);
        escrow.transfer(_token, _to, _value);

        emit LogTransferSurplus(_forToken, _token, _to, _value);
    }

    function updateReserveValues(address _token, uint _forDays)
        public
        note
        onlyAdmin
    {   
        uint lastReserveRun = lastReserveRuns[_token];

        if (lastReserveRun == 0) {
            lastReserveRun = _getDateTimestamp(deployTimestamp) - TIME_INTERVAL;
        }

        uint nowDateTimestamp = _getDateTimestamp(now);
        uint updatesLeft = ((nowDateTimestamp - TIME_INTERVAL) - lastReserveRun) / TIME_INTERVAL;

        if(updatesLeft == 0) {
            emit LogErrorWithHintAddress(_token, "Reserve::updateReserveValues", "RESERVE_VALUES_UP_TO_DATE");
            return;
        }

        uint counter = updatesLeft;

        if(updatesLeft > _forDays && _forDays > 0) {
            counter = _forDays;
        }

        for (uint i = 0; i < counter; i++) {
            reserves[lastReserveRun + TIME_INTERVAL][_token] = sub(
                sub(
                    add(
                        add(
                            reserves[lastReserveRun][_token],
                            deposits[lastReserveRun + TIME_INTERVAL][_token]
                        ),
                        profits[lastReserveRun + TIME_INTERVAL][_token]
                    ),
                    losses[lastReserveRun + TIME_INTERVAL][_token]
                ),
                withdrawals[lastReserveRun + TIME_INTERVAL][_token]
            );
            lastReserveRuns[_token] = lastReserveRun + TIME_INTERVAL;
            lastReserveRun = lastReserveRuns[_token];
            
            emit LogReserveValuesUpdated(
                _token,
                lastReserveRun,
                reserves[lastReserveRun][_token],
                profits[lastReserveRun][_token],
                losses[lastReserveRun][_token]
            );
            
        }
    }

    function updateOrderCumulativeValueBatch(bytes32[] _orderHashes, uint[] _forDays) 
        public
        note
        onlyAdmin
    {   
        if(_orderHashes.length != _forDays.length) {
            emit LogError("Reserve::updateOrderCumulativeValueBatch", "ARGS_ARRAYLENGTH_MISMATCH");
            return;
        }

        for(uint i = 0; i < _orderHashes.length; i++) {
            updateOrderCumulativeValue(_orderHashes[i], _forDays[i]);
        }
    }

    function updateOrderCumulativeValue
    (
        bytes32 _orderHash, 
        uint _forDays
    ) 
        public
        note
        onlyAdmin 
    {
        if(!isOrder[_orderHash]) {
            emit LogErrorWithHintBytes32(_orderHash, "Reserve::updateOrderCumulativeValue", "ORDER_DOES_NOT_EXIST");
            return;
        }

        if(cancelledOrders[_orderHash]) {
            emit LogErrorWithHintBytes32(_orderHash, "Reserve::updateOrderCumulativeValue", "ORDER_ALREADY_CANCELLED");
            return;
        }
        
        Order memory order = hashToOrder[_orderHash];
        CumulativeRun storage cumulativeRun = orderToCumulative[_orderHash];
        
        uint profitsAccrued = 0;
        uint lossesAccrued = 0;
        uint cumulativeValue = 0;
        uint counter = 0;

        uint lastOrderRun = cumulativeRun.timestamp;
        uint nowDateTimestamp = _getDateTimestamp(now);

        uint updatesLeft = ((nowDateTimestamp - TIME_INTERVAL) - lastOrderRun) / TIME_INTERVAL;

        if(updatesLeft == 0) {
            emit LogErrorWithHintBytes32(_orderHash, "Reserve::updateOrderCumulativeValue", "ORDER_VALUES_UP_TO_DATE");
            return;
        }

        counter = updatesLeft;

        if(updatesLeft > _forDays && _forDays > 0) {
            counter = _forDays;
        }

        for (uint i = 0; i < counter; i++){
            cumulativeValue = cumulativeRun.value;
            lastOrderRun = cumulativeRun.timestamp;

            if(lastReserveRuns[order.token] < lastOrderRun) {
                emit LogErrorWithHintBytes32(_orderHash, "Reserve::updateOrderCumulativeValue", "RESERVE_VALUES_NOT_UPDATED");
                emit LogOrderCumulativeUpdated(_orderHash, cumulativeRun.timestamp, cumulativeRun.value);
                return;
            }

            profitsAccrued = div(
                mul(profits[lastOrderRun + TIME_INTERVAL][order.token], cumulativeValue),
                reserves[lastOrderRun][order.token]
            );
                
            lossesAccrued = div(
                mul(losses[lastOrderRun + TIME_INTERVAL][order.token], cumulativeValue),
                reserves[lastOrderRun][order.token]
            );

            cumulativeValue = sub(add(cumulativeValue, profitsAccrued), lossesAccrued);

            cumulativeRun.timestamp = lastOrderRun + TIME_INTERVAL;
            cumulativeRun.value = cumulativeValue;
        }
        
        emit LogOrderCumulativeUpdated(_orderHash, cumulativeRun.timestamp, cumulativeRun.value);
    }

    function getAllOrders() 
        public
        view 
        returns 
        (
            bytes32[]
        ) 
    {
        return orders;
    }

    function getOrdersForAccount(address _account) 
        public
        view 
        returns 
        (
            bytes32[]
        )
    {
        return accountToOrders[_account];
    }

    function getOrder(bytes32 _orderHash)
        public 
        view 
        returns 
        (
            address _account,
            address _token,
            address _byUser,
            uint _value,
            uint _expirationTimestamp,
            uint _salt,
            uint _createdTimestamp
        )
    {   
        Order memory order = hashToOrder[_orderHash];
        return (
            order.account,
            order.token,
            order.byUser,
            order.value,
            order.expirationTimestamp,
            order.salt,
            order.createdTimestamp
        );
    }

    function _isOrderValid(Order _order)
        internal
        view
        returns (bool)
    {
        if(_order.account == address(0) || _order.byUser == address(0)
         || _order.value <= 0
         || _order.expirationTimestamp <= _order.createdTimestamp || _order.salt <= 0) {
            return false;
        }

        if(isOrder[_order.orderHash]) {
            return false;
        }

        if(cancelledOrders[_order.orderHash]) {
            return false;
        }

        return true;
    }

    function _composeOrder(address[3] _orderAddresses, uint[3] _orderValues)
        internal
        view
        returns (Order _order)
    {
        Order memory order = Order({
            account: _orderAddresses[0],
            token: _orderAddresses[1],
            byUser: _orderAddresses[2],
            value: _orderValues[0],
            createdTimestamp: now,
            duration: _orderValues[1],
            expirationTimestamp: add(now, _orderValues[1]),
            salt: _orderValues[2],
            orderHash: bytes32(0)
        });

        order.orderHash = _generateCreateOrderHash(order);

        return order;
    }

    function _generateCreateOrderHash(Order _order)
        internal
        pure //view
        returns (bytes32 _orderHash)
    {
        return keccak256(
            abi.encodePacked(
 //              address(this),
                _order.account,
                _order.token,
                _order.value,
                _order.duration,
                _order.salt
            )
        );
    }

    function _generateActionOrderHash
    (
        bytes32 _orderHash,
        string _action
    )
        internal
        pure //view
        returns (bytes32 _repayOrderHash)
    {
        return keccak256(
            abi.encodePacked(
//                address(this),
                _orderHash,
                _action
            )
        );
    }

    function _getDateTimestamp(uint _timestamp) 
        internal
        view
        returns (uint)
    {
        // 1 day
        return dateTime.toTimestamp(dateTime.getYear(_timestamp), dateTime.getMonth(_timestamp), dateTime.getDay(_timestamp));
        // 1 hour
        //return dateTime.toTimestamp(dateTime.getYear(_timestamp), dateTime.getMonth(_timestamp), dateTime.getDay(_timestamp), dateTime.getHour(_timestamp));
    } 

}
interface ExchangeConnector {

    function tradeWithInputFixed
    (   
        Escrow _escrow,
        address _srcToken,
        address _destToken,
        uint _srcTokenValue
    )
        external
        returns (uint _destTokenValue, uint _srcTokenValueLeft);

    function tradeWithOutputFixed
    (   
        Escrow _escrow,
        address _srcToken,
        address _destToken,
        uint _srcTokenValue,
        uint _maxDestTokenValue
    )
        external
        returns (uint _destTokenValue, uint _srcTokenValueLeft);
    

    function getExpectedRate(address _srcToken, address _destToken, uint _srcTokenValue) 
        external
        view
        returns(uint _expectedRate, uint _slippageRate);
    
    function isTradeFeasible(address _srcToken, address _destToken, uint _srcTokenValue) 
        external
        view
        returns(bool);

}


contract MKernel is DSStop, DSThing, Utils, Utils2, ErrorUtils {
    
    Escrow public escrow;
    AccountFactory public accountFactory;
    Reserve public reserve;
    address public feeWallet;
    Config public config;
    
    constructor
    (
        Escrow _escrow,
        AccountFactory _accountFactory,
        Reserve _reserve,
        address _feeWallet,
        Config _config
    ) 
    public 
    {
        escrow = _escrow;
        accountFactory = _accountFactory;
        reserve = _reserve;
        feeWallet = _feeWallet;
        config = _config;
    }

    function setEscrow(Escrow _escrow) 
        public 
        note 
        auth
        addressValid(_escrow)
    {
        escrow = _escrow;
    }

    function setAccountFactory(AccountFactory _accountFactory)
        public 
        note 
        auth
        addressValid(_accountFactory)
    {
        accountFactory = _accountFactory;
    }

    function setReserve(Reserve _reserve)
        public 
        note 
        auth
        addressValid(_reserve)
    {
        reserve = _reserve;
    }

    function setConfig(Config _config)
        public 
        note 
        auth
        addressValid(_config)
    {
        config = _config;
    }

    function setFeeWallet(address _feeWallet)
        public 
        note 
        auth
        addressValid(_feeWallet)
    {
        feeWallet = _feeWallet;
    }
    
    event LogOrderCreated(
        bytes32 indexed orderHash,
        uint tradeAmount,
        uint expirationTimestamp
    );

    event LogOrderLiquidatedByUser(
        bytes32 indexed orderHash
    );

    event LogOrderStoppedAtProfit(
        bytes32 indexed orderHash
    );

    event LogOrderDefaulted(
        bytes32 indexed orderHash,
        string reason
    );

    event LogNoActionPerformed(
        bytes32 indexed orderHash
    );

    event LogOrderSettlement(
        bytes32 indexed orderHash,
        uint valueRepaid,
        uint reserveProfit,
        uint reserveLoss,
        uint collateralLeft,
        uint userProfit,
        uint fee
    );

    struct Order {
        address account;
        address byUser;
        address principalToken; 
        address collateralToken;
        Trade trade;
        uint principalAmount;
        uint collateralAmount;
        uint premium;
        uint expirationTimestamp;
        uint duration;
        uint salt;
        uint fee;
        uint createdTimestamp;
        bytes32 orderHash;
    }

    struct Trade {
        address tradeToken;
        address closingToken;
        address exchangeConnector; //stores initial and then just used to pass around params
        uint stopProfit;
        uint stopLoss;
    }

    bytes32[] public orders;
    mapping (bytes32 => Order) public hashToOrder;
    mapping (bytes32 => bool) public isOrder;
    mapping (address => bytes32[]) public accountToOrders;

    mapping (bytes32 => uint) public initialTradeAmount;
    mapping (bytes32 => bool) public isLiquidated;
    mapping (bytes32 => bool) public isDefaulted;

    modifier onlyAdmin() {
        require(config.isAdminValid(msg.sender), "MKernel::_ INVALID_ADMIN_ACCOUNT");
        _;
    }


    function createOrder
    (
        address[6] _orderAddresses,
        uint[8] _orderValues,
        address _exchangeConnector,
        bytes _signature
    )    
        external
        note
        onlyAdmin
        whenNotStopped
        addressValid(_exchangeConnector)
    {
        Order memory order = _composeOrder(_orderAddresses, _orderValues);
        address signer = _recoverSigner(order.orderHash, _signature);
        order.trade.exchangeConnector = _exchangeConnector;

        if(signer != order.byUser) {
            emit LogErrorWithHintBytes32(order.orderHash, "MKernel::createOrder","SIGNER_NOT_ORDER_CREATOR");
            return;
        }

        if(isOrder[order.orderHash]){
            emit LogErrorWithHintBytes32(order.orderHash, "MKernel::createOrder","ORDER_ALREADY_EXISTS");
            return;
        }

        if(!accountFactory.isAccount(order.account)){
            emit LogErrorWithHintBytes32(order.orderHash, "MKernel::createOrder","INVALID_ORDER_ACCOUNT");
            return;
        }

        if(!Account(order.account).isUser(signer)) {
            emit LogErrorWithHintBytes32(order.orderHash, "MKernel::createOrder","SIGNER_NOT_AUTHORIZED_WITH_ACCOUNT");
            return;
        }

        if(!_isOrderValid(order)){
            emit LogErrorWithHintBytes32(order.orderHash, "MKernel::createOrder","INVALID_ORDER_PARAMETERS");
            return;
        }

        if(ERC20(order.collateralToken).balanceOf(order.account) < order.collateralAmount){
            emit LogErrorWithHintBytes32(order.orderHash, "MKernel::createOrder","INSUFFICIENT_COLLATERAL_IN_ACCOUNT");
            return;
        }

        if(ERC20(order.principalToken).balanceOf(reserve.escrow()) < order.principalAmount){
            emit LogErrorWithHintBytes32(order.orderHash, "MKernel::createOrder","INSUFFICIENT_FUNDS_IN_RESERVE");
            return;
        }

        if(!_isTradeFeasible(order, order.principalToken, order.trade.tradeToken, order.principalAmount))
        {
            emit LogErrorWithHintBytes32(order.orderHash, "MKernel::createOrder","TRADE_NOT_FEASIBLE");
            return;
        }        

        
        orders.push(order.orderHash);
        hashToOrder[order.orderHash] = order;
        isOrder[order.orderHash] = true;
        accountToOrders[order.account].push(order.orderHash);

        escrow.transferFromAccount(order.account, order.collateralToken, address(escrow), order.collateralAmount);
        reserve.release(order.principalToken, address(escrow), order.principalAmount);
    
        (initialTradeAmount[order.orderHash],) = _tradeWithFixedInput(
            order,
            ERC20(order.principalToken),
            ERC20(order.trade.tradeToken),
            order.principalAmount
        );

        emit LogOrderCreated(
            order.orderHash,
            initialTradeAmount[order.orderHash],
            order.expirationTimestamp
        );
        

    }

    function liquidateOrder
    (
        bytes32 _orderHash,
        address _exchangeConnector,
        bytes _signature
    ) 
        external
        note
        onlyAdmin
        addressValid(_exchangeConnector)
    {
        if(!isOrder[_orderHash]){
            emit LogErrorWithHintBytes32(_orderHash, "MKernel::liquidateOrder","ORDER_DOES_NOT_EXIST");
            return;
        }
        
        if(isLiquidated[_orderHash]){
            emit LogErrorWithHintBytes32(_orderHash, "MKernel::liquidateOrder","ORDER_ALREADY_LIQUIDATED");
            return;
        }

        if(isDefaulted[_orderHash]){
            emit LogErrorWithHintBytes32(_orderHash, "MKernel::liquidateOrder","ORDER_ALREADY_DEFAULTED");
            return;
        }

        bytes32 liquidateOrderHash = _generateLiquidateOrderHash(_orderHash);
        address signer = _recoverSigner(liquidateOrderHash, _signature);

        Order memory order = hashToOrder[_orderHash];
        order.trade.exchangeConnector = _exchangeConnector;
        
        if(!Account(order.account).isUser(signer)){
            emit LogErrorWithHintBytes32(_orderHash, "MKernel::liquidateOrder", "SIGNER_NOT_AUTHORIZED_WITH_ACCOUNT");
            return;
        }

        if(ERC20(order.trade.tradeToken).balanceOf(address(escrow)) < initialTradeAmount[_orderHash]){
            emit LogErrorWithHintBytes32(_orderHash, "MKernel::liquidateOrder", "INSUFFICIENT_TRADE_BALANCE_IN_ESCROW");
            return;
        }

        if(ERC20(order.collateralToken).balanceOf(address(escrow)) < order.collateralAmount){
            emit LogErrorWithHintBytes32(_orderHash, "MKernel::liquidateOrder", "INSUFFICIENT_COLLATERAL_BALANCE_IN_ESCROW");
            return;
        }

        isLiquidated[order.orderHash] = true;
        _performOrderLiquidation(order);

        emit LogOrderLiquidatedByUser(_orderHash);
    }

    function processTradeForExpiry
    (
        bytes32 _orderHash,
        address _exchangeConnector
    )
        external
        note
        onlyAdmin
        addressValid(_exchangeConnector)
    {
        if(!isOrder[_orderHash]){
            emit LogErrorWithHintBytes32(_orderHash, "MKernel::processTradeForExpiry","ORDER_DOES_NOT_EXIST");
            return;
        }

        if(isLiquidated[_orderHash]){
            emit LogErrorWithHintBytes32(_orderHash, "MKernel::processTradeForExpiry","ORDER_ALREADY_LIQUIDATED");
            return;
        }

        if(isDefaulted[_orderHash]){
            emit LogErrorWithHintBytes32(_orderHash, "MKernel::processTradeForExpiry","ORDER_ALREADY_DEFAULTED");
            return;
        }
        

        Order memory order = hashToOrder[_orderHash];
        order.trade.exchangeConnector = _exchangeConnector;

        if(ERC20(order.trade.tradeToken).balanceOf(address(escrow)) < initialTradeAmount[_orderHash]){
            emit LogErrorWithHintBytes32(_orderHash, "MKernel::processTradeForExpiry", "INSUFFICIENT_TRADE_BALANCE_IN_ESCROW");
            return;
        }

        if(ERC20(order.collateralToken).balanceOf(address(escrow)) < order.collateralAmount){
            emit LogErrorWithHintBytes32(_orderHash, "MKernel::processTradeForExpiry", "INSUFFICIENT_COLLATERAL_BALANCE_IN_ESCROW");
            return;
        }

        if(now > order.expirationTimestamp) {
            isDefaulted[order.orderHash] = true;
            _performOrderLiquidation(order);
            emit LogOrderDefaulted(order.orderHash, "MKERNEL_DUE_DATE_PASSED");
            return;
        }

        emit LogErrorWithHintBytes32(order.orderHash, "MKernel::processTradeForExpiry", "NO_ACTION_PERFORMED");
    }


    function processTradeForStopLoss
    (
        bytes32 _orderHash,
        address _exchangeConnector,
        uint[2] _tokenPrices,
        uint _bufferInPrincipal
    )
        external
        note
        onlyAdmin
        addressValid(_exchangeConnector)
    {   
        if(!isOrder[_orderHash]){
            emit LogErrorWithHintBytes32(_orderHash, "MKernel::processTradeForStopLoss","ORDER_DOES_NOT_EXIST");
            return;
        }

        if(isLiquidated[_orderHash]){
            emit LogErrorWithHintBytes32(_orderHash, "MKernel::processTradeForStopLoss","ORDER_ALREADY_LIQUIDATED");
            return;
        }

        if(isDefaulted[_orderHash]){
            emit LogErrorWithHintBytes32(_orderHash, "MKernel::processTradeForStopLoss","ORDER_ALREADY_DEFAULTED");
            return;
        }

        Order memory order = hashToOrder[_orderHash];
        order.trade.exchangeConnector = _exchangeConnector;

        if(ERC20(order.trade.tradeToken).balanceOf(address(escrow)) < initialTradeAmount[_orderHash]){
            emit LogErrorWithHintBytes32(_orderHash, "MKernel::processTradeForStopLoss", "INSUFFICIENT_TRADE_BALANCE_IN_ESCROW");
            return;
        }

        if(ERC20(order.collateralToken).balanceOf(address(escrow)) < order.collateralAmount){
            emit LogErrorWithHintBytes32(_orderHash, "MKernel::processTradeForStopLoss", "INSUFFICIENT_COLLATERAL_BALANCE_IN_ESCROW");
            return;
        }

        if(!_isPositionAboveStopLoss(order, _tokenPrices, _bufferInPrincipal)) {
            isDefaulted[order.orderHash] = true;
            _performOrderLiquidation(order);
            emit LogOrderDefaulted(order.orderHash, "MKERNEL_ORDER_UNSAFE");
            return;
        }

        emit LogErrorWithHintBytes32(order.orderHash, "MKernel::processTradeForStopLoss", "NO_ACTION_PERFORMED");
    }

    function processTradeForStopProfit
    (
        bytes32 _orderHash,
        address _exchangeConnector,
        uint[2] _tokenPrices,
        uint _bufferInPrincipal
    )
        external
        note
        onlyAdmin
        addressValid(_exchangeConnector)
    {   
        if(!isOrder[_orderHash]){
            emit LogErrorWithHintBytes32(_orderHash, "MKernel::processTradeForStopProfit","ORDER_DOES_NOT_EXIST");
            return;
        }

        if(isLiquidated[_orderHash]){
            emit LogErrorWithHintBytes32(_orderHash, "MKernel::processTradeForStopProfit","ORDER_ALREADY_LIQUIDATED");
            return;
        }

        if(isDefaulted[_orderHash]){
            emit LogErrorWithHintBytes32(_orderHash, "MKernel::processTradeForStopProfit","ORDER_ALREADY_DEFAULTED");
            return;
        }

        Order memory order = hashToOrder[_orderHash];
        order.trade.exchangeConnector = _exchangeConnector;

        if(ERC20(order.trade.tradeToken).balanceOf(address(escrow)) < initialTradeAmount[_orderHash]){
            emit LogErrorWithHintBytes32(_orderHash, "MKernel::processTradeForStopProfit", "INSUFFICIENT_TRADE_BALANCE_IN_ESCROW");
            return;
        }

        if(ERC20(order.collateralToken).balanceOf(address(escrow)) < order.collateralAmount){
            emit LogErrorWithHintBytes32(_orderHash, "MKernel::processTradeForStopProfit", "INSUFFICIENT_COLLATERAL_BALANCE_IN_ESCROW");
            return;
        }
        
        if(_isPositionAboveStopProfit(order, _tokenPrices, _bufferInPrincipal)) {
            isLiquidated[order.orderHash] = true;
            _performOrderLiquidation(order);
            emit LogOrderStoppedAtProfit(order.orderHash);
            return;
        }

        emit LogErrorWithHintBytes32(order.orderHash, "MKernel::processTradeForStopProfit", "NO_ACTION_PERFORMED");
    }

    function _performOrderLiquidation(Order _order) 
        internal
    {   
        uint tradeAmount = initialTradeAmount[_order.orderHash];
        uint valueToRepay = add(_order.principalAmount, _order.premium);
        uint valueToRepayWithFee = add(valueToRepay, _order.fee);
    
        uint principalFromTrade = 0;
        uint principalFromCollateral = 0;
        uint principalNeededFromCollateral = 0;
        uint collateralLeft = 0;
        uint userProfit = 0;
        uint totalPrincipalAcquired = 0;
        uint orderFee = 0;
        

        
            (principalFromTrade,) = _tradeWithFixedInput(_order, _order.trade.tradeToken, _order.principalToken, tradeAmount);

            if(principalFromTrade >= valueToRepayWithFee) {
                userProfit = sub(principalFromTrade, valueToRepayWithFee);
                orderFee = _order.fee;
                _performSettlement(_order, valueToRepay, _order.premium, 0, _order.collateralAmount, userProfit, orderFee);
            } else {

                principalNeededFromCollateral = sub(valueToRepayWithFee, principalFromTrade);

                if (_order.collateralToken == _order.principalToken) {
                    principalFromCollateral = principalNeededFromCollateral;

                    if(_order.collateralAmount >= principalNeededFromCollateral) {
                        collateralLeft = sub(_order.collateralAmount, principalNeededFromCollateral);
                    }

                } else {
                    (principalFromCollateral, collateralLeft) = _tradeWithFixedOutput(_order, _order.collateralToken, _order.principalToken, _order.collateralAmount, principalNeededFromCollateral);    
                }

                if(principalFromCollateral >= principalNeededFromCollateral) {
                    orderFee = _order.fee;
                    _performSettlement(_order, valueToRepay, _order.premium, 0, collateralLeft, 0, orderFee);
                } else {
                    totalPrincipalAcquired = add(principalFromTrade, principalFromCollateral);
                    _performSettlementAfterAllPossibleLiquidations(_order, totalPrincipalAcquired);
                }
            }
                       
    }

    function _tradeWithFixedInput(Order _order, address _srcToken, address _destToken, uint _srcTokenValue)
        internal
        returns (uint _destTokenValue, uint _srcTokenValueLeft)
    {
        ExchangeConnector exchangeConnector = ExchangeConnector(_order.trade.exchangeConnector);
        return exchangeConnector.tradeWithInputFixed(
                    escrow,
                    _srcToken,
                    _destToken,
                    _srcTokenValue
        );
    }

    function _tradeWithFixedOutput(Order _order, address _srcToken, address _destToken, uint _srcTokenValue, uint _maxDestTokenValue)
        internal
        returns (uint _destTokenValue, uint _srcTokenValueLeft)
    {
        ExchangeConnector exchangeConnector = ExchangeConnector(_order.trade.exchangeConnector);
        return exchangeConnector.tradeWithOutputFixed(
                    escrow,
                    _srcToken,
                    _destToken,
                    _srcTokenValue,
                    _maxDestTokenValue
        );
    }

    function _isTradeFeasible(Order _order, address _srcToken, address _destToken, uint _srcTokenValue)
        internal
        view
        returns (bool)
    {   
        ExchangeConnector exchangeConnector = ExchangeConnector(_order.trade.exchangeConnector);
        return exchangeConnector.isTradeFeasible(_srcToken, _destToken, _srcTokenValue);
    }

    function _performSettlementAfterAllPossibleLiquidations
    (
        Order _order,
        uint _totalPrincipalAcquired
    )
        internal
    {
        uint valueToRepay = add(_order.principalAmount, _order.premium);

        if(_totalPrincipalAcquired >= valueToRepay) {
            _performSettlement(_order, valueToRepay, _order.premium, 0, 0, 0, sub(_totalPrincipalAcquired, valueToRepay));
        } else if((_totalPrincipalAcquired < valueToRepay) && (_totalPrincipalAcquired >= _order.principalAmount)) {
            _performSettlement(_order, _totalPrincipalAcquired, sub(_totalPrincipalAcquired, _order.principalAmount), 0, 0, 0, 0);
        } else {
            _performSettlement(_order, _totalPrincipalAcquired, 0, sub(_order.principalAmount, _totalPrincipalAcquired), 0, 0, 0);
        }

    }

    function _performSettlement
    (
        Order _order,
        uint _valueRepaid,
        uint _reserveProfit,
        uint _reserveLoss,
        uint _collateralLeft,
        uint _userProfit,
        uint _fee
    ) 
        internal 
    {
        uint closingFromPrincipal = 0;
        uint userEarnings = _userProfit;

        if(_fee > 0){
            escrow.transfer(_order.principalToken, feeWallet, _fee);
        }
        
        reserve.lock(_order.principalToken, escrow, _valueRepaid, _reserveProfit, _reserveLoss);
        
        if(_collateralLeft > 0) {
            escrow.transfer(_order.collateralToken, _order.account, _collateralLeft);    
        }

        if(_userProfit > 0) {
            if(_order.trade.closingToken == _order.principalToken || !_isTradeFeasible(_order, _order.principalToken, _order.trade.closingToken, _userProfit)) {
                escrow.transfer(_order.principalToken, _order.account, _userProfit);
            } else {
                (closingFromPrincipal,) = _tradeWithFixedInput(_order, _order.principalToken, _order.trade.closingToken, _userProfit);
                escrow.transfer(_order.trade.closingToken, _order.account, closingFromPrincipal);
                userEarnings = closingFromPrincipal;
            }
        }

        emit LogOrderSettlement(_order.orderHash, _valueRepaid, _reserveProfit, _reserveLoss, _collateralLeft, userEarnings, _fee);
    }

    function _isPositionAboveStopLoss(Order _order, uint[2] _tokenPrices, uint _bufferInPrincipal)
        internal 
        view
        returns (bool)
    {
        uint principalPerCollateral = _tokenPrices[0]; 
        uint principalPerTrade = _tokenPrices[1];
        uint tradeAmount = initialTradeAmount[_order.orderHash];

        uint valueToRepayWithFee = add(add(_order.principalAmount, _order.premium), _order.fee);
        uint totalCollateralValueInPrincipal = div(mul(_order.collateralAmount, principalPerCollateral), WAD);
        uint totalTradeValueInPrincipal = div(mul(tradeAmount, principalPerTrade), WAD);

        uint bufferValue = div(mul(_order.principalAmount, _bufferInPrincipal), WAD);
        uint minValueReq = div(mul(_order.trade.stopLoss, totalCollateralValueInPrincipal), WAD);

        if(add(valueToRepayWithFee, bufferValue) >= totalTradeValueInPrincipal && 
            sub(add(valueToRepayWithFee, bufferValue), totalTradeValueInPrincipal) >= minValueReq) 
        {
            return false;
        }

        return true;
    }

    function _isPositionAboveStopProfit(Order _order, uint[2] _tokenPrices, uint _bufferInPrincipal)
        internal 
        view
        returns (bool)
    {       
        if(_order.trade.stopProfit == 0) {
            return false;
        } else {
            uint principalPerTrade = _tokenPrices[1];
            uint tradeAmount = initialTradeAmount[_order.orderHash];

            uint valueToRepayWithFee = add(add(_order.principalAmount, _order.premium), _order.fee);
            uint totalTradeValueInPrincipal = div(mul(tradeAmount, principalPerTrade), WAD);

            uint stopProfitValue = div(mul(_order.principalAmount, _order.trade.stopProfit), WAD);
            uint bufferValue = div(mul(_order.principalAmount, _bufferInPrincipal), WAD);

            if(totalTradeValueInPrincipal >= add(add(valueToRepayWithFee, stopProfitValue), bufferValue)) {
                return true;
            }

            return false;
        }
    }

    function _generateLiquidateOrderHash
    (
        bytes32 _orderHash
    )
        internal
        view
        returns (bytes32 _liquidateOrderHash)
    {
        return keccak256(
            abi.encodePacked(
                address(this),
                _orderHash,
                "CANCEL_MKERNEL_ORDER"
            )
        );
    }

    function _isOrderValid(Order _order)
        internal
        pure
        returns (bool)
    {
        if(_order.account == address(0) || _order.byUser == address(0)
         || _order.principalToken == address(0) || _order.collateralToken == address(0)
         || _order.trade.closingToken == address(0)
         || _order.trade.tradeToken == address(0)
         || (_order.trade.tradeToken == _order.principalToken) || _order.trade.exchangeConnector == address(0)
         || _order.principalAmount == 0 || _order.collateralAmount == 0
         || _order.premium == 0
         || _order.expirationTimestamp <= _order.createdTimestamp || _order.salt == 0) {
            return false;
        }

        return true;
    }

    function _composeOrder
    (
        address[6] _orderAddresses,
        uint[8] _orderValues
    )
        internal
        view
        returns (Order _order)
    {   
        Trade memory trade = _composeTrade(_orderAddresses[4], _orderAddresses[5], _orderValues[6], _orderValues[7]);

        Order memory order = Order({
            account: _orderAddresses[0],
            byUser: _orderAddresses[1],
            principalToken: _orderAddresses[2],
            collateralToken: _orderAddresses[3],
            principalAmount: _orderValues[0],
            collateralAmount: _orderValues[1],
            premium: _orderValues[2],
            duration: _orderValues[3],
            expirationTimestamp: add(now, _orderValues[3]),
            salt: _orderValues[4],
            fee: _orderValues[5],
            createdTimestamp: now,
            orderHash: bytes32(0),
            trade: trade
        });

        order.orderHash = _generateOrderHash(order);
    
        return order;
    }

    function _composeTrade
    (
        address _tradeToken,
        address _closingToken,
        uint _stopProfit,
        uint _stopLoss
    )
        internal 
        pure
        returns (Trade _trade)
    {
        _trade = Trade({
            tradeToken: _tradeToken,
            closingToken: _closingToken,
            stopProfit: _stopProfit,
            stopLoss: _stopLoss,
            exchangeConnector: address(0)
        });
    }

    function _generateOrderHash(Order _order)
        internal
        view
        returns (bytes32 _orderHash)
    {
        return keccak256(
            abi.encodePacked(
                address(this),
                _generateOrderHash1(_order),
                _generateOrderHash2(_order)
            )
        );
    }

    function _generateOrderHash1(Order _order)
        internal
        view
        returns (bytes32 _orderHash1) 
    {
        return keccak256(
            abi.encodePacked(
                address(this),
                _order.account,
                _order.principalToken,
                _order.collateralToken,
                _order.principalAmount,
                _order.collateralAmount,
                _order.premium,
                _order.duration,
                _order.salt,
                _order.fee
            )
        );
    }

    function _generateOrderHash2(Order _order)
        internal
        view
        returns (bytes32 _orderHash2)
    {
        return keccak256(
            abi.encodePacked(
                address(this),
                _order.trade.tradeToken,
                _order.trade.closingToken,
                _order.trade.stopProfit,
                _order.trade.stopLoss,
                _order.salt
            )
        );
    }

    function getAllOrders()
        public 
        view 
        returns 
        (
            bytes32[]
        )
    {
        return orders;
    }

    
    function getOrder(bytes32 _orderHash)
        public 
        view 
        returns 
        (
            address _account,
            address _byUser,
            address _principalToken,
            address _collateralToken,
            uint _principalAmount,
            uint _collateralAmount,
            uint _premium,
            uint _expirationTimestamp,
            uint _salt,
            uint _fee,
            uint _createdTimestamp
        )
    {   
        Order memory order = hashToOrder[_orderHash];
        return (
            order.account,
            order.byUser,
            order.principalToken,
            order.collateralToken,
            order.principalAmount,
            order.collateralAmount,
            order.premium,
            order.expirationTimestamp,
            order.salt,
            order.fee,
            order.createdTimestamp
        );
    }

    function getTrade(bytes32 _orderHash)
        public 
        view 
        returns 
        (
            address _tradeToken,
            address _closingToken,
            address _initExchangeConnector,
            uint _stopProfit,
            uint _stopLoss
        )
    {   
        Order memory order = hashToOrder[_orderHash];
        return (
            order.trade.tradeToken,
            order.trade.closingToken,
            order.trade.exchangeConnector,
            order.trade.stopProfit,
            order.trade.stopLoss
        );
    }

    function getOrdersForAccount(address _account) 
        public
        view 
        returns 
        (
            bytes32[]
        )
    {
        return accountToOrders[_account];
    }

}