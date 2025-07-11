//
//  Permission.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 27/03/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import Foundation
import SwolBackEnd

public class AccessManager {
    private init() {
    }

    private static let userDefaults = UserDefaults.standard
    public static var isCloudKitEnabled: Bool {
        get {
            return userDefaults.bool(forKey: UserDefaultsNames.iCloudEnabled.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultsNames.iCloudEnabled.rawValue)
            _ = DataManager.shared(with: cloudKitPermission)
        }
    }

    public static var cloudKitPermission: DataPermission {
        return isCloudKitEnabled ? .Both : .CoreData
    }

    public static var terminationPopupAcknowledged: Bool {
        get {
            return userDefaults.bool(forKey: UserDefaultsNames.terminationPopupAcknowledged.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultsNames.terminationPopupAcknowledged.rawValue)
        }
    }

    public static var newSwolPopupAcknowledged: Bool {
        get {
            return userDefaults.bool(forKey: UserDefaultsNames.newSwolPopupAcknowledged.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultsNames.newSwolPopupAcknowledged.rawValue)
        }
    }
}
