/**
 * Source Code first verified at https://etherscan.io on Monday, April 15, 2019
 (UTC) */

pragma solidity 0.5.7;
// produced by the Solididy File Flattener (c) David Appleton 2018
// contact : <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a3c7c2d5c6e3c2c8cccec1c28dc0ccce">[email protected]</a>
// released under Apache 2.0 licence
// input  /Users/rmanzoku/src/github.com/doublejumptokyo/mch-experimental/contracts/MetaMarking.sol
// flattened :  Friday, 12-Apr-19 07:50:40 UTC
library ECDSA {
    /**
     * @dev Recover signer address from a message by using their signature
     * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
     * @param signature bytes signature, the signature is generated using web3.eth.sign()
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        // If the signature is valid (and not malleable), return the signer address
        return ecrecover(hash, v, r, s);
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

contract OperatorRole {
    using Roles for Roles.Role;

    event OperatorAdded(address indexed account);
    event OperatorRemoved(address indexed account);

    Roles.Role private operators;

    constructor() public {
        operators.add(msg.sender);
    }

    modifier onlyOperator() {
        require(isOperator(msg.sender));
        _;
    }
    
    function isOperator(address account) public view returns (bool) {
        return operators.has(account);
    }

    function addOperator(address account) public onlyOperator() {
        operators.add(account);
        emit OperatorAdded(account);
    }

    function removeOperator(address account) public onlyOperator() {
        operators.remove(account);
        emit OperatorRemoved(account);
    }

}
contract MCHMetaMarking is OperatorRole {

  mapping(address => uint256) public nonces;

  struct Mark {
    bool isExist;
    int64 markAt;
    uint32 uid;
    int64 primeUntil;
    uint8 landType;
  }

  event Marking(
             address indexed from,
             int64 markAt,
             uint32 uid,
             int64 primeUntil,
             uint8 landType
             );

  mapping(uint8 => address[]) public addressesByLandType;
  mapping(address => Mark) public latestMarkByAddress;

  constructor() public {
    addOperator(address(0x51C36baAa8b0e6CF45e2E1A77E84E3c0D1713F97));
  }

  function encodeData(address _from, int64 _markAt, uint32 _uid, int64 _primeUntil,
                      uint8 _landType, uint256 _nonce, address _relayer) public view returns (bytes32) {
    return keccak256(abi.encode(
                                      address(this),
                                      _from,
                                      _markAt,
                                      _uid,
                                      _primeUntil,
                                      _landType,
                                      _nonce,
                                      _relayer
                                      )
                     );
  }

  function ethSignedMessageHash(bytes32 _data) public pure returns (bytes32) {
    return ECDSA.toEthSignedMessageHash(_data);
  }

  function recover(bytes32 _data, bytes memory _sig) public pure returns (address) {
    bytes32 data = ECDSA.toEthSignedMessageHash(_data);
    return ECDSA.recover(data, _sig);
  }

  function executeMarkMetaTx(address _from, int64 _markAt, uint32 _uid, int64 _primeUntil,
                             uint8 _landType, uint256 _nonce, bytes calldata _sig) external onlyOperator() {
    require(nonces[_from]+1 == _nonce, "nonces[_from]+1 != _nonce");
    bytes32 encodedData = encodeData(_from, _markAt, _uid, _primeUntil, _landType, _nonce, msg.sender);
    address signer = recover(encodedData, _sig);
    require(signer == _from, "signer != _from");

    _mark(_from, _markAt, _uid, _primeUntil, _landType);
    nonces[_from]++;
  }

  function forceMark(address _user, int64 _markAt, uint32 _uid, int64 _primeUntil, uint8 _landType) external onlyOperator() {
    _mark(_user, _markAt, _uid, _primeUntil, _landType);
  }

  function _mark(address _user, int64 _markAt, uint32 _uid, int64 _primeUntil, uint8 _landType) private {

    if (!latestMarkByAddress[_user].isExist) {
      latestMarkByAddress[_user] = Mark(
                                        true,
                                        _markAt,
                                        _uid,
                                        _primeUntil,
                                        _landType
                                        );
      addressesByLandType[_landType].push(_user);
      return;
    }

    uint8 currentLandType = latestMarkByAddress[_user].landType;
    if (currentLandType != _landType) {
      uint256 i;
      for (i = 0; i < addressesByLandType[_landType].length; i++) {
	if (addressesByLandType[_landType][i] != _user) {
	  break;
	}
      }

      delete addressesByLandType[currentLandType][i];
      addressesByLandType[_landType].push(_user);
    }

    latestMarkByAddress[_user].markAt = _markAt;
    latestMarkByAddress[_user].uid = _uid;
    latestMarkByAddress[_user].primeUntil = _primeUntil;
    latestMarkByAddress[_user].landType = _landType;

    emit Marking(_user, _markAt, _uid, _primeUntil, _landType);
  }

  function getAddressesByLandType(uint8 _landType, int64 _validSince) public view returns (address[] memory){
    if (addressesByLandType[_landType].length == 0) {
      return new address[](0);
    }

    uint256 cnt;
    for (uint256 i = 0; i < addressesByLandType[_landType].length; i++) {
      address addr = addressesByLandType[_landType][i];
      if (addr == address(0x0)) {
        continue;
      }

      if (latestMarkByAddress[addr].markAt >= _validSince) {
        cnt++;
      }
    }

    address[] memory ret = new address[](cnt);
    uint256 idx = 0;
    for (uint256 i = 0; i < addressesByLandType[_landType].length; i++) {
      address addr = addressesByLandType[_landType][i];
      if (addr == address(0x0)) {
        continue;
      }

      if (latestMarkByAddress[addr].markAt >= _validSince) {
        ret[idx] = addr;
        idx++;
      }
    }

    return ret;
  }

  function meta_nonce(address _from) external view returns (uint256 nonce) {
    return nonces[_from];
  }

  function kill() external onlyOperator() {
    selfdestruct(msg.sender);
  }
}