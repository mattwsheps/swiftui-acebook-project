//
//  PostsServiceProtocol.swift
//  MobileAcebook
//
//  Created by Matthew Shepherd on 19/02/2024.
//

public protocol PostsServiceProtocol {
    func getPosts(token: String)
    func getPostOwnerData(ownerID:String, token: String, completion: @escaping (User?) -> Void)
    func createPost(token: String, message: String, image: String?, completion: @escaping (Bool, Error?) -> Void)
}
