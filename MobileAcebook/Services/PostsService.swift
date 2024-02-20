//
//  PostsService.swift
//  MobileAcebook
//
//  Created by Matthew Shepherd on 19/02/2024.
//

import SwiftUI

struct getPostResponse: Codable {
    let posts: [Post]
    let user: User?
    let token: String
}

struct getPostOwnerDataResponse: Codable {
    let ownerData: User
    let token: String
}

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
                let response = try JSONDecoder().decode(getPostResponse.self, from: data)
                DispatchQueue.main.async {
                    self.posts = response.posts
                    for post in self.posts {
                        self.getPostOwnerData(ownerID: post.createdBy ?? "", token: token) { owner in
                            if let owner = owner {
                                // Update createdByUsername for the post
                                if let index = self.posts.firstIndex(where: { $0.id == post.id }) {
                                    self.posts[index].createdByUsername = owner.username
                                }
                            }
                        }
                    }
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }
    func getPostOwnerData(ownerID: String, token: String, completion: @escaping (User?) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:8080/posts/\(ownerID)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                if let error = error {
                    print("Error: \(error)")
                }
                completion(nil)
                return
            }

            do {
                let response = try JSONDecoder().decode(getPostOwnerDataResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(response.ownerData) // Directly pass ownerData to the completion handler
                }
            } catch {
                print("Error decoding JSON: \(error)")
                completion(nil)
            }
        }.resume()
    }
}

