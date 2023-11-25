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

// Add a new API request to APIService to enable fetching users.
struct UserRequest: APIRequest {
    typealias Response = [String: User]
    
    var path: String { "/users" }
}


//Add a new declaration to APIService for fetching habit statistics. Ask for
// statistics for multiple habit names in one request. Provide a comma-separated / // list of IDs from the queryItems property.
struct HabitStatisticsRequest: APIRequest {
    typealias Response = [HabitStatistics]
    
    var habitNames: [String]?
    
    var path: String { "/habitStats"}
    
    var queryItems: [URLQueryItem]? {
        if let habitNames = habitNames {
            return [URLQueryItem(name: "names", value: habitNames.joined(separator: ","))]
        } else {
            return nil
            
        }
    }
}

struct UserStatisticsRequest: APIRequest {
    typealias Response = [UserStatistics]
    
    var userIDs: [String]?

    var path: String { "/userStats"}

    var queryItems: [URLQueryItem]? {
        if let userIDs = userIDs {
            return [URLQueryItem(name: "ids", value: userIDs.joined(separator: ","))]
        } else {
            return nil
        }
    }
}

struct HabitLeadStatisticsRequest: APIRequest {
    typealias Response = UserStatistics
    
    var userID: String
    var path: String { "/userLeadStats/\(userID)" }
}
