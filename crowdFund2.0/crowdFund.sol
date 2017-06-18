contract CrowdFund {

  address public beneficiary;
  uint256 public goal;
  uint256 public deadline;
  mapping (address => uint256) funders;
  address[] funderAddresses;

  event NewContribution(address indexed _from, uint256 _value);

  function CrowdFund(address _beneficiary, uint256 _goal, uint256 _duration) {
    beneficiary = _beneficiary;
    goal = _goal;
    deadline = now + _duration;  
  }

  function getFunderContribution(address _addr) constant returns (uint) {
    return funders[_addr];
  }

  function getFunderAddress(uint _index) constant returns (address) {
    return funderAddresses[_index];
  }

  function funderAddressLength() constant returns (uint) {
    return funderAddresses.length;
  }

  function contribute() payable {
    if(funders[msg.sender] == 0) funderAddresses.push(msg.sender);
    funders[msg.sender] += msg.value;
    NewContribution(msg.sender, msg.value);
  }

  function payout() {
    if(this.balance >= goal && now > deadline)
      beneficiary.send(this.balance);
  }

  function refund() {
    if(now > deadline && this.balance < goal) {
      msg.sender.send(funders[msg.sender]);
      funders[msg.sender] = 0;
    }
  }

}