//
//  AddingDeviceTableViewController.swift
//  SWoL
//
//  Created by Pedro Giuliano Farina on 04/01/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import UIKit
import SwolKit

public class AddingDeviceTableViewController: UITableViewController {

    public var mockTint: UIColor = {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    /// Return the color for Dark Mode
                    return #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1176470588, alpha: 1)
                } else {
                    /// Return the color for Light Mode
                    return #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.968627451, alpha: 1)
                }
            }
        } else {
            /// Return a fallback color for iOS 12 and lower.
            return #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.968627451, alpha: 1)
        }
    }()

    @IBOutlet weak var nameTableViewCell: TextTableViewCell!
    @IBOutlet weak var ipTableViewCell: TextTableViewCell!
    @IBOutlet weak var macTableViewCell: TextTableViewCell!
    @IBOutlet weak var portTableViewCell: TextTableViewCell!
    @IBOutlet weak var btnDone: UIBarButtonItem!
    @IBOutlet weak var footerTableViewCell: UITableViewCell!
    var footerText: String = "footer0".localized()

    public weak var device: Device?

    public override func viewDidLoad() {
        if let device = device {
            self.navigationItem.title = "Editing".localized()
            btnDone.title = "Save".localized()
            btnDone.isEnabled = true
            nameTableViewCell.txtText = device.name
            ipTableViewCell.txtText = device.address
            macTableViewCell.txtText = device.mac
            portTableViewCell.txtText = String(device.port)
            footerText = "footer7".localized()
        }
        ipTableViewCell.changedCharacters = checkDone(_:)
        macTableViewCell.changedCharacters = checkDone(_:)
        portTableViewCell.changedCharacters = checkDone(_:)
        footerTableViewCell.textLabel?.text = footerText
        footerTableViewCell.accessibilityLabel = footerText
        footerTableViewCell.accessibilityNavigationStyle = .combined
        footerTableViewCell.backgroundColor = mockTint
    }

    private func checkDone(_ text: String?) {
        var footerNum = 0
        if !(ipTableViewCell.txtText?.isEmpty ?? true) {
            footerNum += 1
        }
        if !(macTableViewCell.txtText?.isEmpty ?? true) {
            footerNum += 2
        }
        if !(portTableViewCell.txtText?.isEmpty ?? true) {
            footerNum += 4
        }
        footerText = "footer\(footerNum)".localized()
        if footerNum == 7 {
            if Int32(portTableViewCell.txtText ?? "") != nil {
                btnDone.isEnabled = true
            } else {
                footerText = "footer8".localized()
            }
        } else {
            btnDone.isEnabled = false
        }
        footerTableViewCell.textLabel?.tintColor = .lightGray
        footerTableViewCell.textLabel?.text = footerText
        footerTableViewCell.accessibilityLabel = footerText
    }

    @IBAction func doneTap(_ sender: UIBarButtonItem) {
        guard let name = nameTableViewCell.txtText,
            let ip = ipTableViewCell.txtText,
            var mac = macTableViewCell.txtText,
            let portString = portTableViewCell.txtText,
            let port = Int32(portString) else {
                return
        }
        mac = mac.replacingOccurrences(of: "-", with: ":").uppercased()
        do {
            if let device = device {
                try DataController.shared().editDevice(device, newName: name, newAddress: ip, newMacAddress: mac, newPort: port)
            } else {
                try DataController.shared().registerDevice(name: name, address: ip, macAddress: mac, port: port)
            }
            self.dismiss(animated: true)
        } catch let err {
            footerTableViewCell.textLabel?.tintColor = .red
            footerTableViewCell.textLabel?.text = err.localizedDescription
            UIAccessibility.post(notification: .announcement, argument: footerTableViewCell)
        }
    }
    @IBAction func cancelTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
