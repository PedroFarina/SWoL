//
//  DevicesMenuController.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 02/04/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import UIKit
import SwolBackEnd
import StoreKit

public class DevicesMenuController: UIViewController {
    weak var tableViewController: DevicesTableViewController?
    var selectedDevice: DeviceProtocol? {
        return tableViewController?.selectedDevice
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        if !UserDefaults.standard.bool(forKey: "tutorial") {
            UserDefaults.standard.set(true, forKey: "tutorial")
            self.performSegue(withIdentifier: "tutorial", sender: self)
        }
        let numberOfTimes = UserDefaults.standard.integer(forKey: "numberOfTimes")
        if numberOfTimes >= 5 {
            SKStoreReviewController.requestReview()
        } else {
            UserDefaults.standard.setValue(numberOfTimes + 1, forKey: "numberOfTimes")
        }
    }

    @IBAction func newDeviceTap(_ sender: Any) {
        self.performSegue(withIdentifier: "newDevice", sender: self)
    }

    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cont = segue.destination as? DevicesTableViewController {
            self.tableViewController = cont
        } else if let nav = segue.destination as? UINavigationController,
            let view = nav.topViewController as? AddingDeviceTableViewController {
            view.device = selectedDevice
        }
    }
}
