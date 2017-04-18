contract StuCoin {

  //ERC20 State
  mapping (address => uint256) public balances;
  mapping (address => mapping (address => uint256)) public allowances;
  uint256 public totalSupply;

  //ERC20 Events
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  //Constructor
  function Stucoin(uint256 _initialAmount) {
    balances[msg.sender] = _initialAmount;
    totalSupply = _initialAmount;
  }

  //ERC20 Methods
  function balanceOf(address _address) constant returns (uint256 balance) {
    return balances[_address];
  }

  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowances[_owner][_spender];
  }

  function transfer(address _to, uint256 _value) returns (bool success) {
    if(balances[msg.sender] < _value) throw;
    if(balances[_to] + _value < balances[_to]) throw;
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) returns (bool success) {
    allowances[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function transferFrom(address _owner, address _to, uint256 _value) return (bool success) {
    if(balances[_owner] < _value) throw;
    if(balances[_to] + _value < balances[_to]) throw;
    if(allowances[_owner][msg.sender] < _value) throw;
    balances[_owner] -= _value;
    balances[_to] += _value;
    allowances[_owner][msg.sender] -= _value;
    Transfer(_owner, _to, _value);
    return true;
  }
}