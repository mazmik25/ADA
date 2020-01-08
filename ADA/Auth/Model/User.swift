//
//  User.swift
//  ADA
//
//  Created by Azmi Muhammad on 18/09/19.
//  Copyright © 2019 Azmi Muhammad. All rights reserved.
//

import Foundation

struct User: Codable {
    let email: String
    let name: String
    let dateOfBirth: String
    let uuid: String
    var lat: Double
    var long: Double
}
