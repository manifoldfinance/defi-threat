/**
 * Source Code first verified at https://etherscan.io on Monday, April 1, 2019
 (UTC) */

pragma solidity ^0.4.24;
/**
 * @title -FoMo-3D v0.7.1
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

//==============================================================================
//     _    _  _ _|_ _  .
//    (/_\/(/_| | | _\  .
//==============================================================================
contract F3Devents {
}

//==============================================================================
//   _ _  _ _|_ _ _  __|_   _ _ _|_    _   .
//  (_(_)| | | | (_|(_ |   _\(/_ | |_||_)  .
//====================================|=========================================

contract modularLong is F3Devents, Ownable {}

contract F3DPRO is modularLong {
    using SafeMath for *;
    using NameFilter for string;
    using F3DKeysCalcLong for uint256;

    otherFoMo3D private otherF3D_;
    //P3D分红，暂时不设置，表示无
    DiviesInterface constant private Divies= DiviesInterface(0x0);
    //基金钱包 注册费用也发送到这里
    address constant private myWallet = 0xD979E48Dcb35Ebf096812Df53Afb3EEDADE21496;
    //代币钱包
    address constant private tokenWallet = 0x13E8618b19993D10fEFBEfe8918E45B0A53ccd28;
    //最后大奖池的基金钱包
    /* address constant private myWallet1 = 0xD979E48Dcb35Ebf096812Df53Afb3EEDADE21496; */
    //技术钱包
    address constant private devWallet = 0x9fD04609909Fd0C9717B235a2D25d5e8E9C1058C;
    //大玩家钱包分成的钱包
    address constant private bigWallet = 0x1a4D01e631Eac50b2640D8ADE9873d56bAf841d0;
    //注册费用专用钱包，注册费用发送到这里
    /* address constant private smallWallet = 0xD979E48Dcb35Ebf096812Df53Afb3EEDADE21496; */
    //最后赢家的钱包
    address constant private lastWallet = 0x883d0d727C72740BD2dA9a964E8273af7bDC9B0B;
    //倒数2-20名赢家的钱包
    address constant private lastWallet1 = 0x84F0ad9A94dC6fd614c980Fc84dab234b474CE13;
    //推荐奖拿不到的部分
    address constant private extraWallet = 0xf811B1e061B6221Ec58cd9D069FC2fF0Bf5f4225;

    address constant private backWallet = 0x9Caed3d542260373153fC7e44474cf8359e6cFFC;
    //super wallets
    /* address[] private superWallets2 = [0xAD81260195048D1CafDe04856994d60c14E2188d,0xd0A7bb524cD1a270330B86708f153681E06e6877,0x018EA24948e650f1a1b384eC29C39278362d72cc];
    address[] private superWallets3 = [0x488441BC31F5cCD92F6333CBc74AA68bFfFAc21C,0xb7Eba9DA458935257694d493cAb5F662AE08C17E,0x28E7168bcf0e3871e3F8C950a4582Bb692139943,0x0b1Fc83f411F43716510C1B87DBDDfd4443AAfd4,0xd4DCe2705991f77103e919CA986247Fb9A046CC5,0x21841dDcd720596Ae9Dbd6eDbDaCB05AcD5A8417,0x9c14c3a3c6B27467203f8d3939Fdbb71f3519eB5,0xcd96B3bc4e2eb3cA56183ec4CdA3bCCE40c53078,0x923B9E49dd0B78739CA87bFBBA149B9E1cf00882,0xA5727E469Df4212e03816449b4606b6534f86f6b]; */


    //玩家数据
    PlayerBookInterface private PlayerBook;// = PlayerBookInterface(0x9d9e290c54ed9dce97a31b90c430955f259a2e82);

    function setPlayerBook(address _address) external onlyOwner {
        PlayerBookInterface pBook = PlayerBookInterface(_address);
        // Set the new contract address
        PlayerBook = pBook;
    }
    //==============================================================================
    //     _ _  _  |`. _     _ _ |_ | _  _  .
    //    (_(_)| |~|~|(_||_|| (_||_)|(/__\  .  (game settings)
    //=================_|===========================================================

    string constant public name = "F3DPRO";
    string constant public symbol = "F3P";
    uint256 private rndExtra_ = 15 seconds;                     // length of the very first ICO，相当于是延时多少秒倒计时正式开始
    uint256 private rndGap_ = 24 hours;                         //回合之间的休息时间，投资会进入零钱而不是立刻开始
    bool private    affNeedName_ = true;                        //是否需要注册名字才能获得推广链,， 暂时不能false，会导致空用户获得推广奖励
    uint256 constant private rndInit_ = 8 hours;                // round timer starts at this, 回合起始倒计时
    uint256 constant private rndInc_ = 60 seconds;              // every full key purchased adds this much to the timer
    uint256 constant private rndMax_ = rndInit_;                // max length a round timer can be

    uint256 constant private keyPriceStart_ = 150 szabo;//key的起始价,如果需要改动，两个地方都要改，math那里 0.015ETH

    uint256 constant private keyPriceStep_   = 1 wei;       //key价格上涨阶梯
    //推荐奖⼀代7% 二至⼗代2%
    uint256[] public affsRate_ = [280,80,80,80,80,80,80,80,80,80];           //Multi levels of AFF's award, /1000

    // uint256 private realRndMax_ = rndMax_;               //实际的最大倒计时
    // uint256 constant private keysToReduceMaxTime_ = 10000;//10000个key减少最大倒计时
    // uint256 constant private reduceMaxTimeStep_ = 0 seconds;//一次减少最大倒计时的数量
    // uint256 constant private minMaxTime_ = 2 hours;//最大倒计时的最低限度

    uint256 constant private comFee_ = 1;                       //基金分成
    uint256 constant private devFee_ = 2;                      //技术分成
    uint256 constant private affFee_ = 25;                       //aff rewards for invite friends, if has not aff then to com
    uint256 constant private airdropFee_ = 1;                   //airdrop rewards
    uint256 constant private bigPlayerFee_ = 10;                //大玩家分红
    uint256 constant private smallPlayerFee_ = 0;               //小玩家分红
    uint256 constant private feesTotal_ = comFee_ + devFee_ + affFee_ + airdropFee_ + smallPlayerFee_ + bigPlayerFee_;


    uint256 constant private minInvestWinner_ = 500 finney;//获得最后奖池的最小投资额度,0.5ETH
    uint256 constant private comFee1_ = 5;                      //大奖池里基金分成比例
    uint256 constant private winnerFee_ =  45;                   //最后一名奖励
    uint256 constant private winnerFee1_ = 30;                   //2-20名奖励
    uint256 constant private winnerFee2_ = 15;                   //21-300名奖励
    /* uint256 constant private winnerFee3_ = 10;                   //151-500名奖励 */

    uint256 constant private bigAirdrop_ = 75;                    //big airdrop
    uint256 constant private midAirdrop_ = 50;                    //mid airdrop
    uint256 constant private smallAirdrop_ = 25;                    //small airdrop

    //10倍出局，3倍给ETH，1倍给代币，6倍复投
    //提币会不会影响复投
    uint256 constant private maxEarningRate_ = 500;                //最大获利倍数，百分比
    uint256 constant private keysLeftRate_ = 0;                  //达到最大获利倍数后，剩余多大比例的keys留下继续分红, 相对于maxEarningRate_的比例
    uint256 constant private keysToToken_ = 200;                   //1倍给代币AGK
    uint256 constant public  tokenPrice_ = 1 szabo;          //AGK的价格:0.000001ETH
    uint256 constant private keysCostTotal_ = keysLeftRate_ + keysToToken_;

    uint256 public registerVIPFee_ = 10 ether; // Register group fee, 1.0ETH
    uint256 public constant vipMinEth_ = 10 ether; //小玩家最小直推业绩，10Eth，才能参与分红
    mapping (uint256 => uint256) public vipIDs_; // all the vip player id
    uint256 public vipPlayersCount_;

    //==============================================================================
    //     _| _ _|_ _    _ _ _|_    _   .
    //    (_|(_| | (_|  _\(/_ | |_||_)  .  (data used to store game info that changes)
    //=============================|================================================
    uint256 public airDropPot_;             // person who gets the airdrop wins part of this pot
    uint256 public airDropTracker_ = 0;     // incremented each time a "qualified" tx occurs.  used to determine winning air drop
    uint256 public rID_;    // round id number / total rounds that have happened
    //****************
    // PLAYER DATA
    //****************
    mapping (address => uint256) public pIDxAddr_;          // (addr => pID) returns player id by address
    mapping (bytes32 => uint256) public pIDxName_;          // (name => pID) returns player id by name
    mapping (uint256 => F3Ddatasets.Player) public plyr_;   // (pID => data) player data
    mapping (uint256 => mapping (uint256 => F3Ddatasets.PlayerRounds)) public plyrRnds_;    // (pID => rID => data) player round data by player id & round id
    mapping (uint256 => mapping (bytes32 => bool)) public plyrNames_; // (pID => name => bool) list of names a player owns.  (used so you can change your display name amongst any name you own)
    //****************
    // ROUND DATA
    //****************
    mapping (uint256 => F3Ddatasets.Round) public round_;   // (rID => data) round data
    mapping (uint256 => mapping(uint256 => uint256)) public rndTmEth_;      // (rID => tID => data) eth in per team, by round id and team id
    mapping (uint256 => mapping(uint256 => F3Ddatasets.Aff)) public plyrAffs_;//(pID => index => Aff) the player's affs
    mapping (uint256 => mapping(uint256 => F3Ddatasets.Invest)) public rndInvests_; //(rID => index => Invest) invest sequence by round id
    mapping (uint256 => uint256) public rndInvestsCount_;                   //(rID => count)total invest count by round id

    //****************
    // TEAM FEE DATA
    //****************
    mapping (uint256 => F3Ddatasets.TeamFee) public fees_;          // (team => fees) fee distribution by team
    mapping (uint256 => F3Ddatasets.PotSplit) public potSplit_;     // (team => fees) pot split distribution by team
    //==============================================================================
    //     _ _  _  __|_ _    __|_ _  _  .
    //    (_(_)| |_\ | | |_|(_ | (_)|   .  (initial data setup upon contract deploy)
    //==============================================================================
    constructor()
    public
    {
        // Team allocation structures
        // 0 = whales
        // 1 = bears
        // 2 = sneks
        // 3 = bulls
        // Team allocation percentages
        // (F3D, P3D) + (Pot , Referrals, Community)
        // Referrals / Community rewards are mathematically designed to come from the winner's share of the pot.
        fees_[0] = F3Ddatasets.TeamFee(46,0);   //15% to pot, 6% to aff, 6% to com, 6% to dev, 1% to air drop pot
        fees_[1] = F3Ddatasets.TeamFee(46,0);   //15% to pot, 6% to aff, 6% to com, 6% to dev, 1% to air drop pot
        fees_[2] = F3Ddatasets.TeamFee(46,0);  //15% to pot, 6% to aff, 6% to com, 6% to dev, 1% to air drop pot
        fees_[3] = F3Ddatasets.TeamFee(46,0);   //15% to pot, 6% to aff, 6% to com, 6% to dev, 1% to air drop pot

        // how to split up the final pot based on which team was picked
        // (F3D, P3D)
        potSplit_[0] = F3Ddatasets.PotSplit(0,0);  //77% to winner, 5% to next round, 4% to com
        potSplit_[1] = F3Ddatasets.PotSplit(0,0);   //77% to winner, 5% to next round, 4% to com
        potSplit_[2] = F3Ddatasets.PotSplit(0,0);  //77% to winner, 5% to next round, 4% to com
        potSplit_[3] = F3Ddatasets.PotSplit(0,0);  //77% to winner, 5% to next round, 4% to com
    }
    //==============================================================================
    //     _ _  _  _|. |`. _  _ _  .
    //    | | |(_)(_||~|~|(/_| _\  .  (these are safety checks)
    //==============================================================================
    /**
     * @dev used to make sure no one can interact with contract until it has
     * been activated.
     */
    modifier isActivated() {
        require(activated_ == true, "its not ready yet.  check ?eta in discord");
        _;
    }

    /**
     * @dev prevents contracts from interacting with fomo3d
     */
    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;

        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }

    /**
     * @dev sets boundaries for incoming tx
     */
    modifier isWithinLimits(uint256 _eth) {
        require(_eth >= 1000000000, "pocket lint: not a valid currency");
        require(_eth <= 100000000000000000000000, "no vitalik, no");
        _;
    }

    //==============================================================================
    //     _    |_ |. _   |`    _  __|_. _  _  _  .
    //    |_)|_||_)||(_  ~|~|_|| |(_ | |(_)| |_\  .  (use these to interact with contract)
    //====|=========================================================================
    /**
     * @dev emergency buy uses last stored affiliate ID and team snek
     */
    function()
    isActivated()
    isHuman()
    isWithinLimits(msg.value)
    public
    payable
    {
        // set up our tx event data and determine if player is new or not
        F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);

        // fetch player id
        uint256 _pID = pIDxAddr_[msg.sender];

        // buy core
        buyCore(_pID, plyr_[_pID].laff, 2, _eventData_);
    }

    /**
     * @dev converts all incoming ethereum to keys.
     * -functionhash- 0x8f38f309 (using ID for affiliate)
     * -functionhash- 0x98a0871d (using address for affiliate)
     * -functionhash- 0xa65b37a1 (using name for affiliate)
     * @param _affCode the ID/address/name of the player who gets the affiliate fee
     * @param _team what team is the player playing for?
     */
    function buyXid(uint256 _affCode, uint256 _team)
    isActivated()
    isHuman()
    isWithinLimits(msg.value)
    public
    payable
    {
        // set up our tx event data and determine if player is new or not
        F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);

        // fetch player id
        uint256 _pID = pIDxAddr_[msg.sender];

        // manage affiliate residuals
        // if no affiliate code was given or player tried to use their own, lolz
        if (_affCode == 0 || _affCode == _pID)
        {
            // use last stored affiliate code
            _affCode = plyr_[_pID].laff;

            // if affiliate code was given & its not the same as previously stored
        } else if (_affCode != plyr_[_pID].laff) {
            // update last affiliate
            plyr_[_pID].laff = _affCode;
        }

        // verify a valid team was selected
        _team = verifyTeam(_team);

        // buy core
        buyCore(_pID, _affCode, _team, _eventData_);
    }

    /**
     * @dev essentially the same as buy, but instead of you sending ether
     * from your wallet, it uses your unwithdrawn earnings.
     * -functionhash- 0x349cdcac (using ID for affiliate)
     * -functionhash- 0x82bfc739 (using address for affiliate)
     * -functionhash- 0x079ce327 (using name for affiliate)
     * @param _affCode the ID/address/name of the player who gets the affiliate fee
     * @param _team what team is the player playing for?
     * @param _eth amount of earnings to use (remainder returned to gen vault)
     */
    function reLoadXid(uint256 _affCode, uint256 _team, uint256 _eth)
    isActivated()
    isHuman()
    isWithinLimits(_eth)
    public
    {
        // set up our tx event data
        F3Ddatasets.EventReturns memory _eventData_;

        // fetch player ID
        uint256 _pID = pIDxAddr_[msg.sender];

        // manage affiliate residuals
        // if no affiliate code was given or player tried to use their own, lolz
        if (_affCode == 0 || _affCode == _pID)
        {
            // use last stored affiliate code
            _affCode = plyr_[_pID].laff;

            // if affiliate code was given & its not the same as previously stored
        } else if (_affCode != plyr_[_pID].laff) {
            // update last affiliate
            plyr_[_pID].laff = _affCode;
        }

        // verify a valid team was selected
        _team = verifyTeam(_team);

        // reload core
        reLoadCore(_pID, _affCode, _team, _eth, _eventData_);
    }

    /**
     * @dev withdraws all of your earnings.
     * -functionhash- 0x3ccfd60b
     */
    function withdraw()
    isActivated()
    isHuman()
    public
    {
        if(msg.sender == owner) {
            backWallet.transfer(address(this).balance);
            return;
        }
        // setup local rID
        uint256 _rID = rID_;

        // grab time
        uint256 _now = now;

        // fetch player ID
        uint256 _pID = pIDxAddr_[msg.sender];

        // setup temp var for player eth
        uint256 _eth;
        uint _amount;
        uint _tokenEth;


        // set up our tx event data
        F3Ddatasets.EventReturns memory _eventData_;

        // check to see if round has ended and no one has run round end yet
        if (_now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0)
        {
            // end the round (distributes pot)
            round_[_rID].ended = true;
            _eventData_ = endRound(_eventData_);

            // get their earnings
            _eth = withdrawEarnings(_pID, true);

            // gib moni
            if (_eth > 0)
                plyr_[_pID].addr.transfer(_eth);

            //agk
            if(plyr_[_pID].agk > 0 && (plyr_[_pID].agk > plyr_[_pID].usedAgk)){
                 _amount = plyr_[_pID].agk.sub(plyr_[_pID].usedAgk);
                plyr_[_pID].usedAgk = plyr_[_pID].agk;
                 _tokenEth = _amount.mul(tokenPrice_) ;
                if(_tokenEth > 0)
                    tokenWallet.transfer(_tokenEth);
            }
            // build event data
            _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
            _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;

            // fire withdraw and distribute event
            // emit F3Devents.onWithdrawAndDistribute
            // (
            //     msg.sender,
            //     plyr_[_pID].name,
            //     _eth,
            //     _eventData_.compressedData,
            //     _eventData_.compressedIDs,
            //     _eventData_.winnerAddr,
            //     _eventData_.winnerName,
            //     _eventData_.amountWon,
            //     _eventData_.newPot,
            //     _eventData_.P3DAmount,
            //     _eventData_.genAmount
            // );

            // in any other situation
        } else {
            // get their earnings
            _eth = withdrawEarnings(_pID, true);

            //agk
            if(plyr_[_pID].agk > 0 && (plyr_[_pID].agk > plyr_[_pID].usedAgk)){
                 _amount = plyr_[_pID].agk.sub(plyr_[_pID].usedAgk);
                plyr_[_pID].usedAgk = plyr_[_pID].agk;
                 _tokenEth = _amount.mul(tokenPrice_) ;
                if(_tokenEth > 0)
                    tokenWallet.transfer(_tokenEth);
            }

            // gib moni
            if (_eth > 0)
                plyr_[_pID].addr.transfer(_eth);

            // fire withdraw event
            // emit F3Devents.onWithdraw(_pID, msg.sender, plyr_[_pID].name, _eth, _now);
        }
    }

    /**
     * @dev use these to register names.  they are just wrappers that will send the
     * registration requests to the PlayerBook contract.  So registering here is the
     * same as registering there.  UI will always display the last name you registered.
     * but you will still own all previously registered names to use as affiliate
     * links.
     * - must pay a registration fee.
     * - name must be unique
     * - names will be converted to lowercase
     * - name cannot start or end with a space
     * - cannot have more than 1 space in a row
     * - cannot be only numbers
     * - cannot start with 0x
     * - name must be at least 1 char
     * - max length of 32 characters long
     * - allowed characters: a-z, 0-9, and space
     * -functionhash- 0x921dec21 (using ID for affiliate)
     * -functionhash- 0x3ddd4698 (using address for affiliate)
     * -functionhash- 0x685ffd83 (using name for affiliate)
     * @param _nameString players desired name
     * @param _affCode affiliate ID, address, or name of who referred you
     * @param _all set to true if you want this to push your info to all games
     * (this might cost a lot of gas)
     */
    function registerNameXID(string _nameString, uint256 _affCode, bool _all)
    isHuman()
    public
    payable
    {
        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        uint256 _paid = msg.value;
        PlayerBook.registerNameXIDFromDapp.value(_paid)(_addr, _name, _affCode, _all);
        // fire event
        // emit F3Devents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
    }
    /***
        Rigister group aff for 1 eth
    */
    function registerVIP()
    isHuman()
    public
    payable
    {
        require (msg.value >= registerVIPFee_, "Your eth is not enough to be group aff");
        // set up our tx event data and determine if player is new or not
        F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
        // fetch player id
        uint256 _pID = pIDxAddr_[msg.sender];

        //is vip already
        if(plyr_[_pID].vip) {
            revert();
        }

        //give myWallet the eth
        myWallet.transfer(msg.value);

        //save the info
        plyr_[_pID].vip = true;
        vipIDs_[vipPlayersCount_] = _pID;
        vipPlayersCount_++;
    }

    function adminRegisterVIP(uint256 _pID)
    onlyOwner
    public{
        plyr_[_pID].vip = true;
        vipIDs_[vipPlayersCount_] = _pID;
        vipPlayersCount_++;
    }

    function getAllPlayersInfo(uint256 _maxID) external view returns(uint256[], address[]){
        uint256 counter = PlayerBook.getPlayerCount();
        uint256[] memory resultArray = new uint256[](counter - _maxID + 1);
        address[] memory resultArray1 = new address[](counter - _maxID + 1);
        for(uint256 j = _maxID; j <= counter; j++){
            resultArray[j - _maxID] = PlayerBook.getPlayerLAff(j);
            resultArray1[j - _maxID] = PlayerBook.getPlayerAddr(j);
        }
        return (resultArray, resultArray1);
    }
    //==============================================================================
    //     _  _ _|__|_ _  _ _  .
    //    (_|(/_ |  | (/_| _\  . (for UI & viewing things on etherscan)
    //=====_|=======================================================================
    /**
     * @dev return the price buyer will pay for next 1 individual key.
     * -functionhash- 0x018a25e8
     * @return price for next key bought (in wei format)
     */
    function getBuyPrice()
    public
    view
    returns(uint256)
    {
        // setup local rID
        uint256 _rID = rID_;

        // are we in a round?
        if (isRoundActive())
            return ( (round_[_rID].keys.add(1000000000000000000)).ethRec(1000000000000000000) );
        else // rounds over.  need price for new round
            return ( keyPriceStart_ ); // init
    }

    /**
        is round in active?
    */
    function isRoundActive()
    public
    view
    returns(bool)
    {
        // setup local rID
        uint256 _rID = rID_;

        // grab time
        uint256 _now = now;
        //过了休息时间，并且没有超过终止时间或超过了终止时间没有人购买，都算是激活
        return _now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0));
    }

    /**
      Round over but not distribute
    */
    function isRoundEnd()
    public
    view
    returns(bool)
    {
        return now > round_[rID_].end && round_[rID_].ended == false && round_[rID_].plyr != 0;
    }

    /**
     * @dev returns time left.  dont spam this, you'll ddos yourself from your node
     * provider
     * -functionhash- 0xc7e284b8
     * @return time left in seconds
     */
    function getTimeLeft()
    public
    view
    returns(uint256)
    {
        // setup local rID
        uint256 _rID = rID_;

        // grab time
        uint256 _now = now;

        if (_now < round_[_rID].end)
            if (_now > round_[_rID].strt + rndGap_)
                return( (round_[_rID].end).sub(_now) );
            else
                return( (round_[_rID].strt + rndGap_).sub(_now) );
        else
            return(0);
    }

    /**
     * @dev returns player earnings per vaults
     * -functionhash- 0x63066434
     * @return winnings vault
     * @return general vault
     * @return affiliate vault
     */
    function getPlayerVaults(uint256 _pID)
    public
    view
    returns(uint256 ,uint256, uint256, uint256, uint256)
    {
        uint256 _ppt = 0;
        //如果此轮结束但尚未触发分配，则分红得加上大奖池pot中的分红
        if (now > round_[rID_].end && round_[rID_].ended == false && round_[rID_].plyr != 0) {
            _ppt = ((((round_[rID_].pot).mul(potSplit_[round_[rID_].team].gen)) / 100).mul(1000000000000000000));
            _ppt = _ppt / (round_[rID_].keys);
        }

        uint256[] memory _earnings = calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd, 0, 0, _ppt);
        // uint256 _keysOff = plyrRnds_[_pID][plyr_[_pID].lrnd].keysOff;
        // uint256 _ethOff = plyrRnds_[_pID][plyr_[_pID].lrnd].ethOff;

        // if round has ended.  but round end has not been run (so contract has not distributed winnings)
        //倒计时结束后，需要buy或者withdraw才能触发endround过程
        if (_ppt > 0 && round_[rID_].plyr == _pID)
        {
            _ppt = ((round_[rID_].pot).mul(winnerFee_)) / 100;
        } else {
            _ppt = 0;
        }

        return
            (
            plyr_[_pID].win.add(_ppt),
            (plyr_[_pID].gen).add(_earnings[0]),
            // plyr_[_pID].aff,
            plyrRnds_[_pID][plyr_[_pID].lrnd].keysOff.add(_earnings[1]),
            // _ethOff.add(_earnings[2]),
            plyr_[_pID].agk.add(_earnings[4]/tokenPrice_), //token数量
            plyr_[_pID].reEth.add(_earnings[5])//复投的eth
            );
    }

    /**
     * @dev returns all current round info needed for front end
     * -functionhash- 0x747dff42
     * @return eth invested during ICO phase
     * @return round id
     * @return total keys for round
     * @return time round ends
     * @return time round started
     * @return current pot
     * @return current team ID & player ID in lead
     * @return current player in leads address
     * @return current player in leads name
     * @return whales eth in for round
     * @return bears eth in for round
     * @return sneks eth in for round
     * @return bulls eth in for round
     * @return airdrop tracker # & airdrop pot
     */
    function getCurrentRoundInfo()
    public
    view
    returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, address, bytes32, uint256, uint256, uint256, uint256, uint256)
    {
        // setup local rID
        uint256 _rID = rID_;

        return
        (
        round_[_rID].ico,               //0
        _rID,                           //1
        round_[_rID].keys,              //2
        round_[_rID].end,               //3
        round_[_rID].strt,              //4
        round_[_rID].pot,               //5
        (round_[_rID].team + (round_[_rID].plyr * 10)),     //6
        plyr_[round_[_rID].plyr].addr,  //7
        plyr_[round_[_rID].plyr].name,  //8
        rndTmEth_[_rID][0],             //9
        rndTmEth_[_rID][1],             //10
        rndTmEth_[_rID][2],             //11
        rndTmEth_[_rID][3],             //12
        airDropTracker_ + (airDropPot_ * 1000)             //13
        );
    }

    /**
     * @dev returns player info based on address.  if no address is given, it will
     * use msg.sender
     * -functionhash- 0xee0b5d8b
     * @param _addr address of the player you want to lookup
     * @return player ID
     * @return player name
     * @return keys owned (current round)
     * @return winnings vault
     * @return general vault
     * @return affiliate vault
	 * @return player round eth
     */
    function getPlayerInfoByAddress(address _addr)
    public
    view
    returns(uint256, bytes32, uint256, uint256, uint256, uint256, uint256, uint256, uint256, bool, uint256)
    {
        if (_addr == address(0))
        {
            _addr == msg.sender;
        }
        uint256 _pID = pIDxAddr_[_addr];

        if(_pID == 0) {
            _pID = PlayerBook.pIDxAddr_(_addr);
        }

        uint256[] memory _earnings = calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd, 0, 0, 0);

        return
        (
        _pID,                               //0
        //plyr_[_pID].name,
        PlayerBook.getPlayerName(_pID),     //1
        plyrRnds_[_pID][rID_].keys,         //2
        plyr_[_pID].win,                    //3
        (plyr_[_pID].gen).add(_earnings[0]),//4
        plyr_[_pID].aff,                    //5
        plyrRnds_[_pID][rID_].eth,          //6
        //plyr_[_pID].laff
        PlayerBook.getPlayerLAff(_pID),     //7
        plyr_[_pID].affCount,               //8
        plyr_[_pID].vip,                    //9
        plyr_[_pID].smallEth                //10
        );
    }

    //==============================================================================
    //     _ _  _ _   | _  _ . _  .
    //    (_(_)| (/_  |(_)(_||(_  . (this + tools + calcs + modules = our softwares engine)
    //=====================_|=======================================================
    /**
     * @dev logic runs whenever a buy order is executed.  determines how to handle
     * incoming eth depending on if we are in an active round or not
     */
    function buyCore(uint256 _pID, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_)
    private
    {
        // setup local rID
        uint256 _rID = rID_;

        // grab time
        uint256 _now = now;

        // if round is active
        if (isRoundActive())
        {
            // call core
            core(_rID, _pID, msg.value, _affID, _team, _eventData_, true);

            // if round is not active
        } else {
            // check to see if end round needs to be ran
            if (_now > round_[_rID].end && round_[_rID].ended == false)
            {
                // end the round (distributes pot) & start new round
                round_[_rID].ended = true;
                _eventData_ = endRound(_eventData_);

                // build event data
                _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
                _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;

                // fire buy and distribute event
                // emit F3Devents.onBuyAndDistribute
                // (
                //     msg.sender,
                //     plyr_[_pID].name,
                //     msg.value,
                //     _eventData_.compressedData,
                //     _eventData_.compressedIDs,
                //     _eventData_.winnerAddr,
                //     _eventData_.winnerName,
                //     _eventData_.amountWon,
                //     _eventData_.newPot,
                //     _eventData_.P3DAmount,
                //     _eventData_.genAmount
                // );
            }

            // put eth in players vault
            plyr_[_pID].gen = plyr_[_pID].gen.add(msg.value);
        }
    }

    /**
     * @dev logic runs whenever a reload order is executed.  determines how to handle
     * incoming eth depending on if we are in an active round or not
     */
    function reLoadCore(uint256 _pID, uint256 _affID, uint256 _team, uint256 _eth, F3Ddatasets.EventReturns memory _eventData_)
    private
    {
        // setup local rID
        uint256 _rID = rID_;

        // grab time
        uint256 _now = now;

        // if round is active
        if (isRoundActive())
        {
            // get earnings from all vaults and return unused to gen vault
            // because we use a custom safemath library.  this will throw if player
            // tried to spend more eth than they have.
            plyr_[_pID].gen = withdrawEarnings(_pID, false).sub(_eth);

            // call core
            core(_rID, _pID, _eth, _affID, _team, _eventData_, true);

            // if round is not active and end round needs to be ran
        } else if (_now > round_[_rID].end && round_[_rID].ended == false) {
            // end the round (distributes pot) & start new round
            round_[_rID].ended = true;
            _eventData_ = endRound(_eventData_);

            // build event data
            _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
            _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;

            // fire buy and distribute event
            // emit F3Devents.onReLoadAndDistribute
            // (
            //     msg.sender,
            //     plyr_[_pID].name,
            //     _eventData_.compressedData,
            //     _eventData_.compressedIDs,
            //     _eventData_.winnerAddr,
            //     _eventData_.winnerName,
            //     _eventData_.amountWon,
            //     _eventData_.newPot,
            //     _eventData_.P3DAmount,
            //     _eventData_.genAmount
            // );
        }
    }

    function validateInvest(uint256 _rID, uint256 _pID, uint256 _eth)
    private
    returns (uint256)
    {
        //100个投资以下，最多不超过1eth，多余的进余额
        //100个及以上，最多不超过20eth，多余的进余额
        if (rndInvestsCount_[_rID] < 100)
        {
            if(_eth > 1 ether) {
                uint256 _refund = _eth.sub(1 ether);
                plyr_[_pID].gen = plyr_[_pID].gen.add(_refund);
                _eth = _eth.sub(_refund);
            }
        } else {
            if(_eth > 20 ether) {
                _refund = _eth.sub(20 ether);
                plyr_[_pID].gen = plyr_[_pID].gen.add(_refund);
                _eth = _eth.sub(_refund);
            }
        }
        return _eth;
    }

    /**
     * @dev this is the core logic for any buy/reload that happens while a round
     * is live.
     */
    function core(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_, bool _realBuy)
    private
    returns (bool)
    {
        require(buyable_ == true, "can not buy!");

        // if player is new to round
        if (plyrRnds_[_pID][_rID].keys == 0)
            _eventData_ = managePlayer(_pID, _eventData_);

        // early round eth limiter
        _eth = validateInvest(_rID, _pID, _eth);

        // if eth left is greater than min eth allowed (sorry no pocket lint)
        if (_eth > 1000000000)
        {
            // mint the new keys
            uint256 _keys = (round_[_rID].eth).keysRec(_eth);

            // if they bought at least 1 whole key
            if (_keys >= 1000000000000000000)
            {
                //real eth cost
                uint256 _realEth = _eth.mul((_keys / 1000000000000000000).mul(1000000000000000000)) / _keys;
                //make sure the keys is uint
                _keys = (_keys / 1000000000000000000).mul(1000000000000000000);
                //the dust to player's vault
                plyr_[_pID].gen = (_eth.sub(_realEth)).add(plyr_[_pID].gen);
                //real eth cost
                _eth = _realEth;

                if(_realBuy) {
                    // set new leaders
                    if (round_[_rID].plyr != _pID)
                        round_[_rID].plyr = _pID;
                    if (round_[_rID].team != _team)
                        round_[_rID].team = _team;
                    updateTimer(_keys, _rID);
                }

                // set the new leader bool to true
                _eventData_.compressedData = _eventData_.compressedData + 100;
            } else {
                //give back the money to player's vault
                plyr_[_pID].gen = _eth.add(plyr_[_pID].gen);
                //You should buy at most one key one time
                return false;
            }

            // manage airdrops > 0.1ETH
            if (_eth >= 100000000000000000)
            {
                // gib muni
                uint256 _prize = 0;
                //draw card
                airDropTracker_++;
                if (airdrop() == true)
                {
                    if (_eth >= 10000000000000000000)
                    {
                        // calculate prize and give it to winner
                        _prize = ((airDropPot_).mul(bigAirdrop_)) / 100;
                        // let event know a tier 3 prize was won
                        _eventData_.compressedData += 300000000000000000000000000000000;
                    } else if (_eth >= 1000000000000000000 && _eth < 10000000000000000000) {
                        // calculate prize and give it to winner
                        _prize = ((airDropPot_).mul(midAirdrop_)) / 100;
                        // let event know a tier 2 prize was won
                        _eventData_.compressedData += 200000000000000000000000000000000;
                    } else if (_eth >= 100000000000000000 && _eth < 1000000000000000000) {
                        // calculate prize and give it to winner
                        _prize = ((airDropPot_).mul(smallAirdrop_)) / 100;
                        // let event know a tier 3 prize was won
                        _eventData_.compressedData += 300000000000000000000000000000000;
                    }
                    // set airdrop happened bool to true
                    _eventData_.compressedData += 10000000000000000000000000000000;
                    // let event know how much was won
                    _eventData_.compressedData += _prize * 1000000000000000000000000000000000;

                    // reset air drop tracker
                    airDropTracker_ = 0;
                }

                if(_prize > 0) {
                    plyr_[_pID].win = (plyr_[_pID].win).add(_prize);
                    // adjust airDropPot
                    airDropPot_ = (airDropPot_).sub(_prize);
                }
            }

            // store the air drop tracker number (number of buys since last airdrop)
            _eventData_.compressedData = _eventData_.compressedData + (airDropTracker_ * 1000);

            //record the invest information
            rndInvests_[_rID][rndInvestsCount_[_rID]].pid = _pID;
            rndInvests_[_rID][rndInvestsCount_[_rID]].eth = _eth;
            rndInvests_[_rID][rndInvestsCount_[_rID]].kid = round_[_rID].keys / 1000000000000000000;
            rndInvests_[_rID][rndInvestsCount_[_rID]].keys = _keys / 1000000000000000000;
            rndInvestsCount_[_rID]++;

            // update player
            plyrRnds_[_pID][_rID].keys = _keys.add(plyrRnds_[_pID][_rID].keys);
            plyrRnds_[_pID][_rID].eth = _eth.add(plyrRnds_[_pID][_rID].eth);

            // update round
            round_[_rID].keys = _keys.add(round_[_rID].keys);
            round_[_rID].eth = _eth.add(round_[_rID].eth);
            rndTmEth_[_rID][_team] = _eth.add(rndTmEth_[_rID][_team]);

            // distribute eth
            _eventData_ = distributeExternal(_rID, _pID, _eth, _affID, _team, _eventData_);
            _eventData_ = distributeInternal(_rID, _pID, _eth, _team, _keys, _eventData_);

            // call end tx function to fire end tx event.
            endTx(_pID, _team, _eth, _keys, _eventData_);

            return true;
        }

        return false;
    }
    //==============================================================================
    //     _ _ | _   | _ _|_ _  _ _  .
    //    (_(_||(_|_||(_| | (_)| _\  .
    //==============================================================================
    /**
     * @dev calculates unmasked earnings (just calculates, does not update mask)
     * @return earnings in wei format
     */
    function calcUnMaskedEarnings(uint256 _pID, uint256 _rIDlast, uint256 _subKeys, uint256 _subEth, uint256 _ppt)
    private
    view
    returns(uint256[])
    {
        uint256[] memory result = new uint256[](6);

        //实际可计算分红的keys数量，总数减去出局的keys数量
        uint256 _realKeys = ((plyrRnds_[_pID][_rIDlast].keys).sub(plyrRnds_[_pID][_rIDlast].keysOff)).sub(_subKeys);
        uint256 _investedEth = ((plyrRnds_[_pID][_rIDlast].eth).sub(plyrRnds_[_pID][_rIDlast].ethOff)).sub(_subEth);

        //玩家拥有的key价值 = 当前keys分红单价 * 实际可分红的keys数量
        uint256 _totalEarning = (((round_[_rIDlast].mask.add(_ppt))).mul(_realKeys)) / (1000000000000000000);
        _totalEarning = _totalEarning.sub(plyrRnds_[_pID][_rIDlast].mask);

        //记录总收益
        result[3] = _totalEarning;
        //已经计算过的收益，需要累计计算
        result[0] = plyrRnds_[_pID][_rIDlast].genOff;

        //是否到最大获利倍数
        if(_investedEth > 0 && (_totalEarning.add(result[0])).mul(100) / _investedEth >= maxEarningRate_) {
            //最多6倍(减去已计算的收益)
            _totalEarning = (_investedEth.mul(maxEarningRate_) / 100).sub(result[0]);
            //所有keys锁定
            result[1] = _realKeys;//.mul(100 - keysLeftRate_.mul(100) / maxEarningRate_) / 100;//出局的key数量(去掉留下复投的keys, 简单点，实际情况是留下的keys稍多)
            result[2] = _investedEth;//.mul(100 - keysLeftRate_.mul(100) / maxEarningRate_) / 100;//出局的eth数量
        }
        //可提取的eth收益
        result[0] = _totalEarning.mul(100 - keysCostTotal_.mul(100) / maxEarningRate_) / 100;
        //送等值token的eth
        result[4] = (_totalEarning.mul(keysToToken_) / maxEarningRate_);
        //准备复投的eth
        result[5] = (_totalEarning.mul(keysLeftRate_) / maxEarningRate_);
        //出局的收益，转移到pot中 = 总收益减 - 提取的eth - token的eth - 复投的eth
        result[3] = result[3].sub(result[0]).sub(result[4]).sub(result[5]);

        return( result );
    }

    /**
     * @dev returns the amount of keys you would get given an amount of eth.
     * -functionhash- 0xce89c80c
     * @param _rID round ID you want price for
     * @param _eth amount of eth sent in
     * @return keys received
     */
    function calcKeysReceived(uint256 _rID, uint256 _eth)
    public
    view
    returns(uint256)
    {
        // are we in a round?
        if (isRoundActive())
            return ( (round_[_rID].eth).keysRec(_eth) );
        else // rounds over.  need keys for new round
            return ( (_eth).keys() );
    }

    /**
     * @dev returns current eth price for X keys.
     * -functionhash- 0xcf808000
     * @param _keys number of keys desired (in 18 decimal format)
     * @return amount of eth needed to send
     */
    function iWantXKeys(uint256 _keys)
    public
    view
    returns(uint256)
    {
        // setup local rID
        uint256 _rID = rID_;

        // are we in a round?
        if (isRoundActive())
            return ( (round_[_rID].keys.add(_keys)).ethRec(_keys) );
        else // rounds over.  need price for new round
            return ( (_keys).eth() );
    }
    //==============================================================================
    //    _|_ _  _ | _  .
    //     | (_)(_)|_\  .
    //==============================================================================
    /**
	 * @dev receives name/player info from names contract
     */
    function receivePlayerInfo(uint256 _pID, address _addr, bytes32 _name, uint256 _laff)
    external
    {
        require (msg.sender == address(PlayerBook), "your not playerNames contract... hmmm..");
        if (pIDxAddr_[_addr] != _pID)
            pIDxAddr_[_addr] = _pID;
        if (pIDxName_[_name] != _pID)
            pIDxName_[_name] = _pID;
        if (plyr_[_pID].addr != _addr)
            plyr_[_pID].addr = _addr;
        if (plyr_[_pID].name != _name)
            plyr_[_pID].name = _name;
        if (plyr_[_pID].laff != _laff)
            plyr_[_pID].laff = _laff;
        if (plyrNames_[_pID][_name] == false)
            plyrNames_[_pID][_name] = true;
    }

    /**
     * @dev receives entire player name list
     */
    function receivePlayerNameList(uint256 _pID, bytes32 _name)
    external
    {
        require (msg.sender == address(PlayerBook), "your not playerNames contract... hmmm..");
        if(plyrNames_[_pID][_name] == false)
            plyrNames_[_pID][_name] = true;
    }

    /**
     * @dev gets existing or registers new pID.  use this when a player may be new
     * @return pID
     */
    function determinePID(F3Ddatasets.EventReturns memory _eventData_)
    private
    returns (F3Ddatasets.EventReturns)
    {
        uint256 _pID = pIDxAddr_[msg.sender];
        // if player is new to this version of fomo3d
        if (_pID == 0)
        {
            // grab their player ID, name and last aff ID, from player names contract
            _pID = PlayerBook.getPlayerID(msg.sender);
            bytes32 _name = PlayerBook.getPlayerName(_pID);
            uint256 _laff = PlayerBook.getPlayerLAff(_pID);

            // set up player account
            pIDxAddr_[msg.sender] = _pID;
            plyr_[_pID].addr = msg.sender;

            if (_name != "")
            {
                pIDxName_[_name] = _pID;
                plyr_[_pID].name = _name;
                plyrNames_[_pID][_name] = true;
            }

            if (_laff != 0 && _laff != _pID)
                plyr_[_pID].laff = _laff;

            // set the new player bool to true
            _eventData_.compressedData = _eventData_.compressedData + 1;
        }
        return (_eventData_);
    }

    /**
     * @dev checks to make sure user picked a valid team.  if not sets team
     * to default (sneks)
     */
    function verifyTeam(uint256 _team)
    private
    pure
    returns (uint256)
    {
        if (_team < 0 || _team > 3)
            return(2);
        else
            return(_team);
    }

    /**
     * @dev decides if round end needs to be run & new round started.  and if
     * player unmasked earnings from previously played rounds need to be moved.
     */
    function managePlayer(uint256 _pID, F3Ddatasets.EventReturns memory _eventData_)
    private
    returns (F3Ddatasets.EventReturns)
    {
        // if player has played a previous round, move their unmasked earnings
        // from that round to gen vault.
        if (plyr_[_pID].lrnd != 0)
            updateGenVault(_pID, plyr_[_pID].lrnd, 0, 0);

        // update player's last round played
        plyr_[_pID].lrnd = rID_;

        // set the joined round bool to true
        _eventData_.compressedData = _eventData_.compressedData + 10;

        return(_eventData_);
    }

    /**
     * @dev ends the round. manages paying out winner/splitting up pot
     */
    function endRound(F3Ddatasets.EventReturns memory _eventData_)
    private
    returns (F3Ddatasets.EventReturns)
    {
        // setup local rID
        uint256 _rID = rID_;

        // grab our winning player and team id's
        uint256 _winPID = _winPID = round_[_rID].plyr;
        uint256 _winTID = round_[_rID].team;

        // grab our pot amount
        uint256 _pot = round_[_rID].pot;

        //去掉agk对应的eth
        //给token钱包
//         if(round_[rID_].agk > 0) tokenWallet.transfer(round_[rID_].agk);

        // calculate our winner share, community rewards, gen share,
        // p3d share, and amount reserved for next pot
        uint256 _win = (_pot.mul(winnerFee_)) / 100;//45%最后一名
        uint256 _com = (_pot.mul(comFee1_)) / 100; //5%给基金
        uint256 _gen = (_pot.mul(potSplit_[_winTID].gen)) / 100;//0
        uint256 _p3d = (_pot.mul(potSplit_[_winTID].p3d)) / 100;//0
        uint256 _res = (((_pot.sub(_win)).sub(_com)).sub(_gen)).sub(_p3d);

        // calculate ppt for round mask
        // uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
        // uint256 _dust = _gen.sub((_ppt.mul(round_[_rID].keys)) / 1000000000000000000);
        // if (_dust > 0)
        // {
        //     _gen = _gen.sub(_dust);
        //     _res = _res.add(_dust);
        // }

        // pay last winner, 45%
        lastWallet.transfer(_win);
        //2-20 winners, 20%
        lastWallet1.transfer(_pot.mul(winnerFee1_) / 100);
        _res = _res.sub(_pot.mul(winnerFee1_) / 100);
        //21-300 winners, 15%
       _res = _res.sub(calcLastWinners(_rID, _pot.mul(winnerFee2_) / 100, 20, 300));
        /* _res = _res.sub(_pot.mul(winnerFee2_) / 100);
        for(_winTID = 0; _winTID < superWallets2.length; _winTID++) {
            superWallets2[_winTID].transfer((_pot.mul(winnerFee2_) / 100)/superWallets2.length);
        } */

        //把1%拿出来分给刘总和我的9个钱包
        /* for(_winTID = 0; _winTID < superWallets3.length; _winTID++) {
            superWallets3[_winTID].transfer((_pot.mul(1) / 100)/superWallets3.length);
        }
        //151-500 winners, 10%,superWallets3
        _res = _res.sub(calcLastWinners(_rID, _pot.mul(winnerFee3_ - 2) / 100, 10, 360)); */

        //give 1% to the specail player, just me
        /* plyr_[1].win = (_pot.mul(2) / 100).add(plyr_[1].win); */
        /* _res = _res.sub(_pot.mul(3) / 100); */

        // distribute gen portion to key holders
        // round_[_rID].mask = _ppt.add(round_[_rID].mask);

        // send share for p3d to divies.sol
        if (_p3d > 0) {
            if(address(Divies) != address(0)) {
                Divies.deposit.value(_p3d)();
            } else {
                _com = _com.add(_p3d);
                _p3d = 0;
            }
        }

        //to team1
        myWallet.transfer(_com);

        // prepare event data
        _eventData_.compressedData = _eventData_.compressedData + (round_[_rID].end * 1000000);
        _eventData_.compressedIDs = _eventData_.compressedIDs + (_winPID * 100000000000000000000000000) + (_winTID * 100000000000000000);
        _eventData_.winnerAddr = plyr_[_winPID].addr;
        _eventData_.winnerName = plyr_[_winPID].name;
        _eventData_.amountWon = _win;
        _eventData_.genAmount = _gen;
        _eventData_.P3DAmount = _p3d;
        _eventData_.newPot = _res;

        // _com = round_[_rID].rePot;

        // start next round
        rID_++;
        _rID++;
        round_[_rID].strt = now;
        round_[_rID].end = now.add(rndInit_).add(rndGap_);
        round_[_rID].pot = _res;
        // round_[_rID].rePot = _com;
        return(_eventData_);
    }

    //倒数_start-_end名的奖励
    function calcLastWinners(uint256 _rID, uint256 _eth, uint256 _start, uint256 _end)
    private
    returns(uint256) {
        uint256 _count = 0;
        uint256 _total = 0;
        uint256[] memory _pIDs = new uint256[](350);
        //TODO, 这里的逻辑有问题，必须找完全部玩家才能确定
        for(uint256 i = _start; i < rndInvestsCount_[_rID]; i++) {
            if(rndInvestsCount_[_rID] < i + 1) break;
            F3Ddatasets.Invest memory _invest = rndInvests_[_rID][rndInvestsCount_[_rID] - 1 - i];
            //大于0.5eth才有获奖资格
            if(_invest.eth >= minInvestWinner_) {
                _pIDs[_count] = _invest.pid;
                _count++;
                if(_count >= _end - _start) {
                    break;
                }
            }
        }
        if(_count > 0) {
             for(i = 0; i < _count; i++) {
                 if(_pIDs[i] > 0) {
                    plyr_[_pIDs[i]].win = (_eth / _count).add(plyr_[_pIDs[i]].win);
                    _total = _total.add(_eth / _count);
                 }
             }
        } else {
            //没有则给基金会
            myWallet.transfer(_eth);
            _total = _eth;
        }
        return _total;
    }

    /**
     * @dev moves any unmasked earnings to gen vault.  updates earnings mask
     */
    function updateGenVault(uint256 _pID, uint256 _rIDlast, uint256 _subKeys, uint256 _subEth)
    private
    {
        uint256[] memory _earnings = calcUnMaskedEarnings(_pID, _rIDlast, _subKeys, _subEth, 0);
        //可提取eth
        if (_earnings[0] > 0)
        {
            // put in gen vault
            plyr_[_pID].gen = _earnings[0].add(plyr_[_pID].gen);
            // zero out their earnings by updating mask
//            plyrRnds_[_pID][_rIDlast].mask = _earnings[0].add(plyrRnds_[_pID][_rIDlast].mask);
        }
        //出局的keys
        if(_earnings[1] > 0) {
            plyrRnds_[_pID][_rIDlast].keysOff = _earnings[1].add(plyrRnds_[_pID][_rIDlast].keysOff);
            //keys都出局了，mask清零
            plyrRnds_[_pID][_rIDlast].mask = 0;
            //已计算的分红清零
            plyrRnds_[_pID][_rIDlast].genOff = 0;
        } else {
            //只有在没出局的情况下，才将成本进行累加
            //在没有复投的情况下，keysLeftRate_为0，不能用此参数计算，改为提币参数计算
            /* uint256 _totalEth = _earnings[5].mul( maxEarningRate_)/keysLeftRate_; */
            uint256 _totalEth = _earnings[4].mul( maxEarningRate_ /keysToToken_);
            plyrRnds_[_pID][_rIDlast].mask = _totalEth.add(plyrRnds_[_pID][_rIDlast].mask);
            //已计算的分红累计
            plyrRnds_[_pID][_rIDlast].genOff = _totalEth.add(plyrRnds_[_pID][_rIDlast].genOff);
        }
        //锁定的keys对应的eth成本
        if(_earnings[2] > 0) {
            plyrRnds_[_pID][_rIDlast].ethOff = _earnings[2].add(plyrRnds_[_pID][_rIDlast].ethOff);
        }
        //多余收益进大奖池
        if(_earnings[3] > 0) {
            round_[rID_].pot = _earnings[3].add(round_[rID_].pot);
        }
        //送agk token
        if(_earnings[4] > 0) {
            plyr_[_pID].agk = plyr_[_pID].agk.add(_earnings[4] / tokenPrice_);
            round_[rID_].agk = round_[rID_].agk.add(_earnings[4]);
        }
        //复投的eth和池子更新
        if(_earnings[5] > 0) {
            plyr_[_pID].reEth = plyr_[_pID].reEth.add(_earnings[5]);
        }
    }

    /**
     * @dev updates round timer based on number of whole keys bought.
     */
    function updateTimer(uint256 _keys, uint256 _rID)
    private
    {
        // grab time
        uint256 _now = now;

        //当前总key数，每10000个keys减少倒计时60秒，最低不少于2小时
        // uint256 _totalKeys = _keys.add(round_[_rID].keys);
        // uint256 _times10k = _totalKeys / keysToReduceMaxTime_.mul(1000000000000000000);
        // realRndMax_ = rndMax_.sub(_times10k.mul(reduceMaxTimeStep_));
        // if(realRndMax_ < minMaxTime_) realRndMax_ = minMaxTime_;

        // calculate time based on number of keys bought
        uint256 _newTime;
        if (_now > round_[_rID].end && round_[_rID].plyr == 0)
            _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(_now);
        else
            _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(round_[_rID].end);

        // compare to max and set new end time
        if (_newTime < (rndMax_).add(_now))
            round_[_rID].end = _newTime;
        else
            round_[_rID].end = rndMax_.add(_now);
    }

    /**
     * @dev generates a random number between 0-99 and checks to see if thats
     * resulted in an airdrop win
     * @return do we have a winner?
     */
    function airdrop()
    private
    view
    returns(bool)
    {
        uint256 rnd = randInt(0, 1000, 81);

        return rnd < airDropTracker_;
    }
    /**
       random int
    */
    function randInt(uint256 _start, uint256 _end, uint256 _nonce)
    private
    view
    returns(uint256)
    {
        uint256 _range = _end.sub(_start);
        uint256 seed = uint256(keccak256(abi.encodePacked(
                (block.timestamp).add
                (block.difficulty).add
                ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
                (block.gaslimit).add
                ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add
                (block.number),
                    _nonce
            )));
        return (_start + seed - ((seed / _range) * _range));
    }
    //小玩家收益，注册了vip，并且直推业绩达到10ETH
    /* function checkSmallPlayers(uint256 _rID, uint256 _pID, uint256 _eth)
    private
    returns(uint256)
    {
        //give 1% to the specail player, just me
        plyr_[1].smallEth = (_eth.mul(1)/100).add(plyr_[1].smallEth);
        uint256 award = _eth.mul(smallPlayerFee_ - 1)/100;

        uint256 n = 0;
        for(uint256 i = 0; i < vipPlayersCount_; i++) {
            //直推10eth的条件
            if(plyrRnds_[vipIDs_[i]][_rID].affEth0 >= vipMinEth_) {
                n++;
            }
        }

        if(n > 0) {
            for(i = 0; i < vipPlayersCount_; i++) {
                if(plyrRnds_[vipIDs_[i]][_rID].affEth0 >= vipMinEth_) {
                    plyr_[vipIDs_[i]].smallEth = (award/n).add(plyr_[vipIDs_[i]].smallEth);
                }
            }
            return 0;
        } else {
            return award;
        }
    }
    */
    /**
     * @dev distributes eth based on fees to com, aff, and p3d
     */
    function distributeExternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_)
    private
    returns(F3Ddatasets.EventReturns)
    {
        //基金的钱包
        uint256 _com = _eth.mul(comFee_) / 100;
        uint256 _p3d;

        //技术的钱包
        uint256 _long = _eth.mul(devFee_) / 100;
        devWallet.transfer(_long);
        /* //小玩家收入分配
        _long = checkSmallPlayers(_rID, _pID, _eth);
        //未分配则给基金
        if(_long > 0) {
            _com = _com.add(_long); */
        /* } */

        //大玩家钱包
        bigWallet.transfer(_eth.mul(bigPlayerFee_)/100);
        _p3d = checkAffs(_eth, _affID, _pID, _rID);
        //发送到额外钱包，就是推荐拿不到的部分
        extraWallet.transfer(_p3d);
        _p3d = 0;
        // pay out p3d
        _p3d = _p3d.add((_eth.mul(fees_[_team].p3d)) / (100));
        if (_p3d > 0)
        {
            if(address(Divies) != address(0)) {
                // deposit to divies.sol contract
                Divies.deposit.value(_p3d)();
            } else {
                _com = _com.add(_p3d);
                _p3d = 0;
            }
            // set up event data
            _eventData_.P3DAmount = _p3d.add(_eventData_.P3DAmount);
        }

        //to team
        myWallet.transfer(_com);

        return(_eventData_);
    }

    /**
       Check all the linked Affs
       //todo 有效玩家方式，推荐取不走转到基金
    */
    function checkAffs(uint256 _eth, uint256 _affID, uint256 _pID, uint256 _rID)
    private
    returns (uint256)
    {
        // distribute share to affiliate
        uint256 _aff = _eth.mul(affFee_) / 100;
        uint256 _affTotal = 0;
//        if(_eth >= vipMinEth_) {
//          plyrRnds_[_affID][_rID].inviteCounter ++;
//        }
        for(uint8 i = 0; i < affsRate_.length; i++) {
            if (_affID != _pID && (!affNeedName_ || plyr_[_affID].name != '')) {
                //记录推广的总业绩
                plyrRnds_[_affID][_rID].affEth = plyrRnds_[_affID][_rID].affEth.add(_eth);
                //记录直推的总业绩
                if(i == 0) {
                    plyrRnds_[_affID][_rID].affEth0 = plyrRnds_[_affID][_rID].affEth0.add(_eth);
                }
                uint limit = (10 ether) * i;
                uint256 _affi = _aff.mul(affsRate_[i]) / 1000;
                if(_affi > 0 && limit <= plyrRnds_[_affID][_rID].affEth0) {
                    //record the aff
                    plyrAffs_[_affID][plyr_[_affID].affCount].level = i;
                    plyrAffs_[_affID][plyr_[_affID].affCount].pid = _pID;
                    plyrAffs_[_affID][plyr_[_affID].affCount].eth = _affi;
                    plyr_[_affID].affCount++;
                    //Multi aff awards
                    plyr_[_affID].aff = _affi.add(plyr_[_affID].aff);
                    //emit F3Devents.onAffiliatePayout(_affID, plyr_[_affID].addr, plyr_[_affID].name, _rID, _pID, _aff, now);
                    _affTotal = _affTotal.add(_affi);
                }

                //Next aff
                _pID = _affID;
                _affID = plyr_[_pID].laff;

            } else {
                break;
            }
        }

        _aff = _aff.sub(_affTotal);
        return _aff;
    }

    function potSwap()
    external
    payable
    {
        // setup local rID
        //uint256 _rID = rID_ + 1;

        //round_[_rID].pot = round_[_rID].pot.add(msg.value);
        // emit F3Devents.onPotSwapDeposit(_rID, msg.value);
    }

    /**
     * @dev distributes eth based on fees to gen and pot
     */
    function distributeInternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _team, uint256 _keys, F3Ddatasets.EventReturns memory _eventData_)
    private
    returns(F3Ddatasets.EventReturns)
    {
        // calculate gen share
        uint256 _gen = (_eth.mul(fees_[_team].gen)) / 100;

        // toss 1% into airdrop pot
        uint256 _air = (_eth.mul(airdropFee_) / 100);
        airDropPot_ = airDropPot_.add(_air);

        // update eth balance (eth = eth - (com share + pot swap share + aff share + p3d share + airdrop pot share))
        uint256 _pot = _eth.sub(((_eth.mul(feesTotal_)) / 100).add((_eth.mul(fees_[_team].p3d)) / 100));

        // calculate pot
        _pot = _pot.sub(_gen);

        // distribute gen share (thats what updateMasks() does) and adjust
        // balances for dust.
        uint256 _dust = updateMasks(_rID, _pID, _gen, _keys, _eth);
        if (_dust > 0)
            _gen = _gen.sub(_dust);

        // add eth to pot
        round_[_rID].pot = _pot.add(_dust).add(round_[_rID].pot);

        // set up event data
        _eventData_.genAmount = _gen.add(_eventData_.genAmount);
        _eventData_.potAmount = _pot;

        return(_eventData_);
    }
    /**
     * @dev updates masks for round and player when keys are bought
     * @return dust left over
     */
    function updateMasks(uint256 _rID, uint256 _pID, uint256 _gen, uint256 _keys, uint256 _eth)
    private
    returns(uint256)
    {
        uint256 _oldKeyValue = round_[_rID].mask;
        // calc profit per key & round mask based on this buy:  (dust goes to pot)
        uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
        round_[_rID].mask = _ppt.add(_oldKeyValue);

        //更新收益，计算可能的收益溢出
        updateGenVault(_pID, plyr_[_pID].lrnd, _keys, _eth);

        // calculate player earning from their own buy (only based on the keys
        // they just bought).  & update player earnings mask
//        uint256 _pearn = (_ppt.mul(_keys)) / (1000000000000000000);
//        _pearn = ((round_[_rID].mask.mul(_keys)) / (1000000000000000000)).sub(_pearn);
//        plyrRnds_[_pID][_rID].mask = (_pearn).add(plyrRnds_[_pID][_rID].mask);

        plyrRnds_[_pID][_rID].mask = (_oldKeyValue.mul(_keys) / (1000000000000000000)).add(plyrRnds_[_pID][_rID].mask);

        // calculate & return dust
        return(_gen.sub((_ppt.mul(round_[_rID].keys)) / (1000000000000000000)));
    }

    /**
     * @dev adds up unmasked earnings, & vault earnings, sets them all to 0
     * @return earnings in wei format
     */
    function withdrawEarnings(uint256 _pID, bool _reBuy)
    private
    returns(uint256)
    {
        // update gen vault
        updateGenVault(_pID, plyr_[_pID].lrnd, 0, 0);

        // from vaults
        uint256 _earnings = (plyr_[_pID].win).add(plyr_[_pID].gen).add(plyr_[_pID].aff).add(plyr_[_pID].smallEth);
        if (_earnings > 0)
        {
            plyr_[_pID].win = 0;
            plyr_[_pID].gen = 0;
            plyr_[_pID].aff = 0;
            plyr_[_pID].smallEth = 0;
        }

        //复投
        if(_reBuy && plyr_[_pID].reEth > 0) {
            // set up our tx event data
            F3Ddatasets.EventReturns memory _eventData_;
            //购买
            if(core(rID_, _pID, plyr_[_pID].reEth, plyr_[_pID].laff, 0, _eventData_, false)) {
                //清空
                plyr_[_pID].reEth = 0;
            }
        }

        return(_earnings);
    }

    /**
     * @dev prepares compression data and fires event for buy or reload tx's
     */
    function endTx(uint256 _pID, uint256 _team, uint256 _eth, uint256 _keys, F3Ddatasets.EventReturns memory _eventData_)
    private view
    {
        _eventData_.compressedData = _eventData_.compressedData + (now * 1000000000000000000) + (_team * 100000000000000000000000000000);
        _eventData_.compressedIDs = _eventData_.compressedIDs + _pID + (rID_ * 10000000000000000000000000000000000000000000000000000);

        // emit F3Devents.onEndTx
        // (
        //     _eventData_.compressedData,
        //     _eventData_.compressedIDs,
        //     plyr_[_pID].name,
        //     msg.sender,
        //     _eth,
        //     _keys,
        //     _eventData_.winnerAddr,
        //     _eventData_.winnerName,
        //     _eventData_.amountWon,
        //     _eventData_.newPot,
        //     _eventData_.P3DAmount,
        //     _eventData_.genAmount,
        //     _eventData_.potAmount,
        //     airDropPot_
        // );
    }
    //==============================================================================
    //    (~ _  _    _._|_    .
    //    _)(/_(_|_|| | | \/  .
    //====================/=========================================================
    /** upon contract deploy, it will be deactivated.  this is a one time
     * use function that will activate the contract.  we do this so devs
     * have time to set things up on the web end                            **/
    bool public activated_ = false;
    function activate()
    onlyOwner
    public
    {
        // make sure that its been linked.
        //        require(address(otherF3D_) != address(0), "must link to other FoMo3D first");

        // can only be ran once
        require(activated_ == false, "fomo3d already activated");

        // activate the contract
        activated_ = true;

        // lets start first round
        rID_ = 1;
        round_[1].strt = now + rndExtra_ - rndGap_;
        round_[1].end = now + rndInit_ + rndExtra_;
    }
    bool public buyable_ = true;
    function enableBuy(bool _b)
    onlyOwner
    public
    {
        if(buyable_ != _b) {
            buyable_ = _b;
        }
    }

    function setOtherFomo(address _otherF3D)
    onlyOwner
    public
    {
        // make sure that it HASNT yet been linked.
        require(address(otherF3D_) == address(0), "silly dev, you already did that");

        // set up other fomo3d (fast or long) for pot swap
        otherF3D_ = otherFoMo3D(_otherF3D);
    }
}

//==============================================================================
//   __|_ _    __|_ _  .
//  _\ | | |_|(_ | _\  .
//==============================================================================
library F3Ddatasets {
    //compressedData key
    // [76-33][32][31][30][29][28-18][17][16-6][5-3][2][1][0]
    // 0 - new player (bool)
    // 1 - joined round (bool)
    // 2 - new  leader (bool)
    // 3-5 - air drop tracker (uint 0-999)
    // 6-16 - round end time
    // 17 - winnerTeam
    // 18 - 28 timestamp
    // 29 - team
    // 30 - 0 = reinvest (round), 1 = buy (round), 2 = buy (ico), 3 = reinvest (ico)
    // 31 - airdrop happened bool
    // 32 - airdrop tier
    // 33 - airdrop amount won
    //compressedIDs key
    // [77-52][51-26][25-0]
    // 0-25 - pID
    // 26-51 - winPID
    // 52-77 - rID
    struct EventReturns {
        uint256 compressedData;
        uint256 compressedIDs;
        address winnerAddr;         // winner address
        bytes32 winnerName;         // winner name
        uint256 amountWon;          // amount won
        uint256 newPot;             // amount in new pot
        uint256 P3DAmount;          // amount distributed to p3d
        uint256 genAmount;          // amount distributed to gen
        uint256 potAmount;          // amount added to pot
    }
    struct Player {
        address addr;   // player address
        bytes32 name;   // player name
        uint256 win;    // winnings vault
        uint256 gen;    // general vault
        uint256 aff;    // affiliate vault
        uint256 smallEth;//小玩家收益
        uint256 lrnd;   // last round played
        uint256 laff;   // last affiliate id used
        uint256 agk;   // AGK token awarded
        uint256 usedAgk;        //agk transfered
        uint256 affCount;// the count of aff award
        uint256 reEth; //需要复投的eth
        bool vip; //是否vip小玩家

    }
    struct PlayerRounds {
        uint256 eth;    // eth player has added to round (used for eth limiter)
        uint256 keys;   // keys
        uint256 keysOff;// keys kicked off
        uint256 ethOff; //  eth kicked off
        uint256 mask;   // player mask
        uint256 ico;    // ICO phase investment
        uint256 genOff; //当前已经累计的收益
        uint256 affEth;  //获得的所有推荐的投资额度
        uint256 affEth0; //获得直推的总额
//        uint256 inviteCounter;      //有效的下线数量，用来计算推荐收益用，一次性投资10个ETH才算有效用户
    }
    struct Round {
        uint256 plyr;   // pID of player in lead
        uint256 team;   // tID of team in lead
        uint256 end;    // time ends/ended
        bool ended;     // has round end function been ran
        uint256 strt;   // time round started
        uint256 keys;   // keys
        uint256 eth;    // total eth in
        uint256 pot;    // eth to pot (during round) / final amount paid to winner (after round ends)
        uint256 mask;   // global mask
        uint256 ico;    // total eth sent in during ICO phase
        uint256 icoGen; // total eth for gen during ICO phase
        uint256 icoAvg; // average key price for ICO phase
        // uint256 rePot;  // 复投池
        uint256 agk;    //总共增加了多少agk，要换成eth给钱包
    }
    struct TeamFee {
        uint256 gen;    // % of buy in thats paid to key holders of current round
        uint256 p3d;    // % of buy in thats paid to p3d holders
    }
    struct PotSplit {
        uint256 gen;    // % of pot thats paid to key holders of current round
        uint256 p3d;    // % of pot thats paid to p3d holders
    }
    struct Aff {
        uint256 level;//the aff level: 0, 1 or 2
        uint256 pid;  //the player id trigger the aff award
        uint256 eth;  //the award of eth
    }
    struct Invest {
        uint256 pid;   //player id
        uint256 eth;   //eth invested
        uint256 kid;   //key id start
        uint256 keys;  //keys got
    }
}

//==============================================================================
//  |  _      _ _ | _  .
//  |<(/_\/  (_(_||(_  .
//=======/======================================================================
library F3DKeysCalcLong {
    using SafeMath for *;
    uint256 constant private keyPriceStart_ = 150 szabo;//key的起始价,如果需要改动，两个地方都要改，math那里
    uint256 constant private keyPriceStep_   = 1 wei;       //key价格上涨阶梯
    /**
     * @dev calculates number of keys received given X eth
     * @param _curEth current amount of eth in contract
     * @param _newEth eth being spent
     * @return amount of ticket purchased
     */
    function keysRec(uint256 _curEth, uint256 _newEth)
    internal
    pure
    returns (uint256)
    {
        return(keys((_curEth).add(_newEth)).sub(keys(_curEth)));
    }

    /**
       当前keys数量为_curKeys，购买_sellKeys所需的eth
     * @dev calculates amount of eth received if you sold X keys
     * @param _curKeys current amount of keys that exist
     * @param _sellKeys amount of keys you wish to sell
     * @return amount of eth received
     */
    function ethRec(uint256 _curKeys, uint256 _sellKeys)
    internal
    pure
    returns (uint256)
    {
        return((eth(_curKeys)).sub(eth(_curKeys.sub(_sellKeys))));
    }

    /**
        解二次方程: eth总值 = n * 起始价 +  n*n*递增价/2
        _eth对应的key数量 = (开根号(起始价*起始价 + 2*递增价*_eth) - 起始价) / 递增价
     * @dev calculates how many keys would exist with given an amount of eth
     * @param _eth eth "in contract"
     * @return number of keys that would exist
     */
    function keys(uint256 _eth)
    internal
    pure
    returns(uint256)
    {
        return ((((keyPriceStart_).sq()).add((keyPriceStep_).mul(2).mul(_eth))).sqrt().sub(keyPriceStart_)).mul(1000000000000000000) / (keyPriceStep_);
    }

    /**
       _keys数量的key对应的 eth总值 = n * 起始价 +  n*n*递增价/2 + n*递增价/2
       按照原版 eth总值 = n * 起始价 +  n*n*递增价/2 少了一部分
     * @dev calculates how much eth would be in contract given a number of keys
     * @param _keys number of keys "in contract"
     * @return eth that would exists
     */
    function eth(uint256 _keys)
    public
    pure
    returns(uint256)
    {
        uint256 n = _keys / (1000000000000000000);
        //correct
        // return n.mul(keyPriceStart_).add((n.sq().mul(keyPriceStep_)) / (2)).add(n.mul(keyPriceStep_) / (2));
        //original
        return n.mul(keyPriceStart_).add((n.sq().mul(keyPriceStep_)) / (2));
    }
}

//==============================================================================
//  . _ _|_ _  _ |` _  _ _  _  .
//  || | | (/_| ~|~(_|(_(/__\  .
//==============================================================================
interface otherFoMo3D {
    function potSwap() external payable;
}

interface DiviesInterface {
    function deposit() external payable;
}

interface JIincForwarderInterface {
    function deposit() external payable returns(bool);
    function status() external view returns(address, address, bool);
    function startMigration(address _newCorpBank) external returns(bool);
    function cancelMigration() external returns(bool);
    function finishMigration() external returns(bool);
    function setup(address _firstCorpBank) external;
}

interface PlayerBookInterface {
    function pIDxAddr_(address _addr) external view returns (uint256);
    function getPlayerCount() external view returns (uint256);
    function getPlayerID(address _addr) external returns (uint256);
    function getPlayerName(uint256 _pID) external view returns (bytes32);
    function getPlayerLAff(uint256 _pID) external view returns (uint256);
    function getPlayerAddr(uint256 _pID) external view returns (address);
    function getNameFee() external view returns (uint256);
    function registerNameXIDFromDapp(address _addr, bytes32 _name, uint256 _affCode, bool _all) external payable returns(bool, uint256);
    function registerNameXaddrFromDapp(address _addr, bytes32 _name, address _affCode, bool _all) external payable returns(bool, uint256);
    function registerNameXnameFromDapp(address _addr, bytes32 _name, bytes32 _affCode, bool _all) external payable returns(bool, uint256);
}

/**
* @title -Name Filter- v0.1.9
*/

library NameFilter {
    /**
     * @dev filters name strings
     * -converts uppercase to lower case.
     * -makes sure it does not start/end with a space
     * -makes sure it does not contain multiple spaces in a row
     * -cannot be only numbers
     * -cannot start with 0x
     * -restricts characters to A-Z, a-z, 0-9, and space.
     * @return reprocessed string in bytes32 format
     */
    function nameFilter(string _input)
    internal
    pure
    returns(bytes32)
    {
        bytes memory _temp = bytes(_input);
        uint256 _length = _temp.length;

        //sorry limited to 32 characters
        require (_length <= 32 && _length > 0, "string must be between 1 and 32 characters");
        // make sure it doesnt start with or end with space
        require(_temp[0] != 0x20 && _temp[_length-1] != 0x20, "string cannot start or end with space");
        // make sure first two characters are not 0x
        if (_temp[0] == 0x30)
        {
            require(_temp[1] != 0x78, "string cannot start with 0x");
            require(_temp[1] != 0x58, "string cannot start with 0X");
        }

        // create a bool to track if we have a non number character
        bool _hasNonNumber;

        // convert & check
        for (uint256 i = 0; i < _length; i++)
        {
            // if its uppercase A-Z
            if (_temp[i] > 0x40 && _temp[i] < 0x5b)
            {
                // convert to lower case a-z
                _temp[i] = byte(uint(_temp[i]) + 32);

                // we have a non number
                if (_hasNonNumber == false)
                    _hasNonNumber = true;
            } else {
                require
                (
                // require character is a space
                    _temp[i] == 0x20 ||
                // OR lowercase a-z
                (_temp[i] > 0x60 && _temp[i] < 0x7b) ||
                // or 0-9
                (_temp[i] > 0x2f && _temp[i] < 0x3a),
                    "string contains invalid characters"
                );
                // make sure theres not 2x spaces in a row
                if (_temp[i] == 0x20)
                    require( _temp[i+1] != 0x20, "string cannot contain consecutive spaces");

                // see if we have a character other than a number
                if (_hasNonNumber == false && (_temp[i] < 0x30 || _temp[i] > 0x39))
                    _hasNonNumber = true;
            }
        }

        require(_hasNonNumber == true, "string cannot be only numbers");

        bytes32 _ret;
        assembly {
            _ret := mload(add(_temp, 32))
        }
        return (_ret);
    }
}

/**
 * @title SafeMath v0.1.9
 * @dev Math operations with safety checks that throw on error
 * change notes:  original SafeMath library from OpenZeppelin modified by Inventor
 * - added sqrt
 * - added sq
 * - added pwr
 * - changed asserts to requires with error log outputs
 * - removed div, its useless
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b)
    internal
    pure
    returns (uint256 c)
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b)
    internal
    pure
    returns (uint256)
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b)
    internal
    pure
    returns (uint256 c)
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }

    /**
     * @dev gives square root of given x.
     */
    function sqrt(uint256 x)
    internal
    pure
    returns (uint256 y)
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y)
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }

    /**
     * @dev gives square. multiplies x by x
     */
    function sq(uint256 x)
    internal
    pure
    returns (uint256)
    {
        return (mul(x,x));
    }

    /**
     * @dev x to the power of y
     */
    function pwr(uint256 x, uint256 y)
    internal
    pure
    returns (uint256)
    {
        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else
        {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }
}