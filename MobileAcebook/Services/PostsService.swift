//
//  PostsService.swift
//  MobileAcebook
//
//  Created by Matthew Shepherd on 19/02/2024.
//

import SwiftUI

struct getPostResponse: Codable {
    let posts: [Post]
    let user: User
    let token: String
}

struct getPostOwnerDataResponse: Codable {
    let ownerData: User
    let token: String
}

struct LikeResponse: Decodable {
    let message: String
    let likes: Int
}

class PostsService: PostsServiceProtocol, ObservableObject {
    @Published var posts: [Post] = []
    @Published var user: User?
    @Published var likedStates: [String: Bool] = [:]
    @Published var token: String = ""
    private let baseUrlString = "http://127.0.0.1:8080"
    
    func getPosts(token: String) {
        guard let url = URL(string: "\(baseUrlString)/posts") else { return }
        
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
                    self.user = response.user
                    self.token = response.token
                    if let userID = self.user?.id {
                        for post in self.posts {
                            let isLiked = post.likes.contains(userID)
                            self.likedStates[post.id] = isLiked
                        }
                    }
                    for post in self.posts {
                        self.getPostOwnerData(ownerID: post.createdBy ?? "", token: token) { owner in
                            if let owner = owner {
                                // Update createdByUsername for the post
                                if let index = self.posts.firstIndex(where: { $0.id == post.id }) {
                                    self.posts[index].createdByUsername = owner.username
                                    self.posts[index].createdByAvatar = owner.avatar
                                    self.posts[index].likesCount = self.posts[index].likes.count
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
        guard let url = URL(string: "\(baseUrlString)/posts/\(ownerID)") else { return }

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
                    self.token = response.token
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
    func uploadImageToCloudinary(imageData: Data, completion: @escaping (Result<String, Error>) -> Void) {
            let cloudName = "dououppib" // Make sure this is your correct Cloudinary cloud name
            let uploadPreset = "Acebook" // Replace with your actual unsigned upload preset

            let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            // Setting content type to JSON for the request
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body: [String: Any] = [
                "file": "data:image/jpeg;base64,\(imageData.base64EncodedString())",
                "upload_preset": uploadPreset
            ]

            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("Networking error: \(error?.localizedDescription ?? "Unknown error")")
                    completion(.failure(error ?? URLError(.badServerResponse)))
                    return
                }

                // Attempt to print the whole response body for debugging
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Full response body: \(responseString)")
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    print("HTTP Response Status Code: \(httpResponse.statusCode)")
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }

                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        // Checking and printing the entire JSON response for debugging
                        print("JSON Response: \(jsonResponse)")

                        if let imageUrl = jsonResponse["secure_url"] as? String {
                            completion(.success(imageUrl))
                        } else {
                            print("Error: 'secure_url' not found in response. Full JSON: \(jsonResponse)")
                            completion(.failure(URLError(.cannotParseResponse)))
                        }
                    } else {
                        print("Failed to decode JSON. Full response: \(String(data: data, encoding: .utf8) ?? "Invalid response data")")
                        completion(.failure(URLError(.cannotParseResponse)))
                    }
                } catch {
                    print("JSON Decoding Error: \(error)")
                    completion(.failure(error))
                }
            }.resume()
        }

    func likePost(token: String, postID: String, completion: @escaping (Int?) -> Void) {
        guard let url = URL(string: "\(baseUrlString)/posts/\(postID)/like") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
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
                let response = try JSONDecoder().decode(LikeResponse.self, from: data)
                DispatchQueue.main.async {
                    if let index = self.posts.firstIndex(where: { $0.id == postID }) {
                        self.posts[index].likesCount = response.likes
                    }
                    completion(response.likes)
                }
            } catch {
                print("Error decoding JSON: \(error)")
                completion(nil)
            }
        }.resume()
    }
}

