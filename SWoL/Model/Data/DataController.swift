//
//  DataController.swift
//  SWoL
//
//  Created by Pedro Giuliano Farina on 04/01/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import CoreData
import Foundation
import UIKit

public class DataController {
    enum DataError: Error {
        case FailedToParseNSObject(reason: String)
        case FailedToSaveContext(reason: String)
    }

    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    private var _devices: [Device]

    //MARK: Devices
    public var devices: [Device] {
        var copy: [Device] = []
        copy.append(contentsOf: _devices)
        return copy
    }

    public func registerDevice(name: String, address: String, macAddress: String, port: Int32?) throws {
        let newAddress = address.isEmpty ? nil : address
        let newMacAddress = macAddress.isEmpty ? nil : macAddress
        let newName = name.isEmpty ? "John".localized() : name
        guard let device = NSEntityDescription.insertNewObject(forEntityName: "Device", into: context)
            as? Device else {
                throw DataError.FailedToParseNSObject(reason: "Could not parse object as Device.".localized())
        }
        device.name = newName
        device.address = newAddress
        device.mac = newMacAddress
        if let port = port {
            device.port = port
        }

        do {
            _devices.append(device)
            try saveContext()
        } catch {
            _devices.removeLast()
            throw DataError.FailedToSaveContext(reason: "Could not save device.".localized())
        }
    }
    public func editDevice(_ device:Device, newAddress address: String?,
                           newMacAddress macAddress: String?,
                           newPort port: Int32?) throws {
        var modified: Bool = false
        let oldAddress = device.address
        let oldMac = device.mac
        let oldPort = device.port

        if address != nil {
            device.address = address
            modified = true
        }
        if macAddress != nil {
            device.mac = macAddress
            modified = true
        }
        if let port = port {
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
                throw DataError.FailedToSaveContext(reason: "Could not edit device.".localized())
            }
        }
    }
    public func removeDevice(_ device: Device) throws {
        if let index = _devices.firstIndex(of: device) {
            try removeDeviceAt(index)
        }
    }
    public func removeDeviceAt(_ index: Int) throws {
        let device = _devices.remove(at: index)
        context.delete(device)

        do {
            try saveContext()
        } catch {
            _devices.insert(device, at: index)
            throw DataError.FailedToSaveContext(reason: "Could not remove device.".localized())
        }
    }

    //MARK: Context
    private func saveContext() throws {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                throw DataError.FailedToSaveContext(reason: "Could not save context.".localized())
            }
        }
    }

    //MARK: Singleton Basic Properties
    private init() {
        do {
            _devices = try context.fetch(Device.fetchRequest())
        } catch {
            fatalError("Could not communicate with Core Data.".localized())
        }
    }

    class func shared() -> DataController {
        return sharedDataController
    }

    private static var sharedDataController: DataController = {
        let dController = DataController()
        return dController
    }()
}
