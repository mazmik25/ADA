//
//  Preference.swift
//  cycle
//
//  Created by Azmi Muhammad on 23/08/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import Foundation

enum PreferenceKey: String {
    case kFaceId
    case kAccessLocation
    case kUserName
    case kUserEmail
}

struct Preference {
    
    static func set(value: Any?, forKey key: PreferenceKey) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    static func getString(forKey key: PreferenceKey) -> String? {
        return UserDefaults.standard.string(forKey: key.rawValue)
    }
    
    static func getInt(forKey key: PreferenceKey) -> Int {
        return UserDefaults.standard.integer(forKey: key.rawValue)
    }
    
    static func getBool(forKey key: PreferenceKey) -> Bool? {
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }
    
    static func isFaceIdDone() -> Bool {
        return getBool(forKey: .kFaceId) ?? false
    }
    
    static func isAccessGranted() -> Bool {
        return getBool(forKey: .kAccessLocation) ?? false
    }
}
