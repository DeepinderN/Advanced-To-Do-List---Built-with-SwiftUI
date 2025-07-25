//
//  TodoItem.swift
//  TodoList
//
//  Created by Deepinder on 7/25/25.
//

import Foundation

enum Priority: Int, CaseIterable, Codable, Identifiable {
    case low = 0, medium, high
    var id: Int { rawValue }
    var label: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "orange"
        case .high: return "red"
        }
    }
}

struct TodoItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var dueDate: Date?
    var priority: Priority
    var isCompleted: Bool

    init(id: UUID = UUID(), title: String, dueDate: Date? = nil, priority: Priority = .medium, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.priority = priority
        self.isCompleted = isCompleted
    }
}

