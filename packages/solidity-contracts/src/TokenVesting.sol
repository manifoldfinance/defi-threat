/**
 * Source Code first verified at https://etherscan.io on Friday, March 15, 2019
 (UTC) */

pragma solidity >=0.5.0 <0.6.0;

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract TokenVesting {
    event Released(uint256 amount);
    event Revoked();
    event AddPartner(address _partner);
    event RevokeVoting(bool _revokecable);
    
    address public beneficiary;
    uint256 public times;
    uint256 public releaseStart;
    uint256 public interval;
    
    address public owner;

    mapping (address => uint256) public released;
    mapping (address => uint256) public revoked;

    struct RevokeVote{
        address partner;
        bool vote;
    }

    mapping (address => RevokeVote) partnerRevokeVote;
    
    uint256 public partnerCount = 0;
    uint256 public voteAgreeCount = 0;
    
    constructor(address _beneficiary,  uint256 _times, uint256 _releaseStart, uint256 _interval, address[5] memory _partners) public {
        require(_beneficiary != address(0));
        require(_releaseStart > now);
        require(_times > 0);
        require(_interval > 0);
        
        beneficiary = _beneficiary;
        times = _times;
        releaseStart = _releaseStart;
        interval = _interval;
        
        owner = msg.sender;
        
        for(uint i=0;i<_partners.length;i++){
            addPartner(_partners[i]);
        }
    }

    function addPartner(address _partner) private {
        require(_partner != address(0));
        if(partnerRevokeVote[_partner].partner != _partner){
            partnerRevokeVote[_partner] = RevokeVote({
                partner : _partner,
                vote : false
            });
            partnerCount++;
        }
        // emit AddPartner(_partner);
    }

    function revokeVoting(bool _revokecable) public {
        require(isPartners(msg.sender));
        bool revokeVoted = partnerRevokeVote[msg.sender].vote;
        if(revokeVoted != _revokecable){
            if(_revokecable){
                voteAgreeCount++;
            } else {
                voteAgreeCount--;
            }
            partnerRevokeVote[msg.sender].vote = _revokecable;
        }
        emit RevokeVoting(_revokecable);
    }

    function isPartners(address _voter) private view returns(bool){
        if(partnerRevokeVote[_voter].partner == _voter){
            return true;
        }
        return false;
    }

    function isRevocable() public view returns(bool) {
        if(voteAgreeCount >= (partnerCount/2)+1){
            return true;
        }
        return false;
    }

    function release(ERC20Basic _token) public {
        require(msg.sender == owner || isPartners(msg.sender));
        uint256 _unreleased = releasableAmount(_token);
        require(_unreleased > 0);
        released[address(_token)] = released[address(_token)] + _unreleased;
        _token.transfer(beneficiary, _unreleased);
        emit Released(_unreleased);
    }

    function revoke(ERC20Basic _token) public {
        require(msg.sender == owner || isPartners(msg.sender));
        require(isRevocable());
        uint256 _balance = _token.balanceOf(address(this));
        revoked[address(_token)] = revoked[address(_token)] + _balance;
        _token.transfer(beneficiary, _balance);
        emit Revoked();
    }

    function releasableAmount(ERC20Basic _token) public view returns (uint256) {
        uint256 _currentBalance = _token.balanceOf(address(this));
        uint256 _totalBalance = _currentBalance + released[address(_token)];
        uint256 _revoked = revoked[address(_token)];

        if (now < releaseStart) {
            return 0;
        } else if ((now >= releaseStart + interval * (times-1)) || _revoked > 0) {
            return _currentBalance;
        } else {
            uint256 _count = _totalBalance / times;
            uint256 _currentTimes = (((now - releaseStart) / interval) + 1);
            uint256 _vestedAmount =  _currentTimes * _count;
            return _vestedAmount - released[address(_token)];
        }
    }
}