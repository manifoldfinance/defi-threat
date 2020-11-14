/**
 * Source Code first verified at https://etherscan.io on Monday, March 25, 2019
 (UTC) */

pragma solidity ^0.5.6;
pragma experimental ABIEncoderV2;

library SafeMath {

    function mul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c >= a);
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

library MerkleProof {
	function isContained(bytes32 valueHash, bytes32[] memory proof, bytes32 root) internal pure returns (bool) {
		bytes32 cursor = valueHash;

		for (uint256 i = 0; i < proof.length; i++) {
			if (cursor < proof[i]) {
				cursor = keccak256(abi.encodePacked(cursor, proof[i]));
			} else {
				cursor = keccak256(abi.encodePacked(proof[i], cursor));
			}
		}

		return cursor == root;
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
		if (channel.validUntil > currentTime + MAX_VALIDITY) {
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
		for (uint i=0; i<signatures.length; i++) {
			// NOTE: if a validator has not signed, you can just use SignatureMode.NO_SIG
			if (SignatureValidator.isValidSignature(toSign, channel.validators[i], signatures[i])) {
				signs++;
			}
		}
		return signs*3 >= channel.validators.length*2;
	}
}

// AUDIT: Things we should look for
// 1) every time we check the state, the function should either revert or change the state
// 2) state transition: channelOpen locks up tokens, then all of the tokens can be withdrawn on channelExpiredWithdraw, except how many were withdrawn using channelWithdraw
// 3) external calls (everything using SafeERC20) should be at the end
// 4) channel can always be 100% drained with Withdraw/ExpiredWithdraw

contract AdExCore {
	using SafeMath for uint;
	using ChannelLibrary for ChannelLibrary.Channel;

 	// channelId => channelState
	mapping (bytes32 => ChannelLibrary.State) public states;
	
	// withdrawn per channel (channelId => uint)
	mapping (bytes32 => uint) public withdrawn;
	// withdrawn per channel user (channelId => (account => uint))
	mapping (bytes32 => mapping (address => uint)) public withdrawnPerUser;

	// Events
	event LogChannelOpen(bytes32 indexed channelId);
	event LogChannelWithdrawExpired(bytes32 indexed channelId, uint amount);
	event LogChannelWithdraw(bytes32 indexed channelId, uint amount);

	// All functions are public
	function channelOpen(ChannelLibrary.Channel memory channel)
		public
	{
		bytes32 channelId = channel.hash();
		require(states[channelId] == ChannelLibrary.State.Unknown, "INVALID_STATE");
		require(msg.sender == channel.creator, "INVALID_CREATOR");
		require(channel.isValid(now), "INVALID_CHANNEL");
		
		states[channelId] = ChannelLibrary.State.Active;

		SafeERC20.transferFrom(channel.tokenAddr, msg.sender, address(this), channel.tokenAmount);

		emit LogChannelOpen(channelId);
	}

	function channelWithdrawExpired(ChannelLibrary.Channel memory channel)
		public
	{
		bytes32 channelId = channel.hash();
		require(states[channelId] == ChannelLibrary.State.Active, "INVALID_STATE");
		require(now > channel.validUntil, "NOT_EXPIRED");
		require(msg.sender == channel.creator, "INVALID_CREATOR");
		
		uint toWithdraw = channel.tokenAmount.sub(withdrawn[channelId]);

		// NOTE: we will not update withdrawn, since a WithdrawExpired does not count towards normal withdrawals
		states[channelId] = ChannelLibrary.State.Expired;
		
		SafeERC20.transfer(channel.tokenAddr, msg.sender, toWithdraw);

		emit LogChannelWithdrawExpired(channelId, toWithdraw);
	}

	function channelWithdraw(ChannelLibrary.Channel memory channel, bytes32 stateRoot, bytes32[3][] memory signatures, bytes32[] memory proof, uint amountInTree)
		public
	{
		bytes32 channelId = channel.hash();
		require(states[channelId] == ChannelLibrary.State.Active, "INVALID_STATE");
		require(now <= channel.validUntil, "EXPIRED");

		bytes32 hashToSign = keccak256(abi.encode(channelId, stateRoot));
		require(channel.isSignedBySupermajority(hashToSign, signatures), "NOT_SIGNED_BY_VALIDATORS");

		bytes32 balanceLeaf = keccak256(abi.encode(msg.sender, amountInTree));
		require(MerkleProof.isContained(balanceLeaf, proof, stateRoot), "BALANCELEAF_NOT_FOUND");

		// The user can withdraw their constantly increasing balance at any time (essentially prevent users from double spending)
		uint toWithdraw = amountInTree.sub(withdrawnPerUser[channelId][msg.sender]);
		withdrawnPerUser[channelId][msg.sender] = amountInTree;

		// Ensure that it's not possible to withdraw more than the channel deposit (e.g. malicious validators sign such a state)
		withdrawn[channelId] = withdrawn[channelId].add(toWithdraw);
		require(withdrawn[channelId] <= channel.tokenAmount, "WITHDRAWING_MORE_THAN_CHANNEL");

		SafeERC20.transfer(channel.tokenAddr, msg.sender, toWithdraw);

		emit LogChannelWithdraw(channelId, toWithdraw);
	}
}