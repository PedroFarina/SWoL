//
//  DataSyncronizer.swift
//  SwolBackEnd
//
//  Created by Pedro Giuliano Farina on 26/03/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import Foundation

protocol DataSynchronizer {
    func dataChanged(to devices: [DeviceProtocol])
}
