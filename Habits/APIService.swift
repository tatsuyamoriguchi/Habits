//
//  APIService.swift
//  Habits
//
//  Created by Tatsuya Moriguchi on 11/20/23.
//

import Foundation

struct HabitRequest: APIRequest {
    typealias Response = [String: Habit]
    
    var habitName: String?
    var path: String { "/habits" }
    
}
