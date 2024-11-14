// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;
import "./Tokens.sol";

contract Voting {
    string public name;
    string public description;

    //Creating the structure for each candidate that is standing in the election.
    struct Candidate{
        uint256 id;
        string name;
        uint8 age;
        string nationality;
    }

    struct Voter {
        uint256 votedFor; // storing who the voter voted for.
        bool hasVoted; // storing whether the voter has voted or not.
        uint256 delegateTokens; // storing the tokens that the voter has got from someone else (After delegation).
        bool transferVotingPower; // storing whether the voter has delegated to someone else.
        address delegateAddress; // storing the address of the person to whom the voter has delegated.
    }

    mapping(uint256 => Candidate) public candidates; //Creating an map between id and candidates standing in the election.
    mapping(uint256 => uint256) private voteCounts; //Vote counts of candidates.
    mapping(address=>Voter) private voters; // Making sure that the same person can't vote twice, if they have delegated or not etc.
    address[] public allVoters; // Array of all voters (who ever voted in these elections (Along with their delegates))
    uint256 public id = 0;
    address owner; // Owner of the smart contract (likely the deployer or administrator).

    uint256 StartTime;
    uint256 EndTime;

    Tokens tokens;

    constructor(string memory _name, string memory _description, uint256 _endTime) {
        owner = msg.sender;
        name = _name;
        description = _description;
        StartTime = block.timestamp;
        EndTime = _endTime;
        tokens = new Tokens(address(this)); // initializing the tokens contract. _token is the address of the tokens contract.
    }

    modifier onlyOwner{ //modifier to call in the other functions.
        require(msg.sender == owner); //Only the owner can call this function
        _;
    }


    // Function to add a candidate into the elections
    // We will just provide the name, because vote-count is anwyays set to 0.
    function addCandidate(string memory _name, uint8 _age, string memory _nationality) public onlyOwner { //only the administration, can add candidates.
        candidates[id] = Candidate({
                id: id,
                name: _name,
                age: _age,
                nationality: _nationality
        });
        id += 1;
    }

    function tokenBalance(address _msg_sender) public view returns(uint256) { // view is used, when we do not change the values of the variables used in the contract (state of the contact).
        return tokens.balanceOf(_msg_sender);
    }

    // Function that will enable the voters to vote.
    // The voter will have to provide the index of the candidate they want to vote for.
    function vote(uint256 _candidateIndex, address _msg_sender) public { //anyone can vote, therefore we are not going to put OnlyOwner

        // Check if the voter has already voted
        require(!voters[_msg_sender].hasVoted, "You have already voted.");
        // Making sure that the right/valid candidate is selected.
        require(_candidateIndex < id, "Invalid candidate index.");
        // If time exceeds they shouldn't vote.
        require(block.timestamp >= StartTime && block.timestamp < EndTime, "Voting has not started yet or voting ended.");
        // If the voter has a delegate or not
        require(!voters[_msg_sender].transferVotingPower, "Voter has a delegate.");


        allVoters.push(_msg_sender);
        voters[_msg_sender].votedFor = _candidateIndex;
        voters[_msg_sender].hasVoted = true;
    }
    
    function mintTokens(address _address, uint256 _amount) public onlyOwner { // election-committee head will 'mint'/tansfer tokens to the voters.
        tokens.mint(_address,_amount);
    }
    
    // Function to show the current election standings
    // Allows anyone to view all candidates.
    function getAllCandidates() public view returns (Candidate[] memory){ //public view function, so that it can be called from outside the contract.
        Candidate[] memory allCandidates = new Candidate[](id);
        for(uint256 i=0; i<id;i++) {
            allCandidates[i] = candidates[i];
        }
        return allCandidates;
    }
    

    // Function to return all the votes for all the candidate. (releasing the result of the election)
    function getAllVotesOfCandidates() public view returns(uint256[] memory) {
        // require(block.timestamp > EndTime, "Voting has not yet ended.");
        uint256[] memory allVotes = new uint256[](id);
        for(uint256 i=0;i<id;i++) {
            allVotes[i] = voteCounts[i];
        }

        return allVotes;
    }


    // Function to find, how much votes were given to a particular candidate.
    // Computing all the votes in one function, rather than individually saves gas and also ensures efficient counting of votes.
    function evaluateAllVotes() public onlyOwner {
        uint256[] memory votes = new uint[](id);
        for(uint256 i=0;i<allVoters.length;i++) {
            if(voters[allVoters[i]].transferVotingPower == false){ //esnure that the vote is only counted for a person who has no delegates.
                votes[voters[allVoters[i]].votedFor] += (tokens.balanceOf(allVoters[i]) + voters[allVoters[i]].delegateTokens + 1)*(tokens.balanceOf(allVoters[i]) + voters[allVoters[i]].delegateTokens + 1); 
                // how many tokens the voter has + 1 (adding 1 to ensure the number of votes is not zero) and doubling it, for exponential voting.
            }
        }
        
        for(uint256 i=0;i<id;i++) {
            voteCounts[i] = votes[i];
        }
    }


    // Function to allow a particular voter to choose their delegate.
    function chooseDelegate(address _address, address _msg_sender) public {
        require(voters[_address].transferVotingPower == false && voters[_msg_sender].transferVotingPower == false, "User already has a delegate.");
        require(_address != _msg_sender, "can't be a delegate for yourself.");
        // the person transferring the voting power, and the person recieving it, both must not have a delegate.
        voters[_msg_sender].transferVotingPower = true;
        voters[_msg_sender].delegateAddress = _address;

        voters[_address].delegateTokens += tokens.balanceOf(_msg_sender) + voters[_msg_sender].delegateTokens;

        allVoters.push(_msg_sender);
    }

    // Function to end election.
    function endElection() public onlyOwner {
        EndTime = block.timestamp;
    }
}