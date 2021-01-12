//
//  TabBarController.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 27/03/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import UIKit
import CloudKit
import SwolBackEnd
import Foundation
import NotificationCenter

public class SwolTabBarController: UITabBarController, ConflictHandler {

    public func chooseVersion(completionHandler: @escaping (DataVersion) -> Void) {
        guard let cont = selectedViewController else {
            completionHandler(.Cloud)
            return
        }

        let alert = UIAlertController(title: "The cloud data are different from local data!".localized(), message: "There was a conflict in the data from the cloud.".localized(), preferredStyle: .alert)
        let localAction = UIAlertAction(title: "Keep local data".localized(), style: .destructive, handler: {(_) in
            completionHandler(.Local)
        })
        let cloudAction = UIAlertAction(title: "Keep cloud data".localized(), style: .destructive, handler: {(_) in
            completionHandler(.Cloud)
        })

        alert.addAction(localAction)
        alert.addAction(cloudAction)
        cont.present(alert, animated: true)
    }

    public func errDidOccur(err: Error) {
        guard let cont = selectedViewController else {
            return
        }
        if let ckError = err as? CKError, let alert = ckError.getAlert() {
            cont.present(alert, animated: true)
        } else if let cdError = err as? CDError {
            cont.present(cdError.getAlert(), animated: true)
        } else {
            let alert = UIAlertController(title: "Unkown Error!".localized(), message: err.localizedDescription, preferredStyle: .alert)
            alert.addOkAction()
            cont.present(alert, animated: true)
        }
    }

    public override func viewDidLoad() {
        DataManager.shared(with: AccessManager.cloudKitPermission).conflictHandler = self
    }
}

extension CDError {
    public func getAlert() -> UIAlertController {
        return CDError.failAlert
    }

    private static var failAlert: UIAlertController {
        let alert = UIAlertController(title: "Error!".localized(), message: "Unable to save data locally!".localized(), preferredStyle: .alert)
        alert.addOkAction()
        return alert
    }
}

extension CKError {
    public func getAlert() -> UIAlertController? {
        switch self.code {
        case  .notAuthenticated:
            return CKError.notAuthenticatedAlert
        case .networkFailure, .networkUnavailable:
            return CKError.noNetworkAlert
        default :
            return nil
        }
    }

    private static var notAuthenticatedAlert: UIAlertController {
        let alert = UIAlertController(
            title: "You are not connected to iCloud".localized(),
            message: "This app uses iCloud to synchronize your data accross devices.".localized() + " " +
                "To activate it, go into your device's Settings, iCloud, and sign in with your Apple ID.".localized(), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Deactivate iCloud Sync".localized(), style: .cancel, handler: { (_) in
            AccessManager.isCloudKitEnabled = false
        }))
        alert.addAction(UIAlertAction(title: "Open Settings".localized(), style: .default, handler: { (_) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))

        return alert
    }

    private static var noNetworkAlert: UIAlertController {
        let alert = UIAlertController(
            title: "Connection Error!".localized(),
            message: "Seems that you're not connected to the internet.".localized() + " " +
                "Your changes will not be saved to iCloud, but you can still use the app.".localized(), preferredStyle: .alert)

        alert.addOkAction()
        return alert
    }
}
