contract Escrow {

  address public buyer;
  address public seller;
  address public arbiter;

  function Escrow(address _seller, address _arbiter) {
    buyer = msg.sender;
    seller = _seller;
    arbiter = _arbiter;

  }

  function payoutToSeller() {
    if(msg.sender == buyer || msg.sender == arbiter) {
      seller.transfer(this.balance);  
    } 
  }

  function refundToBuyer() {
    if(msg.sender == seller || msg.sender == arbiter) {
      buyer.transfer(this.balance);
    } 
  }

  function fund() payable returns (bool) {
    return true;
  }

  function getBalance() constant returns (uint) {
    return this.balance;
  }

}