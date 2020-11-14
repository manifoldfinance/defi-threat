/**
 * Source Code first verified at https://etherscan.io on Wednesday, April 3, 2019
 (UTC) */

pragma solidity ^0.4.21;


contract Custodian {

 
    struct Request {
        bytes32 lockId;
        bytes4 callbackSelector; // bytes4 and address can be packed into 1 word
        address callbackAddress;
        uint256 idx;
        uint256 timestamp;
        bool extended;
    }


    event Requested(
        bytes32 _zamokId,
        address _callbackAddress,
        bytes4  _callbackSelector,
        uint256 _nonce,
        address _whitelistedAddress,
        bytes32 _requestMsgHash,
        uint256 _timeLockExpiry
    );

    event TimeLocked(
        uint256 _timeLockExpiry,
        bytes32 _requestMsgHash
    );

    event Completed(
        bytes32 _zamokId,
        bytes32 _requestMsgHash,
        address _signer1,
        address _signer2
    );

    event Failed(
        bytes32 _zamokId,
        bytes32 _requestMsgHash,
        address _signer1,
        address _signer2
    );

    event TimeLockExtended(
        uint256 _timeLockExpiry,
        bytes32 _requestMsgHash
    );

    uint256 public requestCount;

    mapping (address => bool) public signerSet;

    mapping (bytes32 => Request) public requestMap;

    mapping (address => mapping (bytes4 => uint256)) public lastCompletedIdxs;

    uint256 public defaultTimeLock;

    uint256 public extendedTimeLock;

    address public primary;

    // CONSTRUCTOR
    function Custodian(
        address[] _signers,
        uint256 _defaultTimeLock,
        uint256 _extendedTimeLock,
        address _primary
    )
        public
    {
        // check for at least two `_signers`
        require(_signers.length >= 2);

        // validate time lock params
        require(_defaultTimeLock <= _extendedTimeLock);
        defaultTimeLock = _defaultTimeLock;
        extendedTimeLock = _extendedTimeLock;

        primary = _primary;

        // explicitly initialize `requestCount` to zero
        requestCount = 0;
        // turn the array into a set
        for (uint i = 0; i < _signers.length; i++) {
            // no zero addresses or duplicates
            require(_signers[i] != address(0) && !signerSet[_signers[i]]);
            signerSet[_signers[i]] = true;
        }
    }

    // MODIFIERS
    modifier onlyPrimary {
        require(msg.sender == primary);
        _;
    }

    // METHODS
    function requestUnlock(
        bytes32 _zamokId,
        address _callbackAddress,
        bytes4 _callbackSelector,
        address _whitelistedAddress
    )
        public
        payable
        returns (bytes32 requestMsgHash)
    {
        require(msg.sender == primary || msg.value >= 1 ether);

        // disallow using a zero value for the callback address
        require(_callbackAddress != address(0));

        uint256 requestIdx = ++requestCount;
        // compute a nonce value
        // - the blockhash prevents prediction of future nonces
        // - the address of this contract prevents conflicts with co-operating contracts using this scheme
        // - the counter prevents conflicts arising from multiple txs within the same block
        uint256 nonce = uint256(keccak256(block.blockhash(block.number - 1), address(this), requestIdx));

        requestMsgHash = keccak256(nonce, _whitelistedAddress, uint256(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF));

        requestMap[requestMsgHash] = Request({
            lockId: _zamokId,
            callbackSelector: _callbackSelector,
            callbackAddress: _callbackAddress,
            idx: requestIdx,
            timestamp: block.timestamp,
            extended: false
        });

        // compute the expiry time
        uint256 timeLockExpiry = block.timestamp;
        if (msg.sender == primary) {
            timeLockExpiry += defaultTimeLock;
        } else {
            timeLockExpiry += extendedTimeLock;

            // any sender that is not the creator will get the extended time lock
            requestMap[requestMsgHash].extended = true;
        }

        emit Requested(_zamokId, _callbackAddress, _callbackSelector, nonce, _whitelistedAddress, requestMsgHash, timeLockExpiry);
    }

    function completeUnlock(
        bytes32 _requestMsgHash,
        uint8 _recoveryByte1, bytes32 _ecdsaR1, bytes32 _ecdsaS1,
        uint8 _recoveryByte2, bytes32 _ecdsaR2, bytes32 _ecdsaS2
    )
        public
        returns (bool success)
    {
        Request storage request = requestMap[_requestMsgHash];

        // copy storage to locals before `delete`
        bytes32 lockId = request.lockId;
        address callbackAddress = request.callbackAddress;
        bytes4 callbackSelector = request.callbackSelector;

        // failing case of the lookup if the callback address is zero
        require(callbackAddress != address(0));

        // reject confirms of earlier withdrawals buried under later confirmed withdrawals
        require(request.idx > lastCompletedIdxs[callbackAddress][callbackSelector]);

        address signer1 = ecrecover(_requestMsgHash, _recoveryByte1, _ecdsaR1, _ecdsaS1);
        require(signerSet[signer1]);

        address signer2 = ecrecover(_requestMsgHash, _recoveryByte2, _ecdsaR2, _ecdsaS2);
        require(signerSet[signer2]);
        require(signer1 != signer2);

        if (request.extended && ((block.timestamp - request.timestamp) < extendedTimeLock)) {
            emit TimeLocked(request.timestamp + extendedTimeLock, _requestMsgHash);
            return false;
        } else if ((block.timestamp - request.timestamp) < defaultTimeLock) {
            emit TimeLocked(request.timestamp + defaultTimeLock, _requestMsgHash);
            return false;
        } else {
            if (address(this).balance > 0) {
                // reward sender with anti-spam payments
                // ignore send success (assign to `success` but this will be overwritten)
                success = msg.sender.send(address(this).balance);
            }

            // raise the waterline for the last completed unlocking
            lastCompletedIdxs[callbackAddress][callbackSelector] = request.idx;
            // and delete the request
            delete requestMap[_requestMsgHash];

            // invoke callback
            success = callbackAddress.call(callbackSelector, lockId);

            if (success) {
                emit Completed(lockId, _requestMsgHash, signer1, signer2);
            } else {
                emit Failed(lockId, _requestMsgHash, signer1, signer2);
            }
        }
    }

    function deleteUncompletableRequest(bytes32 _requestMsgHash) public {
        Request storage request = requestMap[_requestMsgHash];

        uint256 idx = request.idx;

        require(0 < idx && idx < lastCompletedIdxs[request.callbackAddress][request.callbackSelector]);

        delete requestMap[_requestMsgHash];
    }

    function extendRequestTimeLock(bytes32 _requestMsgHash) public onlyPrimary {
        Request storage request = requestMap[_requestMsgHash];

        // reject ‘null’ results from the map lookup
        // this can only be the case if an unknown `_requestMsgHash` is received
        require(request.callbackAddress != address(0));

        // `extendRequestTimeLock` must be idempotent
        require(request.extended != true);

        // set the `extended` flag; note that this is never unset
        request.extended = true;

        emit TimeLockExtended(request.timestamp + extendedTimeLock, _requestMsgHash);
    }
}