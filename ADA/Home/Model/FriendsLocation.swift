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
    
    override init(key: DatabaseModel) {
        super.init(key: key)
    }
    
    override func save(model: Codable, completion: @escaping ((Error?) -> Void)) {
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
}
