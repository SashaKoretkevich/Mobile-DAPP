// //SPDX-License-Identifier: UNLICENSED
pragma solidity >0.8.16;

contract DeviceManager {
    
    struct Device
    {
        address payable deviceAddress;
        string deviceType;
        uint256 deviceBalance;
        bool isCertified;
    }

    address payable public Manager;

    mapping (address => Device) devices;
    mapping (address => uint[]) potentiometerMetrics;
    mapping (address => uint[]) ultrasonicMetrics;
    address[] addressArray;


    constructor() payable
    {
       Manager = payable(msg.sender);
    }

    function addDevice(address payable deviceAddress, string memory deviceType) public
    {
        require (msg.sender == Manager,
        "Only manager can call this function");
        require (devices[deviceAddress].deviceAddress == address(0),
        "Device has already been registered");
        Device memory newDevice = Device( deviceAddress, deviceType, deviceAddress.balance, false);
        devices[deviceAddress] = newDevice;
        addressArray.push(deviceAddress);
    }

    function removeDevice(address payable deviceAddress)  public
    {
        require (msg.sender == Manager,
        "Only manager can call this function");
        delete devices[deviceAddress];
        if (potentiometerMetrics[deviceAddress].length != 0)
        {
            delete potentiometerMetrics[deviceAddress];
        }
        if (ultrasonicMetrics[deviceAddress].length != 0)
        {
            delete ultrasonicMetrics[deviceAddress];
        }
        for (uint i = 0; i < addressArray.length; i++)
        {
            if (addressArray[i] == deviceAddress)
            {
                for (uint j = i; j < addressArray.length - 1; j++)
                {
                    addressArray[j] = addressArray[j+1];
                }
                addressArray.pop();
                break;
            }
        }
    }

    function updateDevBalance(address payable deviceAddress) internal
    {
        devices[deviceAddress].deviceBalance = devices[deviceAddress].deviceAddress.balance;
    }

    function getDevBalance(address payable deviceAddress)  public view returns (uint256)
    {
        return devices[deviceAddress].deviceBalance;
    }

    function deviceCertification (address payable deviceAddress)  public
    {
        require (msg.sender == Manager,
        "Only manager can call this function");
        require (devices[deviceAddress].isCertified == false,
        "Device has already been certified by manager");
        devices[deviceAddress].isCertified = true;
    }

    function deviceUncertify (address payable deviceAddress) public
    {
        require (msg.sender == Manager,
        "Only manager can call this function");
        require (devices[deviceAddress].isCertified == true,
        "Device has not been certified by manager");
        devices[deviceAddress].isCertified = false;
    }

    function getDeviceCertification (address payable deviceAddress) public view returns (string memory)
    {
        if (devices[deviceAddress].isCertified == true)
        {
            return "Device has been certified by the manager";
        }
        else 
        {
            return "Device has not been certified by the manager";
        }
    }

    function transferFunds (address payable deviceAddress) public payable
    {
        require (msg.sender == Manager,
        "Only manager can call this function");
        require (msg.sender.balance >= msg.value,
        "Insufficient funds, replenish your balance");
        require (devices[deviceAddress].isCertified == true,
        "Device has not been certified yet, contact the manager to request the certification");

        (bool success1, ) = deviceAddress.call{value: msg.value}("");
        require(success1, "Payment failed.");
        updateDevBalance(deviceAddress);
    }

    function getAllDevices() public view returns (Device[] memory)
    {
        uint size = addressArray.length;
        Device[] memory devicesToReturn = new Device[](size);
        for (uint i = 0; i < addressArray.length; i++)
        {
            devicesToReturn[i] = devices[addressArray[i]];
        }
        return (devicesToReturn);
    }

    function sendPotentiometerMetrics (uint metric) public
    {
        require (devices[msg.sender].isCertified == true,
        "Only certified device can send metrics");
       
        if (potentiometerMetrics[msg.sender].length == 10)
        {
            for (uint j = 0; j < potentiometerMetrics[msg.sender].length - 1; j++)
            {
                potentiometerMetrics[msg.sender][j] = potentiometerMetrics[msg.sender][j+1];
            }
            potentiometerMetrics[msg.sender].pop();
        }
        potentiometerMetrics[msg.sender].push(metric);

        updateDevBalance(payable(msg.sender));
    }

    function sendUltrasonicMetrics (uint metric) public
    {
        require (devices[msg.sender].isCertified == true,
        "Only certified device can send metrics");
        
        if (ultrasonicMetrics[msg.sender].length == 10)
        {
            for (uint j = 0; j < ultrasonicMetrics[msg.sender].length - 1; j++)
            {
                ultrasonicMetrics[msg.sender][j] = ultrasonicMetrics[msg.sender][j+1];
            }
            ultrasonicMetrics[msg.sender].pop();
        }
        ultrasonicMetrics[msg.sender].push(metric);

        updateDevBalance(payable(msg.sender));
    }

    function getMetrics (address payable deviceAddress, uint idSensor) public view returns (uint[] memory)
    {
        require (idSensor == 1 || idSensor == 2,
        "Wrong sensor id");
        if (idSensor == 1)
        {
            return potentiometerMetrics[deviceAddress];
        }
        else
        {
            return ultrasonicMetrics[deviceAddress];
        }
    }
}
