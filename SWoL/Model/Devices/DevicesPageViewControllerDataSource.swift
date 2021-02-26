//
//  DevicesPageViewControllerDataSource.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 22/02/21.
//  Copyright © 2021 Pedro Giuliano Farina. All rights reserved.
//

import UIKit
import SwolBackEnd

internal class DevicesPageViewControllerDataSource: NSObject, UIPageViewControllerDataSource {
    private var devices = DataManager.shared(with: AccessManager.cloudKitPermission).devices
    internal var firstViewController: UIViewController? { devicesVC.first }
    private var devicesVC: [UIViewController] = []
    private weak var delegate: DeviceHolderDelegate?

    init(delegate: DeviceHolderDelegate) {
        super.init()
        self.delegate = delegate
        self.createViewControllers()
    }

    internal func needsUpdate() {
        devices = DataManager.shared(with: AccessManager.cloudKitPermission).devices
        createViewControllers()
    }

    internal func createViewControllers() {
        devicesVC = devices.map({
            let deviceVC = DeviceViewController()
            deviceVC.device = $0
            deviceVC.delegate = delegate
            return deviceVC
        })
    }

    func isEmpty() -> Bool {
        return devices.isEmpty
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = devicesVC.firstIndex(of: viewController), index > 0 {
            return devicesVC[index - 1]
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = devicesVC.firstIndex(of: viewController), index < devicesVC.count - 1 {
            return devicesVC[index + 1]
        }
        return nil
    }
}
