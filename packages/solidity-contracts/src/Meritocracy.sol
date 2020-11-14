/**
 * Source Code first verified at https://etherscan.io on Sunday, April 28, 2019
 (UTC) */

pragma solidity ^0.5.0;

/*
Future Goals:
- remove admins necessity
- encourage contributors to allocate
- needs incentive for someone to call forfeit
- read from previous versions of the script

DApp:
- show tokens to allocate
- allocate token to person with praise
- leaderboard, showing amount totalReceived and totalForfeited and amount, praises https://codepen.io/lewismcarey/pen/GJZVoG
- allows you to send SNT to meritocracy
- add/remove contributor
- add/remove adminstrator

Extension:
- Command:
    - above command = display allocation, received, withdraw button, allocate button? (might be better in dapp)
    - /kudos 500 "<person>" "<praise>"
*/



// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/issues/20

interface ERC20Token {

    /**
     * @notice send `_value` token to `_to` from `msg.sender`
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transfer(address _to, uint256 _value) external returns (bool success);

    /**
     * @notice `msg.sender` approves `_spender` to spend `_value` tokens
     * @param _spender The address of the account able to transfer the tokens
     * @param _value The amount of tokens to be approved for transfer
     * @return Whether the approval was successful or not
     */
    function approve(address _spender, uint256 _value) external returns (bool success);

    /**
     * @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    /**
     * @param _owner The address from which the balance will be retrieved
     * @return The balance
     */
    function balanceOf(address _owner) external view returns (uint256 balance);

    /**
     * @param _owner The address of the account owning tokens
     * @param _spender The address of the account able to transfer the tokens
     * @return Amount of remaining tokens allowed to spent
     */
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    /**
     * @notice return total supply of tokens
     */
    function totalSupply() external view returns (uint256 supply);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Meritocracy {

    struct Status {
        address author;
        string praise;
        uint256 amount;
        uint256 time; // block.timestamp
    }

    struct Contributor {
        address addr;
        uint256 allocation; // Amount they can send to other contributors, and amount they forfeit, when forfeit just zero this out and leave Token in contract, Owner can use escape to receive it back
        uint256 totalForfeited; // Allocations they've burnt, can be used to show non-active players.
        uint256 totalReceived;
        uint256 received; // Ignore amounts in Status struct, and use this as source of truth, can withdraw at any time
        // bool inPot; // Require Contributor WARN: commented because there's some edge cases not dealt with
        Status[] status;
    }

    ERC20Token public token; // token contract
    address payable public owner; // contract owner
    uint256 public lastForfeit; // timestamp to block admins calling forfeitAllocations too quickly
    address[] public registry; // array of contributor addresses
    uint256 public maxContributors; // Dynamic finite limit on registry.
    mapping(address => bool) public admins;
    mapping(address => Contributor) public contributors;
    bytes public contributorListIPFSHash;

    Meritocracy public previousMeritocracy; // Reference and read from previous contract

    // Events -----------------------------------------------------------------------------------------------

    event ContributorAdded(address _contributor);
    event ContributorRemoved(address _contributor);
    event ContributorWithdrew(address _contributor);
    event ContributorTransaction(address _cSender, address _cReceiver);

    event AdminAdded(address _admin);
    event AdminRemoved(address _admin);
    event AllocationsForfeited();

    event OwnerChanged(address _owner);
    event TokenChanged(address _token);
    event MaxContributorsChanged(uint256 _maxContributors);
    event EscapeHatchTriggered(address _executor);


    // Modifiers --------------------------------------------------------------------------------------------

    // Functions only Owner can call
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    // Functions only Admin can call
    modifier onlyAdmin {
        require(admins[msg.sender]);
        _;
    }

    // Open Functions  --------------------------------------------------------------------------------------

    // Split amount over each contributor in registry, any contributor can allocate? TODO maybe relax this restriction, so anyone can allocate tokens
    function allocate(uint256 _amount) external {
        // Locals

        // Contributor memory cAllocator = contributors[msg.sender];
        // Requirements
        // require(cAllocator.addr != address(0)); // is sender a Contributor? TODO maybe relax this restriction.
        uint256 individualAmount = _amount / registry.length;

        // removing decimals
        individualAmount = (individualAmount / 1 ether * 1 ether);

        uint amount = individualAmount * registry.length;

        require(token.transferFrom(msg.sender, address(this), amount));
        // Body
        // cAllocator.inPot = true;
        for (uint256 i = 0; i < registry.length; i++) {
               contributors[registry[i]].allocation += individualAmount;
        }
    }

    function getRegistry() public view returns (address[] memory) {
        return registry;
    }

    // Contributor Functions --------------------------------------------------------------------------------

    // Allows a contributor to withdraw their received Token, when their allocation is 0
    function withdraw() external {
        // Locals
         Contributor storage cReceiver = contributors[msg.sender];
         // Requirements
        require(cReceiver.addr == msg.sender); //is sender a Contributor?
        require(cReceiver.received > 0); // Contributor has received some tokens
        require(cReceiver.allocation == 0); // Contributor must allocate all Token (or have Token burnt)  before they can withdraw.
        // require(cReceiver.inPot); // Contributor has put some tokens into the pot
        // Body
        uint256 r = cReceiver.received;
        cReceiver.received = 0;
        // cReceiver.inPot = false;
        token.transfer(cReceiver.addr, r);
        emit ContributorWithdrew(cReceiver.addr);
    }

    // Allow Contributors to award allocated tokens to other Contributors
    function award(address _contributor, uint256 _amount,  string memory _praise) public {
        // Locals
        Contributor storage cSender = contributors[msg.sender];
        Contributor storage cReceiver = contributors[_contributor];
        // Requirements
        require(_amount > 0); // Allow Non-Zero amounts only
        require(cSender.addr == msg.sender); // Ensure Contributors both exist, and isn't the same address
        require(cReceiver.addr == _contributor);
        require(cSender.addr != cReceiver.addr); // cannot send to self
        require(cSender.allocation >= _amount); // Ensure Sender has enough tokens to allocate
        // Body
        cSender.allocation -= _amount; // burn is not adjusted, which is done only in forfeitAllocations
        cReceiver.received += _amount;
        cReceiver.totalReceived += _amount;

        Status memory s = Status({
            author: cSender.addr,
            praise: _praise,
            amount: _amount,
            time: block.timestamp
        });

        cReceiver.status.push(s); // Record the history
        emit ContributorTransaction(cSender.addr, cReceiver.addr);
    }

    function getStatusLength(address _contributor) public view returns (uint) {
        return contributors[_contributor].status.length;
    }

    function getStatus(address _contributor, uint _index) public view returns (
        address author,
        string memory praise,
        uint256 amount,
        uint256 time
    ) {
        author = contributors[_contributor].status[_index].author;
        praise = contributors[_contributor].status[_index].praise;
        amount = contributors[_contributor].status[_index].amount;
        time = contributors[_contributor].status[_index].time;
    }

    // Allow Contributor to award multiple Contributors
    function awardContributors(address[] calldata _contributors, uint256 _amountEach,  string calldata _praise) external {
        // Locals
        Contributor storage cSender = contributors[msg.sender];
        uint256 contributorsLength = _contributors.length;
        uint256 totalAmount = contributorsLength * _amountEach;
        // Requirements
        require(cSender.allocation >= totalAmount);
        // Body
        for (uint256 i = 0; i < contributorsLength; i++) {
                award(_contributors[i], _amountEach, _praise);
        }
    }

    // Admin Functions  -------------------------------------------------------------------------------------

    // Add Contributor to Registry
    function addContributor(address _contributor, bytes memory _contributorListIPFSHash) public onlyAdmin {
       addContributorWithoutHash(_contributor);

        // Set new IPFS hash for the list
        contributorListIPFSHash = _contributorListIPFSHash;
    }

    function addContributorWithoutHash(address _contributor) internal onlyAdmin {
        // Requirements
        require(registry.length + 1 <= maxContributors); // Don't go out of bounds
        require(contributors[_contributor].addr == address(0)); // Contributor doesn't exist
        // Body
        Contributor storage c = contributors[_contributor];
        c.addr = _contributor;
        registry.push(_contributor);
        emit ContributorAdded(_contributor);
    }

    // Add Multiple Contributors to the Registry in one tx
    function addContributors(address[] calldata _newContributors, bytes calldata _contributorListIPFSHash) external onlyAdmin {
        // Locals
        uint256 newContributorLength = _newContributors.length;
        // Requirements
        require(registry.length + newContributorLength <= maxContributors); // Don't go out of bounds
        // Body
        for (uint256 i = 0; i < newContributorLength; i++) {
            addContributorWithoutHash(_newContributors[i]);
        }
        // Set new IPFS hash for the list
        contributorListIPFSHash = _contributorListIPFSHash;
    }

    // Remove Contributor from Registry
    // Note: Should not be easy to remove multiple contributors in one tx
    // WARN: Changed to idx, client can do loop by enumerating registry
    function removeContributor(uint256 idx, bytes calldata _contributorListIPFSHash) external onlyAdmin { // address _contributor
        // Locals
        uint256 registryLength = registry.length - 1;
        // Requirements
        require(idx <= registryLength); // idx needs to be smaller than registry.length - 1 OR maxContributors
        // Body
        address c = registry[idx];
        // Swap & Pop!
        registry[idx] = registry[registryLength];
        registry.pop();
        delete contributors[c]; // TODO check if this works
        // Set new IPFS hash for the list
        contributorListIPFSHash = _contributorListIPFSHash;
        emit ContributorRemoved(c);
    }

    // Implictly sets a finite limit to registry length
    function setMaxContributors(uint256 _maxContributors) external onlyAdmin {
        require(_maxContributors > registry.length); // have to removeContributor first
        // Body
        maxContributors = _maxContributors;
        emit MaxContributorsChanged(maxContributors);
    }

    // Zero-out allocations for contributors, minimum once a week, if allocation still exists, add to burn
    function forfeitAllocations() public onlyAdmin {
        // Locals
        uint256 registryLength = registry.length;
        // Requirements
        require(block.timestamp >= lastForfeit + 6 days); // prevents admins accidently calling too quickly.
        // Body
        lastForfeit = block.timestamp;
        for (uint256 i = 0; i < registryLength; i++) { // should never be longer than maxContributors, see addContributor
                Contributor storage c = contributors[registry[i]];
                c.totalForfeited += c.allocation; // Shaaaaame!
                c.allocation = 0;
                // cReceiver.inPot = false; // Contributor has to put tokens into next round
        }
        emit AllocationsForfeited();
    }

    // Owner Functions  -------------------------------------------------------------------------------------

    // Set Admin flag for address to true
    function addAdmin(address _admin) public onlyOwner {
        admins[_admin] = true;
        emit AdminAdded(_admin);
    }

    //  Set Admin flag for address to false
    function removeAdmin(address _admin) public onlyOwner {
        delete admins[_admin];
        emit AdminRemoved(_admin);
    }

    // Change owner address, ideally to a management contract or multisig
    function changeOwner(address payable _owner) external onlyOwner {
        // Body
        removeAdmin(owner);
        addAdmin(_owner);
        owner = _owner;
        emit OwnerChanged(owner);
    }

    // Change Token address
    // WARN: call escape first, or escape(token);
    function changeToken(address _token) external onlyOwner {
        // Body
        // Zero-out allocation and received, send out received tokens before token switch.
        for (uint256 i = 0; i < registry.length; i++) {
                Contributor storage c = contributors[registry[i]];
                uint256 r =  c.received;
                c.received = 0;
                c.allocation = 0;
                // WARN: Should totalReceived and totalForfeited be zeroed-out?
                token.transfer(c.addr, r); // Transfer any owed tokens to contributor
        }
        lastForfeit = block.timestamp;
        token = ERC20Token(_token);
        emit TokenChanged(_token);
    }

    // Failsafe, Owner can escape hatch all Tokens and ETH from Contract.
    function escape() public onlyOwner {
        // Body
        token.transfer(owner,  token.balanceOf(address(this)));
        owner.transfer(address(this).balance);
        emit EscapeHatchTriggered(msg.sender);
    }

    // Overloaded failsafe function, recourse incase changeToken is called before escape and funds are in a different token
    // Don't want to require in changeToken incase bad behaviour of ERC20 token
    function escape(address _token) external onlyOwner {
        // Body
        ERC20Token t = ERC20Token(_token);
        t.transfer(owner,  t.balanceOf(address(this)));
        escape();
    }

    // Housekeeping -----------------------------------------------------------------------------------------

    // function importPreviousMeritocracyData() private onlyOwner { // onlyOwner not explicitly needed but safer than sorry, it's problem with overloaded function
    //      // if previousMeritocracy != address(0) { // TODO better truthiness test, casting?
    //      //        // Do Stuff
    //      // }
    // }

    // Constructor ------------------------------------------------------------------------------------------

    // constructor(address _token, uint256 _maxContributors, address _previousMeritocracy) public {

    // }

    // Set Owner, Token address,  initial maxContributors
    constructor(address _token, uint256 _maxContributors, bytes memory _contributorListIPFSHash) public {
        // Body
        owner = msg.sender;
        addAdmin(owner);
        lastForfeit = block.timestamp;
        token = ERC20Token(_token);
        maxContributors= _maxContributors;
        contributorListIPFSHash = _contributorListIPFSHash;
        // previousMeritocracy = Meritocracy(_previousMeritocracy);
        // importPreviousMeritocracyData() TODO
    }
}