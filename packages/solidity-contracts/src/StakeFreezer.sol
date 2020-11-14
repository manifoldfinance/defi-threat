/**
 * Source Code first verified at https://etherscan.io on Wednesday, May 8, 2019
 (UTC) */

pragma solidity ^0.4.25;

contract IStdToken {
    function balanceOf(address _owner) public view returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool);
}

contract PoolCommon {
    
    //main adrministrators of the Etherama network
    mapping(address => bool) private _administrators;

    //main managers of the Etherama network
    mapping(address => bool) private _managers;

    
    modifier onlyAdministrator() {
        require(_administrators[msg.sender]);
        _;
    }

    modifier onlyAdministratorOrManager() {
        require(_administrators[msg.sender] || _managers[msg.sender]);
        _;
    }
    
    constructor() public {
        _administrators[msg.sender] = true;
    }
    
    
    function addAdministator(address addr) onlyAdministrator public {
        _administrators[addr] = true;
    }

    function removeAdministator(address addr) onlyAdministrator public {
        _administrators[addr] = false;
    }

    function isAdministrator(address addr) public view returns (bool) {
        return _administrators[addr];
    }

    function addManager(address addr) onlyAdministrator public {
        _managers[addr] = true;
    }

    function removeManager(address addr) onlyAdministrator public {
        _managers[addr] = false;
    }
    
    function isManager(address addr) public view returns (bool) {
        return _managers[addr];
    }
}

contract PoolCore is PoolCommon {
    uint256 constant public MAGNITUDE = 2**64;

    //MNTP token reward per share
    uint256 public mntpRewardPerShare;
    //GOLD token reward per share
    uint256 public goldRewardPerShare;

    //Total MNTP tokens held by users
    uint256 public totalMntpHeld;

    //mntp reward per share
    mapping(address => uint256) private _mntpRewardPerShare;   

    //gold reward per share
    mapping(address => uint256) private _goldRewardPerShare;  

    address public controllerAddress = address(0x0);

    mapping(address => uint256) private _rewardMntpPayouts;
    mapping(address => uint256) private _rewardGoldPayouts;

    mapping(address => uint256) private _userStakes;

    IStdToken public mntpToken;
    IStdToken public goldToken;


    modifier onlyController() {
        require(controllerAddress == msg.sender);
        _;
    }
	
    constructor(address mntpTokenAddr, address goldTokenAddr) PoolCommon() public {
        controllerAddress = msg.sender;
        mntpToken = IStdToken(mntpTokenAddr);
        goldToken = IStdToken(goldTokenAddr);
    }
	
    function setNewControllerAddress(address newAddress) onlyController public {
        controllerAddress = newAddress;
    }
    
    function addHeldTokens(address userAddress, uint256 tokenAmount) onlyController public {
        _userStakes[userAddress] = SafeMath.add(_userStakes[userAddress], tokenAmount);
        totalMntpHeld = SafeMath.add(totalMntpHeld, tokenAmount);
        
        addUserPayouts(userAddress, SafeMath.mul(mntpRewardPerShare, tokenAmount), SafeMath.mul(goldRewardPerShare, tokenAmount));
    }
	
    function freeHeldTokens(address userAddress) onlyController public {
        totalMntpHeld = SafeMath.sub(totalMntpHeld, _userStakes[userAddress]);
		_userStakes[userAddress] = 0;
		_rewardMntpPayouts[userAddress] = 0;
        _rewardGoldPayouts[userAddress] = 0;
    }

    function addRewardPerShare(uint256 mntpReward, uint256 goldReward) onlyController public {
        require(totalMntpHeld > 0);

        uint256 mntpShareReward = SafeMath.div(SafeMath.mul(mntpReward, MAGNITUDE), totalMntpHeld);
        uint256 goldShareReward = SafeMath.div(SafeMath.mul(goldReward, MAGNITUDE), totalMntpHeld);

        mntpRewardPerShare = SafeMath.add(mntpRewardPerShare, mntpShareReward);
        goldRewardPerShare = SafeMath.add(goldRewardPerShare, goldShareReward);
    }  
    
    function addUserPayouts(address userAddress, uint256 mntpReward, uint256 goldReward) onlyController public {
        _rewardMntpPayouts[userAddress] = SafeMath.add(_rewardMntpPayouts[userAddress], mntpReward);
        _rewardGoldPayouts[userAddress] = SafeMath.add(_rewardGoldPayouts[userAddress], goldReward);
    }

    function getMntpTokenUserReward(address userAddress) public view returns(uint256 reward, uint256 rewardAmp) {  
        rewardAmp = SafeMath.mul(mntpRewardPerShare, getUserStake(userAddress));
        rewardAmp = (rewardAmp < getUserMntpRewardPayouts(userAddress)) ? 0 : SafeMath.sub(rewardAmp, getUserMntpRewardPayouts(userAddress));
        reward = SafeMath.div(rewardAmp, MAGNITUDE);
        
        return (reward, rewardAmp);
    }
    
    function getGoldTokenUserReward(address userAddress) public view returns(uint256 reward, uint256 rewardAmp) {  
        rewardAmp = SafeMath.mul(goldRewardPerShare, getUserStake(userAddress));
        rewardAmp = (rewardAmp < getUserGoldRewardPayouts(userAddress)) ? 0 : SafeMath.sub(rewardAmp, getUserGoldRewardPayouts(userAddress));
        reward = SafeMath.div(rewardAmp, MAGNITUDE);
        
        return (reward, rewardAmp);
    }
    
    function getUserMntpRewardPayouts(address userAddress) public view returns(uint256) {
        return _rewardMntpPayouts[userAddress];
    }    
    
    function getUserGoldRewardPayouts(address userAddress) public view returns(uint256) {
        return _rewardGoldPayouts[userAddress];
    }    
    
    function getUserStake(address userAddress) public view returns(uint256) {
        return _userStakes[userAddress];
    }    

}

contract StakeFreezer {

    address public controllerAddress = address(0x0);

    mapping(address => uint256) private _userStakes;

    event onFreeze(address indexed userAddress, uint256 tokenAmount, bytes32 sumusAddress);
    event onUnfreeze(address indexed userAddress, uint256 tokenAmount);


    modifier onlyController() {
        require(controllerAddress == msg.sender);
        _;
    }
	
    constructor() public {
        controllerAddress = msg.sender;
    }
	
    function setNewControllerAddress(address newAddress) onlyController public {
        controllerAddress = newAddress;
    }

    function freezeUserStake(address userAddress, uint256 tokenAmount, bytes32 sumusAddress) onlyController public {
        _userStakes[userAddress] = SafeMath.add(_userStakes[userAddress], tokenAmount);
        emit onFreeze(userAddress, tokenAmount, sumusAddress);
    }

	function unfreezeUserStake(address userAddress, uint256 tokenAmount) onlyController public {
        _userStakes[userAddress] = SafeMath.sub(_userStakes[userAddress], tokenAmount);
        emit onUnfreeze(userAddress, tokenAmount);
    }
    
    function getUserFrozenStake(address userAddress) public view returns(uint256) {
        return _userStakes[userAddress];
    }
}


contract GoldmintPool {

    address public tokenBankAddress = address(0x0);

    PoolCore public core;
    StakeFreezer public stakeFreezer;
    IStdToken public mntpToken;
    IStdToken public goldToken;

    bool public isActualContractVer = true;
    bool public isActive = true;
    
    event onDistribShareProfit(uint256 mntpReward, uint256 goldReward); 
    event onUserRewardWithdrawn(address indexed userAddress, uint256 mntpReward, uint256 goldReward);
    event onHoldStake(address indexed userAddress, uint256 mntpAmount);
    event onUnholdStake(address indexed userAddress, uint256 mntpAmount);

    modifier onlyAdministrator() {
        require(core.isAdministrator(msg.sender));
        _;
    }

    modifier onlyAdministratorOrManager() {
        require(core.isAdministrator(msg.sender) || core.isManager(msg.sender));
        _;
    }
    
    modifier notNullAddress(address addr) {
        require(addr != address(0x0));
        _;
    }
    
    modifier onlyActive() {
        require(isActive);
        _;
    }

    constructor(address coreAddr, address tokenBankAddr, address stakeFreezerAddr) notNullAddress(coreAddr) notNullAddress(tokenBankAddr) public { 
        core = PoolCore(coreAddr);
        stakeFreezer = StakeFreezer(stakeFreezerAddr);
        mntpToken = core.mntpToken();
        goldToken = core.goldToken();
        
        tokenBankAddress = tokenBankAddr;
    }
    
    function setTokenBankAddress(address addr) onlyAdministrator notNullAddress(addr) public {
        tokenBankAddress = addr;
    }

    function setStakeFreezerAddress(address addr) onlyAdministrator public {
        stakeFreezer = StakeFreezer(addr);
    }
    
    function switchActive() onlyAdministrator public {
        require(isActualContractVer);
        isActive = !isActive;
    }
    
    function holdStake(uint256 mntpAmount) onlyActive public {
        require(mntpToken.balanceOf(msg.sender) > 0);
        require(mntpToken.balanceOf(msg.sender) >= mntpAmount);
        
        mntpToken.transferFrom(msg.sender, address(this), mntpAmount);
        core.addHeldTokens(msg.sender, mntpAmount);
        
        emit onHoldStake(msg.sender, mntpAmount);
    }
    
    function unholdStake() onlyActive public {
        uint256 frozenAmount;
        uint256 amount = core.getUserStake(msg.sender);
        
        require(amount > 0);
        require(getMntpBalance() >= amount);
        
        if (stakeFreezer != address(0x0)) {
            frozenAmount = stakeFreezer.getUserFrozenStake(msg.sender);
        }
        require(frozenAmount == 0);
		
        core.freeHeldTokens(msg.sender);
        mntpToken.transfer(msg.sender, amount);
        
        emit onUnholdStake(msg.sender, amount);
    }
    
    function distribShareProfit(uint256 mntpReward, uint256 goldReward) onlyActive onlyAdministratorOrManager public {
        if (mntpReward > 0) mntpToken.transferFrom(tokenBankAddress, address(this), mntpReward);
        if (goldReward > 0) goldToken.transferFrom(tokenBankAddress, address(this), goldReward);
        
        core.addRewardPerShare(mntpReward, goldReward);
        
        emit onDistribShareProfit(mntpReward, goldReward);
    }

    function withdrawUserReward() onlyActive public {
        uint256 mntpReward; uint256 mntpRewardAmp;
        uint256 goldReward; uint256 goldRewardAmp;

        (mntpReward, mntpRewardAmp) = core.getMntpTokenUserReward(msg.sender);
        (goldReward, goldRewardAmp) = core.getGoldTokenUserReward(msg.sender);

        require(getMntpBalance() >= mntpReward);
        require(getGoldBalance() >= goldReward);

        core.addUserPayouts(msg.sender, mntpRewardAmp, goldRewardAmp);
        
        if (mntpReward > 0) mntpToken.transfer(msg.sender, mntpReward);
        if (goldReward > 0) goldToken.transfer(msg.sender, goldReward);
        
        emit onUserRewardWithdrawn(msg.sender, mntpReward, goldReward);
    }
    
    function withdrawRewardAndUnholdStake() onlyActive public {
        withdrawUserReward();
        unholdStake();
    }
    
    function addRewadToStake() onlyActive public {
        uint256 mntpReward; uint256 mntpRewardAmp;
        
        (mntpReward, mntpRewardAmp) = core.getMntpTokenUserReward(msg.sender);
        
        require(mntpReward > 0);

        core.addUserPayouts(msg.sender, mntpRewardAmp, 0);
        core.addHeldTokens(msg.sender, mntpReward);

        emit onHoldStake(msg.sender, mntpReward);
    }

    function freezeStake(bytes32 sumusAddress) onlyActive public {
        require(stakeFreezer != address(0x0));

        uint256 stake = core.getUserStake(msg.sender);
		require(stake > 0);
		
        uint256 freezeAmount = SafeMath.sub(stake, stakeFreezer.getUserFrozenStake(msg.sender));
		require(freezeAmount > 0);

        stakeFreezer.freezeUserStake(msg.sender, freezeAmount, sumusAddress);
    }

    function unfreezeUserStake(address userAddress) onlyActive onlyAdministratorOrManager public {
        require(stakeFreezer != address(0x0));

        uint256 amount = stakeFreezer.getUserFrozenStake(userAddress);
		require(amount > 0);
		
        stakeFreezer.unfreezeUserStake(userAddress, amount);
    }

    //migrate to new controller contract in case of some mistake in the contract and transfer there all the tokens and eth. It can be done only after code review by Etherama developers.
    function migrateToNewControllerContract(address newControllerAddr) onlyAdministrator public {
        require(newControllerAddr != address(0x0) && isActualContractVer);
        
        isActive = false;

        core.setNewControllerAddress(newControllerAddr);
        if (stakeFreezer != address(0x0)) {
            stakeFreezer.setNewControllerAddress(newControllerAddr);
        }

        uint256 mntpTokenAmount = getMntpBalance();
        uint256 goldTokenAmount = getGoldBalance();

        if (mntpTokenAmount > 0) mntpToken.transfer(newControllerAddr, mntpTokenAmount); 
        if (goldTokenAmount > 0) goldToken.transfer(newControllerAddr, goldTokenAmount); 

        isActualContractVer = false;
    }

    function getMntpTokenUserReward() public view returns(uint256) {  
        uint256 mntpReward; uint256 mntpRewardAmp;
        (mntpReward, mntpRewardAmp) = core.getMntpTokenUserReward(msg.sender);
        return mntpReward;
    }
    
    function getGoldTokenUserReward() public view returns(uint256) {  
        uint256 goldReward; uint256 goldRewardAmp;
        (goldReward, goldRewardAmp) = core.getGoldTokenUserReward(msg.sender);
        return goldReward;
    }
    
    function getUserMntpRewardPayouts() public view returns(uint256) {
        return core.getUserMntpRewardPayouts(msg.sender);
    }    
    
    function getUserGoldRewardPayouts() public view returns(uint256) {
        return core.getUserGoldRewardPayouts(msg.sender);
    }    
    
    function getUserStake() public view returns(uint256) {
        return core.getUserStake(msg.sender);
    }

    function getUserFrozenStake() public view returns(uint256) {
        if (stakeFreezer != address(0x0)) {
            return stakeFreezer.getUserFrozenStake(msg.sender);
        }
        return 0;
    }

    // HELPERS

    function getMntpBalance() view public returns(uint256) {
        return mntpToken.balanceOf(address(this));
    }

    function getGoldBalance() view public returns(uint256) {
        return goldToken.balanceOf(address(this));
    }

}


library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    } 

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }   

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? b : a;
    }   
}