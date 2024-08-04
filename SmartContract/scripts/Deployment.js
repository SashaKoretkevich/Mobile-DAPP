async function main()
{
    const DeviceManager = await ethers.deployContract("DeviceManager");
    const contractAddress = await DeviceManager.getAddress();
    console.log("Contract deployed to address:", contractAddress);
 }
 
 main()
   .then(() => process.exit(0))
   .catch(error => {
     console.error(error);
     process.exit(1);
   });