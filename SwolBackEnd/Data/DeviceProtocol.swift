//
//  DeviceProtocol.swift
//  SwolBackEnd
//
//  Created by Pedro Giuliano Farina on 26/03/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import Foundation

public protocol DeviceProtocol {
    var address: String? { get }
    var mac: String? { get }
    var name: String? { get }
    var port: Int32 { get }
    var cloudID: UUID? { get }

    func getBroadcast() -> String?

    var intent: WakeDeviceIntent { get }
    static func getDevice(from intent: WakeDeviceIntent) -> DeviceProtocol?
}

public extension DeviceProtocol {
    func toCodable() -> CodableDevice {
        return CodableDevice(address: address, mac: mac, name: name, port: port)
    }
}

public struct CodableDevice: Codable {
    var address: String?
    var mac: String?
    var name: String?
    var port: Int32?
}
