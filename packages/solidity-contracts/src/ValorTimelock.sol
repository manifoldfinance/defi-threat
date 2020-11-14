/**
 * Source Code first verified at https://etherscan.io on Tuesday, April 16, 2019
 (UTC) */

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}







/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


/**
 * @title ValorTimelock
 * @dev ValorTimelock is a VALOR token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time and includes an
 * emergency exit mechanism which can be activated by owner (Smart Valor) to immediately
 * recover funds towards beneficiary
 */
contract ValorTimelock{


    event EmergencyRelease(
        address from,
        address to,
        uint256 value
    );

    // ERC20 basic token contract being held
    ERC20 public token;

    // beneficiary of tokens after they are released
    address public beneficiary;

    // timestamp when token release is enabled
    uint256 public releaseTime;

    //admin address
    address public owner;

    /**
     * @dev the duration arg is the number of seconds the fund is locked since creation
     * @param _token the token managed by this contract
     * @param _beneficiary the address which will receive the locked funds at due time
     * @param _admin the account which can activate the emergency release
     * @param _duration locking period in secs
     */
    constructor(ERC20 _token, address _beneficiary, address _admin, uint256 _duration )
    public {
        token = _token;
        beneficiary = _beneficiary;
        releaseTime = block.timestamp + _duration;//watchout, no safe math
        owner = _admin;
    }


    /**
    * @dev it releases all tokens held by this contract to beneficiary.
    */
    function release() external {
        uint256 balance = token.balanceOf(address(this));
        partialRelease(balance);
    }

    /**
    * @dev it releases some tokens held by this contract to beneficiary.
    * @param _amount the number of tokens to be sent to beneficiary
    */
    function partialRelease(uint256 _amount) public {

        //check time is done
        //according to 15sec rule, this contract can tolerate a drift of 15sec
        //so that the use of block.timestamp can be considered safe
        require(block.timestamp >= releaseTime);

        uint256 balance = token.balanceOf(address(this));
        require(balance >= _amount);
        require(_amount > 0);

        require(token.transfer(beneficiary, _amount));
    }


    /**
    * @dev it releases all tokens held by this contract to beneficiary. This
    * can be used by owner only and it works anytime
    */
    function emergencyRelease() external{
        require(msg.sender == owner);
        uint256 amount = token.balanceOf(address(this));
        require(amount > 0);
        require(token.transfer(beneficiary, amount));
        emit EmergencyRelease(msg.sender, beneficiary, amount);
    }

}