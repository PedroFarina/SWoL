//
//  DevicePageViewController.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 22/02/21.
//  Copyright © 2021 Pedro Giuliano Farina. All rights reserved.
//

import UIKit
import SwolBackEnd

internal class DevicesPageViewController: UIPageViewController, DeviceHolderDelegate, DataWatcher {
    private lazy var devicesDataSource = DevicesPageViewControllerDataSource(delegate: self)
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
            } else {
                setViewControllers(nil, direction: .forward, animated: false, completion: nil)
            }
        }
    }

    func wakeDevice(_ device: DeviceProtocol) {
        func wakeAction(device: DeviceProtocol, usingUDP: Bool) {
            if let err = Awake.target(device: device, usingUDP: usingUDP) {
                // TODO: Animation
                DispatchQueue.main.async {
                    var message = err.localizedDescription
                    if let wakeErr = err as? Awake.WakeError {
                        switch wakeErr {
                        case .DeviceIncomplete(let reason):
                            message = "deviceIncomplete".localized() + " \( reason.localizedDescription)"
                        case .SendMagicPacketFailed(let reason):
                            message = "magicPacketFailed".localized() + " \( reason.localizedDescription)"
                        case .SetSocketOptionsFailed(let reason):
                            message = "socketOptionsFailed".localized() + " \( reason.localizedDescription)"
                        case .SocketSetupFailed(let reason):
                            message = "socketSetupFailed".localized() + " \( reason.localizedDescription)"
                        }
                    }
                    let error = UIAlertController(title: "Error!".localized(), message: message, preferredStyle: .alert)
                    error.addOkAction()
                    self.parent?.present(error, animated: true)
                }
            } else {
                // TODO: Animation
            }
        }

        if AccessManager.packetShouldAskPath {
            if (device.externalAddress) != nil {
                let cont = UIAlertController(title: "Where to?".localized(), message: "To which IP do you want to send the message?".localized(), preferredStyle: .alert)
                cont.addAction(UIAlertAction(title: "Internal".localized(), style: .default, handler: { (_) in
                    wakeAction(device: device, usingUDP: false)
                }))
                cont.addAction(UIAlertAction(title: "External".localized(), style: .default, handler: { (_) in
                    wakeAction(device: device, usingUDP: true)
                }))
                self.present(cont, animated: true, completion: nil)
            } else {
                wakeAction(device: device, usingUDP: false)
            }
        } else {
            wakeAction(device: device, usingUDP: true)
            wakeAction(device: device, usingUDP: false)
        }
    }

    func shareDevice(_ device: DeviceProtocol) {

    }

    func editDevice(_ device: DeviceProtocol) {

    }
}
