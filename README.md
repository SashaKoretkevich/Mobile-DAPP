# Mobile-DAPP-try

Greetings all! In this repository, we will look how you can have your own Device managing system. In the later part of the text, we will tell you about all the prerequisites to run this application. Our task is divided into three parts:

1. IoT device setup:

a. Writing code on raspberry pi 3

b. Connecting Raspberry with Arduino Uno

2. Backend Smart Contract:

a. Write Smart contract

b. Test the contract

c. Deploy to the test network

d. Verify Smart Contract

3. Frontend Ios Application:

a. Launching the Ios Application

b. Interating with the smart contract on the blockchain 

Let's Go!

***
## Part 2: Smart Contract Setup

**Pre-requisite:**

* RPC for connecting to blockchain network
* API url from Etherscan for contract verification.
* Private key of wallet which will be deploying the contract. The best way is to have MetaMask wallet installed in your Browser

**Setting up contract environment:**

* Navigate to the folder
```
cd Smart Contract
```
* Install the required dependencies
```
npm i
```
* Create a file .env:
```
touch .env
```
Open .env by running open .env or opening by any code editor and paste the following and save it:
```
API_URL = '#Your API HTTPS URL'
PRIVATE_KEY = '#Your Owners Private wallet key'
ETHERSCAN_API_KEY = '#Your Etherscan API KEY'
```
* Compile the contract
```
npx hardhat compile
```
* Test the smart contract's functionality
```
npx hardhat test
```
**Deploy contract:**

Update your hardhat.config.js
```
 defaultNetwork: "sepolia",
```
To deploy the contract run:
```
npx hardhat run scripts/Deployment.js --network sepolia
```
**Verify contract:**
```
npx hardhat verify --network sepolia DEPLOYED_CONTRACT_ADDRESS
```
**Deploying to other networks:**

If you wish to deploy on some other network that supports EVM, then you need to do some configurations.
In the hardhat.config.ts file, do the network configuration as follows (for example for sepolia):
```
module.exports = {
    ...
    networks:
       {
          hardhat: {},
          sepolia:
          {
             url: API_URL,
             accounts: [`0x${PRIVATE_KEY}`]
          }
       },
       etherscan:
       {
          apiKey: ETHERSCAN_API_KEY
       },
    ...
}

```
Note that you will require to add the RPC and API for Ethereum in .secrets.json accordingly.
To deploy, select --network accordingly.
***

