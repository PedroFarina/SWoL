//
//  DeviceHolderDelegate.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 26/02/21.
//  Copyright © 2021 Pedro Giuliano Farina. All rights reserved.
//

import UIKit
import SwolBackEnd

internal protocol DeviceHolderDelegate: class {
    func editDevice(_ device: DeviceProtocol)
    func shareDevice(_ device: DeviceProtocol)
    func wakeDevice(_ device: DeviceProtocol)
}
