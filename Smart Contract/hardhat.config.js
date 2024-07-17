/** @type import('hardhat/config').HardhatUserConfig */

require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-ethers");

require('dotenv').config();

const { API_URL, PRIVATE_KEY, ETHERSCAN_API_KEY} = process.env;

module.exports = {
   solidity: {
      version: "0.8.19",
      
     },
   defaultNetwork: "hardhat",
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
   sourcify:
   {
      enabled: true
   },
   mocha:
   {
      timeout: 100000000
   },
};
