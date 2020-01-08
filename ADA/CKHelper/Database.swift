//
//  Database.swift
//  ADA
//
//  Created by Azmi Muhammad on 18/09/19.
//  Copyright © 2019 Azmi Muhammad. All rights reserved.
//

import CloudKit

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}

enum DatabaseModel: String {
    case Profile
    case Friends
    case Chat
}

protocol Database {
    var key: DatabaseModel! { get set }
    var database: CKDatabase! { get }
    func save(model: Codable, completion: @escaping ((Error?) -> Void))
}

class BaseDatabase: Database {
    
    var key: DatabaseModel!
    var database: CKDatabase!
    
    init(key: DatabaseModel) {
        self.key = key
        database = CKContainer.default().publicCloudDatabase
    }
    
    func save(model: Codable, completion: @escaping ((Error?) -> Void)) {
        if let dict = model.dictionary {
            let record: CKRecord = CKRecord(recordType: key.rawValue)
            for (key, value) in dict {
                record.setValue(value, forKey: key)
                print("\(key) \(value)")
            }
            
            database.save(record) { (savedRecord, err) in
                if let err = err {
                    completion(err)
                } else {
                    completion(nil)
                }
            }
        } else {
            completion(NSError(domain: "Failed to create dict from model", code: 404, userInfo: nil))
        }
    }
}

//@IBAction func onSaveTapped(_ sender: UIButton) {
//    let title = textField.text!
//
//    let record = CKRecord(recordType: "Note")
//
//    record.setValue(title, forKey: "title")
//
//    database.save(record) { (savedRecord, error) in
//        if error == nil {
//            print("Record Saved")
//        } else {
//            print("Record Not Saved")
//        }
//    }
//}
//
//@IBAction func onRetrieveTapped(_ sender: UIButton) {
//    let predicate = NSPredicate(value: true)
//
//    let query = CKQuery(recordType: "Note", predicate: predicate)
//    query.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: false)]
//
//    let operation = CKQueryOperation(query: query)
//
//    titles.removeAll()
//    recordIDs.removeAll()
//
//    operation.recordFetchedBlock = { record in
//        titles.append(record["title"]!)
//        recordIDs.append(record.recordID)
//    }
//
//    operation.queryCompletionBlock = { cursor, error in
//        DispatchQueue.main.async {
//            print("Titles: \(titles)")
//            print("RecordIDs: \(recordIDs)")
//        }
//    }
//
//    database.add(operation)
//}
//
//@IBAction func onUpdateTapped(_ sender: UIButton) {
//    let newTitle = "Anything But The Old Title"
//
//    let recordID = recordIDs.first!
//
//    database.fetch(withRecordID: recordID) { (record, error) in
//        if error == nil {
//            record?.setValue(newTitle, forKey: "title")
//            self.database.save(record!, completionHandler: { (newRecord, error) in
//                if error == nil {
//                    print("Record Saved")
//                } else {
//                    print("Record Not Saved")
//                }
//            })
//        } else {
//            print("Could not fetch record")
//        }
//    }
//}
//
//@IBAction func onDeleteTapped(_ sender: UIButton) {
//    let recordID = recordIDs.first!
//
//    database.delete(withRecordID: recordID) { (deletedRecordID, error) in
//        if error == nil {
//            print("Record Deleted")
//        } else {
//            print("Record Not Deleted")
//
//        }
//    }
//}
