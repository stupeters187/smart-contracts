pragma solidity 0.4.11;

contract Coin {
    
    address owner;
    uint public totalSupply;
    
    mapping (address => uint) public balances;
    
    event Transfer(address indexed _to, address indexed _from, uint _value);
    event NewCoinLog(address _to, uint _amount, uint _newSupply);
    
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
      balances[owner] += _supply;
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
        balances[owner] += _amount;
        NewCoinLog(owner, _amount, totalSupply);
        return true;
    }
}