/**
 * Source Code first verified at https://etherscan.io on Thursday, April 18, 2019
 (UTC) */

pragma solidity >=0.4.22 <0.6.0;

contract CryptoConstellationAccessControl  {
    
    address public ceoAddress;
    address public ctoAddress;
    address public cfoAddress;
    address public cooAddress;

    bool public paused = false;
    
    mapping (address => string) public userNickName;

    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }
    
    modifier onlyCTO() {
        require(msg.sender == ctoAddress);
        _;
    }

    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }

    modifier onlyCOO() {
        require(msg.sender == cooAddress);
        _;
    }

    modifier onlyCLevel() {
        require(
            msg.sender == cooAddress ||
            msg.sender == ceoAddress ||
            msg.sender == cfoAddress ||
            msg.sender == ctoAddress
        );
        _;
    }
    
    function setCEO(address _newCEO) external onlyCEO {
        require(_newCEO != address(0));
        ceoAddress = _newCEO;
    }
    
    function setCTO(address _newCTO) external onlyCEO {
        require(_newCTO != address(0));
        ctoAddress = _newCTO;
    }

    function setCFO(address _newCFO) external onlyCEO {
        require(_newCFO != address(0));
        cfoAddress = _newCFO;
    }

    function setCOO(address _newCOO) external onlyCEO {
        require(_newCOO != address(0));
        cooAddress = _newCOO;
    }

    function setNickName(address _user, string calldata _nickName) external returns (bool) {
        require(_user != address(0));
        userNickName[_user] = _nickName;
    }

    function getNickName(address _user) external view returns (string memory _nickname) {
        require(_user != address(0));

        _nickname = userNickName[_user];
    }
    
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused {
        require(paused);
        _;
    }

    function pause() external onlyCLevel whenNotPaused {
        paused = true;
    }
    
    function unpause() external onlyCEO whenPaused {
        // can't unpause if contract was upgraded
        paused = false;
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

contract CryptoConstellationBase is CryptoConstellationAccessControl {

    using SafeMath for uint256;
    
    event ConstellationCreation(address indexed _owner, uint256 indexed _tokenId);
    
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);

    event Bought (uint256 indexed _tokenId, address indexed _owner, uint256 _price);

    event Sold (uint256 indexed _tokenId, address indexed _owner, uint256 _price);
    
    struct Constellation {
        string name;
        string description;
        string ipfsHash;
        uint64 creationTimestamp;
    }

    
    uint256 internal increaseLimit1 = 0.02 ether;
    uint256 internal increaseLimit2 = 0.5 ether;
    uint256 internal increaseLimit3 = 2.0 ether;
    uint256 internal increaseLimit4 = 5.0 ether;
    
    Constellation[] constellations;
    
    mapping (uint256 => address) public constellationCurrentOwner;
    
    mapping (address => uint256) internal ownershipTokenCount;

    mapping (uint256 => uint256) internal startingPriceOfConstellation;

    mapping (uint256 => uint256) internal priceOfConstellation;

    mapping (uint256 => address) internal approvedOfConstellation;
    
    
    modifier onlyOwner(uint _propId) {
		require(constellationCurrentOwner[_propId] == msg.sender);
		_;
	}

    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        
        // Since the number of assets is capped to 2^32 we can't overflow this
        ownershipTokenCount[_to]++;
        // transfer ownership
        constellationCurrentOwner[_tokenId] = _to;

        approvedOfConstellation[_tokenId] = address(0);
        // When creating new kittens _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
        }
        // Emit the transfer event.
        emit Transfer(_from, _to, _tokenId);
    }
    
    
    function calculateNextPrice (uint256 _price) public view returns (uint256 _nextPrice) {
        if (_price < increaseLimit1) {
            return _price.mul(200).div(95);
        } else if (_price < increaseLimit2) {
            return _price.mul(135).div(96);
        } else if (_price < increaseLimit3) {
            return _price.mul(125).div(97);
        } else if (_price < increaseLimit4) {
            return _price.mul(117).div(97);
        } else {
            return _price.mul(115).div(98);
        }
    }

    function calculateDevCut (uint256 _price) public view returns (uint256 _devCut) {
        if (_price < increaseLimit1) {
            return _price.mul(10).div(100); // 10%
        } else if (_price < increaseLimit2) {
            return _price.mul(9).div(100); // 9%
        } else if (_price < increaseLimit3) {
            return _price.mul(8).div(100); // 8%
        } else if (_price < increaseLimit4) {
            return _price.mul(7).div(100); // 7%
        } else {
            return _price.mul(6).div(100); // 6%
        }
    }

    
    function createConstellation(
        string calldata _name,
        string calldata _description,
        string calldata _ipfsHash,
        uint256 _price,
        address _owner
    )
        external
        whenNotPaused
        onlyCLevel
        returns (uint)
    {
        return _createConstellation(_name, _description, _ipfsHash, _price, _owner);
    }
    
    function _createConstellation(
        string memory _name,
        string memory _description,
        string memory _ipfsHash,
        uint256 _price,
        address _owner
    )
        internal
        whenNotPaused
        onlyCLevel
        returns (uint)
    {
        
        Constellation memory _constellation = Constellation({
            name: _name,
            description: _description,
            ipfsHash: _ipfsHash,
            creationTimestamp: uint64(block.timestamp)
        });
        uint256 newConstellationId = constellations.push(_constellation) - 1;

        require(newConstellationId == uint256(uint32(newConstellationId)));

        startingPriceOfConstellation[newConstellationId] = _price;
        priceOfConstellation[newConstellationId] = _price;

        // emit the birth event
        emit ConstellationCreation(_owner, newConstellationId);

        _transfer(address(0), _owner, newConstellationId);

        return newConstellationId;
    }
   
}


contract ERC721  {
    
    // Required methods
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) public view returns (address owner);
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    // Events
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);

    // Optional
    // function name() public view returns (string name);
    // function symbol() public view returns (string symbol);
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    function supportsInterface(bytes4 _interfaceID) external view returns (bool);
    
}

contract ERC721Metadata {
    /// @dev Given a token Id, returns a byte array that is supposed to be converted into string.
    function getMetadata(uint256 _tokenId, string memory) public pure returns (bytes32[4] memory buffer, uint256 count) {
        if (_tokenId == 1) {
            buffer[0] = "Hello World! :D";
            count = 15;
        } else if (_tokenId == 2) {
            buffer[0] = "I would definitely choose a medi";
            buffer[1] = "um length string.";
            count = 49;
        } else if (_tokenId == 3) {
            buffer[0] = "Lorem ipsum dolor sit amet, mi e";
            buffer[1] = "st accumsan dapibus augue lorem,";
            buffer[2] = " tristique vestibulum id, libero";
            buffer[3] = " suscipit varius sapien aliquam.";
            count = 128;
        }
    }
}

contract CryptoConstellationOwnership is CryptoConstellationBase, ERC721 {
    
    string public constant name = "CryptoConstellation";
    string public constant symbol = "CCL";

    ERC721Metadata public erc721Metadata;

    bytes4 constant InterfaceSignature_ERC165 =
        bytes4(keccak256('supportsInterface(bytes4)'));

    bytes4 constant InterfaceSignature_ERC721 =
        bytes4(keccak256('name()')) ^
        bytes4(keccak256('symbol()')) ^
        bytes4(keccak256('totalSupply()')) ^
        bytes4(keccak256('balanceOf(address)')) ^
        bytes4(keccak256('ownerOf(uint256)')) ^
        bytes4(keccak256('approve(address,uint256)')) ^
        bytes4(keccak256('transfer(address,uint256)')) ^
        bytes4(keccak256('transferFrom(address,address,uint256)')) ^
        bytes4(keccak256('tokensOfOwner(address)')) ^
        bytes4(keccak256('tokenMetadata(uint256,string)'));


    function supportsInterface(bytes4 _interfaceID) external view returns (bool)
    {
        
        return ((_interfaceID == InterfaceSignature_ERC165) || (_interfaceID == InterfaceSignature_ERC721));
    }

    function setMetadataAddress(address _contractAddress) public onlyCEO {
        erc721Metadata = ERC721Metadata(_contractAddress);
    }


    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return constellationCurrentOwner[_tokenId] == _claimant;
    }
    
    function _approvedFor(uint256 _tokenId) internal view returns (address) {
        return approvedOfConstellation[_tokenId];
    }

    function _approve(uint256 _tokenId, address _to) internal {
        require(msg.sender != _to);
        require(tokenExists(_tokenId));
        require(ownerOf(_tokenId) == msg.sender);

        if (_to == address(0)) {
            if (approvedOfConstellation[_tokenId] != address(0)) {
                delete approvedOfConstellation[_tokenId];
                emit Approval(msg.sender, address(0), _tokenId);
            }
        } else {
            approvedOfConstellation[_tokenId] = _to;
            emit Approval(msg.sender, _to, _tokenId);
        }
    }

    function ownerOf (uint256 _itemId) public view returns (address _owner) {
        return constellationCurrentOwner[_itemId];
    }

    function balanceOf(address _owner) public view returns (uint256 count) {
        return ownershipTokenCount[_owner];
    }

    function buy(uint256 _tokenId) payable external whenNotPaused
    {
        require(priceOf(_tokenId) > 0);
        require(ownerOf(_tokenId) != address(0));
        require(msg.value >= priceOf(_tokenId));
        require(ownerOf(_tokenId) != msg.sender);
        require(msg.sender != address(0));

        address payable oldOwner = address(uint160(ownerOf(_tokenId)));
        address payable newOwner = msg.sender;
        uint256 price = priceOf(_tokenId);
        uint256 excess = msg.value.sub(price);

        _transfer(oldOwner, newOwner, _tokenId);
        priceOfConstellation[_tokenId] = nextPriceOf(_tokenId);

        emit Bought(_tokenId, newOwner, price);
        emit Sold(_tokenId, oldOwner, price);

        // Devevloper's cut which is left in contract and accesed by
        // `withdrawAll` and `withdrawAmountTo` methods.
        uint256 devCut = calculateDevCut(price);

        // Transfer payment to old owner minus the developer's cut.
        oldOwner.transfer(price.sub(devCut));

        if (excess > 0) {
            newOwner.transfer(excess);
        }
    }


    function approve(address _to, uint256 _tokenId) external whenNotPaused
    {
        require(_owns(msg.sender, _tokenId));
        
        _approve(_tokenId, _to);
    }

    function transfer(address _to, uint256 _itemId) external {
        require(msg.sender == ownerOf(_itemId));
        _transfer(msg.sender, _to, _itemId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external whenNotPaused
    {
        require(_to != address(0));
        require(_to != address(this));
        
        require(_approvedFor(_tokenId) == msg.sender);
        require(_owns(_from, _tokenId));


        _transfer(_from, _to, _tokenId);
    }
    
    

    function totalSupply() public view returns (uint) {
        return constellations.length - 1;
    }

    function tokenExists(uint256 _itemId) public view returns (bool _exists) {
    return priceOf(_itemId) > 0;
    }

    function startingPriceOf(uint256 _itemId) public view returns (uint256 _startingPrice) {
        return startingPriceOfConstellation[_itemId];
    }

    function priceOf(uint256 _itemId) public view returns (uint256 _price) {
        return priceOfConstellation[_itemId];
    }

    function nextPriceOf(uint256 _itemId) public view returns (uint256 _nextPrice) {
        return calculateNextPrice(priceOf(_itemId));
    }


    function tokensOfOwner(address _owner) external view returns(uint256[] memory ownerTokens) {
        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalConstellation = totalSupply();
            uint256 resultIndex = 0;

            uint256 constellationId;

            for (constellationId = 1; constellationId <= totalConstellation; constellationId++) {
                if (constellationCurrentOwner[constellationId] == _owner) {
                    result[resultIndex] = constellationId;
                    resultIndex++;
                }
            }

            return result;
        }
    }


    function _memcpy(uint _dest, uint _src, uint _len) private pure {
        // Copy word-length chunks while possible
        for(; _len >= 32; _len -= 32) {
            assembly {
                mstore(_dest, mload(_src))
            }
            _dest += 32;
            _src += 32;
        }

        // Copy remaining bytes
        uint256 mask = 256 ** (32 - _len) - 1;
        assembly {
            let srcpart := and(mload(_src), not(mask))
            let destpart := and(mload(_dest), mask)
            mstore(_dest, or(destpart, srcpart))
        }
    }
    
    
    function _toString(bytes32[4] memory _rawBytes, uint256 _stringLength) private pure returns (string memory) {
        string memory outputString = new string(_stringLength);
        uint256 outputPtr;
        uint256 bytesPtr;

        assembly {
            outputPtr := add(outputString, 32)
            bytesPtr := _rawBytes
        }

        _memcpy(outputPtr, bytesPtr, _stringLength);

        return outputString;
    }


    function tokenMetadata(uint256 _tokenId, string calldata _preferredTransport) external view returns (string memory infoUrl) {
        bytes32[4] memory buffer;
        uint256 count;
        (buffer, count) = erc721Metadata.getMetadata(_tokenId, _preferredTransport);

        return _toString(buffer, count);
    }

    function withdrawAll () onlyCLevel external {
        address payable companyAddress = address(uint160(ceoAddress));
        companyAddress.transfer(address(this).balance);
    }

    function withdrawAmount (uint256 _amount) onlyCLevel external {
        address payable companyAddress = address(uint160(ceoAddress));
        companyAddress.transfer(_amount);
    }
}

contract CryptoConstellationCore is CryptoConstellationOwnership{
    
    constructor() public{

        // the creator of the contract is the initial CEO
        ceoAddress = msg.sender;

        // the creator of the contract is also the initial CTO
        ctoAddress = msg.sender;

    }
    
    
    function getConstellation(uint256 _id)
        external
        view
        returns (
        string memory _name,
        string memory _description,
        string memory _ipfsHash,
        address _owner, 
        uint256 _startingPrice, 
        uint256 _price, 
        uint256 _nextPrice
    ) {
        Constellation memory constellation = constellations[_id];
        
        _name = constellation.name;
        _description = constellation.description;
        _ipfsHash = constellation.ipfsHash;
        _owner = ownerOf(_id);
        _startingPrice = startingPriceOf(_id);
        _price = priceOf(_id);
        _nextPrice = nextPriceOf(_id);
        
    }
    
}