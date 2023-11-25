//
//  HabitCount.swift
//  Habits
//
//  Created by Tatsuya Moriguchi on 11/24/23.
//

import Foundation

struct HabitCount {
    let habit: Habit
    let count: Int
}

extension HabitCount: Codable { }

// Custom Hashable conformance to guarantee stable identity of the vewi model items.
extension HabitCount: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(habit)
    }
    
    static func ==(_ lhs: HabitCount, _ rhs: HabitCount) -> Bool {
        return lhs.habit == rhs.habit
    }
}

extension HabitCount: Comparable {
    static func < (lhs: HabitCount, rhs: HabitCount) -> Bool {
        return lhs.count < rhs.count
        
    }
}
