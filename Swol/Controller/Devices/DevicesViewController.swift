//
//  DevicesViewController.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 21/02/21.
//  Copyright © 2021 Pedro Giuliano Farina. All rights reserved.
//

import UIKit
import SwolBackEnd

internal class DevicesViewController: UIViewController, DataWatcher {
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var devicesCollectionView: UICollectionView!
    private let collectionViewDataSource = DevicesCollectionDataSource()
    private lazy var collectionViewDelegate = DevicesCollectionViewDelegate(frame: { self.view.frame })

    override func viewDidLoad() {
        devicesCollectionView.isHidden = collectionViewDataSource.isEmpty()
        placeholderView.isHidden = !devicesCollectionView.isHidden

        devicesCollectionView.register(
            DeviceCollectionViewCell.self,
            forCellWithReuseIdentifier: DeviceCollectionViewCell.cellID)
        devicesCollectionView.allowsSelection = false
        devicesCollectionView.dataSource = collectionViewDataSource
        devicesCollectionView.delegate = collectionViewDelegate
    }

    func dataUpdated() {
        collectionViewDataSource.needsUpdate()
        devicesCollectionView.reloadData()
    }
}
