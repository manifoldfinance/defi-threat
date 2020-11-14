/**
 * Source Code first verified at https://etherscan.io on Monday, April 22, 2019
 (UTC) */

pragma solidity ^0.5.0;
// produced by the Solididy File Flattener (c) David Appleton 2018
// contact : <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="9ffbfee9fadffef4f0f2fdfeb1fcf0f2">[email protected]</a>
// released under Apache 2.0 licence
// input  C:\github\privateCode\retroArt\reactWebsite\contracts\RetroArtStemToken.sol
// flattened :  Monday, 22-Apr-19 22:14:31 UTC
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

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

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

library AddressUtils {

  /**
   * Returns whether the target address is a contract
   * @dev This function will return false if invoked during the constructor of a contract,
   * as the code is not actually created until after the constructor finishes.
   * @param _addr address to check
   * @return whether the target address is a contract
   */
  function isContract(address _addr) internal view returns (bool) {
    uint256 size;
    // XXX Currently there is no better way to check if there is a contract in an address
    // than to check the size of the code at that address.
    // See https://ethereum.stackexchange.com/a/14016/36603
    // for more details about how this works.
    // TODO Check this again before the Serenity release, because all addresses will be
    // contracts then.
    // solium-disable-next-line security/no-inline-assembly
    assembly { size := extcodesize(_addr) }
    return size > 0;
  }

}

contract ERC721Receiver {
  /**
   * @dev Magic value to be returned upon successful reception of an NFT
   *  Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`,
   *  which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
   */
  bytes4 internal constant ERC721_RECEIVED = 0x150b7a02;

  /**
   * @notice Handle the receipt of an NFT
   * @dev The ERC721 smart contract calls this function on the recipient
   * after a `safetransfer`. This function MAY throw to revert and reject the
   * transfer. Return of other than the magic value MUST result in the
   * transaction being reverted.
   * Note: the contract address is always the message sender.
   * @param _operator The address which called `safeTransferFrom` function
   * @param _from The address which previously owned the token
   * @param _tokenId The NFT identifier which is being transferred
   * @param _data Additional data with no specified format
   * @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
   */
  function onERC721Received(
    address _operator,
    address _from,
    uint256 _tokenId,
    bytes memory _data 
  )
    public
    returns(bytes4);
}

library RecordKeeping {
    struct priceRecord {
        uint256 price;
        address owner;
        uint256 timestamp;

    }
}
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
  function getApproved(uint256 _tokenId)
    public view returns (address _operator);

  function setApprovalForAll(address _operator, bool _approved) public;
  function isApprovedForAll(address _owner, address _operator)
    public view returns (bool);

  function transferFrom(address _from, address _to, uint256 _tokenId) public;
  function safeTransferFrom(address _from, address _to, uint256 _tokenId)
    public;

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes memory _data 
  )
    public;
}

contract SupportsInterfaceWithLookup is ERC165 {

  bytes4 public constant InterfaceId_ERC165 = 0x01ffc9a7;
  /**
   * 0x01ffc9a7 ===
   *   bytes4(keccak256('supportsInterface(bytes4)'))
   */

  /**
   * @dev a mapping of interface id to whether or not it's supported
   */
  mapping(bytes4 => bool) internal supportedInterfaces;

  /**
   * @dev A contract implementing SupportsInterfaceWithLookup
   * implement ERC165 itself
   */
  constructor()
    public
  {
    _registerInterface(InterfaceId_ERC165);
  }

  /**
   * @dev implement supportsInterface(bytes4) using a lookup table
   */
  function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool)
  {
    return supportedInterfaces[_interfaceId];
  }

  /**
   * @dev private method for registering an interface
   */
  function _registerInterface(bytes4 _interfaceId)
    internal
  {
    require(_interfaceId != 0xffffffff);
    supportedInterfaces[_interfaceId] = true;
  }
}

contract Withdrawable  is Ownable {
    
    // _changeType is used to indicate the type of the transaction
    // 0 - normal withdraw 
    // 1 - deposit from selling asset
    // 2 - deposit from profit sharing of new token
    // 3 - deposit from auction
    // 4 - failed auction refund
    // 5 - referral commission

    event BalanceChanged(address indexed _owner, int256 _change,  uint256 _balance, uint8 _changeType);
  
    mapping (address => uint256) internal pendingWithdrawals;
  
    //total pending amount
    uint256 internal totalPendingAmount;

    function _deposit(address addressToDeposit, uint256 amount, uint8 changeType) internal{      
        if (amount > 0) {
            _depositWithoutEvent(addressToDeposit, amount);
            emit BalanceChanged(addressToDeposit, int256(amount), pendingWithdrawals[addressToDeposit], changeType);
        }
    }

    function _depositWithoutEvent(address addressToDeposit, uint256 amount) internal{
        pendingWithdrawals[addressToDeposit] += amount;
        totalPendingAmount += amount;       
    }

    function getBalance(address addressToCheck) public view returns (uint256){
        return pendingWithdrawals[addressToCheck];
    }

    function withdrawOwnFund(address payable recipient_address) public {
        require(msg.sender==recipient_address);

        uint amount = pendingWithdrawals[recipient_address];
        require(amount > 0);
        // Remember to zero the pending refund before
        // sending to prevent re-entrancy attacks
        pendingWithdrawals[recipient_address] = 0;
        totalPendingAmount -= amount;
        recipient_address.transfer(amount);
        emit BalanceChanged(recipient_address, -1 * int256(amount),  0, 0);
    }

    function checkAvailableContractBalance() public view returns (uint256){
        if (address(this).balance > totalPendingAmount){
            return address(this).balance - totalPendingAmount;
        } else{
            return 0;
        }
    }
    function withdrawContractFund(address payable recipient_address) public onlyOwner  {
        uint256 amountToWithdraw = checkAvailableContractBalance();
        if (amountToWithdraw > 0){
            recipient_address.transfer(amountToWithdraw);
        }
    }
} 
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

contract ERC721BasicToken is SupportsInterfaceWithLookup, ERC721Basic {

  using SafeMath for uint256;
  using AddressUtils for address;

  // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
  // which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
  bytes4 private constant ERC721_RECEIVED = 0x150b7a02;

  // Mapping from token ID to owner
  mapping (uint256 => address) internal tokenOwner;

  // Mapping from token ID to approved address
  mapping (uint256 => address) internal tokenApprovals;

  // Mapping from owner to number of owned token
  mapping (address => uint256) internal ownedTokensCount;

  // Mapping from owner to operator approvals
  mapping (address => mapping (address => bool)) internal operatorApprovals;

  constructor()
    public
  {
    // register the supported interfaces to conform to ERC721 via ERC165
    _registerInterface(InterfaceId_ERC721);
    _registerInterface(InterfaceId_ERC721Exists);
  }

  /**
   * @dev Gets the balance of the specified address
   * @param _owner address to query the balance of
   * @return uint256 representing the amount owned by the passed address
   */
  function balanceOf(address _owner) public view returns (uint256) {
    require(_owner != address(0));
    return ownedTokensCount[_owner];
  }

  /**
   * @dev Gets the owner of the specified token ID
   * @param _tokenId uint256 ID of the token to query the owner of
   * @return owner address currently marked as the owner of the given token ID
   */
  function ownerOf(uint256 _tokenId) public view returns (address) {
    address owner = tokenOwner[_tokenId];
    require(owner != address(0));
    return owner;
  }

  /**
   * @dev Returns whether the specified token exists
   * @param _tokenId uint256 ID of the token to query the existence of
   * @return whether the token exists
   */
  function exists(uint256 _tokenId) public view returns (bool) {
    address owner = tokenOwner[_tokenId];
    return owner != address(0);
  }

  /**
   * @dev Approves another address to transfer the given token ID
   * The zero address indicates there is no approved address.
   * There can only be one approved address per token at a given time.
   * Can only be called by the token owner or an approved operator.
   * @param _to address to be approved for the given token ID
   * @param _tokenId uint256 ID of the token to be approved
   */
  function approve(address _to, uint256 _tokenId) public {
    address owner = ownerOf(_tokenId);
    require(_to != owner);
    require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

    tokenApprovals[_tokenId] = _to;
    emit Approval(owner, _to, _tokenId);
  }

  /**
   * @dev Gets the approved address for a token ID, or zero if no address set
   * @param _tokenId uint256 ID of the token to query the approval of
   * @return address currently approved for the given token ID
   */
  function getApproved(uint256 _tokenId) public view returns (address) {
    return tokenApprovals[_tokenId];
  }

  /**
   * @dev Sets or unsets the approval of a given operator
   * An operator is allowed to transfer all tokens of the sender on their behalf
   * @param _to operator address to set the approval
   * @param _approved representing the status of the approval to be set
   */
  function setApprovalForAll(address _to, bool _approved) public {
    require(_to != msg.sender);
    operatorApprovals[msg.sender][_to] = _approved;
    emit ApprovalForAll(msg.sender, _to, _approved);
  }

  /**
   * @dev Tells whether an operator is approved by a given owner
   * @param _owner owner address which you want to query the approval of
   * @param _operator operator address which you want to query the approval of
   * @return bool whether the given operator is approved by the given owner
   */
  function isApprovedForAll(
    address _owner,
    address _operator
  )
    public
    view
    returns (bool)
  {
    return operatorApprovals[_owner][_operator];
  }

  /**
   * @dev Transfers the ownership of a given token ID to another address
   * Usage of this method is discouraged, use `safeTransferFrom` whenever possible
   * Requires the msg sender to be the owner, approved, or operator
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
  */
  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    public
  {
    require(isApprovedOrOwner(msg.sender, _tokenId));
    require(_from != address(0));
    require(_to != address(0));

    clearApproval(_from, _tokenId);
    removeTokenFrom(_from, _tokenId);
    addTokenTo(_to, _tokenId);

    emit Transfer(_from, _to, _tokenId);
  }

  /**
   * @dev Safely transfers the ownership of a given token ID to another address
   * If the target address is a contract, it must implement `onERC721Received`,
   * which is called upon a safe transfer, and return the magic value
   * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
   * the transfer is reverted.
   *
   * Requires the msg sender to be the owner, approved, or operator
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
  */
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    public
  {
    // solium-disable-next-line arg-overflow
    safeTransferFrom(_from, _to, _tokenId, "");
  }

  /**
   * @dev Safely transfers the ownership of a given token ID to another address
   * If the target address is a contract, it must implement `onERC721Received`,
   * which is called upon a safe transfer, and return the magic value
   * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
   * the transfer is reverted.
   * Requires the msg sender to be the owner, approved, or operator
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
   * @param _data bytes data to send along with a safe transfer check
   */
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes memory _data
  )
    public
  {
    transferFrom(_from, _to, _tokenId);
    // solium-disable-next-line arg-overflow
    require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
  }

  /**
   * @dev Returns whether the given spender can transfer a given token ID
   * @param _spender address of the spender to query
   * @param _tokenId uint256 ID of the token to be transferred
   * @return bool whether the msg.sender is approved for the given token ID,
   *  is an operator of the owner, or is the owner of the token
   */
  function isApprovedOrOwner(
    address _spender,
    uint256 _tokenId
  )
    internal
    view
    returns (bool)
  {
    address owner = ownerOf(_tokenId);
    // Disable solium check because of
    // https://github.com/duaraghav8/Solium/issues/175
    // solium-disable-next-line operator-whitespace
    return (
      _spender == owner ||
      getApproved(_tokenId) == _spender ||
      isApprovedForAll(owner, _spender)
    );
  }

  /**
   * @dev Internal function to mint a new token
   * Reverts if the given token ID already exists
   * @param _to The address that will own the minted token
   * @param _tokenId uint256 ID of the token to be minted by the msg.sender
   */
  function _mint(address _to, uint256 _tokenId) internal {
    require(_to != address(0));
    addTokenTo(_to, _tokenId);
    emit Transfer(address(0), _to, _tokenId);
  }

  /**
   * @dev Internal function to burn a specific token
   * Reverts if the token does not exist
   * @param _tokenId uint256 ID of the token being burned by the msg.sender
   */
  function _burn(address _owner, uint256 _tokenId) internal {
    clearApproval(_owner, _tokenId);
    removeTokenFrom(_owner, _tokenId);
    emit Transfer(_owner, address(0), _tokenId);
  }

  /**
   * @dev Internal function to clear current approval of a given token ID
   * Reverts if the given address is not indeed the owner of the token
   * @param _owner owner of the token
   * @param _tokenId uint256 ID of the token to be transferred
   */
  function clearApproval(address _owner, uint256 _tokenId) internal {
    require(ownerOf(_tokenId) == _owner);
    if (tokenApprovals[_tokenId] != address(0)) {
      tokenApprovals[_tokenId] = address(0);
    }
  }

  /**
   * @dev Internal function to add a token ID to the list of a given address
   * @param _to address representing the new owner of the given token ID
   * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
   */
  function addTokenTo(address _to, uint256 _tokenId) internal {
    require(tokenOwner[_tokenId] == address(0));
    tokenOwner[_tokenId] = _to;
    ownedTokensCount[_to] = ownedTokensCount[_to].add(1);
  }

  /**
   * @dev Internal function to remove a token ID from the list of a given address
   * @param _from address representing the previous owner of the given token ID
   * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
   */
  function removeTokenFrom(address _from, uint256 _tokenId) internal {
    require(ownerOf(_tokenId) == _from);
    ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);
    tokenOwner[_tokenId] = address(0);
  }

  /**
   * @dev Internal function to invoke `onERC721Received` on a target address
   * The call is not executed if the target address is not a contract
   * @param _from address representing the previous owner of the given token ID
   * @param _to target address that will receive the tokens
   * @param _tokenId uint256 ID of the token to be transferred
   * @param _data bytes optional data to send along with the call
   * @return whether the call correctly returned the expected magic value
   */
  function checkAndCallSafeTransfer(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes memory _data
  )
    internal
    returns (bool)
  {
    if (!_to.isContract()) {
      return true;
    }
    bytes4 retval = ERC721Receiver(_to).onERC721Received(
      msg.sender, _from, _tokenId, _data);
    return (retval == ERC721_RECEIVED);
  }
}

contract ERC721Enumerable is ERC721Basic {
  function totalSupply() public view returns (uint256);
  function tokenOfOwnerByIndex(
    address _owner,
    uint256 _index
  )
    public
    view
    returns (uint256 _tokenId);

  function tokenByIndex(uint256 _index) public view returns (uint256);
}


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Metadata is ERC721Basic {
  function name() external view returns (string memory _name);
  function symbol() external view returns (string memory _symbol);
  function tokenURI(uint256 _tokenId) public view returns (string memory);
}


/**
 * @title ERC-721 Non-Fungible Token Standard, full implementation interface
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract ERC721WithState is ERC721BasicToken {
    mapping (uint256 => uint8) internal tokenState;

    event TokenStateSet(uint256 indexed _tokenId,  uint8 _state);

    function setTokenState(uint256  _tokenId,  uint8 _state) public  {
        require(isApprovedOrOwner(msg.sender, _tokenId));
        require(exists(_tokenId)); 
        tokenState[_tokenId] = _state;      
        emit TokenStateSet(_tokenId, _state);
    }

    function getTokenState(uint256  _tokenId) public view returns (uint8){
        require(exists(_tokenId));
        return tokenState[_tokenId];
    } 


}
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}

contract ERC721Token is SupportsInterfaceWithLookup, ERC721BasicToken, ERC721 {

  // Token name
  string internal name_;

  // Token symbol
  string internal symbol_;

  // Mapping from owner to list of owned token IDs
  mapping(address => uint256[]) internal ownedTokens;

  // Mapping from token ID to index of the owner tokens list
  mapping(uint256 => uint256) internal ownedTokensIndex;

  // Array with all token ids, used for enumeration
  uint256[] internal allTokens;

  // Mapping from token id to position in the allTokens array
  mapping(uint256 => uint256) internal allTokensIndex;

  // Optional mapping for token URIs
  mapping(uint256 => string) internal tokenURIs;

  /**
   * @dev Constructor function
   */
  constructor(string memory _name, string memory _symbol) public {
    name_ = _name;
    symbol_ = _symbol;

    // register the supported interfaces to conform to ERC721 via ERC165
    _registerInterface(InterfaceId_ERC721Enumerable);
    _registerInterface(InterfaceId_ERC721Metadata);
  }

  /**
   * @dev Gets the token name
   * @return string representing the token name
   */
  function name() external view returns (string memory) {
    return name_;
  }

  /**
   * @dev Gets the token symbol
   * @return string representing the token symbol
   */
  function symbol() external view returns (string memory) {
    return symbol_;
  }

  /**
   * @dev Returns an URI for a given token ID
   * Throws if the token ID does not exist. May return an empty string.
   * @param _tokenId uint256 ID of the token to query
   */
  function tokenURI(uint256 _tokenId) public view returns (string memory) {
    require(exists(_tokenId));
    return tokenURIs[_tokenId];
  }

  /**
   * @dev Gets the token ID at a given index of the tokens list of the requested owner
   * @param _owner address owning the tokens list to be accessed
   * @param _index uint256 representing the index to be accessed of the requested tokens list
   * @return uint256 token ID at the given index of the tokens list owned by the requested address
   */
  function tokenOfOwnerByIndex(
    address _owner,
    uint256 _index
  )
    public
    view
    returns (uint256)
  {
    require(_index < balanceOf(_owner));
    return ownedTokens[_owner][_index];
  }

  /**
   * @dev Gets the total amount of tokens stored by the contract
   * @return uint256 representing the total amount of tokens
   */
  function totalSupply() public view returns (uint256) {
    return allTokens.length;
  }

  /**
   * @dev Gets the token ID at a given index of all the tokens in this contract
   * Reverts if the index is greater or equal to the total number of tokens
   * @param _index uint256 representing the index to be accessed of the tokens list
   * @return uint256 token ID at the given index of the tokens list
   */
  function tokenByIndex(uint256 _index) public view returns (uint256) {
    require(_index < totalSupply());
    return allTokens[_index];
  }

  /**
   * @dev Internal function to set the token URI for a given token
   * Reverts if the token ID does not exist
   * @param _tokenId uint256 ID of the token to set its URI
   * @param _uri string URI to assign
   */
  function _setTokenURI(uint256 _tokenId, string memory _uri) internal {
    require(exists(_tokenId));
    tokenURIs[_tokenId] = _uri;
  }

  /**
   * @dev Internal function to add a token ID to the list of a given address
   * @param _to address representing the new owner of the given token ID
   * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
   */
  function addTokenTo(address _to, uint256 _tokenId) internal {
    super.addTokenTo(_to, _tokenId);
    uint256 length = ownedTokens[_to].length;
    ownedTokens[_to].push(_tokenId);
    ownedTokensIndex[_tokenId] = length;
  }

  /**
   * @dev Internal function to remove a token ID from the list of a given address
   * @param _from address representing the previous owner of the given token ID
   * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
   */
  function removeTokenFrom(address _from, uint256 _tokenId) internal {
    super.removeTokenFrom(_from, _tokenId);

    // To prevent a gap in the array, we store the last token in the index of the token to delete, and
    // then delete the last slot.
    uint256 tokenIndex = ownedTokensIndex[_tokenId];
    uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);
    uint256 lastToken = ownedTokens[_from][lastTokenIndex];

    ownedTokens[_from][tokenIndex] = lastToken;
    // This also deletes the contents at the last position of the array
    ownedTokens[_from].length--;

    // Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to
    // be zero. Then we can make sure that we will remove _tokenId from the ownedTokens list since we are first swapping
    // the lastToken to the first position, and then dropping the element placed in the last position of the list

    ownedTokensIndex[_tokenId] = 0;
    ownedTokensIndex[lastToken] = tokenIndex;
  }

  /**
   * @dev Internal function to mint a new token
   * Reverts if the given token ID already exists
   * @param _to address the beneficiary that will own the minted token
   * @param _tokenId uint256 ID of the token to be minted by the msg.sender
   */
  function _mint(address _to, uint256 _tokenId) internal {
    super._mint(_to, _tokenId);

    allTokensIndex[_tokenId] = allTokens.length;
    allTokens.push(_tokenId);
  }

  /**
   * @dev Internal function to burn a specific token
   * Reverts if the token does not exist
   * @param _owner owner of the token to burn
   * @param _tokenId uint256 ID of the token being burned by the msg.sender
   */
  function _burn(address _owner, uint256 _tokenId) internal {
    super._burn(_owner, _tokenId);

    // Clear metadata (if any)
    if (bytes(tokenURIs[_tokenId]).length != 0) {
      delete tokenURIs[_tokenId];
    }

    // Reorg all tokens array
    uint256 tokenIndex = allTokensIndex[_tokenId];
    uint256 lastTokenIndex = allTokens.length.sub(1);
    uint256 lastToken = allTokens[lastTokenIndex];

    allTokens[tokenIndex] = lastToken;
    allTokens[lastTokenIndex] = 0;

    allTokens.length--;
    allTokensIndex[_tokenId] = 0;
    allTokensIndex[lastToken] = tokenIndex;
  }

}

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address _to,
    uint256 _amount
  )
    public
    hasMintPermission
    canMint
    returns (bool)
  {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() public onlyOwner canMint returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}

contract StandardBurnableToken is BurnableToken, StandardToken {

  /**
   * @dev Burns a specific amount of tokens from the target address and decrements allowance
   * @param _from address The address which you want to send tokens from
   * @param _value uint256 The amount of token to be burned
   */
  function burnFrom(address _from, uint256 _value) public {
    require(_value <= allowed[_from][msg.sender]);
    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    _burn(_from, _value);
  }
}

contract RetroArt is ERC721Token, Ownable, Withdrawable, ERC721WithState {
    
    address public stemTokenContractAddress; 
    uint256 public currentPrice;
    uint256 constant initiailPrice = 0.03 ether;
    //new asset price increase at the rate that determined by the variable below
    //it is caculated from the current price + (current price / ( price rate * totalTokens / slowDownRate ))
    uint public priceRate = 10;
    uint public slowDownRate = 7;
    //Commission will be charged if a profit is made
    //Commission is the pure profit / profit Commission  
    // measured in basis points (1/100 of a percent) 
    // Values 0-10,000 map to 0%-100%
    uint public profitCommission = 500;

    //the referral percentage of the commission of selling of aset
    // measured in basis points (1/100 of a percent) 
    // Values 0-10,000 map to 0%-100%
    uint public referralCommission = 3000;

    //share will be given to all tokens equally if a new asset is acquired. 
    //the amount of total shared value is assetValue/sharePercentage   
    // measured in basis points (1/100 of a percent) 
    // Values 0-10,000 map to 0%-100%
    uint public sharePercentage = 3000;

    //number of shares for acquiring new asset. 
    uint public numberOfShares = 10;

    string public uriPrefix ="";


    // Mapping from owner to list of owned token IDs
    mapping (uint256 => string) internal tokenTitles;
    mapping (uint256 => RecordKeeping.priceRecord) internal initialPriceRecords;
    mapping (uint256 => RecordKeeping.priceRecord) internal lastPriceRecords;
    mapping (uint256 => uint256) internal currentTokenPrices;


    event AssetAcquired(address indexed _owner, uint256 indexed _tokenId, string  _title, uint256 _price);
    event TokenPriceSet(uint256 indexed _tokenId,  uint256 _price);
    event TokenBrought(address indexed _from, address indexed _to, uint256 indexed _tokenId, uint256 _price);
    event PriceRateChanged(uint _priceRate);
    event SlowDownRateChanged(uint _slowDownRate);
    event ProfitCommissionChanged(uint _profitCommission);
    event MintPriceChanged(uint256 _price);
    event SharePercentageChanged(uint _sharePercentage);
    event NumberOfSharesChanged(uint _numberOfShares);
    event ReferralCommissionChanged(uint _referralCommission);
    event Burn(address indexed _owner, uint256 _tokenId);

   

    bytes4 private constant InterfaceId_RetroArt = 0x94fb30be;
    /*
    bytes4(keccak256("buyTokenFrom(address,address,uint256)"))^
    bytes4(keccak256("setTokenPrice(uint256,uint256)"))^
    bytes4(keccak256("setTokenState(uint256,uint8)"))^
    bytes4(keccak256("getTokenState(uint256)"));
    */

    address[] internal auctionContractAddresses;
 
   

    function tokenTitle(uint256 _tokenId) public view returns (string memory) {
        require(exists(_tokenId));
        return tokenTitles[_tokenId];
    }
    function lastPriceOf(uint256 _tokenId) public view returns (uint256) {
        require(exists(_tokenId));
        return  lastPriceRecords[_tokenId].price;
    }   

    function lastTransactionTimeOf(uint256 _tokenId) public view returns (uint256) {
        require(exists(_tokenId));
        return  lastPriceRecords[_tokenId].timestamp;
    }

    function firstPriceOf(uint256 _tokenId) public view returns (uint256) {
        require(exists(_tokenId));
        return  initialPriceRecords[_tokenId].price;
    }   
    function creatorOf(uint256 _tokenId) public view returns (address) {
        require(exists(_tokenId));
        return  initialPriceRecords[_tokenId].owner;
    }
    function firstTransactionTimeOf(uint256 _tokenId) public view returns (uint256) {
        require(exists(_tokenId));
        return  initialPriceRecords[_tokenId].timestamp;
    }
    
  
    //problem with current web3.js that can't return an array of struct
    function lastHistoryOf(uint256 _tokenId) internal view returns (RecordKeeping.priceRecord storage) {
        require(exists(_tokenId));
        return lastPriceRecords[_tokenId];
    }

    function firstHistoryOf(uint256 _tokenId) internal view returns (RecordKeeping.priceRecord storage) {
        require(exists(_tokenId)); 
        return   initialPriceRecords[_tokenId];
    }

    function setPriceRate(uint _priceRate) public onlyOwner {
        priceRate = _priceRate;
        emit PriceRateChanged(priceRate);
    }

    function setSlowDownRate(uint _slowDownRate) public onlyOwner {
        slowDownRate = _slowDownRate;
        emit SlowDownRateChanged(slowDownRate);
    }
 
    function setprofitCommission(uint _profitCommission) public onlyOwner {
        require(_profitCommission <= 10000);
        profitCommission = _profitCommission;
        emit ProfitCommissionChanged(profitCommission);
    }

    function setSharePercentage(uint _sharePercentage) public onlyOwner  {
        require(_sharePercentage <= 10000);
        sharePercentage = _sharePercentage;
        emit SharePercentageChanged(sharePercentage);
    }

    function setNumberOfShares(uint _numberOfShares) public onlyOwner  {
        numberOfShares = _numberOfShares;
        emit NumberOfSharesChanged(numberOfShares);
    }

    function setReferralCommission(uint _referralCommission) public onlyOwner  {
        require(_referralCommission <= 10000);
        referralCommission = _referralCommission;
        emit ReferralCommissionChanged(referralCommission);
    }

    function setUriPrefix(string memory _uri) public onlyOwner  {
       uriPrefix = _uri;
    }
  
    //use the token name, symbol as usual
    //this contract create another ERC20 as stemToken,
    //the constructure takes the stemTokenName and stemTokenSymbol

    constructor(string memory _name, string memory _symbol , address _stemTokenAddress) 
        ERC721Token(_name, _symbol) Ownable() public {
       
        currentPrice = initiailPrice;
        stemTokenContractAddress = _stemTokenAddress;
        _registerInterface(InterfaceId_RetroArt);
    }

    function getAllAssets() public view returns (uint256[] memory){
        return allTokens;
    }

    function getAllAssetsForSale() public view returns  (uint256[] memory){
      
        uint arrayLength = allTokens.length;
        uint forSaleCount = 0;
        for (uint i = 0; i<arrayLength; i++) {
            if (currentTokenPrices[allTokens[i]] > 0) {
                forSaleCount++;              
            }
        }
        
        uint256[] memory tokensForSale = new uint256[](forSaleCount);

        uint j = 0;
        for (uint i = 0; i<arrayLength; i++) {
            if (currentTokenPrices[allTokens[i]] > 0) {                
                tokensForSale[j] = allTokens[i];
                j++;
            }
        }

        return tokensForSale;
    }

    function getAssetsForSale(address _owner) public view returns (uint256[] memory) {
      
        uint arrayLength = allTokens.length;
        uint forSaleCount = 0;
        for (uint i = 0; i<arrayLength; i++) {
            if (currentTokenPrices[allTokens[i]] > 0 && tokenOwner[allTokens[i]] == _owner) {
                forSaleCount++;              
            }
        }
        
        uint256[] memory tokensForSale = new uint256[](forSaleCount);

        uint j = 0;
        for (uint i = 0; i<arrayLength; i++) {
            if (currentTokenPrices[allTokens[i]] > 0 && tokenOwner[allTokens[i]] == _owner) {                
                tokensForSale[j] = allTokens[i];
                j++;
            }
        }

        return tokensForSale;
    }

    function getAssetsByState(uint8 _state) public view returns (uint256[] memory){
        
        uint arrayLength = allTokens.length;
        uint matchCount = 0;
        for (uint i = 0; i<arrayLength; i++) {
            if (tokenState[allTokens[i]] == _state) {
                matchCount++;              
            }
        }
        
        uint256[] memory matchedTokens = new uint256[](matchCount);

        uint j = 0;
        for (uint i = 0; i<arrayLength; i++) {
            if (tokenState[allTokens[i]] == _state) {                
                matchedTokens[j] = allTokens[i];
                j++;
            }
        }

        return matchedTokens;
    }
      

    function acquireAsset(uint256 _tokenId, string memory _title) public payable{
        acquireAssetWithReferral(_tokenId, _title, address(0));
    }

    function acquireAssetFromStemToken(address _tokenOwner, uint256 _tokenId, string calldata _title) external {     
         require(msg.sender == stemTokenContractAddress);
        _acquireAsset(_tokenId, _title, _tokenOwner, 0);
    }

    function acquireAssetWithReferral(uint256 _tokenId, string memory _title, address referralAddress) public payable{
        require(msg.value >= currentPrice);
        
        uint totalShares = numberOfShares;
        if (referralAddress != address(0)) totalShares++;

        uint numberOfTokens = allTokens.length;
     
        if (numberOfTokens > 0 && sharePercentage > 0) {

            uint256 perShareValue = 0;
            uint256 totalShareValue = msg.value * sharePercentage / 10000 ;

            if (totalShares > numberOfTokens) {
                               
                if (referralAddress != address(0)) 
                    perShareValue = totalShareValue / (numberOfTokens + 1);
                else
                    perShareValue = totalShareValue / numberOfTokens;
            
                for (uint i = 0; i < numberOfTokens; i++) {
                    //turn off events if there are too many tokens in the loop
                    if (numberOfTokens > 100) {
                        _depositWithoutEvent(tokenOwner[allTokens[i]], perShareValue);
                    }else{
                        _deposit(tokenOwner[allTokens[i]], perShareValue, 2);
                    }
                }
                
            }else{
               
                if (referralAddress != address(0)) 
                    perShareValue = totalShareValue / (totalShares + 1);
                else
                    perShareValue = totalShareValue / totalShares;
              
                uint[] memory randomArray = random(numberOfShares);

                for (uint i = 0; i < numberOfShares; i++) {
                    uint index = randomArray[i] % numberOfTokens;

                    if (numberOfShares > 100) {
                        _depositWithoutEvent(tokenOwner[allTokens[index]], perShareValue);
                    }else{
                        _deposit(tokenOwner[allTokens[index]], perShareValue, 2);
                    }
                }
            }
                    
            if (referralAddress != address(0) && perShareValue > 0) _deposit(referralAddress, perShareValue, 5);

        }

        _acquireAsset(_tokenId, _title, msg.sender, msg.value);
     
    }

    function _acquireAsset(uint256 _tokenId, string memory _title, address _purchaser, uint256 _value) internal {
        
        currentPrice = CalculateNextPrice();
        _mint(_purchaser, _tokenId);        
      
        tokenTitles[_tokenId] = _title;
       
        RecordKeeping.priceRecord memory pr = RecordKeeping.priceRecord(_value, _purchaser, block.timestamp);
        initialPriceRecords[_tokenId] = pr;
        lastPriceRecords[_tokenId] = pr;     

        emit AssetAcquired(_purchaser,_tokenId, _title, _value);
        emit TokenBrought(address(0), _purchaser, _tokenId, _value);
        emit MintPriceChanged(currentPrice);
    }

    function CalculateNextPrice() public view returns (uint256){      
        return currentPrice + currentPrice * slowDownRate / ( priceRate * (allTokens.length + 2));
    }

    function tokensOf(address _owner) public view returns (uint256[] memory){
        return ownedTokens[_owner];
    }

    function _buyTokenFromWithReferral(address _from, address _to, uint256 _tokenId, address referralAddress, address _depositTo) internal {
        require(currentTokenPrices[_tokenId] != 0);
        require(msg.value >= currentTokenPrices[_tokenId]);
        
        tokenApprovals[_tokenId] = _to;
        safeTransferFrom(_from,_to,_tokenId);

        uint256 valueTransferToOwner = msg.value;
        uint256 lastRecordPrice = lastPriceRecords[_tokenId].price;
        if (msg.value >  lastRecordPrice){
            uint256 profit = msg.value - lastRecordPrice;           
            uint256 commission = profit * profitCommission / 10000;
            valueTransferToOwner = msg.value - commission;
            if (referralAddress != address(0)){
                _deposit(referralAddress, commission * referralCommission / 10000, 5);
            }           
        }
        
        if (valueTransferToOwner > 0) _deposit(_depositTo, valueTransferToOwner, 1);
        writePriceRecordForAssetSold(_depositTo, msg.sender, _tokenId, msg.value);
        
    }

    function buyTokenFromWithReferral(address _from, address _to, uint256 _tokenId, address referralAddress) public payable {
        _buyTokenFromWithReferral(_from, _to, _tokenId, referralAddress, _from);        
    }

    function buyTokenFrom(address _from, address _to, uint256 _tokenId) public payable {
        buyTokenFromWithReferral(_from, _to, _tokenId, address(0));        
    }   

    function writePriceRecordForAssetSold(address _from, address _to, uint256 _tokenId, uint256 _value) internal {
       RecordKeeping.priceRecord memory pr = RecordKeeping.priceRecord(_value, _to, block.timestamp);
       lastPriceRecords[_tokenId] = pr;
       
       tokenApprovals[_tokenId] = address(0);
       currentTokenPrices[_tokenId] = 0;
       emit TokenBrought(_from, _to, _tokenId, _value);       
    }

    function recordAuctionPriceRecord(address _from, address _to, uint256 _tokenId, uint256 _value)
       external {

       require(findAuctionContractIndex(msg.sender) >= 0); //make sure the sender is from one of the auction addresses
       writePriceRecordForAssetSold(_from, _to, _tokenId, _value);

    }

    function setTokenPrice(uint256 _tokenId, uint256 _newPrice) public  {
        require(isApprovedOrOwner(msg.sender, _tokenId));
        currentTokenPrices[_tokenId] = _newPrice;
        emit TokenPriceSet(_tokenId, _newPrice);
    }

    function getTokenPrice(uint256 _tokenId)  public view returns(uint256) {
        return currentTokenPrices[_tokenId];
    }

    function random(uint num) private view returns (uint[] memory) {
        
        uint base = uint(keccak256(abi.encodePacked(block.difficulty, now, tokenOwner[allTokens[allTokens.length-1]])));
        uint[] memory randomNumbers = new uint[](num);
        
        for (uint i = 0; i<num; i++) {
            randomNumbers[i] = base;
            base = base * 2 ** 3;
        }
        return  randomNumbers;
        
    }


    function getAsset(uint256 _tokenId)  external
        view
        returns
    (
        string memory title,            
        address owner,     
        address creator,      
        uint256 currentTokenPrice,
        uint256 lastPrice,
        uint256 initialPrice,
        uint256 lastDate,
        uint256 createdDate
    ) {
        require(exists(_tokenId));
        RecordKeeping.priceRecord memory lastPriceRecord = lastPriceRecords[_tokenId];
        RecordKeeping.priceRecord memory initialPriceRecord = initialPriceRecords[_tokenId];

        return (
             
            tokenTitles[_tokenId],        
            tokenOwner[_tokenId],   
            initialPriceRecord.owner,           
            currentTokenPrices[_tokenId],      
            lastPriceRecord.price,           
            initialPriceRecord.price,
            lastPriceRecord.timestamp,
            initialPriceRecord.timestamp
        );
    }

    function getAssetUpdatedInfo(uint256 _tokenId) external
        view
        returns
    (         
        address owner, 
        address approvedAddress,
        uint256 currentTokenPrice,
        uint256 lastPrice,      
        uint256 lastDate
      
    ) {
        require(exists(_tokenId));
        RecordKeeping.priceRecord memory lastPriceRecord = lastPriceRecords[_tokenId];
     
        return (
            tokenOwner[_tokenId],   
            tokenApprovals[_tokenId],  
            currentTokenPrices[_tokenId],      
            lastPriceRecord.price,   
            lastPriceRecord.timestamp           
        );
    }

    function getAssetStaticInfo(uint256 _tokenId)  external
        view
        returns
    (
        string memory title,            
        string memory tokenURI,    
        address creator,            
        uint256 initialPrice,       
        uint256 createdDate
    ) {
        require(exists(_tokenId));      
        RecordKeeping.priceRecord memory initialPriceRecord = initialPriceRecords[_tokenId];

        return (
             
            tokenTitles[_tokenId],        
            tokenURIs[_tokenId],
            initialPriceRecord.owner,
            initialPriceRecord.price,         
            initialPriceRecord.timestamp
        );
         
    }

    function burnExchangeToken(address _tokenOwner, uint256 _tokenId) external  {
        require(msg.sender == stemTokenContractAddress);       
        _burn(_tokenOwner, _tokenId);       
        emit Burn(_tokenOwner, _tokenId);
    }

    function findAuctionContractIndex(address _addressToFind) public view returns (int)  {
        
        for (int i = 0; i < int(auctionContractAddresses.length); i++){
            if (auctionContractAddresses[uint256(i)] == _addressToFind){
                return i;
            }
        }
        return -1;
    }

    function addAuctionContractAddress(address _auctionContractAddress) public onlyOwner {
        require(findAuctionContractIndex(_auctionContractAddress) == -1);
        auctionContractAddresses.push(_auctionContractAddress);
    }

    function removeAuctionContractAddress(address _auctionContractAddress) public onlyOwner {
        int index = findAuctionContractIndex(_auctionContractAddress);
        require(index >= 0);        

        for (uint i = uint(index); i < auctionContractAddresses.length-1; i++){
            auctionContractAddresses[i] = auctionContractAddresses[i+1];         
        }
        auctionContractAddresses.length--;
    }

    function setStemTokenContractAddress(address _stemTokenContractAddress) public onlyOwner {        
        stemTokenContractAddress = _stemTokenContractAddress;
    }          
   

    function tokenURI(uint256 _tokenId) public view returns (string memory) {
        require(exists(_tokenId));   
        return string(abi.encodePacked(uriPrefix, uint256ToString(_tokenId)));

    }
    // Functions used for generating the URI
    function amountOfZeros(uint256 num, uint256 base) public pure returns(uint256){
        uint256 result = 0;
        num /= base;
        while (num > 0){
            num /= base;
            result += 1;
        }
        return result;
    }

      function uint256ToString(uint256 num) public pure returns(string memory){
        if (num == 0){
            return "0";
        }
        uint256 numLen = amountOfZeros(num, 10) + 1;
        bytes memory result = new bytes(numLen);
        while(num != 0){
            numLen -= 1;
            result[numLen] = byte(uint8((num - (num / 10 * 10)) + 48));
            num /= 10;
        }
        return string(result);
    }

    //  function initialImport(uint256[] memory _tokenIds,
    //                         uint256[] memory _lastPrices, address[] memory _owners, uint256[] memory _lastDates,
    //                         uint256[] memory _initialPrices, address[] memory _creators, uint256[] memory _initialDates,
    //                         string[] memory _titles ) public onlyOwner {
    
    //     require( _tokenIds.length == _lastPrices.length &&
    //             _tokenIds.length == _owners.length &&
    //             _tokenIds.length == _lastDates.length &&
    //             _tokenIds.length == _initialPrices.length &&
    //             _tokenIds.length == _creators.length &&
    //             _tokenIds.length == _initialDates.length &&
    //             _tokenIds.length == _titles.length 
    //             );

    //     for (uint i = 0; i < _tokenIds.length; i++){

    //         allTokensIndex[_tokenIds[i]] = allTokens.length;
    //         allTokens.push(_tokenIds[i]);

    //         tokenTitles[_tokenIds[i]] = _titles[i];

    //         addTokenTo(_owners[i],_tokenIds[i]);

    //         RecordKeeping.priceRecord memory prInitial = RecordKeeping.priceRecord(_initialPrices[i], _creators[i], _initialDates[i]);
    //         initialPriceRecords[_tokenIds[i]] = prInitial;      

    //         RecordKeeping.priceRecord memory prLast = RecordKeeping.priceRecord(_lastPrices[i], _owners[i], _lastDates[i]);
    //         lastPriceRecords[_tokenIds[i]] = prLast;  

               

    //     }
    // }
}


contract CappedToken is MintableToken {

  uint256 public cap;

  constructor(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address _to,
    uint256 _amount
  )
    public
    returns (bool)
  {
    require(totalSupply_.add(_amount) <= cap);

    return super.mint(_to, _amount);
  }

}

contract StemToken is CappedToken, StandardBurnableToken {
    string public name;
    string public symbol;
    uint8 public decimals;

    constructor(string memory _name, string memory _symbol, uint256 _cap) CappedToken(_cap)  public {
        name = _name;
        symbol = _symbol;
        decimals = 0;    
    }
}
contract RetroArtStemToken is StemToken {    

    address public retroArtAddress;

    constructor(string memory _name, string memory _symbol, uint256 _cap) StemToken(_name, _symbol, _cap )  public {
        
    }

  
    function setRetroArtAddress(address _retroArtAddress) public onlyOwner {        
        retroArtAddress = _retroArtAddress;
    }

    function sellback(uint256 _tokenId) public {
     
        RetroArt retroArt = RetroArt(retroArtAddress);
        require(retroArt.ownerOf(_tokenId) == msg.sender);
        retroArt.burnExchangeToken(msg.sender, _tokenId);
        totalSupply_ = totalSupply_.add(1);
        balances[msg.sender] = balances[msg.sender].add(1);
        emit Mint(msg.sender, 1);
        emit Transfer(address(0), msg.sender, 1);
    }

    //acquire a new asset using one stem token
    //usually _tokenOwner should just be the msg.sender, as the address who pay with the stem token
    //however it can be used to pay on behalf of someone else if _tokenOwner is a different address
    function acquireAssetForOther(uint256 _tokenId, string memory _title, address _tokenOwner) public {
        require(balanceOf(msg.sender) >= 1);           
        _burn(msg.sender, uint256(1));
        RetroArt retroArt = RetroArt(retroArtAddress);
        retroArt.acquireAssetFromStemToken(_tokenOwner, _tokenId, _title);
    }

    function acquireAsset(uint256 _tokenId, string memory _title) public {
        acquireAssetForOther(_tokenId, _title, msg.sender);
    }

}