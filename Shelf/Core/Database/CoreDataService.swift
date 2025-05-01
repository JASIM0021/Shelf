import UIKit
import CoreData




struct BookData {
    let id : Int
    let title:String
    let createdAt:String
    let isbn:String
    let publisher:String
}

import CoreData

class CoreDataService {
    
    static let shared = CoreDataService()
    
    private init() {}
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Shelf")
        
        // Enable automatic lightweight migration
        let description = container.persistentStoreDescriptions.first
        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = true
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                #if DEBUG
                // For development, delete and recreate if migration fails
                self.deleteAndRecreateStore()
                #else
                fatalError("Unresolved error \(error), \(error.userInfo)")
                #endif
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - CRUD Operations
    
    func saveBooks(_ books: [Datum], completion: ((Bool) -> Void)? = nil) {
        context.perform { [weak self] in
            guard let self = self else { return }
            
            do {
                for bookData in books {
                    let request: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "id == %d", bookData.id ?? 0)
                    
                    let book: BookEntity
                    if let existingBook = try self.context.fetch(request).first {
                        book = existingBook
                    } else {
                        book = BookEntity(context: self.context)
                        book.id = Int32(bookData.id ?? 0)
                    }
                    
                    // Update all properties
                    book.title = bookData.title
                    book.publisher = bookData.publisher
                    book.isbn = bookData.isbn
                    book.pages = Int32(bookData.pages ?? 0)
                    book.year = Int32(bookData.year ?? 0)
                    book.handle = bookData.handle
                    
                    if let notes = bookData.notes {
                        book.notes = notes.joined(separator: ", ")
                    }
                    
                    if let createdAt = bookData.createdAt {
                        let isoFormatter = ISO8601DateFormatter()
                        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                        book.createdAt =  isoFormatter.date(from: createdAt)
//                        createdAt
                       
                    }
                }
                
                try self.context.save()
                completion?(true)
            } catch {
                print("Failed to save books: \(error)")
                completion?(false)
            }
        }
    }
    
    func fetchAllBooks() -> [BookEntity] {
        let request: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching books: \(error)")
            return []
        }
    }
    
    func deleteAllBooks() {
        let request: NSFetchRequest<NSFetchRequestResult> = BookEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Error deleting all books: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    private func deleteAndRecreateStore() {
        guard let storeURL = persistentContainer.persistentStoreDescriptions.first?.url else {
            fatalError("Could not get store URL")
        }
        
        do {
            try persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
            
            // Try loading again
            persistentContainer.loadPersistentStores { _, error in
                if let error = error {
                    fatalError("Failed to load store after deletion: \(error)")
                }
            }
        } catch {
            fatalError("Failed to delete store: \(error)")
        }
    }
}
