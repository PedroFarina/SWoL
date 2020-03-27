//
//  DeviceEntity.swift
//  SwolBackEnd
//
//  Created by Pedro Giuliano Farina on 26/03/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import CloudKit

public class DeviceEntity: NSObject, EntityObject, DeviceProtocol {
    public static let recordType: String = "Device"
    public private(set) var record: CKRecord

    public internal(set) var _address: DataProperty<String>
    public internal(set) var _mac: DataProperty<String>
    public internal(set) var _name: DataProperty<String>
    public internal(set) var _port: DataProperty<Int64>

    init(record: CKRecord) {
        self.record = record
        _address = DataProperty(record: record, key: "address")
        _mac = DataProperty(record: record, key: "mac")
        _name = DataProperty(record: record, key: "name")
        _port = DataProperty(record: record, key: "port")
        super.init()
    }

    internal convenience init(id: UUID, address: String, mac: String, name: String, port: Int64) {
        self.init(id)
        _address.value = address
        _mac.value = mac
        _name.value = name
        _port.value = port
    }

    internal convenience init(_ id: UUID) {
        let record = CKRecord(recordType: DeviceEntity.recordType, recordID: CKRecord.ID(recordName: id.uuidString))
        self.init(record: record)
    }

    public var address: String? {
        return _address.value
    }
    public var mac: String? {
        return _mac.value
    }
    public var name: String? {
        return _name.value
    }
    public var port: Int32 {
        return Int32(_port.value)
    }
    public var cloudID: UUID? {
        return UUID(uuidString: record.recordID.recordName)
    }

    public func getBroadcast() -> String? {
        let address = _address.value
        var newAddress = ""
        let groups = address.components(separatedBy: ".")

        for i in 0..<min(3, groups.count) {
            newAddress += "\(groups[i])."
        }
        newAddress += "255"
        return newAddress
    }
}

infix operator <>
extension DeviceEntity {
    public static func <>(left: DeviceEntity, right: Device) -> Bool {
        return (left.address != right.address) || (left.mac != right.mac) || (left.name != right.name) ||
            (left.port != right.port) || (left.cloudID != right.cloudID)
    }
    public static func <>(left: Device, right: DeviceEntity) -> Bool {
        return (left.address != right.address) || (left.mac != right.mac) || (left.name != right.name) ||
            (left.port != right.port) || (left.cloudID != right.cloudID)
    }
}
