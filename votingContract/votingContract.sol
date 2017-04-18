contract VotingContract {

  event voteCast(address voter, string candidate)

  address _admin;

  enum State {unregistered, pending, voted}

  mapping (address => State) _voters;

  mapping (string => uint) _candidateTally;
  string[] _candidates;

  function VotingContract() {
    _admin = msg.sender;
  }

  function addVoter(address voter) {
    if(msg.sender != _admin) { return; }
    _voters[voter] = State.pending;
  }

  function vote(string candidate) {
    if (_voters[msg.sender] != State.pending) {return;}

    uint count = ++(_candidateTally[candidate])
    if(count == 1) {
      _candidates.push(candidate);
    }

    _voters[msg.sender] = State.voted;

    voteCast(msg.sender, candidate, count);
  }

  function getStatus() constant returns (address admin, uint candidateCount) {
    return (_admin, _candidates.length);
  }

  function getVoterStatus() returns constant (State state) {
    return _voters[voter];
  }

  function getCandiate(uint index) constant returns (string candidate, uint tally) {
    candidate = _candidates[index];
    return (candidate, _candidateTally[candidate]);
  }

}