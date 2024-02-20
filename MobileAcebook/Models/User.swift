//
//  User.swift
//  MobileAcebook
//
//  Created by Josué Estévez Fernández on 01/10/2023.
//

public struct User: Codable {
    let id: String
    let username: String
    let avatar: String
    let email: String
    let password: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case username, avatar, email, password
    }
}
