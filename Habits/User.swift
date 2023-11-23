//
//  User.swift
//  Habits
//
//  Created by Tatsuya Moriguchi on 11/23/23.
//

import Foundation

struct User {
    let id: String
    let name: String
    let color: Color?
    let bio: String?
}

extension User: Codable {
    
}

extension User: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(_ lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}

// Because you'll want to be able to display the users sorted by name, extend User to adopt Comparable in the User file.
extension User: Comparable {
    static func < (lhs: User, rhs: User) -> Bool {
        return lhs.name < rhs.name
    }
}
