//
//  Post.swift
//  MobileAcebook
//
//  Created by Matthew Shepherd on 19/02/2024.
//

import SwiftUI

public struct Post: Codable, Identifiable {
    public let id: String
    let message: String
    let image: String
    let createdBy: String?
    let createdAtString: String // Keep createdAt as a String type
    let likes: [String]
    let comments: Int
    
    // Convert createdAtString to a Date object
    public var createdAt: Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: createdAtString) ?? Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case message, image, createdBy, createdAtString = "createdAt" // Map createdAtString to createdAt
        case likes, comments
    }
}
