//
//  DataController.swift
//  SwolKit
//
//  Created by Pedro Giuliano Farina on 04/01/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import CoreData
import CloudKit
import Foundation
import UIKit

public class DataManager: DataSynchronizer {

    //MARK: Synchronization and permission
    private var permission: DataPermission? {
        didSet {
            fetch()
        }
    }
    private func hasPermissionTo(access permission: DataPermission) -> Bool {
        return ((self.permission?.rawValue ?? 0) & permission.rawValue) >= permission.rawValue
    }
    lazy var coreDataController: CoreDataController = CoreDataController(synchronizer: self)
    lazy var cloudKitDataController: CloudKitDataController = CloudKitDataController(synchronizer: self)

    private func fetch() {
        if hasPermissionTo(access: .CoreData) {
            do {
                try coreDataController.fetchData()
            } catch {
                self.conflictHandler.errDidOccur(err: error)
            }
        }
        if hasPermissionTo(access: .CloudKit) {
            cloudKitDataController.fetchData { (error) in
                if let error = error {
                    self.conflictHandler.errDidOccur(err: error)
                } else {
                    self.syncData()
                }
            }
        }
    }

    func syncData() {
        guard permission == DataPermission.Both else {
            return
        }
        var ckCopy: [DeviceEntity] = []
        ckCopy.append(contentsOf: cloudKitDataController.devices)
        var cdCopy: [Device] = []
        cdCopy.append(contentsOf: coreDataController.devices)

        //Adding CloudKit devices do CoreData
        for ckDevice in ckCopy where !cdCopy.contains(where: { (cdDevice) -> Bool in
            return cdDevice.cloudID ?? UUID() == ckDevice.cloudID
        }) {
            do {
                _ = try coreDataController.registerDevice(ckDevice)
            } catch {
                self.conflictHandler.errDidOccur(err: error)
            }
        }

        //Adding CoreData devices do CloudKit
        for cdDevice in cdCopy where !ckCopy.contains(where: { (ckDevice) -> Bool in
            return ckDevice.cloudID ?? UUID() == cdDevice.cloudID
        }) {
            do {
                try cloudKitDataController.registerDevice(cdDevice)
            } catch {
                self.conflictHandler.errDidOccur(err: error)
            }
        }

        //Checking for conflicts
        ckCopy = []
        ckCopy.append(contentsOf: cloudKitDataController.devices)
        cdCopy = []
        cdCopy.append(contentsOf: coreDataController.devices)
        for i in 0 ..< min(ckCopy.count, cdCopy.count) {
            if ckCopy[i] <> cdCopy[i] {
                conflictHandler.chooseVersion { (version) in
                    if version == .Local {
                        self.cloudKitDataController.overrideDevices(with: cdCopy)
                        self._devices = cdCopy
                    } else {
                        do {
                            try self.coreDataController.overrideDevices(with: ckCopy)
                            self._devices = ckCopy
                        } catch {
                            self.conflictHandler.errDidOccur(err: error)
                        }
                    }
                    self.notifyWatchers()
                }
                break
            }
        }
    }

    func dataChanged(to devices: [DeviceProtocol], in system: DataPermission) {
        if hasPermissionTo(access: .CoreData) && system == .CloudKit {
            return
        }
        self._devices = devices
    }

    //MARK: Devices
    private func notifyWatchers() {
        for watcher in watchers {
            watcher.dataUpdated()
        }
    }
    private var _devices: [DeviceProtocol] = [] {
        didSet {
            notifyWatchers()
        }
    }
    public var devices: [DeviceProtocol] {
        get {
            var copy: [DeviceProtocol] = []
            copy.append(contentsOf: _devices)
            return copy
        }
    }

    public func registerDevice(name: String, address: String, macAddress: String, port: Int32?) throws {
        var device: Device?
        let newName = name.isEmpty ? "John".localized() : name
        if hasPermissionTo(access: .CoreData) {
            device = try coreDataController.registerDevice(name: newName, address: address, macAddress: macAddress, port: port)
        }
        if hasPermissionTo(access: .CloudKit) {
            cloudKitDataController.registerDevice(id: device?.cloudID ?? UUID(),
                                                  name: newName, address: address, macAddress: macAddress, port: port ?? 9)
        }
    }

    public func editDevice(_ device:DeviceProtocol, newName name: String?, newAddress address: String?,
                           newMacAddress macAddress: String?,
                           newPort port: Int32?) throws {
        if hasPermissionTo(access: .CoreData), let device = device as? Device {
            try coreDataController.editDevice(device, newName: name, newAddress: address, newMacAddress: macAddress, newPort: port)
        }
        if hasPermissionTo(access: .CloudKit), let device = cloudKitDataController.findDeviceBy(id: device.cloudID ?? UUID()) {
            cloudKitDataController.editDevice(device, newName: name, newAddress: address, newMacAddress: macAddress, newPort: port)
        }
    }

    public func removeDevice(_ device: DeviceProtocol) throws {
        var id: UUID?
        if hasPermissionTo(access: .CoreData), let device = device as? Device {
            id = device.cloudID
            try coreDataController.removeDevice(device)
        }
        if hasPermissionTo(access: .CloudKit), let device = cloudKitDataController.findDeviceBy(id: id ?? device.cloudID ?? UUID()) {
            cloudKitDataController.removeDevice(device)
        }
    }

    public func removeDeviceAt(_ index: Int) throws {
        if hasPermissionTo(access: .CoreData){
            try coreDataController.removeDeviceAt(index)
        }
        if hasPermissionTo(access: .CloudKit) {
            cloudKitDataController.removeDeviceAt(index)
        }
    }

    public func deleteCloudData() {
        cloudKitDataController.removeDevices(cloudKitDataController.devices)
    }

    //MARK: Watchers
    private var watchers: [DataWatcher] = []
    public func addAsWatcher(_ watcher: DataWatcher) {
        watchers.append(watcher)
    }
    public func removeAsWatcher(_ watcher: DataWatcher) {
        if let index = watchers.firstIndex(where: { (comp) -> Bool in
            return watcher == comp
        }) {
            watchers.remove(at: index)
        }
    }

    public var conflictHandler: ConflictHandler = DefaultConflictHandler()

    //MARK: Singleton Basic Properties
    private init() {
    }

    public class func shared(with permit: DataPermission) -> DataManager {
        if permit != sharedDataController.permission {
            sharedDataController.permission = permit
        }
        return sharedDataController
    }

    private static var sharedDataController: DataManager = {
        let dController = DataManager()
        return dController
    }()
}
