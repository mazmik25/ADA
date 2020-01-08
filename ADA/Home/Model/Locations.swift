//
//  FriendsLocation.swift
//  ADA
//
//  Created by Azmi Muhammad on 19/09/19.
//  Copyright © 2019 Azmi Muhammad. All rights reserved.
//

import CloudKit

class Locations: BaseDatabase {
    
    typealias Result = ([Users]?, Error?) -> Void
    typealias SimpleResult = ((Error?) -> Void)
    
    override init(key: DatabaseModel) {
        super.init(key: key)
    }
    
    override func save(model: Codable, completion: @escaping SimpleResult) {
        super.save(model: model, completion: completion)
    }
    
    func retrieveLocation(completion: @escaping Result) {
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: DatabaseModel.Profile.rawValue, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "email", ascending: false)]
        var results = [Users]()
        
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = { record in
            guard let model = self.generateData(record) else {return}
            results.append(model)
        }
        
        operation.queryCompletionBlock = { cursor, error in
            DispatchQueue.main.async {
                if let err = error {
                    completion(nil, err)
                } else {
                    completion(results, nil)
                }
            }
        }
        
        database.add(operation)
    }
    
    func updateLocation(coordinate: CLLocationCoordinate2D, result: @escaping SimpleResult) {
        retrieveId { (recordId, err) in
            if let recordId = recordId {
                DispatchQueue.main.async {
                    self.handleUpdateLocation(withCoordinate: coordinate, recordId, result)
                }
            } else if let err = err {
                result(err)
            }
        }
    }
    
    private func handleUpdateLocation(withCoordinate coordinate: CLLocationCoordinate2D, _ id: CKRecord.ID, _ result: @escaping SimpleResult) {
        database!.fetch(withRecordID: id) { (record, err) in
            if let record = record {
                record.setValue(coordinate.latitude, forKey: "lat")
                record.setValue(coordinate.longitude, forKey: "long")
                self.updateData(record, result)
            } else if let err = err {
                result(err)
            }
        }
    }
    
    private func updateData(_ record: CKRecord, _ result: @escaping SimpleResult) {
        database!.save(record) { (newRecord, err) in
            if let _ = newRecord {
                result(nil)
            } else if let err = err {
                result(err)
            }
        }
    }
    
    private func generateData(_ record: CKRecord) -> Users? {
        guard let mail = record["email"] as? String, let usermail: String = Preference.getString(forKey: .kUserEmail), !usermail.elementsEqual(mail) else {return nil}
        let lat = record["lat"] as! Double
        let long = record["long"] as! Double
        let username = record["name"] as! String
        let dateOfBirth = record["dateOfBirth"] as! String
        let email = record["email"] as! String
        let uuid = record["uuid"] as! String
        return Users(dateOfBirth: dateOfBirth, email: email, lat: lat, long: long, name: username, uuid: uuid)
    }
    
    private func retrieveId(completion: @escaping ((CKRecord.ID?, Error?) -> Void)) {
        var recordId: CKRecord.ID = CKRecord.ID()
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: key.rawValue, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "email", ascending: false)]
        
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = { record in
            recordId = record.recordID
        }
        
        operation.queryCompletionBlock = { cursor, error in
            DispatchQueue.main.async {
                if let err = error {
                    print(err)
                    completion(nil, err)
                } else {
                    completion(recordId, nil)
                }
            }
        }
        
        database.add(operation)
    }
}
