# Mobile-DAPP

Greetings all! In this repository, we will look how you can have your own Device managing system. In the later part of the text, we will tell you about all the prerequisites to run this application. Our task is divided into three parts:
  
**1. Backend Smart Contract:**

  a. Write Smart contract

  b. Test the contract

  c. Deploy to the test network

  d. Verify Smart Contract

  
**2. iOS Application:**

  a. Launching the iOS Application
  

**3. IoT device setup:**

  a. Writing code on raspberry pi 3

  b. Connecting Raspberry with Arduino Uno
  

Let's Go!

## Setup the environment

Clone the repository and go the folder
```
git clone https://github.com/SashaKoretkevich/Mobile-DAPP.git
cd Mobile-DAPP
```
The folder will have three subfolders:

+ SmartContract

+ iOSApp

+ IoTDevices

## Part 1: Smart Contract Setup

**Pre-requisite:**

* RPC for connecting to blockchain network
* API key from Etherscan for contract verification. Note: In this tutorial, we will be working with Ethereum. You can choose any network that supports EVM (e.g. Binance), and then accordingly change the RPC and API keys
* Private key of wallet which will be deploying the contract. The best way is to have MetaMask wallet installed in your Browser

**Setting up contract environment:**

* Navigate to the folder
```
cd SmartContract
```
* Install the required dependencies
```
npm i
```
```
npm install --save-dev @nomicfoundation/hardhat-toolbox
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
In the hardhat.config.js file, do the network configuration as follows:
```
module.exports = {
    ...
    networks:
       {
          hardhat: {},
          "#Name of the network":
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
Note that you will require to add the RPC and API for Ethereum in .env accordingly.
To deploy and verify, select --network accordingly.
***
## Part 2: iOS application setup
* Going back to the main folder of the repository cloned
```
cd -
```
* Going to iOSApp folder
```
cd iOSApp
```
* Opening the project
```
open blOne.xcodeproj
```
Before building the application it is needed to paste needed information to the file HomeViewController.swift about 
- manager's wallet address and private key,
- smart contract's address and its ABI in the JSON format,
- RPC URL

After that it is possible to open the application and test it.

In order to run the application, simulator or mobile device (iPhone) can be used but the version of iOS should be more or equal to 16.0. 

In the login page to get access to the app it is necessary to use the wallet address of the manager.

## Part 3: IoT Devices
**MicroController:**
We are using the Arduino Uno as our Micro Controller, its connected to a Potentiometer sensor and a Ultrasonic sensor, 
there are also 3 led lights (red, yellow, green) that light up according to the values coming from the Pontentiometer.

**MicroProcessors:**
The Raspberry pi is connected to the Arduino using a USB Cable in order to transfer the data coming from the sensors to the raspberry pi, and then transfer them to the BlockChain.
