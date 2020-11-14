/**
 * Source Code first verified at https://etherscan.io on Thursday, March 28, 2019
 (UTC) */

// File: contracts\math\SafeMath.sol

pragma solidity 0.5.7;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
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

// File: contracts\RedTokenAccessControl.sol

pragma solidity 0.5.7;

/*
 * @title RedTokenAccessControl
 * @notice This contract defines organizational roles and permissions.
 */
contract RedTokenAccessControl {

  event Paused();
  event Unpaused();
  event PausedUser(address indexed account);
  event UnpausedUser(address indexed account);

  /*
   * @notice CEO's address
   */
  address public ceoAddress;

  /*
   * @notice CFO's address
   */
  address public cfoAddress;

  /*
   * @notice COO's address
   */
  address public cooAddress;

  bool public paused = false;

  /*
   * @notice paused users status
   */
  mapping (address => bool) private pausedUsers;

  /*
   * @notice init constructor
   */
  constructor () internal {
      ceoAddress = msg.sender;
      cfoAddress = msg.sender;
      cooAddress = msg.sender;
  }

  /*
   * @dev Modifier to make a function only callable by the CEO
   */
  modifier onlyCEO() {
    require(msg.sender == ceoAddress);
    _;
  }

  /*
   * @dev Modifier to make a function only callable by the CFO
   */
  modifier onlyCFO() {
    require(msg.sender == cfoAddress);
    _;
  }

  /*
   * @dev Modifier to make a function only callable by the COO
   */
  modifier onlyCOO() {
    require(msg.sender == cooAddress);
    _;
  }

  /*
   * @dev Modifier to make a function only callable by C-level execs
   */
  modifier onlyCLevel() {
    require(
      msg.sender == cooAddress ||
      msg.sender == ceoAddress ||
      msg.sender == cfoAddress
    );
    _;
  }

  /*
   * @dev Modifier to make a function only callable by CEO or CFO
   */
  modifier onlyCEOOrCFO() {
    require(
      msg.sender == cfoAddress ||
      msg.sender == ceoAddress
    );
    _;
  }

  /*
   * @dev Modifier to make a function only callable by CEO or COO
   */
  modifier onlyCEOOrCOO() {
    require(
      msg.sender == cooAddress ||
      msg.sender == ceoAddress
    );
    _;
  }

  /*
   * @notice Sets a new CEO
   * @param _newCEO - the address of the new CEO
   */
  function setCEO(address _newCEO) external onlyCEO {
    require(_newCEO != address(0));
    ceoAddress = _newCEO;
  }

  /*
   * @notice Sets a new CFO
   * @param _newCFO - the address of the new CFO
   */
  function setCFO(address _newCFO) external onlyCEO {
    require(_newCFO != address(0));
    cfoAddress = _newCFO;
  }

  /*
   * @notice Sets a new COO
   * @param _newCOO - the address of the new COO
   */
  function setCOO(address _newCOO) external onlyCEO {
    require(_newCOO != address(0));
    cooAddress = _newCOO;
  }

  /* Pausable functionality adapted from OpenZeppelin **/
  /*
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /*
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /*
   * @notice called by any C-LEVEL to pause, triggers stopped state
   */
  function pause() external onlyCLevel whenNotPaused {
    paused = true;
    emit Paused();
  }

  /*
   * @notice called by any C-LEVEL to unpause, returns to normal state
   */
  function unpause() external onlyCLevel whenPaused {
    paused = false;
    emit Unpaused();
  }

  /* user Pausable functionality ref someting : openzeppelin/access/Roles.sol **/
  /*
   * @dev Modifier to make a function callable only when the user is not paused.
   */
  modifier whenNotPausedUser(address account) {
    require(account != address(0));
    require(!pausedUsers[account]);
    _;
  }

  /*
   * @dev Modifier to make a function callable only when the user is paused.
   */
  modifier whenPausedUser(address account) {
    require(account != address(0));
    require(pausedUsers[account]);
    _;
  }

  /*
    * @dev check if an account has this pausedUsers
    * @return bool
    */
  function has(address account) internal view returns (bool) {
      require(account != address(0));
      return pausedUsers[account];
  }
  
  /*
   * @notice _addPauseUser
   */
  function _addPauseUser(address account) internal {
      require(account != address(0));
      require(!has(account));

      pausedUsers[account] = true;

      emit PausedUser(account);
  }

  /*
   * @notice _unpausedUser
   */
  function _unpausedUser(address account) internal {
      require(account != address(0));
      require(has(account));

      pausedUsers[account] = false;
      emit UnpausedUser(account);
  }

  /*
   * @notice isPausedUser
   */
  function isPausedUser(address account) external view returns (bool) {
      return has(account);
  }

  /*
   * @notice called by the COO to pauseUser, triggers stopped user state
   */
  function pauseUser(address account) external onlyCOO whenNotPausedUser(account) {
    _addPauseUser(account);
  }

  /*
   * @notice called by any C-LEVEL to unpauseUser, returns to user state
   */
  function unpauseUser(address account) external onlyCLevel whenPausedUser(account) {
    _unpausedUser(account);
  }
}

// File: contracts\RedTokenBase.sol

pragma solidity 0.5.7;



/*
 * @title RedTokenBase
 * @notice This contract defines the RedToken data structure and how to read from it / functions
 */
contract RedTokenBase is RedTokenAccessControl {
  using SafeMath for uint256;

  /*
   * @notice Product defines a RedToken
   */ 
  struct RedToken {
    uint256 tokenId;
    string rmsBondNo;
    uint256 bondAmount;
    uint256 listingAmount;
    uint256 collectedAmount;
    uint createdTime;
    bool isValid;
  }

  /*
   * @notice tokenId for share users by listingAmount
   */
  mapping (uint256 => mapping(address => uint256)) shareUsers;

  /*
   * @notice tokenid by share accounts in shareUsers list iterator.
   */
  mapping (uint256 => address []) shareUsersKeys;

  /** events **/
  event RedTokenCreated(
    address account, 
    uint256 tokenId, 
    string rmsBondNo, 
    uint256 bondAmount, 
    uint256 listingAmount, 
    uint256 collectedAmount, 
    uint createdTime
  );
  
  /*
   * @notice All redTokens in existence.
   * @dev The ID of each redToken is an index in this array.
   */
  RedToken[] redTokens;
  
  /*
   * @notice Get a redToken RmsBondNo
   * @param _tokenId the token id
   */
  function redTokenRmsBondNo(uint256 _tokenId) external view returns (string memory) {
    return redTokens[_tokenId].rmsBondNo;
  }

  /*
   * @notice Get a redToken BondAmount
   * @param _tokenId the token id
   */
  function redTokenBondAmount(uint256 _tokenId) external view returns (uint256) {
    return redTokens[_tokenId].bondAmount;
  }

  /*
   * @notice Get a redToken ListingAmount
   * @param _tokenId the token id
   */
  function redTokenListingAmount(uint256 _tokenId) external view returns (uint256) {
    return redTokens[_tokenId].listingAmount;
  }
  
  /*
   * @notice Get a redToken CollectedAmount
   * @param _tokenId the token id
   */
  function redTokenCollectedAmount(uint256 _tokenId) external view returns (uint256) {
    return redTokens[_tokenId].collectedAmount;
  }

  /*
   * @notice Get a redToken CreatedTime
   * @param _tokenId the token id
   */
  function redTokenCreatedTime(uint256 _tokenId) external view returns (uint) {
    return redTokens[_tokenId].createdTime;
  }

  /*
   * @notice isValid a redToken
   * @param _tokenId the token id
   */
  function isValidRedToken(uint256 _tokenId) public view returns (bool) {
    return redTokens[_tokenId].isValid;
  }

  /*
   * @notice info a redToken
   * @param _tokenId the token id
   */
  function redTokenInfo(uint256 _tokenId)
    external view returns (uint256, string memory, uint256, uint256, uint256, uint)
  {
    require(isValidRedToken(_tokenId));
    RedToken memory _redToken = redTokens[_tokenId];

    return (
        _redToken.tokenId,
        _redToken.rmsBondNo,
        _redToken.bondAmount,
        _redToken.listingAmount,
        _redToken.collectedAmount,
        _redToken.createdTime
    );
  }
  
  /*
   * @notice info a token of share users
   * @param _tokenId the token id
   */
  function redTokenInfoOfshareUsers(uint256 _tokenId) external view returns (address[] memory, uint256[] memory) {
    require(isValidRedToken(_tokenId));

    uint256 keySize = shareUsersKeys[_tokenId].length;

    address[] memory addrs   = new address[](keySize);
    uint256[] memory amounts = new uint256[](keySize);

    for (uint index = 0; index < keySize; index++) {
      addrs[index]   = shareUsersKeys[_tokenId][index];
      amounts[index] = shareUsers[_tokenId][addrs[index]];
    }
    
    return (addrs, amounts);
  }
}

// File: contracts\interfaces\ERC721.sol

pragma solidity 0.5.7;

/// @title ERC-721 Non-Fungible Token Standard
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
///  Note: the ERC-165 identifier for this interface is 0x80ac58cd.
interface ERC721 {
    /// @dev This emits when ownership of any NFT changes by any mechanism.
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address _owner) external view returns (uint256);

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) external view returns (address);

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) external payable;

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external;

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) external view returns (address);

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

// File: contracts\interfaces\ERC721Metadata.sol

pragma solidity 0.5.7;

/*
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 *  Note: the ERC-165 identifier for this interface is 0x5b5e139f
 */
interface ERC721Metadata /* is ERC721 */ {
    
    /*
     * @notice A descriptive name for a collection of NFTs in this contract
     */
    function name() external pure returns (string memory _name);

    /*
     * @notice An abbreviated name for NFTs in this contract
     */ 
    function symbol() external pure returns (string memory _symbol);

    /*
     * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
     * @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
     *  3986. The URI may point to a JSON file that conforms to the "ERC721
     *  Metadata JSON Schema".
     */
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}

// File: contracts\interfaces\ERC721Enumerable.sol

pragma solidity 0.5.7;

/*
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 *  Note: the ERC-165 identifier for this interface is 0x780e9d63
 */
interface ERC721Enumerable /* is ERC721 */ {
    /*
     * @notice Count NFTs tracked by this contract
     * @return A count of valid NFTs tracked by this contract, where each one of
     *  them has an assigned and queryable owner not equal to the zero address
     */
    function totalSupply() external view returns (uint256);

    /*
     * @notice Enumerate valid NFTs
     * @dev Throws if `_index` >= `totalSupply()`.
     * @param _index A counter less than `totalSupply()`
     * @return The token identifier for the `_index`th NFT,
     *  (sort order not specified)
     */
    function tokenByIndex(uint256 _index) external view returns (uint256);

    /*
     * @notice Enumerate NFTs assigned to an owner
     * @dev Throws if `_index` >= `balanceOf(_owner)` or if
     *  `_owner` is the zero address, representing invalid NFTs.
     * @param _owner An address where we are interested in NFTs owned by them
     * @param _index A counter less than `balanceOf(_owner)`
     * @return The token identifier for the `_index`th NFT assigned to `_owner`,
     *   (sort order not specified)
     */
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 _tokenId);
}

// File: contracts\interfaces\ERC165.sol

pragma solidity 0.5.7;

interface ERC165 {
    /*
     * @notice Query if a contract implements an interface
     * @param interfaceID The interface identifier, as specified in ERC-165
     * @dev Interface identification is specified in ERC-165. This function
     *  uses less than 30,000 gas.
     * @return `true` if the contract implements `interfaceID` and
     *  `interfaceID` is not 0xffffffff, `false` otherwise
     */
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

// File: contracts\strings\Strings.sol

pragma solidity 0.5.7;

library Strings {
  // via https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.5.sol
  function strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e) internal pure returns (string memory) {
    bytes memory _ba = bytes(_a);
    bytes memory _bb = bytes(_b);
    bytes memory _bc = bytes(_c);
    bytes memory _bd = bytes(_d);
    bytes memory _be = bytes(_e);
    string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
    bytes memory babcde = bytes(abcde);
    uint k = 0;
    for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
    for (uint i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
    for (uint i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
    for (uint i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
    for (uint i = 0; i < _be.length; i++) babcde[k++] = _be[i];
    return string(babcde);
  }

  function strConcat(string memory _a, string memory _b, string memory _c, string memory _d) internal pure returns (string memory) {
    return strConcat(_a, _b, _c, _d, "");
  }

  function strConcat(string memory _a, string memory _b, string memory _c) internal pure returns (string memory) {
    return strConcat(_a, _b, _c, "", "");
  }

  function strConcat(string memory _a, string memory _b) internal pure returns (string memory) {
    return strConcat(_a, _b, "", "", "");
  }

  function uint2str(uint i) internal pure returns (string memory) {
    if (i == 0) return "0";
    uint j = i;
    uint len;
    while (j != 0){
        len++;
        j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint k = len - 1;
    while (i != 0){
        bstr[k--] = byte(uint8(48 + i % 10));
        i /= 10;
    }
    return string(bstr);
  }
}

// File: contracts\interfaces\ERC721TokenReceiver.sol

pragma solidity 0.5.7;

/*
 * @dev Note: the ERC-165 identifier for this interface is 0xf0b9e5ba
 */
interface ERC721TokenReceiver {
    /*
     * @notice Handle the receipt of an NFT
     * @dev The ERC721 smart contract calls this function on the recipient
     *  after a `transfer`. This function MAY throw to revert and reject the
     *  transfer. This function MUST use 50,000 gas or less. Return of other
     *  than the magic value MUST result in the transaction being reverted.
     *  Note: the contract address is always the message sender.
     * @param _from The sending address
     * @param _tokenId The NFT identifier which is being transfered
     * @param _data Additional data with no specified format
     * @return `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`
     *  unless throwing
     */
	function onERC721Received(address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4);
}

// File: contracts\RedTokenOwnership.sol

pragma solidity 0.5.7;








/*
 * @title RedTokenOwnership
 * @notice control by TokenBase.
 */
contract RedTokenOwnership is RedTokenBase, ERC721, ERC165, ERC721Metadata, ERC721Enumerable {
  using SafeMath for uint256;

  // Total amount of tokens
  uint256 private totalTokens;

  // Mapping from token ID to owner
  mapping (uint256 => address) private tokenOwner;

  // Mapping from owner to list of owned token IDs
  mapping (address => uint256[]) internal ownedTokens;

  // Mapping from token ID to index of the owner tokens list
  mapping (uint256 => uint256) internal ownedTokensIndex;

  // Mapping from token ID to approved address
  mapping (uint256 => address) internal tokenApprovals;

  // Mapping from owner address to operator address to approval
  mapping (address => mapping (address => bool)) internal operatorApprovals;

  /** events **/
  event calculateShareUsers(uint256 tokenId, address owner, address from, address to, uint256 amount);
  event CollectedAmountUpdate(uint256 tokenId, address owner, uint256 amount);

  /** Constants **/
  // Configure these for your own deployment
  string internal constant NAME = "RedToken";
  string internal constant SYMBOL = "REDT";
  string internal tokenMetadataBaseURI = "https://doc.reditus.co.kr/?docid=";

  /** structs **/
  function supportsInterface(
    bytes4 interfaceID) // solium-disable-line dotta/underscore-function-arguments
    external view returns (bool)
  {
    return
      interfaceID == this.supportsInterface.selector || // ERC165
      interfaceID == 0x5b5e139f || // ERC721Metadata
      interfaceID == 0x80ac58cd || // ERC-721
      interfaceID == 0x780e9d63; // ERC721Enumerable
  }

  /*
   * @notice Guarantees msg.sender is owner of the given token
   * @param _tokenId uint256 ID of the token to validate its ownership belongs to msg.sender
   */
  modifier onlyOwnerOf(uint256 _tokenId) {
    require(ownerOf(_tokenId) == msg.sender);
    _;
  }

  /** external functions **/  
  /*
   * @notice token's name
   */
  function name() external pure returns (string memory) {
    return NAME;
  }

  /*
   * @notice symbols's name
   */
  function symbol() external pure returns (string memory) {
    return SYMBOL;
  }

  /*
   * @notice tokenURI
   * @dev do not checked in array and used function isValidRedToken value is not important, only check in redTokens array
   */
  function tokenURI(uint256 _tokenId)
    external
    view
    returns (string memory infoUrl)
  {
    if ( isValidRedToken(_tokenId) ){
      return Strings.strConcat( tokenMetadataBaseURI, Strings.uint2str(_tokenId));
    }else{
      return Strings.strConcat( tokenMetadataBaseURI, Strings.uint2str(_tokenId));
    }
  }

  /*
   * @notice setTokenMetadataBaseURI
   */
  function setTokenMetadataBaseURI(string calldata _newBaseURI) external onlyCOO {
    tokenMetadataBaseURI = _newBaseURI;
  }

  /*
   * @notice Gets the total amount of tokens stored by the contract
   * @return uint256 representing the total amount of tokens
   */
  function totalSupply() external view returns (uint256) {
    return totalTokens;
  }

  /*
   * @dev Gets the owner of the specified token ID
   * @param _tokenId uint256 ID of the token to query the owner of
   * @return owner address currently marked as the owner of the given token ID
   */
  function ownerOf(uint256 _tokenId) public view returns (address) {
    address owner = tokenOwner[_tokenId];
    require(owner != address(0));
    return owner;
  }

  /*
   * @notice Gets the balance of the specified address
   * @param _owner address to query the balance of
   * @return uint256 representing the amount owned by the passed address
   */
  function balanceOf(address _owner) public view returns (uint256) {
    require(_owner != address(0));
    return ownedTokens[_owner].length;
  }

  /*
   * @notice Gets the list of tokens owned by a given address
   * @param _owner address to query the tokens of
   * @return uint256[] representing the list of tokens owned by the passed address
   */
  function tokensOf(address _owner) external view returns (uint256[] memory) {
    require(_owner != address(0));
    return ownedTokens[_owner];
  }

  /*
  * @notice Enumerate valid NFTs
  * @dev Our Licenses are kept in an array and each new License-token is just
  * the next element in the array. This method is required for ERC721Enumerable
  * which may support more complicated storage schemes. However, in our case the
  * _index is the tokenId
  * @param _index A counter less than `totalSupply()`
  * @return The token identifier for the `_index`th NFT
  */
  function tokenByIndex(uint256 _index) external view returns (uint256) {
    require(_index < totalTokens);
    return _index;
  }

  /*
   * @notice Enumerate NFTs assigned to an owner
   * @dev Throws if `_index` >= `balanceOf(_owner)` or if
   *  `_owner` is the zero address, representing invalid NFTs.
   * @param _owner An address where we are interested in NFTs owned by them
   * @param _index A counter less than `balanceOf(_owner)`
   * @return The token identifier for the `_index`th NFT assigned to `_owner`,
   */
  function tokenOfOwnerByIndex(address _owner, uint256 _index)
    external
    view
    returns (uint256 _tokenId)
  {
    require(_index < balanceOf(_owner));
    return ownedTokens[_owner][_index];
  }

  /*
   * @notice Gets the approved address to take ownership of a given token ID
   * @param _tokenId uint256 ID of the token to query the approval of
   * @return address currently approved to take ownership of the given token ID
   */
  function getApproved(uint256 _tokenId) public view returns (address) {
    return tokenApprovals[_tokenId];
  }

  /*
   * @notice Tells whether an operator is approved by a given owner
   * @param _owner owner address which you want to query the approval of
   * @param _operator operator address which you want to query the approval of
   * @return bool whether the given operator is approved by the given owner
   */
  function isApprovedForAll(address _owner, address _operator) public view returns (bool)
  {
    return operatorApprovals[_owner][_operator];
  }

  /*
   * @notice Approves another address to claim for the ownership of the given token ID
   * @param _to address to be approved for the given token ID
   * @param _tokenId uint256 ID of the token to be approved
   */
  function approve(address _to, uint256 _tokenId)
    external
    payable
    whenNotPaused
    whenNotPausedUser(msg.sender)
    onlyOwnerOf(_tokenId)
  {
    require(_to != ownerOf(_tokenId));
    if (getApproved(_tokenId) != address(0) || _to != address(0)) {
      tokenApprovals[_tokenId] = _to;

      emit Approval(ownerOf(_tokenId), _to, _tokenId);
    }
  }

  /*
   * @notice Enable or disable approval for a third party ("operator") to manage all your assets
   * @dev Emits the ApprovalForAll event
   * @param _to Address to add to the set of authorized operators.
   * @param _approved True if the operators is approved, false to revoke approval
   */
  function setApprovalForAll(address _to, bool _approved)
    external
    whenNotPaused
    whenNotPausedUser(msg.sender)
  {
    if(_approved) {
      approveAll(_to);
    } else {
      disapproveAll(_to);
    }
  }

  /*
   * @notice Approves another address to claim for the ownership of any tokens owned by this account
   * @param _to address to be approved for the given token ID
   */
  function approveAll(address _to)
    internal
    whenNotPaused
    whenNotPausedUser(msg.sender)
  {
    require(_to != msg.sender);
    require(_to != address(0));
    operatorApprovals[msg.sender][_to] = true;

    emit ApprovalForAll(msg.sender, _to, true);
  }

  /*
   * @notice Removes approval for another address to claim for the ownership of any
   *  tokens owned by this account.
   * @dev Note that this only removes the operator approval and
   *  does not clear any independent, specific approvals of token transfers to this address
   * @param _to address to be disapproved for the given token ID
   */
  function disapproveAll(address _to)
    internal
    whenNotPaused
    whenNotPausedUser(msg.sender)
  {
    require(_to != msg.sender);
    delete operatorApprovals[msg.sender][_to];
    
    emit ApprovalForAll(msg.sender, _to, false);
  }

  /*
   * @notice Tells whether the msg.sender is approved to transfer the given token ID or not
   * Checks both for specific approval and operator approval
   * @param _tokenId uint256 ID of the token to query the approval of
   * @return bool whether transfer by msg.sender is approved for the given token ID or not
   */
  function isSenderApprovedFor(uint256 _tokenId) public view returns (bool) {
    return
      ownerOf(_tokenId) == msg.sender ||
      getApproved(_tokenId) == msg.sender ||
      isApprovedForAll(ownerOf(_tokenId), msg.sender);
  }
  
  /*
   * @notice Transfers the ownership of a given token ID to another address
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
   */
  function transfer(address _to, uint256 _tokenId)
    external
    payable
    whenNotPaused
    whenNotPausedUser(msg.sender)
    onlyOwnerOf(_tokenId)
  {
    _clearApprovalAndTransfer(msg.sender, _to, _tokenId);
  }

  /*
   * @notice Transfer a token owned by another address, for which the calling address has
   *  previously been granted transfer approval by the owner.
   * @param _from The address that owns the token
   * @param _to The address that will take ownership of the token. Can be any address, including the caller
   * @param _tokenId The ID of the token to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external
    payable
    whenNotPaused
    whenNotPausedUser(msg.sender)
  {
    require(isSenderApprovedFor(_tokenId));
    _clearApprovalAndTransfer(_from, _to, _tokenId);
  }
  
  /*
   * @notice Transfers the ownership of an NFT from one address to another address
   * @dev This works identically to the other function with an extra data parameter,
   *  except this function just sets data to ""
   * @param _from The current owner of the NFT
   * @param _to The new owner
   * @param _tokenId The NFT to transfer
  */
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external
    payable
    whenNotPaused
    whenNotPausedUser(msg.sender)
  {
    require(isSenderApprovedFor(_tokenId));
    _safeTransferFrom(_from, _to, _tokenId, "");
  }

  /*
   * @notice Transfers the ownership of an NFT from one address to another address
   * @dev Throws unless `msg.sender` is the current owner, an authorized
   * operator, or the approved address for this NFT. Throws if `_from` is
   * not the current owner. Throws if `_to` is the zero address. Throws if
   * `_tokenId` is not a valid NFT. When transfer is complete, this function
   * checks if `_to` is a smart contract (code size > 0). If so, it calls
   * `onERC721Received` on `_to` and throws if the return value is not
   * `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`.
   * @param _from The current owner of the NFT
   * @param _to The new owner
   * @param _tokenId The NFT to transfer
   * @param _data Additional data with no specified format, sent in call to `_to`
   */
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes calldata _data
  )
    external
    payable
    whenNotPaused
    whenNotPausedUser(msg.sender)
  {
    require(isSenderApprovedFor(_tokenId));
    _safeTransferFrom(_from, _to, _tokenId, _data);
  }

  /*
   * @notice send amount shareUsers
   */
  function sendAmountShareUsers(
    uint256 _tokenId, 
    address _to, 
    uint256 _amount
  ) 
    external 
    onlyCOO
    returns (bool) 
  {
    require(_to != address(0));
    return _calculateShareUsers(_tokenId, ownerOf(_tokenId), _to, _amount);
  }

  /*
   * @notice send amount shareUsers
   */
  function sendAmountShareUsersFrom(
    uint256 _tokenId, 
    address _from, 
    address _to, 
    uint256 _amount
  ) 
    external 
    onlyCOO
    returns (bool) 
  {
    require(_to != address(0));
    return _calculateShareUsers(_tokenId, _from, _to, _amount);
  }

  /*
   * @notice update collectedAmount 
   */
  function updateCollectedAmount(
    uint256 _tokenId, 
    uint256 _amount
  ) 
    external 
    onlyCOO 
    returns (bool) 
  {
    require(isValidRedToken(_tokenId));
    require(_amount > 0);
        
    redTokens[_tokenId].collectedAmount = redTokens[_tokenId].collectedAmount.add(_amount);
    
    emit CollectedAmountUpdate(_tokenId, ownerOf(_tokenId), _amount);
    return true;
  }

  /*
   * @notice createRedToken
   */
  function createRedToken(
    address _user, 
    string calldata _rmsBondNo, 
    uint256 _bondAmount, 
    uint256 _listingAmount
  ) 
    external 
    onlyCOO 
    returns (uint256) 
  {
    return _createRedToken(_user,_rmsBondNo,_bondAmount,_listingAmount);
  }

  /*
   * @notice burn amount a token by share users
   */
  function burnAmountByShareUser(
    uint256 _tokenId, 
    address _from, 
    uint256 _amount
  ) 
    external 
    onlyCOO 
    returns (bool) 
  {
    return _calculateShareUsers(_tokenId, _from, address(0), _amount);
  }
  
  /*
   * @notice burn RedToken
   */
  function burn(
    address _owner, 
    uint256 _tokenId
  ) 
    external 
    onlyCOO 
    returns(bool) 
  {
    require(_owner != address(0));
    return _burn(_owner, _tokenId);
  }

  /** internal function **/
  function isContract(address _addr) internal view returns (bool) {
    uint size;
    assembly { size := extcodesize(_addr) }
    return size > 0;
  }

  /*
   * @notice checked shareUser by shareUsersKeys
   */
  function isShareUser(
    uint256 _tokenId, 
    address _from
  ) 
    internal  
    view 
    returns (bool) 
  {
    bool chechedUser = false;
    for (uint index = 0; index < shareUsersKeys[_tokenId].length; index++) {
      if (  shareUsersKeys[_tokenId][index] == _from ){
        chechedUser = true;
        break;
      }
    }
    return chechedUser;
  }

  /*
   * @notice Transfers the ownership of an NFT from one address to another address
   * @param _from The current owner of the NFT
   * @param _to The new owner
   * @param _tokenId The NFT to transfer
   * @param _data Additional data with no specified format, sent in call to `_to`
   */
  function _safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes memory _data
  )
    internal
  {
    _clearApprovalAndTransfer(_from, _to, _tokenId);

    if (isContract(_to)) {
      bytes4 tokenReceiverResponse = ERC721TokenReceiver(_to).onERC721Received.gas(50000)(
        _from, _tokenId, _data
      );
      require(tokenReceiverResponse == bytes4(keccak256("onERC721Received(address,uint256,bytes)")));
    }
  }

  /*
  * @notice Internal function to clear current approval and transfer the ownership of a given token ID
  * @param _from address which you want to send tokens from
  * @param _to address which you want to transfer the token to
  * @param _tokenId uint256 ID of the token to be transferred
  */
  function _clearApprovalAndTransfer(
    address _from, 
    address _to, 
    uint256 _tokenId
  )
    internal 
  {
    require(_to != address(0));
    require(_to != ownerOf(_tokenId));
    require(ownerOf(_tokenId) == _from);
    require(isValidRedToken(_tokenId));
    
    address owner = ownerOf(_tokenId);

    _clearApproval(owner, _tokenId);
    _removeToken(owner, _tokenId);
    _addToken(_to, _tokenId);
    _changeTokenShareUserByOwner(owner, _to, _tokenId);

    emit Transfer(owner, _to, _tokenId);
  }

  /*
   * @notice change token owner rate sending
   * @param _from address which you want to change rate from
   * @param _to address which you want to change rate the token to
   * @param _tokenId uint256 ID of the token to be change rate
   */
  function _changeTokenShareUserByOwner(
    address _from, 
    address _to, 
    uint256 _tokenId
  ) 
    internal  
  {
    uint256 amount = shareUsers[_tokenId][_from];
    delete shareUsers[_tokenId][_from];

    shareUsers[_tokenId][_to] = shareUsers[_tokenId][_to].add(amount);

    if ( !isShareUser(_tokenId, _to) ) {
      shareUsersKeys[_tokenId].push(_to);
    }
  }

  /*
   * @notice remove shareUsers
   */
  function _calculateShareUsers(
    uint256 _tokenId, 
    address _from, 
    address _to, 
    uint256 _amount
  ) 
    internal
    returns (bool) 
  {
    require(_from != address(0));
    require(_from != _to);
    require(_amount > 0);
    require(shareUsers[_tokenId][_from] >= _amount);
    require(isValidRedToken(_tokenId));
    
    shareUsers[_tokenId][_from] = shareUsers[_tokenId][_from].sub(_amount);
    shareUsers[_tokenId][_to] = shareUsers[_tokenId][_to].add(_amount);

    if ( !isShareUser(_tokenId, _to) ) {
      shareUsersKeys[_tokenId].push(_to);
    }

    emit calculateShareUsers(_tokenId, ownerOf(_tokenId), _from, _to, _amount);
    return true;
  }

  /*
  * @notice Internal function to clear current approval of a given token ID
  * @param _tokenId uint256 ID of the token to be transferred
  */
  function _clearApproval(
    address _owner,
    uint256 _tokenId
  ) 
    internal 
  {
    require(ownerOf(_tokenId) == _owner);
    
    tokenApprovals[_tokenId] = address(0);

    emit Approval(_owner, address(0), _tokenId);
  }

  function _createRedToken(
    address _user, 
    string memory _rmsBondNo, 
    uint256 _bondAmount, 
    uint256 _listingAmount
  ) 
    internal 
    returns (uint256)
  {
    require(_user != address(0));
    require(bytes(_rmsBondNo).length > 0);
    require(_bondAmount > 0);
    require(_listingAmount > 0);

    uint256 _newTokenId = redTokens.length;

    RedToken memory _redToken = RedToken({
      tokenId: _newTokenId,
      rmsBondNo: _rmsBondNo,
      bondAmount: _bondAmount,
      listingAmount: _listingAmount,
      collectedAmount: 0,
      createdTime: now,
      isValid:true
    });

    redTokens.push(_redToken) - 1;

    shareUsers[_newTokenId][_user] = shareUsers[_newTokenId][_user].add(_listingAmount);
    shareUsersKeys[_newTokenId].push(_user);

    _addToken(_user, _newTokenId);

    emit RedTokenCreated(_user,
                        _redToken.tokenId,
                        _redToken.rmsBondNo,
                        _redToken.bondAmount,
                        _redToken.listingAmount,
                        _redToken.collectedAmount,
                        _redToken.createdTime);
    
    return _newTokenId;
  }
  
  /*
  * @notice Internal function to add a token ID to the list of a given address
  * @param _to address representing the new owner of the given token ID
  * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
  */
  function _addToken(
    address _to, 
    uint256 _tokenId
  ) 
    internal 
  {
    require(tokenOwner[_tokenId] == address(0));

    tokenOwner[_tokenId] = _to;
    uint256 length = balanceOf(_to);
    ownedTokens[_to].push(_tokenId);
    ownedTokensIndex[_tokenId] = length;
    totalTokens = totalTokens.add(1);
  }

  /*
  * @notice Internal function to remove a token ID from the list of a given address
  * @param _from address representing the previous owner of the given token ID
  * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
  */
  function _removeToken(
    address _from, 
    uint256 _tokenId
  ) 
    internal 
  {
    require(ownerOf(_tokenId) == _from);

    uint256 tokenIndex = ownedTokensIndex[_tokenId];
    uint256 lastTokenIndex = balanceOf(_from).sub(1);
    uint256 lastToken = ownedTokens[_from][lastTokenIndex];

    tokenOwner[_tokenId] = address(0);
    ownedTokens[_from][tokenIndex] = lastToken;
    ownedTokens[_from][lastTokenIndex] = 0;
    // Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to
    // be zero. Then we can make sure that we will remove _tokenId from the ownedTokens list since we are first swapping
    // the lastToken to the first position, and then dropping the element placed in the last position of the list

    ownedTokens[_from].length--;
    ownedTokensIndex[_tokenId] = 0;
    ownedTokensIndex[lastToken] = tokenIndex;
    totalTokens = totalTokens.sub(1);
  }

  /*
   * @dev Internal function to burn a specific token
   * @dev Reverts if the token does not exist
   * @param _tokenId uint256 ID of the token being burned by the msg.sender
   */
  function _burn(
    address _owner, 
    uint256 _tokenId
  ) 
    internal 
    returns(bool) 
  {
    require(ownerOf(_tokenId) == _owner);
    _clearApproval(_owner, _tokenId);
    _removeToken(_owner, _tokenId);

    redTokens[_tokenId].isValid = false;

    emit Transfer(_owner, address(0), _tokenId);
    return true;
  }
}

// File: contracts\RedTokenCore.sol

pragma solidity 0.5.7;


/*
 * @title RedTokenCore is the entry point of the contract
 * @notice RedTokenCore is the entry point and it controls the ability to set a new
 * contract address, in the case where an upgrade is required
 */
contract RedTokenCore is RedTokenOwnership{

  constructor() public {
    ceoAddress = msg.sender;
    cooAddress = msg.sender;
    cfoAddress = msg.sender;
  }

  function() external {
    assert(false);
  }
}