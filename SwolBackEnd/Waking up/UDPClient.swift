//
//  UDPClient.swift
//  SwolBackEnd
//
//  Created by Pedro Giuliano Farina on 12/01/21.
//  Copyright © 2021 Pedro Giuliano Farina. All rights reserved.
//

import Foundation
import Network

typealias UDPPermission = Bool

internal class UDPClient {
    private static var connection: NWConnection?

    private static var resultHandler = NWConnection.SendCompletion.contentProcessed { NWError in
        if let err = NWError {
            DataManager.shared(with: .CoreData).conflictHandler.errDidOccur(err: err)
        }
        connection?.cancel()
    }

    private init() {
    }

    internal static func sendWakePacket(to device: DeviceProtocol) -> Error? {
        guard let mac = device.mac else {
            let err = NSError(domain: "Device Incomplete Error", code: Int(errSecParam), userInfo: nil)
            return Awake.WakeError.DeviceIncomplete(reason: err)
        }
        
        do {
            let data = Data(try Awake.createMagicPacket(mac: mac))
            defer {
                send(data)
            }
            return connectTo(device: device)
        } catch {
            return error
        }
    }

    private static func connectTo(device: DeviceProtocol) -> NSError? {
        guard let newAddress = device.address,
            let codedPort = NWEndpoint.Port(rawValue: NWEndpoint.Port.RawValue(device.port)) else {
            let err = NSError(domain: "Port Error", code: Int(errSecParam), userInfo: nil)
            return err
        }
        let address: NWEndpoint.Host
        if let codedAddress = IPv4Address(newAddress) {
            address = .ipv4(codedAddress)
        } else {
            address = .name(newAddress, .none)
        }
        connection = NWConnection(host: address, port: codedPort, using: .udp)

        connection?.start(queue: .global())
        return nil
    }

    private static func send(_ data: Data) {
        connection?.send(content: data, completion: resultHandler)
    }
}
