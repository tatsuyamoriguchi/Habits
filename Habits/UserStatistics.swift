//
//  UserStatistics.swift
//  Habits
//
//  Created by Tatsuya Moriguchi on 11/24/23.
//

import Foundation

struct UserStatistics {
    let user: User
    let habitCounts: [HabitCount]
}

extension UserStatistics: Codable { }
