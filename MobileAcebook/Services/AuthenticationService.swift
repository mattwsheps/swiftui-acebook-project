//
//  AuthenticationService.swift
//  MobileAcebook
//
//  Created by Josué Estévez Fernández on 01/10/2023.
//

import Foundation

class AuthenticationService: AuthenticationServiceProtocol {
    func signUp(user: User) -> Bool {
        guard let url = URL(string: "http://127.0.0.1:8080/users") else { return false }
        print(user)
        var request = URLRequest(url:url)
//        var payload = ["email": user.email, "username": user.username]
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = "email=\(user.email)".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
               if let error = error {
                   print("Error: \(error)")
               }
            print(response)
               return
           }
        }
        task.resume()
        return true // placeholder
    }
}

//guard let url = URL(string: "http://127.0.0.1:8080/posts") else { return }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data, error == nil else {
//                if let error = error {
//                    print("Error: \(error)")
//                }
//                return
//            }
//            
//            do {
//                let response = try JSONDecoder().decode(PostResponse.self, from: data)
//                DispatchQueue.main.async {
//                    self.posts = response.posts
//                }
//            } catch {
//                print("Error decoding JSON: \(error)")
//            }
//        }.resume()

