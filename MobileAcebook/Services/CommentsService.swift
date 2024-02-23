//
//  CommentsService.swift
//  MobileAcebook
//
//  Created by Matthew Shepherd on 23/02/2024.
//

import SwiftUI

struct getCommentsByPostIdResponse: Codable {
    let comments: [Comment]
    let token: String
}

struct getCommentOwnerDataResponse: Codable {
    let commentOwnerData: User
    let token: String
}


class CommentsService: CommentsServiceProtocol, ObservableObject {
    @Published var comments: [Comment] = []
    @Published var user: User?
    @Published var likedStates: [String: Bool] = [:]
    @Published var token: String = ""
    private let baseUrlString = "http://127.0.0.1:8080"
    
    func getCommentsByPostId(token: String, postId: String) {
        guard let url = URL(string: "\(baseUrlString)/comments/\(postId)") else { return }
        
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
                let response = try JSONDecoder().decode(getCommentsByPostIdResponse.self, from: data)
                DispatchQueue.main.async {
                    self.comments = response.comments
                    print("success", self.comments)
                    self.token = response.token
                    //                    if let userID = self.user?.id {
                    //                        for post in self.comments {
                    //                            let isLiked = post.likes.contains(userID)
                    //                            self.likedStates[post.id] = isLiked
                    //                        }
                    //                    }
                    for comment in self.comments {
                        self.getCommentOwnerData(ownerID: comment.createdBy ?? "", token: token) { owner in
                            if let owner = owner {
                                // Update createdByUsername for the post
                                if let index = self.comments.firstIndex(where: { $0.id == comment.id }) {
                                    self.comments[index].createdByUsername = owner.username
                                    self.comments[index].createdByAvatar = owner.avatar
                                    //                                    self.comments[index].likesCount = self.posts[index].likes.count
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
    func getCommentOwnerData(ownerID: String, token: String, completion: @escaping (User?) -> Void) {
        guard let url = URL(string: "\(baseUrlString)/comments/owner/\(ownerID)") else { return }
        
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
                let response = try JSONDecoder().decode(getCommentOwnerDataResponse.self, from: data)
                DispatchQueue.main.async {
                    self.token = response.token
                    completion(response.commentOwnerData)
                }
            } catch {
                print("Error decoding JSON: \(error)")
                completion(nil)
            }
        }.resume()
    }
    func createComment(token: String, postId: String, message: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let url = URL(string: "\(baseUrlString)/comments/\(postId)") else { return } // if the baseurl is false return does not run the code
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Include the Authorization header
        
        let parameters: [String: Any] = [
            "comment": message,
            "postId": postId
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
