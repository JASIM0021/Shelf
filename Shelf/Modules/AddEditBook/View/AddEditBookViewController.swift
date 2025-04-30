//
//  AddEditBookViewController.swift
//  Shelf
//
//  Created by Sk Jasimuddin on 30/04/25.
//

import UIKit
import CoreData

class EditBookViewController: UIViewController {
    
    var book: Datum?
    var viewModel: BookListViewModel!
    
    // UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    // Form Fields
    private let titleTextField = UITextField()
    private let publisherTextField = UITextField()
    private let yearTextField = UITextField()
    private let isbnTextField = UITextField()
    private let pagesTextField = UITextField()
    private let handleTextField = UITextField()
    private let notesTextView = UITextView()
    private let saveButton = UIButton(type: .system)
    private let dateLabel = UILabel()
    
    // Date Formatter
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    
    var onDismiss: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateFields()
        setupKeyboardHandling()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = book == nil ? "Add New Book" : "Edit Book"
        
        configureScrollView()
        configureStackView()
        configureFormFields()
        configureSaveButton()
        configureDateLabel()
    }
    
    private func configureScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func configureStackView() {
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func configureFormFields() {
        // Title Field
        addFormField(label: "Title*", textField: titleTextField)
        titleTextField.placeholder = "Enter book title"
        
        // Publisher Field
        addFormField(label: "Publisher", textField: publisherTextField)
        publisherTextField.placeholder = "Enter publisher name"
        
        // Year Field
        addFormField(label: "Year", textField: yearTextField)
        yearTextField.placeholder = "Publication year"
        yearTextField.keyboardType = .numberPad
        
        // ISBN Field
        addFormField(label: "ISBN", textField: isbnTextField)
        isbnTextField.placeholder = "Enter ISBN number"
        isbnTextField.keyboardType = .numbersAndPunctuation
        
        // Pages Field
        addFormField(label: "Pages", textField: pagesTextField)
        pagesTextField.placeholder = "Number of pages"
        pagesTextField.keyboardType = .numberPad
        
        // Handle Field
        addFormField(label: "Handle", textField: handleTextField)
        handleTextField.placeholder = "Unique identifier"
        
        // Notes Field
        let notesLabel = UILabel()
        notesLabel.text = "Notes"
        notesLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        stackView.addArrangedSubview(notesLabel)
        
        notesTextView.layer.borderColor = UIColor.systemGray4.cgColor
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.cornerRadius = 8
        notesTextView.font = UIFont.systemFont(ofSize: 16)
        notesTextView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        notesTextView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        stackView.addArrangedSubview(notesTextView)
    }
    
    private func addFormField(label: String, textField: UITextField) {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        stackView.addArrangedSubview(labelView)
        
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        stackView.addArrangedSubview(textField)
    }
    
    private func configureDateLabel() {
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = .secondaryLabel
        dateLabel.textAlignment = .center
        stackView.addArrangedSubview(dateLabel)
        
        if book == nil {
            dateLabel.text = "Created: \(dateFormatter.string(from: Date()))"
        } else if let createdAt = book?.createdAt {
            let isoFormatter = ISO8601DateFormatter()
            if let date = isoFormatter.date(from: createdAt) {
                dateLabel.text = "Created: \(dateFormatter.string(from: date))"
            }
        }
    }
    
    private func configureSaveButton() {
        saveButton.setTitle("Save Book", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 10
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        stackView.addArrangedSubview(saveButton)
    }
    
    private func populateFields() {
        guard let book = book else { return }
        
        titleTextField.text = book.title
        publisherTextField.text = book.publisher
        yearTextField.text = book.year != nil ? "\(book.year!)" : ""
        isbnTextField.text = book.isbn
        pagesTextField.text = book.pages != nil ? "\(book.pages!)" : ""
        handleTextField.text = book.handle
        notesTextView.text = book.notes?.joined(separator: "\n")
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        // Scroll to active field if needed
        if let activeField = findFirstResponder() {
            let rect = activeField.convert(activeField.bounds, to: scrollView)
            scrollView.scrollRectToVisible(rect, animated: true)
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    private func findFirstResponder() -> UIView? {
        for view in [titleTextField, publisherTextField, yearTextField, isbnTextField, pagesTextField, handleTextField, notesTextView] {
            if view.isFirstResponder {
                return view
            }
        }
        return nil
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func saveTapped() {
        guard let title = titleTextField.text?.trimmingCharacters(in: .whitespaces), !title.isEmpty else {
            showAlert(message: "Title is required")
            return
        }
        
        // For new books, set current date
        let createdAt: String? = book?.createdAt ?? {
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return isoFormatter.string(from: Date())
        }()
        
        let bookData = Datum(
            id: book?.id ?? Int.random(in: 0...1000),
            year: Int(yearTextField.text ?? ""),
            title: title,
            handle: handleTextField.text?.trimmingCharacters(in: .whitespaces),
            publisher: publisherTextField.text?.trimmingCharacters(in: .whitespaces),
            isbn: isbnTextField.text?.trimmingCharacters(in: .whitespaces),
            pages: Int(pagesTextField.text ?? ""),
            notes: notesTextView.text.isEmpty ? nil : [notesTextView.text],
            createdAt: createdAt,
            villains: book?.villains
        )
        
        viewModel.saveBook(bookData) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.onDismiss?()
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    self?.showAlert(message: "Failed to save book")
                }
            }
            
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
