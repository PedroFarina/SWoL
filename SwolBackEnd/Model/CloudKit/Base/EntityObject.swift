//
//  EntityObject.swift
//  SwolBackEnd
//
//  Created by Pedro Giuliano Farina on 26/03/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import CloudKit

public protocol EntityObject: NSObject {
    static var recordType: String { get }
    var record: CKRecord { get }
}
