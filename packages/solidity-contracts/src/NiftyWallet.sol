/**
 * Source Code first verified at https://etherscan.io on Monday, May 6, 2019
 (UTC) */

pragma solidity ^0.5.4;

contract NiftyWallet {
    
    /**
     * The Nifty Wallet - the niftiest wallet around!
     * Author - Duncan Cock Foster. <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="086c7d666b69664866616e7c716f697c6d7f6971266b6765">[email protected]</a> 
     */ 

    /**
     * Constants 
     * The address of the master contract, and the account ID for this wallet
     * Account ID is used to retrieve the signing private key for this wallet
     */ 

    address masterContractAdd = 0x4CADB4bAd0e2a49CC5D6CE26D8628C8f451dA346;
    uint userAccountID = 0;
    uint walletTxCount = 0;

    /**
    / Events
    */

    event Execution(address indexed destinationAddress, uint value, bytes txData);
    event ExecutionFailure(address indexed destinationAddress, uint value, bytes txData);
    event Deposit(address indexed sender, uint value);

    /**
    * @dev returns signing private key that controls this wallet
    */

    function returnUserAccountAddress() public view returns(address) {
        MasterContract m_c_instance = MasterContract(masterContractAdd);
        return (m_c_instance.returnUserControlAddress(userAccountID));
    }
    
    function returnWalletTxCount() public view returns(uint) {
        return(walletTxCount);
    }
    
    /**
     * Modifier to check msg.sender
     */
     
    modifier onlyValidSender() {
        MasterContract m_c_instance = MasterContract(masterContractAdd);
        require(m_c_instance.returnIsValidSendingKey(msg.sender) == true);
        _;
      }

    /** 
     * Fall back function - get paid and static calls
     */ 

    function()
        payable
        external
    {
        if (msg.value > 0)
            emit Deposit(msg.sender, msg.value);
        else if (msg.data.length > 0) {
            //static call 
            MasterContract m_c_instance = MasterContract(masterContractAdd);
            address loc =  (m_c_instance.returnStaticContractAddress());
                assembly {
                    calldatacopy(0, 0, calldatasize())
                    let result := staticcall(gas, loc, 0, calldatasize(), 0, 0)
                    returndatacopy(0, 0, returndatasize())
                    switch result 
                    case 0 {revert(0, returndatasize())} 
                    default {return (0, returndatasize())}
                }
        }
    }
    
    /**
     * @dev function to call any on chain transaction
     * @dev verifies that the transaction data has been signed by the wallets controlling private key
     * @dev and that the transaction has been sent from an approved sending wallet
     * @param  _signedData bytes - signature of txData + wallet address
     * @param destination address - destination for this transaction
     * @param value uint - value of this transaction
     * @param data bytes - transaction data 
     */ 

    function callTx(bytes memory _signedData,
                     address destination,
                     uint value,
                     bytes memory data)
    public onlyValidSender returns (bool) {
        address userSigningAddress = returnUserAccountAddress();
        MasterContract m_c_instance = MasterContract(masterContractAdd);
        bytes32 dataHash = m_c_instance.returnTxMessageToSign(data, destination, value, walletTxCount);
        address recoveredAddress = m_c_instance.recover(dataHash, _signedData);
        if (recoveredAddress==userSigningAddress) {
            if (external_call(destination, value, data.length, data)) {
                emit Execution(destination, value, data);
                walletTxCount = walletTxCount + 1;
            } else {
                emit ExecutionFailure(destination, value, data);
                walletTxCount = walletTxCount +1;
            }
            return(true);
        } else {
            revert();
        }
    }
    
    /** External call function 
     * Taken from Gnosis Mutli Sig wallet
     * https://github.com/gnosis/MultiSigWallet/blob/master/contracts/MultiSigWallet.sol
     */ 

    // call has been separated into its own function in order to take advantage
    // of the Solidity's code generator to produce a loop that copies tx.data into memory.
    function external_call(address destination, uint value, uint dataLength, bytes memory data) private returns (bool) {
        bool result;
        assembly {
            let x := mload(0x40)   // "Allocate" memory for output (0x40 is where "free memory" pointer is stored by convention)
            let d := add(data, 32) // First 32 bytes are the padded length of data, so exclude that
            result := call(
                sub(gas, 34710),   // 34710 is the value that solidity is currently emitting
                                   // It includes callGas (700) + callVeryLow (3, to pay for SUB) + callValueTransferGas (9000) +
                                   // callNewAccountGas (25000, in case the destination address does not exist and needs creating)
                destination,
                value,
                d,
                dataLength,        // Size of the input (in bytes) - this is what fixes the padding problem
                x,
                0                  // Output is ignored, therefore the output size is zero
            )
        }
        return result;
    }

}

contract MasterContract {
    function returnUserControlAddress(uint account_id) public view returns (address);
    function returnIsValidSendingKey(address sending_key) public view returns (bool);
    function returnStaticContractAddress() public view returns (address);
    function recover(bytes32 hash, bytes memory sig) public pure returns (address);
    function returnTxMessageToSign(bytes memory txData, address des_add, uint value, uint tx_count)
    public view returns(bytes32);
}