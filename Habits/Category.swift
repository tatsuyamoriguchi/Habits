//
//  Category.swift
//  Habits
//
//  Created by Tatsuya Moriguchi on 11/20/23.
//

import Foundation

struct Category {
    let name: String
    let color: Color
    
}

extension Category: Codable { }


extension Category: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.name == rhs.name
    }
}
