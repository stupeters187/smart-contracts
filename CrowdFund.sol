pragma solidity 0.4.11;

contract CrowdFund {
    
    address public beneficiary;
    uint public goal;
    uint public deadline;
    
    mapping (address => uint) funders;
    
    address[] totalFundersArr;
    
    function CrowdFund(address _beneficiary, uint _goal, uint _duration){
        beneficiary = _beneficiary;
        goal = _goal;
        deadline  = now + _duration;
    }
    
    function totalFunders() constant returns (uint){
        return totalFundersArr.length;
    }
    
    function contribute() payable {
        if(funders[msg.sender] == 0) totalFundersArr.push(msg.sender);
        funders[msg.sender] += msg.value;
    }
    
    function payout(){
        if(now > deadline && this.balance >= goal)
            beneficiary.transfer(this.balance);
    }
    
    function refund(){
        if(now > deadline && this.balance < goal){
            msg.sender.transfer(funders[msg.sender]);
            funders[msg.sender] = 0;
        }
    }
}