/**
 * Source Code first verified at https://etherscan.io on Sunday, March 24, 2019
 (UTC) */

pragma solidity 0.5.3;
interface erc20token {
    function transfer(address _to, uint256 _amount) external returns (bool);
    function balanceOf(address _p) external returns (uint256);
    function decimals() external returns (uint256);
}
contract dapMerkle {
    
    /* variables */
    bytes32 public root;
    erc20token public token;
    address payable owner;
    uint256 public amountSent;
    
    /* storage */
    mapping (address => bool) public sent;
    
    /* events */
    event tokensSent(address to, uint256 amount);
    event rootChanged(bytes32 root);
    
    /* modifiers */
    modifier onlyOwner(){
        if (msg.sender == owner){
            _;
        }
    }
    constructor (address _token, bytes32 _merkleRoot) public{
        owner = msg.sender;
        root = _merkleRoot;
        token = erc20token(_token);
    }
    function setRoot(bytes32 _root) external onlyOwner {
        root = _root;
        emit rootChanged(_root);
    }
    
    function getTokenBalance() external returns (uint256){
        return token.balanceOf(address(this));
    }
    
    function abortAirdrop() onlyOwner external{
        require(token.balanceOf(address(this)) > 0);
        assert( token.transfer(owner, token.balanceOf( address(this) ) ) );
        selfdestruct(owner);
    }
    function getTokens(bytes32[] calldata _proof, address _receiver, uint256 _amount) external returns (bool){
        require (!sent[_receiver]);
        require (_amount > 0);
        require( verify(_proof, makeLeaf(_receiver, _amount)) );
        uint256 decimals = token.decimals();
        uint256 amount = _amount*(10**decimals);
        sent[_receiver] = true;
        assert(token.transfer(_receiver, amount));
        amountSent += _amount;
        emit tokensSent(_receiver, _amount);
        return true;
        
    }

     function addressToAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            byte b = byte(uint8(uint(x) / (2**(8*(19 - i)))));
            byte hi = byte(uint8(b) / 16);
            byte lo = byte(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);
        }
        return string(s);
    }

    function char(byte b) internal pure returns (byte c) {
        if (b < byte(uint8(10))) return byte(uint8(b) + 0x30);
        else return byte(uint8(b) + 0x57);
    }
    
    function uintToStr(uint i) internal pure returns (string memory){
        if (i == 0) return "0";
        uint j = i;
        uint length;
        while (j != 0){
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint k = length - 1;
        while (i != 0){
            bstr[k--] = byte(uint8(48 + i % 10));
            i /= 10;
        }
        return string(bstr);
    }
    
     function makeLeaf(address _a, uint256 _n) internal pure returns(bytes32) {
        string memory prefix = "0x";
        string memory space = " ";

        
        bytes memory _ba = bytes(prefix);
        bytes memory _bb = bytes(addressToAsciiString(_a));
        bytes memory _bc = bytes(space);
        bytes memory _bd = bytes(uintToStr(_n));
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint8 i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (uint8 i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (uint8 i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (uint8 i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];

        return keccak256(babcde);
    }
    function verify(bytes32[] memory proof, bytes32 leaf) internal view returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash < proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        // Check if the computed hash (root) is equal to the provided root
        return computedHash == root;
    }
    function makeString(address _a, uint256 _n) external pure returns(bytes memory){
        string memory prefix = "0x";
        string memory space = " ";

        
        bytes memory _ba = bytes(prefix);
        bytes memory _bb = bytes(addressToAsciiString(_a));
        bytes memory _bc = bytes(space);
        bytes memory _bd = bytes(uintToStr(_n));
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint8 i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (uint8 i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (uint8 i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (uint8 i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];

        return babcde;
    }
}