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

public enum DataPermission: Int {
    case CoreData = 1
    case CloudKit = 2
    case Both = 3
}

public protocol DataWatcher: NSObject {
    func dataUpdated()
}

public class DataManager: DataSynchronizer {

    //MARK: Synchronization and permission
    private var permission: DataPermission? {
        didSet {
            fetch()
        }
    }
    private func hasPermissionTo(access permission: DataPermission) -> Bool {
        return ((self.permission?.rawValue ?? 0) & permission.rawValue) == permission.rawValue
    }
    lazy var coreDataController: CoreDataController = CoreDataController(synchronizer: self)

    private func fetch() {
        if hasPermissionTo(access: .CoreData) {
            do {
                try coreDataController.fetchData()
            } catch {
                fatalError("Could no communicate with CoreData")
            }
        }
    }

    func dataChanged(to devices: [DeviceProtocol]) {
        if hasPermissionTo(access: .Both) && (devices as? [Device]) == nil {
            return
        }
        self._devices = devices
    }

    //MARK: Devices
    private var _devices: [DeviceProtocol] = [] {
        didSet {
            for watcher in watchers {
                watcher.dataUpdated()
            }
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
        if hasPermissionTo(access: .CoreData) {
            try coreDataController.registerDevice(name: name, address: address, macAddress: macAddress, port: port)
        }
        if hasPermissionTo(access: .CloudKit) {
            //Cria no CloudKit também
        }
    }

    public func editDevice(_ device:DeviceProtocol, newName name: String?, newAddress address: String?,
                           newMacAddress macAddress: String?,
                           newPort port: Int32?) throws {
        if hasPermissionTo(access: .CoreData), let device = device as? Device {
            try coreDataController.editDevice(device, newName: name, newAddress: address, newMacAddress: macAddress, newPort: port)
        }
        if hasPermissionTo(access: .CloudKit) {
            //Edita no CloudKit também
        }
    }

    public func removeDevice(_ device: DeviceProtocol) throws {
        if hasPermissionTo(access: .CoreData), let device = device as? Device {
            try coreDataController.removeDevice(device)
        }
        if hasPermissionTo(access: .CloudKit) {
            //Remove do CloudKit também
        }
    }

    public func removeDeviceAt(_ index: Int) throws {
        if hasPermissionTo(access: .CoreData){
            try coreDataController.removeDeviceAt(index)
        }
        if hasPermissionTo(access: .CloudKit) {
            //Remove do CloudKit também
        }
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

    //MARK: Singleton Basic Properties
    private init() {
    }

    public class func shared(with permit: DataPermission = .Both) -> DataManager {
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
