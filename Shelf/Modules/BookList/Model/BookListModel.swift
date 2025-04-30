//
//  BookListModel.swift
//  Shelf
//
//  Created by Sk Jasimuddin on 30/04/25.
//

import Foundation


import Foundation
// MARK: - BookModel
struct BookModel: Codable {
    let data: [Datum]
}

// MARK: - Datum
struct Datum: Codable {
    let id, year: Int?
    let title, handle, publisher, isbn: String?
    let pages: Int?
    let notes: [String]?
    let createdAt: String?
    let villains: [Villain]?
    

    enum CodingKeys: String, CodingKey {
        case id
        case year = "Year"
        case title = "Title"
        case handle
        case publisher = "Publisher"
        case isbn = "ISBN"
        case pages = "Pages"
        case notes = "Notes"
        case createdAt = "created_at"
        case villains
    }
}

// MARK: - Villain
struct Villain: Codable {
    let name: String
    let url: String
}


struct Book : Codable {
    let title: String, author: String, dateOfPublish: Date, desc: String
}
