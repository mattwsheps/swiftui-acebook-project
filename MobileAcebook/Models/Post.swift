//
//  Post.swift
//  MobileAcebook
//
//  Created by Matthew Shepherd on 19/02/2024.
//

import SwiftUI

public struct Post: Codable, Identifiable {
    public let id: String
    var message: String
    var image: String
    var createdBy: String?
    var createdByUsername: String?
    var createdByAvatar: String?
    let createdAtString: String // Keep createdAt as a String type
    var likes: [String]
    var likesCount: Int?
    let comments: Int
    
    // Convert createdAtString to a Date object
    public var createdAt: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // Use the correct format
        return formatter.date(from: createdAtString) ?? Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case message, image, createdBy, createdAtString = "createdAt" // Map createdAtString to createdAt
        case likes, comments
    }
}

