//
//  DeviceEntity+Intents.swift
//  SwolBackEnd
//
//  Created by Pedro Giuliano Farina on 26/03/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import Intents

extension DeviceEntity {
    public var intent: WakeDeviceIntent {
        let wakeUp = WakeDeviceIntent()
        wakeUp.name = name

        wakeUp.suggestedInvocationPhrase = "Wake up time".localized()

        return wakeUp
    }

    public static func getDevice(from intent: WakeDeviceIntent) -> DeviceProtocol? {
        return DataManager.shared(with: .CloudKit).devices.first { (dev) -> Bool in
            return dev.name?.uppercased() == intent.name?.uppercased()
        }
    }
}
