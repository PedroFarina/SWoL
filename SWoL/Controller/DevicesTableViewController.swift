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

    private var devices: [Device] = DataController.shared().devices
    private weak var selectedDevice: Device?

    public override func viewDidLoad() {
        tableView.tableFooterView = UIView()
        navigationItem.leftBarButtonItem = self.editButtonItem
    }
    public override func viewWillDisappear(_ animated: Bool) {
        DataController.shared().removeAsWatcher(self)
    }
    public override func viewWillAppear(_ animated: Bool) {
        DataController.shared().addAsWatcher(self)
        updateData()
    }

    public func dataUpdated() {
        updateData()
    }

    private func updateData() {
        devices = DataController.shared().devices
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

    public override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        self.performSegue(withIdentifier: "detailTap", sender: self)
    }

    private func deleteAction(on device: Device) {
        let cont = UIAlertController(title: "Deletion confirmation".localized(), message: "Do you want to delete ".localized() + (device.name ?? "John".localized()), preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes".localized(), style: .destructive) { (_) in
            do {
                try DataController.shared().removeDevice(device)
            } catch let err {
                DispatchQueue.main.async {
                    let error = UIAlertController(title: "Error!".localized(), message: err.localizedDescription, preferredStyle: .alert)
                    error.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(error, animated: true)
                }
            }
        }
        let no = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)
        cont.addAction(yes)
        cont.addAction(no)
        self.present(cont, animated: true)
    }

    private func editAction(on device:  Device) {
        selectedDevice = device
        self.performSegue(withIdentifier: "newDevice", sender: self)
        selectedDevice = nil
    }

    private func wakeAction(on device: Device) {
        let cont = UIAlertController(title: "Waking confirmation".localized(), message: "Do you want to wake ".localized() + (device.name ?? "John") + "?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes".localized(), style: .default) { (_) in
            if let err = Awake.target(device: device) {
                DispatchQueue.main.async {
                    let error = UIAlertController(title: "Error!".localized(), message: err.localizedDescription, preferredStyle: .alert)
                    error.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(error, animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    let success = UIAlertController(title: "Success".localized(), message: "Packet sent to ".localized() + (device.getBroadcast() ?? ""), preferredStyle: .alert)
                    success.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(success, animated: true)
                }
            }
        }
        let no = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)
        cont.addAction(yes)
        cont.addAction(no)
        self.present(cont, animated: true)
    }

    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController,
            let view = nav.topViewController as? AddingDeviceTableViewController {
            view.device = selectedDevice
        }
    }
}