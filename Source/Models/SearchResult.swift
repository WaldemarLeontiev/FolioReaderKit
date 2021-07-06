//
//  SearchResult.swift
//  FolioReaderKit
//
//  Created by Waldemar Leontiev on 28.06.2021.
//

import Foundation

struct SearchResult {
    let id: String = UUID().uuidString
    let page: Int
    let content: String
    let contentPre: String
    let contentPost: String
    let chapterName: String?
}

class Search {
    private init() {}
    static var results: [SearchResult]?
    static var text: String?
}
