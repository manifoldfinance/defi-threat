/**
 * Source Code first verified at https://etherscan.io on Sunday, March 17, 2019
 (UTC) */

pragma solidity ^0.4.25;

/*******************************************************************************
 *
 * Copyright (c) 2019 Decentralization Authority MDAO.
 * Released under the MIT License.
 *
 * TL;DR - A simple posts manager.
 * 
 *         TL;DR is slang for "Too Long; Didn't Read"
 *
 * Version 19.3.15
 *
 * https://d14na.org
 * <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="20535550504f5254604411144e410e4f5247">[email protected]</a>
 */


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
 * ECRecovery
 *
 * Contract function to validate signature of pre-approved token transfers.
 * (borrowed from LavaWallet)
 */
contract ECRecovery {
    function recover(bytes32 hash, bytes sig) public pure returns (address);
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
 * @notice TL;DR
 *
 * @dev Simple key-value store of short posts.
 */
contract TLDR is Owned {
    /* Initialize predecessor contract. */
    address private _predecessor;

    /* Initialize successor contract. */
    address private _successor;
    
    /* Initialize revision number. */
    uint private _revision;

    /* Initialize Zer0net Db contract. */
    Zer0netDbInterface private _zer0netDb;
    
    /* Set namespace. */
    string _namespace = 'tldr';

    event Posted(
        bytes32 indexed postId,
        address indexed owner,
        bytes body
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
            uint lastRevision = TLDR(_predecessor).getRevision();
            
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
     * ACTIONS
     * 
     */

    /**
     * Save Post
     */
    function savePost(
        string _title,
        bytes _body
    ) external returns (bool success) {
        _setPost(msg.sender, _title, _body);

        /* Return success. */
        return true;
    }
    
    // function addFavorite(
    //     bytes32 _postId
    // ) external returns (bool success) {
    //     bytes32[] storage favorites = _favorites[msg.sender];
        
    //     /* Add to favorites. */
    //     favorites.push(_postId);
        
    //     /* Return success. */
    //     return true;
    // }

    // function removeFavorite(
    //     bytes32 _postId
    // ) external returns (bool success) {
    //     bytes32[] storage favorites = _favorites[msg.sender];
        
    //     /* Add to favorites. */
    //     favorites.push(_postId);
        
    //     /* Return success. */
    //     return true;
    // }


    /***************************************************************************
     * 
     * GETTERS
     * 
     */

    /**
     * Get Post (Metadata)
     * 
     * Retrieves the location and block number of the post data
     * stored for the specified `_postId`.
     * 
     * NOTE: DApps can then read the `Posted` event from the Ethereum 
     *       Event Log, at the specified point, to recover the stored metadata.
     */
    function getPost(
        bytes32 _postId
    ) external view returns (
        address location,
        uint blockNum
    ) {
        /* Retrieve location. */
        location = _zer0netDb.getAddress(_postId);

        /* Retrieve block number. */
        blockNum = _zer0netDb.getUint(_postId);
    }

    // function getFavorites(
    //     address _owner
    // ) external view returns (bytes32[] favorites) {
    //     favorites = _favorites[_owner];
    // }

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
     * Set Post (Metadata)
     * 
     * Stores the location and block number of the metadata being added 
     * to the Ethereum Event Log.
     * 
     * Cost to Broadcast an Event
     * ---------------------------------------
     *         8 gas per byte of `_data`
     *     + 375 gas per LOG operation
     *     + 375 gas per topic
     */
    function _setPost(
        address _owner, 
        string _title,
        bytes _body
    ) private returns (bool success) {
        /* Calculate post id. */
        bytes32 postId = calcPostId(_owner, _title);
        
        /* Set location. */
        _zer0netDb.setAddress(postId, address(this));

        /* Set block number. */
        _zer0netDb.setUint(postId, block.number);

        /* Broadcast event. */
        emit Posted(postId, _owner, _body);

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
     * Calculate Post Id
     */
    function calcPostId(
        address _owner,
        string _title
    ) public view returns (
        bytes32 postId
    ) {
        /* Calculate the post id. */
        postId = keccak256(abi.encodePacked(
            _namespace, '.', _owner, '.', _title));
    }

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