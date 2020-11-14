/**
 * Source Code first verified at https://etherscan.io on Thursday, April 25, 2019
 (UTC) */

contract SerializableOrder {
    using SafeMath for uint256;
    using BytesLib for bytes;

    uint constant public ORDER_SIZE = 206;
    uint constant public UNSIGNED_ORDER_SIZE = 141;
    uint8 constant internal _MASK_IS_BUY = 0x01;
    uint8 constant internal _MASK_IS_MAIN = 0x02;

    /**
     * @notice Get user ID from the serialized order data
     * @param ser_data Serialized order data
     * @return userID User ID
     */
    function _getOrderUserID(bytes memory ser_data) internal pure returns (uint256 userID) {
        userID = ser_data.toUint32(ORDER_SIZE - 4);
    }

    /**
     * @notice Get target token ID from the serialized order data
     * @param ser_data Serialized order data
     * @return tokenTarget Target token ID
     */
    function _getOrderTokenIDTarget(bytes memory ser_data) internal pure returns (uint256 tokenTarget) {
        tokenTarget = ser_data.toUint16(ORDER_SIZE - 6);
    }

    /**
     * @notice Get target token amount from the serialized order data
     * @param ser_data Serialized order data
     * @return amountTarget Target token amount
     */
    function _getOrderAmountTarget(bytes memory ser_data) internal pure returns (uint256 amountTarget) {
        amountTarget = ser_data.toUint(ORDER_SIZE - 38);
    }

    /**
     * @notice Get trade token ID from the serialized order data
     * @param ser_data Serialized order data
     * @return tokenTrade Trade token ID
     */
    function _getOrderTokenIDTrade(bytes memory ser_data) internal pure returns (uint256 tokenTrade) {
        tokenTrade = ser_data.toUint16(ORDER_SIZE - 40);
    }

    /**
     * @notice Get trade token amount from the serialized order data
     * @param ser_data Serialized order data
     * @return amountTrade Trade token amount
     */
    function _getOrderAmountTrade(bytes memory ser_data) internal pure returns (uint256 amountTrade) {
        amountTrade = ser_data.toUint(ORDER_SIZE - 72);
    }

    /**
     * @notice Check if the order is a buy order
     * @param ser_data Serialized order data
     * @return fBuy Is buy order or not
     */
    function _isOrderBuy(bytes memory ser_data) internal pure returns (bool fBuy) {
        fBuy = (ser_data.toUint8(ORDER_SIZE - 73) & _MASK_IS_BUY != 0);
    }

    /**
     * @notice Check if the fee is paid by main token
     * @param ser_data Serialized order data
     * @return fMain Is the fee paid in main token or not
     */
    function _isOrderFeeMain(bytes memory ser_data) internal pure returns (bool fMain) {
        fMain = (ser_data.toUint8(ORDER_SIZE - 73) & _MASK_IS_MAIN != 0);
    }

    /**
     * @notice Get nonce from the serialized order data
     * @param ser_data Serialized order data
     * @return nonce Nonce
     */
    function _getOrderNonce(bytes memory ser_data) internal pure returns (uint256 nonce) {
        nonce = ser_data.toUint32(ORDER_SIZE - 77);
    }

    /**
     * @notice Get trading fee from the serialized order data
     * @param ser_data Serialized order data
     * @return fee Fee amount
     */
    function _getOrderTradeFee(bytes memory ser_data) internal pure returns (uint256 tradeFee) {
        tradeFee = ser_data.toUint(ORDER_SIZE - 109);
    }

    /**
     * @notice Get gas fee from the serialized order data
     * @param ser_data Serialized order data
     * @return fee Fee amount
     */
    function _getOrderGasFee(bytes memory ser_data) internal pure returns (uint256 gasFee) {
        gasFee = ser_data.toUint(ORDER_SIZE - 141);
    }

    /**
     * @notice Get v from the serialized order data
     * @param ser_data Serialized order data
     * @return v Signature v
     */
    function _getOrderV(bytes memory ser_data) internal pure returns (uint8 v) {
        v = ser_data.toUint8(ORDER_SIZE - 142);
    }

    /**
     * @notice Get r from the serialized order data
     * @param ser_data Serialized order data
     * @return r Signature r
     */
    function _getOrderR(bytes memory ser_data) internal pure returns (bytes32 r) {
        r = ser_data.toBytes32(ORDER_SIZE - 174);
    }

    /**
     * @notice Get s from the serialized order data
     * @param ser_data Serialized order data
     * @return s Signature s
     */
    function _getOrderS(bytes memory ser_data) internal pure returns (bytes32 s) {
        s = ser_data.toBytes32(ORDER_SIZE - 206);
    }

    /**
     * @notice Get hash from the serialized order data
     * @param ser_data Serialized order data
     * @return hash Order hash without signature
     */
    function _getOrderHash(bytes memory ser_data) internal pure returns (bytes32 hash) {
        hash = keccak256(ser_data.slice(65, UNSIGNED_ORDER_SIZE));
    }

    /**
     * @notice Fetch the serialized order data with the given index
     * @param ser_data Serialized order data
     * @param index The index of order to be fetched
     * @return order_data The fetched order data
     */
    function _getOrder(bytes memory ser_data, uint index) internal pure returns (bytes memory order_data) {
        require(index < _getOrderCount(ser_data));
        order_data = ser_data.slice(ORDER_SIZE.mul(index), ORDER_SIZE);
    }

    /**
     * @notice Count the order amount
     * @param ser_data Serialized order data
     * @return amount Order amount
     */
    function _getOrderCount(bytes memory ser_data) internal pure returns (uint256 amount) {
        amount = ser_data.length.div(ORDER_SIZE);
    }
}

contract SerializableWithdrawal {
    using SafeMath for uint256;
    using BytesLib for bytes;

    uint constant public WITHDRAWAL_SIZE = 140;
    uint constant public UNSIGNED_WITHDRAWAL_SIZE = 75;
    uint8 constant internal _MASK_IS_ETH = 0x01;

    /**
     * @notice Get user ID from the serialized withdrawal data
     * @param ser_data Serialized withdrawal data
     * @return userID User ID
     */
    function _getWithdrawalUserID(bytes memory ser_data) internal pure returns (uint256 userID) {
        userID = ser_data.toUint32(WITHDRAWAL_SIZE - 4);
    }

    /**
     * @notice Get token ID from the serialized withdrawal data
     * @param ser_data Serialized withdrawal data
     * @return tokenID Withdrawal token ID
     */
    function _getWithdrawalTokenID(bytes memory ser_data) internal pure returns (uint256 tokenID) {
        tokenID = ser_data.toUint16(WITHDRAWAL_SIZE - 6);
    }

    /**
     * @notice Get amount from the serialized withdrawal data
     * @param ser_data Serialized withdrawal data
     * @return amount Withdrawal token amount
     */
    function _getWithdrawalAmount(bytes memory ser_data) internal pure returns (uint256 amount) {
        amount = ser_data.toUint(WITHDRAWAL_SIZE - 38);
    }

    /**
     * @notice Check if the fee is paid by main token
     * @param ser_data Serialized withdrawal data
     * @return fETH Is the fee paid in ETH or DGO
     */
    function _isWithdrawalFeeETH(bytes memory ser_data) internal pure returns (bool fFeeETH) {
        fFeeETH = (ser_data.toUint8(WITHDRAWAL_SIZE - 39) & _MASK_IS_ETH != 0);
    }

    /**
     * @notice Get nonce from the serialized withrawal data
     * @param ser_data Serialized withdrawal data
     * @return nonce Nonce
     */
    function _getWithdrawalNonce(bytes memory ser_data) internal pure returns (uint256 nonce) {
        nonce = ser_data.toUint32(WITHDRAWAL_SIZE - 43);
    }

    /**
     * @notice Get fee amount from the serialized withdrawal data
     * @param ser_data Serialized withdrawal data
     * @return fee Fee amount
     */
    function _getWithdrawalFee(bytes memory ser_data) internal pure returns (uint256 fee) {
        fee = ser_data.toUint(WITHDRAWAL_SIZE - 75);
    }

    /**
     * @notice Get v from the serialized withdrawal data
     * @param ser_data Serialized withdrawal data
     * @return v Signature v
     */
    function _getWithdrawalV(bytes memory ser_data) internal pure returns (uint8 v) {
        v = ser_data.toUint8(WITHDRAWAL_SIZE - 76);
    }

    /**
     * @notice Get r from the serialized withdrawal data
     * @param ser_data Serialized withdrawal data
     * @return r Signature r
     */
    function _getWithdrawalR(bytes memory ser_data) internal pure returns (bytes32 r) {
        r = ser_data.toBytes32(WITHDRAWAL_SIZE - 108);
    }

    /**
     * @notice Get s from the serialized withdrawal data
     * @param ser_data Serialized withdrawal data
     * @return s Signature s
     */
    function _getWithdrawalS(bytes memory ser_data) internal pure returns (bytes32 s) {
        s = ser_data.toBytes32(WITHDRAWAL_SIZE - 140);
    }

    /**
     * @notice Get hash from the serialized withdrawal data
     * @param ser_data Serialized withdrawal data
     * @return hash Withdrawal hash without signature
     */
    function _getWithdrawalHash(bytes memory ser_data) internal pure returns (bytes32 hash) {
        hash = keccak256(ser_data.slice(65, UNSIGNED_WITHDRAWAL_SIZE));
    }
}

contract Dinngo is SerializableOrder, SerializableWithdrawal {
    // Storage alignment
    address private _owner;
    mapping (address => bool) private admins;
    uint256 private _nAdmin;
    uint256 private _nLimit;
    // end
    using ECDSA for bytes32;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 public processTime;

    mapping (address => mapping (address => uint256)) public balances;
    mapping (bytes32 => uint256) public orderFills;
    mapping (uint256 => address payable) public userID_Address;
    mapping (uint256 => address) public tokenID_Address;
    mapping (address => uint256) public userRanks;
    mapping (address => uint256) public tokenRanks;
    mapping (address => uint256) public lockTimes;

    event AddUser(uint256 userID, address indexed user);
    event AddToken(uint256 tokenID, address indexed token);
    event Deposit(address token, address indexed user, uint256 amount, uint256 balance);
    event Withdraw(address token, address indexed user, uint256 amount, uint256 balance);
    event Trade(
        address indexed user,
        bool isBuy,
        address indexed tokenTarget,
        uint256 amountTarget,
        address indexed tokenTrade,
        uint256 amountTrade
    );
    event Lock(address indexed user, uint256 lockTime);
    event Unlock(address indexed user);

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
     * @dev id should be less than 2**32
     * @param id The user id to be assigned
     * @param user The user address to be added
     */
    function addUser(uint256 id, address payable user) external {
        require(user != address(0));
        require(userRanks[user] == 0);
        require(id < 2**32);
        if (userID_Address[id] == address(0))
            userID_Address[id] = user;
        else
            require(userID_Address[id] == user);
        userRanks[user] = 1;
        emit AddUser(id, user);
    }

    /**
     * @notice Remove the address from the user list.
     * @dev The user rank is set to 0 to remove the user.
     * @param user The user address to be added
     */
    function removeUser(address user) external {
        require(user != address(0));
        require(userRanks[user] != 0);
        userRanks[user] = 0;
    }

    /**
     * @notice Update the rank of user. Can only be called by owner.
     * @param user The user address
     * @param rank The rank to be assigned
     */
    function updateUserRank(address user, uint256 rank) external {
        require(user != address(0));
        require(rank != 0);
        require(userRanks[user] != 0);
        require(userRanks[user] != rank);
        userRanks[user] = rank;
    }

    /**
     * @notice Add the token to the token list. Event AddToken will be emitted
     * after execution.
     * @dev Record the token list to map the token contract address to a specific
     * token ID, in order to compact the data size when transferring token contract
     * address information
     * @dev id should be less than 2**16
     * @param id The token id to be assigned
     * @param token The token contract address to be added
     */
    function addToken(uint256 id, address token) external {
        require(token != address(0));
        require(tokenRanks[token] == 0);
        require(id < 2**16);
        if (tokenID_Address[id] == address(0))
            tokenID_Address[id] = token;
        else
            require(tokenID_Address[id] == token);
        tokenRanks[token] = 1;
        emit AddToken(id, token);
    }

    /**
     * @notice Remove the token to the token list.
     * @dev The token rank is set to 0 to remove the token.
     * @param token The token contract address to be removed.
     */
    function removeToken(address token) external {
        require(token != address(0));
        require(tokenRanks[token] != 0);
        tokenRanks[token] = 0;
    }

    /**
     * @notice Update the rank of token. Can only be called by owner.
     * @param token The token contract address.
     * @param rank The rank to be assigned.
     */
    function updateTokenRank(address token, uint256 rank) external {
        require(token != address(0));
        require(rank != 0);
        require(tokenRanks[token] != 0);
        require(tokenRanks[token] != rank);
        tokenRanks[token] = rank;
    }

    /**
     * @notice The deposit function for ether. The ether that is sent with the function
     * call will be deposited. The first time user will be added to the user list.
     * Event Deposit will be emitted after execution.
     */
    function deposit() external payable {
        require(!_isLocking(msg.sender));
        require(msg.value > 0);
        balances[address(0)][msg.sender] = balances[address(0)][msg.sender].add(msg.value);
        emit Deposit(address(0), msg.sender, msg.value, balances[address(0)][msg.sender]);
    }

    /**
     * @notice The deposit function for tokens. The first time user will be added to
     * the user list. Event Deposit will be emitted after execution.
     * @param token Address of the token contract to be deposited
     * @param amount Amount of the token to be depositied
     */
    function depositToken(address token, uint256 amount) external {
        require(token != address(0));
        require(!_isLocking(msg.sender));
        require(_isValidToken(token));
        require(amount > 0);
        balances[token][msg.sender] = balances[token][msg.sender].add(amount);
        emit Deposit(token, msg.sender, amount, balances[token][msg.sender]);
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
    }

    /**
     * @notice The withdraw function for ether. Event Withdraw will be emitted
     * after execution. User needs to be locked before calling withdraw.
     * @param amount The amount to be withdrawn.
     */
    function withdraw(uint256 amount) external {
        require(_isLocked(msg.sender));
        require(_isValidUser(msg.sender));
        require(amount > 0);
        balances[address(0)][msg.sender] = balances[address(0)][msg.sender].sub(amount);
        emit Withdraw(address(0), msg.sender, amount, balances[address(0)][msg.sender]);
        msg.sender.transfer(amount);
    }

    /**
     * @notice The withdraw function for tokens. Event Withdraw will be emitted
     * after execution. User needs to be locked before calling withdraw.
     * @param token The token contract address to be withdrawn.
     * @param amount The token amount to be withdrawn.
     */
    function withdrawToken(address token, uint256 amount) external {
        require(token != address(0));
        require(_isLocked(msg.sender));
        require(_isValidUser(msg.sender));
        require(_isValidToken(token));
        require(amount > 0);
        balances[token][msg.sender] = balances[token][msg.sender].sub(amount);
        emit Withdraw(token, msg.sender, amount, balances[token][msg.sender]);
        IERC20(token).safeTransfer(msg.sender, amount);
    }

    /**
     * @notice The withdraw function that can only be triggered by owner.
     * Event Withdraw will be emitted after execution.
     * @param withdrawal The serialized withdrawal data
     */
    function withdrawByAdmin(bytes calldata withdrawal) external {
        address payable user = userID_Address[_getWithdrawalUserID(withdrawal)];
        address token = tokenID_Address[_getWithdrawalTokenID(withdrawal)];
        uint256 amount = _getWithdrawalAmount(withdrawal);
        uint256 amountFee = _getWithdrawalFee(withdrawal);
        address tokenFee = _isWithdrawalFeeETH(withdrawal)? address(0) : tokenID_Address[1];
        uint256 balance = balances[token][user].sub(amount);
        require(_isValidUser(user));
        _verifySig(
            user,
            _getWithdrawalHash(withdrawal),
            _getWithdrawalR(withdrawal),
            _getWithdrawalS(withdrawal),
            _getWithdrawalV(withdrawal)
        );
        if (tokenFee == token) {
            balance = balance.sub(amountFee);
        } else {
            balances[tokenFee][user] = balances[tokenFee][user].sub(amountFee);
        }
        balances[tokenFee][userID_Address[0]] =
            balances[tokenFee][userID_Address[0]].add(amountFee);
        balances[token][user] = balance;
        emit Withdraw(token, user, amount, balance);
        if (token == address(0)) {
            user.transfer(amount);
        } else {
            IERC20(token).safeTransfer(user, amount);
        }
    }

    /**
     * @notice The settle function for orders. First order is taker order and the followings
     * are maker orders.
     * @param orders The serialized orders.
     */
    function settle(bytes calldata orders) external {
        // Deal with the order list
        uint256 nOrder = _getOrderCount(orders);
        // Get the first order as the taker order
        bytes memory takerOrder = _getOrder(orders, 0);
        bytes32 takerHash = _getOrderHash(takerOrder);
        uint256 takerAmountTarget = _getOrderAmountTarget(takerOrder).sub(orderFills[takerHash]);
        uint256 fillAmountTrade = 0;
        uint256 restAmountTarget = takerAmountTarget;
        // Parse maker orders
        for (uint i = 1; i < nOrder; i++) {
            // Get ith order as the maker order
            bytes memory makerOrder = _getOrder(orders, i);
            require(_isOrderBuy(takerOrder) != _isOrderBuy(makerOrder));
            uint256 makerAmountTrade = _getOrderAmountTrade(makerOrder);
            uint256 makerAmountTarget = _getOrderAmountTarget(makerOrder);
            bytes32 makerHash = _getOrderHash(makerOrder);
            // Calculate the amount to be executed
            uint256 amountTarget = makerAmountTarget.sub(orderFills[makerHash]);
            amountTarget = amountTarget <= restAmountTarget? amountTarget : restAmountTarget;
            uint256 amountTrade = makerAmountTrade.mul(amountTarget).div(makerAmountTarget);
            restAmountTarget = restAmountTarget.sub(amountTarget);
            fillAmountTrade = fillAmountTrade.add(amountTrade);
            // Trade amountTarget and amountTrade for maker order
            _trade(amountTarget, amountTrade, makerOrder);
        }
        // Sum the trade amount and check
        restAmountTarget = takerAmountTarget.sub(restAmountTarget);
        if (_isOrderBuy(takerOrder)) {
            require(fillAmountTrade.mul(_getOrderAmountTarget(takerOrder))
                <= _getOrderAmountTrade(takerOrder).mul(restAmountTarget));
        } else {
            require(fillAmountTrade.mul(_getOrderAmountTarget(takerOrder))
                >= _getOrderAmountTrade(takerOrder).mul(restAmountTarget));
        }
        // Trade amountTarget and amountTrade for taker order
        _trade(restAmountTarget, fillAmountTrade, takerOrder);
    }

    /**
     * @notice Announce lock of the sender
     */
    function lock() external {
        require(!_isLocking(msg.sender));
        lockTimes[msg.sender] = now.add(processTime);
        emit Lock(msg.sender, lockTimes[msg.sender]);
    }

    /**
     * @notice Unlock the sender
     */
    function unlock() external {
        require(_isLocking(msg.sender));
        lockTimes[msg.sender] = 0;
        emit Unlock(msg.sender);
    }

    /**
     * @notice Change the processing time of locking the user address
     */
    function changeProcessTime(uint256 time) external {
        require(processTime != time);
        processTime = time;
    }

    /**
     * @notice Process the trade by the providing information
     * @dev Price equal amountTrade/amountTarget
     * @param amountTarget The provided amount to be traded
     * @param amountTrade The amount to be requested
     * @param order The order that triggered the trading
     */
    function _trade(uint256 amountTarget, uint256 amountTrade, bytes memory order) internal {
        require(amountTarget != 0);
        // Get parameters
        address user = userID_Address[_getOrderUserID(order)];
        bytes32 hash = _getOrderHash(order);
        address tokenTrade = tokenID_Address[_getOrderTokenIDTrade(order)];
        address tokenTarget = tokenID_Address[_getOrderTokenIDTarget(order)];
        uint256 balanceTrade;
        uint256 balanceTarget;
        require(_isValidUser(user));
        // Trade
        if (_isOrderBuy(order)) {
            balanceTrade = balances[tokenTrade][user].sub(amountTrade);
            balanceTarget = balances[tokenTarget][user].add(amountTarget);
        } else {
            balanceTrade = balances[tokenTrade][user].add(amountTrade);
            balanceTarget = balances[tokenTarget][user].sub(amountTarget);
        }
        // Get fee
        address tokenFee = _isOrderFeeMain(order)? tokenTrade : tokenID_Address[1];
        uint256 amountFee = _getOrderTradeFee(order).mul(amountTarget).div(_getOrderAmountTarget(order));
        // Order fill
        if (orderFills[hash] == 0) {
            _verifySig(user, hash, _getOrderR(order), _getOrderS(order), _getOrderV(order));
            amountFee = amountFee.add(_getOrderGasFee(order));
        }
        orderFills[hash] = orderFills[hash].add(amountTarget);
        if (tokenFee == tokenTarget) {
            balanceTarget = balanceTarget.sub(amountFee);
        } else if (tokenFee == tokenTrade) {
            balanceTrade = balanceTrade.sub(amountFee);
        } else {
            balances[tokenFee][user] = balances[tokenFee][user].sub(amountFee);
        }
        balances[tokenFee][userID_Address[0]] = balances[tokenFee][userID_Address[0]].add(amountFee);
        balances[tokenTarget][user] = balanceTarget;
        balances[tokenTrade][user] = balanceTrade;
        emit Trade
        (
            user,
            _isOrderBuy(order),
            tokenTarget,
            amountTarget,
            tokenTrade,
            amountTrade
        );
    }

    /**
     * @dev Check if the user is valid
     * @param user The user address to be checked.
     */
    function _isValidUser(address user) internal view returns (bool) {
        return userRanks[user] != 0;
    }

    /**
     * @dev Check if the token is valid
     * @param token The token address to be checked.
     */

    function _isValidToken(address token) internal view returns (bool) {
        return tokenRanks[token] != 0;
    }

    /**
     * @notice Verify if the data is signed by the given user and signature
     * @param user The signing user
     * @param hash The data hash to be verified
     * @param r The signature R
     * @param s The signature S
     * @param v The signature V
     */
    function _verifySig(address user, bytes32 hash, bytes32 r, bytes32 s, uint8 v) internal pure {
        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }
        require(v == 27 || v == 28);

        address sigAddr = ecrecover(hash.toEthSignedMessageHash(), v, r, s);
        require(user == sigAddr);
    }

    /**
     * @notice Return if the give user has announced lock
     * @param user The user address to be queried
     * @return Query result
     */
    function _isLocking(address user) internal view returns (bool) {
        return lockTimes[user] > 0;
    }

    /**
     * @notice Return if the user is locked
     * @param user The user address to be queried
     */
    function _isLocked(address user) internal view returns (bool) {
        return _isLocking(user) && lockTimes[user] < now;
    }
}

library BytesLib {
    function concat(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bytes memory) {
        bytes memory tempBytes;

        assembly {
            // Get a location of some free memory and store it in tempBytes as
            // Solidity does for memory variables.
            tempBytes := mload(0x40)

            // Store the length of the first bytes array at the beginning of
            // the memory for tempBytes.
            let length := mload(_preBytes)
            mstore(tempBytes, length)

            // Maintain a memory counter for the current write location in the
            // temp bytes array by adding the 32 bytes for the array length to
            // the starting location.
            let mc := add(tempBytes, 0x20)
            // Stop copying when the memory counter reaches the length of the
            // first bytes array.
            let end := add(mc, length)

            for {
                // Initialize a copy counter to the start of the _preBytes data,
                // 32 bytes into its memory.
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                // Increase both counters by 32 bytes each iteration.
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                // Write the _preBytes data into the tempBytes memory 32 bytes
                // at a time.
                mstore(mc, mload(cc))
            }

            // Add the length of _postBytes to the current length of tempBytes
            // and store it as the new length in the first 32 bytes of the
            // tempBytes memory.
            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            // Move the memory counter back from a multiple of 0x20 to the
            // actual end of the _preBytes data.
            mc := end
            // Stop copying when the memory counter reaches the new combined
            // length of the arrays.
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            // Update the free-memory pointer by padding our last write location
            // to 32 bytes: add 31 bytes to the end of tempBytes to move to the
            // next 32 byte block, then round down to the nearest multiple of
            // 32. If the sum of the length of the two arrays is zero then add 
            // one before rounding down to leave a blank 32 bytes (the length block with 0).
            mstore(0x40, and(
              add(add(end, iszero(add(length, mload(_preBytes)))), 31),
              not(31) // Round down to the nearest 32 bytes.
            ))
        }

        return tempBytes;
    }

    function concatStorage(bytes storage _preBytes, bytes memory _postBytes) internal {
        assembly {
            // Read the first 32 bytes of _preBytes storage, which is the length
            // of the array. (We don't need to use the offset into the slot
            // because arrays use the entire slot.)
            let fslot := sload(_preBytes_slot)
            // Arrays of 31 bytes or less have an even value in their slot,
            // while longer arrays have an odd value. The actual length is
            // the slot divided by two for odd values, and the lowest order
            // byte divided by two for even values.
            // If the slot is even, bitwise and the slot with 255 and divide by
            // two to get the length. If the slot is odd, bitwise and the slot
            // with -1 and divide by two.
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)
            let newlength := add(slength, mlength)
            // slength can contain both the length and contents of the array
            // if length < 32 bytes so let's prepare for that
            // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
            switch add(lt(slength, 32), lt(newlength, 32))
            case 2 {
                // Since the new array still fits in the slot, we just need to
                // update the contents of the slot.
                // uint256(bytes_storage) = uint256(bytes_storage) + uint256(bytes_memory) + new_length
                sstore(
                    _preBytes_slot,
                    // all the modifications to the slot are inside this
                    // next block
                    add(
                        // we can just add to the slot contents because the
                        // bytes we want to change are the LSBs
                        fslot,
                        add(
                            mul(
                                div(
                                    // load the bytes from memory
                                    mload(add(_postBytes, 0x20)),
                                    // zero all bytes to the right
                                    exp(0x100, sub(32, mlength))
                                ),
                                // and now shift left the number of bytes to
                                // leave space for the length in the slot
                                exp(0x100, sub(32, newlength))
                            ),
                            // increase length by the double of the memory
                            // bytes length
                            mul(mlength, 2)
                        )
                    )
                )
            }
            case 1 {
                // The stored value fits in the slot, but the combined value
                // will exceed it.
                // get the keccak hash to get the contents of the array
                mstore(0x0, _preBytes_slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                // save new length
                sstore(_preBytes_slot, add(mul(newlength, 2), 1))

                // The contents of the _postBytes array start 32 bytes into
                // the structure. Our first read should obtain the `submod`
                // bytes that can fit into the unused space in the last word
                // of the stored array. To get this, we read 32 bytes starting
                // from `submod`, so the data we read overlaps with the array
                // contents by `submod` bytes. Masking the lowest-order
                // `submod` bytes allows us to add that value directly to the
                // stored value.

                let submod := sub(32, slength)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(
                    sc,
                    add(
                        and(
                            fslot,
                            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
                        ),
                        and(mload(mc), mask)
                    )
                )

                for {
                    mc := add(mc, 0x20)
                    sc := add(sc, 1)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
            default {
                // get the keccak hash to get the contents of the array
                mstore(0x0, _preBytes_slot)
                // Start copying to the last used word of the stored array.
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                // save new length
                sstore(_preBytes_slot, add(mul(newlength, 2), 1))

                // Copy over the first `submod` bytes of the new data as in
                // case 1 above.
                let slengthmod := mod(slength, 32)
                let mlengthmod := mod(mlength, 32)
                let submod := sub(32, slengthmod)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(sc, add(sload(sc), and(mload(mc), mask)))
                
                for { 
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
        }
    }

    function slice(bytes memory _bytes, uint _start, uint _length) internal  pure returns (bytes memory) {
        require(_bytes.length >= (_start + _length));

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                // Get a location of some free memory and store it in tempBytes as
                // Solidity does for memory variables.
                tempBytes := mload(0x40)

                // The first word of the slice result is potentially a partial
                // word read from the original array. To read it, we calculate
                // the length of that partial word and start copying that many
                // bytes into the array. The first word we copy will start with
                // data we don't care about, but the last `lengthmod` bytes will
                // land at the beginning of the contents of the new array. When
                // we're done copying, we overwrite the full first word with
                // the actual length of the slice.
                let lengthmod := and(_length, 31)

                // The multiplication in the next line is necessary
                // because when slicing multiples of 32 bytes (lengthmod == 0)
                // the following copy loop was copying the origin's length
                // and then ending prematurely not copying everything it should.
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    // The multiplication in the next line has the same exact purpose
                    // as the one above.
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                //update free-memory pointer
                //allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint _start) internal  pure returns (address) {
        require(_bytes.length >= (_start + 20));
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint _start) internal  pure returns (uint8) {
        require(_bytes.length >= (_start + 1));
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint16(bytes memory _bytes, uint _start) internal  pure returns (uint16) {
        require(_bytes.length >= (_start + 2));
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }

        return tempUint;
    }

    function toUint32(bytes memory _bytes, uint _start) internal  pure returns (uint32) {
        require(_bytes.length >= (_start + 4));
        uint32 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }

        return tempUint;
    }

    function toUint(bytes memory _bytes, uint _start) internal  pure returns (uint256) {
        require(_bytes.length >= (_start + 32));
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes32(bytes memory _bytes, uint _start) internal  pure returns (bytes32) {
        require(_bytes.length >= (_start + 32));
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }

    function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {
        bool success = true;

        assembly {
            let length := mload(_preBytes)

            // if lengths don't match the arrays are not equal
            switch eq(length, mload(_postBytes))
            case 1 {
                // cb is a circuit breaker in the for loop since there's
                //  no said feature for inline assembly loops
                // cb = 1 - don't breaker
                // cb = 0 - break
                let cb := 1

                let mc := add(_preBytes, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(_postBytes, 0x20)
                // the next line is the loop condition:
                // while(uint(mc < end) + cb == 2)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    // if any of these checks fails then arrays are not equal
                    if iszero(eq(mload(mc), mload(cc))) {
                        // unsuccess:
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }

    function equalStorage(bytes storage _preBytes, bytes memory _postBytes) internal view returns (bool) {
        bool success = true;

        assembly {
            // we know _preBytes_offset is 0
            let fslot := sload(_preBytes_slot)
            // Decode the length of the stored array like in concatStorage().
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)

            // if lengths don't match the arrays are not equal
            switch eq(slength, mlength)
            case 1 {
                // slength can contain both the length and contents of the array
                // if length < 32 bytes so let's prepare for that
                // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                        // blank the last byte which is the length
                        fslot := mul(div(fslot, 0x100), 0x100)

                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                            // unsuccess:
                            success := 0
                        }
                    }
                    default {
                        // cb is a circuit breaker in the for loop since there's
                        //  no said feature for inline assembly loops
                        // cb = 1 - don't breaker
                        // cb = 0 - break
                        let cb := 1

                        // get the keccak hash to get the contents of the array
                        mstore(0x0, _preBytes_slot)
                        let sc := keccak256(0x0, 0x20)

                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)

                        // the next line is the loop condition:
                        // while(uint(mc < end) + cb == 2)
                        for {} eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                                // unsuccess:
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }
}

library ECDSA {
    /**
     * @dev Recover signer address from a message by using their signature
     * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
     * @param signature bytes signature, the signature is generated using web3.eth.sign()
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        // If the signature is valid (and not malleable), return the signer address
        return ecrecover(hash, v, r, s);
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

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require((value == 0) || (token.allowance(address(this), spender) == 0));
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must equal true).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.

        require(address(token).isContract());

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success);

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)));
        }
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