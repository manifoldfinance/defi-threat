/**
 * Source Code first verified at https://etherscan.io on Tuesday, March 26, 2019
 (UTC) */

pragma solidity ^0.5.0;

/*
    Copyright 2016, Jordi Baylina

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/// @title MiniMeToken Contract
/// @author Jordi Baylina
/// @dev This token contract's goal is to make it easy for anyone to clone this
///  token using the token distribution at a given block, this will allow DAO's
///  and DApps to upgrade their features in a decentralized manner without
///  affecting the original token
/// @dev It is ERC20 compliant, but still needs to under go further testing.

contract Controlled {
    /// @notice The address of the controller is the only address that can call
    ///  a function with this modifier
    modifier onlyController { require(msg.sender == controller); _; }

    address public controller;

    constructor() public { controller = msg.sender;}

    /// @notice Changes the controller of the contract
    /// @param _newController The new controller of the contract
    function changeController(address _newController) public onlyController {
        controller = _newController;
    }
}

contract TokenController {
    /// @notice Called when `_owner` sends ether to the MiniMe Token contract
    /// @param _owner The address that sent the ether to create tokens
    /// @return True if the ether is accepted, false if it throws
    function proxyPayment(address _owner) public payable returns(bool);

    /// @notice Notifies the controller about a token transfer allowing the
    ///  controller to react if desired
    /// @param _from The origin of the transfer
    /// @param _to The destination of the transfer
    /// @param _amount The amount of the transfer
    /// @return False if the controller does not authorize the transfer
    function onTransfer(address _from, address _to, uint _amount) public returns(bool);

    /// @notice Notifies the controller about an approval allowing the
    ///  controller to react if desired
    /// @param _owner The address that calls `approve()`
    /// @param _spender The spender in the `approve()` call
    /// @param _amount The amount in the `approve()` call
    /// @return False if the controller does not authorize the approval
    function onApprove(address _owner, address _spender, uint _amount) public
        returns(bool);

    /// @notice Notifies the controller about a token burn
    /// @param _owner The address of the burner
    /// @param _amount The amount to burn
    /// @return False if the controller does not authorize the burn
    function onBurn(address payable _owner, uint _amount) public returns(bool);
}


contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 _amount, address _token, bytes memory _data) public;
}

/// @dev The actual token contract, the default controller is the msg.sender
///  that deploys the contract, so usually this token will be deployed by a
///  token controller contract, which Giveth will call a "Campaign"
/// @dev The actual token contract, the default controller is the msg.sender
///  that deploys the contract, so usually this token will be deployed by a
///  token controller contract, which Giveth will call a "Campaign"
contract MiniMeToken is Controlled {

    string public name;                //The Token's name: e.g. DigixDAO Tokens
    uint8 public decimals;             //Number of decimals of the smallest unit
    string public symbol;              //An identifier: e.g. REP
    string public version = 'EFX_0.1'; //An arbitrary versioning scheme


    /// @dev `Checkpoint` is the structure that attaches a block number to a
    ///  given value, the block number attached is the one that last changed the
    ///  value
    struct  Checkpoint {

        // `fromBlock` is the block number that the value was generated from
        uint128 fromBlock;

        // `value` is the amount of tokens at a specific block number
        uint128 value;
    }

    // `parentToken` is the Token address that was cloned to produce this token;
    //  it will be 0x0 for a token that was not cloned
    MiniMeToken public parentToken;

    // `parentSnapShotBlock` is the block number from the Parent Token that was
    //  used to determine the initial distribution of the Clone Token
    uint public parentSnapShotBlock;

    // `creationBlock` is the block number that the Clone Token was created
    uint public creationBlock;

    // `balances` is the map that tracks the balance of each address, in this
    //  contract when the balance changes the block number that the change
    //  occurred is also included in the map
    mapping (address => Checkpoint[]) balances;

    // `allowed` tracks any extra transfer rights as in all ERC20 tokens
    mapping (address => mapping (address => uint256)) allowed;

    // Tracks the history of the `totalSupply` of the token
    Checkpoint[] totalSupplyHistory;

    // Flag that determines if the token is transferable or not.
    bool public transfersEnabled;

    // Tracks the history of the `pledgedFees` belonging to token holders
    Checkpoint[] totalPledgedFeesHistory; // in wei

    // The factory used to create new clone tokens
    MiniMeTokenFactory public tokenFactory;

////////////////
// Constructor
////////////////

    /// @notice Constructor to create a MiniMeToken
    /// @param _tokenFactory The address of the MiniMeTokenFactory contract that
    ///  will create the Clone token contracts, the token factory needs to be
    ///  deployed first
    /// @param _parentToken Address of the parent token, set to 0x0 if it is a
    ///  new token
    /// @param _parentSnapShotBlock Block of the parent token that will
    ///  determine the initial distribution of the clone token, set to 0 if it
    ///  is a new token
    /// @param _tokenName Name of the new token
    /// @param _decimalUnits Number of decimals of the new token
    /// @param _tokenSymbol Token Symbol for the new token
    /// @param _transfersEnabled If true, tokens will be able to be transferred
    constructor(
        address _tokenFactory,
        address payable _parentToken,
        uint _parentSnapShotBlock,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol,
        bool _transfersEnabled
    ) public {
        tokenFactory = MiniMeTokenFactory(_tokenFactory);
        name = _tokenName;                                 // Set the name
        decimals = _decimalUnits;                          // Set the decimals
        symbol = _tokenSymbol;                             // Set the symbol
        parentToken = MiniMeToken(_parentToken);
        parentSnapShotBlock = _parentSnapShotBlock;
        transfersEnabled = _transfersEnabled;
        creationBlock = block.number;
    }


///////////////////
// ERC20 Methods
///////////////////

    uint constant MAX_UINT = 2**256 - 1;

    /// @notice Send `_amount` tokens to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        require(transfersEnabled);
        doTransfer(msg.sender, _to, _amount);
        return true;
    }

    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it
    ///  is approved by `_from`
    /// @param _from The address holding the tokens being transferred
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function transferFrom(address _from, address _to, uint256 _amount
    ) public returns (bool success) {

        // The controller of this contract can move tokens around at will,
        //  this is important to recognize! Confirm that you trust the
        //  controller of this contract, which in most situations should be
        //  another open source smart contract or 0x0
        if (msg.sender != controller) {
            require(transfersEnabled);

            // The standard ERC 20 transferFrom functionality
            if (allowed[_from][msg.sender] < MAX_UINT) {
                require(allowed[_from][msg.sender] >= _amount);
                allowed[_from][msg.sender] -= _amount;
            }
        }
        doTransfer(_from, _to, _amount);
        return true;
    }

    /// @dev This is the actual transfer function in the token contract, it can
    ///  only be called by other functions in this contract.
    /// @param _from The address holding the tokens being transferred
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function doTransfer(address _from, address _to, uint _amount
    ) internal {

           if (_amount == 0) {
               emit Transfer(_from, _to, _amount);    // Follow the spec to louch the event when transfer 0
               return;
           }

           require(parentSnapShotBlock < block.number);

           // Do not allow transfer to 0x0 or the token contract itself
           require((_to != address(0)) && (_to != address(this)));

           // If the amount being transfered is more than the balance of the
           //  account the transfer throws
           uint256 previousBalanceFrom = balanceOfAt(_from, block.number);

           require(previousBalanceFrom >= _amount);

           // Alerts the token controller of the transfer
           if (isContract(controller)) {
               require(TokenController(controller).onTransfer(_from, _to, _amount));
           }

           // First update the balance array with the new value for the address
           //  sending the tokens
           updateValueAtNow(balances[_from], previousBalanceFrom - _amount);

           // Then update the balance array with the new value for the address
           //  receiving the tokens
           uint256 previousBalanceTo = balanceOfAt(_to, block.number);
           require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
           updateValueAtNow(balances[_to], previousBalanceTo + _amount);

           // An event to make the transfer easy to find on the blockchain
           emit Transfer(_from, _to, _amount);

    }

    /// @param _owner The address that's balance is being requested
    /// @return The balance of `_owner` at the current block
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balanceOfAt(_owner, block.number);
    }

    /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on
    ///  its behalf. This is a modified version of the ERC20 approve function
    ///  to be a little bit safer
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _amount The amount of tokens to be approved for transfer
    /// @return True if the approval was successful
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        require(transfersEnabled);

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender,0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

        // Alerts the token controller of the approve function call
        if (isContract(controller)) {
            require(TokenController(controller).onApprove(msg.sender, _spender, _amount));
        }

        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    /// @dev This function makes it easy to read the `allowed[]` map
    /// @param _owner The address of the account that owns the token
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens of _owner that _spender is allowed
    ///  to spend
    function allowance(address _owner, address _spender
    ) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /// @notice `msg.sender` approves `_spender` to send `_amount` tokens on
    ///  its behalf, and then a function is triggered in the contract that is
    ///  being approved, `_spender`. This allows users to use their tokens to
    ///  interact with contracts in one function call instead of two
    /// @param _spender The address of the contract able to transfer the tokens
    /// @param _amount The amount of tokens to be approved for transfer
    /// @return True if the function call was successful
    function approveAndCall(address _spender, uint256 _amount, bytes memory _extraData
    ) public returns (bool success) {
        require(approve(_spender, _amount));

        ApproveAndCallFallBack(_spender).receiveApproval(
            msg.sender,
            _amount,
            address(this),
            _extraData
        );

        return true;
    }

    /// @dev This function makes it easy to get the total number of tokens
    /// @return The total number of tokens
    function totalSupply() public view returns (uint) {
        return totalSupplyAt(block.number);
    }


////////////////
// Query balance and totalSupply in History
////////////////

    /// @dev Queries the balance of `_owner` at a specific `_blockNumber`
    /// @param _owner The address from which the balance will be retrieved
    /// @param _blockNumber The block number when the balance is queried
    /// @return The balance at `_blockNumber`
    function balanceOfAt(address _owner, uint _blockNumber) public view
        returns (uint) {

        // These next few lines are used when the balance of the token is
        //  requested before a check point was ever created for this token, it
        //  requires that the `parentToken.balanceOfAt` be queried at the
        //  genesis block for that token as this contains initial balance of
        //  this token
        if ((balances[_owner].length == 0)
            || (balances[_owner][0].fromBlock > _blockNumber)) {
            if (address(parentToken) != address(0)) {
                return parentToken.balanceOfAt(_owner, min(_blockNumber, parentSnapShotBlock));
            } else {
                // Has no parent
                return 0;
            }

        // This will return the expected balance during normal situations
        } else {
            return getValueAt(balances[_owner], _blockNumber);
        }
    }

    /// @notice Total amount of tokens at a specific `_blockNumber`.
    /// @param _blockNumber The block number when the totalSupply is queried
    /// @return The total amount of tokens at `_blockNumber`
    function totalSupplyAt(uint _blockNumber) public view returns(uint) {

        // These next few lines are used when the totalSupply of the token is
        //  requested before a check point was ever created for this token, it
        //  requires that the `parentToken.totalSupplyAt` be queried at the
        //  genesis block for this token as that contains totalSupply of this
        //  token at this block number.
        if ((totalSupplyHistory.length == 0)
            || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
            if (address(parentToken) != address(0)) {
                return parentToken.totalSupplyAt(min(_blockNumber, parentSnapShotBlock));
            } else {
                return 0;
            }

        // This will return the expected totalSupply during normal situations
        } else {
            return getValueAt(totalSupplyHistory, _blockNumber);
        }
    }

////////////////
// Query pledgedFees // in wei
////////////////

   /// @dev This function makes it easy to get the total pledged fees
   /// @return The total number of fees belonging to token holders
   function totalPledgedFees() public view returns (uint) {
       return totalPledgedFeesAt(block.number);
   }

   /// @notice Total amount of fees at a specific `_blockNumber`.
   /// @param _blockNumber The block number when the totalPledgedFees is queried
   /// @return The total amount of pledged fees at `_blockNumber`
   function totalPledgedFeesAt(uint _blockNumber) public view returns(uint) {

       // These next few lines are used when the totalPledgedFees of the token is
       //  requested before a check point was ever created for this token, it
       //  requires that the `parentToken.totalPledgedFeesAt` be queried at the
       //  genesis block for this token as that contains totalPledgedFees of this
       //  token at this block number.
       if ((totalPledgedFeesHistory.length == 0)
           || (totalPledgedFeesHistory[0].fromBlock > _blockNumber)) {
           if (address(parentToken) != address(0)) {
               return parentToken.totalPledgedFeesAt(min(_blockNumber, parentSnapShotBlock));
           } else {
               return 0;
           }

       // This will return the expected totalPledgedFees during normal situations
       } else {
           return getValueAt(totalPledgedFeesHistory, _blockNumber);
       }
   }

////////////////
// Pledge Fees To Token Holders or Reduce Pledged Fees // in wei
////////////////

   /// @notice Pledges fees to the token holders, later to be claimed by burning
   /// @param _value The amount sent to the vault by controller, reserved for token holders
   function pledgeFees(uint _value) public onlyController returns (bool) {
       uint curTotalFees = totalPledgedFees();
       require(curTotalFees + _value >= curTotalFees); // Check for overflow
       updateValueAtNow(totalPledgedFeesHistory, curTotalFees + _value);
       return true;
   }

   /// @notice Reduces pledged fees to the token holders, i.e. during upgrade or token burning
   /// @param _value The amount of pledged fees which are being distributed to token holders, reducing liability
   function reducePledgedFees(uint _value) public onlyController returns (bool) {
       uint curTotalFees = totalPledgedFees();
       require(curTotalFees >= _value);
       updateValueAtNow(totalPledgedFeesHistory, curTotalFees - _value);
       return true;
   }

////////////////
// Clone Token Method
////////////////

    /// @notice Creates a new clone token with the initial distribution being
    ///  this token at `_snapshotBlock`
    /// @param _cloneTokenName Name of the clone token
    /// @param _cloneDecimalUnits Number of decimals of the smallest unit
    /// @param _cloneTokenSymbol Symbol of the clone token
    /// @param _snapshotBlock Block when the distribution of the parent token is
    ///  copied to set the initial distribution of the new clone token;
    ///  if the block is zero than the actual block, the current block is used
    /// @param _transfersEnabled True if transfers are allowed in the clone
    /// @return The address of the new MiniMeToken Contract
    function createCloneToken(
        string memory _cloneTokenName,
        uint8 _cloneDecimalUnits,
        string memory _cloneTokenSymbol,
        uint _snapshotBlock,
        bool _transfersEnabled
        ) public returns(address) {
        if (_snapshotBlock == 0) _snapshotBlock = block.number;
        MiniMeToken cloneToken = tokenFactory.createCloneToken(
            address(this),
            _snapshotBlock,
            _cloneTokenName,
            _cloneDecimalUnits,
            _cloneTokenSymbol,
            _transfersEnabled
            );

        cloneToken.changeController(msg.sender);

        // An event to make the token easy to find on the blockchain
        emit NewCloneToken(address(cloneToken), _snapshotBlock);
        return address(cloneToken);
    }

////////////////
// Generate and destroy tokens
////////////////

    /// @notice Generates `_amount` tokens that are assigned to `_owner`
    /// @param _owner The address that will be assigned the new tokens
    /// @param _amount The quantity of tokens generated
    /// @return True if the tokens are generated correctly
    function generateTokens(address _owner, uint _amount
    ) public onlyController returns (bool) {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply + _amount >= curTotalSupply); // Check for overflow
        uint previousBalanceTo = balanceOf(_owner);
        require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
        updateValueAtNow(balances[_owner], previousBalanceTo + _amount);
        emit Transfer(address(0), _owner, _amount);
        return true;
    }


    /// @notice Burns `_amount` tokens from `_owner`
    /// @param _owner The address that will lose the tokens
    /// @param _amount The quantity of tokens to burn
    /// @return True if the tokens are burned correctly
    function destroyTokens(address _owner, uint _amount
    ) onlyController public returns (bool) {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply >= _amount);
        uint previousBalanceFrom = balanceOf(_owner);
        require(previousBalanceFrom >= _amount);
        updateValueAtNow(totalSupplyHistory, curTotalSupply - _amount);
        updateValueAtNow(balances[_owner], previousBalanceFrom - _amount);
        emit Transfer(_owner, address(0), _amount);
        return true;
    }

////////////////
// Enable tokens transfers
////////////////


    /// @notice Enables token holders to transfer their tokens freely if true
    /// @param _transfersEnabled True if transfers are allowed in the clone
    function enableTransfers(bool _transfersEnabled) public onlyController {
        transfersEnabled = _transfersEnabled;
    }

////////////////
// Internal helper functions to query and set a value in a snapshot array
////////////////

    /// @dev `getValueAt` retrieves the number of tokens at a given block number
    /// @param checkpoints The history of values being queried
    /// @param _block The block number to retrieve the value at
    /// @return The number of tokens being queried
    function getValueAt(Checkpoint[] storage checkpoints, uint _block
    ) view internal returns (uint) {
        if (checkpoints.length == 0) return 0;

        // Shortcut for the actual value
        if (_block >= checkpoints[checkpoints.length-1].fromBlock)
            return checkpoints[checkpoints.length-1].value;
        if (_block < checkpoints[0].fromBlock) return 0;

        // Binary search of the value in the array
        uint min = 0;
        uint max = checkpoints.length-1;
        while (max > min) {
            uint mid = (max + min + 1)/ 2;
            if (checkpoints[mid].fromBlock<=_block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

    /// @dev `updateValueAtNow` used to update the `balances` map and the
    ///  `totalSupplyHistory`
    /// @param checkpoints The history of data being updated
    /// @param _value The new number of tokens
    function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value
    ) internal  {
        if ((checkpoints.length == 0)
        || (checkpoints[checkpoints.length -1].fromBlock < block.number)) {
               Checkpoint storage newCheckPoint = checkpoints[ checkpoints.length++ ];
               newCheckPoint.fromBlock =  uint128(block.number);
               newCheckPoint.value = uint128(_value);
           } else {
               Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
               oldCheckPoint.value = uint128(_value);
           }
    }

    /// @dev Internal function to determine if an address is a contract
    /// @param _addr The address being queried
    /// @return True if `_addr` is a contract
    function isContract(address _addr) view internal returns(bool) {
        uint size;
        if (_addr == address(0)) return false;
        assembly {
            size := extcodesize(_addr)
        }
        return size>0;
    }

    /// @dev Helper function to return a min betwen the two uints
    function min(uint a, uint b) pure internal returns (uint) {
        return a < b ? a : b;
    }

    /// @notice The fallback function: If the contract's controller has not been
    ///  set to 0, then the `proxyPayment` method is called which relays the
    ///  ether and creates tokens as described in the token controller contract
    function () external payable {
        require(isContract(controller));
        require(TokenController(controller).proxyPayment.value(msg.value)(msg.sender));
    }


////////////////
// Events
////////////////
    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event NewCloneToken(address indexed _cloneToken, uint _snapshotBlock);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
        );

}


////////////////
// MiniMeTokenFactory
////////////////

/// @dev This contract is used to generate clone contracts from a contract.
///  In solidity this is the way to create a contract from a contract of the
///  same class
contract MiniMeTokenFactory {

    /// @notice Update the DApp by creating a new token with new functionalities
    ///  the msg.sender becomes the controller of this clone token
    /// @param _parentToken Address of the token being cloned
    /// @param _snapshotBlock Block of the parent token that will
    ///  determine the initial distribution of the clone token
    /// @param _tokenName Name of the new token
    /// @param _decimalUnits Number of decimals of the new token
    /// @param _tokenSymbol Token Symbol for the new token
    /// @param _transfersEnabled If true, tokens will be able to be transferred
    /// @return The address of the new token contract
    function createCloneToken(
        address payable _parentToken,
        uint _snapshotBlock,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol,
        bool _transfersEnabled
    ) public returns (MiniMeToken) {
        MiniMeToken newToken = new MiniMeToken(
            address(this),
            _parentToken,
            _snapshotBlock,
            _tokenName,
            _decimalUnits,
            _tokenSymbol,
            _transfersEnabled
            );

        newToken.changeController(msg.sender);
        return newToken;
    }
  }


/*
    Copyright 2017, Will Harborne (Ethfinex)
*/

contract DestructibleMiniMeToken is MiniMeToken {

    address payable public terminator;

    constructor(
        address _tokenFactory,
        address payable _parentToken,
        uint _parentSnapShotBlock,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol,
        bool _transfersEnabled,
        address payable _terminator
    ) public MiniMeToken(
        _tokenFactory,
        _parentToken,
        _parentSnapShotBlock,
        _tokenName,
        _decimalUnits,
        _tokenSymbol,
        _transfersEnabled
    ) {
        terminator = _terminator;
    }

    function recycle() public {
        require(msg.sender == terminator);
        selfdestruct(terminator);
    }
}


contract DestructibleMiniMeTokenFactory {

    /// @notice Update the DApp by creating a new token with new functionalities
    ///  the msg.sender becomes the controller of this clone token
    /// @param _parentToken Address of the token being cloned
    /// @param _snapshotBlock Block of the parent token that will
    ///  determine the initial distribution of the clone token
    /// @param _tokenName Name of the new token
    /// @param _decimalUnits Number of decimals of the new token
    /// @param _tokenSymbol Token Symbol for the new token
    /// @param _transfersEnabled If true, tokens will be able to be transferred
    /// @return The address of the new token contract
    function createDestructibleCloneToken(
        address payable _parentToken,
        uint _snapshotBlock,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol,
        bool _transfersEnabled
    ) public returns (DestructibleMiniMeToken) {
        DestructibleMiniMeToken newToken = new DestructibleMiniMeToken(
            address(this),
            _parentToken,
            _snapshotBlock,
            _tokenName,
            _decimalUnits,
            _tokenSymbol,
            _transfersEnabled,
            msg.sender
        );

        newToken.changeController(msg.sender);
        return newToken;
    }
}


contract Ownable {

  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/*
    Copyright 2018, Will Harborne @ Ethfinex
*/

/// @title TokenListingManager Contract
/// @author Will Harborne @ Ethfinex
contract TokenListingManager is Ownable {

    address public constant NECTAR_TOKEN = 0xCc80C051057B774cD75067Dc48f8987C4Eb97A5e;
    address public constant TOKEN_FACTORY = 0x8936131A81F29205EeDDec486f401A8A0aFAb15A;
    uint public constant MAX_CANDIDATES = 20;

    struct TokenProposal {
        address[] consideredTokens;
        uint startBlock;
        uint startTime;
        uint duration;
        DestructibleMiniMeToken votingToken;
        uint[] yesVotes;
        // criteria values
        // 0. only first one win the vote;
        // 1. top N (number in extraData) win the vote;
        // 2. All over N (number in extra data) votes win the vote;
        uint criteria;
        uint extraData;
        bool concluded;
        mapping(address => mapping(address => uint256)) votesForToken;
    }

    TokenProposal[] public tokenBatches;

    DestructibleMiniMeTokenFactory public tokenFactory;
    address payable public nectarToken;
    mapping(address => bool) public admins;

    mapping(address => bool) public isWinner;
    mapping(address => uint256) public winningVotes;
    mapping(address => uint) public proposalWhenTokenWon;

    modifier onlyAdmins() {
        require(isAdmin(msg.sender));
        _;
    }

    constructor(address _tokenFactory, address payable _nectarToken) public {
        tokenFactory = DestructibleMiniMeTokenFactory(_tokenFactory);
        nectarToken = _nectarToken;
        admins[msg.sender] = true;
    }

    /// @notice Admins are able to approve proposal that someone submitted
    /// @param _tokens the list of tokens in consideration during this period
    /// @param _duration number of days for vote token to exist. Second half is for voting.
    /// @param _criteria number that determines how winner is selected
    /// @param _extraData extra data for criteria parameter
    function startTokenVotes(address[] memory _tokens, uint _duration, uint _criteria, uint _extraData) public onlyAdmins {
        require(_tokens.length <= MAX_CANDIDATES);

        if (_criteria == 1) {
            // in other case all tokens would be winners
            require(_extraData < _tokens.length);
        }

        uint _proposalId = tokenBatches.length;
        if (_proposalId > 0) {
          endTokenVote(_proposalId - 1);
        }
        tokenBatches.length++;
        TokenProposal storage p = tokenBatches[_proposalId];
        p.duration = _duration * (1 days);

        p.consideredTokens = _tokens;
        p.yesVotes = new uint[](_tokens.length);

        p.votingToken = tokenFactory.createDestructibleCloneToken(
                nectarToken,
                getBlockNumber(),
                appendUintToString("EfxTokenVotes-", _proposalId),
                MiniMeToken(nectarToken).decimals(),
                appendUintToString("EVT-", _proposalId),
                true);

        p.startTime = now;
        p.startBlock = getBlockNumber();
        p.criteria = _criteria;
        p.extraData = _extraData;
        p.concluded = false;

        emit NewTokens(_proposalId);
    }


    /// @notice Anyone can end the vote if it has completed
    function endTokenVote(uint _proposalId) public returns(bool) {

        require(_proposalId <= tokenBatches.length);

        TokenProposal storage op = tokenBatches[_proposalId];
        require(op.startTime + op.duration < now);
        if (op.concluded) {
          return true;
        }

        uint[] memory _previousWinnerMap = getWinnerIndices(_proposalId);
        for (uint i=0; i < _previousWinnerMap.length; i++) {
            isWinner[op.consideredTokens[_previousWinnerMap[i]]] = true;
            winningVotes[op.consideredTokens[_previousWinnerMap[i]]] = op.yesVotes[_previousWinnerMap[i]];
            proposalWhenTokenWon[op.consideredTokens[_previousWinnerMap[i]]] = _proposalId;
        }

        DestructibleMiniMeToken(op.votingToken).recycle();
        op.concluded = true;
        return true;
    }

    /// @notice Vote for specific token with yes
    /// @param _proposalId is the proposal's position in tokenBatches array
    /// @param _tokenIndex is the position from 0-11 in the token array of the chosen token
    function vote(uint _proposalId, uint _tokenIndex, uint _amount) public {
        // voting only on the most recent set of proposed tokens
        require(tokenBatches.length > 0);
        require(_proposalId == tokenBatches.length - 1);
        require(_tokenIndex < 12);

        TokenProposal storage p = tokenBatches[_proposalId];

        require(now < p.startTime + (p.duration / 2));

        uint amount = DestructibleMiniMeToken(p.votingToken).balanceOf(msg.sender);
        require(amount >= _amount);

        uint weightedAmount = getFactor(_amount);

        require(DestructibleMiniMeToken(p.votingToken).transferFrom(msg.sender, address(this), _amount));

        tokenBatches[_proposalId].yesVotes[_tokenIndex] += weightedAmount;
        p.votesForToken[tokenBatches[_proposalId].consideredTokens[_tokenIndex]][msg.sender] += weightedAmount;

        emit Vote(_proposalId, msg.sender, tokenBatches[_proposalId].consideredTokens[_tokenIndex], weightedAmount);
    }

    function getFactor(uint _amount) view public returns (uint weighted) {
      uint currentRound = tokenBatches.length - 1;
      TokenProposal memory p = tokenBatches[currentRound];
      if ((now - p.startTime) > (p.duration / 2)) {
          weighted = 2;
      } else {
          weighted = 2 * _amount - ((now - p.startTime) * _amount / (p.duration / 2));
      }
    }

    function getWinnerIndices(uint _proposalId) public view returns(uint[] memory winners) {
        require(_proposalId < tokenBatches.length);

        TokenProposal memory p = tokenBatches[_proposalId];

        // there is only one winner in criteria 0
        if (p.criteria == 0) {
            winners = new uint[](1);
            uint max = 0;

            for (uint i=0; i < p.consideredTokens.length; i++) {
                if (p.yesVotes[i] > p.yesVotes[max]) {
                    max = i;
                }
            }

            winners[0] = max;
        }

        // there is N winners in criteria 1
        if (p.criteria == 1) {
            uint[] memory indexesWithMostVotes = new uint[](p.extraData);
            winners = new uint[](p.extraData);

            // for each token we check if he has more votes than last one,
            // if it has we put it in array and always keep array sorted
            for (uint i = 0; i < p.consideredTokens.length; i++) {
                uint last = p.extraData - 1;
                if (p.yesVotes[i] > p.yesVotes[indexesWithMostVotes[last]]) {
                    indexesWithMostVotes[last] = i;

                    for (uint j=last; j > 0; j--) {
                        if (p.yesVotes[indexesWithMostVotes[j]] > p.yesVotes[indexesWithMostVotes[j-1]]) {
                            uint help = indexesWithMostVotes[j];
                            indexesWithMostVotes[j] = indexesWithMostVotes[j-1];
                            indexesWithMostVotes[j-1] = help;
                        }
                    }
                }
            }

            for (uint i = 0; i < p.extraData; i++) {
                winners[i] = indexesWithMostVotes[i];
            }
        }

        // everybody who has over N votes are winners in criteria 2
        if (p.criteria == 2) {
            uint numOfTokens = 0;
            for (uint i = 0; i < p.consideredTokens.length; i++) {
                if (p.yesVotes[i] > p.extraData) {
                    numOfTokens++;
                }
            }

            winners = new uint[](numOfTokens);
            uint count = 0;
            for (uint i = 0; i < p.consideredTokens.length; i++) {
                if (p.yesVotes[i] > p.extraData) {
                    winners[count] = i;
                    count++;
                }
            }
        }
    }

    function getWinners() public view returns(address[] memory) {
        if(tokenBatches.length == 0) {
            return new address[](0);
        }

        uint[] memory winnerIndices = getWinnerIndices(tokenBatches.length - 1);

        TokenProposal memory p = tokenBatches[tokenBatches.length - 1];

        address[] memory winners = new address[](winnerIndices.length);
        for (uint i = 0; i < winnerIndices.length; i++) {
            winners[i] = p.consideredTokens[winnerIndices[i]];
        }
    }

    function getUserVotesForWinner(address _token, address _voter) external view returns(uint256) {
      uint roundWhenWon = proposalWhenTokenWon[_token];
      return tokenBatches[roundWhenWon].votesForToken[_token][_voter];
    }

    /// @notice Get number of proposals so you can know which is the last one
    function numberOfProposals() public view returns(uint) {
        return tokenBatches.length;
    }

    /// @notice Any admin is able to add new admin
    /// @param _newAdmin Address of new admin
    function addAdmin(address _newAdmin) public onlyAdmins {
        admins[_newAdmin] = true;
    }

    /// @notice Only owner is able to remove admin
    /// @param _admin Address of current admin
    function removeAdmin(address _admin) public onlyOwner {
        admins[_admin] = false;
    }

    /// @notice Get data about specific proposal
    /// @param _proposalId Id of proposal
    function proposal(uint _proposalId) public view returns(
        uint _startBlock,
        uint _startTime,
        uint _duration,
        bool _active,
        bool _finalized,
        uint[] memory _votes,
        address[] memory _tokens,
        address _votingToken,
        bool _hasBalance
    ) {
        require(_proposalId < tokenBatches.length);

        TokenProposal memory p = tokenBatches[_proposalId];
        _startBlock = p.startBlock;
        _startTime = p.startTime;
        _duration = p.duration;
        _finalized = (_startTime+_duration < now);
        _active = !_finalized && (p.startBlock < getBlockNumber());
        _votes = p.yesVotes;
        _tokens = p.consideredTokens;
        _votingToken = address(p.votingToken);
        _hasBalance = (_votingToken == address(0)) ? false : (DestructibleMiniMeToken(p.votingToken).balanceOf(msg.sender) > 0);
    }

    function isAdmin(address _admin) public view returns(bool) {
        return admins[_admin];
    }

    function proxyPayment(address ) public payable returns(bool) {
        return false;
    }

    function onTransfer(address, address, uint ) public pure returns(bool) {
        return true;
    }

    function onApprove(address, address, uint ) public pure returns(bool) {
        return true;
    }

    function getBlockNumber() internal view returns (uint) {
        return block.number;
    }

    function appendUintToString(string memory inStr, uint _i) internal pure returns (string memory _str) {
    if (_i == 0) {
        return "0";
    }
    uint j = _i;
    uint len;
    while (j != 0) {
        len++;
        j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint k = len - 1;
    while (_i != 0) {
        bstr[k--] = byte(uint8(48 + _i % 10));
        _i /= 10;
    }

    return string(abi.encodePacked(inStr, string(bstr)));
    }

    event Vote(uint indexed idProposal, address indexed _voter, address chosenToken, uint amount);
    event NewTokens(uint indexed idProposal);
}