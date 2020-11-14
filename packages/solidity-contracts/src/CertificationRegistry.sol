/**
 * Source Code first verified at https://etherscan.io on Thursday, March 21, 2019
 (UTC) */

pragma solidity ^0.5.0;

// File: contracts/IndividualCertification.sol

/**
  * @title   Individual Certification Contract
  * @author  Rosen GmbH
  *
  * This contract represents the individual certificate.
  */
contract IndividualCertification {
    address public registryAddress;
    bytes32 public b0;
    bytes32 public b1;

    constructor(bytes32 _b0, bytes32 _b1)
    public
    {
        registryAddress = msg.sender;
        b0 = _b0;
        b1 = _b1;
    }
    function updateHashValue(bytes32 _b0, bytes32 _b1)
    public
    {
        require(msg.sender == registryAddress);
        b0 = _b0;
        b1 = _b1;
    }

    function hashValue()
    public
    view
    returns (bytes32, bytes32)
    {
        return (b0, b1);
    }

    /**
  * Extinguish this certificate.
  *
  * This can be done by the same certifier contract which has created
  * the certificate in the first place only.
  */
    function deleteCertificate() public {
        require(msg.sender == registryAddress);
        selfdestruct(msg.sender);
    }
}

// File: contracts/OrganizationalCertification.sol

/**
  * @title   Certificate Contract
  * @author  Chainstep GmbH
  *
  * Each instance of this contract represents a single certificate.
  */
contract OrganizationalCertification  {

    /**
      * Address of certifier contract this certificate belongs to.
      */
    address public registryAddress;

    string public CompanyName;
    string public Norm;
    string public CertID;
    uint public issued;
    uint public expires;
    string public Scope;
    string public issuingBody;

    /**
      * Constructor.
      *
      * @param _CompanyName Name of company name the certificate is issued to.
      * @param _Norm The norm.
      * @param _CertID Unique identifier of the certificate.
      * @param _issued Timestamp (Unix epoch) when the certificate was issued.
      * @param _expires Timestamp (Unix epoch) when the certificate will expire.
      * @param _Scope The scope of the certificate.
      * @param _issuingBody The issuer of the certificate.
      */
    constructor(
        string memory _CompanyName,
        string memory _Norm,
        string memory _CertID,
        uint _issued,
        uint _expires,
        string memory _Scope,
        string memory _issuingBody)
        public
    {
        require(_issued < _expires);

        registryAddress = msg.sender;

        CompanyName = _CompanyName;
        Norm =_Norm;
        CertID = _CertID;
        issued = _issued;
        expires = _expires;
        Scope = _Scope;
        issuingBody = _issuingBody;
    }

    /**
      * Extinguish this certificate.
      *
      * This can be done the same certifier contract which has created
      * the certificate in the first place only.
      */
    function deleteCertificate() public {
        require(msg.sender == registryAddress);
        selfdestruct(tx.origin);
    }

}

// File: contracts\CertificationRegistry.sol

/**
  * @title   Certification Contract
  * @author  Chainstep GmbH
  * @author  Rosen GmbH
  * This contract represents the singleton certificate registry.
  */

contract CertificationRegistry {

    /** @dev Dictionary of all Certificate Contracts issued by the Organization.
             Stores the Organization ID and which Certificates they issued.
             Stores the Certification key derived from the sha(CertID) and stores the
             address where the corresponding Certificate is stored.
             Mapping(keccak256(CertID, organizationID) => certAddress))
             */
    mapping (bytes32 => address) public CertificateAddresses;
    mapping (bytes32 => address) public RosenCertificateAddresses;

    /** @dev Dictionary that stores which addresses are owntrated by Certification administrators and
             which Organization those Certification adminisors belong to
             keccak256 (adminAddress, organizationID) => bool
     */
    mapping (bytes32  => bool) public CertAdmins;

    /** @dev Dictionary that stores which addresses are owned by ROSEN Certification administrators
             Mapping(adminAddress => bool)
    */
    mapping (address => bool) public RosenCertAdmins;

    /** @dev stores the address of the Global Administrator*/
    address public GlobalAdmin;


    event CertificationSet(address indexed contractAddress);
    event IndividualCertificationSet(address indexed contractAddress);
    event IndividualCertificationUpdated(address indexed contractAddress);
    event CertificationDeleted(address indexed contractAddress);
    event CertAdminAdded(address indexed account);
    event CertAdminDeleted(address account);
    event GlobalAdminChanged(address indexed account);

    /**
      * Constructor.
      *
      * The creator of this contract becomes the global administrator.
      */
    constructor() public {
        GlobalAdmin = msg.sender;
    }

    // Functions

    /**
      * Create a new certificate contract.
      * This can be done by an certificate administrator only.
      *
      * @param _CompanyName Name of company name the certificate is issued to.
      * @param _Norm The norm.
      * @param _CertID Unique identifier of the certificate.
      * @param _issued Timestamp (Unix epoch) when the certificate was issued.
      * @param _expires Timestamp (Unix epoch) when the certificate will expire.
      * @param _Scope The scope of the certificate.
      * @param _issuingBody The issuer of the certificate.
      */
    function setCertificate(
            string memory _CompanyName,
            string memory _Norm,
            string memory _CertID,
            uint _issued,
            uint _expires,
            string memory _Scope,
            string memory _issuingBody
    )
    public
    onlyRosenCertAdmin
    {
        bytes32 certKey = keccak256(abi.encodePacked(_CertID));

        OrganizationalCertification orgCert = new OrganizationalCertification(
            _CompanyName,
            _Norm,
            _CertID,
            _issued,
            _expires,
            _Scope,
            _issuingBody);

        RosenCertificateAddresses[certKey] = address(orgCert);
        emit CertificationSet(address(orgCert));
    }

    function setIndividualCertificate(
            bytes32 b0,
            bytes32 b1,
            string memory _CertID,
            string memory _organizationID)
        public
        onlyPrivilegedCertAdmin(_organizationID)
        entryMustNotExist(_CertID, _organizationID)
    {

        IndividualCertification individualCert = new IndividualCertification(b0, b1);
        CertificateAddresses[toCertificateKey(_CertID, _organizationID)] = address(individualCert);
        emit IndividualCertificationSet(address(individualCert));
    }

    function updateIndividualCertificate(bytes32 b0, bytes32 b1, string memory _CertID, string memory _organizationID)
        public
        onlyPrivilegedCertAdmin(_organizationID)
        duplicatedHashGuard(b0, b1, _CertID, _organizationID)
    {
		address certAddr = CertificateAddresses[toCertificateKey(_CertID,_organizationID)];
        IndividualCertification(certAddr).updateHashValue(b0, b1);
        emit IndividualCertificationUpdated(certAddr);
    }

    /**
      * Delete an existing certificate.
      *
      * This can be done by an certificate administrator only.
      *
      * @param _CertID Unique identifier of the certificate to delete.
      */
    function delOrganizationCertificate(string memory _CertID)
        public
        onlyRosenCertAdmin
    {
		bytes32 certKey = keccak256(abi.encodePacked(_CertID));
        OrganizationalCertification(RosenCertificateAddresses[certKey]).deleteCertificate();

        emit CertificationDeleted(RosenCertificateAddresses[certKey]);
        delete RosenCertificateAddresses[certKey];
    }
    /**
      * Delete an exisiting certificate.
      *
      * This can be done by an certificate administrator only.
      *
      * @param _CertID Unique identifier of the certificate to delete.
      */
    function delIndividualCertificate(
        string memory _CertID,
        string memory _organizationID)
    public
    onlyPrivilegedCertAdmin(_organizationID)
    {
		bytes32 certKey = toCertificateKey(_CertID,_organizationID);
        IndividualCertification(CertificateAddresses[certKey]).deleteCertificate();
        emit CertificationDeleted(CertificateAddresses[certKey]);
        delete CertificateAddresses[certKey];

    }
    /**
      * Register a certificate administrator.
      *
      * This can be done by the global administrator only.
      *
      * @param _CertAdmin Address of certificate administrator to be added.
      */
    function addCertAdmin(address _CertAdmin, string memory _organizationID)
        public
        onlyGlobalAdmin
    {
        CertAdmins[toCertAdminKey(_CertAdmin, _organizationID)] = true;
        emit CertAdminAdded(_CertAdmin);
    }

    /**
      * Delete a certificate administrator.
      *
      * This can be done by the global administrator only.
      *
      * @param _CertAdmin Address of certificate administrator to be removed.
      */
    function delCertAdmin(address _CertAdmin, string memory _organizationID)
    public
    onlyGlobalAdmin
    {
        delete CertAdmins[toCertAdminKey(_CertAdmin, _organizationID)];
        emit CertAdminDeleted(_CertAdmin);
    }

    /**
  * Register a ROSEN certificate administrator.
  *
  * This can be done by the global administrator only.
  *
  * @param _CertAdmin Address of certificate administrator to be added.
  */
    function addRosenCertAdmin(address _CertAdmin) public onlyGlobalAdmin {
        RosenCertAdmins[_CertAdmin] = true;
        emit CertAdminAdded(_CertAdmin);
    }

    /**
      * Delete a ROSEN certificate administrator.
      *
      * This can be done by the global administrator only.
      *
      * @param _CertAdmin Address of certificate administrator to be removed.
      */
    function delRosenCertAdmin(address _CertAdmin) public onlyGlobalAdmin {
        delete RosenCertAdmins[_CertAdmin];
        emit CertAdminDeleted(_CertAdmin);
    }

    /**
      * Change the address of the global administrator.
      *
      * This can be done by the global administrator only.
      *
      * @param _GlobalAdmin Address of new global administrator to be set.
      */
    function changeGlobalAdmin(address _GlobalAdmin) public onlyGlobalAdmin {
        GlobalAdmin=_GlobalAdmin;
        emit GlobalAdminChanged(_GlobalAdmin);

    }

    // Constant Functions

    /**
      * Determines the address of a certificate contract.
      *
      * @param _CertID Unique certificate identifier.
      * @return Address of certification contract.
      */
    function getCertAddressByID(string memory _organizationID, string memory _CertID)
        public
        view
        returns (address)
    {
        return CertificateAddresses[toCertificateKey(_CertID,_organizationID)];
    }

    /**
      * Determines the address of a certificate contract.
      *
      * @param _CertID Unique certificate identifier.
      * @return Address of certification contract.
      */
    function getOrganizationalCertAddressByID(string memory _CertID)
        public
        view
        returns (address)
    {
        return RosenCertificateAddresses[keccak256(abi.encodePacked(_CertID))];
    }


    function getCertAdminByOrganizationID(address _certAdmin, string memory _organizationID)
        public
        view
        returns (bool)
    {
        return CertAdmins[toCertAdminKey(_certAdmin, _organizationID)];
    }

    /**
      * Derives an unique key from a certificate identifier to be used in the
      * global mapping CertificateAddresses.
      *
      * This is necessary due to certificate identifiers are of type string
      * which cannot be used as dictionary keys.
      *
      * @param _CertID The unique certificate identifier.
      * @return The key derived from certificate identifier.
      */
    function toCertificateKey(string memory _CertID, string memory _organizationID)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_CertID, _organizationID));
    }


    function toCertAdminKey(address _certAdmin, string memory _organizationID)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_certAdmin, _organizationID));
    }


    // Modifiers

    /**
      * Ensure that only the global administrator is able to perform.
      */
    modifier onlyGlobalAdmin () {
        require(msg.sender == GlobalAdmin,
		"Access denied, require global admin account");
        _;
    }

    /**
      * Ensure that only a privileged certificate administrator is able to perform.
      */
    modifier onlyPrivilegedCertAdmin(string memory organizationID) {
        require(CertAdmins[toCertAdminKey(msg.sender, organizationID)] || RosenCertAdmins[msg.sender], 
		"Access denied, Please use function with certificate admin privileges");
        _;
    }

    modifier onlyRosenCertAdmin() {
        require(RosenCertAdmins[msg.sender],
        "Access denied, Please use function with certificate admin privileges");
        _;
    }
    /**
     * Ensure individual entry should not exist, prevent re-entrancy
     */
    modifier entryMustNotExist(string memory _CertID, string memory _organizationID) {
        require(CertificateAddresses[toCertificateKey(_CertID, _organizationID)] == address(0),
        "Entry existed exception!");
        _;
    }
    modifier duplicatedHashGuard(
      bytes32 _b0,
      bytes32 _b1,
      string memory _CertID,
      string memory _organizationID) {

        IndividualCertification individualCert = IndividualCertification(CertificateAddresses[toCertificateKey(_CertID, _organizationID)]);
        require(keccak256(abi.encodePacked(_b0, _b1)) != keccak256(abi.encodePacked(individualCert.b0(), individualCert.b1())),
        "Duplicated hash-value exception!");
        _;
    }
}