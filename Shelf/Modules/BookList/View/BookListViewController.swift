//
//  BookListViewController.swift
//  Shelf
//
//  Created by Sk Jasimuddin on 30/04/25.
//

import Foundation
import UIKit

import UIKit

class BookListViewController: UIViewController {
    
    @IBOutlet weak var listTableView: UITableView!
    private let viewModel = BookListViewModel()
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupSearchController()
        loadData()
        
        viewModel.apiObserver = {[weak self] event in
            
            switch event {
                
            case .loading:
                self?.startActivityIndicator()
            case .loaded:
                self?.stopActivityIndicator()
            default:
                break
                
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh data when returning from edit screen
        viewModel.groupAndSortBooks()
        listTableView.reloadData()
        self.navigationItem.hidesBackButton = true
    }
    
    private func setupUI() {
        title = "Shelf"
        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.register(UINib(nibName: "ListCell", bundle: nil), forCellReuseIdentifier: "ListCell")
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewBook)
        )
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Filter by author"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func loadData() {
        viewModel.fetchInitialData { [weak self] in
            self?.listTableView.reloadData()
        }
    }
    
    @objc private func addNewBook() {
        showEditScreen()
    }
    
    private func showEditScreen(for book: BookEntity? = nil) {
        let editVC = EditBookViewController()
        if let book = book {
            editVC.book = convertToDatum(book)
           
        }
        editVC.viewModel = self.viewModel
        editVC.onDismiss = { [weak self] in
              self?.viewModel.fetchInitialData { [weak self] in
                  self?.listTableView.reloadData()
              }
          }
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    private func convertToDatum(_ book: BookEntity) -> Datum {
        return Datum(
            id: Int(book.id),
            year: Int(book.year),
            title: book.title,
            handle: book.handle,
            publisher: book.publisher,
            isbn: book.isbn,
            pages: Int(book.pages),
            notes: book.notes?.components(separatedBy: ", "),
            createdAt: nil,
            villains: nil
        )
    }
}

// MARK: - Table View Data Source & Delegate
extension BookListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.groupedBooks.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.groupedBooks[section].books.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "📚 Created: \(viewModel.groupedBooks[section].date)"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as? ListCell else {
            return UITableViewCell()
        }
        
        let book = viewModel.groupedBooks[indexPath.section].books[indexPath.row]
        let bookData = convertToDatum(book)
        cell.prepaireCell(bookData)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let book = viewModel.groupedBooks[indexPath.section].books[indexPath.row]
        showEditScreen(for: book)
    }
}

// MARK: FOR SWIPE DELITING
extension BookListViewController {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            self?.deleteBook(at: indexPath, completion: completion)
        }
        deleteAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    private func deleteBook(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        viewModel.apiObserver?(.loading)
        
        viewModel.deleteBook(at: indexPath) { [weak self] success in
            DispatchQueue.main.async {
                self?.viewModel.apiObserver?(.loaded)
                
                if success {
                    // Update the table view
                    self?.listTableView.performBatchUpdates({
                        self?.listTableView.deleteRows(at: [indexPath], with: .automatic)
                        
                        // Check if section is now empty
                        if let sectionCount = self?.viewModel.groupedBooks[indexPath.section].books.count,
                           sectionCount == 0 {
                            self?.viewModel.groupedBooks.remove(at: indexPath.section)
                            self?.listTableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
                        }
                    }, completion: nil)
                } else {
                    self?.showErrorAlert(message: "Failed to delete book")
                }
                completion(success)
            }
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Search Results Updating
extension BookListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        viewModel.filterBooks(by: searchText)
        listTableView.reloadData()
    }
}

// MARK: - XIB Loading

extension BookListViewController {
    
    class func loadFromXIB() -> BookListViewController? {
        
        let storyboard = UIStoryboard(name: "BookListViewController", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "BookListViewController")  as? BookListViewController else {return nil}
        
        return vc
    }
}

