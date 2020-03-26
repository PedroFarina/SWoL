//
//  Device+CoreDataProperties.swift
//  SwolBackEnd
//
//  Created by Pedro Giuliano Farina on 26/03/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//
//

import Foundation
import CoreData


extension Device {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Device> {
        return NSFetchRequest<Device>(entityName: "Device")
    }

    @NSManaged public var address: String?
    @NSManaged public var mac: String?
    @NSManaged public var name: String?
    @NSManaged public var port: Int32
    @NSManaged public var cloudID: UUID?

    @nonobjc public func getBroadcast() -> String? {
        guard let address = address else {
            return nil
        }
        var newAddress = ""
        let groups = address.components(separatedBy: ".")

        for i in 0..<min(3, groups.count) {
            newAddress += "\(groups[i])."
        }
        newAddress += "255"
        return newAddress
    }
}
