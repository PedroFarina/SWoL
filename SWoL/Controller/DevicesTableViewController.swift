//
//  DevicesTableViewController.swift
//  SWoL
//
//  Created by Pedro Giuliano Farina on 04/01/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import UIKit

public class DevicesTableViewController: UITableViewController, DataWatcher {

    private var devices: [Device] = DataController.shared().devices
    private weak var selectedDevice: Device?

    public override func viewDidLoad() {
        tableView.tableFooterView = UIView()
        navigationItem.leftBarButtonItem = self.editButtonItem
        DataController.shared().addAsWatcher(self)
    }
    public override func viewWillDisappear(_ animated: Bool) {
        DataController.shared().removeAsWatcher(self)
    }
    public override func viewWillAppear(_ animated: Bool) {
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
        return devices.isEmpty ? 5 : devices.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell") else {
            return UITableViewCell()
        }
        if devices.isEmpty {
            cell.textLabel?.text = "Example Device ".localized() + "\(indexPath.row + 1)"
            cell.detailTextLabel?.text = "12:34:56:78:90:12"
            cell.isUserInteractionEnabled = false
        } else {
            cell.textLabel?.text = devices[indexPath.row].name
            cell.detailTextLabel?.text = devices[indexPath.row].mac
            cell.isUserInteractionEnabled = true
        }
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

    private func deleteAction(on device: Device) {
        let cont = UIAlertController(title: "Deletion confirmation".localized(), message: "Do you want to delete ".localized() + (device.name ?? "John".localized()), preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes".localized(), style: .destructive) { (_) in
            do {
                try DataController.shared().removeDevice(device)
            } catch let err {
                DispatchQueue.main.async {
                    self.present(UIAlertController(title: "Error!".localized(), message: err.localizedDescription, preferredStyle: .alert), animated: true)
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
                    self.present(UIAlertController(title: "Error!".localized(), message: err.localizedDescription, preferredStyle: .alert), animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    self.present(UIAlertController(title: "Success".localized(), message: "Packet sent to  ".localized() + (device.getBroadcast() ?? ""), preferredStyle: .alert), animated: true)
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
