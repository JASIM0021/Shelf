//
//  BookListViewModel.swift
//  Shelf
//
//  Created by Sk Jasimuddin on 01/05/25.
//


import Foundation
import CoreData
import Combine

enum APIState {
    case idle
    case loading
    case loaded
    case error(Error)
}

class BookListViewModel: ObservableObject {
    @Published private(set) var groupedBooks: [(date: String, books: [BookEntity])] = []
    @Published private(set) var state: APIState = .idle
    @Published var searchText = ""
    
    private var allBooks: [BookEntity] = []
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSearchPublisher()
    }
    
    // MARK: - Public Methods
    
    @MainActor
    func fetchInitialData() async {
        state = .loading
        
        // First check if we have data in CoreData
        let localBooks = CoreDataService.shared.fetchAllBooks()
        
        if !localBooks.isEmpty {
            self.allBooks = localBooks
            self.groupAndSortBooks()
            state = .loaded
            return
        }
        
        // If no local data, fetch from API
        do {
            let bookResponse = try await NetworkingManager.shared.request(
                endpoint: BookEndPoint.fetchBook,
                parameters: [:],
                headerType: .emptyHeaders
            ) as BookModel
            
            // Save to CoreData
            CoreDataService.shared.saveBooks(bookResponse.data)
            
            // Load from CoreData
            self.allBooks = CoreDataService.shared.fetchAllBooks()
            self.groupAndSortBooks()
            state = .loaded
        } catch {
            state = .error(error)
        }
    }
    
    @MainActor
    func saveBook(_ bookData: Datum) async -> Bool {
        state = .loading
        
        do {
            try await withCheckedThrowingContinuation { continuation in
                CoreDataService.shared.saveBooks([bookData]) { success in
                    if success {
                        continuation.resume()
                    } else {
                        continuation.resume(throwing: NSError(domain: "CoreDataError", code: -1))
                    }
                }
            }
            
            // Refresh local data
            self.allBooks = CoreDataService.shared.fetchAllBooks()
            self.groupAndSortBooks()
            state = .loaded
            return true
        } catch {
            state = .error(error)
            return false
        }
    }
    
    @MainActor
    func deleteBook(_ book: BookEntity) async -> Bool {
        state = .loading
        
        do {
            CoreDataService.shared.context.delete(book)
            try CoreDataService.shared.context.save()
            
            self.allBooks = CoreDataService.shared.fetchAllBooks()
            self.groupAndSortBooks()
            state = .loaded
            return true
        } catch {
            state = .error(error)
            return false
        }
    }
    
    // MARK: - Private Methods
    
    private func setupSearchPublisher() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                self?.filterBooks(by: searchText)
            }
            .store(in: &cancellables)
    }
    
    private func filterBooks(by publisher: String) {
        if publisher.isEmpty {
            groupAndSortBooks()
        } else {
            let filtered = allBooks.filter {
                $0.publisher?.lowercased().contains(publisher.lowercased()) ?? false
            }
            groupBooks(filtered)
        }
    }
    
    private func groupAndSortBooks() {
        groupBooks(allBooks)
    }
    
    private func groupBooks(_ books: [BookEntity]) {
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "yyyy-MM-dd"
        
        // Group books by created date
        let groupedDict = Dictionary(grouping: books) { book -> String in
            guard let date = book.createdAt else {
                return "Unknown Date"
            }
            return displayFormatter.string(from: date)
        }
        
        // Sort books within each group by publisher (author) descending
        groupedBooks = groupedDict.map { (dateKey, booksInGroup) in
            let sortedBooks = booksInGroup.sorted {
                ($0.publisher ?? "") > ($1.publisher ?? "")
            }
            return (date: dateKey, books: sortedBooks)
        }
        // Sort groups by date descending
        .sorted { $0.date > $1.date }
    }
}
