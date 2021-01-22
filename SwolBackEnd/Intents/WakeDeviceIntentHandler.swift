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
        let usesUDP = (intent.useExternalAddress ?? 0) == true

        let userActivity = NSUserActivity(activityType: NSUserActivity.wakeDeviceActivityType)
        userActivity.title = "Start up".localized() + " \(device.name ?? "")"
        userActivity.suggestedInvocationPhrase = "Start up device".localized()
        userActivity.isEligibleForPrediction = true
        userActivity.isEligibleForSearch = true

        let response: WakeDeviceIntentResponse
        if let deviceName = device.name,
           let address = usesUDP ? device.externalAddress : device.address {
            userActivity.persistentIdentifier = device.mac
            userActivity.addUserInfoEntries(from: [NSUserActivity.ActivityKeys.name.rawValue: deviceName])
            if Awake.target(device: device, usingUDP: usesUDP) != nil {
                response = WakeDeviceIntentResponse.failureAddress(name: deviceName, address: address)
            } else {
                response = WakeDeviceIntentResponse.success(name: deviceName, address: address)
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

    public func resolveUseExternalAddress(for intent: WakeDeviceIntent, with completion: @escaping (INBooleanResolutionResult) -> Void) {
        if let usesExternalAddress = intent.useExternalAddress {
            completion(INBooleanResolutionResult.success(with: usesExternalAddress == true ))
        } else {
            completion(INBooleanResolutionResult.confirmationRequired(with: false))
        }
    }
}
