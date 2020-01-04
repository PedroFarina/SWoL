//
//  DevicesTableViewController.swift
//  SWoL
//
//  Created by Pedro Giuliano Farina on 04/01/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import UIKit

public class DevicesTableViewController: UITableViewController {
    var devices: [Device] = DataController.shared().devices

    public override func viewDidLoad() {
        tableView.tableFooterView = UIView()
    }
    public override func viewWillAppear(_ animated: Bool) {
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
            cell.textLabel?.text = "Example Device \(indexPath.row + 1)"
            cell.detailTextLabel?.text = "12:34:56:78:90:12"
            cell.isUserInteractionEnabled = false
        } else {
            cell.textLabel?.text = devices[indexPath.row].name
            cell.detailTextLabel?.text = devices[indexPath.row].mac
        }
        return cell
    }
}
