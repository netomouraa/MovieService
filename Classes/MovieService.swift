//
//  MovieService.swift
//  MovieService_Example
//
//  Created by Neto Moura on 11/12/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

public protocol MovieServiceProtocol {
    func getMovies(completion: @escaping (Result<MovieListModel, Error>) -> Void)
    func searchMovies(query: String, completion: @escaping (Result<MovieListModel, Error>?) -> Void)
    func loadImage(for movie: MovieListItem, completion: @escaping (UIImage?) -> Void)
}

public class MovieService: MovieServiceProtocol {
    let apiKey = "e0704089dab5a4884ecf67ab2aef73dd"
    private let baseURL = "https://api.themoviedb.org/3/"
    
    private let popularMoviesURL = "movie/popular?api_key="
    private let searchURL = "search/movie?api_key="
    private let imageBaseURL = "https://image.tmdb.org/t/p/w500/"
    
    public init() {}

    public func getMovies(completion: @escaping (Result<MovieListModel, Error>) -> Void) {
        
        let urlString = "\(baseURL)\(popularMoviesURL)\(apiKey)"
        
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "Dados vazios", code: 0, userInfo: nil)))
                    return
                }
                
                do {
                    let movies = try JSONDecoder().decode(MovieListModel.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(movies))
                    }
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    public func searchMovies(query: String, completion: @escaping (Result<MovieListModel, Error>?) -> Void) {
        guard !query.isEmpty else {
            return
        }
        
        let urlString = "\(baseURL)\(searchURL)\(apiKey)&query=\(query)"
        
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    do {
                        let result = try JSONDecoder().decode(MovieListModel.self, from: data)
                        DispatchQueue.main.async {
                            completion(.success(result))
                        }
                    } catch {
                        print("Erro ao decodificar JSON: \(error)")
                    }
                } else if let error = error {
                    print("Erro na requisição: \(error)")
                }
            }.resume()
        }
    }
    
    public func loadImage(for movie: MovieListItem, completion: @escaping (UIImage?) -> Void) {
        guard let path = movie.posterPath,
              let url = URL(string: "\(imageBaseURL)\(path)") else {
            completion(nil)
            return
        }
        // Tenta carregar a imagem do cache
        if let data = URLCache.shared.cachedResponse(for: URLRequest(url: url))?.data,
           let image = UIImage(data: data) {
            completion(image)
        } else {
            // Se a imagem não estiver em cache, faz o download
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    // Armazena a imagem em cache
                    let response = URLResponse(url: url, mimeType: "image/jpeg", expectedContentLength: data.count, textEncodingName: nil)
                    let cachedResponse = CachedURLResponse(response: response, data: data)
                    URLCache.shared.storeCachedResponse(cachedResponse, for: URLRequest(url: url))
                    completion(image)
                } else {
                    completion(nil)
                }
            }.resume()
        }
    }
    
}

