/**
 * Source Code first verified at https://etherscan.io on Wednesday, April 24, 2019
 (UTC) */

pragma solidity ^0.4.21;

/** @title  KRWT contract
  *
  * @author  Hansung Future Co.,Ltd
  */
contract LockRequestable {

    uint256 public lockRequestCount;

    function LockRequestable() public {
        lockRequestCount = 0;
    }

    function generateLockId() internal returns (bytes32 lockId) {
        return keccak256(block.blockhash(block.number - 1), address(this), ++lockRequestCount);
    }
}


/** @title  KRWT contract
  *
  * @author  Hansung Future Co.,Ltd
  */
contract CustodianUpgradeable is LockRequestable {

    struct CustodianChangeRequest {
        address proposedNew;
    }

    address public custodian;

    mapping (bytes32 => CustodianChangeRequest) public custodianChangeReqs;

    function CustodianUpgradeable(
        address _custodian
    )
      LockRequestable()
      public
    {
        custodian = _custodian;
    }

    modifier onlyCustodian {
        require(msg.sender == custodian);
        _;
    }

    function requestCustodianChange(address _proposedCustodian) public returns (bytes32 lockId) {
        require(_proposedCustodian != address(0));

        lockId = generateLockId();

        custodianChangeReqs[lockId] = CustodianChangeRequest({
            proposedNew: _proposedCustodian
        });

        emit CustodianChangeRequested(lockId, msg.sender, _proposedCustodian);
    }

    function confirmCustodianChange(bytes32 _lockId) public onlyCustodian {
        custodian = getCustodianChangeReq(_lockId);

        delete custodianChangeReqs[_lockId];

        emit CustodianChangeConfirmed(_lockId, custodian);
    }

    function getCustodianChangeReq(bytes32 _lockId) private view returns (address _proposedNew) {
        CustodianChangeRequest storage changeRequest = custodianChangeReqs[_lockId];

        require(changeRequest.proposedNew != 0);

        return changeRequest.proposedNew;
    }

    event CustodianChangeRequested(
        bytes32 _lockId,
        address _msgSender,
        address _proposedCustodian
    );

    event CustodianChangeConfirmed(bytes32 _lockId, address _newCustodian);
}


/** @title  KRWT contract
  *
  * @author  Hansung Future Co.,Ltd
  */
contract ERC20ImplUpgradeable is CustodianUpgradeable  {

    struct ImplChangeRequest {
        address proposedNew;
    }

    ERC20Impl public erc20Impl;

    mapping (bytes32 => ImplChangeRequest) public implChangeReqs;

    function ERC20ImplUpgradeable(address _custodian) CustodianUpgradeable(_custodian) public {
        erc20Impl = ERC20Impl(0x0);
    }

    modifier onlyImpl {
        require(msg.sender == address(erc20Impl));
        _;
    }

    function requestImplChange(address _proposedImpl) public returns (bytes32 lockId) {
        require(_proposedImpl != address(0));

        lockId = generateLockId();

        implChangeReqs[lockId] = ImplChangeRequest({
            proposedNew: _proposedImpl
        });

        emit ImplChangeRequested(lockId, msg.sender, _proposedImpl);
    }

    function confirmImplChange(bytes32 _lockId) public onlyCustodian {
        erc20Impl = getImplChangeReq(_lockId);

        delete implChangeReqs[_lockId];

        emit ImplChangeConfirmed(_lockId, address(erc20Impl));
    }

    function getImplChangeReq(bytes32 _lockId) private view returns (ERC20Impl _proposedNew) {
        ImplChangeRequest storage changeRequest = implChangeReqs[_lockId];

        require(changeRequest.proposedNew != address(0));

        return ERC20Impl(changeRequest.proposedNew);
    }

    event ImplChangeRequested(
        bytes32 _lockId,
        address _msgSender,
        address _proposedImpl
    );

    event ImplChangeConfirmed(bytes32 _lockId, address _newImpl);
}

/** @title  KRWT contract
  *
  * @author  Hansung Future Co.,Ltd
  */
contract ERC20Interface {
  function totalSupply() public view returns (uint256);

  function balanceOf(address _owner) public view returns (uint256 balance);

  function transfer(address _to, uint256 _value) public returns (bool success);

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

  function approve(address _spender, uint256 _value) public returns (bool success);

  function allowance(address _owner, address _spender) public view returns (uint256 remaining);

  event Transfer(address indexed _from, address indexed _to, uint256 _value);

  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/** @title  KRWT contract
  *
  * @author  Hansung Future Co.,Ltd
  */
contract ERC20Proxy is ERC20Interface, ERC20ImplUpgradeable {

    string public name;

    string public symbol;

    uint8 public decimals;

    function ERC20Proxy(
        string _name,
        string _symbol,
        uint8 _decimals,
        address _custodian
    )
        ERC20ImplUpgradeable(_custodian)
        public
    {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return erc20Impl.totalSupply();
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return erc20Impl.balanceOf(_owner);
    }

    function emitTransfer(address _from, address _to, uint256 _value) public onlyImpl {
        emit Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        return erc20Impl.transferWithSender(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        return erc20Impl.transferFromWithSender(msg.sender, _from, _to, _value);
    }

    function emitApproval(address _owner, address _spender, uint256 _value) public onlyImpl {
        emit Approval(_owner, _spender, _value);
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        return erc20Impl.approveWithSender(msg.sender, _spender, _value);
    }

    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool success) {
        return erc20Impl.increaseApprovalWithSender(msg.sender, _spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool success) {
        return erc20Impl.decreaseApprovalWithSender(msg.sender, _spender, _subtractedValue);
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return erc20Impl.allowance(_owner, _spender);
    }
}

/** @title  KRWT contract
  *
  * @author  Hansung Future Co.,Ltd
  */
contract ERC20Impl is CustodianUpgradeable {

    struct PendingPrint {
        address receiver;
        uint256 value;
    }

    ERC20Proxy public erc20Proxy;

    ERC20Store public erc20Store;

    address public sweeper;

    bytes32 public sweepMsg;

    mapping (address => bool) public sweptSet;

    mapping (bytes32 => PendingPrint) public pendingPrintMap;

    function ERC20Impl(
          address _erc20Proxy,
          address _erc20Store,
          address _custodian,
          address _sweeper
    )
        CustodianUpgradeable(_custodian)
        public
    {
        require(_sweeper != 0);
        erc20Proxy = ERC20Proxy(_erc20Proxy);
        erc20Store = ERC20Store(_erc20Store);

        sweeper = _sweeper;
        sweepMsg = keccak256(address(this), "sweep");
    }

    modifier onlyProxy {
        require(msg.sender == address(erc20Proxy));
        _;
    }
    modifier onlySweeper {
        require(msg.sender == sweeper);
        _;
    }


    function approveWithSender(
        address _sender,
        address _spender,
        uint256 _value
    )
        public
        onlyProxy
        returns (bool success)
    {
        require(_spender != address(0));
        erc20Store.setAllowance(_sender, _spender, _value);
        erc20Proxy.emitApproval(_sender, _spender, _value);
        return true;
    }

    function increaseApprovalWithSender(
        address _sender,
        address _spender,
        uint256 _addedValue
    )
        public
        onlyProxy
        returns (bool success)
    {
        require(_spender != address(0));
        uint256 currentAllowance = erc20Store.allowed(_sender, _spender);
        uint256 newAllowance = currentAllowance + _addedValue;

        require(newAllowance >= currentAllowance);

        erc20Store.setAllowance(_sender, _spender, newAllowance);
        erc20Proxy.emitApproval(_sender, _spender, newAllowance);
        return true;
    }

    function decreaseApprovalWithSender(
        address _sender,
        address _spender,
        uint256 _subtractedValue
    )
        public
        onlyProxy
        returns (bool success)
    {
        require(_spender != address(0));
        uint256 currentAllowance = erc20Store.allowed(_sender, _spender);
        uint256 newAllowance = currentAllowance - _subtractedValue;

        require(newAllowance <= currentAllowance);

        erc20Store.setAllowance(_sender, _spender, newAllowance);
        erc20Proxy.emitApproval(_sender, _spender, newAllowance);
        return true;
    }

    function requestPrint(address _receiver, uint256 _value) public returns (bytes32 lockId) {
        require(_receiver != address(0));

        lockId = generateLockId();

        pendingPrintMap[lockId] = PendingPrint({
            receiver: _receiver,
            value: _value
        });

        emit PrintingLocked(lockId, _receiver, _value);
    }

    function confirmPrint(bytes32 _lockId) public onlyCustodian {
        PendingPrint storage print = pendingPrintMap[_lockId];

        address receiver = print.receiver;
        require (receiver != address(0));
        uint256 value = print.value;

        delete pendingPrintMap[_lockId];

        uint256 supply = erc20Store.totalSupply();
        uint256 newSupply = supply + value;
        if (newSupply >= supply) {
          erc20Store.setTotalSupply(newSupply);
          erc20Store.addBalance(receiver, value);

          emit PrintingConfirmed(_lockId, receiver, value);
          erc20Proxy.emitTransfer(address(0), receiver, value);
        }
    }

    function burn(uint256 _value) public returns (bool success) {
        uint256 balanceOfSender = erc20Store.balances(msg.sender);
        require(_value <= balanceOfSender);

        erc20Store.setBalance(msg.sender, balanceOfSender - _value);
        erc20Store.setTotalSupply(erc20Store.totalSupply() - _value);

        erc20Proxy.emitTransfer(msg.sender, address(0), _value);

        return true;
    }

    function batchTransfer(address[] _tos, uint256[] _values) public returns (bool success) {
        require(_tos.length == _values.length);

        uint256 numTransfers = _tos.length;
        uint256 senderBalance = erc20Store.balances(msg.sender);

        for (uint256 i = 0; i < numTransfers; i++) {
          address to = _tos[i];
          require(to != address(0));
          uint256 v = _values[i];
          require(senderBalance >= v);

          if (msg.sender != to) {
            senderBalance -= v;
            erc20Store.addBalance(to, v);
          }
          erc20Proxy.emitTransfer(msg.sender, to, v);
        }

        erc20Store.setBalance(msg.sender, senderBalance);

        return true;
    }

    function enableSweep(uint8[] _vs, bytes32[] _rs, bytes32[] _ss, address _to) public onlySweeper {
        require(_to != address(0));
        require((_vs.length == _rs.length) && (_vs.length == _ss.length));

        uint256 numSignatures = _vs.length;
        uint256 sweptBalance = 0;

        for (uint256 i=0; i<numSignatures; ++i) {
          address from = ecrecover(sweepMsg, _vs[i], _rs[i], _ss[i]);

          if (from != address(0)) {
            sweptSet[from] = true;

            uint256 fromBalance = erc20Store.balances(from);

            if (fromBalance > 0) {
              sweptBalance += fromBalance;

              erc20Store.setBalance(from, 0);

              erc20Proxy.emitTransfer(from, _to, fromBalance);
            }
          }
        }

        if (sweptBalance > 0) {
          erc20Store.addBalance(_to, sweptBalance);
        }
    }

    function replaySweep(address[] _froms, address _to) public onlySweeper {
        require(_to != address(0));
        uint256 lenFroms = _froms.length;
        uint256 sweptBalance = 0;

        for (uint256 i=0; i<lenFroms; ++i) {
            address from = _froms[i];

            if (sweptSet[from]) {
                uint256 fromBalance = erc20Store.balances(from);

                if (fromBalance > 0) {
                    sweptBalance += fromBalance;

                    erc20Store.setBalance(from, 0);

                    erc20Proxy.emitTransfer(from, _to, fromBalance);
                }
            }
        }

        if (sweptBalance > 0) {
            erc20Store.addBalance(_to, sweptBalance);
        }
    }

    function transferFromWithSender(
        address _sender,
        address _from,
        address _to,
        uint256 _value
    )
        public
        onlyProxy
        returns (bool success)
    {
        require(_to != address(0));

        uint256 balanceOfFrom = erc20Store.balances(_from);
        require(_value <= balanceOfFrom);

        uint256 senderAllowance = erc20Store.allowed(_from, _sender);
        require(_value <= senderAllowance);

        erc20Store.setBalance(_from, balanceOfFrom - _value);
        erc20Store.addBalance(_to, _value);

        erc20Store.setAllowance(_from, _sender, senderAllowance - _value);

        erc20Proxy.emitTransfer(_from, _to, _value);

        return true;
    }

    function transferWithSender(
        address _sender,
        address _to,
        uint256 _value
    )
        public
        onlyProxy
        returns (bool success)
    {
        require(_to != address(0));

        uint256 balanceOfSender = erc20Store.balances(_sender);
        require(_value <= balanceOfSender);

        erc20Store.setBalance(_sender, balanceOfSender - _value);
        erc20Store.addBalance(_to, _value);

        erc20Proxy.emitTransfer(_sender, _to, _value);

        return true;
    }

    function totalSupply() public view returns (uint256) {
        return erc20Store.totalSupply();
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return erc20Store.balances(_owner);
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return erc20Store.allowed(_owner, _spender);
    }

    event PrintingLocked(bytes32 _lockId, address _receiver, uint256 _value);
    event PrintingConfirmed(bytes32 _lockId, address _receiver, uint256 _value);
}


/** @title  KRWT contract
  *
  * @author  Hansung Future Co.,Ltd
  */
contract ERC20Store is ERC20ImplUpgradeable {

    uint256 public totalSupply;

    mapping (address => uint256) public balances;

    mapping (address => mapping (address => uint256)) public allowed;

    function ERC20Store(address _custodian) ERC20ImplUpgradeable(_custodian) public {
        totalSupply = 0;
    }

    function setTotalSupply(
        uint256 _newTotalSupply
    )
        public
        onlyImpl
    {
        totalSupply = _newTotalSupply;
    }

    function setAllowance(
        address _owner,
        address _spender,
        uint256 _value
    )
        public
        onlyImpl
    {
        allowed[_owner][_spender] = _value;
    }

    function setBalance(
        address _owner,
        uint256 _newBalance
    )
        public
        onlyImpl
    {
        balances[_owner] = _newBalance;
    }

    function addBalance(
        address _owner,
        uint256 _balanceIncrease
    )
        public
        onlyImpl
    {
        balances[_owner] = balances[_owner] + _balanceIncrease;
    }
}