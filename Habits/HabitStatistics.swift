//
//  HabitStatistics.swift
//  Habits
//
//  Created by Tatsuya Moriguchi on 11/23/23.
//

import Foundation

struct HabitStatistics {
    let habit: Habit
    let userCounts: [UserCount]
}

extension HabitStatistics: Codable { }
