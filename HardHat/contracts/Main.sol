// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;
import "./Voting.sol";

contract Main {
    mapping(uint256 => Voting) public elections;
    address owner; // Owner of the smart contract (likely the deployer or administrator).
    uint256 public id = 0;

    struct Election {
        uint256 id;
        string name;
        string description;
    }

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner{ //modifier to call in the other functions.
        require(msg.sender == owner); //Only the owner can call this function
        _;
    }

    function createElection(string memory name, string memory description, uint256 endTime) public onlyOwner {
        Voting election = new Voting(name,description,endTime);

        elections[id] = election;
        id++;
    }

    function getElections() public view returns (Election[] memory) {
        Election[] memory election = new Election[](id);
        for(uint256 i=0;i<id;i++) {
            Voting ele = Voting(elections[i]);
            election[i] = Election({
                id: i,
                name: ele.name(),
                description: ele.description()
            });
        }

        return election;
    }

    function addCandidate(uint256 _id, string memory _name, uint8 _age, string memory _nationality) public onlyOwner() {
        Voting election = Voting(elections[_id]);
        election.addCandidate(_name,_age,_nationality);
    }

    function tokenBalance(uint256 _id) public view returns(uint256) {
        Voting election = Voting(elections[_id]);
        return election.tokenBalance(msg.sender);
    }

    function vote(uint256 _id, uint256 _candidateId) public {
        Voting election = Voting(elections[_id]);
        election.vote(_candidateId, msg.sender);
    }

    function mintTokens(uint256 _id, address _address, uint256 _amount) public onlyOwner {
        Voting election = Voting(elections[_id]);
        election.mintTokens(_address, _amount);
    }

    function getAllCandidates(uint256 _id) public view returns(Voting.Candidate[] memory){
        Voting election = Voting(elections[_id]);
        return election.getAllCandidates();
    }

    function getAllVotesOfCandidates(uint256 _id) public view returns(uint256[] memory) {
        Voting election = Voting(elections[_id]);
        return election.getAllVotesOfCandidates();
    }

    function evaluateAllVotes(uint256 _id) public onlyOwner {
        Voting election = Voting(elections[_id]);
        return election.evaluateAllVotes();
    }

    function chooseDelegate(uint256 _id, address _delegate_address) public {
        Voting election = Voting(elections[_id]);
        return election.chooseDelegate(_delegate_address, msg.sender);
    }

    function endElection(uint256 _id) public onlyOwner {
        Voting election = Voting(elections[_id]);
        return election.endElection();
    }
}