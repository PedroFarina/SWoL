//
//  Permission.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 27/03/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import Foundation
import SwolBackEnd

public class iCloudAccessManager {
    private init() {
    }

    private static let userDefaults = UserDefaults.standard
    public static var isEnabled: Bool {
        get {
            return userDefaults.bool(forKey: UserDefaultsNames.iCloudEnabled.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultsNames.iCloudEnabled.rawValue)
            _ = DataManager.shared(with: permission)
        }
    }

    public static var permission: DataPermission {
        return isEnabled ? .Both : .CoreData
    }
}
