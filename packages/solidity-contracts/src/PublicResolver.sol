/**
 * Source Code first verified at https://etherscan.io on Wednesday, April 17, 2019
 (UTC) */

// File: contracts/ens/AbstractENS.sol

pragma solidity ^0.5.0;

contract AbstractENS {
    function owner(bytes32 _node) public view returns(address);
    function resolver(bytes32 _node) public view returns(address);
    function ttl(bytes32 _node) public view returns(uint64);
    function setOwner(bytes32 _node, address _owner) public;
    function setSubnodeOwner(bytes32 _node, bytes32 _label, address _owner) public;
    function setResolver(bytes32 _node, address _resolver) public;
    function setTTL(bytes32 _node, uint64 _ttl) public;

    // Logged when the owner of a node assigns a new owner to a subnode.
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    // Logged when the owner of a node transfers ownership to a new account.
    event Transfer(bytes32 indexed node, address owner);

    // Logged when the resolver for a node changes.
    event NewResolver(bytes32 indexed node, address resolver);

    // Logged when the TTL of a node changes
    event NewTTL(bytes32 indexed node, uint64 ttl);
}

// File: contracts/ens/PublicResolver.sol

pragma solidity ^0.5.0;


/**
 * A simple resolver anyone can use; only allows the owner of a node to set its
 * address.
 */
contract PublicResolver {
    AbstractENS ens;
    mapping(bytes32=>address) addresses;
    mapping(bytes32=>bytes32) hashes;

    modifier only_owner(bytes32 _node) {
        require(ens.owner(_node) == msg.sender);
        _;
    }

    /**
     * Constructor.
     * @param _ensAddr The ENS registrar contract.
     */
    constructor(AbstractENS _ensAddr) public {
        ens = _ensAddr;
    }

    /**
     * Returns true if the specified node has the specified record type.
     * @param _node The ENS node to query.
     * @param _kind The record type name, as specified in EIP137.
     * @return True if this resolver has a record of the provided type on the
     *         provided node.
     */
    function has(bytes32 _node, bytes32 _kind) public view returns (bool) {
        return (_kind == "addr" && addresses[_node] != address(0)) || (_kind == "hash" && hashes[_node] != 0);
    }

    /**
     * Returns true if the resolver implements the interface specified by the provided hash.
     * @param _interfaceID The ID of the interface to check for.
     * @return True if the contract implements the requested interface.
     */
    function supportsInterface(bytes4 _interfaceID) public pure returns (bool) {
        return _interfaceID == 0x3b3b57de || _interfaceID == 0xd8389dc5;
    }

    /**
     * Returns the address associated with an ENS node.
     * @param _node The ENS node to query.
     * @return The associated address.
     */
    function addr(bytes32 _node) public view returns (address ret) {
        ret = addresses[_node];
    }

    /**
     * Sets the address associated with an ENS node.
     * May only be called by the owner of that node in the ENS registry.
     * @param _node The node to update.
     * @param _addr The address to set.
     */
    function setAddr(bytes32 _node, address _addr) public only_owner(_node) {
        addresses[_node] = _addr;
    }

    /**
     * Returns the content hash associated with an ENS node.
     * Note that this resource type is not standardized, and will likely change
     * in future to a resource type based on multihash.
     * @param _node The ENS node to query.
     * @return The associated content hash.
     */
    function content(bytes32 _node) public view returns (bytes32 ret) {
        ret = hashes[_node];
    }

    /**
     * Sets the content hash associated with an ENS node.
     * May only be called by the owner of that node in the ENS registry.
     * Note that this resource type is not standardized, and will likely change
     * in future to a resource type based on multihash.
     * @param _node The node to update.
     * @param _hash The content hash to set
     */
    function setContent(bytes32 _node, bytes32 _hash) public only_owner(_node) {
        hashes[_node] = _hash;
    }
}