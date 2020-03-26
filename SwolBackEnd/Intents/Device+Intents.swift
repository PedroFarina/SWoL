//
//  Device + Intents.swift
//  SWoLIntents
//
//  Created by Pedro Giuliano Farina on 06/01/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import Intents

extension Device {
    public var intent: WakeDeviceIntent {
        let wakeUp = WakeDeviceIntent()
        wakeUp.name = name

        wakeUp.suggestedInvocationPhrase = "Wake up time".localized()

        return wakeUp
    }

    public static func getDevice(from intent: WakeDeviceIntent) -> DeviceProtocol? {
        return DataManager.shared(with: .CoreData).devices.first { (dev) -> Bool in
            return dev.name?.uppercased() == intent.name?.uppercased()
        }
    }
}
