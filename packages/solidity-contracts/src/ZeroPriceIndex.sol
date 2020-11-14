/**
 * Source Code first verified at https://etherscan.io on Monday, March 25, 2019
 (UTC) */

pragma solidity ^0.4.25;

/*******************************************************************************
 *
 * Copyright (c) 2019 Decentralization Authority MDAO.
 * Released under the MIT License.
 *
 * ZeroPriceIndex - Management system for maintaining the "official" community 
 *                  trade prices of ERC tokens & collectibles listed within 
 *                  the ZeroCache.
 *
 * Version 19.3.24
 *
 * https://d14na.org
 * <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="275452575748555367431613494609485540">[email protected]</a>
 */


/*******************************************************************************
 *
 * SafeMath
 */
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


/*******************************************************************************
 *
 * ERC Token Standard #20 Interface
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
 */
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


/*******************************************************************************
 *
 * ApproveAndCallFallBack
 *
 * Contract function to receive approval and execute function in one call
 * (borrowed from MiniMeToken)
 */
contract ApproveAndCallFallBack {
    function approveAndCall(address spender, uint tokens, bytes data) public;
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}


/*******************************************************************************
 *
 * Owned contract
 */
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);

        emit OwnershipTransferred(owner, newOwner);

        owner = newOwner;

        newOwner = address(0);
    }
}


/*******************************************************************************
 * 
 * Zer0netDb Interface
 */
contract Zer0netDbInterface {
    /* Interface getters. */
    function getAddress(bytes32 _key) external view returns (address);
    function getBool(bytes32 _key)    external view returns (bool);
    function getBytes(bytes32 _key)   external view returns (bytes);
    function getInt(bytes32 _key)     external view returns (int);
    function getString(bytes32 _key)  external view returns (string);
    function getUint(bytes32 _key)    external view returns (uint);

    /* Interface setters. */
    function setAddress(bytes32 _key, address _value) external;
    function setBool(bytes32 _key, bool _value) external;
    function setBytes(bytes32 _key, bytes _value) external;
    function setInt(bytes32 _key, int _value) external;
    function setString(bytes32 _key, string _value) external;
    function setUint(bytes32 _key, uint _value) external;

    /* Interface deletes. */
    function deleteAddress(bytes32 _key) external;
    function deleteBool(bytes32 _key) external;
    function deleteBytes(bytes32 _key) external;
    function deleteInt(bytes32 _key) external;
    function deleteString(bytes32 _key) external;
    function deleteUint(bytes32 _key) external;
}


/*******************************************************************************
 *
 * @notice Zero(Cache) Price Index
 *
 * @dev Manages the current trade prices of ZeroCache tokens.
 */
contract ZeroPriceIndex is Owned {
    using SafeMath for uint;

    /* Initialize predecessor contract. */
    address private _predecessor;

    /* Initialize successor contract. */
    address private _successor;
    
    /* Initialize revision number. */
    uint private _revision;

    /* Initialize Zer0net Db contract. */
    Zer0netDbInterface private _zer0netDb;

    /**
     * Set Zero(Cache) Price Index namespaces
     * 
     * NOTE: Keep all namespaces lowercase.
     */
    string private _namespace = 'zpi';

    /* Set Dai Stablecoin (trade pair) base. */
    string private _TRADE_PAIR_BASE = 'DAI';

    /**
     * Initialize Core Tokens
     * 
     * NOTE: All tokens are traded against DAI Stablecoin.
     */
    string[4] _CORE_TOKENS = [
        '0GOLD',    // ZeroGold
        '0xBTC',    // 0xBitcoin Token
        'WBTC',     // Wrapped Bitcoin
        'WETH'      // Wrapped Ether
    ];

    /* Initialize price update notifications. */
    event PriceUpdate(
        bytes32 indexed dataId, 
        uint value
    );

    /* Initialize price list update notifications. */
    event PriceListUpdate(
        bytes32 indexed listId, 
        bytes ipfsHash
    );

    /***************************************************************************
     *
     * Constructor
     */
    constructor() public {
        /* Initialize Zer0netDb (eternal) storage database contract. */
        // NOTE We hard-code the address here, since it should never change.
        _zer0netDb = Zer0netDbInterface(0xE865Fe1A1A3b342bF0E2fcB11fF4E3BCe58263af);

        /* Initialize (aname) hash. */
        bytes32 hash = keccak256(abi.encodePacked('aname.', _namespace));

        /* Set predecessor address. */
        _predecessor = _zer0netDb.getAddress(hash);

        /* Verify predecessor address. */
        if (_predecessor != 0x0) {
            /* Retrieve the last revision number (if available). */
            uint lastRevision = ZeroPriceIndex(_predecessor).getRevision();
            
            /* Set (current) revision number. */
            _revision = lastRevision + 1;
        }
    }

    /**
     * @dev Only allow access to an authorized Zer0net administrator.
     */
    modifier onlyAuthBy0Admin() {
        /* Verify write access is only permitted to authorized accounts. */
        require(_zer0netDb.getBool(keccak256(
            abi.encodePacked(msg.sender, '.has.auth.for.', _namespace))) == true);

        _;      // function code is inserted here
    }
    
    /**
     * THIS CONTRACT DOES NOT ACCEPT DIRECT ETHER
     */
    function () public payable {
        /* Cancel this transaction. */
        revert('Oops! Direct payments are NOT permitted here.');
    }


    /***************************************************************************
     * 
     * GETTERS
     * 
     */

    /**
     * Get Trade Price (Token)
     * 
     * NOTE: All trades are made against DAI stablecoin.
     */
    function tradePriceOf(
        string _token
    ) external view returns (uint price) {
        /* Set hash. */
        bytes32 hash = keccak256(abi.encodePacked(
            _namespace, '.', 
            _token, '.', 
            _TRADE_PAIR_BASE
        ));

        /* Retrieve value from Zer0net Db. */
        price = _zer0netDb.getUint(hash);
    }

    /**
     * Get Trade Price (Collectible)
     * 
     * NOTE: All trades are made against DAI stablecoin.
     * 
     * An up-to-date trade price index of the TOP 100 collectibles 
     * listed in the ZeroCache.
     * (the complete listing is available via IPFS, see below)
     */
    function tradePriceOf(
        address _token,
        uint _tokenId
    ) external view returns (uint price) {
        /* Set hash. */
        bytes32 hash = keccak256(abi.encodePacked(
            _namespace, '.', 
            _token, '.', 
            _tokenId
        ));

        /* Retrieve value from Zer0net Db. */
        price = _zer0netDb.getUint(hash);
    }

    /**
     * Get Trade Price List(s)
     * 
     * An real-time trade price index of the ZeroCache TOP tokens:
     *     1. ERC-20
     *     2. ERC-721 (Collectible)
     * 
     * Also, returns the IPFS address(es) to complete 
     * ERC-721 (Collectible) trade price histories.
     * 
     * Available Price List Ids [sha3 db keys]:
     * (prefix = `zpi.ipfs.`)
     *     1. ...total          [0xd7ea7671063c5fb2c6913499e32dc9fa57ebeaeaea57318fb1c5d85fc2b7bd9a]
     *     2. ...erc20.total    [0xe2a4d3615b13317181f86cf96dd85e05c8b88398081afe4c28bb7a614cb15d0f]
     *     3. ...erc20.top100   [0x6e06845611588cbefd856f969d489fd79dfc0f11bdd8b6c033a386ba5629c7e8]
     *     4. ...erc20.top1000  [0xa591401b1b623d8a9e8e5807dbd9a79cd4ede4270274bbabc20b15415a9386e7]
     *     5. ...erc721.total   [0xe6685143353a7b4ee6f59925a757017f2638c0ed4cb9376ec8e6e37b4995aed2]
     *     6. ...erc721.top100  [0xe75054ff8b05a4e8ebaeca5b43579e9f59fb910b50615bd3f225a8fe8c8aea49]
     *     7. ...erc721.top1000 [0xdae2a49474830953c576849e09151b23c15dd3f8c4e98fbcd27c13b9f5739930]
     * 
     * NOTE: All trades are made against DAI stablecoin.
     */
    function tradePriceList(
        string _listId
    ) external view returns (bytes ipfsHash) {
        /* Initailze data id. */
        bytes32 dataId = 0x0;
        
        /* Set hash. */
        dataId = keccak256(abi.encodePacked(
            _namespace, 
            '.ipfs.', 
            _listId
        ));

        /* Validate data id. */
        if (dataId == 0x0) {
            /* Default to `...total`. */
            dataId = 0xd7ea7671063c5fb2c6913499e32dc9fa57ebeaeaea57318fb1c5d85fc2b7bd9a;
        }
        
        /* Retrun IPFS hash. */
        ipfsHash = _zer0netDb.getBytes(dataId);
    }

    /**
     * Trade Price Summary
     * 
     * Retrieves the trade prices for the TOP 100 tokens and collectibles.
     * 
     * NOTE: All trades are made against DAI stablecoin.
     */
    function tradePriceSummary() external view returns (
        uint[4] summary
    ) {
        /* Initailze hash. */
        bytes32 hash = 0x0;
        
        /* Set hash. */
        hash = keccak256(abi.encodePacked(
            _namespace, 
            '.0GOLD.', 
            _TRADE_PAIR_BASE
        ));

        /* Retrieve value from Zer0net Db. */
        summary[0] = _zer0netDb.getUint(hash);

        /* Set hash. */
        hash = keccak256(abi.encodePacked(
            _namespace, 
            '.0xBTC.', 
            _TRADE_PAIR_BASE
        ));

        /* Retrieve value from Zer0net Db. */
        summary[1] = _zer0netDb.getUint(hash);

        /* Set hash. */
        hash = keccak256(abi.encodePacked(
            _namespace, 
            '.WBTC.', 
            _TRADE_PAIR_BASE
        ));

        /* Retrieve value from Zer0net Db. */
        summary[2] = _zer0netDb.getUint(hash);

        /* Set hash. */
        hash = keccak256(abi.encodePacked(
            _namespace, 
            '.WETH.', 
            _TRADE_PAIR_BASE
        ));

        /* Retrieve value from Zer0net Db. */
        summary[3] = _zer0netDb.getUint(hash);
    }

    /**
     * Get Revision (Number)
     */
    function getRevision() public view returns (uint) {
        return _revision;
    }

    /**
     * Get Predecessor (Address)
     */
    function getPredecessor() public view returns (address) {
        return _predecessor;
    }
    
    /**
     * Get Successor (Address)
     */
    function getSuccessor() public view returns (address) {
        return _successor;
    }
    

    /***************************************************************************
     * 
     * SETTERS
     * 
     */

    /**
     * Set Trade Price (Token)
     * 
     * Keys for trade pairs are encoded using the 'exact' symbol,
     * as listed in their respective contract:
     * 
     *     ZeroGold `zpi.0GOLD.DAI`
     *     0x3cf0b17677519ce01176e2dde0338a4d8962be5853b2d83217cc99c527d5629a
     * 
     *     0xBitcoin Token `zpi.0xBTC.DAI`
     *     0x9b7396ba7848459ddbaa41b35e502a95d1df654913a5b67c4e7870bd40064612
     * 
     *     Wrapped Ether `zpi.WBTC.DAI`
     *     0x03f90c9c29c9a65eabac4ea5eb624068469de88b5b8557eae0c8778367e8dfae
     * 
     *     Wrapped Ether `zpi.WETH.DAI`
     *     0xf2349fd68dcc221f5a12142038d2619c9f73c8e7e95afcd8e0bd5bcd33b291bb
     * 
     * NOTE: All trades are made against DAI stablecoin.
     */
    function setTradePrice(
        string _token,
        uint _value
    ) onlyAuthBy0Admin external returns (bool success) {
        /* Calculate data id. */
        bytes32 dataId = keccak256(abi.encodePacked(
            _namespace, '.', 
            _token, '.', 
            _TRADE_PAIR_BASE
        ));

        /* Set value in Zer0net Db. */
        _zer0netDb.setUint(dataId, _value);
        
        /* Broadcast event. */
        emit PriceUpdate(
            dataId, 
            _value
        );
        
        /* Return success. */
        return true;
    }
    
    /**
     * Set Trade Price (Collectible)
     * 
     * NOTE: All trades are made against DAI stablecoin.
     */
    function setTradePrice(
        address _token,
        uint _tokenId,
        uint _value
    ) onlyAuthBy0Admin external returns (bool success) {
        /* Calculate data id. */
        bytes32 dataId = keccak256(abi.encodePacked(
            _namespace, '.', 
            _token, '.', 
            _tokenId
        ));

        /* Set value in Zer0net Db. */
        _zer0netDb.setUint(dataId, _value);
        
        /* Broadcast event. */
        emit PriceUpdate(
            dataId, 
            _value
        );
        
        /* Return success. */
        return true;
    }
    
    /**
     * Set Trade Price (IPFS) List
     * 
     * NOTE: All trades are made against DAI stablecoin.
     */
    function setTradePriceList(
        string _listId,
        bytes _ipfsHash
    ) onlyAuthBy0Admin external returns (bool success) {
        /* Set hash. */
        bytes32 hash = keccak256(abi.encodePacked(
            _namespace, 
            '.ipfs.', 
            _listId
        ));
        
        /* Set value in Zer0net Db. */
        _zer0netDb.setBytes(hash, _ipfsHash);
        
        /* Broadcast event. */
        emit PriceListUpdate(
            hash, 
            _ipfsHash
        );
        
        /* Return success. */
        return true;
    }
    
    /**
     * Set Core Trade Prices
     * 
     * NOTE: All trades are made against DAI stablecoin.
     * 
     * NOTE: Use of `string[]` is still experimental, 
     *       so we are required to `setCorePrices` by sending
     *       `_values` in the proper format.
     */
    function setAllCoreTradePrices(
        uint[] _values
    ) onlyAuthBy0Admin external returns (bool success) {
        /* Iterate Core Tokens for updating. */    
        for (uint8 i = 0; i < _CORE_TOKENS.length; i++) {
            /* Set data id. */
            bytes32 dataId = keccak256(abi.encodePacked(
                _namespace, '.', 
                _CORE_TOKENS[i], '.', 
                _TRADE_PAIR_BASE
            ));
    
            /* Set value in Zer0net Db. */
            _zer0netDb.setUint(dataId, _values[i]);
            
            /* Broadcast event. */
            emit PriceUpdate(
                dataId, 
                _values[i]
            );
        }
        
        /* Return success. */
        return true;
    }
    
    /**
     * Set (Multiple) Trade Prices
     * 
     * This will be used for ERC-721 Collectible tokens.
     * 
     * NOTE: All trades are made against DAI stablecoin.
     */
    function setTokenTradePrices(
        address[] _tokens,
        uint[] _tokenIds,
        uint[] _values
    ) onlyAuthBy0Admin external returns (bool success) {
        /* Iterate Core Tokens for updating. */    
        for (uint8 i = 0; i < _tokens.length; i++) {
            /* Set data id. */
            bytes32 dataId = keccak256(abi.encodePacked(
                _namespace, '.', 
                _tokens[i], '.', 
                _tokenIds[i]
            ));
    
            /* Set value in Zer0net Db. */
            _zer0netDb.setUint(dataId, _values[i]);
            
            /* Broadcast event. */
            emit PriceUpdate(
                dataId, 
                _values[i]
            );
        }
        
        /* Return success. */
        return true;
    }

    /**
     * Set Successor
     * 
     * This is the contract address that replaced this current instnace.
     */
    function setSuccessor(
        address _newSuccessor
    ) onlyAuthBy0Admin external returns (bool success) {
        /* Set successor contract. */
        _successor = _newSuccessor;
        
        /* Return success. */
        return true;
    }


    /***************************************************************************
     * 
     * INTERFACES
     * 
     */

    /**
     * Supports Interface (EIP-165)
     * 
     * (see: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md)
     * 
     * NOTE: Must support the following conditions:
     *       1. (true) when interfaceID is 0x01ffc9a7 (EIP165 interface)
     *       2. (false) when interfaceID is 0xffffffff
     *       3. (true) for any other interfaceID this contract implements
     *       4. (false) for any other interfaceID
     */
    function supportsInterface(
        bytes4 _interfaceID
    ) external pure returns (bool) {
        /* Initialize constants. */
        bytes4 InvalidId = 0xffffffff;
        bytes4 ERC165Id = 0x01ffc9a7;

        /* Validate condition #2. */
        if (_interfaceID == InvalidId) {
            return false;
        }

        /* Validate condition #1. */
        if (_interfaceID == ERC165Id) {
            return true;
        }
        
        // TODO Add additional interfaces here.
        
        /* Return false (for condition #4). */
        return false;
    }


    /***************************************************************************
     * 
     * UTILITIES
     * 
     */

    /**
     * Transfer Any ERC20 Token
     *
     * @notice Owner can transfer out any accidentally sent ERC20 tokens.
     *
     * @dev Provides an ERC20 interface, which allows for the recover
     *      of any accidentally sent ERC20 tokens.
     */
    function transferAnyERC20Token(
        address _tokenAddress, 
        uint _tokens
    ) public onlyOwner returns (bool success) {
        return ERC20Interface(_tokenAddress).transfer(owner, _tokens);
    }
}