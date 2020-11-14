/**
 * Source Code first verified at https://etherscan.io on Sunday, March 24, 2019
 (UTC) */

pragma solidity >=0.4.22 <0.6.0;

interface tokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external;
}

contract DarchNetwork {
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address payable public fundsWallet;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burn(address indexed from, uint256 value);


    constructor(
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) public {
        initialSupply = 1000000000;
        tokenName = "Darch Network";
        tokenSymbol = "DARCH";
        fundsWallet = msg.sender;
        totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        balanceOf[msg.sender] = totalSupply;                // Give the creator all initial tokens
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes

    }


    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != address(0x0));
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }


    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }


    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }


    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        emit Burn(_from, _value);
        return true;
    }




    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
    uint private productId;
    function getProductID() private returns (uint256) {
    return productId++;
    }

    uint private requestID;
    function getRequestID() private returns (uint256) {
    return requestID++;
    }


    struct productDetails {
      uint time;
      string headline;
      string explain;
      string imagelist;
      string showdemo;
      string category;
      address senderaddress;
      uint256 pid;
      uint256 price;
    }

    mapping (string => productDetails) newProduct;
    string[] public listofproducts;

    function SharenewProduct(string memory uHeadline, string memory uExplain, string memory uImageList, string memory uShowDemo,string memory uCate, uint uPrice, string memory pname) public {

        uint256 newpid = getProductID();
        newProduct[pname].time = now;
        newProduct[pname].senderaddress = msg.sender;
        newProduct[pname].headline = uHeadline;
        newProduct[pname].explain = uExplain;
        newProduct[pname].imagelist = uImageList;
        newProduct[pname].showdemo = uShowDemo;
        newProduct[pname].category = uCate;
        newProduct[pname].pid = newpid;
        newProduct[pname].price = uPrice;
        listofproducts.push(pname) -1;
    }





    function numberofProduct() view public returns (uint) {
      return listofproducts.length;
    }

    function getpnamefromid(uint _pid) view public returns (string memory){
        return listofproducts[_pid];
    }


    function getProductFromName(string memory pname) view public returns (string memory, string memory,string memory, string memory, string memory, string memory, string memory) {

        if(newProduct[pname].time == 0){
            return ("0", "0", "0","0","0","0","0");
        } else {
        return (uint2str(newProduct[pname].time), uint2str(newProduct[pname].price), newProduct[pname].headline, newProduct[pname].explain, newProduct[pname].imagelist, newProduct[pname].showdemo, newProduct[pname].category);
        }
    }


    function checkProductExist(string memory pname) view public returns (bool) {

        if(newProduct[pname].time == 0){
            return false;
        } else {
            return true;
        }
    }





  struct Requesters {
      bool exists;
      uint256 ptime;
      string publicKey;
      address rqaddress;
  }

  mapping(string => Requesters[]) rlist;
  mapping (string => bool) public RWlist;
  string[] public listofrequests;

 function checkWalletexist(string memory _wallet) view public returns (bool){
        return RWlist[_wallet];
 }


  function setNewRequest(string memory pname, string memory pubkey) public returns (uint)  {
      bool checkProduct = checkProductExist(pname);
      if(checkProduct){
          string memory wid = appendString(WallettoString(msg.sender),pname);

          bool cwallet = checkWalletexist(wid);

          if(cwallet){
              revert();
          } else {
            if(balanceOf[msg.sender] >= newProduct[pname].price) {
              transfer(fundsWallet, newProduct[pname].price);
              RWlist[wid]=true;
              rlist[pname].push(Requesters(true,now, pubkey, msg.sender));
              listofproducts.push(wid) -1;
              return rlist[pname].length - 1;
            } else {
                revert();
            }

          }
      } else {
          revert();
      }

  }



    function num_of_request() view public returns (uint) {
      return listofproducts.length;
    }

    function get_product_from_pid(uint _listid) view public returns (string memory){
        return listofproducts[_listid];
    }


   function num_of_product_requests(string memory key) public view returns (uint) {
    return rlist[key].length;
  }

  function get_public_key(string memory key, uint index) public view returns (string memory) {
    if (rlist[key][index].exists == false) {
      assert(false);
    }
    return rlist[key][index].publicKey;
  }


   struct TransmitProduct {
      bool exists;
      bool status;
      uint256 ptime;
      string signedMessage;
      address forwho;
  }

  mapping(string => TransmitProduct[]) responseList;
  mapping (string => bool) public BWlist;
  string[] public listoftransmits;


  function checkBWalletexist(string memory _walletandid) view public returns (bool){
        return BWlist[_walletandid];
  }

  function WallettoString(address x) public returns(string memory) {
    bytes memory b = new bytes(20);
    for (uint i = 0; i < 20; i++)
        b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));
    return string(b);
 }

 function appendString(string memory a, string memory b) internal pure returns (string memory) {
    return string(abi.encodePacked(a, b));
}



   function setTransmitProduct(string memory pname, uint index, string memory smessage) payable public  {
      bool checkProduct = checkProductExist(pname);
      if(checkProduct){
          address radress = rlist[pname][index].rqaddress;
          string memory wid = appendString(WallettoString(radress),pname);
          bool cwallet = checkBWalletexist(wid);

          if(cwallet){
              //Buraya geliyorsa daha önce zaten göndermiş demektir.
              revert();
          } else {

              if(msg.sender == newProduct[pname].senderaddress){

                require(balanceOf[fundsWallet] >= newProduct[pname].price);
                _transfer(fundsWallet, msg.sender, newProduct[pname].price);

                BWlist[wid]=true;
                //Sadece alıcının çözüleceği şekilde istek şifrelenerek blockchaine yükleniyor.
                responseList[pname].push(TransmitProduct(true, true, now, smessage, radress));
                listoftransmits.push(wid) -1;
              } else {
                  revert();
              }
          }
      } else {
          revert();
      }

  }



  function cancelTransmitProduct(string memory pname, uint index) public  {
      bool checkProduct = checkProductExist(pname);
      if(checkProduct){
          address radress = rlist[pname][index].rqaddress;
          string memory wid = appendString(WallettoString(radress),pname);
          bool cwallet = checkBWalletexist(wid);


          if(cwallet){
              //Buraya geliyorsa daha önce zaten göndermiş demektir.
              revert();
          } else {
              //Eğer önceden gönderim yapılmamışsa burası çalışır.
              //rqaddress
              if(msg.sender == rlist[pname][index].rqaddress){
                //Sadece o ürüne istek gönderen kişi iptal edebilir.

                //coin kontrattan iptal edene iletiliyor.

                 require(balanceOf[fundsWallet] >= newProduct[pname].price);

                _transfer(fundsWallet,msg.sender,newProduct[pname].price);


                BWlist[wid]=true;
                //status false olması ürünün iptal edildiği anlamına geliyor.
                //Gönderici parasını alıyor ve ürün
                responseList[pname].push(TransmitProduct(true, false, now, "canceled", radress));
                listoftransmits.push(wid) -1;
              } else {
                  revert();
              }
          }
      } else {
          revert();
      }

  }


    function num_of_transmit() view public returns (uint) {
      return listoftransmits.length;
    }

    function get_transmits_from_pid(uint _listid) view public returns (string memory){
        return listoftransmits[_listid];
    }

  function num_of_product_transmit(string memory _pid) public view returns (uint) {
    return responseList[_pid].length;
  }

  function getTransmits(string memory _pid, uint index) public view returns (address) {
    if (responseList[_pid][index].exists == false) {
      assert(false);
    }
    return rlist[_pid][index].rqaddress;
  }



    function() payable external{
      uint256 yirmimart = 1553040000;
      uint256 onnisan = 1554854400;
      uint256 birmayis = 1556668800;
      uint256 yirmimayis = 1558310400;
      uint256 onhaziran = 1560124800;

      if(yirmimart > now) {
        require(balanceOf[fundsWallet] >= msg.value * 100);
        _transfer(fundsWallet, msg.sender, msg.value * 100);
        fundsWallet.transfer(msg.value);
      } else if(yirmimart < now && onnisan > now) {
        require(balanceOf[fundsWallet] >= msg.value * 15000);
        _transfer(fundsWallet, msg.sender, msg.value * 15000);
        fundsWallet.transfer(msg.value);
      } else if(onnisan < now && birmayis > now) {
        require(balanceOf[fundsWallet] >= msg.value * 12000);
        _transfer(fundsWallet, msg.sender, msg.value * 12000);
        fundsWallet.transfer(msg.value);
      }else if(birmayis < now && yirmimayis > now) {
        require(balanceOf[fundsWallet] >= msg.value * 10000);
        _transfer(fundsWallet, msg.sender, msg.value * 10000);
        fundsWallet.transfer(msg.value);
      }else if(yirmimayis < now && onhaziran > now) {
        require(balanceOf[fundsWallet] >= msg.value * 7500);
        _transfer(fundsWallet, msg.sender, msg.value * 7500);
        fundsWallet.transfer(msg.value);
      } else {
        assert(false);
      }

    }

}