//
//  NSUserActivities + IntentData.swift
//  SWoL
//
//  Created by Pedro Giuliano Farina on 06/01/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import Foundation
import MobileCoreServices

extension NSUserActivity {

    public enum ActivityKeys: String {
        case name
    }

    public static let wakeDeviceActivityType = "WakeDeviceIntent"
}

