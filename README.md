# Mobile-DAPP-try
***
## Part 2: Smart Contract Setup

**Pre-requisite:**

* RPC for connecting to blockchain network
* API key from Binance for contract verification. Note: In this tutorial, we will be working with Binance, therefore the above links are for binance. You can choose any network that supports EVM (e.g. Ethereum), and then accordingly change the RPC and API keys
* Private key of wallet which will be deploying the contract. The best way is to have MetaMask wallet installed in your Browser

**Setting up contract environment:**

* Navigate to the folder
```
cd contracts
```
* Install the required dependencies
```
npm i
```
* Compile the contract
```
npm run compile
```
* Test the smart contract's functionality
```
npm run test
```
Note: If you see any error after running test, most likely because of .env file that you need to create. Please check the next step and then re run this code.

**Deploy contract:**

Create a file .env:
```
touch .env
```
Open .env by running open .env or opening by any code editor and paste the following and save it:
```
privateKey = '#Your RPC key'
apiKey= '#Your private key'
PROVIDER_URL = '#Your API  Key'
```
Replace the API keys with your keys. Note: This file will be ignored by git as it is included in the .gitignore file.
To deploy and verify the contract
```
npx hardhat deploy --tags token --network bsc_testnet
```
***
**Deploying to other networks:**
***
If you wish to deploy on some other network that supports EVM, then you need to do some configurations.
In the hardhat.config.ts file, do the network configuration as follows (for example for ETH):
```
eth_scan: {
    url: process.env.PROVIDER_URL,
    accounts: [process.env.privateKey],
    verify: {
        etherscan: {
        apiKey: secrets.apiKey,
    },
  },
},
```
Note that you will require to add the RPC and API for Ethereum in .secrets.json accordingly.
To deploy, select --network accordingly, e.g. --network eth_scan.
***
Once the contract is deployed, you should verify the smart contract, such that interacting with it becomes easy:
```
npx hardhat etherscan-verify --network bsc_testnet
```
