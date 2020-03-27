//
//  WakeDeviceIntentHandler.swift
//  SWoLIntents
//
//  Created by Pedro Giuliano Farina on 06/01/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import Foundation
import Intents

public class WakeDeviceIntentHandler: NSObject, WakeDeviceIntentHandling {
    public func handle(intent: WakeDeviceIntent, completion: @escaping (WakeDeviceIntentResponse) -> Void) {
        guard let device = Device.getDevice(from: intent),
            let intentName = intent.name else {
                completion(WakeDeviceIntentResponse.failureNotFound(name: intent.name ?? ""))
                return
        }

        let userActivity = NSUserActivity(activityType: NSUserActivity.wakeDeviceActivityType)
        userActivity.title = "Start up a device".localized()
        userActivity.suggestedInvocationPhrase = "Start up device".localized()
        userActivity.persistentIdentifier = NSUserActivity.wakeDeviceActivityType
        userActivity.isEligibleForSearch = true

        let response: WakeDeviceIntentResponse
        if let deviceName = device.name,
            let broadcast = device.getBroadcast() {
            userActivity.addUserInfoEntries(from: [NSUserActivity.ActivityKeys.name.rawValue: deviceName])

            if Awake.target(device: device) != nil {
                response = WakeDeviceIntentResponse.failureAddress(name: deviceName, address: broadcast)
            } else {
                response = WakeDeviceIntentResponse.success(name: deviceName, address: broadcast)
            }
        } else {
            response = WakeDeviceIntentResponse.failureInsuficientData(name: intentName)
        }

        response.userActivity = userActivity
        completion(response)
    }

    public func resolveName(for intent: WakeDeviceIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let name = intent.name {
            completion(INStringResolutionResult.success(with: name))
        } else {
            completion(INStringResolutionResult.needsValue())
        }
    }


}
