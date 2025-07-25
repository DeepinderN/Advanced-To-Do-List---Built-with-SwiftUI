//
//  TodoViewModel.swift
//  TodoList
//
//  Created by Deepinder on 7/25/25.
//
import SwiftUI

class TodoViewModel: ObservableObject {
    @Published var items: [TodoItem] = [] {
        didSet { saveItems() }
    }
    @Published var filter: FilterType = .all
    @Published var sort: SortType = .dueDateAsc
    private let saveKey = "TodoItems"

    enum FilterType: String, CaseIterable, Identifiable {
        case all, active, completed
        var id: String { rawValue }
    }
    enum SortType: String, CaseIterable, Identifiable {
        case dueDateAsc, dueDateDesc, priority, title
        var id: String { rawValue }
        var label: String {
            switch self {
            case .dueDateAsc: return "Due ↑"
            case .dueDateDesc: return "Due ↓"
            case .priority: return "Priority"
            case .title: return "Title"
            }
        }
    }

    init() {
        loadItems()
    }

    var filteredSortedItems: [TodoItem] {
        var list = items
        // Filter
        switch filter {
        case .active:
            list = list.filter { !$0.isCompleted }
        case .completed:
            list = list.filter { $0.isCompleted }
        default:
            break
        }
        // Sort
        switch sort {
        case .dueDateAsc:
            list.sort { ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) }
        case .dueDateDesc:
            list.sort { ($0.dueDate ?? Date.distantPast) > ($1.dueDate ?? Date.distantPast) }
        case .priority:
            list.sort { $0.priority.rawValue > $1.priority.rawValue }
        case .title:
            list.sort { $0.title.lowercased() < $1.title.lowercased() }
        }
        return list
    }

    func addItem(title: String, dueDate: Date?, priority: Priority) {
        var newItem = TodoItem(title: title, dueDate: dueDate, priority: priority)
        items.append(newItem)
        if dueDate != nil {
            NotificationManager.shared.scheduleReminder(for: newItem)
        }
    }

    func toggleCompletion(of item: TodoItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx].isCompleted.toggle()
        // Cancel reminder if completed
        if items[idx].isCompleted {
            NotificationManager.shared.cancelReminder(for: items[idx])
        }
    }

    func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            NotificationManager.shared.cancelReminder(for: items[index])
        }
        items.remove(atOffsets: offsets)
    }

    private func loadItems() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([TodoItem].self, from: data)
        else { return }
        items = decoded
    }

    private func saveItems() {
        guard let encoded = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(encoded, forKey: saveKey)
    }
}

