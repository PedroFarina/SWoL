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
        let cont = UIAlertController(title: "Are you sure?", message: "This action will delete all your devices from iCloud. It can't be undone.".localized(), preferredStyle: .alert)
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
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
