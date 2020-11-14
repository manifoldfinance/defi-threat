/**
 * Source Code first verified at https://etherscan.io on Thursday, March 21, 2019
 (UTC) */

/**
 *
 *  Provable Connector v1.3.0
 *
 *  Copyright (c) 2015-2016 Oraclize SRL
 *  Copyright (c) 2016-2019 Oraclize LTD
 *  Copyright (c) 2019 Provable Things LTD
 *
 */
pragma solidity 0.4.24;

interface ERC20Interface {

  function balanceOf(address who) external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(address from, address to, uint256 value) external returns (bool);

}

contract Oraclize {

    mapping (address => uint256) requestCounter;
    mapping (address => byte) public callbackAddresses;
    mapping (address => bool) public offchainPayment;
    address admin;
    address paymentFlagger;
    uint256 gasPrice = 20e9;
    mapping (address => byte) addressProofType;
    mapping (address => uint256) addressCustomGasPrice;
    uint256 public basePrice;
    mapping (bytes32 => uint256) public price;
    mapping (bytes32 => uint256) priceMultiplier;
    bytes32[] datasources;
    bytes32[] public randomDS_sessionPublicKeyHash;
    uint256 constant BASE_TX_COST = 21e3;
    uint256 constant DEFAULT_GAS_LIMIT = 2e5;
    mapping (address => uint256) public amplifiedTokenPrices;
    mapping (address => address) public addressCustomPaymentToken;

    event Log1(
        address sender,
        bytes32 cid,
        uint256 timestamp,
        string datasource,
        string arg,
        uint256 gaslimit,
        byte proofType,
        uint256 gasPrice
    );

    event Log1_byte(
        address sender,
        bytes32 cid,
        uint256 timestamp,
        byte datasource,
        string arg,
        uint256 gaslimit,
        byte proofType,
        uint256 gasPrice
    );

    event Log2(
        address sender,
        bytes32 cid,
        uint256 timestamp,
        string datasource,
        string arg1,
        string arg2,
        uint256 gaslimit,
        byte proofType,
        uint256 gasPrice
    );

    event Log2_byte(
        address sender,
        bytes32 cid,
        uint256 timestamp,
        byte datasource,
        string arg1,
        string arg2,
        uint256 gaslimit,
        byte proofType,
        uint256 gasPrice
    );

    event LogN(
        address sender,
        bytes32 cid,
        uint256 timestamp,
        string datasource,
        bytes args,
        uint256 gaslimit,
        byte proofType,
        uint256 gasPrice
    );

    event LogN_byte(
        address sender,
        bytes32 cid,
        uint256 timestamp,
        byte datasource,
        bytes args,
        uint256 gaslimit,
        byte proofType,
        uint256 gasPrice
    );

    event Emit_OffchainPaymentFlag(
        address indexed idx_sender,
        address sender,
        bool indexed idx_flag,
        bool flag
    );

    event CallbackRebroadcastRequest(
      bytes32 indexed queryId,
      uint256 gasLimit,
      uint256 gasPrice
    );

    event LogTokenWhitelistRemoval(
        address tokenAddress
    );

    event LogTokenWhitelisting(
        string tokenTicker,
        address tokenAddress
    );

    event EnableCache(
        address indexed sender,
        bytes32 cid
    );

    event LogCached(
        address sender,
        bytes32 cid,
        uint256 value
    );

    constructor() public {
        admin = msg.sender;
    }

    function onlyAdmin()
        view
        private
    {
        require(msg.sender == admin);
    }

    function onlyManagers()
        view
        private
    {
        require(msg.sender == admin || msg.sender == paymentFlagger);
    }

    /**
     * @notice  The price amplification allows representation of lower-priced
     *          tokens by the connector, & maintains higher precision during the
     *          the conversion of a query price in ETH to it's token equivalent.
     *
     * @dev     Token price amplified via: tokenUSDPrice * 1e3.
     */
    function whitelistToken(
        string _tokenTicker,
        address _tokenAddress,
        uint256 _amplifiedTokenPrice
    )
        external
    {
        onlyAdmin();
        amplifiedTokenPrices[_tokenAddress] = _amplifiedTokenPrice;
        emit LogTokenWhitelisting(_tokenTicker, _tokenAddress);
    }

    function updateTokenAmplifiedPrice(
        address _tokenAddress,
        uint256 _newAmplifiedTokenPrice
    )
        external
    {
        onlyManagers();
        amplifiedTokenPrices[_tokenAddress] = _newAmplifiedTokenPrice;
    }

    function revokeTokenWhitelisting(address _tokenAddress)
        external
    {
        onlyManagers();
        delete amplifiedTokenPrices[_tokenAddress];
        emit LogTokenWhitelistRemoval(_tokenAddress);
    }

    function setCustomTokenPayment(address _tokenAddress)
        external
    {
        require(amplifiedTokenPrices[_tokenAddress] > 0);
        addressCustomPaymentToken[msg.sender] = _tokenAddress;
    }

    function unsetCustomTokenPayment()
        external
    {
        delete addressCustomPaymentToken[msg.sender];
    }

    function getTokenBalance(address _tokenAddress)
    view
        public
        returns (uint256 _tokenBalance)
    {
        return ERC20Interface(_tokenAddress).balanceOf(address(this));
    }

    function withdrawTokens(address _tokenAddress)
        external
    {
        onlyAdmin();
        withdrawTokens(
            _tokenAddress,
            msg.sender,
            getTokenBalance(_tokenAddress)
        );
    }

    function withdrawTokens(
        address _tokenAddress,
        address _recipient,
        uint256 _amount
    )
        public
    {
        onlyAdmin();
        require(_recipient != address(0));
        ERC20Interface(_tokenAddress).transfer(_recipient, _amount);
    }

    function migrateRequestCounter(
        address _address,
        uint256 _requestCounter
    )
        private
    {
        require(requestCounter[_address] == 0);
        requestCounter[_address] = _requestCounter;
    }

    function batchMigrateRequestCounters(
        address[] _addresses,
        uint256[] _requestCounters
    )
        public
    {
        onlyManagers();
        for (uint256 i = 0; i < _addresses.length; i++) {
            migrateRequestCounter(
                _addresses[i],
                _requestCounters[i]
            );
        }
    }
    function migrateCustomSettings(
        address _address,
        byte _proofType,
        uint256 _gasPrice,
        bool _offchainPayer,
        uint256 _requestCounter
    )
        private
    {
        require(requestCounter[_address] == 0);
        addressProofType[_address] = _proofType;
        requestCounter[_address] = _requestCounter;
        offchainPayment[_address] = _offchainPayer;
        addressCustomGasPrice[_address] = _gasPrice;
    }

    function batchMigrateCustomSettings(
        address[] _addresses,
        byte[] _proofTypes,
        uint256[] _gasPrices,
        bool[] _offchainPayers,
        uint256[] _requestCounters
    )
        public
    {
        onlyManagers();
        for (uint256 i = 0; i < _addresses.length; i++) {
            migrateCustomSettings(
                _addresses[i],
                _proofTypes[i],
                _gasPrices[i],
                _offchainPayers[i],
                _requestCounters[i]
            );
        }
    }

    function costs(
        string _datasource,
        uint256 _gasLimit
    )
        private
    {
        settlePayment(getPrice(_datasource, _gasLimit, msg.sender));
    }

    function costs(
        byte _datasource,
        uint256 _gasLimit
    )
        private
    {
        settlePayment(getPrice(_datasource, _gasLimit, msg.sender));
    }

    /**
     * @dev Any ETH sent over and above a query price is refunded. Please note
     *      that the same is NOT true for any queries paid for by ERC20 tokens.
     *      In such cases, please ensure no ETH is sent along with query
     *      function calls.
     */
    function settlePayment(uint256 _price)
        private
    {
        if (msg.value == _price) {
            return;
        }
        else if (msg.value > _price) {
            msg.sender.transfer(msg.value - _price);
            return;
        }
        address tokenAddress = addressCustomPaymentToken[msg.sender];
        if (tokenAddress != address(0)) {
            makeERC20Payment(
                msg.sender,
                convertToERC20Price(_price, tokenAddress)
            );
            return;
        }
        else {
            revert('Error settling query payment');
        }
    }

    /**
     * @notice  The amplified token price here allows higher precision when
     *          converting the query price in wei to its token equivalent.
     */
    function convertToERC20Price(
        uint256 _queryPriceInWei,
        address _tokenAddress
    )
        view
        public
        returns (uint256 _price)
    {
        uint256 erc20Price = (_queryPriceInWei * 1 ether) / (amplifiedTokenPrices[_tokenAddress] * basePrice);
        require(erc20Price > 0);
        return erc20Price;
    }

    function makeERC20Payment(
        address _address,
        uint256 _amount
    )
        private
    {
        ERC20Interface(addressCustomPaymentToken[_address])
            .transferFrom(
                _address,
                address(this),
                _amount
            );
    }

    function changeAdmin(address _newAdmin)
        external
    {
        onlyAdmin();
        admin = _newAdmin;
    }

    function changePaymentFlagger(address _newFlagger)
        external
    {
        onlyAdmin();
        paymentFlagger = _newFlagger;
    }

    function addCallbackAddress(
        address _newCallbackAddress,
        byte _addressType
    )
        public
    {
        onlyAdmin();
        addCallbackAddress(
            _newCallbackAddress,
            _addressType,
            hex''
        );
    }

    /**
     * @dev "proof" is currently a placeholder for when associated proof
     *      for _addressType is added.
     */
    function addCallbackAddress(
        address _newCallbackAddress,
        byte _addressType,
        bytes _proof
    )
        public
    {
        onlyAdmin();
        callbackAddresses[_newCallbackAddress] = _addressType;
    }

    function removeCallbackAddress(address _callbackAddress)
        public
    {
        onlyAdmin();
        delete callbackAddresses[_callbackAddress];
    }

    function isOriginCallbackAddress()
        public
        view
        returns (bool _isCallback)
    {
        if (callbackAddresses[tx.origin] != 0)
            return true;
    }

    function addDatasource(
        string _datasourceName,
        uint256 _multiplier
    )
        public
    {
        addDatasource(_datasourceName, 0x00, _multiplier);
    }

    function addDatasource(
        byte _datasourceName,
        uint256 _multiplier
    )
        external
    {
        addDatasource(_datasourceName, 0x00, _multiplier);
    }

    function addDatasource(
        string _datasourceName,
        byte _proofType,
        uint256 _multiplier
    )
        public
    {
        onlyAdmin();
        bytes32 dsname_hash = keccak256(
            _datasourceName,
            _proofType
        );
        datasources[datasources.length++] = dsname_hash;
        priceMultiplier[dsname_hash] = _multiplier;
    }

    function addDatasource(
        byte _datasourceName,
        byte _proofType,
        uint256 _multiplier
    )
        public
    {
        onlyAdmin();
        bytes32 dsname_hash = keccak256(
            _datasourceName,
            _proofType
        );
        datasources[datasources.length++] = dsname_hash;
        priceMultiplier[dsname_hash] = _multiplier;
    }

    /**
     * @notice  Used by the "ethereum-bridge"
     *
     * @dev     Calculate dsHash via:
     *          bytes32 hash = keccak256(DATASOURCE_NAME, PROOF_TYPE);
     */
    function multiAddDatasources(
        bytes32[] _datasourceHash,
        uint256[] _multiplier
    )
        public
    {
        onlyAdmin();
        for (uint256 i = 0; i < _datasourceHash.length; i++) {
            datasources[datasources.length++] = _datasourceHash[i];
            priceMultiplier[_datasourceHash[i]] = _multiplier[i];
        }
    }

    function multiSetProofTypes(
        uint256[] _proofType,
        address[] _address
    )
        public
    {
        onlyAdmin();
        for (uint256 i = 0; i < _address.length; i++) {
            addressProofType[_address[i]] = byte(_proofType[i]);
        }
    }

    function multiSetCustomGasPrices(
        uint256[] _gasPrice,
        address[] _address
    )
        public
    {
        onlyAdmin();
        for (uint256 i = 0; i < _address.length; i++) {
            addressCustomGasPrice[_address[i]] = _gasPrice[i];
        }
    }

    function setGasPrice(uint256 _newGasPrice)
        external
    {
        onlyAdmin();
        gasPrice = _newGasPrice;
    }

    /**
     * @notice  Base price is maintained @ 0.001 USD in ether. Notice too that
     *          any datasources need to be added before setting the base price
     *          in order for datasource prices to be correctly persisted.
     *
     * @dev     To calculate base price:
     *          uint256 basePrice = 1 * 10 ** _tokenDecimals / _USDPrice * 1000;
     *
     */
    function setBasePrice(uint256 _newBasePrice)
        external
    {
        onlyManagers();
        basePrice = _newBasePrice;
        for (uint256 i = 0; i < datasources.length; i++) {
            price[datasources[i]] = _newBasePrice * priceMultiplier[datasources[i]];
        }
    }


    function setOffchainPayment(
        address _address,
        bool _flag
    )
        external
    {
        onlyManagers();
        offchainPayment[_address] = _flag;
        emit Emit_OffchainPaymentFlag(_address, _address, _flag, _flag);
    }

    function withdrawFunds(address _address)
        external
    {
        onlyAdmin();
        _address.transfer(address(this).balance);
    }

    function randomDS_updateSessionPublicKeyHash(bytes32[] _newSessionPublicKeyHash)
        public
    {
        onlyAdmin();
        randomDS_sessionPublicKeyHash.length = 0;
        for (uint256 i = 0; i < _newSessionPublicKeyHash.length; i++) {
            randomDS_sessionPublicKeyHash.push(_newSessionPublicKeyHash[i]);
        }
    }

    function randomDS_getSessionPublicKeyHash()
        public
        view
        returns (bytes32)
    {
        uint256 i = uint256(keccak256(requestCounter[msg.sender])) % randomDS_sessionPublicKeyHash.length;
        return randomDS_sessionPublicKeyHash[i];
    }

    function setCustomProofType(byte _proofType)
        public
    {
        addressProofType[msg.sender] = _proofType;
    }

    function setCustomGasPrice(uint256 _gasPrice)
        external
    {
        addressCustomGasPrice[msg.sender] = _gasPrice;
    }

    function getPrice(string _datasource)
        view
        public
        returns (uint256 _datasourcePrice)
    {
        return getPrice(_datasource, msg.sender);
    }

    function getPrice(byte _datasource)
        view
        public
        returns (uint256 _datasourcePrice)
    {
        return getPrice(_datasource, msg.sender);
    }

    function getPrice(
        string _datasource,
        uint256 _gasLimit
    )
        view
        public
        returns (uint256 _datasourcePrice)
    {
        return getPrice(_datasource, _gasLimit, msg.sender);
    }

    function getPrice(
        byte _datasource,
        uint256 _gasLimit
    )
        view
        public
        returns (uint256 _datasourcePrice)
    {
        return getPrice(_datasource, _gasLimit, msg.sender);
    }

    function getPrice(
        string _datasource,
        address _address
    )
        view
        public
        returns (uint256 _datasourcePrice)
    {
        return getPrice(_datasource, DEFAULT_GAS_LIMIT, _address);
    }


    function getPrice(
        byte _datasource,
        address _address
    )
        view
        public
        returns (uint256 _datasourcePrice)
    {
        return getPrice(_datasource, DEFAULT_GAS_LIMIT, _address);
    }

    /**
     * @dev The ordering of the comparatives in the third `if` statement
     *      provide the greatest efficiency with respect to gas prices.
     */
    function getPrice(
        string _datasource,
        uint256 _gasLimit,
        address _address
    )
        view
        public
        returns (uint256 _datasourcePrice)
    {
        if (offchainPayment[_address]) return 0;
        uint256 customGasPrice = addressCustomGasPrice[_address];
        if (requestCounter[_address] == 0 &&
            _gasLimit <= DEFAULT_GAS_LIMIT &&
            customGasPrice <= gasPrice &&
            !isOriginCallbackAddress()) return 0;
        if (customGasPrice == 0) customGasPrice = gasPrice;
       _datasourcePrice = price[keccak256(
            _datasource,
            addressProofType[_address]
        )];
        _datasourcePrice += _gasLimit * customGasPrice;
        return _datasourcePrice;
    }

    /**
     * @dev Ibid.
    */
    function getPrice(
        byte _datasource,
        uint256 _gasLimit,
        address _address
    )
        view
        public
        returns (uint256 _datasourcePrice)
    {

        if (offchainPayment[_address]) return 0;
        uint256 customGasPrice = addressCustomGasPrice[_address];
        if (requestCounter[_address] == 0 &&
            _gasLimit <= DEFAULT_GAS_LIMIT &&
            customGasPrice <= gasPrice &&
            !isOriginCallbackAddress()) return 0;
        if (customGasPrice == 0) customGasPrice = gasPrice;
       _datasourcePrice = price[keccak256(
            _datasource,
            addressProofType[_address]
        )];
        _datasourcePrice += _gasLimit * customGasPrice;
        return _datasourcePrice;
    }

    function query(
        string _datasource,
        string _arg
    )
        payable
        external
        returns (bytes32 _id)
    {
        return query1(0, _datasource, _arg, DEFAULT_GAS_LIMIT);
    }

    function query(
        byte _datasource,
        string _arg
    )
        payable
        external
        returns (bytes32 _id)
    {
        return query1(0, _datasource, _arg, DEFAULT_GAS_LIMIT);
    }

    function query1(
        string _datasource,
        string _arg
    )
        payable
        external
        returns (bytes32 _id)
    {
        return query1(0, _datasource, _arg, DEFAULT_GAS_LIMIT);
    }

    function query1(
        byte _datasource,
        string _arg
    )
        payable
        external
        returns (bytes32 _id)
    {
        return query1(0, _datasource, _arg, DEFAULT_GAS_LIMIT);
    }

   function query2(
        string _datasource,
        string _arg1,
        string _arg2
    )
        payable
        external
        returns (bytes32 _id)
    {
        return query2(0, _datasource, _arg1, _arg2, DEFAULT_GAS_LIMIT);
    }

    function query2(
        byte _datasource,
        string _arg1,
        string _arg2
    )
        payable
        external
        returns (bytes32 _id)
    {
        return query2(0, _datasource, _arg1, _arg2, DEFAULT_GAS_LIMIT);
    }

    function queryN(
        string _datasource,
        bytes _args
    )
        payable
        external
        returns (bytes32 _id)
    {
        return queryN(0, _datasource, _args, DEFAULT_GAS_LIMIT);
    }

    function queryN(
        byte _datasource,
        bytes _args
    )
        payable
        external
        returns (bytes32 _id)
    {
        return queryN(0, _datasource, _args, DEFAULT_GAS_LIMIT);
    }

    function query(
        uint256 _timestamp,
        string _datasource,
        string _arg
    )
        payable
        external
        returns (bytes32 _id)
    {
        return query1(_timestamp, _datasource, _arg, DEFAULT_GAS_LIMIT);
    }

    function query(
        uint256 _timestamp,
        byte _datasource,
        string _arg
    )
        payable
        external
        returns (bytes32 _id)
    {
        return query1(_timestamp, _datasource, _arg, DEFAULT_GAS_LIMIT);
    }

    function query1(
        uint256 _timestamp,
        string _datasource,
        string _arg
    )
        payable
        external
        returns (bytes32 _id)
    {
        return query1(_timestamp, _datasource, _arg, DEFAULT_GAS_LIMIT);
    }

    function query1(
        uint256 _timestamp,
        byte _datasource,
        string _arg
    )
        payable
        external
        returns (bytes32 _id)
    {
        return query1(_timestamp, _datasource, _arg, DEFAULT_GAS_LIMIT);
    }

    function query2(
        uint256 _timestamp,
        string _datasource,
        string _arg1,
        string _arg2
    )
        payable
        external
        returns (bytes32 _id)
    {
        return query2(_timestamp, _datasource, _arg1, _arg2, DEFAULT_GAS_LIMIT);
    }

    function query2(
        uint256 _timestamp,
        byte _datasource,
        string _arg1,
        string _arg2
    )
        payable
        external
        returns (bytes32 _id)
    {
        return query2(_timestamp, _datasource, _arg1, _arg2, DEFAULT_GAS_LIMIT);
    }

    function queryN(
        uint256 _timestamp,
        string _datasource,
        bytes _args
    )
        payable
        external
        returns (bytes32 _id)
    {
        return queryN(_timestamp, _datasource, _args, DEFAULT_GAS_LIMIT);
    }

    function queryN(
        uint256 _timestamp,
        byte _datasource,
        bytes _args
    )
        payable
        external
        returns (bytes32 _id)
    {
        return queryN(_timestamp, _datasource, _args, DEFAULT_GAS_LIMIT);
    }

    function queryWithGasLimit(
        uint256 _timestamp,
        string _datasource,
        string _arg,
        uint256 _gasLimit
    )
        payable
        external
        returns (bytes32 _id)
    {
        return query1(_timestamp, _datasource, _arg, _gasLimit);
    }

    function queryWithGasLimit(
        uint256 _timestamp,
        byte _datasource,
        string _arg,
        uint256 _gasLimit
    )
        payable
        external
        returns (bytes32 _id)
    {
        return query1(_timestamp, _datasource, _arg, _gasLimit);
    }

    function query1WithGasLimit(
        uint256 _timestamp,
        string _datasource,
        string _arg,
        uint256 _gasLimit
    )
        payable
        external
        returns (bytes32 _id)
    {
        return query1(_timestamp, _datasource, _arg, _gasLimit);
    }

    function query1WithGasLimit(
        uint256 _timestamp,
        byte _datasource,
        string _arg,
        uint256 _gasLimit
    )
        payable
        external
        returns (bytes32 _id)
    {
        return query1(_timestamp, _datasource, _arg, _gasLimit);
    }

    function query2WithGasLimit(
        uint256 _timestamp,
        string _datasource,
        string _arg1,
        string _arg2,
        uint256 _gasLimit
    )
        payable
        external
        returns (bytes32 _id)
    {
        return query2(_timestamp, _datasource, _arg1, _arg2, _gasLimit);
    }

    function query2WithGasLimit(
        uint256 _timestamp,
        byte _datasource,
        string _arg1,
        string _arg2,
        uint256 _gasLimit
    )
        payable
        external
        returns (bytes32 _id)
    {
        return query2(_timestamp, _datasource, _arg1, _arg2, _gasLimit);
    }

    function queryNWithGasLimit(
        uint256 _timestamp,
        string _datasource,
        bytes _args,
        uint256 _gasLimit
    )
        payable
        external
        returns (bytes32 _id)
    {
        return queryN(_timestamp, _datasource, _args, _gasLimit);
    }

    function queryNWithGasLimit(
        uint256 _timestamp,
        byte _datasource,
        bytes _args,
        uint256 _gasLimit
    )
        payable
        external
        returns (bytes32 _id)
    {
        return queryN(_timestamp, _datasource, _args, _gasLimit);
    }

    /**
     * @dev In the following `query` functions, any timestamps that pertain
     *      to a delay greater than 60 days are invalid. This is enforced
     *      off-chain and thus no check appears here.
     *
     *      Also enforced off-chain and so not checked herein is that the
     *      provided `_gasLimit` is less than or equal to the current block
     *      gas limit.
     */
    function query1(
        uint256 _timestamp,
        string _datasource,
        string _arg,
        uint256 _gasLimit
    )
        payable
        public
        returns (bytes32 _id)
    {
        costs(_datasource, _gasLimit);
        _id = keccak256(
            this,
            msg.sender,
            requestCounter[msg.sender]++
        );
        emit Log1(
            msg.sender,
            _id,
            _timestamp,
            _datasource,
            _arg,
            _gasLimit,
            addressProofType[msg.sender],
            addressCustomGasPrice[msg.sender]
        );
        return _id;
    }

    function query1(
        uint256 _timestamp,
        byte _datasource,
        string _arg,
        uint256 _gasLimit
    )
        payable
        public
        returns (bytes32 _id)
    {
        costs(_datasource, _gasLimit);
        _id = keccak256(
            this,
            msg.sender,
            requestCounter[msg.sender]++
        );
        emit Log1_byte(
            msg.sender,
            _id,
            _timestamp,
            _datasource,
            _arg,
            _gasLimit,
            addressProofType[msg.sender],
            addressCustomGasPrice[msg.sender]
        );
        return _id;
    }

    function query2(
        uint256 _timestamp,
        string _datasource,
        string _arg1,
        string _arg2,
        uint256 _gasLimit
    )
        payable
        public
        returns (bytes32 _id)
    {
        costs(_datasource, _gasLimit);
        _id = keccak256(
            this,
            msg.sender,
            requestCounter[msg.sender]++
        );
        emit Log2(
            msg.sender,
            _id,
            _timestamp,
            _datasource,
            _arg1,
            _arg2,
            _gasLimit,
            addressProofType[msg.sender],
            addressCustomGasPrice[msg.sender]
        );
        return _id;
    }

    function query2(
        uint256 _timestamp,
        byte _datasource,
        string _arg1,
        string _arg2,
        uint256 _gasLimit
    )
        payable
        public
        returns (bytes32 _id)
    {
        costs(_datasource, _gasLimit);
        _id = keccak256(
            this,
            msg.sender,
            requestCounter[msg.sender]++
        );
        emit Log2_byte(
            msg.sender,
            _id,
            _timestamp,
            _datasource,
            _arg1,
            _arg2,
            _gasLimit,
            addressProofType[msg.sender],
            addressCustomGasPrice[msg.sender]
        );
        return _id;
    }

    function queryN(
        uint256 _timestamp,
        string _datasource,
        bytes _args,
        uint256 _gasLimit
    )
        payable
        public
        returns (bytes32 _id)
    {
        costs(_datasource, _gasLimit);
        _id = keccak256(
            this,
            msg.sender,
            requestCounter[msg.sender]++
        );
        emit LogN(
            msg.sender,
            _id,
            _timestamp,
            _datasource,
            _args,
            _gasLimit,
            addressProofType[msg.sender],
            addressCustomGasPrice[msg.sender]
        );
        return _id;
    }

    function queryN(
        uint256 _timestamp,
        byte _datasource,
        bytes _args,
        uint256 _gasLimit
    )
        payable
        public
        returns (bytes32 _id)
    {
        costs(_datasource, _gasLimit);
        _id = keccak256(
            this,
            msg.sender,
            requestCounter[msg.sender]++
        );
        emit LogN_byte(
            msg.sender,
            _id,
            _timestamp,
            _datasource,
            _args,
            _gasLimit,
            addressProofType[msg.sender],
            addressCustomGasPrice[msg.sender]
        );
        return _id;
    }

    function getRebroadcastCost(
        uint256 _gasLimit,
        uint256 _gasPrice
    )
        pure
        public
        returns (uint256 _rebroadcastCost)
    {
        _rebroadcastCost = _gasPrice * _gasLimit;
        /**
         * @dev gas limit sanity check and overflow test
         */
        require(
            _gasLimit >= BASE_TX_COST &&
            _rebroadcastCost / _gasPrice == _gasLimit
        );

        return _rebroadcastCost;
    }

    /**
     * @dev     Allows a user to increase the gas price of a query to aid in
     *          ensuring prompt service during unexpected network traffic spikes.
     *
     * @notice  This function foregoes validation of the parameters provided
     *          and retains any passing value sent to it. Parameters provided
     *          are validated in the off-chain context, and irregular or
     *          impossible parameters will simply be ignored (e.g. gas limit
     *          above the current block gas limit).
     */
    function requestCallbackRebroadcast(
        bytes32 _queryId,
        uint256 _gasLimit,
        uint256 _gasPrice
    )
        payable
        external
    {
        uint256 ethCost = getRebroadcastCost(
            _gasLimit,
            _gasPrice
        );

        require (msg.value >= ethCost);

        if (msg.value > ethCost) {
            msg.sender.transfer(msg.value - ethCost);
        }

        emit CallbackRebroadcastRequest(
            _queryId,
            _gasLimit,
            _gasPrice
        );
    }

    /**
     * @dev Fires an event the engine watches for, to notify it to cache the
     *      specified query's parameters. ALL parameters for that specific
     *      query are cached, including timestamps & gas prices. When calling
     *      this function, a queryID needs to be explicitly sent in order to
     *      specify the exact query whose parameters the caller wants cached.
     */
    function requestQueryCaching(
        bytes32 _queryId
    )
        external
    {
        require(requestCounter[msg.sender] > 0);

        emit EnableCache(
            msg.sender,
            _queryId
        );
    }

    /**
     * @dev     Function which requests the calling contract's cached query
     *          be processed.
     *
     * @notice  A query must be cached by the sender first. Correct funding
     *          must be provided, or will be ignored by the Provable service.
     *          In order to make query-caching as efficient as possible there
     *          are NO on-chain checks regarding sufficient payment. Thus any
     *          queries found to be under-funded will be dropped by Provable.
     */
    function queryCached()
        payable
        external
        returns (bytes32 _id)
    {
        _id = keccak256(
            this,
            msg.sender,
            requestCounter[msg.sender]++
        );

        emit LogCached(
            msg.sender,
            _id,
            msg.value
        );
    }

    /**
     * @notice  The following functions provide backwards-compatibility
     *          with previous Provable connectors.
     *
     */
    function setProofType(byte _proofType)
        external
    {
        setCustomProofType(_proofType);
    }

    function removeCbAddress(address _callbackAddress)
        external
    {
        removeCallbackAddress(_callbackAddress);
    }

    function cbAddresses(address _address)
        external
        view
        returns (byte)
    {
        return callbackAddresses[_address];
    }


    function cbAddress()
        public
        view
        returns (address _callbackAddress)
    {
        if (callbackAddresses[tx.origin] != 0)
            _callbackAddress = tx.origin;
    }

    function addCbAddress(
        address _newCallbackAddress,
        byte _addressType
    )
        external
    {
        addCallbackAddress(
            _newCallbackAddress,
            _addressType
        );
    }

    function addCbAddress(
        address _newCallbackAddress,
        byte _addressType,
        bytes _proof
    )
        external
    {
        addCallbackAddress(
            _newCallbackAddress,
            _addressType,
            _proof
        );
    }

    function addDSource(
        string _datasourceName,
        uint256 _multiplier
    )
        external
    {
        addDatasource(
            _datasourceName,
            _multiplier
        );
    }

    function multiAddDSource(
        bytes32[] _datasourceHashes,
        uint256[] _multipliers
    )
        external
    {
        multiAddDatasources(
            _datasourceHashes,
            _multipliers
        );
    }

    function multisetProofType(
        uint256[] _proofTypes,
        address[] _addresses
    )
        external
    {
        multiSetProofTypes(
            _proofTypes,
            _addresses
        );
    }

    function multisetCustomGasPrice(
        uint256[] _gasPrice,
        address[] _addr
    )
        external
    {
        multiSetCustomGasPrices(
            _gasPrice,
            _addr
        );
    }

    function randomDS_getSessionPubKeyHash()
        external
        view
        returns (bytes32)
    {
        return randomDS_getSessionPublicKeyHash();
    }


    function randomDS_updateSessionPubKeysHash(
        bytes32[] _newSessionPublicKeyHash
    )
        external
    {
        randomDS_updateSessionPublicKeyHash(_newSessionPublicKeyHash);
    }

    function query_withGasLimit(
        uint256 _timestamp,
        string _datasource,
        string _arg,
        uint256 _gasLimit
    )
        payable
        external
        returns (bytes32 _id)
    {
        return query1(
            _timestamp,
            _datasource,
            _arg,
            _gasLimit
        );
    }

    function query1_withGasLimit(
        uint256 _timestamp,
        string _datasource,
        string _arg,
        uint256 _gasLimit
    )
        payable
        external
        returns (bytes32 _id)
    {
        return query1(
            _timestamp,
            _datasource,
            _arg,
            _gasLimit
        );
    }

    function query2_withGasLimit(
        uint256 _timestamp,
        string _datasource,
        string _arg1,
        string _arg2,
        uint256 _gasLimit
    )
        payable
        external
        returns (bytes32 _id)
    {
        return query2(
            _timestamp,
            _datasource,
            _arg1,
            _arg2,
            _gasLimit
        );
    }

    function queryN_withGasLimit(
        uint256 _timestamp,
        string _datasource,
        bytes _args,
        uint256 _gasLimit
    )
        payable
        external
        returns (bytes32 _id)
    {
        return queryN(
            _timestamp,
            _datasource,
            _args,
            _gasLimit
        );
    }
}