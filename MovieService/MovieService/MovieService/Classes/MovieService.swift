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
//    func loadImage(for movie: MovieListItem, completion: @escaping (UIImage?) -> Void)
}

public class MovieService: MovieServiceProtocol {
    let apiKey = "e0704089dab5a4884ecf67ab2aef73dd"
//    private let imageBaseURL = "https://image.tmdb.org/t/p/w500/"
    
    public init() {}

    public func getMovies(completion: @escaping (Result<MovieListModel, Error>) -> Void) {
        
        let urlString = "https://api.themoviedb.org/3/movie/popular?api_key=\(apiKey)"
        
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
                        //                        self.movieListModel = movies
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
        
        let urlString = "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&query=\(query)"
        
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
    
}

