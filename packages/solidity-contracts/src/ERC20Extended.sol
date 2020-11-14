/**
 * Source Code first verified at https://etherscan.io on Thursday, April 4, 2019
 (UTC) */

pragma solidity >=0.5.4<0.6.0;

contract ERC20Detailed {
  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(string memory name, string memory symbol, uint8 decimals) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

  function name() public view returns (string memory) {
    return _name;
  }

  function symbol() public view returns (string memory) {
    return _symbol;
  }

  function decimals() public view returns (uint8) {
    return _decimals;
  }
}


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

contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping(address => uint256) private _balances;

  mapping(address => mapping(address => uint256)) private _allowed;

  uint256 private _totalSupply;

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowed[owner][spender];
  }

  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  function approve(address spender, uint256 value) public returns (bool) {
    _approve(msg.sender, spender, value);
    return true;
  }

  function transferFrom(address from, address to, uint256 value) public returns (bool) {
    _transfer(from, to, value);
    _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
    return true;
  }

  function _transfer(address from, address to, uint256 value) internal {
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

  function _mint(address account, uint256 value) internal {
    require(account != address(0));

    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

  function _burn(address account, uint256 value) internal {
    require(account != address(0));

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

  function _approve(address owner, address spender, uint256 value) internal {
    require(spender != address(0));
    require(owner != address(0));

    _allowed[owner][spender] = value;
    emit Approval(owner, spender, value);
  }
}


contract Ownable {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  function isOwner() public view returns (bool) {
    return msg.sender == _owner;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

library MultiSigAction {
  struct Action {
    uint8 actionType;
    address callbackAddress;
    string callbackSig;
    bytes callbackData;
    uint8 quorum;
    address requestedBy;
    address rejectedBy;
    mapping(address => bool) approvedBy;
    uint8 numOfApprovals;
    bool rejected;
    bool failed;
  }

  function init(
    Action storage _self,
    uint8 _actionType,
    address _callbackAddress,
    string memory _callbackSig,
    bytes memory _callbackData,
    uint8 _quorum
  ) internal {
    _self.actionType = _actionType;
    _self.callbackAddress = _callbackAddress;
    _self.callbackSig = _callbackSig;
    _self.callbackData = _callbackData;
    _self.quorum = _quorum;
    _self.requestedBy = msg.sender;
  }

  function approve(Action storage _self) internal {
    require(!_self.rejected, "CANNOT_APPROVE_REJECTED");
    require(!_self.failed, "CANNOT_APPROVE_FAILED");
    require(!_self.approvedBy[msg.sender], "CANNOT_APPROVE_AGAIN");
    require(!isCompleted(_self), "CANNOT_APPROVE_COMPLETED");

    _self.approvedBy[msg.sender] = true;
    _self.numOfApprovals++;
  }

  function reject(Action storage _self) internal {
    require(!_self.approvedBy[msg.sender], "CANNOT_REJECT_APPROVED");
    require(!_self.failed, "CANNOT_REJECT_FAILED");
    require(!_self.rejected, "CANNOT_REJECT_REJECTED");
    require(!isCompleted(_self), "CANNOT_REJECT_COMPLETED");

    _self.rejectedBy = msg.sender;
    _self.rejected = true;
  }

  function complete(Action storage _self) internal {
    require(!_self.rejected, "CANNOT_COMPLETE_REJECTED");
    require(!_self.failed, "CANNOT_COMPLETE_FAILED");
    require(isCompleted(_self), "CANNNOT_COMPLETE_AGAIN");

    // solium-disable-next-line security/no-low-level-calls
    (bool _success, ) = _self.callbackAddress.call(
      abi.encodePacked(bytes4(keccak256(bytes(_self.callbackSig))), _self.callbackData)
    );

    if (!_success) {
      _self.failed = true;
    }
  }

  function isCompleted(Action storage _self) internal view returns (bool) {
    return _self.numOfApprovals >= _self.quorum && !_self.failed;
  }
}


library SafeMath {
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }
}

contract ERC20Extended is Ownable, ERC20, ERC20Detailed {
  constructor(string memory _name, string memory _symbol, uint8 _decimals)
    public
    ERC20Detailed(_name, _symbol, _decimals)
  {}

  function burn(uint256 _value) public onlyOwner returns (bool) {
    _burn(msg.sender, _value);
    return true;
  }

  function mint(address _to, uint256 _value) public onlyOwner returns (bool) {
    _mint(_to, _value);

    return true;
  }
}

contract MultiSigAdministration {
  event TenantRegistered(
    address indexed tenant,
    address[] creators,
    address[] admins,
    uint8 quorum
  );
  event ActionInitiated(address indexed tenant, uint256 indexed id, address initiatedBy);
  event ActionApproved(address indexed tenant, uint256 indexed id, address approvedBy);
  event ActionRejected(address indexed tenant, uint256 indexed id, address rejectedBy);
  event ActionCompleted(address indexed tenant, uint256 indexed id);
  event ActionFailed(address indexed tenant, uint256 indexed id);

  using MultiSigAction for MultiSigAction.Action;

  enum AdminAction {ADD_ADMIN, REMOVE_ADMIN, CHANGE_QUORUM, ADD_CREATOR, REMOVE_CREATOR}
  uint8 private constant OTHER_ACTION = uint8(AdminAction.REMOVE_CREATOR) + 1;

  mapping(address => uint256) public numOfActions;
  mapping(address => mapping(address => bool)) public isAdmin;
  mapping(address => uint8) public numOfAdmins;
  mapping(address => mapping(address => bool)) public isCreator;
  mapping(address => uint8) public quorums;
  mapping(address => bool) public isRegistered;
  mapping(address => uint256) public minValidActionId;

  mapping(address => mapping(uint256 => MultiSigAction.Action)) private actions;

  modifier onlyAdminOf(address _tenant) {
    require(isAdmin[_tenant][msg.sender], "ONLY_ADMIN_OF_TENANT");

    _;
  }

  modifier onlyAdminOrCreatorOf(address _tenant) {
    require(
      isAdmin[_tenant][msg.sender] || isCreator[_tenant][msg.sender],
      "ONLY_ADMIN_OR_CREATOR_OF_TENANT"
    );

    _;
  }

  modifier onlyRegistered(address _tenant) {
    require(isRegistered[_tenant], "ONLY_REGISTERED_TENANT");

    _;
  }

  modifier onlyMe() {
    require(msg.sender == address(this), "ONLY_INTERNAL");

    _;
  }

  modifier onlyExistingAction(address _tenant, uint256 _id) {
    require(_id <= numOfActions[_tenant], "ONLY_EXISTING_ACTION");
    require(_id > 0, "ONLY_EXISTING_ACTION");

    _;
  }

  constructor() public {}

  /* Public Functions - Start */
  function register(
    address _tenant,
    address[] memory _creators,
    address[] memory _admins,
    uint8 _quorum
  ) public returns (bool success) {
    require(
      msg.sender == _tenant || msg.sender == Ownable(_tenant).owner(),
      "ONLY_TENANT_OR_TENANT_OWNER"
    );

    return _register(_tenant, _creators, _admins, _quorum);
  }

  function initiateAdminAction(
    address _tenant,
    AdminAction _adminAction,
    bytes memory _callbackData
  ) public onlyRegistered(_tenant) onlyAdminOf(_tenant) returns (uint256 id) {
    string memory _callbackSig = _getAdminActionCallbackSig(_adminAction);

    uint256 _id = _initiateAction(
      uint8(_adminAction),
      _tenant,
      address(this),
      _callbackSig,
      abi.encodePacked(abi.encode(_tenant), _callbackData)
    );
    _approveAction(_tenant, _id);

    return _id;
  }

  function initiateAction(address _tenant, string memory _callbackSig, bytes memory _callbackData)
    public
    onlyRegistered(_tenant)
    onlyAdminOrCreatorOf(_tenant)
    returns (uint256 id)
  {
    uint256 _id = _initiateAction(OTHER_ACTION, _tenant, _tenant, _callbackSig, _callbackData);

    if (isAdmin[_tenant][msg.sender]) {
      _approveAction(_tenant, _id);
    }

    return _id;
  }

  function approveAction(address _tenant, uint256 _id)
    public
    onlyRegistered(_tenant)
    onlyAdminOf(_tenant)
    onlyExistingAction(_tenant, _id)
    returns (bool success)
  {
    return _approveAction(_tenant, _id);
  }

  function rejectAction(address _tenant, uint256 _id)
    public
    onlyRegistered(_tenant)
    onlyAdminOrCreatorOf(_tenant)
    onlyExistingAction(_tenant, _id)
    returns (bool success)
  {
    return _rejectAction(_tenant, _id);
  }

  function addAdmin(address _tenant, address _admin, bool _increaseQuorum) public onlyMe {
    minValidActionId[_tenant] = numOfActions[_tenant] + 1;
    _addAdmin(_tenant, _admin);

    if (_increaseQuorum) {
      uint8 _quorum = quorums[_tenant];
      uint8 _newQuorum = _quorum + 1;
      require(_newQuorum > _quorum, "OVERFLOW");

      _changeQuorum(_tenant, _newQuorum);
    }
  }

  function removeAdmin(address _tenant, address _admin, bool _decreaseQuorum) public onlyMe {
    uint8 _quorum = quorums[_tenant];

    if (_decreaseQuorum && _quorum > 1) {
      _changeQuorum(_tenant, _quorum - 1);
    }

    minValidActionId[_tenant] = numOfActions[_tenant] + 1;
    _removeAdmin(_tenant, _admin);
  }

  function changeQuorum(address _tenant, uint8 _quorum) public onlyMe {
    minValidActionId[_tenant] = numOfActions[_tenant] + 1;
    _changeQuorum(_tenant, _quorum);
  }

  function addCreator(address _tenant, address _creator) public onlyMe {
    _addCreator(_tenant, _creator);
  }

  function removeCreator(address _tenant, address _creator) public onlyMe {
    _removeCreator(_tenant, _creator);
  }

  function getAction(address _tenant, uint256 _id)
    public
    view
    returns (
    bool isAdminAction,
    string memory callbackSig,
    bytes memory callbackData,
    uint8 quorum,
    address requestedBy,
    address rejectedBy,
    uint8 numOfApprovals,
    bool rejected,
    bool failed,
    bool completed,
    bool valid
  )
  {
    MultiSigAction.Action storage _action = _getAction(_tenant, _id);

    isAdminAction = _action.callbackAddress == address(this);
    callbackSig = _action.callbackSig;
    callbackData = _action.callbackData;
    quorum = _action.quorum;
    requestedBy = _action.requestedBy;
    rejectedBy = _action.rejectedBy;
    numOfApprovals = _action.numOfApprovals;
    rejected = _action.rejected;
    failed = _action.failed;
    completed = _action.isCompleted();
    valid = _isActionValid(_tenant, _id);
  }

  function hasApprovedBy(address _tenant, uint256 _id, address _admin)
    public
    view
    returns (bool approvedBy)
  {
    approvedBy = _getAction(_tenant, _id).approvedBy[_admin];
  }
  /* Public Functions - End */

  /* Private Functions - Start */
  function _getAction(address _tenant, uint256 _id)
    private
    view
    returns (MultiSigAction.Action storage)
  {
    return actions[_tenant][_id];
  }

  function _isActionValid(address _tenant, uint256 _id) private view returns (bool) {
    return _id >= minValidActionId[_tenant];
  }

  function _getAdminActionCallbackSig(AdminAction _adminAction)
    private
    pure
    returns (string memory)
  {
    if (_adminAction == AdminAction.ADD_ADMIN) {
      return "addAdmin(address,address,bool)";
    }

    if (_adminAction == AdminAction.REMOVE_ADMIN) {
      return "removeAdmin(address,address,bool)";
    }

    if (_adminAction == AdminAction.CHANGE_QUORUM) {
      return "changeQuorum(address,uint8)";
    }

    if (_adminAction == AdminAction.ADD_CREATOR) {
      return "addCreator(address,address)";
    }

    return "removeCreator(address,address)";
  }

  function _addCreator(address _tenant, address _creator) private {
    require(_creator != address(this), "INVALID_CREATOR");
    require(!isAdmin[_tenant][_creator], "ALREADY_ADMIN");
    require(!isCreator[_tenant][_creator], "ALREADY_CREATOR");

    isCreator[_tenant][_creator] = true;
  }

  function _removeCreator(address _tenant, address _creator) private {
    require(isCreator[_tenant][_creator], "NOT_CREATOR");

    isCreator[_tenant][_creator] = false;
  }

  function _addAdmin(address _tenant, address _admin) private {
    require(_admin != address(this), "INVALID_ADMIN");
    require(!isAdmin[_tenant][_admin], "ALREADY_ADMIN");
    require(!isCreator[_tenant][_admin], "ALREADY_CREATOR");
    require(numOfAdmins[_tenant] + 1 > numOfAdmins[_tenant], "OVERFLOW");

    numOfAdmins[_tenant]++;
    isAdmin[_tenant][_admin] = true;
  }

  function _removeAdmin(address _tenant, address _admin) private {
    require(isAdmin[_tenant][_admin], "NOT_ADMIN");
    require(--numOfAdmins[_tenant] >= quorums[_tenant], "TOO_FEW_ADMINS");

    isAdmin[_tenant][_admin] = false;
  }

  function _changeQuorum(address _tenant, uint8 _quorum) private {
    require(_quorum <= numOfAdmins[_tenant], "QUORUM_TOO_BIG");
    require(_quorum > 0, "QUORUM_ZERO");

    quorums[_tenant] = _quorum;
  }

  function _register(
    address _tenant,
    address[] memory _creators,
    address[] memory _admins,
    uint8 _quorum
  ) private returns (bool) {
    require(_tenant != address(this), "INVALID_TENANT");
    require(!isRegistered[_tenant], "ALREADY_REGISTERED");

    for (uint8 i = 0; i < _admins.length; i++) {
      _addAdmin(_tenant, _admins[i]);
    }
    _changeQuorum(_tenant, _quorum);

    for (uint8 i = 0; i < _creators.length; i++) {
      _addCreator(_tenant, _creators[i]);
    }

    isRegistered[_tenant] = true;
    emit TenantRegistered(_tenant, _creators, _admins, _quorum);

    return true;
  }

  function _initiateAction(
    uint8 _actionType,
    address _tenant,
    address _callbackAddress,
    string memory _callbackSig,
    bytes memory _callbackData
  ) private returns (uint256) {
    uint256 _id = ++numOfActions[_tenant];
    uint8 _quorum = quorums[_tenant];

    if (_actionType == uint8(AdminAction.REMOVE_ADMIN)) {
      require(numOfAdmins[_tenant] > 1, "TOO_FEW_ADMINS");

      if (_quorum == numOfAdmins[_tenant] && _quorum > 2) {
        _quorum = numOfAdmins[_tenant] - 1;
      }
    }

    _getAction(_tenant, _id).init(
      _actionType,
      _callbackAddress,
      _callbackSig,
      _callbackData,
      _quorum
    );

    emit ActionInitiated(_tenant, _id, msg.sender);

    return _id;
  }

  function _approveAction(address _tenant, uint256 _id) private returns (bool) {
    require(_isActionValid(_tenant, _id), "ACTION_INVALIDATED");

    MultiSigAction.Action storage _action = _getAction(_tenant, _id);
    _action.approve();
    emit ActionApproved(_tenant, _id, msg.sender);

    if (_action.isCompleted()) {
      _action.complete();

      if (_action.failed) {
        emit ActionFailed(_tenant, _id);
      } else {
        emit ActionCompleted(_tenant, _id);
      }
    }

    return true;
  }

  function _rejectAction(address _tenant, uint256 _id) private returns (bool) {
    MultiSigAction.Action storage _action = _getAction(_tenant, _id);

    if (isCreator[_tenant][msg.sender]) {
      require(msg.sender == _action.requestedBy, "CREATOR_REJECT_NOT_REQUESTOR");
    }

    if (_action.actionType == uint8(AdminAction.REMOVE_ADMIN)) {
      (, address _admin, ) = abi.decode(_action.callbackData, (address, address, bool));

      require(_admin != msg.sender, "CANNOT_REJECT_ITS_OWN_REMOVAL");
    }

    _action.reject();

    emit ActionRejected(_tenant, _id, msg.sender);

    return true;
  }
  /* Private Functions - End */
}

contract MultiSigProxyOwner {
  event BurnRequested(address indexed owner, uint256 value);
  event BurnCanceled(address indexed owner);
  event BurnMinSet(uint256 burnMin);

  struct BurnRequest {
    uint256 actionId;
    uint256 value;
  }

  uint256 public burnMin;
  mapping(address => BurnRequest) public burnRequests;

  ERC20Extended private token;
  MultiSigAdministration private multiSigAdmin;
  address[] private creators;

  modifier onlyMultiSigAdministration {
    require(msg.sender == address(multiSigAdmin));

    _;
  }

  constructor(
    address _token,
    address _multiSigAdmin,
    address[] memory _admins,
    uint8 _quorum,
    uint256 _burnMin
  ) public {
    token = ERC20Extended(_token);
    multiSigAdmin = MultiSigAdministration(_multiSigAdmin);
    burnMin = _burnMin;

    creators.push(address(this));
    multiSigAdmin.register(address(this), creators, _admins, _quorum);

  }

  function requestBurn(uint256 _value) public returns (bool) {
    require(!_burnRequestExist(msg.sender), "BURN_REQUEST_EXISTS");
    require(_value >= burnMin, "SMALLER_THAN_MIN_BURN_AMOUNT");

    token.transferFrom(msg.sender, address(this), _value);
    burnRequests[msg.sender].value = _value;
    burnRequests[msg.sender].actionId = multiSigAdmin.initiateAction(
      address(this),
      "burn(address,uint256)",
      abi.encode(msg.sender, _value)
    );

    emit BurnRequested(msg.sender, _value);

    return true;
  }

  function cancelBurn() public returns (bool) {
    uint256 _actionId = burnRequests[msg.sender].actionId;
    uint256 _value = burnRequests[msg.sender].value;
    _deleteBurnRequest(msg.sender);

    // solium-disable-next-line security/no-low-level-calls
    (bool _success, ) = address(multiSigAdmin).call(
      abi.encodeWithSignature("rejectAction(address,uint256)", address(this), _actionId)
    );
    _success;
    token.transfer(msg.sender, _value);

    emit BurnCanceled(msg.sender);

    return true;
  }

  function burn(address _owner, uint256 _value) public onlyMultiSigAdministration returns (bool) {
    require(burnRequests[_owner].value == _value, "BURN_VALUE_MISMATCH");

    _deleteBurnRequest(_owner);
    token.burn(_value);

    return true;
  }

  function mint(address _to, uint256 _value) public onlyMultiSigAdministration returns (bool) {
    return token.mint(_to, _value);
  }

  function transferOwnership(address _newOwner) public onlyMultiSigAdministration returns (bool) {
    token.transferOwnership(_newOwner);

    return true;
  }

  function setBurnMin(uint256 _burnMin) public onlyMultiSigAdministration returns (bool) {
    return _setBurnMin(_burnMin);
  }

  function _setBurnMin(uint256 _burnMin) internal returns (bool) {
    burnMin = _burnMin;
    emit BurnMinSet(_burnMin);

    return true;
  }

  function _burnRequestExist(address _owner) internal view returns (bool) {
    return burnRequests[_owner].actionId != 0;
  }

  function _deleteBurnRequest(address _owner) internal returns (bool) {
    require(_burnRequestExist(_owner), "NO_BURN_REQUEST_EXISTS");

    burnRequests[_owner].actionId = 0;
    burnRequests[_owner].value = 0;

    return true;
  }
}