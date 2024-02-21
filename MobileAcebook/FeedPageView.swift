//
//  FeedPageView.swift
//  MobileAcebook
//
//  Created by Matthew Shepherd on 19/02/2024.
//

import SwiftUI
import PhotosUI

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
    @State private var newPostMessage: String = ""
    @State private var newPostImageURL: String = ""
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    @State private var isShowingCommentSheet = false
    @State private var commentText = ""
    
    @State private var token: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNjVkNWU0Njg0ZjE0YTNhYmRkNTA3MjY1IiwiaWF0IjoxNzA4NTM4NjA5LCJleHAiOjE3MDg1NDIyMDl9.Zb8R_A4c__1XTT0cIXqap0b0DdtWy9WqKfz6HNCPQUA"
    
    
    var body: some View {
        ZStack{
            Color(red: 242/255, green: 242/255, blue: 247/255)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView{
                VStack(alignment: .leading, spacing: 20){
                    Text("Feed")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    HStack(spacing: 10){
                        if let avatarURLString = postsService.user?.avatar, let avatarURL = URL(string: avatarURLString) {
                            AsyncImage(url: avatarURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(Circle())
                                    .frame(width: 80, height: 80)
                            } placeholder: {
                                Color.gray
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .frame(width: 45, height: 45)
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
                        
                        VStack(alignment: .center, spacing: 10) {
                            TextField("What's on your mind?", text: $newPostMessage)
                                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 15))
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(30)
                                .multilineTextAlignment(.leading)
                                .keyboardType(.default)
                                .autocapitalization(.none)

                            
                            HStack{
                                Button(action: {
                                    print("Select Image button was tapped.")
                                    showingImagePicker = true
                                }) {
                                    HStack{
                                        Image("photo-icon")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20, height: 20)
                                        Text("Image")
                                            .foregroundColor(.gray)
                                    }
                                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 15))
                                    .background(Color.white)
                                    .cornerRadius(30)
                                    
                                }
                                .sheet(isPresented: $showingImagePicker) {
                                    PhotoPicker(image: self.$inputImage)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    print("Post button was tapped.")
                                    if let inputImage = inputImage {
                                        print("An image is selected for posting.")
                                        uploadImageAndCreatePost(image: inputImage)
                                    } else {
                                        print("No image is selected, creating a text-only post.")
                                        createPost(with: nil)
                                    }
                                }) {
                                    HStack{
                                        Text("Post")
                                            .foregroundColor(.gray)
                                        Image(systemName: "paperplane.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20, height: 20)
                                    }
                                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 15))
                                    .background(Color.white)
                                    .cornerRadius(30)
                                }
                                .disabled(newPostMessage.isEmpty)
                            }
                            
                        }
                        
                    }
                    VStack(alignment: .center){
                        if let inputImage = inputImage {
                            Image(uiImage: inputImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .padding()
                        }
                    }
                    
                    
                    Text("Recent")
                        .font(.title)
                        .fontWeight(.bold)
                     
                    
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
                postsService.getPosts(token: token)
            }
        }
    }
    // Function to load an image
    func loadImage() {
        print("loadImage() was called.")
        guard let selectedImage = inputImage else {
            print("No image is selected.")
            return
        }
        print("Proceeding to upload the selected image.")
        postsService.uploadImageToCloudinary(imageData: selectedImage.jpegData(compressionQuality: 0.8)!) { result in
            switch result {
            case .success(let imageUrl):
                // Use the imageUrl for creating a new post
                createPost(with: imageUrl)
            case .failure(let error):
                // Handle the error
                print("Image upload failed: \(error.localizedDescription)")
            }
        }
    }
    
    // Function to upload an image
    func uploadImageAndCreatePost(image: UIImage) {
        print("Uploading image to Cloudinary...")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to get JPEG data from the image.")
            return
        }
        
        postsService.uploadImageToCloudinary(imageData: imageData) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let imageUrl):
                    print("Image uploaded successfully. Image URL: \(imageUrl)")
                    print("Creating post with image URL...")
                    self.createPost(with: imageUrl)
                case .failure(let error):
                    print("Failed to upload image: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Function to create a post
    func createPost(with imageUrl: String?) {
        print("Creating post with image URL: \(String(describing: imageUrl))")
        postsService.createPost(token: token, message: newPostMessage, image: imageUrl) { success, error in
            if success {
                // Reset the form on success
                newPostMessage = ""
                inputImage = nil
                // Fetch the latest posts
                postsService.getPosts(token: token)
            } else {
                // Handle the error
                print(error?.localizedDescription ?? "Failed to create post")
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
