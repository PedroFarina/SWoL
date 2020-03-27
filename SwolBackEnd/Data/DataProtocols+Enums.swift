//
//  DataProtocols+Enums.swift
//  SwolBackEnd
//
//  Created by Pedro Giuliano Farina on 26/03/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import CloudKit

public enum DataPermission: Int {
    case CoreData = 1
    case CloudKit = 2
    case Both = 3
}
public protocol DataWatcher: NSObject {
    func dataUpdated()
}

public enum CDError: Error {
    case FailedToParseObject(reason: String)
    case FailedToSaveContext(reason: String)
}
public enum DataVersion {
    case Local
    case Cloud
}
public protocol ConflictHandler {
    func chooseVersion() -> DataVersion
    func errDidOccur(err: Error)
}
public struct DefaultConflictHandler: ConflictHandler {
    public func errDidOccur(err: Error) {
        fatalError(err.localizedDescription)
    }

    public func chooseVersion() -> DataVersion {
        return .Local
    }
}

internal protocol DataSynchronizer {
    func dataChanged(to devices: [DeviceProtocol], in system: DataPermission)
}
