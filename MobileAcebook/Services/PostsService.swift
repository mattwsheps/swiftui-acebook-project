//
//  PostsService.swift
//  MobileAcebook
//
//  Created by Matthew Shepherd on 19/02/2024.
//

import SwiftUI

class PostsService: PostsServiceProtocol, ObservableObject {
    @Published var posts: [Post] = []
    
    func getPosts(token: String) {
        guard let url = URL(string: "http://127.0.0.1:8080/posts") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }
            
            do {
                let response = try JSONDecoder().decode(PostResponse.self, from: data)
                DispatchQueue.main.async {
                    self.posts = response.posts
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }
}

struct PostResponse: Codable {
    let posts: [Post]
    let user: User?
    let token: String
}
