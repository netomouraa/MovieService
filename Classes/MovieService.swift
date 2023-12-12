//
//  MovieService.swift
//  MovieService_Example
//
//  Created by Neto Moura on 11/12/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import Combine
import UIKit

public protocol MovieServiceProtocol {
    func getMovies() -> AnyPublisher<MovieListModel, Error>
    func searchMovies(query: String) -> AnyPublisher<MovieListModel, Error>
    func loadImage(for movie: MovieListItem) -> AnyPublisher<UIImage?, Error>
}

public class MovieService: MovieServiceProtocol {
    private let baseURL = "https://api.themoviedb.org/3/"
    
    private let popularMoviesURL = "movie/popular?api_key="
    private let searchURL = "search/movie?api_key="
    private let imageBaseURL = "https://image.tmdb.org/t/p/w500/"
    
    public init() {}

    public func getMovies() -> AnyPublisher<MovieListModel, Error> {
        let urlString = "\(baseURL)\(popularMoviesURL)\(APIKeys.apiKey)"
        guard let url = URL(string: urlString) else {
            return Fail(error: NSError(domain: "URL Inválida", code: 0, userInfo: nil)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: MovieListModel.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    public func searchMovies(query: String) -> AnyPublisher<MovieListModel, Error> {
        guard !query.isEmpty else {
            return Fail(error: MovieServiceError.emptyQuery).eraseToAnyPublisher()
        }

        let urlString = "\(baseURL)\(searchURL)\(APIKeys.apiKey)&query=\(query)"
        
        guard let url = URL(string: urlString) else {
            let error = MovieServiceError.invalidURL
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: MovieListModel.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    public func loadImage(for movie: MovieListItem) -> AnyPublisher<UIImage?, Error> {
        guard let path = movie.posterPath,
              let url = URL(string: "\(imageBaseURL)\(path)") else {
            return Just(nil)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        if let data = URLCache.shared.cachedResponse(for: URLRequest(url: url))?.data,
           let image = UIImage(data: data) {
            return Just(image)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return URLSession.shared.dataTaskPublisher(for: url)
                .map(\.data)
                .tryMap { data throws -> UIImage in
                    guard let image = UIImage(data: data) else {
                        throw MovieServiceError.invalidImageData
                    }

                    let response = URLResponse(url: url, mimeType: "image/jpeg", expectedContentLength: data.count, textEncodingName: nil)
                    let cachedResponse = CachedURLResponse(response: response, data: data)
                    URLCache.shared.storeCachedResponse(cachedResponse, for: URLRequest(url: url))

                    return image
                }
                .mapError { _ in MovieServiceError.imageLoadingFailed }
                .eraseToAnyPublisher()
        }
    }

    
}


enum MovieServiceError: Error {
    case invalidImageData
    case imageLoadingFailed
    case emptyQuery
    case invalidURL
}

enum APIKeys {
    static let apiKey = "e0704089dab5a4884ecf67ab2aef73dd"
}
