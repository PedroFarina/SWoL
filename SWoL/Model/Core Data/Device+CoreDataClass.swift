//
//  Device+CoreDataClass.swift
//  SWoL
//
//  Created by Pedro Giuliano Farina on 03/01/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Device)
public class Device: NSManagedObject {
    func getBroadcast() -> String? {
        guard let address = address else {
            return nil
        }
        var newAddress = ""
        let groups = address.components(separatedBy: ".")

        for i in 0...2 {
            newAddress += "\(groups[i])."
        }
        newAddress += "255"
        return newAddress
    }
}
