//
//  MovieServiceError.swift
//  MovieService
//
//  Created by Neto Moura on 12/12/23.
//

import Foundation

enum MovieServiceError: Error {
    case emptyQuery
    case invalidURL
    case invalidImageData
    case imageLoadingFailed
}


