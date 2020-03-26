//
//  CloudKitDataController.swift
//  SwolBackEnd
//
//  Created by Pedro Giuliano Farina on 26/03/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import  CloudKit

internal enum DatabaseType {
    case Private
    case Shared
    case Public

    private static let container = CKContainer.init(identifier: "iCloud.PGF.Swol")

    internal var value: CKDatabase {
        switch self {
        case .Private:
            return DatabaseType.container.privateCloudDatabase
        case .Shared:
            return DatabaseType.container.sharedCloudDatabase
        case .Public:
            return DatabaseType.container.publicCloudDatabase
        }
    }
}

internal class DataConnector {
    private init() {
    }

    private static let container: CKContainer = CKContainer.default()
    private static let privateDB: CKDatabase = container.privateCloudDatabase
    private static let sharedDB: CKDatabase = container.sharedCloudDatabase
    private static let publicDB: CKDatabase = container.publicCloudDatabase

    // MARK: Saving Object
    internal static func saveObject(database: DatabaseType, object: EntityObject,
                                    completionHandler: @escaping ((DataActionAnswer) -> Void)) {
        database.value.save(object.record) { (_, error) in
            if let error = error as? CKError {
                DispatchQueue.main.async {
                    completionHandler(.fail(error: error, description:
                        "Erro em salvar o objeto na Cloud - Save: \(String(describing: error))"))
                }
                return
            }
            DispatchQueue.main.async {
                completionHandler(.successful)
            }
            return
        }
    }

    // MARK: Saving Objects
    internal static func saveData(database: DatabaseType, entitiesToSave: [EntityObject]) {
        saveData(database: database, entitiesToSave: entitiesToSave, entitiesToDelete: [])
    }
    internal static func deleteData(database: DatabaseType, entitiesToDelete: [EntityObject]) {
        saveData(database: database, entitiesToSave: [], entitiesToDelete: entitiesToDelete)
    }

    internal static func saveData(database: DatabaseType, entitiesToSave: [EntityObject], entitiesToDelete: [EntityObject]) {

        var savingRecords: [CKRecord] = []
        for obj in entitiesToSave {
            savingRecords.append(obj.record)
        }

        var deletingRecords: [CKRecord.ID] = []
        for obj in entitiesToDelete {
            deletingRecords.append(obj.record.recordID)
        }

        let operation: CKModifyRecordsOperation = CKModifyRecordsOperation(
            recordsToSave: savingRecords, recordIDsToDelete: deletingRecords)
        operation.savePolicy = .changedKeys
        database.value.add(operation)
    }

    // MARK: Deleting Object
    internal func deleteObject(database: DatabaseType, object: EntityObject,
                               completionHandler: @escaping ((DataActionAnswer) -> Void)) {
        database.value.delete(withRecordID: object.record.recordID) { (_, error) in
            if let error = error as? CKError {
                DispatchQueue.main.async {
                    completionHandler(.fail(error: error, description:
                        "Erro em deletar o objeto na Cloud - Delete: \(String(describing: error))"))
                }
                return
            }
            DispatchQueue.main.async {
                completionHandler(.successful)
            }
            return
        }
    }

    // MARK: Fetching
    internal static func fetchUserID(completionHandler: @escaping (DataFetchAnswer) -> Void) {
        container.fetchUserRecordID { (userID, error) in
            if let error = error as? CKError {
                DispatchQueue.main.async {
                    completionHandler(.fail(error: error, description:
                        "Erro no Query da Cloud - Fetch: \(String(describing: error))"))
                }
                return
            }
            completionHandler(.successful(result: userID))
        }
    }

    internal static func fetch(recordType: String, database: DatabaseType, completionHandler: @escaping (DataFetchAnswer) -> Void) {
        let predicate = NSPredicate(value: true)
        fetch(query: CKQuery(recordType: recordType, predicate: predicate), database: database, completionHandler: completionHandler)
    }

    internal static func fetch(query: CKQuery, database: DatabaseType, completionHandler: @escaping (DataFetchAnswer) -> Void ) {
        database.value.perform(query, inZoneWith: nil) { (results, error) in
            if let error = error as? CKError {
                DispatchQueue.main.async {
                    completionHandler(.fail(error: error, description:
                        "Erro no Query da Cloud - Fetch: \(String(describing: error))"))
                }
                return
            }

            DispatchQueue.main.async {
                completionHandler(.successful(results: results))
            }
        }
    }
}
