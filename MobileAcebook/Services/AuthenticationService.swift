//
//  AuthenticationService.swift
//  MobileAcebook
//
//  Created by Josué Estévez Fernández on 01/10/2023.
//

import SwiftUI

struct LoginResponse: Decodable {
    let message: String
    let token: String
}

class AuthenticationService: AuthenticationServiceProtocol, ObservableObject {
    @Published var token = ""
    
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
    
    
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:8080/tokens") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
                return
            }
            
            if response.statusCode == 201 {
                if let response = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                    DispatchQueue.main.async {
                        self.token = response.token
                        print(self.token)
                    }
                    print("Login successful")
                    completion(true)
                }
            } else {
                print("Login failed with status code: \(response.statusCode)")
                completion(false)
            }
        }.resume()
    }
}
//        @Published var token: String = ""
//    func login(email:String,password:String,completion:@escaping(Bool) -> Void) {
//        
//        
//        guard let url = URL(string:"http://127.0.0.1:8080/tokens") else {return}
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        let parameters: [String: Any] = [
//            "email": email,
//            "password": password
//            
//        ]
//        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
//                //errorMessage = "Error: \(error?.localizedDescription ?? "Unknown error")"
//                return
//            }
//            let token = try? JSONDecoder().decode(String.self, from: data)
//                            DispatchQueue.main.async{
//                                self.token = token ?? ""
//                                print(self.token)
//                                completion(true)
//                            }
//            if response.statusCode == 200 {
//                //token = response.token
//                //invalidLogin = false
//                print("Login successful")
//            } else {
//                //invalidLogin  = true
//                //errorMessage = "Invalid username or password"
//                print(response)
//            }
//        }.resume()
//    }
//            
//        }
//   //}
//    
//    
//    
//
//
