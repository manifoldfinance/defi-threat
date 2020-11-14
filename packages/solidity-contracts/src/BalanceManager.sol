/**
 * Source Code first verified at https://etherscan.io on Friday, April 26, 2019
 (UTC) */

pragma solidity ^0.4.25;


/**
 *  @title ERC223 Interface of the Bether Token currently deployed on the Ethereum main net.
 */
contract BetherERC223Interface {
    /** 
     *  @dev The total amount of Bether available
     */
    uint256 public totalSupply;

    /** 
     *  @dev Provides access to check how much Bether the _owner allowed the _spender to use.
     *  @param _owner Address that owns the Bether.
     *  @param _spender Address that wants to transfer the _owner's Bether.
     *  @return remaining The amount of Bether that _owner allowed _spender to transfer (in Wei).
     */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    /** 
     *  @dev Allows the Bether holder to authorize _spender to transfer the holder's Bether (in Wei).
     *  @param _spender The address that will be allowed to transfer _value amount of the holders Bether.
     *  @param _value The amount of Bether that _spender is allowed to transfer on behalf of the holder.
     *  @return _approved Whether the approval was successful or not.
     */
    function approve(address _spender, uint256 _value) public returns (bool _approved);

    /** 
     *  @dev Checks the amount of Bether the _address holds.
     *  @param _address The address the balance of which is to be checked.
     *  @return balance The Bether balance of _address (in Wei).
     */
    function balanceOf(address _address) public constant returns (uint256 balance);

    /**
     *  @dev Gets the amount of decimal points Bether supports.
     *  @return _decimals The amount of decimal points Bether supports.
     */
    function decimals() public constant returns (uint8 _decimals);

    /**
     *  @dev Gets the name of the token.
     *  @return _name The name of the token.
     */
    function name() public constant returns (string _name);

    /**
     *  @dev Gets the symbol of the token.
     *  @return _symbol The symbol of the token.
     */
    function symbol() public constant returns (string _symbol);

    /**
     *  @dev Transfers Bether.
     *  @param _to The target address to which Bether will be sent from the caller.
     *  @param _value The amount of Bether to send (in Wei).
     *  @return _sent Whether the transfer was successful or not.
     */
    function transfer(address _to, uint256 _value) public returns (bool _sent);

    /**
     *  @dev Transfers Bether.
     *  @param _to The target address to which Bether will be sent from the caller.
     *  @param _value The amount of Bether to send (in Wei).
     *  @param _data TODO: What is this?
     *  @return _sent Whether the transfer was successful or not.
     */
    function transfer(address _to, uint256 _value, bytes _data) public returns (bool _sent);

    /**
     *  @dev Transfers Bether.
     *  @param _from The address from which Bether will be sent (Requires approval via the approve() method).
     *  @param _to The target address to which Bether will be sent.
     *  @param _value The amount of Bether to send (in Wei).
     *  @return _sent Whether the transfer was successful or not.
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool _sent);
}


 /*
 * Contract that is working with ERC223 tokens. Implementing the tokenFallback function in a way that doesn't throw an error enables
 * the contract to receive ERC223 tokens. Making it an empty function is enough to enable receiving of tokens. The default
 * implementation of tokenFallback ALWAYS throws an error. This is to prevent random contracts from ending up with ERC223
 * tokens but not having the functionality to send them away.
 * https://github.com/ethereum/EIPs/issues/223
 */

/** @title ERC223ReceivingContract - Standard contract implementation for compatibility with ERC223 tokens. */
contract ERC223ReceivingContract {

    /** 
     *  @dev Function that is called when a user or another contract wants to transfer funds.
     *  @param _from Transaction initiator, analogue of msg.sender.
     *  @param _value Number of tokens to transfer.
     *  @param _data Data containig a function signature and/or parameters.
     */
    function tokenFallback(address _from, uint256 _value, bytes _data) public;
}


/**
    The DepositContract only has a single purpose and that is to forward all Bether and Ether
    to the BalanceManager contract, which created it. It serves as an aggregator.
    Every user has one DepositContract, meaning when the funds arrive to the BalanceManager,
    we know which user sent them (it depends on which DepositContract forwarded the funds).
*/
contract DepositContract is ERC223ReceivingContract {

    /** @dev The BalanceManager to which funds will be transfered. */
    BalanceManager public balanceManager;

    /** @dev The Bether token itself. Only this token will be forwarded, others will be aborted. */
    BetherERC223Interface public betherToken;

    /**
        @dev Basic constructor.
        @param balanceManagerAddress The address of the BalanceManager to forward funds to.
        @param betherTokenAddress The address of the token that is to be forwarded.
    */
    constructor(address balanceManagerAddress, address betherTokenAddress) public {
        balanceManager = BalanceManager(balanceManagerAddress);
        betherToken = BetherERC223Interface(betherTokenAddress);
    }

    /**
        @dev Fallback payable function, which forwards all Ether to the BalanceManager.
    */
    function () public payable {
        require(address(balanceManager).send(msg.value));
    }


    /** 
        @dev Function that is called by the ERC223 token contract when tokens are sent to
        this contract.
        @param _value Number of tokens (in wei) that have been sent.
     */
    function tokenFallback(address, uint256 _value, bytes) public {
        require(msg.sender == address(betherToken));
        require(betherToken.transfer(address(balanceManager), _value));
    }
}


/**
    The BalanceManager is a contract that aggregates Bether and Ether that users deposit into our
    platform via DepositContracts. It is also responsible for applying an exchange rate for received
    Ether.
*/
contract BalanceManager is ERC223ReceivingContract {

    /** @dev The BalanceManager to which funds will be transfered. */
    BetherERC223Interface public betherToken;

    /** @dev Current exchange rate (amount of Bether that is given for each Ether) */
    uint256 public betherForEther;

    /** @dev The address of the Admin. The Admin wallet is fully authorized to control this contract */
    address public adminWallet;

    /**
        @dev The Operator wallet has a subset of the privileges of the Admin wallet. It can send Bether
        and change the exchange rate.
    */
    address public operatorWallet;

    /** @dev Basic constructor populates the storage variables.    */
    constructor(address betherTokenAddress, address _adminWallet, address _operatorWallet) public {
        betherToken = BetherERC223Interface(betherTokenAddress);
        adminWallet = _adminWallet;
        operatorWallet = _operatorWallet;
    }



    /***********************************************************************************************************/
    /** Security and Privilege Control *************************************************************************/

    /** @dev Modifier for ensuring only the Admin wallet can call a function. */
    modifier adminLevel {
        require(msg.sender == adminWallet);
        _;
    }

    /** @dev Modifier for ensuring only the Admin and Operator wallets can call a function. */
    modifier operatorLevel {
        require(msg.sender == operatorWallet || msg.sender == adminWallet);
        _;
    }
    
    /** @dev Setter for the Admin wallet. */
    function setAdminWallet(address _adminWallet) public adminLevel {
        adminWallet = _adminWallet;
    }

    /** @dev Setter for the Operator wallet. */
    function setOperatorWallet(address _operatorWallet) public adminLevel {
        operatorWallet = _operatorWallet;
    }



    /***********************************************************************************************************/
    /** Token Receiving and Exchanging *************************************************************************/

    /** @dev Setter for the exchange rate. */
    function setBetherForEther(uint256 _betherForEther) public operatorLevel {
        betherForEther = _betherForEther;
    }

    /** 
        @dev This event is used to track which account deposited how much Bether.
        @param depositContractAddress The address from whence the Bether arrived.
        @param amount The amount of Bether (in wei) that arrived.
    */
    event DepositDetected(address depositContractAddress, uint256 amount);
    
    /**
        @dev Payable callback function. This is triggered when Ether is sent to
        this contract. It applies the exchange rate to the Ether and emits an
        event, logging the deposit.
    */
    function () public payable {
        uint256 etherValue = msg.value;
        require(etherValue > 0);
        uint256 betherValue = etherValue * betherForEther;
        require(betherValue / etherValue == betherForEther);
        emit DepositDetected(msg.sender, betherValue);
    }

    /** 
        @dev Function that is called by the ERC223 token contract when tokens are sent to
        this contract.
        @param _from Transaction initiator, analogue of msg.sender.
        @param _value Number of tokens (in wei) that have been sent.
     */
    function tokenFallback(address _from, uint256 _value, bytes) public {
        require(msg.sender == address(betherToken));
        emit DepositDetected(_from, _value);
    }



    /***********************************************************************************************************/
    /** Token Transfering **************************************************************************************/

    /**
        @dev Function sends 'amount' of Bether (in wei) from this contract to
        the 'target' address.
    */
    function sendBether(address target, uint256 amount) public operatorLevel {
        require(betherToken.transfer(target, amount));
    }

    /**
        @dev Function sends 'amount' of Ether (in wei) from this contract to
        the 'target' address. This function can only be triggered by the Admin
        wallet, since we only support one-way exchange.
    */
    function sendEther(address target, uint256 amount) public adminLevel {
        require(target.send(amount));
    }



    /***********************************************************************************************************/
    /** Deployment of Deposit Contracts ************************************************************************/

    /** @dev This event is used to track down the addresses of newly deployed DepositContracts. */
    event NewDepositContract(address depositContractAddress);

    /**
        @dev Function deploys 'amount' DepositContracts with this contract set as their
        DepositManager.
        @param amount Amount of DepositContracts to Deploy.
    */
    function deployNewDepositContracts(uint256 amount) public {
        for (uint256 i = 0; i < amount; i++) {
            address newContractAddress = new DepositContract(address(this), address(betherToken));
            emit NewDepositContract(newContractAddress);
        }
    }

    /***********************************************************************************************************/
}