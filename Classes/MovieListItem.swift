//
//  MovieListItem.swift
//  MovieService_Example
//
//  Created by Neto Moura on 11/12/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

public struct MovieListItem: Codable {
    public let id: Int
    public let title: String
    public let overview: String
    public let releaseDate: String
    public let posterPath: String?
    public let voteAverage: Double

    public init(id: Int, title: String, overview: String, releaseDate: String, posterPath: String?, voteAverage: Double) {
        self.id = id
        self.title = title
        self.overview = overview
        self.releaseDate = releaseDate
        self.posterPath = posterPath
        self.voteAverage = voteAverage
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case releaseDate = "release_date"
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
    }
}
