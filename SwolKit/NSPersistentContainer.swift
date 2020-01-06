//
//  NSPersistentContainer.swift
//  SwolKit
//
//  Created by Pedro Giuliano Farina on 06/01/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import Foundation

import UIKit
import CoreData

class NSCustomPersistentContainer: NSPersistentContainer {

    override open class func defaultDirectoryURL() -> URL {
        var storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.Swol")
        storeURL = storeURL?.appendingPathComponent("Swol.sqlite")
        return storeURL!
    }

}
