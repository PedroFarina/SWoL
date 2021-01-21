//
//  DataProperty.swift
//  SwolBackEnd
//
//  Created by Pedro Giuliano Farina on 26/03/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import CloudKit

public class DataProperty<T: Equatable> {
    private let record: CKRecord
    private let key: String
    public var value: T? {
        get {
            return record.value(forKey: key) as? T
        }
        set {
            record.setValue(newValue, forKey: key)
        }
    }

    init(record: CKRecord, key: String) {
        self.record = record
        self.key = key
    }
}

extension DataProperty {
    static func == (lhs: T, rhs: DataProperty) -> Bool {
        return lhs == rhs.value
    }
    static func != (lhs: T, rhs: DataProperty) -> Bool {
        return lhs != rhs.value
    }
    static func == (lhs: DataProperty, rhs: T) -> Bool {
        return lhs.value == rhs
    }
    static func != (lhs: DataProperty, rhs: T) -> Bool {
        return lhs.value != rhs
    }
}

