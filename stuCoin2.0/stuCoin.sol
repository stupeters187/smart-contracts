contract StuCoin {

  //ERC20 State
  mapping (address => uint256) public balances;
  mapping (address => mapping (address => uint256)) public allowances;
  uint256 public totalSupply;

  //Human State
  string public name;
  uint8 public decimals;
  string public symbol;
  string public version;

  //Minter State
  address public centralMinter;

  //Backed by Ether State
  uint256 public buyPrice;
  uint256 public sellPrice;

  //Modifiers
  modifier onlyMinter {
    if(msg.sender != centralMinter) throw;
    _;
  }

  //ERC20 Events
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  //Constructor
  function Stucoin(uint256 _initialAmount) {
    balances[msg.sender] = _initialAmount;
    totalSupply = _initialAmount;
    name = "StuCoin";
    decimals = 18;
    symbol = "STU";
    version = "0.1";
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

  function mint (uint256 _mintAmount) onlyMinter {
    balances[centralMinter] += _mintAmount;
    totalSupply += _mintAmount;
    Transfer(this, centralMinter, _mintAmount);
  }

  function transferMinter(address _newMinter) onlyMinter {
    centralMinter = _newMinter;
  }

  //Backed by Ether Methods
  //Must create the contract so that it has enough Ether to buy back ALL of the tokens on the market, or else the contract will be insolvent

  function setPrice(uint256 _newSellPrice, uint256 _newBuyPrice) onlyMinter {
    sellPrice = _newSellPrice;
    buyPrice = _newBuyPrice;
  }

  function buy() payable returns (uint256 amount) {
    amount = msg.value / buyPrice;
    if(balances[centralMinter] < amount) throw;       // Validate that enough tokens are available for purchase
    balances[centralMinter] -= amount;
    balances[msg.sender] += amount;
    Transfer(centralMinter, msg.sender, amount);
    return amount;
  }

  function sell(uint _amount) returns (uint revenue) {
    if(balances[msg.sender] < _amount) throw;         // Validate that sender has enough tokens to sell
    balances[centralMinter] += _amount;
    balances[msg.sender] -= _amount;
    revenue = _amount * sellPrice;
    if(!msg.sender.send(revenue)) {
      throw;
    } else {
      Transfer(msg.sender, centralMinter,_amount);
      return revenue;
    }
  }
}





















