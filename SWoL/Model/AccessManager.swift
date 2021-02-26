//
//  Permission.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 27/03/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import Foundation
import SwolBackEnd

internal class AccessManager {
    private init() {
    }

    private static let userDefaults = UserDefaults.standard
    internal static var isCloudKitEnabled: Bool {
        get {
            return userDefaults.bool(forKey: UserDefaultsNames.iCloudEnabled.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultsNames.iCloudEnabled.rawValue)
            _ = DataManager.shared(with: cloudKitPermission)
        }
    }
    internal static var cloudKitPermission: DataPermission {
        return isCloudKitEnabled ? .Both : .CoreData
    }

    internal static var packetShouldAskPath: Bool {
        get {
            return userDefaults.bool(forKey: UserDefaultsNames.packetShouldAskPath.rawValue)
        }
        set {
            userDefaults.setValue(newValue, forKey: UserDefaultsNames.packetShouldAskPath.rawValue)
        }
    }
}
