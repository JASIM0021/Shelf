//
//  BookListView.swift
//  Shelf
//
//  Created by Sk Jasimuddin on 01/05/25.
//

import Foundation
import SwiftUI
import CoreData

struct BookListView: View {
    @StateObject private var viewModel = BookListViewModel()
    @State private var searchText = ""
    @State private var showingAddBook = false
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.groupedBooks.isEmpty {
                    emptyStateView
                } else {
                    listView
                }
            }
            .navigationTitle("Shelf")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddBook = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Filter by author")
            .onChange(of: searchText) { newValue in
                viewModel.filterBooks(by: newValue)
            }
            .sheet(isPresented: $showingAddBook) {
                EditBookView(viewModel: viewModel)
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                        .background(.thickMaterial)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "books.vertical.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Your shelf is empty")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Button(action: { showingAddBook = true }) {
                Label("Add Your First Book", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    private var listView: some View {
        List {
            ForEach(viewModel.groupedBooks) { group in
                Section(header: sectionHeader(for: group)) {
                    ForEach(group.books) { book in
                        NavigationLink {
                            EditBookView(book: book, viewModel: viewModel)
                        } label: {
                            BookRow(book: book)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        deleteBook(book)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await viewModel.fetchInitialData()
        }
        .animation(.default, value: viewModel.groupedBooks)
    }
    
    private func sectionHeader(for group: BookGroup) -> some View {
        HStack {
            Image(systemName: "books.vertical.fill")
            Text("Created: \(group.date)")
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
    
    private func deleteBook(_ book: BookEntity) {
        Task {
            await viewModel.deleteBook(book)
        }
    }
}

struct BookRow: View {
    let book: BookEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(book.title ?? "Untitled")
                .font(.headline)
                .lineLimit(1)
            
            if let publisher = book.publisher, !publisher.isEmpty {
                Text(publisher)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 8)
    }
}

struct EditBookView: View {
    var book: BookEntity?
    @ObservedObject var viewModel: BookListViewModel
    
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var publisher: String = ""
    @State private var year: String = ""
    @State private var isbn: String = ""
    @State private var pages: String = ""
    @State private var handle: String = ""
    @State private var notes: String = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    private var isNewBook: Bool { book == nil }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Book Information")) {
                    TextField("Title*", text: $title)
                    TextField("Publisher", text: $publisher)
                    TextField("Year", text: $year)
                        .keyboardType(.numberPad)
                    TextField("ISBN", text: $isbn)
                        .keyboardType(.numbersAndPunctuation)
                    TextField("Pages", text: $pages)
                        .keyboardType(.numberPad)
                    TextField("Handle", text: $handle)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Button(action: saveBook) {
                        HStack {
                            Spacer()
                            Text("Save Book")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                
                if !isNewBook, let createdAt = book?.createdAt {
                    Section {
                        HStack {
                            Text("Created")
                            Spacer()
                            Text(formattedDate(createdAt))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(isNewBook ? "Add Book" : "Edit Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                populateFields()
            }
        }
    }
    
    private func populateFields() {
        guard let book = book else { return }
        
        title = book.title ?? ""
        publisher = book.publisher ?? ""
        year = book.year != 0 ? String(book.year) : ""
        isbn = book.isbn ?? ""
        pages = book.pages != 0 ? String(book.pages) : ""
        handle = book.handle ?? ""
        notes = book.notes ?? ""
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func saveBook() {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Title is required"
            showingError = true
            return
        }
        
        let bookData = Datum(
            id: book?.id?.intValue ?? Int.random(in: 0...1000),
            year: Int(year),
            title: title,
            handle: handle.isEmpty ? nil : handle,
            publisher: publisher.isEmpty ? nil : publisher,
            isbn: isbn.isEmpty ? nil : isbn,
            pages: Int(pages),
            notes: notes.isEmpty ? nil : [notes],
            createdAt: book?.createdAtString,
            villains: nil
        )
        
        Task {
            let success = await viewModel.saveBook(bookData)
            if success {
                dismiss()
            } else {
                errorMessage = "Failed to save book"
                showingError = true
            }
        }
    }
}

// Preview
struct BookListView_Previews: PreviewProvider {
    static var previews: some View {
        BookListView()
    }
}
