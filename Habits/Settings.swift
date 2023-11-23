//
//  Settings.swift
//  Habits
//
//  Created by Tatsuya Moriguchi on 11/21/23.
//

import Foundation


enum Setting {
    static let favoriteHabits = "favoriteHabits"
    static let followedUserIDs = "followedUserIDs"
}

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
    
    // Computed prperty for favorite habits to store and retrieve the IDs of followed users.
    var favoriteHabits: [Habit] {
        get {
            return unarchiveJSON(key: Setting.favoriteHabits) ?? []
        }
        set {
            archiveJSON(value: newValue, key: Setting.favoriteHabits)
        }
    }
    
    
    mutating func toggleFavorite(_ habit: Habit) {
        var favorites = favoriteHabits
        
        if favorites.contains(habit) {
            favorites = favorites.filter({ $0 != habit })
        } else {
            favorites.append(habit)
        }
        
        favoriteHabits = favorites
    }
    
    //  In the Settings file, add a new key to the Setting namespace with the name and value of "followedUserIDs" and create a new property to store and retrieve the IDs of followed users. (You won't store the user objects themselves, since users might occasionally change things like their favorite color, which would invalidate this data.)
    var followedUserIDs: [String] {
        get {
            return unarchiveJSON(key: Setting.followedUserIDs) ?? []
        }
        set {
            archiveJSON(value: newValue, key: Setting.followedUserIDs)
        }
    }
    
    // Toggle the status of a user.
    mutating func toggleFollowed(user: User) {
        var updated = followedUserIDs
        
        if updated.contains(user.id) {
            updated = updated.filter({ $0 != user.id })
        } else {
            updated.append(user.id)
        }
        
        followedUserIDs = updated
    }
    
}

