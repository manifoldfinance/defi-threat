/**
 * Source Code first verified at https://etherscan.io on Thursday, May 2, 2019
 (UTC) */

pragma solidity ^0.5.7;

/**
 * Copy right (c) Donex UG (haftungsbeschraenkt)
 * All rights reserved
 * Version 0.2.1 (BETA)
 */

contract Freebies
{

    address owner;
    address payable public masterAddress;

    uint public deadline;
    mapping(address => bool) gotFreebie;
    mapping(address => bool) isMakerWithFreebiePermission;
    mapping(address => address) makersDerivative;
    uint public freebie;
    uint8 public maxNumberOfFreebies;
    uint8 public numberOfGivenFreebies;

    modifier onlyByOwner() {
        require(msg.sender ==  owner);
        _;
    }

    modifier deadlineExceeded() {
        require(now > deadline);
        _;
    }

    constructor (address payable _masterAddress, uint8 _maxNumberOfFreebies, uint _deadline)
        payable
        public
    {
        owner = msg.sender;
        maxNumberOfFreebies = _maxNumberOfFreebies;
        freebie = msg.value / maxNumberOfFreebies;
        numberOfGivenFreebies = 0;
        deadline = _deadline;
        masterAddress = _masterAddress;
    }

    /**
     * @notice The aim is to create a derivative and find someone to buy the counter position
     * @param long Decide if you want to be in the long or short position of your contract
     * @param dueDate Set a due date of your contract. Make sure this is supported by us. Use OD.exchange to avoid conflicts here.
     * @param strikePrice Choose a strike price which will be used at due date for calculation of your payout. Make sure that the format is correct. Use OD.exchange to avoid mistakes.
     */
    function createContractWithFreebie (
        bool long,
        uint256 dueDate,
        uint256 strikePrice
    )
        payable
        public
    {
        // New derivative must be created before deadline exceeded
        require(now < deadline);

        // Only once per maker address
        require(!isMakerWithFreebiePermission[msg.sender]);
        isMakerWithFreebiePermission[msg.sender] = true;

        // Only first customers get freebie
        numberOfGivenFreebies += 1;
        require(numberOfGivenFreebies <= maxNumberOfFreebies);

        Master master = Master(masterAddress);

        // Create new derivative from factory
        address newConditionalPayment = master.createConditionalPayment.value(msg.value)
        (
            msg.sender,
            long,
            dueDate,
            strikePrice
        );

        // Attribute derivative to maker
        makersDerivative[msg.sender] = newConditionalPayment;
    }

    /**
     *  @notice Withdraw the freebie after creation of derivative and finding counter party
     */
    function withdrawFreebie ()
        public
    {
        // Maker needs to have permission
        require(isMakerWithFreebiePermission[msg.sender]);

        // Only one withdraw per maker
        require(!gotFreebie[msg.sender]);
        gotFreebie[msg.sender] = true;

        ConditionalPayment conditionalPayment = ConditionalPayment(makersDerivative[msg.sender]);

        // Derivative needs to have at least one taker
        require(conditionalPayment.countCounterparties() > 0);

        msg.sender.transfer(freebie);
    }

    /**
     * @notice Owner can kick unsuccessful makers who did not succeed to find a taker before the deadline
     */
    function kick (address unsuccessfulMaker)
        public
        onlyByOwner
        deadlineExceeded
    {
        ConditionalPayment conditionalPayment = ConditionalPayment(makersDerivative[unsuccessfulMaker]);

        // Unsuccessful criterium
        require(conditionalPayment.countCounterparties() == 0);

        // Disqualify maker from freebie
        isMakerWithFreebiePermission[unsuccessfulMaker] = false;

        // Freebie can be given to new maker
        require(numberOfGivenFreebies > 0);
        numberOfGivenFreebies -= 1;
    }

    function withdrawUnusedFreebies ()
        public
        onlyByOwner
        deadlineExceeded
    {
        msg.sender.transfer((maxNumberOfFreebies - numberOfGivenFreebies)*freebie);
    }

}


interface Master {

  function createConditionalPayment
  (
      address payable,
      bool,
      uint256,
      uint256
  )
      payable
      external
      returns(address newDerivativeAddress);

}

interface ConditionalPayment {

  function countCounterparties() external returns(uint8);

}