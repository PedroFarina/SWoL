//
//  Awake.swift
//  SWoL
//
//  Created by Pedro Giuliano Farina on 03/01/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//
// code mainly from https://github.com/jesper-lindberg/Awake <- these guys are awesome

import Foundation
import Intents
import os.log

public class Awake {

    private static func donateInteraction(for device: Device) {
        let interaction = INInteraction(intent: device.intent, response: nil)
        if let mac = device.mac {
            interaction.identifier = mac
        }

        interaction.donate { (error) in
            if let error = error as NSError? {
                os_log("Interaction donation failed: %@", log: OSLog.default, type: .error, error)
            } else {
                os_log("Successfully donated interaction")
            }
        }
    }
    
    public enum WakeError: Error {
        case SocketSetupFailed(reason: String)
        case SetSocketOptionsFailed(reason: String)
        case SendMagicPacketFailed(reason: String)
        case DeviceIncomplete(reason: String)
    }

    public static func target(device: Device) -> Error? {
        donateInteraction(for: device)
        guard let broadcastAddress = device.getBroadcast(),
            let macAddress = device.mac else {
                return WakeError.DeviceIncomplete(reason: "")
        }
        let port = UInt16(device.port)

        var sock: Int32
        var target = sockaddr_in()

        target.sin_family = sa_family_t(AF_INET)
        target.sin_addr.s_addr = inet_addr(broadcastAddress)

        let isLittleEndian = Int(OSHostByteOrder()) == OSLittleEndian
        target.sin_port = isLittleEndian ? _OSSwapInt16(port) : port

        // Setup the packet socket
        sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
        if sock < 0 {
            let err = String(utf8String: strerror(errno)) ?? ""
            return WakeError.SocketSetupFailed(reason: err)
        }

        let packet = Awake.createMagicPacket(mac: macAddress)
        let sockaddrLen = socklen_t(MemoryLayout<sockaddr>.stride)
        let intLen = socklen_t(MemoryLayout<Int>.stride)

        // Set socket options
        var broadcast = 1
        if setsockopt(sock, SOL_SOCKET, SO_BROADCAST, &broadcast, intLen) == -1 {
            close(sock)
            let err = String(utf8String: strerror(errno)) ?? ""
            return WakeError.SetSocketOptionsFailed(reason: err)
        }

        // Send magic packet
        var targetCast = unsafeBitCast(target, to: sockaddr.self)
        if sendto(sock, packet, packet.count, 0, &targetCast, sockaddrLen) != packet.count {
            close(sock)
            let err = String(utf8String: strerror(errno)) ?? ""
            return WakeError.SendMagicPacketFailed(reason: err)
        }

        close(sock)

        return nil
    }

    private static func createMagicPacket(mac: String) -> [CUnsignedChar] {
        var buffer = [CUnsignedChar]()

        // Create header
        for _ in 1...6 {
            buffer.append(0xFF)
        }

        let components = mac.components(separatedBy: ":")
        let numbers = components.map {
            return strtoul($0, nil, 16)
        }

        // Repeat MAC address 16 times
        for _ in 1...16 {
            for number in numbers {
                buffer.append(CUnsignedChar(number))
            }
        }

        return buffer
    }
}
