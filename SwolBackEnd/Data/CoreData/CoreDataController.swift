//
//  CoreDataController.swift
//  SwolBackEnd
//
//  Created by Pedro Giuliano Farina on 26/03/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import CoreData
import Foundation
import UIKit

internal class CoreDataController {
    internal init(synchronizer: DataSynchronizer) {
        self.synchronizer = synchronizer
    }
    func fetchData() throws {
        devices = try context.fetch(Device.fetchRequest())
        synchronizer.dataChanged(to: devices, in: .CoreData)
    }

    let synchronizer: DataSynchronizer
    var devices: [Device] = []

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSCustomPersistentContainer(name: "DataModel")

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    private lazy var context:NSManagedObjectContext = persistentContainer.viewContext

    //MARK: Core Data Devices
    public func registerDevice(id: UUID = UUID(), name: String, address: String, macAddress: String, port: Int32?) throws -> Device {
        let newAddress = address.isEmpty ? nil : address
        let newMacAddress = macAddress.isEmpty ? nil : macAddress
        guard let device = NSEntityDescription.insertNewObject(forEntityName: "Device", into: context)
            as? Device else {
                throw CDError.FailedToParseObject(reason: "Could not parse object as Device.".localized())
        }
        device.name = name
        device.address = newAddress
        device.mac = newMacAddress
        device.cloudID = id
        if let port = port {
            device.port = port
        }

        do {
            devices.append(device)
            try saveContext()
            return device
        } catch {
            devices.removeLast()
            throw CDError.FailedToSaveContext(reason: "Could not save device.".localized())
        }
    }
    public func registerDevice(_ device: DeviceEntity) throws -> Device {
        guard let id = UUID(uuidString: device.record.recordID.recordName) else {
            throw CDError.FailedToParseObject(reason: "Could not convert cloud data to local device".localized())
        }
        return try registerDevice(id: id, name: device._name.value, address: device._address.value, macAddress: device._mac.value, port: device.port)
    }

    public func editDevice(_ device:Device, newName name: String?, newAddress address: String?,
                           newMacAddress macAddress: String?,
                           newPort port: Int32?) throws {
        var modified: Bool = false
        let oldName = device.name
        let oldAddress = device.address
        let oldMac = device.mac
        let oldPort = device.port

        if name != nil && name != oldName {
            device.name = name
            modified = true
        }

        if address != nil && address != oldAddress {
            device.address = address
            modified = true
        }
        if macAddress != nil && macAddress != oldMac {
            device.mac = macAddress
            modified = true
        }
        if let port = port, port != oldPort {
            device.port = port
            modified = true
        }

        if modified {
            do {
                try saveContext()
            } catch {
                device.address = oldAddress
                device.mac = oldMac
                device.port = oldPort
                throw CDError.FailedToSaveContext(reason: "Could not edit device.".localized())
            }
        }
    }
    public func removeDevice(_ device: Device) throws {
        if let index = devices.firstIndex(of: device) {
            try removeDeviceAt(index)
        }
    }
    public func removeDeviceAt(_ index: Int) throws {
        let device = devices.remove(at: index)
        context.delete(device)

        do {
            try saveContext()
        } catch {
            devices.insert(device, at: index)
            throw CDError.FailedToSaveContext(reason: "Could not remove device.".localized())
        }
    }

    public func overrideDevices(with devices: [DeviceProtocol]) throws {
        for device in self.devices {
            context.delete(device)
        }

        var newDevices: [Device] = []
        for device in devices {
            guard let newDevice = NSEntityDescription.insertNewObject(forEntityName: "Device", into: context)
                as? Device else {
                    throw CDError.FailedToParseObject(reason: "Could not parse object as Device.".localized())
            }
            newDevice.name = device.name
            newDevice.mac = device.mac
            newDevice.cloudID = device.cloudID
            newDevice.address = device.address
            newDevice.port = device.port
            newDevices.append(newDevice)
        }
        do {
            try saveContext()
            self.devices = newDevices
        } catch {
            throw CDError.FailedToSaveContext(reason: "Could not override devices.".localized())
        }
    }

    //MARK: Context
    private func saveContext() throws {
        if context.hasChanges {
            do {
                try context.save()
                synchronizer.dataChanged(to: devices, in: .CoreData)
            } catch {
                throw CDError.FailedToSaveContext(reason: "Could not save context.".localized())
            }
        }
    }
}
