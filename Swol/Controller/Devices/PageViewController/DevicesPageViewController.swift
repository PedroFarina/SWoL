//
//  DevicePageViewController.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 22/02/21.
//  Copyright © 2021 Pedro Giuliano Farina. All rights reserved.
//

import UIKit
import SwolBackEnd

internal class DevicesPageViewController: UIPageViewController, DataWatcher {
    private let devicesDataSource = DevicesPageViewControllerDataSource()
    override func viewDidLoad() {
        self.dataSource = devicesDataSource
        setupViewControllers()
    }

    func dataUpdated() {
        let wasEmpty = devicesDataSource.isEmpty()
        devicesDataSource.needsUpdate()
        setupViewControllers(previousState: wasEmpty)
    }

    func setupViewControllers(previousState wasEmpty: Bool = true) {
        if wasEmpty, let deviceViewController = devicesDataSource.firstViewController {
            setViewControllers([deviceViewController], direction: .forward, animated: false)
        } else if devicesDataSource.isEmpty() {
            if let vc = storyboard?.instantiateViewController(identifier: "noDevices") {
                setViewControllers([vc], direction: .forward, animated: false, completion: nil)
            }
            setViewControllers(nil, direction: .forward, animated: false, completion: nil)
        }
    }
}
