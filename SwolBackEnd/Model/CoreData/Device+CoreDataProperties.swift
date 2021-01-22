//
//  Device+CoreDataProperties.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 12/01/21.
//  Copyright © 2021 Pedro Giuliano Farina. All rights reserved.
//
//

import Foundation
import CoreData


extension Device {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Device> {
        return NSFetchRequest<Device>(entityName: "Device")
    }

    @NSManaged public var address: String?
    @NSManaged public var cloudID: UUID?
    @NSManaged public var mac: String?
    @NSManaged public var name: String?
    @NSManaged public var port: Int32
    @NSManaged public var externalAddress: String?

}

extension Device : Identifiable {

}
