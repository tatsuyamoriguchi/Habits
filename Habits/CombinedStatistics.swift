//
//  CombinedStatistics.swift
//  Habits
//
//  Created by Tatsuya Moriguchi on 12/8/23.
//

import Foundation

struct CombinedStatistics {
    let userStatistics: [UserStatistics]
    let habitStatistics: [HabitStatistics]
}

extension CombinedStatistics: Codable { }

