//
//  Settings.swift
//  Habits
//
//  Created by Tatsuya Moriguchi on 11/21/23.
//

import Foundation

struct Settings {
    static var shared = Settings()
    private let defaults = UserDefaults.standard

    // Archive and unacrchive JSON from UserDefaults
    private func archiveJSON<T: Encodable>(value: T, key: String) {
        // You can assume that JSON encoding and decoding will work, so you can disable error propagation by using try!
        // No need to wrap your code in a do/catch block.
        let data = try! JSONEncoder().encode(value)
        let string = String(data: data, encoding: .utf8)

        defaults.set(string, forKey: key)
    }
    
    private func unarchiveJSON<T: Decodable>(key: String) -> T? {
        guard let string = defaults.string(forKey: key), let data = string.data(using: .utf8) else {
            return nil
        }
        return try! JSONDecoder().decode(T.self, from: data)
                
    }
    
    // Computed prperty for favorite habits
    var favoriteHabits: [Habit] {
        get {
            return unarchiveJSON(key: Setting.favoriteHabits) ?? []
        }
        set {
            archiveJSON(value: newValue, key: Setting.favoriteHabits)
        }
    }
    
    enum Setting {
        static let favoriteHabits = "favoriteHabits"
    }
    
    
}

