const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:",deployer.address);

    const Election = await ethers.getContractFactory("Main");
    const electionContract = await Election.deploy();
    await electionContract.deployed();

    console.log("Main-Contract-Address: " + electionContract.address);
}

main() 
    .catch((error) => {
        console.error(error);
        process.exitCode = 1;
    })