//
//  DevicesTableViewController.swift
//  SWoL
//
//  Created by Pedro Giuliano Farina on 04/01/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import UIKit
import SwolBackEnd

public class DevicesTableViewController: UITableViewController, DataWatcher {

    public private(set) var devices: [DeviceProtocol] = DataManager.shared(with: AccessManager.cloudKitPermission).devices
    public private(set) var selectedDevice: DeviceProtocol?

    public override func viewDidLoad() {
        tableView.tableFooterView = UIView()
        navigationItem.leftBarButtonItem = self.editButtonItem
    }
    public override func viewWillDisappear(_ animated: Bool) {
        DataManager.shared(with: AccessManager.cloudKitPermission).removeAsWatcher(self)
    }
    public override func viewWillAppear(_ animated: Bool) {
        DataManager.shared(with: AccessManager.cloudKitPermission).addAsWatcher(self)
        updateData()
    }

    public func dataUpdated() {
        updateData()
    }

    private func updateData() {
        devices = DataManager.shared(with: AccessManager.cloudKitPermission).devices
        tableView.reloadData()
    }

    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.isEmpty ? 1 : devices.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if devices.isEmpty {
            let cell = UITableViewCell()
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.text = "You have no devices yet.\nPlease tap on '+' to create one.".localized()
            cell.isUserInteractionEnabled = false
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell") else {
            return UITableViewCell()
        }
        cell.textLabel?.text = devices[indexPath.row].name
        cell.detailTextLabel?.text = devices[indexPath.row].mac
        cell.isUserInteractionEnabled = true
        return cell
    }

    override public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !devices.isEmpty
    }

    public override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let delete = UIContextualAction(style: .destructive, title: "Delete".localized()) { (_, _, success) in
            DispatchQueue.main.async {
                self.deleteAction(on: self.devices[indexPath.row])
                success(true)
            }
        }

        let edit = UIContextualAction(style: .normal, title: "Edit".localized()) { (_, _, success) in
            DispatchQueue.main.async {
                self.editAction(on: self.devices[indexPath.row])
                success(true)
            }
        }
        edit.backgroundColor = .systemOrange

        let config = UISwipeActionsConfiguration(actions: [delete, edit])
        config.performsFirstActionWithFullSwipe = true
        return config
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            editAction(on: devices[indexPath.row])
        } else {
            wakeAction(on: devices[indexPath.row])
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func deleteAction(on device: DeviceProtocol) {
        let cont = UIAlertController(title: "Deletion confirmation".localized(), message: "Do you want to delete ".localized() + (device.name ?? "John".localized()), preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes".localized(), style: .destructive) { (_) in
            do {
                try DataManager.shared(with: AccessManager.cloudKitPermission).removeDevice(device)
            } catch let err {
                DispatchQueue.main.async {
                    let error = UIAlertController(title: "Error!".localized(), message: err.localizedDescription, preferredStyle: .alert)
                    error.addOkAction()
                    self.parent?.present(error, animated: true)
                }
            }
        }
        let no = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)
        cont.addAction(yes)
        cont.addAction(no)
        self.parent?.present(cont, animated: true)
    }

    private func editAction(on device:  DeviceProtocol) {
        selectedDevice = device
        self.parent?.performSegue(withIdentifier: "newDevice", sender: self)
        selectedDevice = nil
    }

    private func wakeAction(on device: DeviceProtocol) {
        let cont = UIAlertController(title: "Waking confirmation".localized(), message: "Do you want to wake ".localized() + (device.name ?? "John".localized()) + "?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes".localized(), style: .default) { (_) in
            if let err = Awake.target(device: device, usingUDP: false) {
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
                DispatchQueue.main.async {
                    let success = UIAlertController(title: "Success".localized(), message: "Packet sent to ".localized() + (device.address ?? ""), preferredStyle: .alert)
                    success.addOkAction()
                    self.parent?.present(success, animated: true)
                }
            }
        }
        let no = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)
        cont.addAction(yes)
        cont.addAction(no)
        self.parent?.present(cont, animated: true)
    }
}
