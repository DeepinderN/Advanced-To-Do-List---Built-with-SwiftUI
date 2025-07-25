//
//  ContentView.swift
//  TodoList
//
//  Created by Deepinder on 7/25/25.
//
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: TodoViewModel
    @State private var newTitle = ""
    @State private var newDue: Date = Date()
    @State private var newPriority: Priority = .medium
    @State private var showingAddSheet = false

    var body: some View {
        NavigationView {
            List {
                // Filter & Sort controls
                Section {
                    Picker("Filter", selection: $viewModel.filter) {
                        ForEach(TodoViewModel.FilterType.allCases) { f in
                            Text(f.rawValue.capitalized).tag(f)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    Menu {
                        ForEach(TodoViewModel.SortType.allCases) { s in
                            Button(action: { viewModel.sort = s }) {
                                Text(s.label + (viewModel.sort == s ? " ✓" : ""))
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down.circle")
                    }
                }

                // To-Do Items
                ForEach(viewModel.filteredSortedItems) { item in
                    HStack {
                        Button(action: { viewModel.toggleCompletion(of: item) }) {
                            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(item.isCompleted ? .green : .primary)
                        }
                        VStack(alignment: .leading) {
                            Text(item.title)
                                .strikethrough(item.isCompleted)
                            HStack {
                                if let due = item.dueDate {
                                    Text(dateFormatter.string(from: due))
                                        .font(.caption)
                                        .foregroundColor(.gray)

                                }
                                Spacer()
                                Text(item.priority.label)
                                    .font(.caption2)
                                    .padding(4)
                                    .background(Color(item.priority.color))
                                    .cornerRadius(4)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .onDelete(perform: viewModel.delete)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Advanced To-Do")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddTodoView(isPresented: $showingAddSheet)
                    .environmentObject(viewModel)
            }
        }
    }
}

// Date formatter for display
private let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .short
    df.timeStyle = .short
    return df
}()

// MARK: Add Item Sheet
struct AddTodoView: View {
    @EnvironmentObject var viewModel: TodoViewModel
    @Binding var isPresented: Bool
    @State private var title = ""
    @State private var dueDate = Date()
    @State private var useDue = false
    @State private var priority: Priority = .medium

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task")) {
                    TextField("Title", text: $title)
                }
                Section(header: Text("Due Date")) {
                    Toggle(isOn: $useDue) { Text("Set due date") }
                    if useDue {
                        DatePicker("Due", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                Section(header: Text("Priority")) {
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases) { p in
                            Text(p.label).tag(p)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("New To-Do")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addItem(title: title.trimmingCharacters(in: .whitespaces),
                                          dueDate: useDue ? dueDate : nil,
                                          priority: priority)
                        isPresented = false
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(TodoViewModel())
    }
}
