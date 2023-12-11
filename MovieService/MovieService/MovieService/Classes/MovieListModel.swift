//
//  MovieListModel.swift
//  MovieService_Example
//
//  Created by Neto Moura on 11/12/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

//struct MovieListModel: Codable {
//    let page: Int
//    let results: [MovieListItem]
//    let totalPages: Int
//    let totalResults: Int
//    
//    enum CodingKeys: String, CodingKey {
//        case page
//        case results
//        case totalPages = "total_pages"
//        case totalResults = "total_results"
//    }
//}


public struct MovieListModel: Codable {
    public let page: Int
    public let results: [MovieListItem]
    public let totalPages: Int
    public let totalResults: Int

    public init(page: Int, results: [MovieListItem], totalPages: Int, totalResults: Int) {
        self.page = page
        self.results = results
        self.totalPages = totalPages
        self.totalResults = totalResults
    }
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
