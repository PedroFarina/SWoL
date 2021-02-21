//
//  DeviceCollectionViewCell.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 21/02/21.
//  Copyright © 2021 Pedro Giuliano Farina. All rights reserved.
//

import UIKit
import SwolBackEnd

internal class DeviceCollectionViewCell: UICollectionViewCell {
    internal static let cellID = "deviceCell"
    internal weak var device: DeviceProtocol?

    internal func setup() {
        backgroundColor = .red
    }
}
