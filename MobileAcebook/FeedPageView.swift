//
//  FeedPageView.swift
//  MobileAcebook
//
//  Created by Matthew Shepherd on 19/02/2024.
//

import SwiftUI


extension Date {
    func timeAgo() -> String {
        let calendar = Calendar.current
        let now = Date()
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self, to: now)
        
        if let years = components.year, years > 0 {
            return "\(years) years ago"
        } else if let months = components.month, months > 0 {
            return "\(months) months ago"
        } else if let days = components.day, days > 0 {
            return "\(days) days ago"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours) hours ago"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes) mins ago"
        } else {
            return "now"
        }
    }
}

struct FeedPageView: View {
    @ObservedObject var postsService = PostsService()
    @ObservedObject var authenticationService = AuthenticationService()
    @State private var newPostMessage: String = ""
    @State private var newPostImageURL: String = ""
    
    @State private var isShowingCommentSheet = false
    @State private var commentText = ""
    
    @State private var token: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNjVkNWU0Njg0ZjE0YTNhYmRkNTA3MjY1IiwiaWF0IjoxNzA4NTI0MzU4LCJleHAiOjE3MDg1Mjc5NTh9.I7LXcxMeb2S4zkbyWACX4JkDd0q48QLbXOyDUSfSG70"
    
  
    var body: some View {
        ZStack{
            Color(red: 242/255, green: 242/255, blue: 247/255)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView{
                VStack(alignment: .leading, spacing: 20){
                    Text("Recent")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("What's on your mind?", text: $newPostMessage)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        TextField("Image URL (optional)", text: $newPostImageURL)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Button(action: {
                            postsService.createPost(token: token, message: newPostMessage, image: newPostImageURL.isEmpty ? nil : newPostImageURL) { success, error in
                                if success {
                                    newPostMessage = ""
                                    newPostImageURL = ""
                                    // Fetch the latest posts
                                    postsService.getPosts(token: token)
                                } else {
                                    // Handle the error, e.g., show an alert to the user
                                    print(error?.localizedDescription ?? "Failed to create post")
                                }
                            }
                        }) {
                            Text("Post")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()
                    }
                    .background(Color.white)
                    .cornerRadius(15)
                    .padding()
                    
                    ForEach(postsService.posts) { post in
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack{
                                if let avatarURLString = post.createdByAvatar, let avatarURL = URL(string: avatarURLString) {
                                    AsyncImage(url: avatarURL) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .clipShape(Circle())
                                            .frame(width: 50, height: 50)
                                    } placeholder: {
                                        Color.gray
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                            .overlay(
                                                Image(systemName: "person.fill")
                                                    .resizable()
                                                    .frame(width: 30, height: 30)
                                                    .aspectRatio(contentMode: .fill)
                                                    .foregroundColor(.white)
                                            )
                                    }
                                } else {
                                    Color.gray
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .aspectRatio(contentMode: .fill)
                                                .foregroundColor(.white)
                                        )
                                }
                                
                                VStack(alignment: .leading, spacing: 5){
                                    Text("\(post.createdByUsername ?? "???")")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    
                                    Text("\(post.createdAt.timeAgo())")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            if let imageURL = URL(string: post.image) {
                                if let imageData = try? Data(contentsOf: imageURL), let uiImage = UIImage(data: imageData) {
                                    AsyncImage(url: imageURL) { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fit)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(maxHeight: 200)
                                }
                            }
                            
                            Text(post.message)
                                .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                                .font(.title3)
                            
                            HStack{
                                Button(action: {
                                    postsService.likePost(token: token, postID: post.id) { likesCount in
                                        // Handle the response if needed, such as updating UI based on likesCount
                                        if let likesCount = likesCount {
                                            // Update UI or perform actions based on the likesCount
                                            print("Likes count: \(likesCount)")
                                        } else {
                                            // Handle error or nil response if needed
                                            print("Failed to like the post.")
                                        }
                                        toggleLike(for: post.id)
                                    }
                                }) {
                                    Image(postsService.likedStates[post.id] == true ? "like-icon-liked" : "like-icon-unliked")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                }
                                
                                Text("\(post.likesCount ?? 0) likes")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                Text("\(post.comments) comments")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Button(action: {
                                    // Show the comment sheet
                                    isShowingCommentSheet.toggle()
                                }) {
                                    Image("comment-icon")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                }
                                .sheet(isPresented: $isShowingCommentSheet) {
                                    // Content of the comment sheet
                                    CommentSheetView(commentText: $commentText)
                                }
                            }
                            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                        }
                        .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(50)
                    }
                }
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                
            }
            .onAppear(){
                token = authenticationService.token
                postsService.getPosts(token: token)
            }
        }
    }
    private func toggleLike(for postID: String) {
        postsService.likedStates[postID] = !(postsService.likedStates[postID] ?? false)
    }
}

struct FeedPageView_Previews: PreviewProvider {
    static var previews: some View {
        FeedPageView()
    }
}

struct CommentSheetView: View {
    @Binding var commentText: String
    
    var body: some View {
        VStack {
            Text("Comments")
                .padding()
            Text("Comments")
                .padding()
            Text("Comments")
                .padding()
            Text("Comments")
                .padding()
            
            Spacer() // Spacer to push content to the top
            
            // Comment bar
            HStack {
                TextField("Write a comment...", text: $commentText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: {
                    // Action to handle comment submission
                    print("Comment submitted: \(commentText)")
                    commentText = "" // Clear text field after submission
                }) {
                    Text("Send")
                }
                .padding(.trailing)
                .disabled(commentText.isEmpty) // Disable the button if the text field is empty
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }
}
