/**
 * Source Code first verified at https://etherscan.io on Thursday, April 25, 2019
 (UTC) */

pragma solidity ^0.5.5;

//WLC VERSION 10

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="7d191809183d1c05141210071813531e12">[email protected]</a>> (https://github.com/dete)
interface ERC721 {
    // Required methods
    function totalSupply() external view returns (uint256 total);
    
    function balanceOf(address _owner) external view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) external view returns (address owner);
    function exists(uint256 _tokenId) external view returns (bool _exists);
    
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    // Events
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);

    // Optional
    function tokensOfOwner(address _owner) external view returns (uint256[] memory tokenIds);
    
    function supportsInterface(bytes4 _interfaceID) external view returns (bool);
}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Metadata is ERC721 {
  function name() external view returns (string memory _name);
  function symbol() external view returns (string memory _symbol);
  function tokenURI(uint256 _tokenId) public view returns (string memory);
}

contract DreamCarToken {
    function getWLCReward(uint256 _boughtWLCAmount, address _owner) public returns (uint256 remaining) {}
    
    function getForWLC(address _owner) public {}
}

contract WishListToken is ERC721, ERC721Metadata {
    string internal constant tokenName   = 'WishListCoin';
    string internal constant tokenSymbol = 'WLC';
    
    uint256 public constant decimals = 0;
    
    //ERC721 VARIABLES
    
    //the total count of wishes
    uint256 public totalTokenSupply;
    
    //this address is the CEO
    address payable public CEO;
    
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
    
    // Mapping from token ID to owner
    mapping (uint256 => address) internal tokenOwner;
    
    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) internal ownedTokensIndex;
    
    // Optional mapping for token URIs
    mapping(uint256 => string) internal tokenURIs;
    
    //TOKEN SPECIFIC VARIABLES
    
    // Mapping from owner to ids of owned tokens
    mapping (address => uint256[]) internal tokensOwnedBy;
    
    // Mapping from owner to ids of exchanged tokens
    mapping (address => uint256[]) internal tokensExchangedBy;
    
    //Token price in WEI
    uint256 public tokenPrice;
    
    //A list of price admins; they can change price, in addition to the CEO
    address[] public priceAdmins;
    
    //Next id that will be assigned to token
    uint256 internal nextTokenId = 1;
    
    //DCC INTERACTION VARIABLES
    
    //A list, containing the addresses of DreamCarToken contracts, which will be used to award bonus tokens,
    //when an user purchases a large number of WLC tokens
    DreamCarToken[] public dreamCarCoinContracts;
    
    //A DreamCarToken contract address, which will be used to allow the excange of WLC tokens for DCC tokens
    DreamCarToken public dreamCarCoinExchanger;
    
    //ERC721 FUNCTIONS IMPLEMENTATIONS
    
    function supportsInterface(bytes4 _interfaceID) external view returns (bool) {
        return ((_interfaceID == InterfaceSignature_ERC165) || (_interfaceID == InterfaceSignature_ERC721));
    }
    
    /**
     * Gets the total amount of tokens stored by the contract
     * @return uint256 representing the total amount of tokens
     */
    function totalSupply() public view returns (uint256 total) {
        return totalTokenSupply;
    }
    
    /**
     * Gets the balance of the specified address
     * @param _owner address to query the balance of
     * @return uint256 representing the amount owned by the passed address
     */
    function balanceOf(address _owner) public view returns (uint256 _balance) {
        return tokensOwnedBy[_owner].length;
    }
    
    /**
     * Gets the owner of the specified token ID
     * @param _tokenId uint256 ID of the token to query the owner of
     * @return owner address currently marked as the owner of the given token ID
     */
    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        return tokenOwner[_tokenId];
    }
    
    /**
     * Returns whether the specified token exists
     * @param _tokenId uint256 ID of the token to query the existence of
     * @return whether the token exists
     */
    function exists(uint256 _tokenId) public view returns (bool) {
        address owner = tokenOwner[_tokenId];
        return owner != address(0);
    }
    
    /**
     * Returns a list of the tokens ids, owned by the passed address
     * @param _owner address the address to chesck
     * @return the list of token ids
     */
    function tokensOfOwner(address _owner) external view returns (uint256[] memory tokenIds) {
        return tokensOwnedBy[_owner];
    }
    
    /**
     * Transfers the specified token to the specified address
     * @param _to address the receiver
     * @param _tokenId uint256 the id of the token
     */
    function transfer(address _to, uint256 _tokenId) external {
        require(_to != address(0));
        
        ensureAddressIsTokenOwner(msg.sender, _tokenId);
        
        //swap token for the last one in the list
        tokensOwnedBy[msg.sender][ownedTokensIndex[_tokenId]] = tokensOwnedBy[msg.sender][tokensOwnedBy[msg.sender].length - 1];
        
        //record the changed position of the last element
        ownedTokensIndex[tokensOwnedBy[msg.sender][tokensOwnedBy[msg.sender].length - 1]] = ownedTokensIndex[_tokenId];
        
        //remove last element of the list
        tokensOwnedBy[msg.sender].pop();
        
        //delete tokensOwnedBy[msg.sender][ownedTokensIndex[_tokenId]];
        tokensOwnedBy[_to].push(_tokenId);
        
        tokenOwner[_tokenId] = _to;
        ownedTokensIndex[_tokenId] = tokensOwnedBy[_to].length - 1;
        
        emit Transfer(msg.sender, _to, _tokenId);
    }
    
    /**
     * Not necessary in the contract
     */
    function approve(address _to, uint256 _tokenId) external { }
    
    /**
     * Not necessary in the contract
     */
    function transferFrom(address _from, address _to, uint256 _tokenId) external { }
    
    /**
     * Internal function to set the token URI for a given token
     * Reverts if the token ID does not exist
     * @param _tokenId uint256 ID of the token to set its URI
     * @param _uri string URI to assign
     */
    function _setTokenURI(uint256 _tokenId, string storage _uri) internal {
        require(exists(_tokenId));
        tokenURIs[_tokenId] = _uri;
    }
    
    //ERC721Metadata FUNCTIONS IMPLEMENTATIONS
    /**
     * Gets the token name
     * @return string representing the token name
     */
    function name() external view returns (string memory _name) {
        return tokenName;
    }
    
    /**
     * Gets the token symbol
     * @return string representing the token symbol
     */
    function symbol() external view returns (string memory _symbol) {
        return tokenSymbol;
    }
    
    /**
     * Returns an URI for a given token ID
     * Throws if the token ID does not exist. May return an empty string.
     * @param _tokenId uint256 ID of the token to query
     */
    function tokenURI(uint256 _tokenId) public view returns (string memory) {
        require(exists(_tokenId));
        return tokenURIs[_tokenId];
    }
    
    //TOKEN SPECIFIC FUNCTIONS
    
    event Buy(address indexed from, uint256 amount, uint256 fromTokenId, uint256 toTokenId, uint256 timestamp);
    
    event Exchange(address indexed from, uint256 tokenId);
    
    event ExchangeForDCC(address indexed from, uint256 tokenId);
    
    /**
     * Ensures that the caller of the function is the CEO of contract
     */
    modifier onlyCEO {
        require(msg.sender == CEO, 'You need to be the CEO to do that!');
        _;
    }
    
    /**
     * Constructor of the contract
     * @param _ceo address the CEO (owner) of the contract
     */
    constructor (address payable _ceo) public {
        CEO = _ceo;
        
        totalTokenSupply = 1001000;
        
        tokenPrice = 3067484662576687; // (if eth = 163USD, 0.5 USD for token)
    }

    /**
     * Gets an array of all tokens ids, exchanged by the specified address
     * @param _owner address The excanger of the tokens
     * @return uint256[] The list of exchanged tokens ids
     */
    function exchangedBy(address _owner) external view returns (uint256[] memory tokenIds) {
        return tokensExchangedBy[_owner];
    }
    
    /**
     * Gets the last existing token ids
     * @return uint256 the id of the token
     */
    function lastTokenId() public view returns (uint256 tokenId) {
        return nextTokenId - 1;
    }
    
    /**
     * Sets a new price for the tokensExchangedBy
     * @param _newPrice uint256 the new price in WEI
     */
    function setTokenPriceInWEI(uint256 _newPrice) public {
        bool transactionAllowed = false;
        
        if (msg.sender == CEO) {
            transactionAllowed = true;
        } else {
            for (uint256 i = 0; i < priceAdmins.length; i++) {
                if (msg.sender == priceAdmins[i]) {
                    transactionAllowed = true;
                    break;
                }
            }
        }
        
        require((transactionAllowed == true), 'You cannot do that!');
        tokenPrice = _newPrice;
    }
    
    /**
     * Add a new price admin address to the list
     * @param _newPriceAdmin address the address of the new price admin
     */
    function addPriceAdmin(address _newPriceAdmin) onlyCEO public {
        priceAdmins.push(_newPriceAdmin);
    }
    
    /**
     * Remove existing price admin address from the list
     * @param _existingPriceAdmin address the address of the existing price admin
     */
    function removePriceAdmin(address _existingPriceAdmin) onlyCEO public {
        for (uint256 i = 0; i < priceAdmins.length; i++) {
            if (_existingPriceAdmin == priceAdmins[i]) {
                delete priceAdmins[i];
                break;
            }
        }
    }
    
    /**
     * Adds the specified number of tokens to the specified address
     * Internal method, used when creating new tokens
     * @param _to address The address, which is going to own the tokens
     * @param _amount uint256 The number of tokens
     */
    function _addTokensToAddress(address _to, uint256 _amount) internal {
        for (uint256 i = 0; i < _amount; i++) {
            tokensOwnedBy[_to].push(nextTokenId + i);
            tokenOwner[nextTokenId + i] = _to;
            ownedTokensIndex[nextTokenId + i] = tokensOwnedBy[_to].length - 1;
        }
        
        nextTokenId += _amount;
    }
    
    /**
     * Checks if the specified token is owned by the transaction sender
     */
    function ensureAddressIsTokenOwner(address _owner, uint256 _tokenId) internal view {
        require(balanceOf(_owner) >= 1, 'You do not own any tokens!');
        
        require(tokenOwner[_tokenId] == _owner, 'You do not own this token!');
    }
    
    /**
     * Scales the amount of tokens in a purchase, to ensure it will be less or equal to the amount of unsold tokens
     * If there are no tokens left, it will return 0
     * @param _amount uint256 the amout of tokens in the purchase attempt
     * @return _exactAmount uint256
     */
    function scalePurchaseTokenAmountToMatchRemainingTokens(uint256 _amount) internal view returns (uint256 _exactAmount) {
        if (nextTokenId + _amount - 1 > totalTokenSupply) {
            _amount = totalTokenSupply - nextTokenId + 1;
        }
        
        if (balanceOf(msg.sender) + _amount > 100) {
            _amount = 100 - balanceOf(msg.sender);
            require(_amount > 0, "You can own maximum of 100 tokens!");
        }
        
        return _amount;
    }
    
    /**
    * Buy new tokens with ETH
    * Calculates the nubmer of tokens for the given ETH amount
    * Creates the new tokens when they are purchased
    * Returns the excessive ETH (if any) to the transaction sender
    */
    function buy() payable public {
        require(msg.value >= tokenPrice, "You did't send enough ETH");
        
        uint256 amount = scalePurchaseTokenAmountToMatchRemainingTokens(msg.value / tokenPrice);
        
        require(amount > 0, "Not enough tokens are available for purchase!");
        
        _addTokensToAddress(msg.sender, amount);
        
        emit Buy(msg.sender, amount, nextTokenId - amount, nextTokenId - 1, now);
        
        //transfer ETH to CEO
        CEO.transfer((amount * tokenPrice));
        
        getDCCRewards(amount);
        
        //returns excessive ETH
        msg.sender.transfer(msg.value - (amount * tokenPrice));
    }
    
    /**
     * Removes a token from the provided address ballance and puts it in the tokensExchangedBy mapping
     * @param _owner address the address of the token owner
     * @param _tokenId uint256 the id of the token
     */
    function exchangeToken(address _owner, uint256 _tokenId) internal {
        ensureAddressIsTokenOwner(_owner, _tokenId);
        
        //swap token for the last one in the list
        tokensOwnedBy[_owner][ownedTokensIndex[_tokenId]] = tokensOwnedBy[_owner][tokensOwnedBy[_owner].length - 1];
        
        //record the changed position of the last element
        ownedTokensIndex[tokensOwnedBy[_owner][tokensOwnedBy[_owner].length - 1]] = ownedTokensIndex[_tokenId];
        
        //remove last element of the list
        tokensOwnedBy[_owner].pop();
        
        ownedTokensIndex[_tokenId] = 0;
        
        delete tokenOwner[_tokenId];
        
        tokensExchangedBy[_owner].push(_tokenId);
    }
    
    /**
    * Allows user to destroy a specified token in order to claim his prize for the it
    * @param _tokenId uint256 ID of the token
    */
    function exchange(uint256 _tokenId) public {
        exchangeToken(msg.sender, _tokenId);
        
        emit Exchange(msg.sender, _tokenId);
    }
    
    /**
     * Allows the CEO to increase the totalTokenSupply
     * @param _amount uint256 the number of tokens to create
     */
    function mint(uint256 _amount) onlyCEO public {
        require (_amount > 0, 'Amount must be bigger than 0!');
        totalTokenSupply += _amount;
    }
    
    //DCC INTERACTION FUNCTIONS
    
    /**
     * Adds a DreamCarToken contract address to the list on a specific position.
     * This allows to maintain and control the order of DreamCarToken contracts, according to their bonus rates
     * @param _index uint256 the index where the address will be inserted/overwritten
     * @param _address address the address of the DreamCarToken contract
     */
    function setDreamCarCoinAddress(uint256 _index, address _address) public onlyCEO {
        require (_address != address(0));
        if (dreamCarCoinContracts.length > 0 && dreamCarCoinContracts.length - 1 >= _index) {
            dreamCarCoinContracts[_index] = DreamCarToken(_address);
        } else {
            dreamCarCoinContracts.push(DreamCarToken(_address));
        }
    }
    
    /**
     * Removes a DreamCarToken contract address from the list, by its list index
     * @param _index uint256 the position of the address
     */
    function removeDreamCarCoinAddress(uint256 _index) public onlyCEO {
        delete(dreamCarCoinContracts[_index]);
    }
    
    /**
     * Allows the CEO to set an address of DreamCarToken contract, which will be used to excanger
     * WLCs for DCCs
     * @param _address address the address of the DreamCarToken contract
     */
    function setDreamCarCoinExchanger(address _address) public onlyCEO {
        require (_address != address(0));
        dreamCarCoinExchanger = DreamCarToken(_address);
    }
    
    /**
     * Allows the CEO to remove the address of DreamCarToken contract, which will be used to excanger
     * WLCs for DCCs
     */
    function removeDreamCarCoinExchanger() public onlyCEO {
        dreamCarCoinExchanger = DreamCarToken(address(0));
    }
    
    /**
     * Allows the buyer of WLC coins to receive DCCs as bonus.
     * Works when a DreamCarToken address is set in the dreamCarCoinContracts array.
     * Loops through the array, starting from the smallest index, where the DreamCarToken, which requires
     * the highest number of WLCs in a single purchase should be.
     * Gets the remaining WLCs, after the bonus is payed and tries to get bonus from the other DreamCarToken contracts
     * in the list
     * @param _amount uint256 how many tokens was purchased by the buyer
     */
    function getDCCRewards(uint256 _amount) internal {
        for (uint256 i = 0; i < dreamCarCoinContracts.length; i++) {
            if (_amount > 0 && address(dreamCarCoinContracts[i]) != address(0)) {
                _amount = dreamCarCoinContracts[i].getWLCReward(_amount, msg.sender);
            } else {
                break;
            }
        }
    }
    
    /**
     * Allows a user to exchange any WLC coin token a DCC token
     * @param _tokenId uint256 the id of the owned token
     */
    function exchangeForDCC(uint256 _tokenId) public {
        require (address(dreamCarCoinExchanger) != address(0));
        
        dreamCarCoinExchanger.getForWLC(msg.sender);
        
        exchangeToken(msg.sender, _tokenId);
        
        emit ExchangeForDCC(msg.sender, _tokenId);
    }
}