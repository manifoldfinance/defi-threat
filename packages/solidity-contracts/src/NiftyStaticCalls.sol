/**
 * Source Code first verified at https://etherscan.io on Monday, April 29, 2019
 (UTC) */

pragma solidity ^0.5.4;

contract NiftyStaticCalls {
    
    function retAdd() external view returns(address) {
        return(msg.sender);
    }
    
       /**
   * Recovery function for signature - taken from OpenZeppelin
   * https://github.com/OpenZeppelin/openzeppelin-solidity/blob/9e1da49f235476290d5433dac6807500e18c7251/contracts/ECRecovery.sol
   * @dev Recover signer address from a message by using their signature
   * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
   * @param sig bytes signature, the signature is generated using web3.eth.sign()
   */
  function recover(bytes32 hash, bytes memory sig) internal pure returns (address) {
    bytes32 r;
    bytes32 s;
    uint8 v;

    //Check the signature length
    if (sig.length != 65) {
      return (address(0));
    }

    // Divide the signature in r, s and v variables
    // ecrecover takes the signature parameters, and the only way to get them
    // currently is to use assembly.
    // solium-disable-next-line security/no-inline-assembly
    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := byte(0, mload(add(sig, 96)))
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

    
        /** Functions to validate signatures so wallet can sign messages
     * @dev Two functions - isValidSignature(bytes,bytes) and isValidSignature(bytes32,bytes)
     * @dev isValidSignature(bytes,bytes) conforms to ERC1271 - https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1271.md
     * @dev This means it returns the magic value 0x20c13b0b
     * @dev isValidSignature(bytes32,bytes) conforms to - https://github.com/0xProject/0x-monorepo/blob/development/contracts/exchange/contracts/examples/Wallet.sol#L45
     */ 
    
        /// @dev Validates a signature.
    ///      The signer must match the owner of this wallet.
    /// @param hash Message hash that is signed.
    /// @param signature Proof of signing.
    /// @return Validity of signature as bool
    /// @dev To ensure a signature from one Nifty Wallet can't be used for another,
    /// @dev Data signed is concantenated with the wallets address
    function isValidSignature(
        bytes32 hash,
        bytes calldata signature
    )
        external
        view
        returns (bool isValid)
    {
        require(
            signature.length == 65,
            "LENGTH_65_REQUIRED"
        );
        
        bytes memory newData = abi.encodePacked(msg.sender, hash);
        bytes32 newDataHash = keccak256(newData);
        
        address recoveredAddress = recover(newDataHash, signature);
        NiftyWalletContract NW_instance = NiftyWalletContract(msg.sender);
        address WALLET_OWNER = NW_instance.returnUserAccountAddress();
        isValid = WALLET_OWNER == recoveredAddress;
        return isValid;
    }
    
    bytes4 internal MAGICVALUE = 0x20c13b0b;
    
        /// @dev Validates a signature.
    ///      The signer must match the owner of this wallet.
    /// @param _data Data that is signed.
    /// @param signature Proof of signing.
    /// @return Validity of signature as bytes4
    /// @dev To ensure a signature from one Nifty Wallet can't be used for another,
    /// @dev Data signed is concantenated with the wallets address
    function isValidSignature(
        bytes calldata _data,
        bytes calldata signature
    )
        external
        view
      returns (bytes4 magicValue)
    {
        require(
            signature.length == 65,
            "LENGTH_65_REQUIRED"
        );
        
        bytes32 dataHash = keccak256(_data);
        bytes memory newData = abi.encodePacked(msg.sender, dataHash);
        bytes32 newDataHash = keccak256(newData);
        
        address recoveredAddress = recover(newDataHash, signature);
        NiftyWalletContract NW_instance = NiftyWalletContract(msg.sender);
        address WALLET_OWNER = NW_instance.returnUserAccountAddress();
        if (WALLET_OWNER == recoveredAddress) {
            return MAGICVALUE;
        } else {
            return (0xdeadbeef);
        }
    }

    /**
     * @dev Safe receiver functions
    */
    
    /** ERC721 receiver function 
     * From OpenZeppelin - https://github.com/OpenZeppelin/openzeppelin-solidity/blob/v1.12.0/contracts/token/ERC721/ERC721Receiver.sol
     * Nifty Wallets will always receive an ERC721
     */
    
    bytes4 internal constant ERC721_RECEIVED = 0x150b7a02;
    
    function onERC721Received(address, address, uint256, bytes memory) public returns (bytes4) {
        return (ERC721_RECEIVED);
    }

    /** Safe ERC1155 receiver
    * Nifty Wallets will always receive ERC1155s as well
    * We like all tokens
    * From Horizon Games - https://github.com/horizon-games/multi-token-standard
    */
    bytes4 constant public ERC1155_RECEIVED_SIG = 0xf23a6e61;
      bytes4 constant public ERC1155_BATCH_RECEIVED_SIG = 0xbc197c81;
      bytes4 constant public ERC1155_RECEIVED_INVALID = 0xdeadbeef;

      bytes public lastData;
      address public lastOperator;
      uint256 public lastId;
      uint256 public lastValue;

      /**
      * @notice Handle the receipt of a single ERC1155 token type.
      * @dev An ERC1155-compliant smart contract MUST call this function on the token recipient contract, at the end of a `safeTransferFrom` after the balance has been updated.
      * This function MAY throw to revert and reject the transfer.
      * Return of other than the magic value MUST result in the transaction being reverted.
      * Note: The contract address is always the message sender.
      * @param _operator  The address which called the `safeTransferFrom` function
      * @param _from      The address which previously owned the token
      * @param _id        The id of the token being transferred
      * @param _value     The amount of tokens being transferred
      * @param _data      Additional data with no specified format
      * @return           `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
      */
      function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data )
        external view returns(bytes4)
      {
          return ERC1155_RECEIVED_SIG;
      }

      /**
      * @notice Handle the receipt of multiple ERC1155 token types.
      * @dev An ERC1155-compliant smart contract MUST call this function on the token recipient contract, at the end of a `safeBatchTransferFrom` after the balances have been updated.
      * This function MAY throw to revert and reject the transfer.
      * Return of other than the magic value WILL result in the transaction being reverted.
      * Note: The contract address is always the message sender.
      * @param _operator  The address which called the `safeBatchTransferFrom` function
      * @param _from      The address which previously owned the token
      * @param _ids       An array containing ids of each token being transferred
      * @param _values    An array containing amounts of each token being transferred
      * @param _data      Additional data with no specified format
      * @return           `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
      */
      function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data)
        external view returns(bytes4)
      {
          return ERC1155_BATCH_RECEIVED_SIG;
      }
}

contract NiftyWalletContract {
    function returnWalletTxCount() public view returns (uint);
    function returnUserAccountAddress() public view returns (address);
}