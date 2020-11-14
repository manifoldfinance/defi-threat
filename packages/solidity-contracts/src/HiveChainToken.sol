/**
 * Source Code first verified at https://etherscan.io on Tuesday, May 7, 2019
 (UTC) */

pragma solidity ^0.4.20;

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require (msg.sender == owner) ;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public{
        owner = newOwner;
    }
}




/// @title Hive Chain Coin (HIVE)
contract HiveChainToken is owned {
    // Public variables of the token
    string public constant standard = "ERC20";
    string public constant name = "Hive Chain Coin";  
    string public constant symbol = "HIVE";
    uint8  public constant decimals =18;
    uint256 public constant totalSupply=3000000000*10 ** uint256(decimals);
    uint public allcatedTime = 0;
 
    address  public constant teamAddress = 0x95EEe45FFef756D8bfce8D8Ad1617c331A6d0CbB;
                                            
    
    address  public constant counselorAddress = 0x067AA439831C0E6070Aaf0Ba2c6c6EC4bb4c9D09;
    
    address  public constant footstoneAddress = 0xe1461098D05c8d30aACb8Db6E3c10F9aCE80319A;

    // This creates an array with all balanceOf 
    mapping (address => uint256) public balanceOf;
 
   
    // These are related to HC team members
    mapping (address => bool) public frozenAccount;
 
		// This creates an array with all lockedTokens 
    mapping (address => frozenTeam[]) public lockedTokens;
    
    
   
		// Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    struct frozenTeam{       
        uint256 time;
        uint256 token;    
    }

    // Constructor 
    function HiveChainToken()  public
    {
       
        balanceOf[0x065cCc2Ed012925f428643df16AA9395a1e5c664] = totalSupply*116/300; 
        
        balanceOf[msg.sender]=totalSupply/3;
        
        //team
        
        balanceOf[teamAddress] = totalSupply*15/100; // 15% 
            
        allcatedTime=now;
        
        frozenAccount[teamAddress]=true;
         for (uint i = 0; i < 19; i++) {
             uint256 temp0=balanceOf[teamAddress]*(i+1)*5/100;
             lockedTokens[teamAddress].push(frozenTeam({
                 time:allcatedTime + 3*(i+1) * 30 days ,
                 token:balanceOf[teamAddress]-temp0
             }));
            
         }
        
        
       balanceOf[counselorAddress] = totalSupply*3/100; // 3% 
       
       frozenAccount[counselorAddress]=true;
            for (uint j = 0; j < 5; j++){
                 uint256 temp;
                 if(j==0){
                     temp=balanceOf[counselorAddress]*80/100;
                 }else if(j==1){
                     temp=balanceOf[counselorAddress]*65/100;
                 }else if(j==2){
                     temp=balanceOf[counselorAddress]*50/100;
                 }else if(j==3){
                     temp=balanceOf[counselorAddress]*30/100;
                 }else if(j==4){
                      temp=balanceOf[counselorAddress]*15/100;
                 }
                 lockedTokens[counselorAddress].push(frozenTeam({
                 time:allcatedTime + (j+1) * 30 days ,
                 token:temp
             }));
            }
        
       
        
        balanceOf[footstoneAddress] = totalSupply*10/100; // 10% 
      
       
       frozenAccount[footstoneAddress]=true;
            for (uint k = 0; k < 5; k++){
                 uint256 temp1;
                   if(k==0){
                     temp1=balanceOf[footstoneAddress]*80/100;
                 }else if(k==1){
                     temp1=balanceOf[footstoneAddress]*65/100;
                 }else if(k==2){
                     temp1=balanceOf[footstoneAddress]*50/100;
                 }else if(k==3){
                     temp1=balanceOf[footstoneAddress]*30/100;
                 }else if(k==4){
                      temp1=balanceOf[footstoneAddress]*15/100;
                 }
                 lockedTokens[footstoneAddress].push(frozenTeam({
                 time:allcatedTime + (k+1) * 30 days ,
                 token:temp1
             }));
            }
        
                            
    }
  


    // Transfer the balance from owner"s account to another account
    function transfer(address _to, uint256 _amount) public
        returns (bool success) 
    {
  
        if (_amount <= 0) return false;
      
        if (frozenRules(msg.sender, _amount)) return false;

        if (balanceOf[msg.sender] >= _amount
            && balanceOf[_to] + _amount > balanceOf[_to]) {

            balanceOf[msg.sender] -= _amount;
            balanceOf[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }     
    }
 


    /// @dev Token frozen rules for token holders.
    /// @param _from The token sender.
    /// @param _value The token amount.
    function frozenRules(address _from, uint256 _value) 
        internal 
        returns (bool success) 
    {
        if (frozenAccount[_from]) {
            
            frozenTeam[] storage lockedInfo=lockedTokens[_from];
            for(uint256 i=0;i<lockedInfo.length;i++){
                if (now <lockedInfo[i].time) {
                   // 100% locked within the first 6 months.
                        if (balanceOf[_from] - _value < lockedInfo[i].token)
                            return true;  
                 }else if (now >=lockedInfo[i].time && now < lockedInfo[i+1].time) {
                     // 20% unlocked after 6 months.
                        if (balanceOf[_from] - _value <lockedInfo[i+1].token) 
                            return true;  
                 }else if(now>=lockedInfo[lockedInfo.length-1].time){
                      frozenAccount[_from] = false; 
                      return false;
                 }
            }
            
        }
        return false;
    }   
}