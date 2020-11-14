/**
 * Source Code first verified at https://etherscan.io on Saturday, May 4, 2019
 (UTC) */

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

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

// File: openzeppelin-solidity/contracts/access/Roles.sol

pragma solidity ^0.5.0;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

// File: openzeppelin-solidity/contracts/access/roles/PauserRole.sol

pragma solidity ^0.5.0;


contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender));
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

pragma solidity ^0.5.0;


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

// File: contracts/libs/Strings.sol

pragma solidity 0.5.0;

library Strings {

    // via https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.5.sol
    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e) internal pure returns (string memory _concatenatedString) {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        uint i = 0;
        for (i = 0; i < _ba.length; i++) {
            babcde[k++] = _ba[i];
        }
        for (i = 0; i < _bb.length; i++) {
            babcde[k++] = _bb[i];
        }
        for (i = 0; i < _bc.length; i++) {
            babcde[k++] = _bc[i];
        }
        for (i = 0; i < _bd.length; i++) {
            babcde[k++] = _bd[i];
        }
        for (i = 0; i < _be.length; i++) {
            babcde[k++] = _be[i];
        }
        return string(babcde);
    }

    function strConcat(string memory _a, string memory _b) internal pure returns (string memory) {
        return strConcat(_a, _b, "", "", "");
    }

    function strConcat(string memory _a, string memory _b, string memory _c) internal pure returns (string memory) {
        return strConcat(_a, _b, _c, "", "");
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
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
        return string(bstr);
    }
}

// File: contracts/INiftyTradingCardCreator.sol

pragma solidity 0.5.0;

interface INiftyTradingCardCreator {
    function mintCard(
        uint256 _cardType,
        uint256 _nationality,
        uint256 _position,
        uint256 _ethnicity,
        uint256 _kit,
        uint256 _colour,
        address _to
    ) external returns (uint256 _tokenId);

    function setAttributes(
        uint256 _tokenId,
        uint256 _strength,
        uint256 _speed,
        uint256 _intelligence,
        uint256 _skill
    ) external returns (bool);

    function setName(
        uint256 _tokenId,
        uint256 _firstName,
        uint256 _lastName
    ) external returns (bool);

    function setAttributesAndName(
        uint256 _tokenId,
        uint256 _strength,
        uint256 _speed,
        uint256 _intelligence,
        uint256 _skill,
        uint256 _firstName,
        uint256 _lastName
    ) external returns (bool);
}

// File: contracts/generators/INiftyFootballTradingCardGenerator.sol

pragma solidity 0.5.0;

contract INiftyFootballTradingCardGenerator {
    function generateCard(address _sender) external returns (uint256 _nationality, uint256 _position, uint256 _ethnicity, uint256 _kit, uint256 _colour);

    function generateAttributes(address _sender, uint256 _base) external returns (uint256 strength, uint256 speed, uint256 intelligence, uint256 skill);

    function generateName(address _sender) external returns (uint256 firstName, uint256 lastName);
}

// File: contracts/FundsSplitter.sol

pragma solidity ^0.5.0;



contract FundsSplitter is Ownable {
    using SafeMath for uint256;

    address payable public platform;
    address payable public partner;

    uint256 public partnerRate = 7;

    constructor (address payable _platform, address payable _partner) public {
        platform = _platform;
        partner = _partner;
    }

    function splitFunds(uint256 _totalPrice) internal {
        if (msg.value > 0) {
            uint256 refund = msg.value.sub(_totalPrice);

            // overpaid...
            if (refund > 0) {
                msg.sender.transfer(refund);
            }

            // work out the amount to split and send it
            uint256 partnerAmount = _totalPrice.div(100).mul(partnerRate);
            partner.transfer(partnerAmount);

            // send remaining amount to partner wallet
            uint256 remaining = _totalPrice.sub(partnerAmount);
            platform.transfer(remaining);
        }
    }

    function updatePartnerAddress(address payable _partner) onlyOwner public {
        partner = _partner;
    }

    function updatePartnerRate(uint256 _techPartnerRate) onlyOwner public {
        partnerRate = _techPartnerRate;
    }

    function updatePlatformAddress(address payable _platform) onlyOwner public {
        platform = _platform;
    }

    function withdraw() public onlyOwner returns (bool) {
        platform.transfer(address(this).balance);
        return true;
    }
}

// File: contracts/NiftyFootballTradingCardBlindPack.sol

pragma solidity 0.5.0;









contract NiftyFootballTradingCardBlindPack is Ownable, Pausable, FundsSplitter {
    using SafeMath for uint256;

    event PriceInWeiChanged(uint256 _old, uint256 _new);

    event CreditAdded(address indexed _to);

    event DefaultCardTypeChanged(uint256 _new);

    event AttributesBaseChanged(uint256 _new);

    event FutballCardsGeneratorChanged(INiftyFootballTradingCardGenerator _new);

    INiftyFootballTradingCardGenerator public generator;
    INiftyTradingCardCreator public creator;

    mapping(address => uint256) public credits;

    uint256 public totalPurchasesInWei = 0;
    uint256 public cardTypeDefault = 0;
    uint256 public attributesBase = 40; // Standard 40-100

    uint256[] public pricePerCard = [
    // single cards
    11000000000000000, // 1 @ = 0.011 ETH / $1.75
    11000000000000000, // 2 @ = 0.011 ETH / $1.75

    // 1 packs
    10000000000000000, //  3 @ = 0.01 ETH / $1.59
    10000000000000000, //  4 @ = 0.01 ETH / $1.59
    10000000000000000, //  5 @ = 0.01 ETH / $1.59

    // 2 packs
    9100000000000000, //  6 @ = 0.0091 ETH / $1.45
    9100000000000000, //  7 @ = 0.0091 ETH / $1.45
    9100000000000000, //  8 @ = 0.0091 ETH / $1.45

    // 3 packs or more
    8500000000000000, //  9 @ = 0.0085 ETH / $1.35
    8500000000000000 //  10 @ = 0.0085 ETH / $1.35
    ];

    constructor (
        address payable _wallet,
        address payable _partnerAddress,
        INiftyFootballTradingCardGenerator _generator,
        INiftyTradingCardCreator _creator
    ) FundsSplitter(_wallet, _partnerAddress) public {
        generator = _generator;
        creator = _creator;
    }

    function blindPack() whenNotPaused public payable {
        blindPackTo(msg.sender);
    }

    function blindPackTo(address _to) whenNotPaused public payable {
        uint256 _totalPrice = totalPrice(1);
        require(
            credits[msg.sender] > 0 || msg.value >= _totalPrice,
            "Must supply at least the required minimum purchase value or have credit"
        );
        require(!isContract(msg.sender), "Unable to buy packs from another contract");

        _generateAndAssignCard(_to);

        _takePayment(1, _totalPrice);
    }

    function buyBatch(uint256 _numberOfCards) whenNotPaused public payable {
        return buyBatchTo(msg.sender, _numberOfCards);
    }

    function buyBatchTo(address _to, uint256 _numberOfCards) whenNotPaused public payable {
        uint256 _totalPrice = totalPrice(_numberOfCards);
        require(
            credits[msg.sender] >= _numberOfCards || msg.value >= _totalPrice,
            "Must supply at least the required minimum purchase value or have credit"
        );
        require(!isContract(msg.sender), "Unable to buy packs from another contract");

        for (uint i = 0; i < _numberOfCards; i++) {
            _generateAndAssignCard(_to);
        }

        _takePayment(_numberOfCards, _totalPrice);
    }

    function _generateAndAssignCard(address _to) internal {
        // Generate card
        (uint256 _nationality, uint256 _position, uint256 _ethnicity, uint256 _kit, uint256 _colour) = generator.generateCard(msg.sender);

        // cardType is 0 for genesis (initially)
        uint256 tokenId = creator.mintCard(cardTypeDefault, _nationality, _position, _ethnicity, _kit, _colour, _to);

        // Generate attributes
        (uint256 _strength, uint256 _speed, uint256 _intelligence, uint256 _skill) = generator.generateAttributes(msg.sender, attributesBase);
        (uint256 _firstName, uint256 _lastName) = generator.generateName(msg.sender);

        creator.setAttributesAndName(tokenId, _strength, _speed, _intelligence, _skill, _firstName, _lastName);
    }

    function _takePayment(uint256 _numberOfCards, uint256 _totalPrice) internal {
        // use credits first
        if (credits[msg.sender] >= _numberOfCards) {
            credits[msg.sender] = credits[msg.sender].sub(_numberOfCards);

            // Refund any accidentally ETH
            if (msg.value > 0) {
                msg.sender.transfer(msg.value);
            }
        } else {
            // any trapped ether can be withdrawn with withdraw()
            totalPurchasesInWei = totalPurchasesInWei.add(_totalPrice);
            splitFunds(_totalPrice);
        }
    }

    function setCardTypeDefault(uint256 _newDefaultCardType) public onlyOwner returns (bool) {
        cardTypeDefault = _newDefaultCardType;

        emit DefaultCardTypeChanged(_newDefaultCardType);

        return true;
    }

    function setAttributesBase(uint256 _newAttributesBase) public onlyOwner returns (bool) {
        attributesBase = _newAttributesBase;

        emit AttributesBaseChanged(_newAttributesBase);

        return true;
    }

    function setFutballCardsGenerator(INiftyFootballTradingCardGenerator _futballCardsGenerator) public onlyOwner returns (bool) {
        generator = _futballCardsGenerator;

        emit FutballCardsGeneratorChanged(_futballCardsGenerator);

        return true;
    }

    function updatePricePerCardAtIndex(uint256 _index, uint256 _priceInWei) public onlyOwner returns (bool) {
        pricePerCard[_index] = _priceInWei;
        return true;
    }

    function updatePricePerCard(uint256[] memory _pricePerCard) public onlyOwner returns (bool) {
        pricePerCard = _pricePerCard;
        return true;
    }

    function addCredit(address _to) public onlyOwner returns (bool) {
        credits[_to] = credits[_to].add(1);

        emit CreditAdded(_to);

        return true;
    }

    function addCredits(address _to, uint256 _creditsToAdd) public onlyOwner returns (bool) {
        credits[_to] = credits[_to].add(_creditsToAdd);

        emit CreditAdded(_to);

        return true;
    }

    function totalPrice(uint256 _numberOfCards) public view returns (uint256) {
        if (_numberOfCards > pricePerCard.length) {
            return pricePerCard[pricePerCard.length - 1].mul(_numberOfCards);
        }
        return pricePerCard[_numberOfCards - 1].mul(_numberOfCards);
    }

    /**
     * Returns whether the target address is a contract
     * Based on OpenZeppelin Address library
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
        // contracts then.
        // solhint-disable-next-line no-inline-assembly
        assembly {size := extcodesize(account)}
        return size > 0;
    }
}