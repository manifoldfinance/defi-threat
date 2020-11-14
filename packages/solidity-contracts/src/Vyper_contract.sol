# @title Vyper loveregister contract
# @author Kevin Foesenek

#Struct
struct register: 
    owner1: address
    owner1_name: string[120]
    owner2: address
    owner2_name: string[120]
    message: string[280]
    private_message: string[280]
    alive: bool

# Events
Register: event({_from: indexed(address), _to: indexed(address), identifier: bytes32})
Search: event({Owner: indexed(address), _Identifier: bytes32})

# Variables contract owner
owner1: public(address)
owner2: public(address)
payment_address: public(address)
price: public(wei_value)

# Variables ERC20 
name: public(string[64])
register_entries: public(map(bytes32, register))
register_totalEntries: public(uint256)
register_publicmessage: public(map(uint256, string[280]))
register_identifier: map(address, bytes32)

# Constructor
@public
def __init__(_name: string[64], _price: wei_value):
        self.name = _name
        self.owner1 = msg.sender
        self.price = _price
        self.payment_address = msg.sender

# Function to set second owner
@public
def setsecondowner(newowner: address):
    assert self.owner1 == msg.sender or self.owner2 == msg.sender
    self.owner2 = newowner
        
# Function to set price
@public
def setprice(newprice: wei_value):
    assert self.owner1 == msg.sender or self.owner2 == msg.sender
    self.price = newprice

# Function to change payment address
@public
def changepaymentaddress(newaddress: address):
    assert self.owner1 == msg.sender or self.owner2 == msg.sender
    self.payment_address = newaddress

# Function to send amount of ETH to owner determined address
@public
def clear_valuecontract():
    assert self.owner1 == msg.sender or self.owner2 == msg.sender
    receiver: address = self.payment_address
    amount: wei_value = self.balance
    send(receiver, amount)
    
# Function to register
@public
@payable
def newRegister(_from: address, _fromName: string[120], _for: address, _forName: string[120], message: string[280], privatenote: string[280]):
    index_entries: uint256 = self.register_totalEntries
    
    hash_index_entries: bytes32 = sha3(convert(index_entries, bytes32))
    
    assert _from != ZERO_ADDRESS
    assert _for != ZERO_ADDRESS
    assert msg.value >= self.price
    self.register_entries[hash_index_entries] = register({owner1: _from, owner1_name: _fromName, owner2: _for, owner2_name: _forName, 
    message: message, private_message: privatenote, alive: True})
    
    self.register_publicmessage[index_entries] = message
    self.register_identifier[_from] = hash_index_entries
    
    index_entries += 1
    self.register_totalEntries = index_entries
    log.Register(_from, _for, hash_index_entries)
    
# Function to deregister -> note it only closes the entry - removal is not possible
@public
def deRegister(register_entry: bytes32):
    assert self.register_entries[register_entry].owner1 == msg.sender or self.register_entries[register_entry].owner2 == msg.sender
    self.register_entries[register_entry].alive = False

#Function to find the identifier for a relationship 
@public
def findIdentifier():
    log.Search(msg.sender, self.register_identifier[msg.sender])