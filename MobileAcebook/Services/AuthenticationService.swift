//
//  AuthenticationService.swift
//  MobileAcebook
//
//  Created by Josué Estévez Fernández on 01/10/2023.
//

import SwiftUI

class AuthenticationService: AuthenticationServiceProtocol, ObservableObject {
    @Published var posts: [Post] = []
    
    func signUp(user: User) -> Bool {
        // Logic to call the backend API for signing up
        return true // placeholder
    }
    
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

