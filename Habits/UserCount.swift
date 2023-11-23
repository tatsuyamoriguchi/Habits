//
//  UserCount.swift
//  Habits
//
//  Created by Tatsuya Moriguchi on 11/23/23.
//

import Foundation

struct UserCount {
    let user: User
    let count: Int
}

extension UserCount: Codable { }
extension UserCount: Hashable {  }
