/**
 * Source Code first verified at https://etherscan.io on Thursday, April 18, 2019
 (UTC) */

pragma solidity ^0.4.24;

// File: contracts/libraries/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
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
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

// File: contracts/standards/Ownable.sol

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

// File: contracts/ItemBase.sol

contract ItemBase is Ownable {
    using SafeMath for uint;

    struct Item {
        string name;
        string itemType;
        string size;
        string color;
        // price (in wei) of item
        uint128 price;
    }

    uint128 MAX_ITEMS = 1;
    // array of items
    Item[] items;

    // @dev A mapping of item ids to the address that owns them
    mapping(uint => address) public itemIndexToOwner;

    // @dev A mapping from owner address to count of tokens that address owns.
    //  Used internally inside balanceOf() to resolve ownership count.
    mapping (address => uint) public ownershipTokenCount;

    // @dev A mapping from item ids to an address that has been approved to call
    //  transferFrom(). Each item can only have one approved address for transfer
    //  at any time. A zero value means no approval is outstanding.
    mapping (uint => address) public itemIndexToApproved;


    function getItem( uint _itemId ) public view returns(string name, string itemType, string size, string color, uint128 price) {
        Item memory _item = items[_itemId];

        name = _item.name;
        itemType = _item.itemType;
        size = _item.size;
        color = _item.color;
        price = _item.price;
    }
}

// File: contracts/standards/ERC721.sol

/// @title ERC-721 Non-Fungible Token Standard
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
///  Note: the ERC-165 identifier for this interface is 0x80ac58cd
contract ERC721 {
    function totalSupply() public view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function approve(address _approved, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;
    // function tokenMetadata(uint256 _tokenId) constant returns (string infoUrl);

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
}

// File: contracts/SatoshiZero.sol

contract SatoshiZero is ItemBase, ERC721 {
    string public constant name = "Satoshis Closet";
    string public constant symbol = "STCL";
    string public constant tokenName = "Tom's Shirt / The Proof of Concept";

    /// @dev Purchase event is fired after a purchase has been completed
    event Purchase(address owner, uint itemId);

    // Internal utility functions: These functions all assume that their input arguments are valid
    // We leave it to public methods to sanitize their inputs and follow the required logic.

    // @dev Checks if a given address is the current owner of a particular item.
    // @param _claimant the address we are validating against.
    // @param _tokenId item id, only valid when > 0
    function _owns(address _claimant, uint _tokenId) internal view returns (bool) {
        return itemIndexToOwner[_tokenId] == _claimant;
    }

    // @dev Checks if a given address currently has transferApproval for a particular item.
    // @param _claimant the address we are confirming item is approved for.
    // @param _tokenId item id, only valid when > 0
    function _approvedFor(address _claimant, uint _tokenId) internal view returns (bool) {
        return itemIndexToApproved[_tokenId] == _claimant;
    }

    // @dev Marks an address as being approved for transferFrom(), overwriting any previous approval
    //  Setting _approved to address(0) clears all transfer approval.
    //  NOTE: _approve() does NOT send the Approval event (IS THIS RIGHT?)
    function _approve(uint _tokenId, address _approved) internal {
        itemIndexToApproved[_tokenId] = _approved;
    }

    function balanceOf(address _owner) external view returns (uint) {
        return ownershipTokenCount[_owner];
    }

    function tokenMetadata(uint256 _tokenId) public view returns (string) {
        return 'https://satoshiscloset.com/SatoshiZero.json';
    }

    // @dev function to transfer item from one user to another
    //  this will become useful when reselling is implemented
    function transfer(address _to, uint _tokenId) external {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // You can only send your own item
        require(_owns(msg.sender, _tokenId));
        // Reassign ownership, clear pending approvals, emit Transfer event.
        _transfer(msg.sender, _to, _tokenId);
    }

    /// @notice Grant another address the right to transfer a specific item via
    ///  transferFrom(). This is the preferred flow for transfering NFTs to contracts.
    /// @param _to The address to be granted transfer approval. Pass address(0) to
    ///  clear all approvals.
    /// @param _tokenId The ID of the item that can be transferred if this call succeeds.
    /// @dev Required for ERC-721 compliance.
    function approve(address _to, uint _tokenId) external {
        // Only an owner can grant transfer approval.
        require(_owns(msg.sender, _tokenId));

        // Register the approval (replacing any previous approval).
        _approve(_tokenId, _to);

        // Emit approval event.
        emit Approval(msg.sender, _to, _tokenId);
    }

    /// @notice Transfer an item owned by another address, for which the calling address
    ///  has previously been granted transfer approval by the owner.
    /// @param _from The address that owns the item to be transfered.
    /// @param _to The address that should take ownership of the item. Can be any address,
    ///  including the caller.
    /// @param _tokenId The ID of the item to be transferred.
    /// @dev Required for ERC-721 compliance.
    function transferFrom(address _from, address _to, uint256 _tokenId) external {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Check for approval and valid ownership
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));

        // Reassign ownership (also clears pending approvals and emits Transfer event).
        _transfer(_from, _to, _tokenId);
    }

    /// @notice Returns the total number of items currently in existence.
    /// @dev Required for ERC-721 compliance.
    function totalSupply() public view returns (uint) {
        return items.length;
    }

    /// @notice Returns the address currently assigned ownership of a given item.
    /// @dev Required for ERC-721 compliance.
    function ownerOf(uint _tokenId) external view returns (address) {
        owner = itemIndexToOwner[_tokenId];
        require(owner != address(0));
    }

    function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens) {
        uint256 tokenCount = ownershipTokenCount[_owner];

        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalItems = totalSupply();
            uint256 resultIndex = 0;

            // We count on the fact that all items have IDs starting at 1 and increasing
            // sequentially up to the totalItems count.
            uint256 itemId;

            for (itemId = 1; itemId <= totalItems; itemId++) {
                if (itemIndexToOwner[itemId] == _owner) {
                    result[resultIndex] = itemId;
                    resultIndex++;
                }
            }

            return result;
        }
    }

    function _purchase(string _name, string _type, string _size, string _color, uint128 _price) internal returns (uint) {
        Item memory _item = Item({ name: _name, itemType: _type, size: _size, color: _color, price: _price });
        uint itemId = items.push(_item);

        // emit purchase event
        emit Purchase(msg.sender, itemId);

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _transfer(0, owner, itemId);

        return itemId;
    }

    // @dev Assigns ownership of a specific item to an address.
    function _transfer(address _from, address _to, uint _tokenId) internal {
        ownershipTokenCount[_to] = ownershipTokenCount[_to].add(1);
        // transfer ownership
        itemIndexToOwner[_tokenId] = _to;
        // When creating new items _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            ownershipTokenCount[_from] = ownershipTokenCount[_from].sub(1);
            // clear any previously approved ownership exchange
            delete itemIndexToApproved[_tokenId];
        }
        // Emit the transfer event.
        emit Transfer(_from, _to, _tokenId);
    }

    function createItem( string _name, string _itemType, string _size, string _color, uint128 _price) external onlyOwner returns (uint) {
        require(MAX_ITEMS > totalSupply());

        Item memory _item = Item({
            name: _name,
            itemType: _itemType,
            size: _size,
            color: _color,
            price: _price
        });
        uint itemId = items.push(_item);

        _transfer(0, owner, itemId);

        return itemId;
    }
}