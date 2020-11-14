/**
 * Source Code first verified at https://etherscan.io on Friday, March 22, 2019
 (UTC) */

pragma solidity ^0.4.23;


contract LetsBreakThings {
    
    address public creator;
    address public creatorproxy;
    

    // Fallback function
    function deposit() public payable {

    }
    
    // constructor
    constructor(address _proxy) public {
        creator = msg.sender;
        creatorproxy = _proxy;
    }

    
    /// create events to log everything as cheaply as possible instead of by return values
    event txSenderDetails(address sender, address origin);
    event gasDetails(uint remainingGas, uint txGasPrice, uint blockGasLimit);
    event balanceLog(address balanceHolder, uint256 balance);
    event blockDetails(address coinbase, uint difficulty, uint blockNumber, uint timestamp);
    

    // deprecated in version 0.4.22 and replaced by blockhash(uint blockNumber).
    function getBlockHash(uint _blockNumber) public view returns (bytes32 _hash) {
        // blockHash() for later versions
        logBlockDetails();
        logGasDetails();
        logGasDetails();
        logSenderDetails();
        return block.blockhash(_blockNumber);
    }
    
    /// @dev Emits details about the origin of a transaction.
    /// @dev This includes sender and tx origin
    function logSenderDetails() public view {
        emit txSenderDetails(msg.sender, tx.origin);
    }
    
    /// @dev logs the gas, gasprice and block gaslimit
    function logGasDetails() public view {
        emit gasDetails(msg.gas, tx.gasprice, block.gaslimit);
        // gasLeft() in later versions
    }
    
    /// @dev logs the coinbase difficulty number and timestamp for the block
    function logBlockDetails() public view { 
        emit blockDetails(block.coinbase, block.difficulty, block.number, block.timestamp);
    }
    
    /// @dev Test function number 1
    function checkBalanceSendEth(address _recipient) public {
        
        require(creator == msg.sender, "unauthorized");

        /// log balance at the start
        checkBalance(_recipient);
        

        /// transfer recipient smallest unit possible
        /// solium-disable-next-line
        _recipient.transfer(1);

        /// log balance
        checkBalance(_recipient);

        /// send recipient smallest unit possible
        _recipient.send(1);

        /// check final balance
        checkBalance(_recipient);
        
        /// log everything
        logBlockDetails();
        logGasDetails();
        logGasDetails();
        logSenderDetails();
        
        
    
    }
    
    /// @dev internal function to check balance for an address and emit log event
    function checkBalance(address _target) internal returns (uint256) {
        uint256 balance = address(_target).balance;
        emit balanceLog(_target, balance);
        return balance;
    }
    
    
    /// @dev lets verify some block hashes against each other on chain
    function verifyBlockHash(string memory _hash, uint _blockNumber) public returns (bytes32, bytes32) {
        bytes32 hash1 = keccak256(_hash);
        bytes32 hash2 = getBlockHash(_blockNumber);
        return(hash1, hash2) ;
    }
    
}

/// @dev now lets try this via a proxy

/// @dev creator proxy calls the target function
/// @dev same test, same tx.origin, different msg.sender
contract creatorProxy {
    function proxyCall(address _target, address _contract) public {
        LetsBreakThings(_contract).checkBalanceSendEth(_target);
    }
}