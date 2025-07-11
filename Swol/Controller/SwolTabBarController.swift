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
import StoreKit
import SafariServices
import NotificationCenter

public class SwolTabBarController: UITabBarController, ConflictHandler, SKStoreProductViewControllerDelegate {

    func terminatedAppPopup() {
        guard let url = URL(string: "https://apps.apple.com/br/developer/pedro-giuliano-farina/id1473472102") else { return }

        DispatchQueue.main.async { [self] in
            guard let cont = selectedViewController else { return }
            loadURLAndShowPopup(url: url) { safariViewController in
                if !AccessManager.terminationPopupAcknowledged {
                    let alert = UIAlertController(
                        title: "Big news!".localized(),
                        message: "This app will soon be removed from the app store. There'll be a new version available for iOS + macOS 26 as soon as possible with the new Glass effect!".localized(),
                        preferredStyle: .alert
                    )

                    let downloadAction = UIAlertAction(
                        title: "Bookmark the developer apps".localized(),
                        style: .default) { _ in
                            cont.present(safariViewController, animated: true)
                        }

                    let acknowledgeAction = UIAlertAction(
                        title: "Don't show this again".localized(),
                        style: .destructive) { _ in
                            AccessManager.terminationPopupAcknowledged = true
                        }
                    alert.addAction(acknowledgeAction)
                    alert.addAction(downloadAction)
                    DispatchQueue.main.async {
                        cont.present(alert, animated: true)
                    }
                }
            }
        }
    }

    func popNewAppAlert() {
        let gistLink = "https://gist.githubusercontent.com/PedroFarina/5fa4993ac80bc766ebc841ccf94095cc/raw/swol-id.txt"

        guard let url = URL(string: gistLink) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let data = data, let content = String(data: data, encoding: .utf8) {
                if let intId = Int(content) {
                    self?.loadAppAndShowPopup(id: NSNumber(value: intId))
                } else if let url = URL(string: content) {
                    self?.loadURLAndShowPopup(url: url) {
                        self?.showNewAppPopup(vc: $0)
                    }
                } else {
                    self?.terminatedAppPopup()
                }
            } else {
                self?.terminatedAppPopup()
            }
        }.resume()
    }

    private func loadAppAndShowPopup(id: NSNumber) {
        DispatchQueue.main.async {
            let vc = SKStoreProductViewController()
            vc.delegate = self

            let parameters = [SKStoreProductParameterITunesItemIdentifier: id]

            vc.loadProduct(withParameters: parameters) { [weak self] (loaded, error) in
                if loaded {
                    self?.showNewAppPopup(vc: vc)
                } else {
                    self?.terminatedAppPopup()
                }
            }
        }
    }
    private func loadURLAndShowPopup(url: URL, completion: @escaping (UIViewController) -> Void) {
        DispatchQueue.main.async {
            let vc = SFSafariViewController(url: url)
            completion(vc)
        }
    }

    private func showNewAppPopup(vc: UIViewController) {
        guard let cont = selectedViewController else { return }

        if !AccessManager.newSwolPopupAcknowledged {
            let alert = UIAlertController(
                title: "Great news!".localized(),
                message: "There's a new Swol app available for download! This version will not receive further updates and will soon leave the store. Try out the new version and leave some feedback!".localized(),
                preferredStyle: .alert
            )

            let downloadAction = UIAlertAction(
                title: "Try it now".localized(),
                style: .default) { _ in
                    DispatchQueue.main.async {
                        cont.present(vc, animated: true)
                    }
                }

            let acknowledgeAction = UIAlertAction(
                title: "Don't show this again".localized(),
                style: .destructive) { _ in
                    AccessManager.newSwolPopupAcknowledged = true
                }
            alert.addAction(acknowledgeAction)
            alert.addAction(downloadAction)
            DispatchQueue.main.async {
                cont.present(alert, animated: true)
            }
        } else {
            self.terminatedAppPopup()
        }
    }

    public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true)
    }


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
        popNewAppAlert()
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
