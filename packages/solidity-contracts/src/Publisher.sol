/**
 * Source Code first verified at https://etherscan.io on Monday, April 1, 2019
 (UTC) */

pragma solidity ^0.5.3;

interface Token {
  function transfer( address to, uint amount ) external;
  function transferFrom( address from, address to, uint amount ) external;
}

interface Membership {
  function isMember( address pusher ) external returns (bool);
}

contract Owned
{
  address payable public owner;
  constructor() public { owner = msg.sender; }

  function changeOwner( address payable newOwner ) isOwner public {
    owner = newOwner;
  }

  modifier isOwner {
    require( msg.sender == owner );
    _;
  }
}

contract Publisher is Owned
{
  event Published( string indexed receiverpubkey,
                   string ipfshash,
                   string redmeta );

  Membership public membership;

  address payable public treasury;
  uint256 public fee;
  uint256 dao;

  uint256 public tokenFee;
  Token   public token;

  constructor() public {
    dao = uint256(100);
  }

  function setFee( uint256 _fee ) isOwner public {
    fee = _fee;
  }

  function setDao( uint256 _dao ) isOwner public {
    dao = _dao;
  }

  function setTreasury( address payable _treasury ) isOwner public {
    treasury = _treasury;
  }

  function setMembership( address _contract ) isOwner public {
    membership = Membership(_contract);
  }

  function setTokenFee( uint256 _fee ) isOwner public {
    tokenFee = _fee;
  }

  function setToken( address _token ) isOwner public {
    token = Token(_token);
  }

  function publish( string memory receiverpubkey,
                    string memory ipfshash,
                    string memory redmeta ) payable public {

    require(    msg.value >= fee
             && membership.isMember(msg.sender) );

    if (treasury != address(0))
      treasury.transfer( msg.value - msg.value / dao );

    emit Published( receiverpubkey, ipfshash, redmeta );
  }

  function publish_t( string memory receiverpubkey,
                      string memory ipfshash,
                      string memory redmeta ) public {

    require( membership.isMember(msg.sender) );

    token.transferFrom( msg.sender, address(this), tokenFee );

    if (treasury != address(0)) {
      token.transfer( treasury, tokenFee - tokenFee/dao );
    }

    emit Published( receiverpubkey, ipfshash, redmeta );
  }

  function withdraw( uint256 amount ) isOwner public {
    owner.transfer( amount );
  }

  function sendTok( address _tok, address _to, uint256 _qty ) isOwner public {
    Token(_tok).transfer( _to, _qty );
  }
}