//
//  SettingsTableViewController.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 27/03/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import UIKit
import SwolBackEnd

public class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var iCloudTableViewCell: SwitchTableViewCell!
    private var deleteAlert: UIAlertController = {
        let cont = UIAlertController(title: "Are you sure?".localized(), message: "This action will delete all your devices from iCloud. It can't be undone.".localized(), preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes".localized(), style: .destructive) { (_) in
            DataManager.shared(with: iCloudAccessManager.permission).deleteCloudData()
        }
        let noAction = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)

        cont.addAction(yesAction)
        cont.addAction(noAction)
        return cont
    }()

    public override func viewDidLoad() {
        iCloudTableViewCell.onOffChanged = { (onOffSwitch) in
            iCloudAccessManager.isEnabled = onOffSwitch.isOn
        }
    }

    public override func viewWillAppear(_ animated: Bool){
        iCloudTableViewCell.onOff.isOn = iCloudAccessManager.isEnabled
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                iCloudTableViewCell.isOn = !iCloudTableViewCell.isOn
            } else if indexPath.row == 1 {
                self.present(deleteAlert, animated: true)
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                self.performSegue(withIdentifier: "tutorial", sender: self)
            }
        } else if indexPath.section == 2  {
            if indexPath.row == 0 {
                let alertController = ImportExportDevices.importDevicesViewController { [weak self] (success) in
                    let alert: UIAlertController
                    if success {
                        alert = UIAlertController(title: "Success".localized(),
                                                  message: "Successfully imported your devices".localized(),
                                                  preferredStyle: .alert)
                    } else {
                        alert = UIAlertController(title: "Oops!".localized(),
                                                  message: "Unable to import devices.".localized(),
                                                  preferredStyle: .alert)
                    }
                    alert.addOkAction()
                    DispatchQueue.main.async {
                        self?.present(alert, animated: true)
                    }
                }
                alertController.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath) ?? tableView
                self.present(alertController, animated: true)
            } else if indexPath.row == 1 {
                let controller = ImportExportDevices.exportDevicesViewController()
                controller.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath) ?? tableView
                self.present(controller, animated: true)
            }
        } else if indexPath.section == 3 {
            if indexPath.row == 0 {
                IAPHelper.shared.requestProducts { [weak self] success, products in
                    if let product = products?.first {
                        IAPHelper.shared.buyProduct(product)
                    } else {
                        let failAlert = UIAlertController(title: "Oops!".localized(),
                                                          message: "Unable to proccess your order.".localized(),
                                                          preferredStyle: .alert)
                        failAlert.addOkAction()
                        DispatchQueue.main.async {
                            self?.present(failAlert, animated: true)
                        }
                    }
                }
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
