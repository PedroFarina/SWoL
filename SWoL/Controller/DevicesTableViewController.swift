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

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedDevice = devices[indexPath.row]
        if tableView.isEditing {
            self.performSegue(withIdentifier: "deviceSelected", sender: self)
        } else {
            wakeAction(on: devices[indexPath.row])
        }
    }

    private func wakeAction(on device: Device) {
        let cont = UIAlertController(title: "Waking confirmation".localized(), message: "Do you want to wake ".localized() + String(describing: device.name) + "?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes".localized(), style: .default) { (_) in
            if let err = Awake.target(device: device) {
                DispatchQueue.main.sync {
                    self.present(UIAlertController(title: "Error!".localized(), message: err.localizedDescription, preferredStyle: .alert), animated: true)
                }
            } else {
                DispatchQueue.main.sync {
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
        if let view = segue.destination as? DeviceViewController, let device = selectedDevice {
            view.device = device
        }
    }
}
