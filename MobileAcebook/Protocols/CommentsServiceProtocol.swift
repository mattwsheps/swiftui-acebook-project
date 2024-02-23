//
//  CommentsServiceProtocol.swift
//  MobileAcebook
//
//  Created by Matthew Shepherd on 23/02/2024.
//

public protocol CommentsServiceProtocol {
    func getCommentsByPostId(token: String, postId: String)
    func getCommentOwnerData(ownerID:String, token: String, completion: @escaping (User?) -> Void)
    func createComment(token: String, postId: String, message: String, completion: @escaping (Bool, Error?) -> Void)
}
