# Mobile-DAPP-try
***
## Part 2: Smart Contract Setup

**Pre-requisite:**

* RPC for connecting to blockchain network
* API key from Etherscan for contract verification. Note: In this tutorial, we will be working with Binance, therefore the above links are for binance. You can choose any network that supports EVM (e.g. Ethereum), and then accordingly change the RPC and API keys
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
Replace the API keys with your keys.

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
To deploy and verify the contract run:
```
npx hardhat run scripts/Deployment.js --network sepolia
```
**Verify contract:**
```
npx hardhat verify --network sepolia DEPLOYED_CONTRACT_ADDRESS
```
**Deploying to other networks:**

If you wish to deploy on some other network that supports EVM, then you need to do some configurations.
In the hardhat.config.ts file, do the network configuration as follows (for example for ETH):
```
...
require('dotenv').config();
...
const { API_URL, PRIVATE_KEY, ETHERSCAN_API_KEY} = process.env;
...
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
To deploy, select --network accordingly, e.g. --network eth_scan.
***
Once the contract is deployed, you should verify the smart contract, such that interacting with it becomes easy:
```
npx hardhat etherscan-verify --network bsc_testnet
```
