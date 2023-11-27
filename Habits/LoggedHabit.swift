//
//  LoggedHabit.swift
//  Habits
//
//  Created by Tatsuya Moriguchi on 11/26/23.
//

import Foundation

struct LoggedHabit {
    let userID: String
    let habitName: String
    let timestamp: Date
}

extension LoggedHabit: Codable { }
