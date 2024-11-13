require('dotenv').config();
const express = require('express');
const app = express();
const fileUpload = require('express-fileupload');

app.use(
    fileUpload({
        extended:true
    })
)

app.use(express.static(__dirname)); //allowing front end js files, to access backend js files.
app.use(express.json());
const path = require("path");
const ethers = require('ethers');

var port = 8080; //setting the backend port to be PORT 8080.


// Getting the required information from the .env file.
const API_URL = process.env.API_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS;

// Creating the Application Binary Instance (ABI) of our contract.
// This defines how our application interacts with the smart contract.
const {abi} = require('./artifacts/contracts/Voting.sol/Voting.json');



// USING THE ETHER.JS LIBRARY OBJECTS.

// Creating a provide that is helping us to connect to the Ethereum network.
const provider = new ethers.providers.JsonRpcProvider(API_URL);

// Creating a wallet object, that helps us sign/create transactions.
const signer = new ethers.Wallet(PRIVATE_KEY, provider);

//Creating an instance of our HardHat Contract, that helps to connect with the deployed contract.
const contractInstance = new ethers.Contract(CONTRACT_ADDRESS, abi, signer);


// Getting our HTML file.

// From the root route
app.get("/", (req, res) => {
    res.sendFile(path.join(__dirname, "index.html"));
})

// From the /index.html route
app.get("/index.html", (req, res) => {
    res.sendFile(path.join(__dirname, "index.html"));
})


// Handling the POST REQUEST to cast a vote, or register a candidate.
app.post("/vote", async (req, res) => {
    var vote = req.body.vote;
    console.log(vote)
    async function storeDataInBlockchain(vote) {
        console.log("Adding the candidate in voting contract...");
        const tx = await contractInstance.addCandidate(vote);
        await tx.wait();
    }
    const bool = await contractInstance.getVotingStatus();
    if (bool == true) {
        await storeDataInBlockchain(vote);
        res.send("The candidate has been registered in the smart contract");
    }
    else {
        res.send("Voting is finished");
    }
});

// Printing the server that we are going to work on.
app.listen(port, function () {
    console.log("App is listening on port 3000")
});