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
            // Se a consulta estiver vazia, retornar um erro apropriado
            return Fail(error: MovieServiceError.emptyQuery).eraseToAnyPublisher()
        }

        let urlString = "\(baseURL)\(searchURL)\(APIKeys.apiKey)&query=\(query)"
        guard let url = URL(string: urlString) else {
            // Se a URL for inválida, retornar um erro
            return Fail(error: MovieServiceError.invalidURL).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: MovieListModel.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
//    public func searchMovies(query: String, completion: @escaping (Result<MovieListModel, Error>?) -> Void) {
//        guard !query.isEmpty else {
//            return
//        }
//        
//        let urlString = "\(baseURL)\(searchURL)\(APIKeys.apiKey)&query=\(query)"
//        
//        if let url = URL(string: urlString) {
//            URLSession.shared.dataTask(with: url) { data, _, error in
//                if let data = data {
//                    do {
//                        let result = try JSONDecoder().decode(MovieListModel.self, from: data)
//                        DispatchQueue.main.async {
//                            completion(.success(result))
//                        }
//                    } catch {
//                        print("Erro ao decodificar JSON: \(error)")
//                    }
//                } else if let error = error {
//                    print("Erro na requisição: \(error)")
//                }
//            }.resume()
//        }
//    }
    
    public func loadImage(for movie: MovieListItem) -> AnyPublisher<UIImage?, Error> {
        guard let path = movie.posterPath,
              let url = URL(string: "\(imageBaseURL)\(path)") else {
            return Just(nil)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        // Tenta carregar a imagem do cache
        if let data = URLCache.shared.cachedResponse(for: URLRequest(url: url))?.data,
           let image = UIImage(data: data) {
            return Just(image)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            // Se a imagem não estiver em cache, faz o download
            return URLSession.shared.dataTaskPublisher(for: url)
                .map(\.data)
                .tryMap { data throws -> UIImage in
                    guard let image = UIImage(data: data) else {
                        throw MovieServiceError.invalidImageData
                    }

                    // Armazena a imagem em cache
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

