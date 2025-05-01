//
//  BookListViewModel.swift
//  Shelf
//
//  Created by Sk Jasimuddin on 30/04/25.
//

enum APIState {
    case loading
    case loaded
    case error
}

import UIKit
import CoreData

class BookListViewModel {
    
    private var allBooks: [BookEntity] = []
    var groupedBooks: [(date: String, books: [BookEntity])] = []
    
    var apiObserver:((APIState) -> Void)?
    
    func fetchInitialData(completion: @escaping () -> Void) {

        self.apiObserver?(.loading)
        let localBooks = CoreDataService.shared.fetchAllBooks()
       
        if !localBooks.isEmpty {
            self.allBooks = localBooks
            self.groupAndSortBooks()
            self.apiObserver?(.loaded)
            completion()
            return
        }
        

       
        NetworkingManager.shared.request(
            endpoint: BookEndPoint.fetchBook,
            parameters: [:],
            headerType: .emptyHeaders
        ) { (result: Result<BookModel, Error>) in
            DispatchQueue.main.async {
                self.apiObserver?(.loaded)
                switch result {
                case .success(let bookResponse):

                    CoreDataService.shared.saveBooks(bookResponse.data) { [weak self] success in
                        self?.allBooks = CoreDataService.shared.fetchAllBooks()
                        self?.groupAndSortBooks()
                        completion()
                    }

                    
                case .failure(let error):
                    self.apiObserver?(.error)
                    print("Error fetching books: \(error)")
                    completion()
                }
            }
        }
    }
    
    func saveBook(_ bookData: Datum, completion: @escaping (Bool) -> Void) {
        self.apiObserver?(.loading)
        
        // Save to Core Data
        CoreDataService.shared.saveBooks([bookData]) { [weak self] success in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if success {
                    // Refresh local data
                    self.allBooks = CoreDataService.shared.fetchAllBooks()
                    self.groupAndSortBooks()
                    self.apiObserver?(.loaded)
                    completion(true)
                } else {
                    self.apiObserver?(.error)
                    completion(false)
                }
            }
        }
    }
    
    func filterBooks(by publisher: String) {
        if publisher.isEmpty {
            groupAndSortBooks()
        } else {
            let filtered = allBooks.filter {
                $0.publisher?.lowercased().contains(publisher.lowercased()) ?? false
            }
            groupBooks(filtered)
        }
    }
    
    func deleteBook(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let book = groupedBooks[indexPath.section].books[indexPath.row]
        CoreDataService.shared.context.delete(book)
        
        do {
            try CoreDataService.shared.context.save()
            self.allBooks = CoreDataService.shared.fetchAllBooks()
            self.groupAndSortBooks()
            completion(true)
        } catch {
            print("Error deleting book: \(error)")
            completion(false)
        }
    }
    

    
    func groupAndSortBooks() {
        groupBooks(allBooks)
    }
    

    
    private func groupBooks(_ books: [BookEntity]) {
        // Formatter for grouping by exact second
        let groupingFormatter = DateFormatter()
        groupingFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        groupingFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        

        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .medium
        displayFormatter.timeZone = TimeZone.current
        
    
        let groupedDict = Dictionary(grouping: books) { book -> String in
            guard let date = book.createdAt else {
                return "Unknown Date"
            }
            return groupingFormatter.string(from: date)
        }
        

        groupedBooks = groupedDict.map { (dateKey, booksInGroup) in
       
            if let groupDate = groupingFormatter.date(from: dateKey) {
                let displayDate = displayFormatter.string(from: groupDate)
                let sortedBooks = booksInGroup.sorted {
                    ($0.publisher ?? "") > ($1.publisher ?? "")
                }
                return (date: displayDate, books: sortedBooks)
            } else {
                let sortedBooks = booksInGroup.sorted {
                    ($0.publisher ?? "") > ($1.publisher ?? "")
                }
                return (date: dateKey, books: sortedBooks)
            }
        }
  
        .sorted {
            if let date1 = groupingFormatter.date(from: $0.date),
               let date2 = groupingFormatter.date(from: $1.date) {
                return date1 > date2
            }
            return $0.date > $1.date
        }
    }
}
