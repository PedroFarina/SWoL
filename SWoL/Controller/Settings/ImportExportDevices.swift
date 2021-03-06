//
//  ImportExportDevices.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 28/12/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import UIKit
import SwolBackEnd

public class ImportExportDevices {

    public static func importDevicesViewController(completionHandler: @escaping (Bool) -> Void) -> UIViewController {
        let alertController = UIAlertController(title: "Enter the new devices".localized(),
                                                message: "This text can be generated by exporting the devices.".localized(),
                                                preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        alertController.addAction(UIAlertAction(title: "Add".localized(),
                                                style: .default,
                                                handler: { [weak alertController] (_) in
                                                    do {
                                                        let jsonDecoder = JSONDecoder()
                                                        guard let jsonString = alertController?.textFields?.first?.text,
                                                              let jsonData = jsonString.data(using: .utf8),
                                                              let devices = try? jsonDecoder.decode([CodableDevice].self, from: jsonData) else {
                                                            completionHandler(false)
                                                            return
                                                        }
                                                        for device in devices {
                                                            if let name = device.name,
                                                               let address = device.address,
                                                               let mac = device.mac {
                                                                try? DataManager.shared(with: AccessManager.cloudKitPermission).registerDevice(
                                                                    name: name,
                                                                    address: address,
                                                                    externalAddress: device.externalAdress,
                                                                    macAddress: mac,
                                                                    port: device.port)
                                                            }
                                                        }
                                                        completionHandler(true)
                                                    }
                                                }))
        alertController.addCancelAction()
        return alertController
    }

    public static func exportDevicesViewController() -> UIViewController {
        let jsonEncoder = JSONEncoder()
        let devicesString: String?
        if let jsonData = try? jsonEncoder.encode(DataManager.shared(with: AccessManager.cloudKitPermission).codableDevices),
           let json = String(data: jsonData, encoding: .utf8) {
            devicesString = json
        } else {
            devicesString = nil
        }
        if let devicesString = devicesString, devicesString.count != 2 {
            UIPasteboard.general.string = devicesString
            return UIActivityViewController(activityItems: [devicesString], applicationActivities: nil)
        } else {
            let alertController = UIAlertController(title: "Oops!".localized(),
                                                    message: "You have no devices yet. Create one to export.".localized(),
                                                    preferredStyle: .alert)
            alertController.addOkAction()
            return alertController
        }
    }
}
