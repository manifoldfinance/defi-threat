/**
 * Source Code first verified at https://etherscan.io on Thursday, May 9, 2019
 (UTC) */

pragma solidity ^0.5.6;
pragma experimental ABIEncoderV2;

interface GeneralERC20 {
	function transfer(address to, uint256 value) external;
	function transferFrom(address from, address to, uint256 value) external;
	function approve(address spender, uint256 value) external;
	function balanceOf(address spender) external view returns (uint);
}

library SafeERC20 {
	function checkSuccess()
		private
		pure
		returns (bool)
	{
		uint256 returnValue = 0;

		assembly {
			// check number of bytes returned from last function call
			switch returndatasize

			// no bytes returned: assume success
			case 0x0 {
				returnValue := 1
			}

			// 32 bytes returned: check if non-zero
			case 0x20 {
				// copy 32 bytes into scratch space
				returndatacopy(0x0, 0x0, 0x20)

				// load those bytes into returnValue
				returnValue := mload(0x0)
			}

			// not sure what was returned: don't mark as success
			default { }
		}

		return returnValue != 0;
	}

	function transfer(address token, address to, uint256 amount) internal {
		GeneralERC20(token).transfer(to, amount);
		require(checkSuccess());
	}

	function transferFrom(address token, address from, address to, uint256 amount) internal {
		GeneralERC20(token).transferFrom(from, to, amount);
		require(checkSuccess());
	}

	function approve(address token, address spender, uint256 amount) internal {
		GeneralERC20(token).approve(spender, amount);
		require(checkSuccess());
	}
}

library SafeMath {

    function mul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        require(b > 0);
        uint c = a / b;
        require(a == b * c + a % b);
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        require(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint a, uint b) internal pure returns (uint) {
        return a >= b ? a : b;
    }

    function min256(uint a, uint b) internal pure returns (uint) {
        return a < b ? a : b;
    }
}

library SignatureValidator {
	enum SignatureMode {
		NO_SIG,
		EIP712,
		GETH,
		TREZOR,
		ADEX
	}

	function recoverAddr(bytes32 hash, bytes32[3] memory signature) internal pure returns (address) {
		SignatureMode mode = SignatureMode(uint8(signature[0][0]));

		if (mode == SignatureMode.NO_SIG) {
			return address(0x0);
		}

		uint8 v = uint8(signature[0][1]);

		if (mode == SignatureMode.GETH) {
			hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
		} else if (mode == SignatureMode.TREZOR) {
			hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n\x20", hash));
		} else if (mode == SignatureMode.ADEX) {
			hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n108By signing this message, you acknowledge signing an AdEx bid with the hash:\n", hash));
		}

		return ecrecover(hash, v, signature[1], signature[2]);
	}

	/// @dev Validates that a hash was signed by a specified signer.
	/// @param hash Hash which was signed.
	/// @param signer Address of the signer.
	/// @param signature ECDSA signature along with the mode [{mode}{v}, {r}, {s}]
	/// @return Returns whether signature is from a specified user.
	function isValidSignature(bytes32 hash, address signer, bytes32[3] memory signature) internal pure returns (bool) {
		return recoverAddr(hash, signature) == signer;
	}
}


library ChannelLibrary {
	uint constant MAX_VALIDITY = 365 days;

	// Both numbers are inclusive
	uint constant MIN_VALIDATOR_COUNT = 2;
	// This is an arbitrary number, but we impose this limit to restrict on-chain load; also to ensure the *3 operation is safe
	uint constant MAX_VALIDATOR_COUNT = 25;

	enum State {
		Unknown,
		Active,
		Expired
	}

	struct Channel {
		address creator;

		address tokenAddr;
		uint tokenAmount;

		uint validUntil;

		address[] validators;

		// finally, arbitrary bytes32 that allows to... @TODO document that this acts as a nonce
		bytes32 spec;
	}

	function hash(Channel memory channel)
		internal
		view
		returns (bytes32)
	{
		// In this version of solidity, we can no longer keccak256() directly
		return keccak256(abi.encode(
			address(this),
			channel.creator,
			channel.tokenAddr,
			channel.tokenAmount,
			channel.validUntil,
			channel.validators,
			channel.spec
		));
	}

	function isValid(Channel memory channel, uint currentTime)
		internal
		pure
		returns (bool)
	{
		// NOTE: validators[] can be sybil'd by passing the same addr a few times
		// this does not matter since you can sybil validators[] anyway, and that is mitigated off-chain
		if (channel.validators.length < MIN_VALIDATOR_COUNT) {
			return false;
		}
		if (channel.validators.length > MAX_VALIDATOR_COUNT) {
			return false;
		}
		if (channel.validUntil < currentTime) {
			return false;
		}
		if (channel.validUntil > (currentTime + MAX_VALIDITY)) {
			return false;
		}

		return true;
	}

	function isSignedBySupermajority(Channel memory channel, bytes32 toSign, bytes32[3][] memory signatures) 
		internal
		pure
		returns (bool)
	{
		// NOTE: each element of signatures[] must signed by the elem with the same index in validators[]
		// In case someone didn't sign, pass SignatureMode.NO_SIG
		if (signatures.length != channel.validators.length) {
			return false;
		}

		uint signs = 0;
		uint sigLen = signatures.length;
		for (uint i=0; i<sigLen; i++) {
			// NOTE: if a validator has not signed, you can just use SignatureMode.NO_SIG
			if (SignatureValidator.isValidSignature(toSign, channel.validators[i], signatures[i])) {
				signs++;
			}
		}
		return signs*3 >= channel.validators.length*2;
	}
}

contract ValidatorRegistry {
	// The contract will probably just use a mapping, but this is a generic interface
	function whitelisted(address) view external returns (bool);
}

contract Identity {
	using SafeMath for uint;

	// Storage
	// WARNING: be careful when modifying this
	// privileges and routineAuthorizations must always be 0th and 1th thing in storage
	mapping (address => uint8) public privileges;
	// Routine authorizations
	mapping (bytes32 => bool) public routineAuthorizations;
	// The next allowed nonce
	uint public nonce = 0;
	// Routine operations are authorized at once for a period, fee is paid once
	mapping (bytes32 => uint256) public routinePaidFees;

	// Constants
	bytes4 private constant CHANNEL_WITHDRAW_SELECTOR = bytes4(keccak256('channelWithdraw((address,address,uint256,uint256,address[],bytes32),bytes32,bytes32[3][],bytes32[],uint256)'));
	bytes4 private constant CHANNEL_WITHDRAW_EXPIRED_SELECTOR = bytes4(keccak256('channelWithdrawExpired((address,address,uint256,uint256,address[],bytes32))'));
	bytes4 private constant CHANNEL_OPEN_SELECTOR = bytes4(keccak256('channelOpen((address,address,uint256,uint256,address[],bytes32))'));
	uint256 private constant CHANNEL_MAX_VALIDITY = 90 days;

	enum PrivilegeLevel {
		None,
		Routines,
		Transactions,
		WithdrawTo
	}
	enum RoutineOp {
		ChannelWithdraw,
		ChannelWithdrawExpired,
		ChannelOpen,
		Withdraw
	}

	// Events
	event LogPrivilegeChanged(address indexed addr, uint8 privLevel);
	event LogRoutineAuth(bytes32 hash, bool authorized);

	// Transaction structure
	// Those can be executed by keys with >= PrivilegeLevel.Transactions
	// Even though the contract cannot receive ETH, we are able to send ETH (.value), cause ETH might've been sent to the contract address before it's deployed
	struct Transaction {
		// replay protection
		address identityContract;
		uint nonce;
		// tx fee, in tokens
		address feeTokenAddr;
		uint feeAmount;
		// all the regular txn data
		address to;
		uint value;
		bytes data;
	}

	// RoutineAuthorizations allow the user to authorize (via keys >= PrivilegeLevel.Routines) a particular relayer to do any number of routines
	// those routines are safe: e.g. withdrawing channels to the identity, or from the identity to the pre-approved withdraw (>= PrivilegeLevel.Withdraw) address
	// while the fee will be paid only ONCE per auth, the authorization can be used until validUntil
	// while the routines are safe, there is some level of implied trust as the relayer may run executeRoutines without any routines to claim the fee
	struct RoutineAuthorization {
		address relayer;
		address outpace;
		address registry;
		uint validUntil;
		address feeTokenAddr;
		uint weeklyFeeAmount;
	}
	struct RoutineOperation {
		RoutineOp mode;
		bytes data;
	}

	constructor(address[] memory addrs, uint8[] memory privLevels)
		public
	{
		uint len = privLevels.length;
		for (uint i=0; i<len; i++) {
			privileges[addrs[i]] = privLevels[i];
			emit LogPrivilegeChanged(addrs[i], privLevels[i]);
		}
	}

	function setAddrPrivilege(address addr, uint8 privLevel)
		external
	{
		require(msg.sender == address(this), 'ONLY_IDENTITY_CAN_CALL');
		privileges[addr] = privLevel;
		emit LogPrivilegeChanged(addr, privLevel);
	}

	function setRoutineAuth(bytes32 hash, bool authorized)
		external
	{
		require(msg.sender == address(this), 'ONLY_IDENTITY_CAN_CALL');
		routineAuthorizations[hash] = authorized;
		emit LogRoutineAuth(hash, authorized);
	}

	function execute(Transaction[] memory txns, bytes32[3][] memory signatures)
		public
	{
		address feeTokenAddr = txns[0].feeTokenAddr;
		uint feeAmount = 0;
		uint len = txns.length;
		for (uint i=0; i<len; i++) {
			Transaction memory txn = txns[i];
			require(txn.identityContract == address(this), 'TRANSACTION_NOT_FOR_CONTRACT');
			require(txn.feeTokenAddr == feeTokenAddr, 'EXECUTE_NEEDS_SINGLE_TOKEN');
			require(txn.nonce == nonce, 'WRONG_NONCE');

			// If we use the naive abi.encode(txn) and have a field of type `bytes`,
			// there is a discrepancy between ethereumjs-abi and solidity
			// if we enter every field individually, in order, there is no discrepancy
			//bytes32 hash = keccak256(abi.encode(txn));
			bytes32 hash = keccak256(abi.encode(txn.identityContract, txn.nonce, txn.feeTokenAddr, txn.feeAmount, txn.to, txn.value, txn.data));
			address signer = SignatureValidator.recoverAddr(hash, signatures[i]);

			require(privileges[signer] >= uint8(PrivilegeLevel.Transactions), 'INSUFFICIENT_PRIVILEGE_TRANSACTION');

			nonce = nonce.add(1);
			feeAmount = feeAmount.add(txn.feeAmount);

			executeCall(txn.to, txn.value, txn.data);
			// The actual anti-bricking mechanism - do not allow a signer to drop his own priviledges
			require(privileges[signer] >= uint8(PrivilegeLevel.Transactions), 'PRIVILEGE_NOT_DOWNGRADED');
		}
		if (feeAmount > 0) {
			SafeERC20.transfer(feeTokenAddr, msg.sender, feeAmount);
		}
	}

	function executeBySender(Transaction[] memory txns)
		public
	{
		require(privileges[msg.sender] >= uint8(PrivilegeLevel.Transactions), 'INSUFFICIENT_PRIVILEGE_SENDER');
		uint len = txns.length;
		for (uint i=0; i<len; i++) {
			Transaction memory txn = txns[i];
			require(txn.nonce == nonce, 'WRONG_NONCE');

			nonce = nonce.add(1);

			executeCall(txn.to, txn.value, txn.data);
		}
		// The actual anti-bricking mechanism - do not allow the sender to drop his own priviledges
		require(privileges[msg.sender] >= uint8(PrivilegeLevel.Transactions), 'PRIVILEGE_NOT_DOWNGRADED');
	}

	function executeRoutines(RoutineAuthorization memory auth, RoutineOperation[] memory operations)
		public
	{
		require(auth.relayer == msg.sender, 'ONLY_RELAYER_CAN_CALL');
		require(auth.validUntil >= now, 'AUTHORIZATION_EXPIRED');
		bytes32 hash = keccak256(abi.encode(auth));
		require(routineAuthorizations[hash], 'NOT_AUTHORIZED');
		uint len = operations.length;
		for (uint i=0; i<len; i++) {
			RoutineOperation memory op = operations[i];
			if (op.mode == RoutineOp.ChannelWithdraw) {
				// Channel: Withdraw
				executeCall(auth.outpace, 0, abi.encodePacked(CHANNEL_WITHDRAW_SELECTOR, op.data));
			} else if (op.mode == RoutineOp.ChannelWithdrawExpired) {
				// Channel: Withdraw Expired
				executeCall(auth.outpace, 0, abi.encodePacked(CHANNEL_WITHDRAW_EXPIRED_SELECTOR, op.data));
			} else if (op.mode == RoutineOp.ChannelOpen) {
				// Channel: open
				(ChannelLibrary.Channel memory channel) = abi.decode(op.data, (ChannelLibrary.Channel));
				// Ensure validity is sane
				require(channel.validUntil <= (now + CHANNEL_MAX_VALIDITY), 'CHANNEL_EXCEEDED_MAX_VALID');
				// Ensure all validators are whitelisted
				uint validatorsLen = channel.validators.length;
				for (uint j=0; j<validatorsLen; j++) {
					require(
						ValidatorRegistry(auth.registry).whitelisted(channel.validators[j]),
						"VALIDATOR_NOT_WHITELISTED"
					);
				}
				SafeERC20.approve(channel.tokenAddr, auth.outpace, 0);
				SafeERC20.approve(channel.tokenAddr, auth.outpace, channel.tokenAmount);
				executeCall(auth.outpace, 0, abi.encodePacked(CHANNEL_OPEN_SELECTOR, op.data));
			} else if (op.mode == RoutineOp.Withdraw) {
				// Withdraw from identity
				(address tokenAddr, address to, uint amount) = abi.decode(op.data, (address, address, uint));
				require(privileges[to] >= uint8(PrivilegeLevel.WithdrawTo), 'INSUFFICIENT_PRIVILEGE_WITHDRAW');
				SafeERC20.transfer(tokenAddr, to, amount);
			} else {
				revert('INVALID_MODE');
			}
		}
		if (auth.weeklyFeeAmount > 0 && (now - routinePaidFees[hash]) >= 7 days) {
			routinePaidFees[hash] = now;
			SafeERC20.transfer(auth.feeTokenAddr, msg.sender, auth.weeklyFeeAmount);
		}
	}

	// we shouldn't use address.call(), cause: https://github.com/ethereum/solidity/issues/2884
	// copied from https://github.com/uport-project/uport-identity/blob/develop/contracts/Proxy.sol
	// there's also
	// https://github.com/gnosis/MultiSigWallet/commit/e1b25e8632ca28e9e9e09c81bd20bf33fdb405ce
	// https://github.com/austintgriffith/bouncer-proxy/blob/master/BouncerProxy/BouncerProxy.sol
	// https://github.com/gnosis/safe-contracts/blob/7e2eeb3328bb2ae85c36bc11ea6afc14baeb663c/contracts/base/Executor.sol
	function executeCall(address to, uint256 value, bytes memory data)
		internal
	{
		assembly {
			let result := call(gas, to, value, add(data, 0x20), mload(data), 0, 0)

			switch result case 0 {
				let size := returndatasize
				let ptr := mload(0x40)
				returndatacopy(ptr, 0, size)
				revert(ptr, size)
			}
			default {}
		}
	}
}

contract IdentityFactory {
	event LogDeployed(address addr, uint256 salt);

	address public relayer;
	constructor(address relayerAddr) public {
		relayer = relayerAddr;
	}

	function deploy(bytes memory code, uint256 salt) public {
		address addr;
		assembly { addr := create2(0, add(code, 0x20), mload(code), salt) }
		require(addr != address(0), "FAILED_DEPLOYING");
		emit LogDeployed(addr, salt);
	}

	function deployAndFund(bytes memory code, uint256 salt, address tokenAddr, uint256 tokenAmount) public {
		require(msg.sender == relayer, "ONLY_RELAYER");
		address addr;
		assembly { addr := create2(0, add(code, 0x20), mload(code), salt) }
		require(addr != address(0), "FAILED_DEPLOYING");
		SafeERC20.transfer(tokenAddr, addr, tokenAmount);
		emit LogDeployed(addr, salt);
	}

	function deployAndExecute(bytes memory code, uint256 salt, Identity.Transaction[] memory txns, bytes32[3][] memory signatures) public {
		address addr;
		assembly { addr := create2(0, add(code, 0x20), mload(code), salt) }
		require(addr != address(0), "FAILED_DEPLOYING");
		Identity(addr).execute(txns, signatures);
		emit LogDeployed(addr, salt);
	}

	function withdraw(address tokenAddr, address to, uint256 tokenAmount) public {
		require(msg.sender == relayer, "ONLY_RELAYER");
		SafeERC20.transfer(tokenAddr, to, tokenAmount);
	}
}