from web3 import Web3, HTTPProvider
import serial
import math

array_potentiometer = []
array_ultrasonic = []
maximum_potentiometer = 0
maximum_ultrasonic = 0
i = 0
j = 0
z = 0

w3 = Web3(Web3.HTTPProvider('https://sepolia.infura.io/v3/163bdf41b27c48a09367f19df7d25ff2'))

print("Connection:")
print(w3.is_connected())

# Making instance of the contract
deviceAddress = '0x48A9C9CDDd5B0703F528AC282A359e0DEd03D503'
devicePrivatekey = 'dc4a30f11c2b12ee71b18f31eb77e8a3fc590f76d60ce4bc5f1e2d4a3d01b96c'
contractAddress = '0x6126d9B2Ba6664b90F0685fB723bff46dA9Eaef5'
abi = '[{"inputs":[],"stateMutability":"payable","type":"constructor"},{"inputs":[],"name":"Manager","outputs":[{"internalType":"address payable","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address payable","name":"deviceAddress","type":"address"},{"internalType":"string","name":"deviceType","type":"string"}],"name":"addDevice","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address payable","name":"deviceAddress","type":"address"}],"name":"deviceCertification","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address payable","name":"deviceAddress","type":"address"}],"name":"deviceUncertify","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"getAllDevices","outputs":[{"components":[{"internalType":"address payable","name":"deviceAddress","type":"address"},{"internalType":"string","name":"deviceType","type":"string"},{"internalType":"uint256","name":"deviceBalance","type":"uint256"},{"internalType":"bool","name":"isCertified","type":"bool"}],"internalType":"struct DeviceManager.Device[]","name":"","type":"tuple[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address payable","name":"deviceAddress","type":"address"}],"name":"getDevBalance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address payable","name":"deviceAddress","type":"address"}],"name":"getDeviceCertification","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address payable","name":"deviceAddress","type":"address"},{"internalType":"uint256","name":"idSensor","type":"uint256"}],"name":"getMetrics","outputs":[{"internalType":"uint256[]","name":"","type":"uint256[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address payable","name":"deviceAddress","type":"address"}],"name":"removeDevice","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"metric","type":"uint256"}],"name":"sendPotentiometerMetrics","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"metric","type":"uint256"}],"name":"sendUltrasonicMetrics","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address payable","name":"deviceAddress","type":"address"}],"name":"transferFunds","outputs":[],"stateMutability":"payable","type":"function"}]'
contract = w3.eth.contract(address = contractAddress, abi = abi)
Chain_id = w3.eth.chain_id

if __name__ == '__main__':
    ser = serial.Serial('/dev/ttyUSB0',9600,timeout = 1)
    ser.flush() 
    while contract.functions.getDeviceCertification(deviceAddress).call() == "Device has been certified by the manager":
        if ser.in_waiting > 0:
            if i < 30:
                if i % 2 == 0:
                    line = ser.readline().decode('utf-8').rstrip()
                    array_ultrasonic.append(int(line))
                    if array_ultrasonic[z] > maximum_ultrasonic:
                       maximum_ultrasonic = array_ultrasonic[z]
                       z += 1
                    
                    
                if i % 2 != 0:
                    line = ser.readline().decode('utf-8').rstrip()
                    array_potentiometer.append(int(line))
                    if array_potentiometer[j] > maximum_potentiometer:
                        maximum_potentiometer = array_potentiometer[j]
                        j += 1
    
                i += 1
            else:
                nonce = w3.eth.get_transaction_count(deviceAddress)

                call_function = contract.functions.sendPotentiometerMetrics(maximum_potentiometer).build_transaction({'chainId': Chain_id, 'from': deviceAddress, 'nonce': nonce})
                signed_tx = w3.eth.account.sign_transaction(call_function, private_key = devicePrivatekey)
                send_tx = w3.eth.send_raw_transaction(signed_tx.rawTransaction)
                tx_receipt = w3.eth.wait_for_transaction_receipt(send_tx)

                nonce = w3.eth.get_transaction_count(deviceAddress)

                call_function = contract.functions.sendUltrasonicMetrics(maximum_ultrasonic).build_transaction({'chainId': Chain_id, 'from': deviceAddress, 'nonce': nonce})
                signed_tx = w3.eth.account.sign_transaction(call_function, private_key = devicePrivatekey)
                send_tx = w3.eth.send_raw_transaction(signed_tx.rawTransaction)
                tx_receipt = w3.eth.wait_for_transaction_receipt(send_tx)

                maximum_potentiometer = 0
                maximum_ultrasonic = 0
                i = 0
                j = 0
                z = 0
                array_potentiometer.clear()
                array_ultrasonic.clear()