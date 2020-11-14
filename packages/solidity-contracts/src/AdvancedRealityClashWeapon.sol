/**
 * Source Code first verified at https://etherscan.io on Monday, April 1, 2019
 (UTC) */

pragma solidity 0.5.1;

// RCC Tokenization Contract

/**
 * @title ERC20
 * @author Prashant Prabhakar Singh
 * @dev  https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 */
contract ERC20Interface {
  function transfer(address to, uint tokens) public returns (bool success);
  event Transfer(address indexed from, address indexed to, uint tokens);
}

/**
 * @title ERC165
 * @author Prashant Prabhakar Singh
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

/**
 * Utility library of inline functions on addresses
 */
library AddressUtils {

  /**
   * Returns whether the target address is a contract
   * @dev This function will return false if invoked during the constructor of a contract,
   * as the code is not actually created until after the constructor finishes.
   * @param addr address to check
   * @return whether the target address is a contract
   */
  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    // XXX Currently there is no better way to check if there is a contract in an address
    // than to check the size of the code at that address.
    // See https://ethereum.stackexchange.com/a/14016/36603
    // for more details about how this works.
    // TODO Check this again before the Serenity release, because all addresses will be
    // contracts then.
    // solium-disable-next-line security/no-inline-assembly
    assembly { size := extcodesize(addr) }
    return size > 0;
  }
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @title ERC721 token receiver interface
 * @author Prashant Prabhakar Singh
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
contract ERC721Receiver {
  /**
   * @dev Magic value to be returned upon successful reception of an NFT
   *  Equals to `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`,
   *  which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
   */
  bytes4 internal constant ERC721_RECEIVED = 0xf0b9e5ba;

  /**
   * @notice Handle the receipt of an NFT
   * @dev The ERC721 smart contract calls this function on the recipient
   * after a `safetransfer`. This function MAY throw to revert and reject the
   * transfer. This function MUST use 50,000 gas or less. Return of other
   * than the magic value MUST result in the transaction being reverted.
   * Note: the contract address is always the message sender.
   * @param _from The sending address
   * @param _tokenId The NFT identifier which is being transfered
   * @param _data Additional data with no specified format
   * @return `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`
   */
  function onERC721Received(
    address _from,
    uint256 _tokenId,
    bytes memory _data
  )
    public
    returns(bytes4);
}

/**
 * @title SupportsInterfaceWithLookup
 * @author Prashant Prabhakar Singh
 * @dev Implements ERC165 using a lookup table.
 */
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

/**
 * @title Pausable
 * @author Prashant Prabhakar Singh
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable {
  event Paused(address account);
  event Unpaused(address account);

  bool private _paused;
  address public pauser;

  constructor () internal {
    _paused = false;
    pauser = msg.sender;
  }

  /**
    * @return true if the contract is paused, false otherwise.
    */
  function paused() public view returns (bool) {
    return _paused;
  }

  /**
    * @dev Modifier to make a function callable only by pauser.
    */
  modifier onlyPauser() {
    require(msg.sender == pauser);
    _;
  }

  /**
    * @dev Modifier to make a function callable only when the contract is not paused.
    */
  modifier whenNotPaused() {
    require(!_paused);
    _;
  }


  /**
    * @dev called by the owner to pause, triggers stopped state
    */
  function pause() public onlyPauser {
    require(!_paused);
    _paused = true;
    emit Paused(msg.sender);
  }

  /**
    * @dev called by the owner to unpause, returns to normal state
    */
  function unpause() public onlyPauser {
    require(_paused);
    _paused = false;
    emit Unpaused(msg.sender);
  }
}

/**
 * @title ERC721 Non-Fungible Token Standard basic interface
 * @author Prashant Prabhakar Singh
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Basic is ERC165, Pausable {
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

/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @author Prashant Prabhakar Singh
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721BasicToken is SupportsInterfaceWithLookup, ERC721Basic {

  bytes4 private constant InterfaceId_ERC721 = 0x80ac58cd;
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

  bytes4 private constant InterfaceId_ERC721Exists = 0x4f558e79;
  /*
   * 0x4f558e79 ===
   *   bytes4(keccak256('exists(uint256)'))
   */

  using SafeMath for uint256;
  using AddressUtils for address;

  // Equals to `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`
  // which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
  bytes4 private constant ERC721_RECEIVED = 0xf0b9e5ba;

  // Mapping from token ID to owner
  mapping (uint256 => address) internal tokenOwner;

  // Mapping from token ID to approved address
  mapping (uint256 => address) internal tokenApprovals;

  // Mapping from owner to number of owned token
  mapping (address => uint256) internal ownedTokensCount;

  // Mapping from owner to operator approvals
  mapping (address => mapping (address => bool)) internal operatorApprovals;

  /**
   * @dev Guarantees msg.sender is owner of the given token
   * @param _tokenId uint256 ID of the token to validate its ownership belongs to msg.sender
   */
  modifier onlyOwnerOf(uint256 _tokenId) {
    require(ownerOf(_tokenId) == msg.sender);
    _;
  }

  /**
   * @dev Checks msg.sender can transfer a token, by being owner, approved, or operator
   * @param _tokenId uint256 ID of the token to validate
   */
  modifier canTransfer(uint256 _tokenId) {
    require(isApprovedOrOwner(msg.sender, _tokenId));
    _;
  }

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
  function approve(address _to, uint256 _tokenId) public whenNotPaused {
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
  function setApprovalForAll(address _to, bool _approved) public whenNotPaused {
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
    canTransfer(_tokenId)
    whenNotPaused
  {
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
   * `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`; otherwise,
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
    canTransfer(_tokenId)
    whenNotPaused
  {
    // solium-disable-next-line arg-overflow
    safeTransferFrom(_from, _to, _tokenId, "");
  }

  /**
   * @dev Safely transfers the ownership of a given token ID to another address
   * If the target address is a contract, it must implement `onERC721Received`,
   * which is called upon a safe transfer, and return the magic value
   * `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`; otherwise,
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
    canTransfer(_tokenId)
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
      emit Approval(_owner, address(0), _tokenId);
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
      _from, _tokenId, _data);
    return (retval == ERC721_RECEIVED);
  }
}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @author Prashant Prabhakar Singh
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
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
 * @title ERC-721 Non-Fungible Token Standard, optional metadata 
 * @author Prashant Prabhakar Singh
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Metadata is ERC721Basic {
  function name() external view returns (string memory _name);
  function symbol() external view returns (string memory _symbol);
  function tokenURI(uint256 _tokenId) public view returns (string memory);
}

/**
 * @title ERC-721 Non-Fungible Token Standard, full implementation interface
 * @author Prashant Prabhakar Singh
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {
}

/**
 * @title Full ERC721 Token
 * @author Prashant Prabhakar Singh
 * This implementation includes all the required and some optional functionality of the ERC721 standard
 * Moreover, it includes approve all functionality using operator terminology
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Token is SupportsInterfaceWithLookup, ERC721BasicToken, ERC721 {

  bytes4 private constant InterfaceId_ERC721Enumerable = 0x780e9d63;
  /**
   * 0x780e9d63 ===
   *   bytes4(keccak256('totalSupply()')) ^
   *   bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^
   *   bytes4(keccak256('tokenByIndex(uint256)'))
   */

  bytes4 private constant InterfaceId_ERC721Metadata = 0x5b5e139f;
  /**
   * 0x5b5e139f ===
   *   bytes4(keccak256('name()')) ^
   *   bytes4(keccak256('symbol()')) ^
   *   bytes4(keccak256('tokenURI(uint256)'))
   */

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

    uint256 tokenIndex = ownedTokensIndex[_tokenId];
    uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);
    uint256 lastToken = ownedTokens[_from][lastTokenIndex];

    ownedTokens[_from][tokenIndex] = lastToken;
    ownedTokens[_from][lastTokenIndex] = 0;
    // Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to
    // be zero. Then we can make sure that we will remove _tokenId from the ownedTokens list since we are first swapping
    // the lastToken to the first position, and then dropping the element placed in the last position of the list

    ownedTokens[_from].length--;
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

/**
 * @title Ownership
 * @author Prashant Prabhakar Singh
 * This contract has an owner address, and provides basic authorization control
 */
contract Ownership is Pausable {
  address public owner;
  event OwnershipUpdated(address oldOwner, address newOwner);

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function updateOwner(address _newOwner)
    public
    onlyOwner
    whenNotPaused
  {
    owner = _newOwner;
    emit OwnershipUpdated(msg.sender, owner);
  }
}

/**
 * @title Operators
 * @author Prashant Prabhakar Singh
 * This contract add functionlaity of adding operators that have higher authority than a normal user
 * @dev Operators can perform different actions based on their level.
 */
contract Operators is Ownership {
  // state variable
  address[] private operators;
  uint8 MAX_OP_LEVEL;
  mapping (address => uint8) operatorLevel; // mapping of address to level

  // events
  event OperatorAdded (address _operator, uint8 _level);
  event OperatorUpdated (address _operator, uint8 _level);
  event OperatorRemoved (address _operator);

  constructor()
    public
  {
    MAX_OP_LEVEL = 3;
  }

  modifier onlyLevel(uint8 level) {
    uint8 opLevel = getOperatorLevel(msg.sender);
    if (level > 0) {
      require( opLevel <= level && opLevel != 0);
      _;
    } else {
      _;
    }
  }

  modifier onlyValidLevel(uint8 _level){
    require(_level> 0 && _level <= MAX_OP_LEVEL);
    _;
  }

  function addOperator(address _newOperator, uint8 _level)
    public 
    onlyOwner
    whenNotPaused
    onlyValidLevel(_level)
    returns (bool)
  {
    require (operatorLevel[_newOperator] == 0); // use change level instead
    operatorLevel[_newOperator] = _level;
    operators.push(_newOperator);
    emit OperatorAdded(_newOperator, _level);
    return true;
  }

  function updateOperator(address _operator, uint8 _level)
    public
    onlyOwner
    whenNotPaused
    onlyValidLevel(_level)
    returns (bool)
  {
    require (operatorLevel[_operator] != 0); // use add Operator
    operatorLevel[_operator] = _level;
    emit OperatorUpdated(_operator, _level);
    return true;
  }

  function removeOperatorByIndex(uint index)
    public
    onlyOwner
    whenNotPaused
    returns (bool)
  {
    index = index - 1;
    operatorLevel[operators[index]] = 0;
    operators[index] = operators[operators.length - 1];
    operators.length -- ;
    return true;

  }

  
    /**
   * @dev Use removeOperatorByIndex instead to save gas
   * warning: not advised to use this function.
   */
  function removeOperator(address _operator)
    public
    onlyOwner
    whenNotPaused
    returns (bool)
  {
    uint index = getOperatorIndex(_operator);
    require(index > 0);
    return removeOperatorByIndex(index);
  }

  function getOperatorIndex(address _operator)
    public
    view
    returns (uint)
  {
    for (uint i=0; i<operators.length; i++) {
      if (operators[i] == _operator) return i+1;
    }
    return 0;
  }

  function getOperators()
    public
    view
    returns (address[] memory)
  {
    return operators;
  }

  function getOperatorLevel(address _operator)
    public
    view
    returns (uint8)
  {
    return operatorLevel[_operator];
  }

}

/**
 * @title RealityClashWeapon
 * @author Prashant Prabhakar Singh
 * This contract implements Reality Clash Weapons NFTs.
 */
contract RealityClashWeapon is ERC721Token, Operators {

  // mappings to store RealityClash Weapon Data
  mapping (uint => string) gameDataOf;
  mapping (uint => string) weaponDataOf;
  mapping (uint => string) ownerDataOf;

 
  event WeaponAdded(uint indexed weaponId, string gameData, string weaponData, string ownerData, string tokenURI);
  event WeaponUpdated(uint indexed weaponId, string gameData, string weaponData, string ownerData, string tokenURI);
  event WeaponOwnerUpdated (uint indexed  _weaponId, address indexed  _oldOwner, address indexed  _newOwner);

  constructor() public  ERC721Token('Reality Clash Weapon', 'RC GUN'){
  }

  /**
   * @dev Mints new tokens wih jsons on blockchain
   * Reverts if the sender is not operator with level 1
   * @param _id Id of weapon to be minted
   * @param _gameData represent game data of the weapon
   * @param _weaponData represents weapon data of the weapon
   * @param _ownerData represents owner data of the weapon
   */
  function mint(uint256 _id, string memory _gameData, string memory _weaponData, string memory _ownerData, address _to)
    public
    onlyLevel(1)
    whenNotPaused
  {
    super._mint(_to, _id);
    gameDataOf[_id] = _gameData;
    weaponDataOf[_id] = _weaponData;
    ownerDataOf[_id] = _ownerData;
    emit WeaponAdded(_id, _gameData, _weaponData, _ownerData, '');
  }

  /**
   * @dev Mints new tokens with tokenURI
   * Reverts if the sender is not operator with level 1
   * @param _id Id of weapon to be minted
   * @param _to represent address to which unique token is minted
   * @param _uri represents string URI to assign
   */
  function mintWithURI(uint256 _id, address _to, string memory _uri)
    public
    onlyLevel(1)
    whenNotPaused
  {
    super._mint(_to, _id);
    super._setTokenURI(_id, _uri);
    emit WeaponAdded(_id, '', '', '', _uri);
  }


  /**
   * @dev Transfer tokens (similar to ERC-20 transfer)
   * Reverts if the sender is not owner of the weapon or approved
   * @param _to address to which token is transferred
   * @param _tokenId Id of weapon being transferred
   */
  function transfer(address _to, uint256 _tokenId)
    public
    whenNotPaused
  {
    safeTransferFrom(msg.sender, _to, _tokenId);
  }

  /**
   * @dev Updates metaData of already minted tokens
   * Reverts if the sender is not operator with level 2 or above
   * @param _id Id of weapon whose data needs to be updated
   * @param _gameData represent game data of the weapon
   * @param _weaponData represents weapon data of the weapon
   * @param _ownerData represents owner data of the weapon
   */
  function updateMetaData(uint _id, string memory _gameData, string memory _weaponData, string memory _ownerData)
    public 
    onlyLevel(2)
    whenNotPaused
  {
    gameDataOf[_id] = _gameData;
    weaponDataOf[_id] = _weaponData;
    ownerDataOf[_id] = _ownerData;
  }

  /**
   * @dev Burn an existing weapon
   * @param _id Id of weapon to be burned
   */
  function burn(uint _id)
    public
    whenNotPaused
  {
   super._burn(msg.sender, _id);
  }


  /**
   * @dev Update game proprietary data
   * @param _id Id of weapon whose data needs to be updated
   * @param _gameData is new game data for weapon
   */
  function updateGameData (uint _id, string memory _gameData)
    public
    onlyLevel(2)
    whenNotPaused
    returns(bool)
  {
    gameDataOf[_id] = _gameData;
    emit WeaponUpdated(_id, _gameData, "", "", "");
    return true;
  }

  /**
   * @dev Update weapon sepcific data of weapon
   * @param _id Id of weapon whose data needs to be updated
   * @param _weaponData is new public data for weapon
   */
  function updateWeaponData (uint _id,  string memory _weaponData)
    public 
    onlyLevel(2)
    whenNotPaused
    returns(bool) 
  {
    weaponDataOf[_id] = _weaponData;
    emit WeaponUpdated(_id, "", _weaponData, "", "");
    return true;
  }

  /**
   * @dev Update owner proprietary data
   * @param _id Id of weapon whose data needs to be updated
   * @param _ownerData is new owner data for weapon
   */
  function updateOwnerData (uint _id, string memory _ownerData)
    public
    onlyLevel(2)
    whenNotPaused
    returns(bool)
  {
    ownerDataOf[_id] = _ownerData;
    emit WeaponUpdated(_id, "", "", _ownerData, "");
    return true;
  }

  /**
   * @dev Update token URI of weapon
   * @param _id Id of weapon whose data needs to be updated
   * @param _uri Url of weapon details
   */
  function updateURI (uint _id, string memory _uri)
    public
    onlyLevel(2)
    whenNotPaused
    returns(bool)
  {
    super._setTokenURI(_id, _uri);
    emit WeaponUpdated(_id, "", "", "", _uri);
    return true;
  }

  //////////////////////////////////////////
  // PUBLICLY ACCESSIBLE METHODS (CONSTANT)
  //////////////////////////////////////////

  /**
  * @return game data of weapon.
  */
  function getGameData (uint _id) public view returns(string memory _gameData) {
    return gameDataOf[_id];
  }

  /**
  * @return weapon data of weapon.
  */
  function getWeaponData (uint _id) public view returns(string memory _pubicData) {
    return weaponDataOf[_id];
  }

  /**
  * @return owner data of weapon.
  */
  function getOwnerData (uint _id) public view returns(string memory _ownerData) {
    return ownerDataOf[_id] ;
  }

  /**
  * @return all metaData data of weapon including game data, weapon data, owner data.
  */
  function getMetaData (uint _id) public view returns(string memory _gameData,string memory _pubicData,string memory _ownerData ) {
    return (gameDataOf[_id], weaponDataOf[_id], ownerDataOf[_id]);
  }
}


/**
 * @title AdvancedRealityClashWeapon
 * @author Prashant Prabhakar Singh
 * This contract implements submitting a pre signed tx
 * @dev Method allowed is setApproval and transfer
 */
contract AdvancedRealityClashWeapon is RealityClashWeapon {

  // mapping for replay protection
  mapping(address => uint) private userNonce;

  bool public isNormalUserAllowed; // can normal user access advanced features
  
  constructor() public {
    isNormalUserAllowed = false;
  }

  /**
   * @dev Allows normal users to call proval fns
   * Reverts if the sender is not owner of contract
   * @param _perm permission to users
   */
  function allowNormalUser(bool _perm)
    public 
    onlyOwner
    whenNotPaused
  {
    isNormalUserAllowed = _perm;
  }

  /**
   * @dev Allows submitting already signed transaction
   * Reverts if the signed data is incorrect
   * @param message signed message by user
   * @param r signature
   * @param s signature
   * @param v recovery id of signature
   * @param spender address which is approved
   * @param approved bool value for status of approval
   * message should be hash(functionWord, contractAddress, nonce, fnParams)
   */
  function provable_setApprovalForAll(bytes32 message, bytes32 r, bytes32 s, uint8 v, address spender, bool approved)
    public
    whenNotPaused
  {
    if (!isNormalUserAllowed) {
      uint8 opLevel = getOperatorLevel(msg.sender);
      require (opLevel != 0 && opLevel < 3); // level 3 operators are allowed to submit proof
    }
    address signer = getSigner(message, r, s, v);
    require (signer != address(0));

    bytes32 proof = getMessageSendApprovalForAll(signer, spender, approved);
    require( proof == message);

    // perform the original set Approval
    operatorApprovals[signer][spender] = approved;
    emit ApprovalForAll(signer, spender, approved);
    userNonce[signer] = userNonce[signer].add(1);
  }

  /**
   * @dev Allows submitting already signed transaction for weapon transfer
   * Reverts if the signed data is incorrect
   * @param message signed message by user
   * @param r signature
   * @param s signature
   * @param v recovery id of signature
   * @param to recipient address
   * @param tokenId ID of RC Weapon
   * message should be hash(functionWord, contractAddress, nonce, fnParams)
   */
  function provable_transfer(bytes32 message, bytes32 r, bytes32 s, uint8 v, address to, uint tokenId)
    public 
    whenNotPaused
  {
    if (!isNormalUserAllowed) {
      uint8 opLevel = getOperatorLevel(msg.sender);
      require (opLevel != 0 && opLevel < 3); // level 3 operators are allowed to submit proof
    }
    address signer = getSigner(message, r, s, v);
    require (signer != address(0));

    bytes32 proof = getMessageTransfer(signer, to, tokenId);
    require (proof == message);
    
    // Execute original function
    require(to != address(0));
    clearApproval(signer, tokenId);
    removeTokenFrom(signer, tokenId);
    addTokenTo(to, tokenId);
    emit Transfer(signer, to, tokenId);

    // update state variables
    userNonce[signer] = userNonce[signer].add(1);
  }

  /**
   * @dev Check signer of a message
   * @param message signed message by user
   * @param r signature
   * @param s signature
   * @param v recovery id of signature
   * @return signer of message
   */
  function getSigner(bytes32 message, bytes32 r, bytes32 s,  uint8 v) public pure returns (address){
    bytes memory prefix = "\x19Ethereum Signed Message:\n32";
    bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, message));
    address signer = ecrecover(prefixedHash,v,r,s);
    return signer;
  }

  /**
   * @dev Get message to be signed for transfer
   * @param signer of message
   * @param to recipient address
   * @param id weapon id
   * @return hash of (functionWord, contractAddress, nonce, ...fnParams)
   */
  function getMessageTransfer(address signer, address to, uint id)
    public
    view
    returns (bytes32) 
  {
    return keccak256(abi.encodePacked(
      bytes4(0xb483afd3),
      address(this),
      userNonce[signer],
      to,
      id
    ));
  }

  /**
   * @dev Get message to be signed for set Approval
   * @param signer of message
   * @param spender address which is approved
   * @param approved bool value for status of approval
   * @return hash of (functionWord, contractAddress, nonce, ...fnParams)
   */
  function getMessageSendApprovalForAll(address signer, address spender, bool approved)
    public 
    view 
    returns (bytes32)
  {
    bytes32 proof = keccak256(abi.encodePacked(
      bytes4(0xbad4c8ea),
      address(this),
      userNonce[signer],
      spender,
      approved
    ));
    return proof;
  }

  /**
  * returns nonce of user to be used for next signing
  */
  function getUserNonce(address user) public view returns (uint) {
    return userNonce[user];
  }

  /**
   * @dev Owner can transfer out any accidentally sent ERC20 tokens
   * @param contractAddress ERC20 contract address
   * @param to withdrawal address
   * @param value no of tokens to be withdrawan
   */
  function transferAnyERC20Token(address contractAddress, address to,  uint value) public onlyOwner {
    ERC20Interface(contractAddress).transfer(to, value);
  }

  /**
   * @dev Owner can transfer out any accidentally sent ERC721 tokens
   * @param contractAddress ERC721 contract address
   * @param to withdrawal address
   * @param tokenId Id of 721 token
   */
  function withdrawAnyERC721Token(address contractAddress, address to, uint tokenId) public onlyOwner {
    ERC721Basic(contractAddress).safeTransferFrom(address(this), to, tokenId);
  }

  /**
   * @dev Owner kill the smart contract
   * @param message Confirmation message to prevent accidebtal calling
   * @notice BE VERY CAREFULL BEFORE CALLING THIS FUNCTION
   * Better pause the contract
   * DO CALL "transferAnyERC20Token" before TO WITHDRAW ANY ERC-2O's FROM CONTRACT
   */
  function kill(uint message) public onlyOwner {
    require (message == 123456789987654321);
    // Transfer Eth to owner and terminate contract
    selfdestruct(msg.sender);
  }

}