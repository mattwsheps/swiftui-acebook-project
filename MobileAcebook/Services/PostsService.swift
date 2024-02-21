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
    private let baseUrlString = "http://127.0.0.1:8080"
    
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
                    completion(response.ownerData)
                }
            } catch {
                print("Error decoding JSON: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    func createPost(token: String, message: String, image: String?, completion: @escaping (Bool, Error?) -> Void) {
            guard let url = URL(string: "\(baseUrlString)/posts") else { return } // if the baseurl is false return does not run the code
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Include the Authorization header
            
            let parameters: [String: Any] = [
                "message": message,
                "publicID": image ?? ""
            ]
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let httpResponse = response as? HTTPURLResponse, error == nil else {
                    completion(false, error)
                    return
                }
                
                // Check the response status code for success
                if (200...299).contains(httpResponse.statusCode) {
                    completion(true, nil)
                } else {
                    print("Unexpected status code: \(httpResponse.statusCode)")
                    if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                        print("Response body: \(responseBody)")
                    }
                    completion(false, nil)
                }
            }.resume()
        }
}

