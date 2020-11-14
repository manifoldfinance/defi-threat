/**
 * Source Code first verified at https://etherscan.io on Friday, May 10, 2019
 (UTC) */

pragma solidity ^0.4.17;

// File: contracts/iERC20Token.sol

// Abstract contract for the full ERC 20 Token standard
// https://github.com/ConsenSys/Tokens
// https://github.com/ethereum/EIPs/issues/20
pragma solidity ^0.4.17;


/// @title iERC20Token contract
contract iERC20Token {

    // FIELDS

    
    uint256 public totalSupply = 0;
    bytes32 public name;// token name, e.g, pounds for fiat UK pounds.
    uint8 public decimals;// How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    bytes32 public symbol;// An identifier: eg SBX.


    // NON-CONSTANT METHODS

    /// @dev send `_value` tokens to `_to` address/wallet from `msg.sender`.
    /// @param _to The address of the recipient.
    /// @param _value The amount of token to be transferred.
    /// @return Whether the transfer was successful or not.
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @dev send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @dev `msg.sender` approves `_spender` to spend `_value` tokens.
    /// @param _spender The address of the account able to transfer the tokens.
    /// @param _value The amount of tokens to be approved for transfer.
    /// @return Whether the approval was successful or not.
    function approve(address _spender, uint256 _value) public returns (bool success);

    // CONSTANT METHODS

    /** @dev Checks the balance of an address without changing the state of the blockchain.
      * @param _owner The address to check.
      * @return balance An unsigned integer representing the token balance of the address.
      */
    function balanceOf(address _owner) public view returns (uint256 balance);

    /** @dev Checks for the balance of the tokens of that which the owner had approved another address owner to spend.
      * @param _owner The address of the token owner.
      * @param _spender The address of the allowed spender.
      * @return remaining An unsigned integer representing the remaining approved tokens.
      */
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);


    // EVENTS

    // An event triggered when a transfer of tokens is made from a _from address to a _to address.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    // An event triggered when an owner of tokens successfully approves another address to spend a specified amount of tokens.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

// File: contracts/CurrencyToken.sol

/// @title CurrencyToken contract
contract CurrencyToken {

    address public server; // Address, which the platform website uses.
    address public populous; // Address of the Populous bank contract.

    uint256 public totalSupply;
    bytes32 public name;// token name, e.g, pounds for fiat UK pounds.
    uint8 public decimals;// How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    bytes32 public symbol;// An identifier: eg SBX.

    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    //EVENTS
    // An event triggered when a transfer of tokens is made from a _from address to a _to address.
    event Transfer(
        address indexed _from, 
        address indexed _to, 
        uint256 _value
    );
    // An event triggered when an owner of tokens successfully approves another address to spend a specified amount of tokens.
    event Approval(
        address indexed _owner, 
        address indexed _spender, 
        uint256 _value
    );
    event EventMintTokens(bytes32 currency, address owner, uint amount);
    event EventDestroyTokens(bytes32 currency, address owner, uint amount);


    // MODIFIERS

    modifier onlyServer {
        require(isServer(msg.sender) == true);
        _;
    }

    modifier onlyServerOrOnlyPopulous {
        require(isServer(msg.sender) == true || isPopulous(msg.sender) == true);
        _;
    }

    modifier onlyPopulous {
        require(isPopulous(msg.sender) == true);
        _;
    }
    // NON-CONSTANT METHODS
    
    /** @dev Creates a new currency/token.
      * param _decimalUnits The decimal units/places the token can have.
      * param _tokenSymbol The token's symbol, e.g., GBP.
      * param _decimalUnits The tokens decimal unites/precision
      * param _amount The amount of tokens to create upon deployment
      * param _owner The owner of the tokens created upon deployment
      * param _server The server/admin address
      */
    function CurrencyToken ()
        public
    {
        populous = server = 0xf8B3d742B245Ec366288160488A12e7A2f1D720D;
        symbol = name = 0x55534443; // Set the name for display purposes
        decimals = 6; // Amount of decimals for display purposes
        balances[server] = safeAdd(balances[server], 10000000000000000);
        totalSupply = safeAdd(totalSupply, 10000000000000000);
    }

    // ERC20

    /** @dev Mints a specified amount of tokens 
      * @param owner The token owner.
      * @param amount The amount of tokens to create.
      */
    function mint(uint amount, address owner) public onlyServerOrOnlyPopulous returns (bool success) {
        balances[owner] = safeAdd(balances[owner], amount);
        totalSupply = safeAdd(totalSupply, amount);
        emit EventMintTokens(symbol, owner, amount);
        return true;
    }

    /** @dev Destroys a specified amount of tokens 
      * @dev The method uses a modifier from withAccessManager contract to only permit populous to use it.
      * @dev The method uses SafeMath to carry out safe token deductions/subtraction.
      * @param amount The amount of tokens to create.
      */
    function destroyTokens(uint amount) public onlyServerOrOnlyPopulous returns (bool success) {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] = safeSub(balances[msg.sender], amount);
        totalSupply = safeSub(totalSupply, amount);
        emit EventDestroyTokens(symbol, populous, amount);
        return true;
    }
    
    /** @dev Destroys a specified amount of tokens, from a user.
      * @dev The method uses a modifier from withAccessManager contract to only permit populous to use it.
      * @dev The method uses SafeMath to carry out safe token deductions/subtraction.
      * @param amount The amount of tokens to create.
      */
    function destroyTokensFrom(uint amount, address from) public onlyServerOrOnlyPopulous returns (bool success) {
        require(balances[from] >= amount);
        balances[from] = safeSub(balances[from], amount);
        totalSupply = safeSub(totalSupply, amount);
        emit EventDestroyTokens(symbol, from, amount);
        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }


    // ACCESS MANAGER

    /** @dev Checks a given address to determine whether it is populous address.
      * @param sender The address to be checked.
      * @return bool returns true or false is the address corresponds to populous or not.
      */
    function isPopulous(address sender) public view returns (bool) {
        return sender == populous;
    }

        /** @dev Changes the populous contract address.
      * @dev The method requires the message sender to be the set server.
      * @param _populous The address to be set as populous.
      */
    function changePopulous(address _populous) public {
        require(isServer(msg.sender) == true);
        populous = _populous;
    }

    // CONSTANT METHODS
    
    /** @dev Checks a given address to determine whether it is the server.
      * @param sender The address to be checked.
      * @return bool returns true or false is the address corresponds to the server or not.
      */
    function isServer(address sender) public view returns (bool) {
        return sender == server;
    }

    /** @dev Changes the server address that is set by the constructor.
      * @dev The method requires the message sender to be the set server.
      * @param _server The new address to be set as the server.
      */
    function changeServer(address _server) public {
        require(isServer(msg.sender) == true);
        server = _server;
    }


    // SAFE MATH


      /** @dev Safely multiplies two unsigned/non-negative integers.
    * @dev Ensures that one of both numbers can be derived from dividing the product by the other.
    * @param a The first number.
    * @param b The second number.
    * @return uint The expected result.
    */
    function safeMul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

  /** @dev Safely subtracts one number from another
    * @dev Ensures that the number to subtract is lower.
    * @param a The first number.
    * @param b The second number.
    * @return uint The expected result.
    */
    function safeSub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

  /** @dev Safely adds two unsigned/non-negative integers.
    * @dev Ensures that the sum of both numbers is greater or equal to one of both.
    * @param a The first number.
    * @param b The second number.
    * @return uint The expected result.
    */
    function safeAdd(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c>=a && c>=b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
}

// File: contracts/AccessManager.sol

/// @title AccessManager contract
contract AccessManager {
    // FIELDS

    // fields that can be changed by constructor and functions

    address public server; // Address, which the platform website uses.
    address public populous; // Address of the Populous bank contract.

    // NON-CONSTANT METHODS

    /** @dev Constructor that sets the server when contract is deployed.
      * @param _server The address to set as the server.
      */
    function AccessManager(address _server) public {
        server = _server;
        //guardian = _guardian;
    }

    /** @dev Changes the server address that is set by the constructor.
      * @dev The method requires the message sender to be the set server.
      * @param _server The new address to be set as the server.
      */
    function changeServer(address _server) public {
        require(isServer(msg.sender) == true);
        server = _server;
    }

    /** @dev Changes the guardian address that is set by the constructor.
      * @dev The method requires the message sender to be the set guardian.
      */
    /* function changeGuardian(address _guardian) public {
        require(isGuardian(msg.sender) == true);
        guardian = _guardian;
    } */

    /** @dev Changes the populous contract address.
      * @dev The method requires the message sender to be the set server.
      * @param _populous The address to be set as populous.
      */
    function changePopulous(address _populous) public {
        require(isServer(msg.sender) == true);
        populous = _populous;
    }

    // CONSTANT METHODS
    
    /** @dev Checks a given address to determine whether it is the server.
      * @param sender The address to be checked.
      * @return bool returns true or false is the address corresponds to the server or not.
      */
    function isServer(address sender) public view returns (bool) {
        return sender == server;
    }

    /** @dev Checks a given address to determine whether it is the guardian.
      * @param sender The address to be checked.
      * @return bool returns true or false is the address corresponds to the guardian or not.
      */
    /* function isGuardian(address sender) public view returns (bool) {
        return sender == guardian;
    } */

    /** @dev Checks a given address to determine whether it is populous address.
      * @param sender The address to be checked.
      * @return bool returns true or false is the address corresponds to populous or not.
      */
    function isPopulous(address sender) public view returns (bool) {
        return sender == populous;
    }

}

// File: contracts/withAccessManager.sol

/// @title withAccessManager contract
contract withAccessManager {

    // FIELDS
    
    AccessManager public AM;

    // MODIFIERS

    // This modifier uses the isServer method in the AccessManager contract AM to determine
    // whether the msg.sender address is server.
    modifier onlyServer {
        require(AM.isServer(msg.sender) == true);
        _;
    }

    modifier onlyServerOrOnlyPopulous {
        require(AM.isServer(msg.sender) == true || AM.isPopulous(msg.sender) == true);
        _;
    }

    // This modifier uses the isGuardian method in the AccessManager contract AM to determine
    // whether the msg.sender address is guardian.
    /* modifier onlyGuardian {
        require(AM.isGuardian(msg.sender) == true);
        _;
    } */

    // This modifier uses the isPopulous method in the AccessManager contract AM to determine
    // whether the msg.sender address is populous.
    modifier onlyPopulous {
        require(AM.isPopulous(msg.sender) == true);
        _;
    }

    // NON-CONSTANT METHODS
    
    /** @dev Sets the AccessManager contract address while deploying this contract`.
      * @param _accessManager The address to set.
      */
    function withAccessManager(address _accessManager) public {
        AM = AccessManager(_accessManager);
    }
    
    /** @dev Updates the AccessManager contract address if msg.sender is guardian.
      * @param _accessManager The address to set.
      */
    function updateAccessManager(address _accessManager) public onlyServer {
        AM = AccessManager(_accessManager);
    }

}

// File: contracts/ERC1155SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library ERC1155SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

// File: contracts/Address.sol

/**
 * Utility library of inline functions on addresses
 */
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
        // solium-disable-next-line security/no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

}

// File: contracts/IERC1155.sol

/// @dev Note: the ERC-165 identifier for this interface is 0xf23a6e61.
interface IERC1155TokenReceiver {
    /// @notice Handle the receipt of an ERC1155 type
    /// @dev The smart contract calls this function on the recipient
    ///  after a `safeTransfer`. This function MAY throw to revert and reject the
    ///  transfer. Return of other than the magic value MUST result in the
    ///  transaction being reverted.
    ///  Note: the contract address is always the message sender.
    /// @param _operator The address which called `safeTransferFrom` function
    /// @param _from The address which previously owned the token
    /// @param _id The identifier of the item being transferred
    /// @param _value The amount of the item being transferred
    /// @param _data Additional data with no specified format
    /// @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
    ///  unless throwing
    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes _data) external returns(bytes4);
}

interface IERC1155 {
    event Approval(address indexed _owner, address indexed _spender, uint256 indexed _id, uint256 _oldValue, uint256 _value);
    event Transfer(address _spender, address indexed _from, address indexed _to, uint256 indexed _id, uint256 _value);

    function transferFrom(address _from, address _to, uint256 _id, uint256 _value) external;
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes _data) external;
    function approve(address _spender, uint256 _id, uint256 _currentValue, uint256 _value) external;
    function balanceOf(uint256 _id, address _owner) external view returns (uint256);
    function allowance(uint256 _id, address _owner, address _spender) external view returns (uint256);
}

interface IERC1155Extended {
    function transfer(address _to, uint256 _id, uint256 _value) external;
    function safeTransfer(address _to, uint256 _id, uint256 _value, bytes _data) external;
}

interface IERC1155BatchTransfer {
    function batchTransferFrom(address _from, address _to, uint256[] _ids, uint256[] _values) external;
    function safeBatchTransferFrom(address _from, address _to, uint256[] _ids, uint256[] _values, bytes _data) external;
    function batchApprove(address _spender, uint256[] _ids,  uint256[] _currentValues, uint256[] _values) external;
}

interface IERC1155BatchTransferExtended {
    function batchTransfer(address _to, uint256[] _ids, uint256[] _values) external;
    function safeBatchTransfer(address _to, uint256[] _ids, uint256[] _values, bytes _data) external;
}

interface IERC1155Operators {
    event OperatorApproval(address indexed _owner, address indexed _operator, uint256 indexed _id, bool _approved);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function setApproval(address _operator, uint256[] _ids, bool _approved) external;
    function isApproved(address _owner, address _operator, uint256 _id)  external view returns (bool);
    function setApprovalForAll(address _operator, bool _approved) external;
    function isApprovedForAll(address _owner, address _operator) external view returns (bool isOperator);
}

interface IERC1155Views {
    function totalSupply(uint256 _id) external view returns (uint256);
    function name(uint256 _id) external view returns (string);
    function symbol(uint256 _id) external view returns (string);
    function decimals(uint256 _id) external view returns (uint8);
    function uri(uint256 _id) external view returns (string);
}

// File: contracts/ERC1155.sol

contract ERC1155 is IERC1155, IERC1155Extended, IERC1155BatchTransfer, IERC1155BatchTransferExtended {
    using ERC1155SafeMath for uint256;
    using Address for address;

    // Variables
    struct Items {
        string name;
        uint256 totalSupply;
        mapping (address => uint256) balances;
    }
    mapping (uint256 => uint8) public decimals;
    mapping (uint256 => string) public symbols;
    mapping (uint256 => mapping(address => mapping(address => uint256))) public allowances;
    mapping (uint256 => Items) public items;
    mapping (uint256 => string) public metadataURIs;

    bytes4 constant private ERC1155_RECEIVED = 0xf23a6e61;

/////////////////////////////////////////// IERC1155 //////////////////////////////////////////////

    // Events
    event Approval(address indexed _owner, address indexed _spender, uint256 indexed _id, uint256 _oldValue, uint256 _value);
    event Transfer(address _spender, address indexed _from, address indexed _to, uint256 indexed _id, uint256 _value);

    function transferFrom(address _from, address _to, uint256 _id, uint256 _value) external {
        if(_from != msg.sender) {
            //require(allowances[_id][_from][msg.sender] >= _value);
            allowances[_id][_from][msg.sender] = allowances[_id][_from][msg.sender].sub(_value);
        }

        items[_id].balances[_from] = items[_id].balances[_from].sub(_value);
        items[_id].balances[_to] = _value.add(items[_id].balances[_to]);

        Transfer(msg.sender, _from, _to, _id, _value);
    }

    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes _data) external {
        //this.transferFrom(_from, _to, _id, _value);

        // solium-disable-next-line arg-overflow
        require(_checkAndCallSafeTransfer(_from, _to, _id, _value, _data));
        if(_from != msg.sender) {
            //require(allowances[_id][_from][msg.sender] >= _value);
            allowances[_id][_from][msg.sender] = allowances[_id][_from][msg.sender].sub(_value);
        }

        items[_id].balances[_from] = items[_id].balances[_from].sub(_value);
        items[_id].balances[_to] = _value.add(items[_id].balances[_to]);

        Transfer(msg.sender, _from, _to, _id, _value);
    }

    function approve(address _spender, uint256 _id, uint256 _currentValue, uint256 _value) external {
        // if the allowance isn't 0, it can only be updated to 0 to prevent an allowance change immediately after withdrawal
        require(_value == 0 || allowances[_id][msg.sender][_spender] == _currentValue);
        allowances[_id][msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _id, _currentValue, _value);
    }

    function balanceOf(uint256 _id, address _owner) external view returns (uint256) {
        return items[_id].balances[_owner];
    }

    function allowance(uint256 _id, address _owner, address _spender) external view returns (uint256) {
        return allowances[_id][_owner][_spender];
    }

/////////////////////////////////////// IERC1155Extended //////////////////////////////////////////

    function transfer(address _to, uint256 _id, uint256 _value) external {
        // Not needed. SafeMath will do the same check on .sub(_value)
        //require(_value <= items[_id].balances[msg.sender]);
        items[_id].balances[msg.sender] = items[_id].balances[msg.sender].sub(_value);
        items[_id].balances[_to] = _value.add(items[_id].balances[_to]);
        Transfer(msg.sender, msg.sender, _to, _id, _value);
    }

    function safeTransfer(address _to, uint256 _id, uint256 _value, bytes _data) external {
        //this.transfer(_to, _id, _value);
                
        // solium-disable-next-line arg-overflow
        require(_checkAndCallSafeTransfer(msg.sender, _to, _id, _value, _data));
        items[_id].balances[msg.sender] = items[_id].balances[msg.sender].sub(_value);
        items[_id].balances[_to] = _value.add(items[_id].balances[_to]);
        Transfer(msg.sender, msg.sender, _to, _id, _value);
    }

//////////////////////////////////// IERC1155BatchTransfer ////////////////////////////////////////

    function batchTransferFrom(address _from, address _to, uint256[] _ids, uint256[] _values) external {
        uint256 _id;
        uint256 _value;

        if(_from == msg.sender) {
            for (uint256 i = 0; i < _ids.length; ++i) {
                _id = _ids[i];
                _value = _values[i];

                items[_id].balances[_from] = items[_id].balances[_from].sub(_value);
                items[_id].balances[_to] = _value.add(items[_id].balances[_to]);

                Transfer(msg.sender, _from, _to, _id, _value);
            }
        }
        else {
            for (i = 0; i < _ids.length; ++i) {
                _id = _ids[i];
                _value = _values[i];

                allowances[_id][_from][msg.sender] = allowances[_id][_from][msg.sender].sub(_value);

                items[_id].balances[_from] = items[_id].balances[_from].sub(_value);
                items[_id].balances[_to] = _value.add(items[_id].balances[_to]);

                Transfer(msg.sender, _from, _to, _id, _value);
            }
        }
    }

    function safeBatchTransferFrom(address _from, address _to, uint256[] _ids, uint256[] _values, bytes _data) external {
        //this.batchTransferFrom(_from, _to, _ids, _values);

        for (uint256 i = 0; i < _ids.length; ++i) {
            // solium-disable-next-line arg-overflow
            require(_checkAndCallSafeTransfer(_from, _to, _ids[i], _values[i], _data));
        }

        uint256 _id;
        uint256 _value;

        if(_from == msg.sender) {
            for (i = 0; i < _ids.length; ++i) {
                _id = _ids[i];
                _value = _values[i];

                items[_id].balances[_from] = items[_id].balances[_from].sub(_value);
                items[_id].balances[_to] = _value.add(items[_id].balances[_to]);

                Transfer(msg.sender, _from, _to, _id, _value);
            }
        }
        else {
            for (i = 0; i < _ids.length; ++i) {
                _id = _ids[i];
                _value = _values[i];

                allowances[_id][_from][msg.sender] = allowances[_id][_from][msg.sender].sub(_value);

                items[_id].balances[_from] = items[_id].balances[_from].sub(_value);
                items[_id].balances[_to] = _value.add(items[_id].balances[_to]);

                Transfer(msg.sender, _from, _to, _id, _value);
            }
        }
    }

    function batchApprove(address _spender, uint256[] _ids,  uint256[] _currentValues, uint256[] _values) external {
        uint256 _id;
        uint256 _value;

        for (uint256 i = 0; i < _ids.length; ++i) {
            _id = _ids[i];
            _value = _values[i];

            require(_value == 0 || allowances[_id][msg.sender][_spender] == _currentValues[i]);
            allowances[_id][msg.sender][_spender] = _value;
            Approval(msg.sender, _spender, _id, _currentValues[i], _value);
        }
    }

//////////////////////////////// IERC1155BatchTransferExtended ////////////////////////////////////

    function batchTransfer(address _to, uint256[] _ids, uint256[] _values) external {
        uint256 _id;
        uint256 _value;

        for (uint256 i = 0; i < _ids.length; ++i) {
            _id = _ids[i];
            _value = _values[i];

            items[_id].balances[msg.sender] = items[_id].balances[msg.sender].sub(_value);
            items[_id].balances[_to] = _value.add(items[_id].balances[_to]);

            Transfer(msg.sender, msg.sender, _to, _id, _value);
        }
    }

    function safeBatchTransfer(address _to, uint256[] _ids, uint256[] _values, bytes _data) external {
        //this.batchTransfer(_to, _ids, _values);

        for (uint256 i = 0; i < _ids.length; ++i) {
            // solium-disable-next-line arg-overflow
            require(_checkAndCallSafeTransfer(msg.sender, _to, _ids[i], _values[i], _data));
        }

        uint256 _id;
        uint256 _value;

        for (i = 0; i < _ids.length; ++i) {
            _id = _ids[i];
            _value = _values[i];

            items[_id].balances[msg.sender] = items[_id].balances[msg.sender].sub(_value);
            items[_id].balances[_to] = _value.add(items[_id].balances[_to]);

            Transfer(msg.sender, msg.sender, _to, _id, _value);
        }
    }

//////////////////////////////// IERC1155BatchTransferExtended ////////////////////////////////////

    // Optional meta data view Functions
    // consider multi-lingual support for name?
    function name(uint256 _id) external view returns (string) {
        return items[_id].name;
    }

    function symbol(uint256 _id) external view returns (string) {
        return symbols[_id];
    }

    function decimals(uint256 _id) external view returns (uint8) {
        return decimals[_id];
    }

    function totalSupply(uint256 _id) external view returns (uint256) {
        return items[_id].totalSupply;
    }

    function uri(uint256 _id) external view returns (string) {
        return metadataURIs[_id];
    }

////////////////////////////////////////// OPTIONALS //////////////////////////////////////////////


    function multicastTransfer(address[] _to, uint256[] _ids, uint256[] _values) external {
        for (uint256 i = 0; i < _to.length; ++i) {
            uint256 _id = _ids[i];
            uint256 _value = _values[i];
            address _dst = _to[i];

            items[_id].balances[msg.sender] = items[_id].balances[msg.sender].sub(_value);
            items[_id].balances[_dst] = _value.add(items[_id].balances[_dst]);

            Transfer(msg.sender, msg.sender, _dst, _id, _value);
        }
    }

    function safeMulticastTransfer(address[] _to, uint256[] _ids, uint256[] _values, bytes _data) external {
        //this.multicastTransfer(_to, _ids, _values);

        for (uint256 i = 0; i < _ids.length; ++i) {
            // solium-disable-next-line arg-overflow
            require(_checkAndCallSafeTransfer(msg.sender, _to[i], _ids[i], _values[i], _data));
        }

        for (i = 0; i < _to.length; ++i) {
            uint256 _id = _ids[i];
            uint256 _value = _values[i];
            address _dst = _to[i];

            items[_id].balances[msg.sender] = items[_id].balances[msg.sender].sub(_value);
            items[_id].balances[_dst] = _value.add(items[_id].balances[_dst]);

            Transfer(msg.sender, msg.sender, _dst, _id, _value);
        }
    }

////////////////////////////////////////// INTERNAL //////////////////////////////////////////////

    function _checkAndCallSafeTransfer(
        address _from,
        address _to,
        uint256 _id,
        uint256 _value,
        bytes _data
    )
    internal
    returns (bool)
    {
        if (!_to.isContract()) {
            return true;
        }
        bytes4 retval = IERC1155TokenReceiver(_to).onERC1155Received(
            msg.sender, _from, _id, _value, _data);
        return (retval == ERC1155_RECEIVED);
    }
}

// File: contracts/ERC165.sol

/**
 * @title ERC165
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
 */
interface ERC165 {

  /**
   * @notice Query if a contract implements an interface
   * @param _interfaceId The interface identifier, as specified in ERC-165
   * @dev Interface identification is specified in ERC-165. This function
   * uses less than 30,000 gas.
   */
  function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool);
}

// File: contracts/ERC721Basic.sol

/**
 * @title ERC721 Non-Fungible Token Standard basic interface
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Basic is ERC165 {

    bytes4 internal constant InterfaceId_ERC721 = 0x80ac58cd;
    /*
    * 0x80ac58cd ===
    *   bytes4(keccak256('balanceOf(address)')) ^
    *   bytes4(keccak256('ownerOf(uint256)')) ^
    *   bytes4(keccak256('approve(address,uint256)')) ^
    *   bytes4(keccak256('getApproved(uint256)')) ^
    *   bytes4(keccak256('setApprovalForAll(address,bool)')) ^
    *   bytes4(keccak256('isApprovedForAll(address,address)')) ^
    *   bytes4(keccak256('transferFrom(address,address,uint256)')) ^
    *   bytes4(keccak256('safeTransferFrom(address,address,uint256)')) ^
    *   bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)'))
    */

    bytes4 internal constant InterfaceId_ERC721Exists = 0x4f558e79;
    /*
    * 0x4f558e79 ===
    *   bytes4(keccak256('exists(uint256)'))
    */

    bytes4 internal constant InterfaceId_ERC721Enumerable = 0x780e9d63;
    /**
    * 0x780e9d63 ===
    *   bytes4(keccak256('totalSupply()')) ^
    *   bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^
    *   bytes4(keccak256('tokenByIndex(uint256)'))
    */

    bytes4 internal constant InterfaceId_ERC721Metadata = 0x5b5e139f;
    /**
    * 0x5b5e139f ===
    *   bytes4(keccak256('name()')) ^
    *   bytes4(keccak256('symbol()')) ^
    *   bytes4(keccak256('tokenURI(uint256)'))
    */

    event Transfer(
      address indexed _from,
      address indexed _to,
      uint256 indexed _tokenId
    );
    event Approval(
      address indexed _owner,
      address indexed _approved,
      uint256 indexed _tokenId
    );
    event ApprovalForAll(
      address indexed _owner,
      address indexed _operator,
      bool _approved
    );

    function balanceOf(address _owner) public view returns (uint256 _balance);
    function ownerOf(uint256 _tokenId) public view returns (address _owner);
    function exists(uint256 _tokenId) public view returns (bool _exists);

    function approve(address _to, uint256 _tokenId) public;
    function getApproved(uint256 _tokenId) public view returns (address _operator);

    function setApprovalForAll(address _operator, bool _approved) public;
    function isApprovedForAll(address _owner, address _operator) public view returns (bool);

    function transferFrom(address _from, address _to, uint256 _tokenId) public;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) public;
}

// File: contracts/DepositContract.sol

/// @title DepositContract contract
contract DepositContract is withAccessManager {

    bytes32 public clientId; // client ID.
    uint256 public version = 2;

    // EVENTS
    event EtherTransfer(address to, uint256 value);

    // NON-CONSTANT METHODS 

    /** @dev Constructor that sets the _clientID when the contract is deployed.
      * @dev The method also sets the manager to the msg.sender.
      * @param _clientId A string of fixed length representing the client ID.
      */
    function DepositContract(bytes32 _clientId, address accessManager) public withAccessManager(accessManager) {
        clientId = _clientId;
    }
     
    /** @dev Transfers an amount '_value' of tokens from msg.sender to '_to' address/wallet.
      * @param populousTokenContract The address of the ERC20 token contract which implements the transfer method.
      * @param _value the amount of tokens to transfer.
      * @param _to The address/wallet to send to.
      * @return success boolean true or false indicating whether the transfer was successful or not.
      */
    function transfer(address populousTokenContract, address _to, uint256 _value) public
        onlyServerOrOnlyPopulous returns (bool success) 
    {
        return iERC20Token(populousTokenContract).transfer(_to, _value);
    }

    /** @dev This function will transfer iERC1155 tokens
     */
    function transferERC1155(address _erc1155Token, address _to, uint256 _id, uint256 _value) 
        public onlyServerOrOnlyPopulous returns (bool success) {
        ERC1155(_erc1155Token).safeTransfer(_to, _id, _value, "");
        return true;
    }

    /**
    * @notice Handle the receipt of an NFT
    * @dev The ERC721 smart contract calls this function on the recipient
    * after a `safetransfer` if the recipient is a smart contract. This function MAY throw to revert and reject the
    * transfer. Return of other than the magic value (0x150b7a02) MUST result in the
    * transaction being reverted.
    * Note: the contract address is always the message sender.
    * @param _operator The address which called `safeTransferFrom` function
    * @param _from The address which previously owned the token
    * @param _tokenId The NFT identifier which is being transferred
    * @param _data Additional data with no specified format
    * @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    */
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) public returns(bytes4) {
        return 0x150b7a02; 
    }

    /// @notice Handle the receipt of an ERC1155 type
    /// @dev The smart contract calls this function on the recipient
    ///  after a `safeTransfer`. This function MAY throw to revert and reject the
    ///  transfer. Return of other than the magic value MUST result in the
    ///  transaction being reverted.
    ///  Note: the contract address is always the message sender.
    /// @param _operator The address which called `safeTransferFrom` function
    /// @param _from The address which previously owned the token
    /// @param _id The identifier of the item being transferred
    /// @param _value The amount of the item being transferred
    /// @param _data Additional data with no specified format
    /// @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
    ///  unless throwing
    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes _data) public returns(bytes4) {
        return 0xf23a6e61;
    }

    /**
    * @dev Safely transfers the ownership of a given token ID to another address
    * If the target address is a contract, it must implement `onERC721Received`,
    * which is called upon a safe transfer, and return the magic value
    * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
    * the transfer is reverted.
    *
    * Requires the msg sender to be the owner, approved, or operator
    * @param erc721Token address of the erc721 token to target
    * @param _to address to receive the ownership of the given token ID
    * @param _tokenId uint256 ID of the token to be transferred
    */
    function transferERC721(
        address erc721Token,
        address _to,
        uint256 _tokenId
    )
        public onlyServerOrOnlyPopulous returns (bool success)
    {
        // solium-disable-next-line arg-overflow
        ERC721Basic(erc721Token).safeTransferFrom(this, _to, _tokenId, "");
        return true;
    }

    /** @dev Transfers ether from this contract to a specified wallet/address
      * @param _to An address implementing to send ether to.
      * @param _value The amount of ether to send in wei. 
      * @return bool Successful or unsuccessful transfer
      */
    function transferEther(address _to, uint256 _value) public 
        onlyServerOrOnlyPopulous returns (bool success) 
    {
        require(this.balance >= _value);
        require(_to.send(_value) == true);
        EtherTransfer(_to, _value);
        return true;
    }

    // payable function to allow this contract receive ether - for version 3
    //function () public payable {}

    // CONSTANT METHODS
    
    /** @dev Returns the ether or token balance of the current contract instance using the ERC20 balanceOf method.
      * @param populousTokenContract An address implementing the ERC20 token standard. 
      * @return uint An unsigned integer representing the returned token balance.
      */
    function balanceOf(address populousTokenContract) public view returns (uint256) {
        // ether
        if (populousTokenContract == address(0)) {
            return address(this).balance;
        } else {
            // erc20
            return iERC20Token(populousTokenContract).balanceOf(this);
        }
    }

    /**
    * @dev Gets the balance of the specified address
    * @param erc721Token address to erc721 token to target
    * @return uint256 representing the amount owned by the passed address
    */
    function balanceOfERC721(address erc721Token) public view returns (uint256) {
        return ERC721Basic(erc721Token).balanceOf(this);
        // returns ownedTokensCount[_owner];
    }

    /**
    * @dev Gets the balance of the specified address
    * @param _id the token id
    * @param erc1155Token address to erc1155 token to target
    * @return uint256 representing the amount owned by the passed address
    */
    function balanceOfERC1155(address erc1155Token, uint256 _id) external view returns (uint256) {
        return ERC1155(erc1155Token).balanceOf(_id, this);
    }

    /** @dev Gets the version of this deposit contract
      * @return uint256 version
      */
    function getVersion() public view returns (uint256) {
        return version;
    }

    // CONSTANT FUNCTIONS

    /** @dev This function gets the client ID or deposit contract owner
     * returns _clientId
     */
    function getClientId() public view returns (bytes32 _clientId) {
        return clientId;
    }
}

// File: contracts/SafeMath.sol

/// @title Overflow aware uint math functions.
/// @notice Inspired by https://github.com/MakerDAO/maker-otc/blob/master/contracts/simple_market.sol
library SafeMath {

  /** @dev Safely multiplies two unsigned/non-negative integers.
    * @dev Ensures that one of both numbers can be derived from dividing the product by the other.
    * @param a The first number.
    * @param b The second number.
    * @return uint The expected result.
    */
    function safeMul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

  /** @dev Safely subtracts one number from another
    * @dev Ensures that the number to subtract is lower.
    * @param a The first number.
    * @param b The second number.
    * @return uint The expected result.
    */
    function safeSub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

  /** @dev Safely adds two unsigned/non-negative integers.
    * @dev Ensures that the sum of both numbers is greater or equal to one of both.
    * @param a The first number.
    * @param b The second number.
    * @return uint The expected result.
    */
    function safeAdd(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c>=a && c>=b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
}

// File: contracts/iDataManager.sol

/// @title DataManager contract
contract iDataManager {
    // FIELDS
    uint256 public version;
    // currency symbol => currency erc20 contract address
    mapping(bytes32 => address) public currencyAddresses;
    // currency address => currency symbol
    mapping(address => bytes32) public currencySymbols;
    // clientId => depositAddress
    mapping(bytes32 => address) public depositAddresses;
    // depositAddress => clientId
    mapping(address => bytes32) public depositClientIds;
    // blockchainActionId => boolean 
    mapping(bytes32 => bool) public actionStatus;
    // blockchainActionData
    struct actionData {
        bytes32 currency;
        uint amount;
        bytes32 accountId;
        address to;
        uint pptFee;
    }
    // blockchainActionId => actionData
    mapping(bytes32 => actionData) public blockchainActionIdData;
    
    //actionId => invoiceId
    mapping(bytes32 => bytes32) public actionIdToInvoiceId;
    // invoice provider company data
    struct providerCompany {
        //bool isEnabled;
        bytes32 companyNumber;
        bytes32 companyName;
        bytes2 countryCode;
    }
    // companyCode => companyNumber => providerId
    mapping(bytes2 => mapping(bytes32 => bytes32)) public providerData;
    // providedId => providerCompany
    mapping(bytes32 => providerCompany) public providerCompanyData;
    // crowdsale invoiceDetails
    struct _invoiceDetails {
        bytes2 invoiceCountryCode;
        bytes32 invoiceCompanyNumber;
        bytes32 invoiceCompanyName;
        bytes32 invoiceNumber;
    }
    // crowdsale invoiceData
    struct invoiceData {
        bytes32 providerUserId;
        bytes32 invoiceCompanyName;
    }

    // country code => company number => invoice number => invoice data
    mapping(bytes2 => mapping(bytes32 => mapping(bytes32 => invoiceData))) public invoices;
    
    
    
    
    // NON-CONSTANT METHODS

    /** @dev Adds a new deposit smart contract address linked to a client id
      * @param _depositAddress the deposit smart contract address
      * @param _clientId the client id
      * @return success true/false denoting successful function call
      */
    function setDepositAddress(bytes32 _blockchainActionId, address _depositAddress, bytes32 _clientId) public returns (bool success);

    /** @dev Adds a new currency sumbol and smart contract address  
      * @param _currencyAddress the currency smart contract address
      * @param _currencySymbol the currency symbol
      * @return success true/false denoting successful function call
      */
    function setCurrency(bytes32 _blockchainActionId, address _currencyAddress, bytes32 _currencySymbol) public returns (bool success);

    /** @dev Updates a currency sumbol and smart contract address  
      * @param _currencyAddress the currency smart contract address
      * @param _currencySymbol the currency symbol
      * @return success true/false denoting successful function call
      */
    function _setCurrency(bytes32 _blockchainActionId, address _currencyAddress, bytes32 _currencySymbol) public returns (bool success);


    /** @dev set blockchain action data in struct 
      * @param _blockchainActionId the blockchain action id
      * @param currency the token currency symbol
      * @param accountId the clientId
      * @param to the blockchain address or smart contract address used in the transaction
      * @param amount the amount of tokens in the transaction
      * @return success true/false denoting successful function call
      */
    function setBlockchainActionData(
        bytes32 _blockchainActionId, bytes32 currency, 
        uint amount, bytes32 accountId, address to, uint pptFee) 
        public 
        returns (bool success);

    /** @dev upgrade deposit address 
      * @param _blockchainActionId the blockchain action id
      * @param _clientId the client id
      * @param _depositContract the deposit contract address for the client
      * @return success true/false denoting successful function call
      */
    function upgradeDepositAddress(bytes32 _blockchainActionId, bytes32 _clientId, address _depositContract) public returns (bool success);
  

    /** @dev Updates a deposit address for client id
      * @param _blockchainActionId the blockchain action id
      * @param _clientId the client id
      * @param _depositContract the deposit contract address for the client
      * @return success true/false denoting successful function call
      */
    function _setDepositAddress(bytes32 _blockchainActionId, bytes32 _clientId, address _depositContract) public returns (bool success);

    /** @dev Add a new invoice to the platform  
      * @param _providerUserId the providers user id
      * @param _invoiceCountryCode the country code of the provider
      * @param _invoiceCompanyNumber the providers company number
      * @param _invoiceCompanyName the providers company name
      * @param _invoiceNumber the invoice number
      * @return success true or false if function call is successful
      */
    function setInvoice(
        bytes32 _blockchainActionId, bytes32 _providerUserId, bytes2 _invoiceCountryCode, 
        bytes32 _invoiceCompanyNumber, bytes32 _invoiceCompanyName, bytes32 _invoiceNumber) 
        public returns (bool success);

    
    /** @dev Add a new invoice provider to the platform  
      * @param _blockchainActionId the blockchain action id
      * @param _userId the user id of the provider
      * @param _companyNumber the providers company number
      * @param _companyName the providers company name
      * @param _countryCode the providers country code
      * @return success true or false if function call is successful
      */
    function setProvider(
        bytes32 _blockchainActionId, bytes32 _userId, bytes32 _companyNumber, 
        bytes32 _companyName, bytes2 _countryCode) 
        public returns (bool success);

    /** @dev Update an added invoice provider to the platform  
      * @param _blockchainActionId the blockchain action id
      * @param _userId the user id of the provider
      * @param _companyNumber the providers company number
      * @param _companyName the providers company name
      * @param _countryCode the providers country code
      * @return success true or false if function call is successful
      */
    function _setProvider(
        bytes32 _blockchainActionId, bytes32 _userId, bytes32 _companyNumber, 
        bytes32 _companyName, bytes2 _countryCode) 
        public returns (bool success);
    
    // CONSTANT METHODS

    /** @dev Gets a deposit address with the client id 
      * @return clientDepositAddress The client's deposit address
      */
    function getDepositAddress(bytes32 _clientId) public view returns (address clientDepositAddress);


    /** @dev Gets a client id linked to a deposit address 
      * @return depositClientId The client id
      */
    function getClientIdWithDepositAddress(address _depositContract) public view returns (bytes32 depositClientId);


    /** @dev Gets a currency smart contract address 
      * @return currencyAddress The currency address
      */
    function getCurrency(bytes32 _currencySymbol) public view returns (address currencyAddress);

   
    /** @dev Gets a currency symbol given it's smart contract address 
      * @return currencySymbol The currency symbol
      */
    function getCurrencySymbol(address _currencyAddress) public view returns (bytes32 currencySymbol);

    /** @dev Gets details of a currency given it's smart contract address 
      * @return _symbol The currency symbol
      * @return _name The currency name
      * @return _decimals The currency decimal places/precision
      */
    function getCurrencyDetails(address _currencyAddress) public view returns (bytes32 _symbol, bytes32 _name, uint8 _decimals);

    /** @dev Get the blockchain action Id Data for a blockchain Action id
      * @param _blockchainActionId the blockchain action id
      * @return bytes32 currency
      * @return uint amount
      * @return bytes32 accountId
      * @return address to
      */
    function getBlockchainActionIdData(bytes32 _blockchainActionId) public view returns (bytes32 _currency, uint _amount, bytes32 _accountId, address _to);


    /** @dev Get the bool status of a blockchain Action id
      * @param _blockchainActionId the blockchain action id
      * @return bool actionStatus
      */
    function getActionStatus(bytes32 _blockchainActionId) public view returns (bool _blockchainActionStatus);


    /** @dev Gets the details of an invoice with the country code, company number and invocie number.
      * @param _invoiceCountryCode The country code.
      * @param _invoiceCompanyNumber The company number.
      * @param _invoiceNumber The invoice number
      * @return providerUserId The invoice provider user Id
      * @return invoiceCompanyName the invoice company name
      */
    function getInvoice(bytes2 _invoiceCountryCode, bytes32 _invoiceCompanyNumber, bytes32 _invoiceNumber) 
        public 
        view 
        returns (bytes32 providerUserId, bytes32 invoiceCompanyName);


    /** @dev Gets the details of an invoice provider with the country code and company number.
      * @param _providerCountryCode The country code.
      * @param _providerCompanyNumber The company number.
      * @return isEnabled The boolean value true/false indicating whether invoice provider is enabled or not
      * @return providerId The invoice provider user Id
      * @return companyName the invoice company name
      */
    function getProviderByCountryCodeCompanyNumber(bytes2 _providerCountryCode, bytes32 _providerCompanyNumber) 
        public 
        view 
        returns (bytes32 providerId, bytes32 companyName);


    /** @dev Gets the details of an invoice provider with the providers user Id.
      * @param _providerUserId The provider user Id.
      * @return countryCode The invoice provider country code
      * @return companyName the invoice company name
      */
    function getProviderByUserId(bytes32 _providerUserId) public view 
        returns (bytes2 countryCode, bytes32 companyName, bytes32 companyNumber);


    /** @dev Gets the version number for the current contract instance
      * @return _version The version number
      */
    function getVersion() public view returns (uint256 _version);

}

// File: contracts/DataManager.sol

/// @title DataManager contract
contract DataManager is iDataManager, withAccessManager {
    

    // NON-CONSTANT METHODS

    /** @dev Constructor that sets the server when contract is deployed.
      * @param _accessManager The address to set as the access manager.
      */
    function DataManager(address _accessManager, uint256 _version) public withAccessManager(_accessManager) {
        version = _version;
    }

    /** @dev Adds a new deposit smart contract address linked to a client id
      * @param _depositAddress the deposit smart contract address
      * @param _clientId the client id
      * @return success true/false denoting successful function call
      */
    function setDepositAddress(bytes32 _blockchainActionId, address _depositAddress, bytes32 _clientId) public onlyServerOrOnlyPopulous returns (bool success) {
        require(actionStatus[_blockchainActionId] == false);
        require(depositAddresses[_clientId] == 0x0 && depositClientIds[_depositAddress] == 0x0);
        depositAddresses[_clientId] = _depositAddress;
        depositClientIds[_depositAddress] = _clientId;
        assert(depositAddresses[_clientId] != 0x0 && depositClientIds[_depositAddress] != 0x0);
        return true;
    }

    /** @dev Adds a new currency sumbol and smart contract address  
      * @param _currencyAddress the currency smart contract address
      * @param _currencySymbol the currency symbol
      * @return success true/false denoting successful function call
      */
    function setCurrency(bytes32 _blockchainActionId, address _currencyAddress, bytes32 _currencySymbol) public onlyServerOrOnlyPopulous returns (bool success) {
        require(actionStatus[_blockchainActionId] == false);
        require(currencySymbols[_currencyAddress] == 0x0 && currencyAddresses[_currencySymbol] == 0x0);
        currencySymbols[_currencyAddress] = _currencySymbol;
        currencyAddresses[_currencySymbol] = _currencyAddress;
        assert(currencyAddresses[_currencySymbol] != 0x0 && currencySymbols[_currencyAddress] != 0x0);
        return true;
    }

    /** @dev Updates a currency sumbol and smart contract address  
      * @param _currencyAddress the currency smart contract address
      * @param _currencySymbol the currency symbol
      * @return success true/false denoting successful function call
      */
    function _setCurrency(bytes32 _blockchainActionId, address _currencyAddress, bytes32 _currencySymbol) public onlyServerOrOnlyPopulous returns (bool success) {
        require(actionStatus[_blockchainActionId] == false);
        currencySymbols[_currencyAddress] = _currencySymbol;
        currencyAddresses[_currencySymbol] = _currencyAddress;
        assert(currencyAddresses[_currencySymbol] != 0x0 && currencySymbols[_currencyAddress] != 0x0);
        setBlockchainActionData(_blockchainActionId, _currencySymbol, 0, 0x0, _currencyAddress, 0);
        return true;
    }

    /** @dev set blockchain action data in struct 
      * @param _blockchainActionId the blockchain action id
      * @param currency the token currency symbol
      * @param accountId the clientId
      * @param to the blockchain address or smart contract address used in the transaction
      * @param amount the amount of tokens in the transaction
      * @return success true/false denoting successful function call
      */
    function setBlockchainActionData(
        bytes32 _blockchainActionId, bytes32 currency, 
        uint amount, bytes32 accountId, address to, uint pptFee) 
        public
        onlyServerOrOnlyPopulous 
        returns (bool success)
    {
        require(actionStatus[_blockchainActionId] == false);
        blockchainActionIdData[_blockchainActionId].currency = currency;
        blockchainActionIdData[_blockchainActionId].amount = amount;
        blockchainActionIdData[_blockchainActionId].accountId = accountId;
        blockchainActionIdData[_blockchainActionId].to = to;
        blockchainActionIdData[_blockchainActionId].pptFee = pptFee;
        actionStatus[_blockchainActionId] = true;
        return true;
    }
    
    /** @dev Updates a deposit address for client id
      * @param _blockchainActionId the blockchain action id
      * @param _clientId the client id
      * @param _depositContract the deposit contract address for the client
      * @return success true/false denoting successful function call
      */
    function _setDepositAddress(bytes32 _blockchainActionId, bytes32 _clientId, address _depositContract) public
      onlyServerOrOnlyPopulous
      returns (bool success)
    {
        require(actionStatus[_blockchainActionId] == false);
        depositAddresses[_clientId] = _depositContract;
        depositClientIds[_depositContract] = _clientId;
        // check that deposit address has been stored for client Id
        assert(depositAddresses[_clientId] == _depositContract && depositClientIds[_depositContract] == _clientId);
        // set blockchain action data
        setBlockchainActionData(_blockchainActionId, 0x0, 0, _clientId, depositAddresses[_clientId], 0);
        return true;
    }

    /** @dev Add a new invoice to the platform  
      * @param _providerUserId the providers user id
      * @param _invoiceCountryCode the country code of the provider
      * @param _invoiceCompanyNumber the providers company number
      * @param _invoiceCompanyName the providers company name
      * @param _invoiceNumber the invoice number
      * @return success true or false if function call is successful
      */
    function setInvoice(
        bytes32 _blockchainActionId, bytes32 _providerUserId, bytes2 _invoiceCountryCode, 
        bytes32 _invoiceCompanyNumber, bytes32 _invoiceCompanyName, bytes32 _invoiceNumber) 
        public 
        onlyServerOrOnlyPopulous 
        returns (bool success) 
    {   
        require(actionStatus[_blockchainActionId] == false);
        bytes32 providerUserId; 
        bytes32 companyName;
        (providerUserId, companyName) = getInvoice(_invoiceCountryCode, _invoiceCompanyNumber, _invoiceNumber);
        require(providerUserId == 0x0 && companyName == 0x0);
        // country code => company number => invoice number => invoice data
        invoices[_invoiceCountryCode][_invoiceCompanyNumber][_invoiceNumber].providerUserId = _providerUserId;
        invoices[_invoiceCountryCode][_invoiceCompanyNumber][_invoiceNumber].invoiceCompanyName = _invoiceCompanyName;
        
        assert(
            invoices[_invoiceCountryCode][_invoiceCompanyNumber][_invoiceNumber].providerUserId != 0x0 && 
            invoices[_invoiceCountryCode][_invoiceCompanyNumber][_invoiceNumber].invoiceCompanyName != 0x0
        );
        return true;
    }
    
    /** @dev Add a new invoice provider to the platform  
      * @param _blockchainActionId the blockchain action id
      * @param _userId the user id of the provider
      * @param _companyNumber the providers company number
      * @param _companyName the providers company name
      * @param _countryCode the providers country code
      * @return success true or false if function call is successful
      */
    function setProvider(
        bytes32 _blockchainActionId, bytes32 _userId, bytes32 _companyNumber, 
        bytes32 _companyName, bytes2 _countryCode) 
        public 
        onlyServerOrOnlyPopulous
        returns (bool success)
    {   
        require(actionStatus[_blockchainActionId] == false);
        require(
            providerCompanyData[_userId].companyNumber == 0x0 && 
            providerCompanyData[_userId].countryCode == 0x0 &&
            providerCompanyData[_userId].companyName == 0x0);
        
        providerCompanyData[_userId].countryCode = _countryCode;
        providerCompanyData[_userId].companyName = _companyName;
        providerCompanyData[_userId].companyNumber = _companyNumber;

        providerData[_countryCode][_companyNumber] = _userId;
        return true;
    }


    /** @dev Update an added invoice provider to the platform  
      * @param _blockchainActionId the blockchain action id
      * @param _userId the user id of the provider
      * @param _companyNumber the providers company number
      * @param _companyName the providers company name
      * @param _countryCode the providers country code
      * @return success true or false if function call is successful
      */
    function _setProvider(
        bytes32 _blockchainActionId, bytes32 _userId, bytes32 _companyNumber, 
        bytes32 _companyName, bytes2 _countryCode) 
        public 
        onlyServerOrOnlyPopulous
        returns (bool success)
    {   
        require(actionStatus[_blockchainActionId] == false);
        providerCompanyData[_userId].countryCode = _countryCode;
        providerCompanyData[_userId].companyName = _companyName;
        providerCompanyData[_userId].companyNumber = _companyNumber;
        providerData[_countryCode][_companyNumber] = _userId;
        
        setBlockchainActionData(_blockchainActionId, 0x0, 0, _userId, 0x0, 0);
        return true;
    }

    // CONSTANT METHODS

    /** @dev Gets a deposit address with the client id 
      * @return clientDepositAddress The client's deposit address
      */
    function getDepositAddress(bytes32 _clientId) public view returns (address clientDepositAddress){
        return depositAddresses[_clientId];
    }

    /** @dev Gets a client id linked to a deposit address 
      * @return depositClientId The client id
      */
    function getClientIdWithDepositAddress(address _depositContract) public view returns (bytes32 depositClientId){
        return depositClientIds[_depositContract];
    }

    /** @dev Gets a currency smart contract address 
      * @return currencyAddress The currency address
      */
    function getCurrency(bytes32 _currencySymbol) public view returns (address currencyAddress) {
        return currencyAddresses[_currencySymbol];
    }
   
    /** @dev Gets a currency symbol given it's smart contract address 
      * @return currencySymbol The currency symbol
      */
    function getCurrencySymbol(address _currencyAddress) public view returns (bytes32 currencySymbol) {
        return currencySymbols[_currencyAddress];
    }

    /** @dev Gets details of a currency given it's smart contract address 
      * @return _symbol The currency symbol
      * @return _name The currency name
      * @return _decimals The currency decimal places/precision
      */
    function getCurrencyDetails(address _currencyAddress) public view returns (bytes32 _symbol, bytes32 _name, uint8 _decimals) {
        return (CurrencyToken(_currencyAddress).symbol(), CurrencyToken(_currencyAddress).name(), CurrencyToken(_currencyAddress).decimals());
    } 

    /** @dev Get the blockchain action Id Data for a blockchain Action id
      * @param _blockchainActionId the blockchain action id
      * @return bytes32 currency
      * @return uint amount
      * @return bytes32 accountId
      * @return address to
      */
    function getBlockchainActionIdData(bytes32 _blockchainActionId) public view 
    returns (bytes32 _currency, uint _amount, bytes32 _accountId, address _to) 
    {
        require(actionStatus[_blockchainActionId] == true);
        return (blockchainActionIdData[_blockchainActionId].currency, 
        blockchainActionIdData[_blockchainActionId].amount,
        blockchainActionIdData[_blockchainActionId].accountId,
        blockchainActionIdData[_blockchainActionId].to);
    }

    /** @dev Get the bool status of a blockchain Action id
      * @param _blockchainActionId the blockchain action id
      * @return bool actionStatus
      */
    function getActionStatus(bytes32 _blockchainActionId) public view returns (bool _blockchainActionStatus) {
        return actionStatus[_blockchainActionId];
    }

    /** @dev Gets the details of an invoice with the country code, company number and invocie number.
      * @param _invoiceCountryCode The country code.
      * @param _invoiceCompanyNumber The company number.
      * @param _invoiceNumber The invoice number
      * @return providerUserId The invoice provider user Id
      * @return invoiceCompanyName the invoice company name
      */
    function getInvoice(bytes2 _invoiceCountryCode, bytes32 _invoiceCompanyNumber, bytes32 _invoiceNumber) 
        public 
        view 
        returns (bytes32 providerUserId, bytes32 invoiceCompanyName) 
    {   
        bytes32 _providerUserId = invoices[_invoiceCountryCode][_invoiceCompanyNumber][_invoiceNumber].providerUserId;
        bytes32 _invoiceCompanyName = invoices[_invoiceCountryCode][_invoiceCompanyNumber][_invoiceNumber].invoiceCompanyName;
        return (_providerUserId, _invoiceCompanyName);
    }

    /** @dev Gets the details of an invoice provider with the country code and company number.
      * @param _providerCountryCode The country code.
      * @param _providerCompanyNumber The company number.
      * @return isEnabled The boolean value true/false indicating whether invoice provider is enabled or not
      * @return providerId The invoice provider user Id
      * @return companyName the invoice company name
      */
    function getProviderByCountryCodeCompanyNumber(bytes2 _providerCountryCode, bytes32 _providerCompanyNumber) 
        public 
        view 
        returns (bytes32 providerId, bytes32 companyName) 
    {
        bytes32 providerUserId = providerData[_providerCountryCode][_providerCompanyNumber];
        return (providerUserId, 
        providerCompanyData[providerUserId].companyName);
    }

    /** @dev Gets the details of an invoice provider with the providers user Id.
      * @param _providerUserId The provider user Id.
      * @return countryCode The invoice provider country code
      * @return companyName the invoice company name
      */
    function getProviderByUserId(bytes32 _providerUserId) public view 
        returns (bytes2 countryCode, bytes32 companyName, bytes32 companyNumber) 
    {
        return (providerCompanyData[_providerUserId].countryCode,
        providerCompanyData[_providerUserId].companyName,
        providerCompanyData[_providerUserId].companyNumber);
    }

    /** @dev Gets the version number for the current contract instance
      * @return _version The version number
      */
    function getVersion() public view returns (uint256 _version) {
        return version;
    }

}

// File: contracts/Populous.sol

/**
This is the core module of the system. Currently it holds the code of
the Bank and crowdsale modules to avoid external calls and higher gas costs.
It might be a good idea in the future to split the code, separate Bank
and crowdsale modules into external files and have the core interact with them
with addresses and interfaces. 
*/








/// @title Populous contract
contract Populous is withAccessManager {
    // EVENTS
    // Bank events
    event EventUSDCToUSDp(bytes32 _blockchainActionId, bytes32 _clientId, uint amount);
    event EventUSDpToUSDC(bytes32 _blockchainActionId, bytes32 _clientId, uint amount);
    event EventDepositAddressUpgrade(bytes32 blockchainActionId, address oldDepositContract, address newDepositContract, bytes32 clientId, uint256 version);
    event EventWithdrawPPT(bytes32 blockchainActionId, bytes32 accountId, address depositContract, address to, uint amount);
    event EventWithdrawPoken(bytes32 _blockchainActionId, bytes32 accountId, bytes32 currency, uint amount);
    event EventNewDepositContract(bytes32 blockchainActionId, bytes32 clientId, address depositContractAddress, uint256 version);
    event EventWithdrawXAUp(bytes32 _blockchainActionId, address erc1155Token, uint amount, uint token_id, bytes32 accountId, uint pptFee);

    // FIELDS
    struct tokens {   
        address _token;
        uint256 _precision;
    }
    mapping(bytes8 => tokens) public tokenDetails;

    // NON-CONSTANT METHODS
    // Constructor method called when contract instance is 
    // deployed with 'withAccessManager' modifier.
    function Populous(address _accessManager) public withAccessManager(_accessManager) {
        /*ropsten
        
        //pxt
        tokenDetails[0x505854]._token = 0xD8A7C588f8DC19f49dAFd8ecf08eec58e64d4cC9;
        tokenDetails[0x505854]._precision = 8;
        //usdc
        tokenDetails[0x55534443]._token = 0xF930f2C7Bc02F89D05468112520553FFc6D24801;
        tokenDetails[0x55534443]._precision = 6;
        //tusd
        tokenDetails[0x54555344]._token = 0x78e7BEE398D66660bDF820DbDB415A33d011cD48;
        tokenDetails[0x54555344]._precision = 18;
        //ppt
        tokenDetails[0x505054]._token = 0x0ff72e24AF7c09A647865820D4477F98fcB72a2c;        
        tokenDetails[0x505054]._precision = 8;
        //xau
        tokenDetails[0x584155]._token = 0x9b935E3779098bC5E1ffc073CaF916F1E92A6145;
        tokenDetails[0x584155]._precision = 0;
        //usdp
        tokenDetails[0x55534470]._token = 0xf4b1533b6F45fAC936fA508F7e5db6d4BbC4c8bd;
        tokenDetails[0x55534470]._precision = 6;
        */
        
        /*livenet*/

        //pxt
        tokenDetails[0x505854]._token = 0xc14830E53aA344E8c14603A91229A0b925b0B262;
        tokenDetails[0x505854]._precision = 8;
        //usdc
        tokenDetails[0x55534443]._token = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        tokenDetails[0x55534443]._precision = 6;
        //tusd
        tokenDetails[0x54555344]._token = 0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
        tokenDetails[0x54555344]._precision = 18;
        //ppt
        tokenDetails[0x505054]._token = 0xd4fa1460F537bb9085d22C7bcCB5DD450Ef28e3a;        
        tokenDetails[0x505054]._precision = 8;
        //xau
        tokenDetails[0x584155]._token = 0x73a3b7DFFE9af119621f8467D8609771AB4BC33f;
        tokenDetails[0x584155]._precision = 0;
        //usdp
        tokenDetails[0x55534470]._token = 0xBaB5D0f110Be6f4a5b70a2FA22eD17324bFF6576;
        tokenDetails[0x55534470]._precision = 6;
    }

    /**
    BANK MODULE
    */
    // NON-CONSTANT METHODS

    function usdcToUsdp(
        address _dataManager, bytes32 _blockchainActionId, 
        bytes32 _clientId, uint amount)
        public
        onlyServer
    {   
        // client deposit smart contract address
        address _depositAddress = DataManager(_dataManager).getDepositAddress(_clientId);
        require(_dataManager != 0x0 && _depositAddress != 0x0 && amount > 0);
        //transfer usdc from deposit contract to server/admin
        require(DepositContract(_depositAddress).transfer(tokenDetails[0x55534443]._token, msg.sender, amount) == true);
        // mint USDp into depositAddress with amount
        require(CurrencyToken(tokenDetails[0x55534470]._token).mint(amount, _depositAddress) == true);     
        //set action data
        require(DataManager(_dataManager).setBlockchainActionData(_blockchainActionId, 0x55534470, amount, _clientId, _depositAddress, 0) == true); 
        //event
        emit EventUSDCToUSDp(_blockchainActionId, _clientId, amount);
    }

    function usdpToUsdc(
        address _dataManager, bytes32 _blockchainActionId, 
        bytes32 _clientId, uint amount) 
        public
        onlyServer
    {
        // client deposit smart contract address
        address _depositAddress = DataManager(_dataManager).getDepositAddress(_clientId);
        require(_dataManager != 0x0 && _depositAddress != 0x0 && amount > 0);
        //destroyFrom depositAddress USDp amount
        require(CurrencyToken(tokenDetails[0x55534470]._token).destroyTokensFrom(amount, _depositAddress) == true);
        //transferFrom USDC from server to depositAddress
        require(CurrencyToken(tokenDetails[0x55534443]._token).transferFrom(msg.sender, _depositAddress, amount) == true);
        //set action data
        require(DataManager(_dataManager).setBlockchainActionData(_blockchainActionId, 0x55534470, amount, _clientId, _depositAddress, 0) == true); 
        //event
        emit EventUSDpToUSDC(_blockchainActionId, _clientId, amount);
    }

    // Creates a new 'depositAddress' gotten from deploying a deposit contract linked to a client ID
    function createAddress(address _dataManager, bytes32 _blockchainActionId, bytes32 clientId) 
        public
        onlyServer
    {   
        require(_dataManager != 0x0);
        DepositContract newDepositContract;
        DepositContract dc;
        if (DataManager(_dataManager).getDepositAddress(clientId) != 0x0) {
            dc = DepositContract(DataManager(_dataManager).getDepositAddress(clientId));
            newDepositContract = new DepositContract(clientId, AM);
            require(!dc.call(bytes4(keccak256("getVersion()")))); 
            // only checking version 1 now to upgrade to version 2
            address PXT = tokenDetails[0x505854]._token;
            address PPT = tokenDetails[0x505054]._token;            
            if(dc.balanceOf(PXT) > 0){
                require(dc.transfer(PXT, newDepositContract, dc.balanceOf(PXT)) == true);
            }
            if(dc.balanceOf(PPT) > 0) {
                require(dc.transfer(PPT, newDepositContract, dc.balanceOf(PPT)) == true);
            }
            require(DataManager(_dataManager)._setDepositAddress(_blockchainActionId, clientId, newDepositContract) == true);
            EventDepositAddressUpgrade(_blockchainActionId, address(dc), DataManager(_dataManager).getDepositAddress(clientId), clientId, newDepositContract.getVersion());
        } else { 
            newDepositContract = new DepositContract(clientId, AM);
            require(DataManager(_dataManager).setDepositAddress(_blockchainActionId, newDepositContract, clientId) == true);
            require(DataManager(_dataManager).setBlockchainActionData(_blockchainActionId, 0x0, 0, clientId, DataManager(_dataManager).getDepositAddress(clientId), 0) == true);
            EventNewDepositContract(_blockchainActionId, clientId, DataManager(_dataManager).getDepositAddress(clientId), newDepositContract.getVersion());
        }
    }

    /* /// Ether to XAUP exchange between deposit contract and Populous.sol
    function exchangeXAUP(
        address _dataManager, bytes32 _blockchainActionId, 
        address erc20_tokenAddress, uint erc20_amount, uint xaup_amount, 
        uint _tokenId, bytes32 _clientId, address adminExternalWallet) 
        public 
        onlyServer
    {    
        ERC1155 xa = ERC1155(tokenDetails[0x584155]._token);
        // client deposit smart contract address
        address _depositAddress = DataManager(_dataManager).getDepositAddress(_clientId);
        require(
            // check dataManager contract is valid
            _dataManager != 0x0 &&
            // check deposit address of client
            _depositAddress != 0x0 && 
            // check xaup token address
            // tokenDetails[0x584155]._token != 0x0 && 
            erc20_tokenAddress != 0x0 &&
            // check action id is unused
            DataManager(_dataManager).getActionStatus(_blockchainActionId) == false &&
            // deposit contract version >= 2
            DepositContract(_depositAddress).getVersion() >= 2 &&
            // populous server xaup balance
            xa.balanceOf(_tokenId, msg.sender) >= xaup_amount
        );
        // transfer erc20 token balance from clients deposit contract to server/admin
        require(DepositContract(_depositAddress).transfer(erc20_tokenAddress, adminExternalWallet, erc20_amount) == true);
        // transfer xaup tokens to clients deposit address from populous server allowance
        xa.safeTransferFrom(msg.sender, _depositAddress, _tokenId, xaup_amount, "");
        // set action status in dataManager
        require(DataManager(_dataManager).setBlockchainActionData(_blockchainActionId, 0x0, erc20_amount, _clientId, _depositAddress, 0) == true);
        // emit event 
        EventExchangeXAUp(_blockchainActionId, erc20_tokenAddress, erc20_amount, xaup_amount, _tokenId, _clientId, _depositAddress);
    } */


    /** dev Import an amount of pokens of a particular currency from an ethereum wallet/address to bank
      * @param _blockchainActionId the blockchain action id
      * @param accountId the account id of the client
      * @param from the blockchain address to import pokens from
      * @param currency the poken currency
      */
    function withdrawPoken(
        address _dataManager, bytes32 _blockchainActionId, 
        bytes32 currency, uint256 amount, uint256 amountUSD,
        address from, address to, bytes32 accountId, 
        uint256 inCollateral,
        uint256 pptFee, address adminExternalWallet) 
        public 
        onlyServer 
    {
        require(_dataManager != 0x0);
        //DataManager dm = DataManager(_dataManager);
        require(DataManager(_dataManager).getActionStatus(_blockchainActionId) == false && DataManager(_dataManager).getDepositAddress(accountId) != 0x0);
        require(adminExternalWallet != 0x0 && pptFee > 0 && amount > 0);
        require(DataManager(_dataManager).getCurrency(currency) != 0x0);
        DepositContract o = DepositContract(DataManager(_dataManager).getDepositAddress(accountId));
        // check if pptbalance minus collateral held is more than pptFee then transfer pptFee from users ppt deposit to adminWallet
        require(SafeMath.safeSub(o.balanceOf(tokenDetails[0x505054]._token), inCollateral) >= pptFee);
        require(o.transfer(tokenDetails[0x505054]._token, adminExternalWallet, pptFee) == true);
        // WITHDRAW PART / DEBIT
        if(amount > CurrencyToken(DataManager(_dataManager).getCurrency(currency)).balanceOf(from)) {
            // destroying total balance as user has less than pokens they want to withdraw
            require(CurrencyToken(DataManager(_dataManager).getCurrency(currency)).destroyTokensFrom(CurrencyToken(DataManager(_dataManager).getCurrency(currency)).balanceOf(from), from) == true);
            //remaining ledger balance of deposit address is 0
        } else {
            // destroy amount from balance as user has more than pokens they want to withdraw
            require(CurrencyToken(DataManager(_dataManager).getCurrency(currency)).destroyTokensFrom(amount, from) == true);
            //left over balance is deposit address balance.
        }
        // TRANSFER PART / CREDIT
        // approve currency amount for populous for the next require to pass
        if(amountUSD > 0) //give the user USDC
        {
            CurrencyToken(tokenDetails[0x55534443]._token).transferFrom(msg.sender, to, amountUSD);
        }else { //give the user GBP / poken currency
            CurrencyToken(DataManager(_dataManager).getCurrency(currency)).transferFrom(msg.sender, to, amount);
        }
        require(DataManager(_dataManager).setBlockchainActionData(_blockchainActionId, currency, amount, accountId, to, pptFee) == true); 
        EventWithdrawPoken(_blockchainActionId, accountId, currency, amount);
    }

    /** @dev Withdraw an amount of PPT Populous tokens to a blockchain address 
      * @param _blockchainActionId the blockchain action id
      * @param pptAddress the address of the PPT smart contract
      * @param accountId the account id of the client
      * @param pptFee the amount of fees to pay in PPT tokens
      * @param adminExternalWallet the platform admin wallet address to pay the fees to 
      * @param to the blockchain address to withdraw and transfer the pokens to
      * @param inCollateral the amount of pokens withheld by the platform
      */    
    function withdrawERC20(
        address _dataManager, bytes32 _blockchainActionId, 
        address pptAddress, bytes32 accountId, 
        address to, uint256 amount, uint256 inCollateral, 
        uint256 pptFee, address adminExternalWallet) 
        public 
        onlyServer 
    {   
        require(_dataManager != 0x0);
        require(DataManager(_dataManager).getActionStatus(_blockchainActionId) == false && DataManager(_dataManager).getDepositAddress(accountId) != 0x0);
        require(adminExternalWallet != 0x0 && pptFee > 0 && amount > 0);
        address depositContract = DataManager(_dataManager).getDepositAddress(accountId);
        if(pptAddress == tokenDetails[0x505054]._token) {
            uint pptBalance = SafeMath.safeSub(DepositContract(depositContract).balanceOf(tokenDetails[0x505054]._token), inCollateral);
            require(pptBalance >= SafeMath.safeAdd(amount, pptFee));
        } else {
            uint erc20Balance = DepositContract(depositContract).balanceOf(pptAddress);
            require(erc20Balance >= amount);
        }
        require(DepositContract(depositContract).transfer(tokenDetails[0x505054]._token, adminExternalWallet, pptFee) == true);
        require(DepositContract(depositContract).transfer(pptAddress, to, amount) == true);
        bytes32 tokenSymbol = iERC20Token(pptAddress).symbol();    
        require(DataManager(_dataManager).setBlockchainActionData(_blockchainActionId, tokenSymbol, amount, accountId, to, pptFee) == true);
        EventWithdrawPPT(_blockchainActionId, accountId, DataManager(_dataManager).getDepositAddress(accountId), to, amount);
    }

    // erc1155 withdraw function using transferFrom in erc1155 token contract
/*     function withdrawERC1155(
        address _dataManager, bytes32 _blockchainActionId,
        address _to, uint256 _id, uint256 _value,
        bytes32 accountId, uint256 pptFee, 
        address adminExternalWallet) 
        public
        onlyServer 
    {
        require(DataManager(_dataManager).getActionStatus(_blockchainActionId) == false && DataManager(_dataManager).getDepositAddress(accountId) != 0x0);
        require(adminExternalWallet != 0x0 && pptFee > 0 && _value > 0);
        DepositContract o = DepositContract(DataManager(_dataManager).getDepositAddress(accountId));
        require(o.transfer(tokenDetails[0x505054]._token, adminExternalWallet, pptFee) == true);
        // transfer xaup tokens to address from deposit contract
        require(o.transferERC1155(tokenDetails[0x584155]._token, _to, _id, _value) == true);
        // set action status in dataManager
        require(DataManager(_dataManager).setBlockchainActionData(_blockchainActionId, 0x584155, _value, accountId, _to, pptFee) == true);
        // emit event 
        EventWithdrawXAUp(_blockchainActionId, tokenDetails[0x584155]._token, _value, _id, accountId, pptFee);
    } */
}