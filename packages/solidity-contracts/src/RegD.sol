/**
 * Source Code first verified at https://etherscan.io on Thursday, March 28, 2019
 (UTC) */

pragma solidity 0.5.0;

//
// base contract for all our horizon contracts and tokens
//
contract HorizonContractBase {
    // The owner of the contract, set at contract creation to the creator.
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    // Contract authorization - only allow the owner to perform certain actions.
    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/ERC20/ERC20.sol
// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/ERC20/ERC20Basic.sol
// 
// ----------------------------------------------------------------------------
interface ERC20Interface {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address approver, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    // solhint-disable-next-line no-simple-event-func-name
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed approver, address indexed spender, uint256 value);
}

/**
 * ICOToken for the timelessluxurygroup.com by Horizon-Globex.com of Switzerland.
 *
 * An ERC20 standard
 *
 * Author: Horizon Globex GmbH Development Team
 *
 * Dev Notes
 *   NOTE: There is no fallback function as this contract will never contain Ether, only the ICO tokens.
 *   NOTE: There is no approveAndCall/receiveApproval or ERC223 functionality.
 *   NOTE: Coins will never be minted beyond those at contract creation.
 *   NOTE: Zero transfers are allowed - we don't want to break a valid transaction chain.
 *   NOTE: There is no selfDestruct, changeOwner or migration path - this is the only contract.
 */


contract ICOToken is ERC20Interface, HorizonContractBase {
    using SafeMath for uint256;

    // Contract authorization - only allow the official KYC provider to perform certain actions.
    modifier onlyKycProvider {
        require(msg.sender == regulatorApprovedKycProvider, "Only the KYC Provider can call this function.");
        _;
    }
	
	// Contract authorization - only allow the official issuer to perform certain actions.
    modifier onlyIssuer {
        require(msg.sender == issuer, "Only the Issuer can call this function.");
        _;
    }

    // The approved KYC provider that verifies all ICO/TGE Contributors.
    address public regulatorApprovedKycProvider;
    
    // The issuer
    address public issuer;

    // Public identity variables of the token used by ERC20 platforms.
    string public name;
    string public symbol;
    
    // There is no good reason to deviate from 18 decimals, see https://github.com/ethereum/EIPs/issues/724.
    uint8 public decimals = 18;
    
    // The total supply of tokens, set at creation, decreased with burn.
    uint256 public totalSupply_;

    // The supply of tokens, set at creation, to be allocated for the referral bonuses.
    uint256 public rewardPool_;

    // The Initial Coin Offering is finished.
    bool public isIcoComplete;

    // The balances of all accounts.
    mapping (address => uint256) public balances;

    // KYC submission hashes accepted by KYC service provider for AML/KYC review.
    bytes32[] public kycHashes;

    // All users that have passed the external KYC verification checks.
    address[] public kycValidated;

    // Addresses authorized to transfer tokens on an account's behalf.
    mapping (address => mapping (address => uint256)) internal allowanceCollection;

    // Lookup an ICO/TGE Contributor address to see if it was referred by another address (referee => referrer).
    mapping (address => address) public referredBy;

    // Emitted when the Initial Coin Offering phase ends, see closeIco().
    event IcoComplete();

    // Notification when tokens are burned by the owner.
    event Burn(address indexed from, uint256 value);
    
    // Emitted when mint event ocurred
    // added by andrewju
    event Mint(address indexed from, uint256 value);

    // Someone who was referred has purchased tokens, when the bonus is awarded log the details.
    event ReferralRedeemed(address indexed referrer, address indexed referee, uint256 value);

    /**
     * Initialise contract with the 50 million initial supply tokens, allocated to
     * the creator of the contract (the owner).
     */
    constructor(uint256 totalSupply, string memory _name, string memory _symbol, uint256 _rewardPool) public {
		name = _name;
		symbol = _symbol;
        totalSupply_ = totalSupply * 10 ** uint256(decimals);   // Set the total supply of ICO Tokens.
        balances[msg.sender] = totalSupply_;
        rewardPool_ = _rewardPool * 10 ** uint256(decimals);   // Set the total supply of ICO Reward Tokens.
        
        setKycProvider(msg.sender);
        setIssuer(msg.sender);
        
    }

    /**
     * The total number of tokens that exist.
     */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**
     * The total number of reward pool tokens that remains.
     */
    function rewardPool() public onlyOwner view returns (uint256) {
        return rewardPool_;
    }

    /**
     * Get the number of tokens for a specific account.
     *
     * @param who    The address to get the token balance of.
     */
    function balanceOf(address who) public view returns (uint256 balance) {
        return balances[who];
    }

    /**
     * Get the current allowanceCollection that the approver has allowed 'spender' to spend on their behalf.
     *
     * See also: approve() and transferFrom().
     *
     * @param _approver  The account that owns the tokens.
     * @param _spender   The account that can spend the approver's tokens.
     */
    function allowance(address _approver, address _spender) public view returns (uint256) {
        return allowanceCollection[_approver][_spender];
    }

    /**
     * Add the link between the referrer and who they referred.
     *
     * ---- ICO-Platform Note ----
     * The horizon-globex.com ICO platform offers functionality for referrers to sign-up
     * to refer Contributors. Upon such referred Contributions, Company shall automatically
     * award 1% of our "owner" ICO tokens to the referrer as coded by this Smart Contract.
     *
     * All referrers must successfully complete our ICO KYC review prior to being allowed on-board.
     * -- End ICO-Platform Note --
     *
     * @param referrer  The person doing the referring.
     * @param referee   The person that was referred.
     */
    function refer(address referrer, address referee) public onlyOwner {
        require(referrer != address(0x0), "Referrer cannot be null");
        require(referee != address(0x0), "Referee cannot be null");
        require(!isIcoComplete, "Cannot add new referrals after ICO is complete.");

        referredBy[referee] = referrer;
    }

    /**
     * Transfer tokens from the caller's account to the recipient.
     *
     * @param to    The address of the recipient.
     * @param value The number of tokens to send.
     */
    // solhint-disable-next-line no-simple-event-func-name
    function transfer(address to, uint256 value) public returns (bool) {
        return _transfer(msg.sender, to, value);
    }
	
    /**
     * Transfer pre-approved tokens on behalf of an account.
     *
     * See also: approve() and allowance().
     *
     * @param from  The address of the sender
     * @param to    The address of the recipient
     * @param value The number of tokens to send
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(value <= allowanceCollection[from][msg.sender], "Amount to transfer is greater than allowance.");
		
        allowanceCollection[from][msg.sender] = allowanceCollection[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * Allow another address to spend tokens on your behalf.
     *
     * transferFrom can be called multiple times until the approved balance goes to zero.
     * Subsequent calls to this function overwrite the previous balance.
     * To change from a non-zero value to another non-zero value you must first set the
     * allowance to zero - it is best to use safeApprove when doing this as you will
     * manually have to check for transfers to ensure none happened before the zero allowance
     * was set.
     *
     * @param _spender   The address authorized to spend your tokens.
     * @param _value     The maximum amount of tokens they can spend.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        if(allowanceCollection[msg.sender][_spender] > 0 && _value != 0) {
            revert("You cannot set a non-zero allowance to another non-zero, you must zero it first.");
        }

        allowanceCollection[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    /**
     * Allow another address to spend tokens on your behalf while mitigating a double spend.
     *
     * Subsequent calls to this function overwrite the previous balance.
     * The old value must match the current allowance otherwise this call reverts.
     *
     * @param spender   The address authorized to spend your tokens.
     * @param value     The maximum amount of tokens they can spend.
     * @param oldValue  The current allowance for this spender.
     */
    function safeApprove(address spender, uint256 value, uint256 oldValue) public returns (bool) {
        require(spender != address(0x0), "Cannot approve null address.");
        require(oldValue == allowanceCollection[msg.sender][spender], "The expected old value did not match current allowance.");

        allowanceCollection[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);

        return true;
    }

    /**
     * The hash for all Know Your Customer information is calculated outside but stored here.
     * This storage will be cleared once the ICO completes, see closeIco().
     *
     * ---- ICO-Platform Note ----
     * The horizon-globex.com ICO platform's KYC app will register a hash of the Contributors
     * KYC submission on the blockchain. Our Swiss financial-intermediary KYC provider will be 
     * notified of the submission and retrieve the Contributor data for formal review.
     *
     * All Contributors must successfully complete our ICO KYC review prior to being allowed on-board.
     * -- End ICO-Platform Note --
     *
     * @param sha   The hash of the customer data.
    */
    function setKycHash(bytes32 sha) public onlyOwner {
        require(!isIcoComplete, "The ICO phase has ended, you can no longer set KYC hashes.");

        kycHashes.push(sha);
    }

    /**
     * A user has passed KYC verification, store them on the blockchain in the order it happened.
     * This will be cleared once the ICO completes, see closeIco().
     *
     * ---- ICO-Platform Note ----
     * The horizon-globex.com ICO platform's registered KYC provider submits their approval
     * for this Contributor to particpate using the ICO-Platform portal. 
     *
     * Each Contributor will then be sent the Ethereum, Bitcoin and IBAN account numbers to
     * deposit their Approved Contribution in exchange for ICO Tokens.
     * -- End ICO-Platform Note --
     *
     * @param who   The user's address.
     */
    function kycApproved(address who) public onlyKycProvider {
        require(!isIcoComplete, "The ICO phase has ended, you can no longer approve.");
        require(who != address(0x0), "Cannot approve a null address.");

        kycValidated.push(who);
    }

    /**
     * Set the address that has the authority to approve users by KYC.
     *
     * ---- ICO-Platform Note ----
     * The horizon-globex.com ICO platform shall register a fully licensed Swiss KYC
     * provider to assess each potential Contributor for KYC and AML under Swiss law. 
     *
     * -- End ICO-Platform Note --
     *
     * @param who   The address of the KYC provider.
     */
    function setKycProvider(address who) public onlyOwner {
        regulatorApprovedKycProvider = who;
    }
    
        /**
     * Set the issuer address
     *
     * @param who   The address of the issuer.
     */
    function setIssuer(address who) public onlyOwner {
        issuer = who;
    }
    
    
    /**
     * Retrieve the KYC hash from the specified index.
     *
     * @param   index   The index into the array.
     */
    function getKycHash(uint256 index) public view returns (bytes32) {
        return kycHashes[index];
    }

    /**
     * Retrieve the validated KYC address from the specified index.
     *
     * @param   index   The index into the array.
     */
    function getKycApproved(uint256 index) public view returns (address) {
        return kycValidated[index];
    }

    /**
     * When someone referred (the referee) purchases tokens the referrer gets a 1% bonus from the central pool.
     *
     * ---- ICO-Platform Note ----
     * The horizon-globex.com ICO platform's portal shall award referrers as part of the ICO
     * ICO Token issuance procedure as overseen by the Swiss KYC provider. 
     *
     * -- End ICO-Platform Note --
     *
     * @param referee   The referred account who just purchased some tokens.
     * @param referrer  The account that referred the one purchasing tokens.
     * @param value     The number of tokens purchased by the referee.
    */
    function awardReferralBonus(address referee, address referrer, uint256 value) private {
        uint256 bonus = value / 100;
        balances[owner] = balances[owner].sub(bonus);
        balances[referrer] = balances[referrer].add(bonus);
        rewardPool_ -= bonus;
        emit ReferralRedeemed(referee, referrer, bonus);
    }

    /**
     * During the ICO phase the owner will allocate tokens once KYC completes and funds are deposited.
     *
     * ---- ICO-Platform Note ----
     * The horizon-globex.com ICO platform's portal shall issue ICO Token to Contributors on receipt of 
     * the Approved Contribution funds at the KYC providers Escrow account/wallets.
     * Only after ICO Tokens are issued to the Contributor can the Swiss KYC provider allow the transfer
     * of funds from their Escrow to Company.
     *
     * -- End ICO-Platform Note --
     *
     * @param to       The recipient of the tokens.
     * @param value    The number of tokens to send.
     */
    function icoTransfer(address to, uint256 value) public onlyOwner {
        require(!isIcoComplete, "ICO is complete, use transfer().");

        // If an attempt is made to transfer more tokens than owned, transfer the remainder.
        uint256 toTransfer = (value > (balances[msg.sender] - rewardPool_ )) ? (balances[msg.sender] - rewardPool_) : value;
        
        _transfer(msg.sender, to, toTransfer);

        // Handle a referred account receiving tokens.
        address referrer = referredBy[to];
        if(referrer != address(0x0)) {
            referredBy[to] = address(0x0);
            awardReferralBonus(to, referrer, toTransfer);
        }
    }

    /**
     * End the ICO phase in accordance with KYC procedures and clean up.
     *
     * ---- ICO-Platform Note ----
     * The horizon-globex.com ICO platform's portal shall halt the ICO at the end of the 
     * Contribution Period, as defined in the ICO Terms and Conditions at timelessluxurygroup.com.
     *
     * -- End ICO-Platform Note --
     */
    function closeIco() public onlyOwner {
        require(!isIcoComplete, "The ICO phase has already ended, you cannot close it again.");
        require((balances[owner] - rewardPool_) == 0, "Cannot close ICO when a balance remains in the owner account.");

        isIcoComplete = true;
        delete kycHashes;
        delete kycValidated;

        emit IcoComplete();
    }
	
    /**
     * Internal transfer, can only be called by this contract
     *
     * @param from     The sender of the tokens.
     * @param to       The recipient of the tokens.
     * @param value    The number of tokens to send.
     */
    function _transfer(address from, address to, uint256 value) internal returns (bool) {
        require(from != address(0x0), "Cannot send tokens from null address");
        require(to != address(0x0), "Cannot transfer tokens to null");
        require(balances[from] >= value, "Insufficient funds");

        // Quick exit for zero, but allow it in case this transfer is part of a chain.
        if(value == 0)
            return true;
		
        // Perform the transfer.
        balances[from] = balances[from].sub(value);
        balances[to] = balances[to].add(value);
		
        // Any tokens sent to to owner are implicitly burned.
        if (to == owner) {
            _burn(to, value);
        }

        return true;
    }
    
    /**
     * Permanently mint tokens to increase the totalSupply_.
     *
     * @param value            The number of tokens to mint.
     */
    function mint(uint256 value) public onlyIssuer {
        require(value > 0, "Tokens to mint must be greater than zero");
        balances[owner] = balances[owner].add(value);
        totalSupply_ = totalSupply_.add(value);
        
        emit Mint(msg.sender, value);
        
    }
    
    /**
     * Permanently destroy tokens from totalSupply_.
     *
     * @param value            The number of tokens to burn.
     */
    function burn(uint256 value) public onlyIssuer {
        _burn(owner, value);
    }

    /**
     * Permanently destroy tokens belonging to a user.
     *
     * @param addressToBurn    The owner of the tokens to burn.
     * @param value            The number of tokens to burn.
     */
    function _burn(address addressToBurn, uint256 value) private returns (bool success) {
        require(value > 0, "Tokens to burn must be greater than zero");
        require(balances[addressToBurn] >= value, "Tokens to burn exceeds balance");

        balances[addressToBurn] = balances[addressToBurn].sub(value);
        totalSupply_ = totalSupply_.sub(value);

        emit Burn(msg.sender, value);

        return true;
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 *
 * Source: https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol
 */
library SafeMath {
    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
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
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

// ----------------------------------------------------------------------------
// TradeToken Standard #20 Interface
// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/ERC20/ERC20.sol
// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/ERC20/ERC20Basic.sol
// 
// ----------------------------------------------------------------------------
interface TokenInterface {
    function hold(address who, uint256 quantity) external returns(bool);
}

/**
 * A version of the Regulation D contract (https://www.investopedia.com/terms/r/regulationd.asp) with the
 * added role of Transfer Agent to perform specialised actions.
 *
 * Part of the timelessluxurygroup.com ICO by Horizon-Globex.com of Switzerland.
 *
 * Author: Horizon Globex GmbH Development Team
 */
contract RegD is HorizonContractBase {
    using SafeMath for uint256;

    /**
     * The details of the tokens bought.
     */
    struct Holding {
        // The number of tokens purchased.
        uint256 quantity;

        // The date and time when the tokens are no longer restricted.
        uint256 releaseDate;

        // Whether the holder is an affiliate of the company or not.
        bool isAffiliate;
    }

    // Restrict functionality to the creator (owner) of the contract - the token issuer.
    modifier onlyIssuer {
        require(msg.sender == owner, "You must be issuer/owner to execute this function.");
        _;
    }

    // Restrict functionaly to the official Transfer Agent.
    modifier onlyTransferAgent {
        require(msg.sender == transferAgent, "You must be the Transfer Agent to execute this function.");
        _;
    }

    // The collection of all held tokens by user.
    mapping(address => Holding) public heldTokens;

    // The ICO contract, where all tokens this contract holds originate from.
    address public icoContract;

    // The ERC20 Token contract where tokens past their holding period are released to.
    address public tokenContract;

    // The authorised Transfer Agent who performs specialist actions on this contract.
    address public transferAgent;

    // Number of seconds a holding is held for before it can be released.
    uint256 public expiry = 0;

    // Emitted when someone subject to Regulation D buys tokens and they are held here.
    event TokensHeld(address indexed who, uint256 tokens, uint256 releaseDate);

    // Emitted when the tokens have passed their release date and have been returned to the original owner.
    event TokensReleased(address indexed who, uint256 tokens);

    // The Transfer Agent moved tokens from an address to a new wallet, for escheatment obligations.
    event TokensTransferred(address indexed from, address indexed to, uint256 tokens);

    // The Transfer Agent was unable to verify a token holder and needed to push out the release date.
    event ReleaseDateChanged(address who, uint256 oldReleaseDate, uint256 newReleaseDate);

    // Extra restrictions apply to company affiliates, notify when the status of an address changes.
    event AffiliateStatusChanged(address who, bool isAffiliate);

    /**
     * @notice Create this contract and assign the ICO contract where the tokens originate from.
     *
     * @param icoContract_      The address of the ICO contract.
     * @param expiry_           The number of seconds after holding before the tokens can be released.
     */
    constructor(address icoContract_, uint256 expiry_) public {
        icoContract = icoContract_;
        expiry = expiry_;
    }

    /**
     * @notice Set the address of the contract where tokens are released to after the holding period.
     *
     * @param tokenContract_    The contract address.
     */
    function setTokenContract(address tokenContract_) public onlyIssuer {
        tokenContract = tokenContract_;
    }

    /**
     * @notice Set the address of the Transfer Agent.
     *
     * @param who   The wallet id of the Transfer Agent.
     */
    function setTransferAgent(address who) public onlyIssuer {
        transferAgent = who;
    }

    /**
     * @notice Change the expiry for subsequent holdings, existing holdings are not affected.
     *
     * @param expiry_   The number of seconds after holding before the tokens can be released.
     */
    function setExpiry(uint256 expiry_) public onlyIssuer {
        expiry = expiry_;
    }

    /**
     * @notice Keep a US Citizen's tokens for one year.
     *
     * @param who           The wallet of the US Citizen.
     * @param quantity      The number of tokens to store.
     */
    function hold(address who, uint256 quantity) public onlyIssuer {
        require(who != address(0x0), "The null address cannot own tokens.");
        require(quantity != 0, "Quantity must be greater than zero.");
        require(!isExistingHolding(who), "Cannot overwrite an existing holding, use a new wallet.");

        // Create the holding for the customer who will get these tokens once custody ends.
        Holding memory holding = Holding(quantity, block.timestamp+expiry, false);
        heldTokens[who] = holding;
        emit TokensHeld(who, holding.quantity, holding.releaseDate);
    }
	
    /**
     * @notice Hold tokens post-ICO with a variable release date on those tokens.
     *
     * @param who           The wallet of the US Citizen.
     * @param quantity      The number of tokens to store.
	 * @param addedTime		The number of seconds to add to the current date to calculate the release date.
     */
    function postIcoHold(address who, uint256 quantity, uint256 addedTime) public onlyTransferAgent {
        require(who != address(0x0), "The null address cannot own tokens.");
        require(quantity != 0, "Quantity must be greater than zero.");
        require(!isExistingHolding(who), "Cannot overwrite an existing holding, use a new wallet.");

        bool res = ERC20Interface(icoContract).transferFrom(who, address(this), quantity);
        require(res, "Unable to complete Post-ICO Custody, token contract transfer failed.");
        if(res) {
            Holding memory holding = Holding(quantity, block.timestamp+addedTime, false);
            heldTokens[who] = holding;
            emit TokensHeld(who, holding.quantity, holding.releaseDate);
        }
    }

    /**
    * @notice Check if a user's holding are eligible for release.
    *
    * @param who        The user to check the holding of.
    * @return           True if can be released, false if not.
    */
    function canRelease(address who) public view returns (bool) {
        Holding memory holding = heldTokens[who];
        if(holding.releaseDate == 0 || holding.quantity == 0)
            return false;

        return block.timestamp > holding.releaseDate;
    }

    /**
     * @notice Release the tokens once the holding period expires, transferring them back to the ERC20 contract to the holder.
     *
     * NOTE: This function preserves the isAffiliate flag of the holder.
     *
     * @param who       The owner of the tokens.
     * @return          True on successful release, false on error.
     */
    function release(address who) public onlyTransferAgent returns (bool) {
        require(tokenContract != address(0x0), "ERC20 Token contract is null, nowhere to release to.");
        Holding memory holding = heldTokens[who];
        require(!holding.isAffiliate, "To release tokens for an affiliate use partialRelease().");

        if(block.timestamp > holding.releaseDate) {
            // Transfer the tokens from this contract's ownership to the original owner.
            bool res = TokenInterface(tokenContract).hold(who, holding.quantity);
            if(res) {
                heldTokens[who] = Holding(0, 0, holding.isAffiliate);
                emit TokensReleased(who, holding.quantity);
                return true;
            }
        }

        return false;
    }
	
    /**
     * @notice Release some of an affiliate's tokens to a broker/trading wallet.
     *
     * @param who       		The owner of the tokens.
	 * @param tradingWallet		The broker/trader receiving the tokens.
	 * @param amount 			The number of tokens to release to the trading wallet.
     */
    function partialRelease(address who, address tradingWallet, uint256 amount) public onlyTransferAgent returns (bool) {
        require(tokenContract != address(0x0), "ERC20 Token contract is null, nowhere to release to.");
        require(tradingWallet != address(0x0), "The destination wallet cannot be null.");
        require(!isExistingHolding(tradingWallet), "The destination wallet must be a new fresh wallet.");
        Holding memory holding = heldTokens[who];
        require(holding.isAffiliate, "Only affiliates can use this function; use release() for non-affiliates.");
        require(amount <= holding.quantity, "The holding has less than the specified amount of tokens.");

        if(block.timestamp > holding.releaseDate) {

            // Send the tokens currently held by this contract on behalf of 'who' to the nominated wallet.
            bool res = TokenInterface(tokenContract).hold(tradingWallet, amount);
            if(res) {
                heldTokens[who] = Holding(holding.quantity.sub(amount), holding.releaseDate, holding.isAffiliate);
                emit TokensReleased(who, amount);
                return true;
            }
        }

        return false;
    }

    /**
     * @notice Under special circumstances the Transfer Agent needs to move tokens around.
     *
     * @dev As the release date is accurate to one second it is very unlikely release dates will
     * match so an address that does not have a holding in this contract is required as the target.
     *
     * @param from      The current holder of the tokens.
     * @param to        The recipient of the tokens - must be a 'clean' address.
     * @param amount    The number of tokens to move.
     */
    function transfer(address from, address to, uint256 amount) public onlyTransferAgent returns (bool) {
        require(to != address(0x0), "Cannot transfer tokens to the null address.");
        require(amount > 0, "Cannot transfer zero tokens.");
        Holding memory fromHolding = heldTokens[from];
        require(fromHolding.quantity >= amount, "Not enough tokens to perform the transfer.");
        require(!isExistingHolding(to), "Cannot overwrite an existing holding, use a new wallet.");

        heldTokens[from] = Holding(fromHolding.quantity.sub(amount), fromHolding.releaseDate, fromHolding.isAffiliate);
        heldTokens[to] = Holding(amount, fromHolding.releaseDate, false);

        emit TokensTransferred(from, to, amount);

        return true;
    }

    /**
     * @notice The Transfer Agent may need to add time to the release date if they are unable to verify
     * the holder in a timely manner.
     *
     * @param who       The holder of the tokens.
     * @param tSeconds    The number of seconds to add to the release date.  NOTE: 'tSeconds' appears to
     *                  be a reserved word.
     */
    function addTime(address who, int tSeconds) public onlyTransferAgent returns (bool) {
        require(tSeconds != 0, "Time added cannot be zero.");
        
        Holding memory holding = heldTokens[who];
        uint256 oldDate = holding.releaseDate;
        uint256 newDate = tSeconds < 0 ? holding.releaseDate.sub(uint(-tSeconds)) : holding.releaseDate.add(uint(tSeconds));
        heldTokens[who] = Holding(holding.quantity, newDate, holding.isAffiliate);
        
        emit ReleaseDateChanged(who, oldDate, heldTokens[who].releaseDate);
        return true;
    }

    /**
     * @notice Company affiliates have added restriction, allow the Transfer Agent set/clear this flag
     * as needed.
     *
     * @param who           The address being affiliated/unaffiliated.
     * @param isAffiliate   Whether the address is an affiliate or not.
     */
    function setAffiliate(address who, bool isAffiliate) public onlyTransferAgent returns (bool) {
        require(who != address(0x0), "The null address cannot be used.");

        Holding memory holding = heldTokens[who];
        require(holding.isAffiliate != isAffiliate, "Attempt to set the same affiliate status that is already set.");

        heldTokens[who] = Holding(holding.quantity, holding.releaseDate, isAffiliate);

        emit AffiliateStatusChanged(who, isAffiliate);

        return true;
    }

    /**
     * @notice Check if a wallet is already in use, only new/fresh/clean wallets can hold tokens.
     *
     * @param who   The wallet to check.
     * @return      True if the wallet is in use, false otherwise.
     */
    function isExistingHolding(address who) public view returns (bool) {
        Holding memory h = heldTokens[who];
        return (h.quantity != 0 || h.releaseDate != 0);
    }
}