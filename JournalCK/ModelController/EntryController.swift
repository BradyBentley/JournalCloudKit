//
//  EntryController.swift
//  JournalCK
//
//  Created by Brady Bentley on 12/31/18.
//  Copyright © 2018 Brady. All rights reserved.
//

import Foundation
import CloudKit

class EntryController {
    // MARK: - Properties
    
    static let shared = EntryController()
    
    var entries: [Entry] = []
    
    // MARK: - Functions
    func save(entry: Entry, completion: @escaping (Bool) -> Void) {
        let record = CKRecord(entry: entry)
        CKContainer.default().privateCloudDatabase.save(record) { (record, error) in
            if let error = error{
                print("\(error.localizedDescription) \(error) in function: \(#function)")
                completion(false)
                return
            }
            guard let record = record, let entry = Entry(ckRecord: record) else { completion(false) ; return }
            self.entries.append(entry)
            completion(true)
        }
    }
    
    func addEntryWith(title: String, body: String, completion: @escaping (Bool) -> Void){
        let newEntry = Entry(title: title, body: body)
        self.save(entry: newEntry) { (success) in
            if success {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func updateEntry(entry: Entry, title: String, body: String, completion: @escaping (Bool) -> Void){
        // update locally
        entry.title = title
        entry.body = body
        
        // update on cloudKit
        CKContainer.default().privateCloudDatabase.fetch(withRecordID: entry.ckRecordID) { (record, error) in
            if let error = error {
                print("\(error.localizedDescription) \(error) in function: \(#function)")
                completion(false)
                return
            }
            guard let record = record else { completion(false) ; return }
            record[Constants.TitleKey] = title
            record[Constants.BodyKey] = body
            
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            operation.savePolicy = .changedKeys
            operation.queuePriority = .high
            operation.qualityOfService = .userInitiated
            operation.modifyRecordsCompletionBlock = { (records, recordIDs, error) in
                completion(true)
            }
            CKContainer.default().privateCloudDatabase.add(operation)
        }
    }
    
    func remove(entry: Entry, completion: @escaping (Bool) -> Void) {
        // delete it locally
        guard let index = entries.index(of: entry) else { completion(false) ; return }
        entries.remove(at: index)
        
        // delete it from cloudkit
        CKContainer.default().privateCloudDatabase.delete(withRecordID: entry.ckRecordID) { (_, error) in
            if let error = error {
                print("\(error.localizedDescription) \(error) in function: \(#function)")
                completion(false)
                return
            } else {
                print("Successful removed item")
                completion(true)
            }
        }
    }
    
    func fetchEntries(completion: @escaping (Bool) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Constants.recordKey, predicate: predicate)
        CKContainer.default().privateCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error{
                print("\(error.localizedDescription) \(error) in function: \(#function)")
                completion(false)
                return
            }
            guard let records = records else { completion(false) ; return }
            let entries = records.compactMap { Entry(ckRecord: $0) }
            self.entries = entries
            completion(true)
        }
    }
}
