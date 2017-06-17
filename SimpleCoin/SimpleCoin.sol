pragma solidity 0.4.11;

contract Coin {
    
    address owner;
    uint public totalSupply;
    
    mapping (address => uint) public balances;
    
    event Transfer(address indexed _to, address indexed _from, uint _value);
    
    modifier onlyOwner(){
        if(msg.sender != owner) {
            throw;
        } else {
            _;
        }
    }
    
    function Coin(uint _supply) {
      owner = msg.sender;
      totalSupply = _supply;
    }
    
    function getBalance(address _addr) constant returns (uint){
        return balances[_addr];
    }
    
    function transfer(address _to, uint _amount) returns (bool) {
        if(balances[msg.sender] < _amount) throw;
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        Transfer(_to, msg.sender, _amount);
        return true;
    }
    
    function mint(uint _amount) onlyOwner returns (bool){
        totalSupply += _amount;
        return true;
    }
}