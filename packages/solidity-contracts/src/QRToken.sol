/**
 * Source Code first verified at https://etherscan.io on Friday, March 15, 2019
 (UTC) */

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

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: openzeppelin-solidity/contracts/cryptography/ECDSA.sol

pragma solidity ^0.5.0;

/**
 * @title Elliptic curve signature operations
 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
 * TODO Remove this library once solidity supports passing a signature to ecrecover.
 * See https://github.com/ethereum/solidity/issues/864
 */

library ECDSA {
    /**
     * @dev Recover signer address from a message by using their signature
     * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
     * @param signature bytes signature, the signature is generated using web3.eth.sign()
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }

    /**
     * toEthSignedMessageHash
     * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:"
     * and hash the result
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

// File: contracts/IndexedMerkleProof.sol

pragma solidity ^0.5.5;


library IndexedMerkleProof {
    function compute(bytes memory proof, uint160 leaf) internal pure returns (uint160 root, uint256 index) {
        uint160 computedHash = leaf;

        for (uint256 i = 0; i < proof.length / 20; i++) {
            uint160 proofElement;
            // solium-disable-next-line security/no-inline-assembly
            assembly {
                proofElement := div(mload(add(proof, add(32, mul(i, 20)))), 0x1000000000000000000000000)
            }

            if (computedHash < proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = uint160(uint256(keccak256(abi.encodePacked(computedHash, proofElement))));
                index += (1 << i);
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = uint160(uint256(keccak256(abi.encodePacked(proofElement, computedHash))));
            }
        }

        return (computedHash, index);
    }
}

// File: contracts/InstaLend.sol

pragma solidity ^0.5.5;




contract InstaLend {
    using SafeMath for uint;

    address private _feesReceiver;
    uint256 private _feesPercent;
    bool private _inLendingMode;

    modifier notInLendingMode {
        require(!_inLendingMode);
        _;
    }

    constructor(address receiver, uint256 percent) public {
        _feesReceiver = receiver;
        _feesPercent = percent;
    }

    function feesReceiver() public view returns(address) {
        return _feesReceiver;
    }

    function feesPercent() public view returns(uint256) {
        return _feesPercent;
    }

    function lend(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        address target,
        bytes memory data
    )
        public
        notInLendingMode
    {
        _inLendingMode = true;

        // Backup original balances and lend tokens
        uint256[] memory prevAmounts = new uint256[](tokens.length);
        for (uint i = 0; i < tokens.length; i++) {
            prevAmounts[i] = tokens[i].balanceOf(address(this));
            require(tokens[i].transfer(target, amounts[i]));
        }

        // Perform arbitrary call
        (bool res,) = target.call(data);    // solium-disable-line security/no-low-level-calls
        require(res, "Invalid arbitrary call");

        // Ensure original balances were restored
        for (uint i = 0; i < tokens.length; i++) {
            uint256 expectedFees = amounts[i].mul(_feesPercent).div(100);
            require(tokens[i].balanceOf(address(this)) >= prevAmounts[i].add(expectedFees));
            if (_feesReceiver != address(this)) {
                require(tokens[i].transfer(_feesReceiver, expectedFees));
            }
        }

        _inLendingMode = false;
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.5.0;



/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 *
 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
 * all accounts just by listening to said events. Note that this isn't required by the specification, and other
 * compliant implementations may not do it.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
    * @dev Transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }
}

// File: contracts/CheckedERC20.sol

pragma solidity ^0.5.5;




library CheckedERC20 {
    using SafeMath for uint;

    function isContract(IERC20 addr) internal view returns(bool result) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            result := gt(extcodesize(addr), 0)
        }
    }

    function handleReturnBool() internal pure returns(bool result) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            switch returndatasize()
            case 0 { // not a std erc20
                result := 1
            }
            case 32 { // std erc20
                returndatacopy(0, 0, 32)
                result := mload(0)
            }
            default { // anything else, should revert for safety
                revert(0, 0)
            }
        }
    }

    function handleReturnBytes32() internal pure returns(bytes32 result) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            switch eq(returndatasize(), 32) // not a std erc20
            case 1 {
                returndatacopy(0, 0, 32)
                result := mload(0)
            }

            switch gt(returndatasize(), 32) // std erc20
            case 1 {
                returndatacopy(0, 64, 32)
                result := mload(0)
            }

            switch lt(returndatasize(), 32) // anything else, should revert for safety
            case 1 {
                revert(0, 0)
            }
        }
    }

    function asmTransfer(IERC20 token, address to, uint256 value) internal returns(bool) {
        require(isContract(token));
        // solium-disable-next-line security/no-low-level-calls
        (bool res,) = address(token).call(abi.encodeWithSignature("transfer(address,uint256)", to, value));
        require(res);
        return handleReturnBool();
    }

    function asmTransferFrom(IERC20 token, address from, address to, uint256 value) internal returns(bool) {
        require(isContract(token));
        // solium-disable-next-line security/no-low-level-calls
        (bool res,) = address(token).call(abi.encodeWithSignature("transferFrom(address,address,uint256)", from, to, value));
        require(res);
        return handleReturnBool();
    }

    function asmApprove(IERC20 token, address spender, uint256 value) internal returns(bool) {
        require(isContract(token));
        // solium-disable-next-line security/no-low-level-calls
        (bool res,) = address(token).call(abi.encodeWithSignature("approve(address,uint256)", spender, value));
        require(res);
        return handleReturnBool();
    }

    //

    function checkedTransfer(IERC20 token, address to, uint256 value) internal {
        if (value > 0) {
            uint256 balance = token.balanceOf(address(this));
            asmTransfer(token, to, value);
            require(token.balanceOf(address(this)) == balance.sub(value), "checkedTransfer: Final balance didn't match");
        }
    }

    function checkedTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        if (value > 0) {
            uint256 toBalance = token.balanceOf(to);
            asmTransferFrom(token, from, to, value);
            require(token.balanceOf(to) == toBalance.add(value), "checkedTransfer: Final balance didn't match");
        }
    }
}

// File: contracts/IKyberNetwork.sol

pragma solidity ^0.5.2;


contract IKyberNetwork {
    function trade(
        address src,
        uint256 srcAmount,
        address dest,
        address destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address walletId
    )
        public
        payable
        returns(uint);

    function getExpectedRate(
        address source,
        address dest,
        uint srcQty
    )
        public
        view
        returns (
            uint expectedPrice,
            uint slippagePrice
        );
}

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

// File: contracts/AnyPaymentReceiver.sol

pragma solidity ^0.5.5;







contract AnyPaymentReceiver is Ownable {
    using SafeMath for uint256;
    using CheckedERC20 for IERC20;

    address constant public ETHER_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    function _processPayment(
        IKyberNetwork kyber,
        address paymentToken,
        uint256 paymentAmount
    )
        internal
        returns(uint256)
    {
        uint256 previousBalance = address(this).balance;

        require(IERC20(paymentToken).asmApprove(address(kyber), paymentAmount));
        kyber.trade(
            paymentToken,
            paymentAmount,
            ETHER_ADDRESS,
            address(this),
            1 << 255,
            0,
            address(0)
        );

        uint256 currentBalance = address(this).balance;
        return currentBalance.sub(previousBalance);
    }
}

// File: contracts/QRToken.sol

pragma solidity ^0.5.5;










contract QRToken is InstaLend, AnyPaymentReceiver {
    using SafeMath for uint;
    using ECDSA for bytes;
    using IndexedMerkleProof for bytes;
    using CheckedERC20 for IERC20;

    uint256 constant public MAX_CODES_COUNT = 1024;
    uint256 constant public MAX_WORDS_COUNT = (MAX_CODES_COUNT + 31) / 32;

    struct Distribution {
        IERC20 token;
        uint256 sumAmount;
        uint256 codesCount;
        uint256 deadline;
        address sponsor;
        uint256[32] bitMask; // MAX_WORDS_COUNT
    }

    mapping(uint160 => Distribution) public distributions;

    event Created();
    event Redeemed(uint160 root, uint256 index, address receiver);

    constructor()
        public
        InstaLend(msg.sender, 1)
    {
    }

    function create(
        IERC20 token,
        uint256 sumTokenAmount,
        uint256 codesCount,
        uint160 root,
        uint256 deadline
    )
        external
        notInLendingMode
    {
        require(0 < sumTokenAmount);
        require(0 < codesCount && codesCount <= MAX_CODES_COUNT);
        require(deadline > now);

        token.checkedTransferFrom(msg.sender, address(this), sumTokenAmount);
        Distribution storage distribution = distributions[root];
        distribution.token = token;
        distribution.sumAmount = sumTokenAmount;
        distribution.codesCount = codesCount;
        distribution.deadline = deadline;
        distribution.sponsor = msg.sender;
    }

    function redeemed(uint160 root, uint index) public view returns(bool) {
        Distribution storage distribution = distributions[root];
        return distribution.bitMask[index / 32] & (1 << (index % 32)) != 0;
    }

    function calcRootAndIndex(
        bytes memory signature,
        bytes memory merkleProof,
        bytes memory message
    )
        public
        pure
        returns(uint160 root, uint256 index)
    {
        bytes32 messageHash = keccak256(message);
        bytes32 signedHash = ECDSA.toEthSignedMessageHash(messageHash);
        address signer = ECDSA.recover(signedHash, signature);
        uint160 signerHash = uint160(uint256(keccak256(abi.encodePacked(signer))));
        return merkleProof.compute(signerHash);
    }

    function redeem(
        bytes calldata signature,
        bytes calldata merkleProof
    )
        external
        notInLendingMode
    {
        (uint160 root, uint256 index) = calcRootAndIndex(signature, merkleProof, abi.encodePacked(msg.sender));
        Distribution storage distribution = distributions[root];
        require(distribution.bitMask[index / 32] & (1 << (index % 32)) == 0);

        distribution.bitMask[index / 32] = distribution.bitMask[index / 32] | (1 << (index % 32));
        distribution.token.checkedTransfer(msg.sender, distribution.sumAmount.div(distribution.codesCount));
        emit Redeemed(root, index, msg.sender);
    }

    function redeemWithFee(
        IKyberNetwork kyber, // 0x818E6FECD516Ecc3849DAf6845e3EC868087B755
        address receiver,
        uint256 feePrecent,
        bytes calldata signature,
        bytes calldata merkleProof
    )
        external
        notInLendingMode
    {
        (uint160 root, uint256 index) = calcRootAndIndex(signature, merkleProof, abi.encodePacked(receiver, feePrecent));
        Distribution storage distribution = distributions[root];
        require(distribution.bitMask[index / 32] & (1 << (index % 32)) == 0);

        distribution.bitMask[index / 32] = distribution.bitMask[index / 32] | (1 << (index % 32));
        uint256 reward = distribution.sumAmount.div(distribution.codesCount);
        uint256 fee = reward.mul(feePrecent).div(100);
        distribution.token.checkedTransfer(receiver, reward.sub(fee));
        emit Redeemed(root, index, msg.sender);

        uint256 gotEther = _processPayment(kyber, address(distribution.token), fee);
        msg.sender.transfer(gotEther);
    }

    function abort(uint160 root)
        public
        notInLendingMode
    {
        Distribution storage distribution = distributions[root];
        require(now > distribution.deadline);

        uint256 count = 0;
        for (uint i = 0; i < 1024; i++) {
            if (distribution.bitMask[i / 32] & (1 << (i % 32)) != 0) {
                count += distribution.sumAmount / distribution.codesCount;
            }
        }
        distribution.token.checkedTransfer(distribution.sponsor, distribution.sumAmount.sub(count));
        delete distributions[root];
    }

    function() external payable {
        require(msg.sender != tx.origin);
    }
}