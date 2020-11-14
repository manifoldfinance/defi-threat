/**
 * Source Code first verified at https://etherscan.io on Friday, April 5, 2019
 (UTC) */

pragma solidity ^0.5.1;

contract LockRequestable {

        // MEMBERS
        /// @notice  the count of all invocations of `generateLockId`.
        uint256 public lockRequestCount;

        constructor() public {
                lockRequestCount = 0;
        }

        // FUNCTIONS
        /** @notice  Returns a fresh unique identifier.
            *
            * @dev the generation scheme uses three components.
            * First, the blockhash of the previous block.
            * Second, the deployed address.
            * Third, the next value of the counter.
            * This ensure that identifiers are unique across all contracts
            * following this scheme, and that future identifiers are
            * unpredictable.
            *
            * @return a 32-byte unique identifier.
            */
        function generateLockId() internal returns (bytes32 lockId) {
                return keccak256(
                abi.encodePacked(blockhash(block.number - 1), address(this), ++lockRequestCount)
                );
        }
}

contract CustodianUpgradeable is LockRequestable {

        // TYPES
        /// @dev  The struct type for pending custodian changes.
        struct CustodianChangeRequest {
                address proposedNew;
        }

        // MEMBERS
        /// @dev  The address of the account or contract that acts as the custodian.
        address public custodian;

        /// @dev  The map of lock ids to pending custodian changes.
        mapping (bytes32 => CustodianChangeRequest) public custodianChangeReqs;

        constructor(address _custodian) public LockRequestable() {
                custodian = _custodian;
        }

        // MODIFIERS
        modifier onlyCustodian {
                require(msg.sender == custodian);
                _;
        }

        /** @notice  Requests a change of the custodian associated with this contract.
            *
            * @dev  Returns a unique lock id associated with the request.
            * Anyone can call this function, but confirming the request is authorized
            * by the custodian.
            *
            * @param  _proposedCustodian  The address of the new custodian.
            * @return  lockId  A unique identifier for this request.
            */
        function requestCustodianChange(address _proposedCustodian) public returns (bytes32 lockId) {
                require(_proposedCustodian != address(0));

                lockId = generateLockId();

                custodianChangeReqs[lockId] = CustodianChangeRequest({
                        proposedNew: _proposedCustodian
                });

                emit CustodianChangeRequested(lockId, msg.sender, _proposedCustodian);
        }

        /** @notice  Confirms a pending change of the custodian associated with this contract.
            *
            * @dev  When called by the current custodian with a lock id associated with a
            * pending custodian change, the `address custodian` member will be updated with the
            * requested address.
            *
            * @param  _lockId  The identifier of a pending change request.
            */
        function confirmCustodianChange(bytes32 _lockId) public onlyCustodian {
                custodian = getCustodianChangeReq(_lockId);

                delete custodianChangeReqs[_lockId];

                emit CustodianChangeConfirmed(_lockId, custodian);
        }

        // PRIVATE FUNCTIONS
        function getCustodianChangeReq(bytes32 _lockId) private view returns (address _proposedNew) {
                CustodianChangeRequest storage changeRequest = custodianChangeReqs[_lockId];

                // reject ‘null’ results from the map lookup
                // this can only be the case if an unknown `_lockId` is received
                require(changeRequest.proposedNew != address(0));

                return changeRequest.proposedNew;
        }

        /// @dev  Emitted by successful `requestCustodianChange` calls.
        event CustodianChangeRequested(
                bytes32 _lockId,
                address _msgSender,
                address _proposedCustodian
        );

        /// @dev Emitted by successful `confirmCustodianChange` calls.
        event CustodianChangeConfirmed(bytes32 _lockId, address _newCustodian);
}

contract KnowYourCustomer is CustodianUpgradeable {

    enum Status {
        none,
        passed,
        suspended
    }

    struct Customer {
        Status status;
        mapping(string => string) fields;
    }
    
    event ProviderAuthorized(address indexed _provider, string _name);
    event ProviderRemoved(address indexed _provider, string _name);
    event CustomerApproved(address indexed _customer, address indexed _provider);
    event CustomerSuspended(address indexed _customer, address indexed _provider);
    event CustomerFieldSet(address indexed _customer, address indexed _field, string _name);

    mapping(address => bool) private providers;
    mapping(address => Customer) private customers;

    constructor(address _custodian) public CustodianUpgradeable(_custodian) {
        customers[_custodian].status = Status.passed;
        customers[_custodian].fields["type"] = "custodian";
        emit CustomerApproved(_custodian, msg.sender);
        emit CustomerFieldSet(_custodian, msg.sender, "type");
    }

    function providerAuthorize(address _provider, string calldata name) external onlyCustodian {
        require(providers[_provider] == false, "provider must not exist");
        providers[_provider] = true;
        // cc:II. Manage Providers#2;Provider becomes authorized in contract;1;
        emit ProviderAuthorized(_provider, name);
    }

    function providerRemove(address _provider, string calldata name) external onlyCustodian {
        require(providers[_provider] == true, "provider must exist");
        delete providers[_provider];
        emit ProviderRemoved(_provider, name);
    }

    function hasWritePermissions(address _provider) external view returns (bool) {
        return _provider == custodian || providers[_provider] == true;
    }

    function getCustomerStatus(address _customer) external view returns (Status) {
        return customers[_customer].status;
    }

    function getCustomerField(address _customer, string calldata _field) external view returns (string memory) {
        return customers[_customer].fields[_field];
    }

    function approveCustomer(address _customer) external onlyAuthorized {
        Status status = customers[_customer].status;
        require(status != Status.passed, "customer must not be approved before");
        customers[_customer].status = Status.passed;
        // cc:III. Manage Customers#2;Customer becomes approved in contract;1;
        emit CustomerApproved(_customer, msg.sender);
    }

    function setCustomerField(address _customer, string calldata _field, string calldata _value) external onlyAuthorized {
        Status status = customers[_customer].status;
        require(status != Status.none, "customer must have a set status");
        customers[_customer].fields[_field] = _value;
        emit CustomerFieldSet(_customer, msg.sender, _field);
    }

    function suspendCustomer(address _customer) external onlyAuthorized {
        Status status = customers[_customer].status;
        require(status != Status.suspended, "customer must be not suspended");
        customers[_customer].status = Status.suspended;
        emit CustomerSuspended(_customer, msg.sender);
    }

    modifier onlyAuthorized() {
        require(msg.sender == custodian || providers[msg.sender] == true);
        _;
    }
}