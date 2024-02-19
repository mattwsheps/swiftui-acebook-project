//
//  FeedPageView.swift
//  MobileAcebook
//
//  Created by Matthew Shepherd on 19/02/2024.
//

import SwiftUI

struct FeedPageView: View {
    @ObservedObject var authenticationService = AuthenticationService()
    @State private var token: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNjVkMzc1NGRkZTkyOTg1NjZlYjJjOTFhIiwiaWF0IjoxNzA4MzY0MjI4LCJleHAiOjE3MDgzNjc4Mjh9.tgjApiPNqh-alYuIFLpzwSiLiud5YZDiQNmY91nxK-I"
    
    var body: some View {
        List(authenticationService.posts) { post in
            VStack(alignment: .leading) {
                Text(post.message) // Assuming message is the content of the post
                    .font(.headline)
                Text(post.image) // Assuming image is the URL or identifier for the post image
                    .font(.subheadline)
            }
        }
        .onAppear {
            authenticationService.getPosts(token: token)
        }
    }
}

struct FeedPageView_Previews: PreviewProvider {
    static var previews: some View {
        FeedPageView()
    }
}
