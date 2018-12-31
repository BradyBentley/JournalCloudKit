//
//  Entry.swift
//  JournalCK
//
//  Created by Brady Bentley on 12/31/18.
//  Copyright © 2018 Brady. All rights reserved.
//

import Foundation
import CloudKit

class Entry {
    
    // MARK: - Properties
    var title: String
    var body: String
    let ckRecordID: CKRecord.ID
    
    // MARK: - Initialization
    init(title: String, body: String, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.title = title
        self.body = body
        self.ckRecordID = ckRecordID
    }
    
    convenience init?(ckRecord: CKRecord){
        guard let title = ckRecord[Constants.TitleKey] as? String,
            let body = ckRecord[Constants.BodyKey] as? String else { return nil }
        self.init(title: title, body: body, ckRecordID: ckRecord.recordID)
    }
}
// MARK: - Constants
struct Constants{
    static let TitleKey = "title"
    static let BodyKey = "body"
    static let recordKey = "Entry"
}

// MARK: - CKRecord
extension CKRecord {
    convenience init(entry: Entry) {
        self.init(recordType: Constants.recordKey, recordID: entry.ckRecordID)
        self.setValue(entry.title, forKey: Constants.TitleKey)
        self.setValue(entry.body, forKey: Constants.BodyKey)
    }
}

// MARK: - Equatable
extension Entry: Equatable {
    static func == (lhs: Entry, rhs: Entry) -> Bool {
        return lhs.body == rhs.body && lhs.title == rhs.title
    }
}
