//
//  DeviceEntity+Intents.swift
//  SwolBackEnd
//
//  Created by Pedro Giuliano Farina on 26/03/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import Intents

extension DeviceEntity {

    public func getIntent(completionHandler: @escaping (WakeDeviceIntent) -> Void) {
        INVoiceShortcutCenter.shared.getAllVoiceShortcuts { [weak self] (shortcuts, error) in
            if let voiceShortcut = shortcuts?.first(where: { ($0.shortcut.intent as? WakeDeviceIntent)?.name == self?.name }),
               let intent = voiceShortcut.shortcut.intent as? WakeDeviceIntent {
                completionHandler(intent)
            } else {
                let wakeUp = WakeDeviceIntent()
                wakeUp.name = self?.name
                wakeUp.suggestedInvocationPhrase = "Start up".localized() + " \(self?.name ?? "")"

                completionHandler(wakeUp)
            }
        }
    }

    public static func getDevice(from intent: WakeDeviceIntent) -> DeviceProtocol? {
        return DataManager.shared(with: .CloudKit).devices.first { (dev) -> Bool in
            return dev.name?.uppercased() == intent.name?.uppercased()
        }
    }
}
