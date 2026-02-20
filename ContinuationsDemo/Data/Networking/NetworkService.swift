//
//  NetworkService.swift
//  ContinuationsDemo
//
//  Created by Abraham Gonzalez Puga on 19/02/26.
//
import Foundation

enum NetworkError: Error {
    case badURL
    case noData
    case decodingFailed
    case generic
}

class NetworkService {
    
    private let url = "https://jsonplaceholder.typicode.com/posts"
    
    // MARK: Classic completion handler
    // Before async/await
    func fetchPostsWithCompletion(completion: @escaping (Result<[PostDTO], NetworkError>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(.generic))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let posts = try JSONDecoder().decode([PostDTO].self, from: data)
                completion(.success(posts))
            } catch {
                completion(.failure(.decodingFailed))
            }
        }.resume()
    }
    
    // MARK: Using Continuations
    func fetchPosts() async throws -> [Post] {
        return try await withCheckedThrowingContinuation { continuation in
            fetchPostsWithCompletion { result in
                switch result {
                case .success(let postsDTO):
                    let posts = postsDTO.map({ $0.toDomain() })
                    continuation.resume(returning: posts)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
