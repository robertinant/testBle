//
//  ViewController.swift
//  testBle
//
//  Created by Robert Wessels on 6/8/22.
//

import Cocoa
import CoreBluetooth

class ViewController: NSViewController {
    var centralManager: CBCentralManager!
    var muteButtonPeripheral: CBPeripheral!
    let muteButtonServiceCBUUID = CBUUID(string: "0xFFF0")
    let muteButtonStateCharacteristicCBUUID = CBUUID(string: "0xFFF1")
    let muteButtonEventCharacteristicCBUUID = CBUUID(string: "0xFFF2")

    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)


        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
          case .unknown:
            print("central.state is .unknown")
          case .resetting:
            print("central.state is .resetting")
          case .unsupported:
            print("central.state is .unsupported")
          case .unauthorized:
            print("central.state is .unauthorized")
          case .poweredOff:
            print("central.state is .poweredOff")
           case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: [muteButtonServiceCBUUID])
        @unknown default:
            print("central.state is unknown")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        muteButtonPeripheral = peripheral
        muteButtonPeripheral.delegate = self

        centralManager.stopScan()
        centralManager.connect(muteButtonPeripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected")
        muteButtonPeripheral.discoverServices([muteButtonServiceCBUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("disconnected")
        centralManager.scanForPeripherals(withServices: [muteButtonServiceCBUUID])
    }
}

extension ViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }

        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
         }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
      guard let characteristics = service.characteristics else { return }
        
      for characteristic in characteristics {
//          peripheral.discoverDescriptors(for: characteristic)

          if characteristic.properties.contains(.read) {
              print("\(characteristic.uuid): properties contains .read")
              peripheral.readValue(for: characteristic)
          }
          if characteristic.properties.contains(.notify) {
              print("\(characteristic.uuid): properties contains .notify")
              peripheral.setNotifyValue(true, for: characteristic)
          }
          
      }
    }
    
//    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
//        guard let descriptors = characteristic.descriptors else { return }
//
//        for descr in descriptors {
//            peripheral.readValue(for: descr)
//        }
//    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        
      switch characteristic.uuid {
        case muteButtonStateCharacteristicCBUUID:
          print(characteristic.descriptors)
          //print(characteristic.value ?? "no value")
          let characteristicData = characteristic.value
          let byte = characteristicData?.first ?? 0xFF
          print(byte as UInt8)
          break
        case muteButtonEventCharacteristicCBUUID:
          let characteristicData = characteristic.value
          let byte = characteristicData?.first ?? 0xFF
          print(byte as UInt8)
          switch byte {
            case 0x01:
              print("Right Button")
              break
            case 0x02:
              print("Left Button")
              break
          default:
              print("Unknown value for button")
              break
          }
          break
        default:
          print("Unhandled Characteristic UUID: \(characteristic.uuid)")
      }
    }
    
//    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
//        switch descriptor.uuid.uuidString {
//        case CBUUIDCharacteristicExtendedPropertiesString:
//            guard let properties = descriptor.value as? NSNumber else {
//                break
//            }
//            print("  Extended properties: \(properties)")
//        case CBUUIDCharacteristicUserDescriptionString:
//            guard let description = descriptor.value as? NSString else {
//                break
//            }
//            print("  User description: \(description)")
//        case CBUUIDClientCharacteristicConfigurationString:
//            guard let clientConfig = descriptor.value as? NSNumber else {
//                break
//            }
//            print("  Client configuration: \(clientConfig)")
//        case CBUUIDServerCharacteristicConfigurationString:
//            guard let serverConfig = descriptor.value as? NSNumber else {
//                break
//            }
//            print("  Server configuration: \(serverConfig)")
//        case CBUUIDCharacteristicFormatString:
//            guard let format = descriptor.value as? NSData else {
//                break
//            }
//            print("  Format: \(format)")
//        case CBUUIDCharacteristicAggregateFormatString:
//            print("  Aggregate Format: (is not documented)")
//        default:
//            break
//        }
//    }
//    private func bodyLocation(from characteristic: CBCharacteristic) -> String {
//      guard let characteristicData = characteristic.value,
//        let byte = characteristicData.first else { return "Error" }
//
//      switch byte {
//        case 0: return "Other"
//        case 1: return "Chest"
//        case 2: return "Wrist"
//        case 3: return "Finger"
//        case 4: return "Hand"
//        case 5: return "Ear Lobe"
//        case 6: return "Foot"
//        default:
//          return "Reserved for future use"
//      }
//    }
}
