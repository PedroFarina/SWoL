//
//  DevicesCollectionViewDataSource.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 21/02/21.
//  Copyright © 2021 Pedro Giuliano Farina. All rights reserved.
//

import UIKit
import SwolBackEnd

internal class DevicesCollectionDataSource: NSObject, UICollectionViewDataSource {
    private var devices = DataManager.shared(with: AccessManager.cloudKitPermission).devices

    internal func needsUpdate() {
        devices = DataManager.shared(with: AccessManager.cloudKitPermission).devices
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return devices.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DeviceCollectionViewCell.cellID, for: indexPath) as? DeviceCollectionViewCell {
            cell.device = devices[indexPath.row]
            cell.setup()
            return cell
        }
        fatalError("No cell")
    }

    func isEmpty() -> Bool {
        return devices.isEmpty
    }
}
