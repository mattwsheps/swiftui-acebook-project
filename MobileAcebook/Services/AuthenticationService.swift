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
        var request = URLRequest(url:url)
        let payload = ["email": user.email, "username": user.username, "password": user.password, "avatar": user.avatar]
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error encoding JSON: \(error)")
            return false
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
               if let error = error {
                   print("Error: \(error)")
            }
            print(response as Any)
            return
           }
        }
        task.resume()
        return true // placeholder
    }
}

