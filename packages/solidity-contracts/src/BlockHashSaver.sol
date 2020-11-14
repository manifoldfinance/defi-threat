/**
 * Source Code first verified at https://etherscan.io on Thursday, May 2, 2019
 (UTC) */

contract BlockHashSaver {
    bytes32 public currentHash;
    bytes32 public prevHash;
    
    function saveHash() public {
        currentHash = blockhash(block.number);
        prevHash = blockhash(block.number - 1);
    }
}