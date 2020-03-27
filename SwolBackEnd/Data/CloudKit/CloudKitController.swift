//
//  CloudKitController.swift
//  SwolBackEnd
//
//  Created by Pedro Giuliano Farina on 26/03/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import CloudKit

internal class CloudKitDataController {
    internal init(synchronizer: DataSynchronizer) {
        self.synchronizer = synchronizer
    }
    func fetchData(completionHandler: ((CKError?) -> Void)? =  nil) {
        DataConnector.fetch(recordType: DeviceEntity.recordType, database: .Private) { (answer) in
            switch answer {
            case .fail(let err, _):
                completionHandler?(err)
            case .successful(let results):
                self.devices = []
                for result in results {
                    let device = DeviceEntity(record: result)
                    self.devices.append(device)
                }
                self.synchronizer.dataChanged(to: self.devices, in: .CloudKit)
                completionHandler?(nil)
                break
            default:
                break
            }
        }
    }

    let synchronizer: DataSynchronizer
    var devices: [DeviceEntity] = []

    //MARK: CloudKit Devices
    public func registerDevice(id: UUID, name: String?, address: String, macAddress: String, port: Int32) {
        let realName = name ?? ""
        let finalName = realName.isEmpty ? "John".localized() : realName

        let device = DeviceEntity(id: id, address: address, mac: macAddress, name: finalName, port: Int64(port))

        devices.append(device)
        saveData(entitiesToSave: [device])
    }
    public func registerDevice(_ device: Device) throws {
        guard let id = device.cloudID, let name = device.name, let address = device.address, let mac = device.mac else {
            throw CDError.FailedToParseObject(reason: "Couldn't convert device to send to Cloud".localized())
        }
        registerDevice(id: id, name: name, address: address, macAddress: mac, port: device.port)
    }

    public func findDeviceBy(id: UUID) -> DeviceEntity? {
        return devices.first { (dev) -> Bool in
            return dev.record.recordID.recordName == id.uuidString
        }
    }

    public func editDevice(_ device:DeviceEntity, newName name: String?, newAddress address: String?,
                           newMacAddress macAddress: String?,
                           newPort port: Int32?) {
        var modified: Bool = false
        let oldName = device.name
        let oldAddress = device.address
        let oldMac = device.mac
        let oldPort = device.port

        if let name = name, name != oldName {
            device._name.value = name
            modified = true
        }

        if let address = address, address != oldAddress {
            device._address.value = address
            modified = true
        }
        if let macAddress = macAddress, macAddress != oldMac {
            device._mac.value = macAddress
            modified = true
        }
        if let port = port, port != oldPort {
            device._port.value = Int64(port)
            modified = true
        }

        if modified {
            saveData(entitiesToSave: [device])
        }
    }

    public func removeDevice(_ device: DeviceEntity) {
        if let index = devices.firstIndex(of: device) {
            removeDeviceAt(index)
        }
    }
    
    public func removeDeviceAt(_ index: Int) {
        let device = devices.remove(at: index)
        saveData(entitiesToDelete: [device])
    }

    public func removeDevices(_ devices: [DeviceEntity]) {
        saveData(entitiesToDelete: devices)
    }

    //MARK: Saving data
    private func saveData(entitiesToSave: [EntityObject] = [], entitiesToDelete: [EntityObject] = []) {
        DataConnector.saveData(database: .Private, entitiesToSave: entitiesToSave, entitiesToDelete: entitiesToDelete)
        synchronizer.dataChanged(to: devices, in: .CloudKit)
    }
}
