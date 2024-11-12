// SPDX-License-Identifier : MIT

pragma solidity ^0.8.0;

contract Voting {
    //Creating the structure for each candidate that is standing in the election.
    struct Candidate{
        string name;
        uint256 voteCount;
    }

    Candidate[] public candidates; //Creating an array of candidates standing in the election.
    address owner; // Owner of the smart contract (likely the deployer or administrator).
    mapping(address=>bool) public voters; // Making sure that the same person can't vote twice.

    uint256 StartTime;
    uint256 EndTime;

    constructor(string[] memory _candidateNames, uint256 _durationofelection) {
        for(uint256 i=0; i<_candidateNames.length; i++){
            candidates.push(Candidate({
                    name : _candidateNames[i], 
                    voteCount : 0
                }));
        }
        owner = msg.sender;
        StartTime = block.timestamp;
        EndTime = block.timestamp + (_durationofelection * 1 minutes);
    }

    modifier onlyOwner{
        require(msg.sender == owner); //Only the owner can call this function
        _;
    }


    // Function to add a candidate into the elections
    // We will just provide the name, because vote-count is anwyays set to 0.
    function addCandidate(string memory _name) public onlyOwner { //only the administration, can add candidates.
        candidates.push(Candidate({
                name: _name,
                voteCount: 0
        }));
    }

    // Function that will enable the voters to vote.
    // The voter will have to provide the index of the candidate they want to vote for.
    function vote(uint256 _candidateIndex) public { //anyone can vote, therefore we are not going to put OnlyOwner

        // Check if the voter has already voted
        require(!voters[msg.sender], "You have already voted.");
        // Making sure that the right/valid candidate is selected.
        require(_candidateIndex < candidates.length, "Invalid candidate index.");

        // Increase the vote count by one, and then making sure that the voter can't vote again.
        candidates[_candidateIndex].voteCount++;
        voters[msg.sender] = true;
    }
    
    // Function to show the current election standings
    // Allows anyone to view all candidates and their corresponding vote counts.
    function getAllVotesOfCandiates() public view returns (Candidate[] memory){ //public view function, so that it can be called from outside the contract.
        return candidates;
    }


    //Function to check if the voting status is currently active or not.
    function getVotingStatus() public view returns (bool) {
        return (block.timestamp >= StartTime && block.timestamp < EndTime);
    }


    //Function to return how much time is left in the election.
    function getRemainingTime() public view returns (uint256) {
        // Ensuring that the function cannot be called until the voting has started.
        require(block.timestamp >= StartTime, "Voting has not started yet.");
        if (block.timestamp >= EndTime) {
            return 0;
        }
        return EndTime - block.timestamp;
    }
}