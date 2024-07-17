const { expect } = require("chai");
const hre = require("hardhat");

const 
{
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");


describe ("DeviceManager", function ()
{  
    async function deploy() 
    {
        const [owner, user] = await hre.ethers.getSigners();
        const contract = await hre.ethers.deployContract("DeviceManager");
        await  contract.waitForDeployment();
        return {contract, owner, user};
    }
  it("User access denied (addDevice)", async function ()
  {
    const {contract, owner, user} = await loadFixture(deploy);
    await expect(contract.connect(user).addDevice(user.address, "Transport")).to.be.revertedWith("Only manager can call this function");
  });
  it("User access denied (uncertify)", async function ()
  {
    const {contract, owner, user} = await loadFixture(deploy);
    await expect(contract.connect(user).deviceUncertify(user)).to.be.revertedWith("Only manager can call this function");
  });
  it("User access denied (transferFunds)", async function ()
  { 
    const {contract, owner, user} = await loadFixture(deploy);
    await expect(contract.connect(user).transferFunds(user)).to.be.revertedWith("Only manager can call this function");
  });
  it("User access denied (removeDevice)", async function ()
  {
    const {contract, owner, user} = await loadFixture(deploy);
    await expect(contract.connect(user).removeDevice(user)).to.be.revertedWith("Only manager can call this function");
  });
  it("Device access denied (sendPotentiometerMetrics)", async function ()
  {
    const {contract, owner, user} = await loadFixture(deploy);
    await expect(contract.connect(user).sendPotentiometerMetrics(1)).to.be.revertedWith("Only certified device can send metrics");
  });
  it("Device access denied (sendUltrasonicMetrics)", async function ()
  {
    const {contract, owner, user} = await loadFixture(deploy);
    await expect(contract.connect(user).sendUltrasonicMetrics(1)).to.be.revertedWith("Only certified device can send metrics");
  });
  it("AddDevice", async function ()
  {
    const {contract, owner, user} = await loadFixture(deploy);
    let c = await contract.getAllDevices();
    let lc = c.length;
    const b = await contract["addDevice(address payable, string memory)"](user.address, "Transport");
    await b.wait();
    let a = await contract.getAllDevices();
    let la = a.length;
    expect(la).to.equal(lc + 1);
  });
  it("Device already registered (addDevice)", async function ()
  {
    const {contract, owner, user} = await loadFixture(deploy);
    const b = await contract.addDevice(user.address, "Transport");
    await b.wait();
    await expect(contract.addDevice(user.address, "Transport")).to.be.revertedWith("Device has already been registered");
  });
  it("Has not been certified to revoke certificate", async function ()
  {
    
    const {contract, owner, user} = await loadFixture(deploy);
    const b = await contract.addDevice(user.address, "Transport");
    await b.wait();
    await expect(contract.deviceUncertify(user)).to.be.revertedWith("Device has not been certified by manager");
  });
  it("User access denied (certification)", async function ()
  {
    const {contract, owner, user} = await loadFixture(deploy);
    await expect(contract.connect(user).deviceCertification(user)).to.be.revertedWith("Only manager can call this function");
  });
  it("Certification of device", async function ()
  {
    const {contract, owner, user} = await loadFixture(deploy);
    const b = await contract.addDevice(user.address, "Transport");
    await b.wait();
    let c = await contract.deviceCertification(user);
    await c.wait();
    let a = await contract.getDeviceCertification(user);
    expect(a).to.equal("Device has been certified by the manager");
  });
  it("Has already been certified", async function ()
  {
    const {contract, owner, user} = await loadFixture(deploy);
    const b = await contract.addDevice(user.address, "Transport");
    await b.wait();
    let c = await contract.deviceCertification(user);
    await c.wait();
    await expect(contract.deviceCertification(user)).to.be.revertedWith("Device has already been certified by manager");
  });
  it("Revoke certificate of device", async function ()
  {
    const {contract, owner, user} = await loadFixture(deploy);
    const b = await contract.addDevice(user.address, "Transport");
    await b.wait();
    let l = await contract.deviceCertification(user);
    await l.wait();
    let c = await contract.deviceUncertify(user);
    await c.wait();
    let a = await contract.getDeviceCertification(user);
    expect(a).to.equal("Device has not been certified by the manager");
  });
  it("Has no certificate, unable to recieve funds", async function ()
  {
    const {contract, owner, user} = await loadFixture(deploy);
    const b = await contract.addDevice(user.address, "Transport");
    await b.wait();
    await expect(contract.transferFunds(user , {value: 1000000000000000})).to.be.revertedWith("Device has not been certified yet, contact the manager to request the certification");
  });
  it("Transfer Funds", async function ()
  {
    const {contract, owner, user} = await loadFixture(deploy);
    const l = await contract.addDevice(user.address, "Transport");
    await l.wait();
    let h = await contract.deviceCertification(user);
    await h.wait();
    let a = await contract.getDevBalance(user);
    let b = await contract.transferFunds(user , {value: 1000000000000000});
    await b.wait();
    let c = await contract.getDevBalance(user);
    expect(c).to.not.equal(a);
  });

  it("Sending metrics of ultrasonic", async function ()
  {
    const {contract, owner, user} = await loadFixture(deploy);
    const l = await contract.addDevice(user.address, "Transport");
    await l.wait();
    let h = await contract.deviceCertification(user);
    await h.wait();
    let f = await contract.getMetrics(user.address, 2);
    let lf = f.length;
    let t = await contract.connect(user).sendUltrasonicMetrics(2, {gasLimit: 3000000});
    await t.wait();
    let j = await contract.getMetrics(user.address, 2);
    let lj = j.length;
    expect(lj).to.equal(lf + 1);
  });

  it("Sending metrics of ultrasonic limit 10", async function ()
  {
    const {contract, owner, user} = await loadFixture(deploy);
    const l = await contract.addDevice(user.address, "Transport");
    await l.wait();
    let h = await contract.deviceCertification(user);
    await h.wait();
    for (let i = 0; i <= 10; i++)
    {
      let t = await contract.connect(user).sendUltrasonicMetrics(i, {gasLimit: 3000000});
      await t.wait();
    }
    let j = await contract.getMetrics(user.address, 2);
    let lj = j.length;
    expect(lj).to.equal(10);
  });

  it("Sending metrics of potentiometer", async function ()
  {
    const {contract, owner, user} = await loadFixture(deploy);
    const l = await contract.addDevice(user.address, "Transport");
    await l.wait();
    let h = await contract.deviceCertification(user);
    await h.wait();
    let a = await contract.getMetrics(user.address, 1);
    let la = a.length;
    let b = await contract.connect(user).sendPotentiometerMetrics(1, {gasLimit: 3000000});
    await b.wait();
    let c = await contract.getMetrics(user.address, 1);
    let lc = c.length;
    expect(lc).to.equal(la + 1);
  });

  it("Sending metrics of potentiometer limit 10", async function ()
  {
    const {contract, owner, user} = await loadFixture(deploy);
    const l = await contract.addDevice(user.address, "Transport");
    await l.wait();
    let h = await contract.deviceCertification(user);
    await h.wait();
    let a = await contract.getMetrics(user.address, 1);
    for (let i = 0; i <= 10; i++)
    {
      let b = await contract.connect(user).sendPotentiometerMetrics(i, {gasLimit: 3000000});
      await b.wait();
    }
    let c = await contract.getMetrics(user.address, 1);
    let lc = c.length;
    expect(lc).to.equal(10);
  });
  
  it("Remove device", async function ()
  {
    const {contract, owner, user} = await loadFixture(deploy);
    const l = await contract.addDevice(user.address, "Transport");
    await l.wait();
    let d = await contract.getAllDevices();
    let ld = d.length;
    let a = await contract.removeDevice(user.address, {gasLimit: 3000000});
    await a.wait();
    let b = await contract.getAllDevices();
    let lb = b.length;
    expect(lb).to.equal(ld - 1);
 });
})
