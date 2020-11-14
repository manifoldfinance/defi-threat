/**
 * Source Code first verified at https://etherscan.io on Thursday, April 18, 2019
 (UTC) */

pragma solidity >=0.4.22 <0.6.0;

contract GomicsERC20 {

    uint internal maxAdmin;       // 관리자 최대 수 MaxAdmin

    string public name;             // ERC20 = 토큰 이름 name
    string public symbol;           // ERC20 = 토큰 심볼 symbol
    uint8 public decimals;          // ERC20 = 토큰 소숫점 18자리 까지 가능  decimals 18
    uint256 public totalSupply;     // ERC20 = 총 발행 량 totalSupply

    address public owner;           // 소유자 owner

    bool public stopTransfer;       // 일시 거래 중단 기능 stopTransfer

    struct userMap {
        bool black;
        uint256 balanceOf;
    }

    address[] internal adminsnew;   // 신규 관리자 추가 adminsnew
    address[] public admins;        // 관리자 admins

    // 사용자 리스트 public user list
    mapping (address => userMap) public user;

    event StopTransfer(address indexed from, bool value);                                           // 이벤트 - 토큰 전송 중지 StopTransfer
    event UserBlack(address indexed from, address indexed user, bool value);                        // 이벤트 - 블랙 리스트 UserBlack
    event UserAdmin(address indexed from, address indexed user, bool value);                        // 이벤트 - 관리자 리스트 UserAdmin list
    event Transfer(address indexed from, address indexed to, uint256 value);                        // 이벤트 - 토큰 전송 Transfer

    /**
     * 생성자 issuer
     *
     * 초기 토큰에 대한 발행량, 토큰 이름, 토큰 심볼를 초기화 한다. Initialize the amount of issuance, token name, token symbol for the initial token
     */
    constructor(
        address _owner
    ) public {
        maxAdmin                                         = 3;                                       // max admin
        decimals                                         = 8;                                       // 소수 점 decimals
        totalSupply                                      = 75000000 * 10 ** uint256(decimals);      // 총 발행량  totalSupply
        name                                             = 'GOM';                                   // 토큰 이름  name
        symbol                                           = 'GOM';                                   // 토큰 심볼  symbol 

        owner                                            = _owner;                                  // 주인 설정  owner         

        user[_owner]                                     = userMap(false, totalSupply);             // 주인 관리자 owner / 화이트 리스트에 자동 추가 Automatically add to whitelist
        user[0x0101010101010101010101010101010101010101] = userMap(false, 0);                       // 토큰 파기 주소 token revocation address
    }

    modifier requireOwner() { require(owner == msg.sender); _; }                                    // 소유자 권한 owner's rights
    modifier requireAdmin() {                                                                       // 관리자 권한 Administrator rights
        if( owner == msg.sender) {
            require(true);
            _;
        }
        else {
            for(uint i = 0; i < admins.length; i++) {
                require(admins[i] == msg.sender);
                _;
            }
        }

        require(true);
        _;
    }
    modifier requireStopTransfer() { require(!stopTransfer); _; }                                   // 거래 중단 StopTransfer
    modifier requireBlack() { require(!user[msg.sender].black); _; }                                // 거래 거부 requireBlack

    /**
     * modify User admin
     *
     */
    function adminLength() public view requireOwner returns(uint ret) {
        return admins.length;
    }

    /**
     * modify User admin
     *
     * @param _address 주소 address
     * @param _admin 관리자 admin
     */
    function modifyUserAdmin(address _address, bool _admin) public requireOwner {

        require(owner != _address);

        if( _admin ) {
            _addAdmin(_address);
        }
        else{
            _removeAdmin(_address);
        }

        emit UserAdmin(msg.sender, _address, _admin);
    }

    /**
     * modify User black
     *
     * @param _address 주소 address
     * @param _black 블록 black
     */
    function modifyUserBlack(address _address, bool _black) public requireAdmin {
        user[_address].black  = _black;

        emit UserBlack(msg.sender, _address, _black);
    }

    /**
     * modify Stop Transfer
     *
     * @param _stop 비상 중지 여부 Emergency stop status
     */
    function modifyStopTransfer(bool _stop) public requireOwner {
        stopTransfer = _stop;

        emit StopTransfer(msg.sender, _stop);
    }

    /**
     * _addAdmin
     *
     * @param _address 주소 address
     */
    function _addAdmin(address _address) internal {
        
        require(admins.length<=maxAdmin - 1);
        
        for(uint i = 0 ; i < admins.length; i++){
            require(admins[i] != _address);
        }
        
        admins.push(_address);
    }
    
    /**
     * _removeAdmin
     *
     * @param _address 주소 address
     */
    function _removeAdmin(address _address) internal {
        
        for(uint i = 0 ; i < admins.length; i++){
            if( admins[i] != _address ) {
                adminsnew.push(admins[i]);
            }
        }
        
        admins = adminsnew;
        delete adminsnew;
    }

    /**
     * 잔고
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _address The address of the recipient
     */
    function balanceOf(address _address) public view returns (uint256 result) {
        return user[_address].balanceOf;
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal requireStopTransfer {

        require(user[_from].black != true);
        require(user[_to].black != true);

        // Check if the sender has enough
        require(user[_from].balanceOf >= _value);

        // Check for overflows
        require(_add(user[_to].balanceOf, _value) >= user[_to].balanceOf);

        // Save this for an assertion in the future
        uint previousBalances = _add(user[_from].balanceOf, user[_to].balanceOf);

        // Subtract from the sender
        user[_from].balanceOf = _sub(user[_from].balanceOf, _value);

        // Add the same to the recipient
        user[_to].balanceOf = _add(user[_to].balanceOf, _value);

        // 이벤트 발생 Event Occurrence
        emit Transfer(_from, _to, _value);

        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(_add(user[_from].balanceOf, user[_to].balanceOf) == previousBalances);
    }

    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function _mul(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function _div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function _sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function _add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function _mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }
}