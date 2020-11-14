pragma solidity ^0.5.0;

import "./GameChannelConflict.sol";


/**
 * @title Game Channel
 * @author dicether
 */
contract GameChannel is GameChannelConflict {
    /**
     * @dev contract constructor
     * @param _serverAddress Server address.
     * @param _minStake Min value user needs to deposit to create game session.
     * @param _maxStake Max value user can deposit to create game session.
     * @param _conflictResAddress Conflict resolution contract address.
     * @param _houseAddress House address to move profit to.
     * @param _chainId Chain id for signature domain.
     */
    constructor(
        address _serverAddress,
        uint128 _minStake,
        uint128 _maxStake,
        address _conflictResAddress,
        address payable _houseAddress,
        uint _chainId
    )
        public
        GameChannelConflict(_serverAddress, _minStake, _maxStake, _conflictResAddress, _houseAddress, _chainId)
    {
        // nothing to do
    }

    /**
     * @notice Create games session request. msg.value needs to be valid stake value.
     * @param _userEndHash Last entry of users' hash chain.
     * @param _previousGameId User's previous game id, initial 0.
     * @param _createBefore Game can be only created before this timestamp.
     * @param _serverEndHash Last entry of server's hash chain.
     * @param _serverSig Server signature. See verifyCreateSig
     */
    function createGame(
        bytes32 _userEndHash,
        uint _previousGameId,
        uint _createBefore,
        bytes32 _serverEndHash,
        bytes memory _serverSig
    )
        public
        payable
        onlyValidValue
        onlyValidHouseStake(activeGames + 1)
        onlyNotPaused
    {
        uint previousGameId = userGameId[msg.sender];
        Game storage game = gameIdGame[previousGameId];

        require(game.status == GameStatus.ENDED, "prev game not ended");
        require(previousGameId == _previousGameId, "inv gamePrevGameId");
        require(block.timestamp < _createBefore, "expired");

        verifyCreateSig(msg.sender, _previousGameId, _createBefore, _serverEndHash, _serverSig);

        uint gameId = gameIdCntr++;
        userGameId[msg.sender] = gameId;
        Game storage newGame = gameIdGame[gameId];

        newGame.stake = uint128(msg.value); // It's safe to cast msg.value as it is limited, see onlyValidValue
        newGame.status = GameStatus.ACTIVE;

        activeGames = activeGames.add(1);

        // It's safe to cast msg.value as it is limited, see onlyValidValue
        emit LogGameCreated(msg.sender, gameId, uint128(msg.value), _serverEndHash,  _userEndHash);
    }


    /**
     * @dev Regular end game session. Used if user and house have both
     * accepted current game session state.
     * The game session with gameId _gameId is closed
     * and the user paid out. This functions is called by the server after
     * the user requested the termination of the current game session.
     * @param _roundId Round id of bet.
     * @param _balance Current balance.
     * @param _serverHash Hash of server's seed for this bet.
     * @param _userHash Hash of user's seed for this bet.
     * @param _gameId Game session id.
     * @param _contractAddress Address of this contract.
     * @param _userAddress Address of user.
     * @param _userSig User's signature of this bet.
     */
    function serverEndGame(
        uint32 _roundId,
        int _balance,
        bytes32 _serverHash,
        bytes32 _userHash,
        uint _gameId,
        address _contractAddress,
        address payable _userAddress,
        bytes memory _userSig
    )
        public
        onlyServer
    {
        verifySig(
                _roundId,
                0,
                0,
                0,
                _balance,
                _serverHash,
                _userHash,
                _gameId,
                _contractAddress,
                _userSig,
                _userAddress
        );

        regularEndGame(_userAddress, _roundId, _balance, _gameId, _contractAddress);
    }

    /**
     * @notice Regular end game session. Normally not needed as server ends game (@see serverEndGame).
     * Can be used by user if server does not end game session.
     * @param _roundId Round id of bet.
     * @param _balance Current balance.
     * @param _serverHash Hash of server's seed for this bet.
     * @param _userHash Hash of user's seed for this bet.
     * @param _gameId Game session id.
     * @param _contractAddress Address of this contract.
     * @param _serverSig Server's signature of this bet.
     */
    function userEndGame(
        uint32 _roundId,
        int _balance,
        bytes32 _serverHash,
        bytes32 _userHash,
        uint _gameId,
        address _contractAddress,
        bytes memory _serverSig
    )
        public
    {
        verifySig(
                _roundId,
                0,
                0,
                0,
                _balance,
                _serverHash,
                _userHash,
                _gameId,
                _contractAddress,
                _serverSig,
                serverAddress
        );

        regularEndGame(msg.sender, _roundId, _balance, _gameId, _contractAddress);
    }

    /**
     * @dev Verify server signature.
     * @param _userAddress User's address.
     * @param _previousGameId User's previous game id, initial 0.
     * @param _createBefore Game can be only created before this timestamp.
     * @param _serverEndHash Last entry of server's hash chain.
     * @param _serverSig Server signature.
     */
    function verifyCreateSig(
        address _userAddress,
        uint _previousGameId,
        uint _createBefore,
        bytes32 _serverEndHash,
        bytes memory _serverSig
    )
        private view
    {
        address contractAddress = address(this);
        bytes32 hash = keccak256(abi.encodePacked(
            contractAddress, _userAddress, _previousGameId, _createBefore, _serverEndHash
        ));

        verify(hash, _serverSig, serverAddress);
    }

    /**
     * @dev Regular end game session implementation. Used if user and house have both
     * accepted current game session state. The game session with gameId _gameId is closed
     * and the user paid out.
     * @param _userAddress Address of user.
     * @param _balance Current balance.
     * @param _gameId Game session id.
     * @param _contractAddress Address of this contract.
     */
    function regularEndGame(
        address payable _userAddress,
        uint32 _roundId,
        int _balance,
        uint _gameId,
        address _contractAddress
    )
        private
    {
        uint gameId = userGameId[_userAddress];
        Game storage game = gameIdGame[gameId];
        int maxBalance = conflictRes.maxBalance();
        int gameStake = game.stake;

        require(_gameId == gameId, "inv gameId");
        require(_roundId > 0, "inv roundId");
        // save to cast as game.stake hash fixed range
        require(-gameStake <= _balance && _balance <= maxBalance, "inv balance");
        require(game.status == GameStatus.ACTIVE, "inv status");

        assert(_contractAddress == address(this));

        closeGame(game, gameId, _roundId, _userAddress, ReasonEnded.REGULAR_ENDED, _balance);
    }
}
