/**
 * Source Code first verified at https://etherscan.io on Friday, April 26, 2019
 (UTC) */

pragma solidity ^0.5.0;



/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 *
 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
 * all accounts just by listening to said events. Note that this isn't required by the specification, and other
 * compliant implementations may not do it.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowed;

    uint256 private _totalSupply;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
    * @dev Transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }


    function sellTokens(address payable from, uint256 value) internal;

    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
        if (to == address(this) && msg.sender == from) {
            sellTokens(msg.sender, value);
        } else {
            addInvestor(to);
        }
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
        addInvestor(account);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }

    function addInvestor(address investor) internal;
}

contract DividendsERC20 is ERC20 {

    event Dividends(address indexed investor, uint256 value);

    mapping(address => bool)  public inList;
    address[]  internal investorList;
    uint8 internal nextReferId = 0;

    function addInvestor(address investor) internal {
        if (!inList[investor]) {
            investorList.push(investor);
            inList[investor] = true;
        }
    }

    function getList() public view returns (address[] memory){
        return investorList;
    }

    function distribute(address buyer, uint256 tokens) internal returns (uint256) {

        uint256 _total = totalSupply() - balanceOf(buyer);
        uint256 distributed = 0;
        for (uint i = 0; i < investorList.length; i++) {
            address investor = investorList[i];
            uint256 _balance = balanceOf(investor);
            if (_balance > 0 && investor != buyer) {
                uint256 _dividend = _balance * tokens / _total;
                _mint(investor, _dividend);
                emit Dividends(investor, _dividend);
                distributed += _dividend;
            }
        }
        return distributed;
    }


}

contract ReferalsERC20 is DividendsERC20 {

    event ReferalBonus(address indexed from, address indexed to, uint256 value);

    mapping(address => int256) internal SBalance;
    mapping(address => address) public refers;

    function getNextRefer() private returns (address) {
        if (investorList.length > nextReferId) {
            address result = investorList[nextReferId];
            if (nextReferId < 9 && nextReferId < investorList.length - 1) {
                nextReferId = nextReferId + 1;
            } else {
                nextReferId = 0;
            }
            return result;
        }
        else {
            return address(0x0);
        }
    }

    function checkRefer(address referal, address refer) internal returns (address){

        if (investorList.length < 1 || referal == investorList[0]) return address(0x0);

        if (refers[referal] == address(0x0)) {

            if (refer == address(0x0)) {
                refers[referal] = getNextRefer();
            } else {

                refers[referal] = refer;



            }
        }

        return refers[referal];
    }

    function changeSBalance(address investor, int256 amount) internal returns (int256){
        SBalance[investor] = SBalance[investor] + amount;
        return SBalance[investor];
    }

    function calcToRefer(address investor, uint256 amount, uint256 tokens)
    internal returns (uint256){
        int256 thisSBalance = changeSBalance(investor, int256(amount));
        uint256 result = 0;

        if (thisSBalance >= int256(amount)) {
            result = tokens / 20;
            changeSBalance(investor, int256( amount) * (-1) );
        } else if (thisSBalance > 0) {
            result = (uint256(thisSBalance) * tokens / amount) / 20;
            changeSBalance(investor, thisSBalance * (-1));
        }
        return result;
    }

}


contract FibonumCyclingToken is ReferalsERC20 {


    string public name = "Fibonum Cycling Token";
    string public symbol = "FCT";
    uint8 public decimals = 18;

    event Buy(address indexed investor, uint256 indexed tokens, uint256 ethers);
    event Sell(address indexed investor, uint256 indexed tokens, uint256 ethers);


    int256 private x = 0; 
    int256 private c = 0;
    int256 private  n = 1000000000000000000;

    int256 constant xe = 1590797660368290000;
    int256 constant ce = 1428285685708570000;
    int256 constant xa = 775397496610753000;
    int256 constant ca = - 714142842854285000;




    uint64[] ethToTokenA = [uint64(1417139259168220000), 1395328479040590000, 1374818151911760000, 1355496481642670000,
    1337264861422160000, 1320035947620740000, 1303732066667570000, 1288283889008670000, 1273629318822690000,
    1259712559222210000, 1246483321098410000, 1233896150251810000, 1221909852479560000, 1210487000216940000,
    1199593507419850000, 1189198261821420000, 1179272805644490000, 1169791057414210000, 1160729068774030000,
    1152064811228980000, 1143777988571040000, 1135849871421960000, 1128263150888080000, 1121001808783790000,
    1114051002263240000, 1107396961019390000, 1101026895475830000, 1094928914620790000, 1089091952321460000,
    1083505701115530000, 1078160552612450000, 1073047543751270000, 1068158308260090000, 1063485032746130000,
    1059020416916920000, 1054757637495480000, 1050690315445410000, 1046812486168130000, 1043118572374580000,
    1039603359368500000, 1036261972508700000, 1033089856644290000, 1030082757340130000, 1027236703730050000,
    1024547992853300000, 1022013175345570000, 1019629042369960000, 1017392613685540000, 1015301126762090000,
    1013352026859850000, 1011542958001130000, 1009871754769190000, 1008336434876480000, 1006935192450680000,
    1005666391992810000, 1004528562966940000, 1003520394985710000, 1002640733560210000, 1001888576386930000,
    1001263070147930000, 1000763507804280000, 1000389326365660000, 1000140105122260000, 1000015564328210000];

    uint64[] ethToTokenB = [uint64(775429218219143000), 775671327829898000, 776127901211966000, 776773645353675000,
    777586422946545000, 778546770812539000, 779637503568884000, 780843385369321000, 782150856410282000,
    783547803792281000, 785023368533855000, 786567782228188000, 788172228141079000, 789828722568099000,
    791530013068024000, 793269490820609000, 795041114858058000, 796839346320061000, 798659091204212000,
    800495650343652000, 802344675554931000, 804202131071437000, 806064259518883000, 807927551805687000,
    809788720397125000, 811644675521967000, 813492503926740000, 815329449848342000, 817152897922371000,
    818960357783777000, 820749450149599000, 822517894201629000, 824263496110689000, 825984138564496000,
    827677771178473000, 829342401683636000, 830976087798466000, 832576929702567000, 834143063039316000,
    835672652382843000, 837163885111639000, 838614965637138000, 840024109940838000, 841389540378025000,
    842709480710032000, 843982151330350000, 845205764652730000, 846378520631928000, 847498602389816000,
    848564171921350000, 849573365856374000, 850524291254470000, 851415021411011000, 852243591653376000,
    853007995106812000, 853706178409820000, 854336037359125000, 854895412464314000, 855382084392069000,
    855793769279634000, 856128113896648000, 856382690633867000, 856554992296479000, 856642426678713000,
    856642310895322000, 856551865444122000, 856368207972221000, 856088346716798000, 855709173589260000,
    855227456869334000, 854639833473084000, 853942800755975000, 853132707808898000, 852205746201468000,
    851157940122901000, 849985135866291000, 848682990597101000, 847246960341106000, 845672287120746000,
    843953985161896000, 842086826085187000, 840065322987306000, 837883713307804000, 835535940365946000,
    833015633439678000, 830316086244836000, 827430233656903000, 824350626499847000, 821069404206372000,
    817578265131108000, 813868434272292000, 809930628128026000, 805755016379575000, 801331180055767000,
    796648065788695000, 791693935720538000, 786456312563492000, 780921919248189000, 775076612519082000,
    768905309746284000, 762391908120150000, 755519195274780000, 748268750246655000, 740620833510800000,
    732554264644806000, 724046285945012000, 715072410052456000, 705606249330304000, 695619324359237000,
    685080848469791000, 673957484695128000, 662213070884326000, 649808307940139000, 636700405205061000,
    622842675875531000, 608184073925882000, 592668662306040000, 576235000056606000, 558815433353122000,
    540335272206310000, 520711830420428000, 499853301200371000, 477657434169810000, 454009971072929000,
    428782786477567000, 401831665549952000, 372993632284706000, 342083716845033000];

    uint64[] tokenToEthA = [uint64(704424178155537000), 713190762066846000, 721847189493791000, 730392123400529000,
    738824243972042000, 747142248817992000, 755344853173881000, 763430790099493000, 771398810674579000,
    779247684191759000, 786976198346613000, 794583159424929000, 802067392487080000, 809427741549495000,
    816663069763215000, 823772259589481000, 830754212972345000, 837607851508273000, 844332116612708000,
    850925969683577000, 857388392261710000, 863718386188143000, 869914973758293000, 875977197872967000,
    881904122186196000, 887694831249856000, 893348430655064000, 898864047170326000, 904240828876413000,
    909477945297944000, 914574587531659000, 919529968371354000, 924343322429479000, 929013906255348000,
    933540998449971000, 937923899777483000, 942161933273140000, 946254444347881000, 950200800889437000,
    954000393359958000, 957652634890164000, 961156961369993000, 964512831535722000, 967719727053578000,
    970777152599792000, 973684635937107000, 976441727987718000, 979048002902630000, 981503058127442000,
    983806514464515000, 985958016131545000, 987957230816517000, 989803849729030000, 991497587647993000,
    993038182965679000, 994425397728130000, 995659017671913000, 996738852257213000, 997664734697262000,
    998436521984103000, 999054094910676000, 999517358089229000, 999826239966055000, 999980692832543000];

    uint64[] tokenToEthB = [uint64(714156574852348000), 714265413504371000, 714480464730154000, 714798940623867000,
    715218004285508000, 715734770689657000, 716346307566699000, 717049636296306000, 717841732812979000,
    718719528523439000, 719679911235652000, 720719726099286000, 721835776557362000, 723024825308907000,
    724283595282368000, 725608770619570000, 726996997669992000, 728444885995139000, 729949009382765000,
    731505906870731000, 733112083780254000, 734764012758310000, 736458134828956000, 738190860453334000,
    739958570598101000, 741757617812056000, 743584327310708000, 745434998068541000, 747305903918727000,
    749193294660028000, 751093397170644000, 753002416528754000, 754916537139472000, 756831923867992000,
    758744723178644000, 760651064279594000, 762547060272951000, 764428809309991000, 766292395751258000,
    768133891331251000, 769949356327459000, 771734840733451000, 773486385435772000, 775200023394360000,
    776871780826229000, 778497678392132000, 780073732385946000, 781595955926494000, 783060360151543000,
    784462955413693000, 785799752477890000, 787066763720288000, 788260004328181000, 789375493500727000,
    790409255650206000, 791357321603504000, 792215729803583000, 792980527510629000, 793647772002626000,
    794213531775060000, 794673887739485000, 795024934420690000, 795262781152149000, 795383553269528000,
    795383393301940000, 795258462160674000, 795004940325147000, 794619029025774000, 794096951423502000,
    793434953785727000, 792629306658317000, 791676306033484000, 790572274513209000, 789313562467972000,
    787896549190501000, 786317644044284000, 784573287606558000, 782659952805530000, 780574146051537000,
    778312408361911000, 775871316479255000, 773247483982883000, 770437562393166000, 767438242268508000,
    764246254294709000, 760858370366446000, 757271404660626000, 753482214701341000, 749487702416195000,
    745284815183731000, 740870546871712000, 736241938866023000, 731396081089926000, 726330113013445000,
    721041224652618000, 715526657558394000, 709783705794922000, 703809716907010000, 697602092876500000,
    691158291067352000, 684475825159183000, 677552266069049000, 670385242861237000, 662972443644848000,
    655311616458951000, 647400570145076000, 639237175206862000, 630819364656603000, 622145134848520000,
    613212546298535000, 604019724490329000, 594564860667512000, 584846212611674000, 574862105406138000,
    564610932185217000, 554091154868778000, 543301304881934000, 532239983859669000, 520905864336217000,
    509297690419021000, 497414278447080000, 485254517633538000, 472817370692305000, 460101874448585000,
    447107140433120000, 433832355459993000, 420276782187844000, 406439759664335000];


    function xf(int256 tokens) private pure returns (int256){
        return (tokens / 24500) % xe;
    }

    function tokenToEth(int256 tokens) private view returns (int256) {

        uint64 inCircle = uint64(tokens);

        uint i = uint(inCircle / 12428106721627265);
        uint256 ai;
        if (i < 64) {
            ai = tokenToEthA[i];
        } else {
            ai = tokenToEthA[127 - i];
        }

        uint256 bi = tokenToEthB[i];
        int256 ax = int256(ai * inCircle) / (1 ether);

        int256 result = int256(bi) - ax;
        return result;

    }


    function Dx(int256 ethPrev, uint256 ethIncome, int256 nPrev) private view returns (uint256){
        int256 ethNew = ethPrev + int256(ethIncome);

        int256 first = xe * (intNcn(ethNew, nPrev) - intNcn(ethPrev, nPrev));
        int256 second = ethToToken(cf(ethNew, nPrev));
        int256 third = ethToToken(cf(ethPrev, nPrev));
        int256 result = (first + second - third) * 24500 * 98 / 100;

        return uint256(result);
    }


    function calcN(int256 totalTokens, int256 totalEther) private view returns (int256){
        int256 x24500 = totalTokens / 24500;

        int256 first = (x24500 / xe) * ce;
        int256 second = tokenToEth(x24500 % xe);
        int256 third = first - second - ca;
        return totalEther * (1 ether) / (350 * third);
    }

    function intNcn(int256 eth, int256 nPrev) private pure returns (int256) {
        return (1 ether) * (eth / 350) / (nPrev * ce);
    }


    function cf(int256 eth, int256 nPrev) private pure returns (int256){
        int256 mod350 = ((1 ether) * eth / 350) % (nPrev * ce);
        return mod350 / nPrev;
    }

    function ethToToken(int256 eth) private view returns (int256){

        uint256 inCircle = uint256(eth) % 1428285685708570000;

        uint i = uint(inCircle / 11158481919598203);

        int256 ai;
        if (i < 64) {
            ai = int256(ethToTokenA[i]);
        } else {
            ai = int256(ethToTokenA[127 - i]);
        }

        int256 bi = int256(ethToTokenB[i]);

        return (ai * int256(inCircle)) / (1 ether) + bi;
    }


    function Dc(int256 tokensPrev, uint256 tokensIncome, int256 nPrev) private view
    returns (int256){
        int256 tokensNew = tokensPrev - int256(tokensIncome);
        int256 first = (tokensNew / 24500) / xe;
        int256 second = (tokensPrev / 24500) / xe;
        int256 third = tokenToEth(xf(tokensNew));
        int256 fourth = tokenToEth(xf(tokensPrev));

        int256 result = nPrev * 350 * ((first - second) * ce - third + fourth) * 98 / (- 100 ether);

        return result;

    }


    function recalcValues() private {
        x = int256(totalSupply());
        c = int256(address(this).balance);
        if (x == 0) {
            n = 1000000000000000000;
        } else {
            n = calcN(x, c);
        }

    }

    function() external payable {
        require((msg.value == 0) || (msg.value >= 0.01 ether));
        if(msg.value == 0){
            sellAllTokens();
        }else{
            buy(msg.sender, msg.value, address(0x0));
        }
    }

    function buyTokens(address refer) public payable {
        require(msg.value > 0.01 ether);
        buy(msg.sender, msg.value, refer);
    }


    function buy(address investor, uint256 amount, address _refer) private {

        uint256 tokens = Dx(c, amount, n);
        uint256 toDistribute = tokens / 50;
        address refer = checkRefer(investor, _refer);
        uint256 toRefer = calcToRefer(investor, amount, tokens);
        uint256 distributed = distribute(investor, toDistribute);
        if (toRefer > 0 && refer != address(0x0)) {
            _mint(refer, toRefer);
            emit ReferalBonus(investor, refer, toRefer);
        }
        uint256 total = tokens - distributed - toRefer;
        _mint(msg.sender, total);
        emit Buy(msg.sender, total, amount);
        recalcValues();
    }

    function sellAllTokens() public {
        transfer(address(this), balanceOf(msg.sender));
    }

    function sellTokens(address payable from, uint256 value) internal {
        uint256 ethers = address(this).balance;
        if (int256(value) < x) {
            ethers = uint256(Dc(x, value, n));
        }
        _burn(address(this), value);
        from.transfer(ethers);
        emit Sell(from, value, ethers);
        changeSBalance(from, int256(ethers) * (- 1));
        recalcValues();
    }

    function calcEther(uint256 value) public view returns (uint256) {
        uint256 ethers = address(this).balance;
        if (int256(value) < x) {
            ethers = uint256(Dc(x, value, n));
        }
        return ethers;
    }

    function calcTokens(uint256 amount) public view returns (uint256 tokens,
        uint256 toDistribute, uint256 toRefer, uint256 total) {
        uint256 _tokens = Dx(c, amount, n);
        uint256 _toDistribute = _tokens / 50;
        uint256 _toRefer;
        int256 thisSBalance = SBalance[msg.sender] + int256(amount);

        if (thisSBalance <= 0) {
            _toRefer = 0;
        } else if (thisSBalance >= int256(amount)) {
            _toRefer = _tokens / 20;
        } else {
            _toRefer = (uint256(thisSBalance) * _tokens / amount) / 20;
        }

        return (_tokens, _toDistribute, _toRefer, _tokens - _toDistribute - _toRefer);
    }

}