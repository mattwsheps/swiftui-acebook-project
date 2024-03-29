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
    @ObservedObject var authService: AuthenticationService
    @State private var newPostMessage: String = ""
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var imageSelect = false
    
    @State private var isShowingCommentSheet = false

    @State private var commentText = ""
    @State private var postId = ""
    @State private var selectedPostIndex: Int = 0
    

    @State private var token: String = ""
    @State private var isLoggedOut: Bool = false

    var body: some View {
        ZStack {
            Color(red: 242/255, green: 242/255, blue: 247/255).edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Feed").font(.largeTitle).fontWeight(.bold)
                    // Avatar and post input area
                    HStack(alignment: .top, spacing: 10) {
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
                        
                        VStack(alignment: .center, spacing: 10) {
                            TextField("What's on your mind?", text: $newPostMessage)
                                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 15))
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(30)
                                .multilineTextAlignment(.leading)
                                .keyboardType(.default)
                                .autocapitalization(.none)
                            
                            // Image picker and Post button area
                            VStack(alignment: .center, spacing: 10) {
                                // Image picker and Post button
                                HStack {
                                    Button(action: {
                                        showingImagePicker = true
                                    }) {
                                        HStack {
                                            Image(systemName: "photo.on.rectangle") // This assumes you are using SF Symbols
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
                                        PhotoPicker(image: self.$inputImage, imageSelected: $imageSelect)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        if let inputImage = inputImage {
                                            uploadImageAndCreatePost(image: inputImage)
                                        } else {
                                            createPost(with: nil)
                                        }
                                    }) {
                                        HStack {
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
                    }
                    
                    // Image preview and Remove button
                    if let inputImage = inputImage {
                        VStack(alignment: .center, spacing: 15){
                            VStack{
                                Image(uiImage: inputImage)
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(30)
                              
                            }
                            .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(50)
                            
                            Button(action: {
                                self.inputImage = nil
                            })
                            {
                                HStack {
                                    Text("Remove")
                                        .foregroundColor(.red)
                                    Image(systemName: "xmark.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 20, height: 20)
                                }
                                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 15))
                                .background(Color.white)
                                .cornerRadius(30)
                            }
                        }
                    }
                    
                    
                    // Recent posts list
                    ForEach(postsService.posts) { post in

                        
                        VStack(alignment: .leading, spacing: 10) {

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
                                AsyncImageView(imageUrl: imageURL)
                                    .cornerRadius(10)

                            } else {
                                // Fallback content if there's no image URL
                                Text("No image available")
                            }
                            
                            Text(post.message)
                                .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                                .font(.title3)
                            
                            HStack{
                                Button(action: {
                                    postsService.likePost(token: token, postID: post.id) { likesCount in
                                        if let likesCount = likesCount {
                                            print("Likes count: \(likesCount)")
                                        } else {
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
                                    if let index = postsService.posts.firstIndex(of: post) {
                                        // Set the selected post index
                                        self.selectedPostIndex = index
                                        self.postId = post.id
                                        // Show the comment sheet
                                        isShowingCommentSheet.toggle()
                                    }

                                }) {
                                    Image("comment-icon")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                }
                                .sheet(isPresented: $isShowingCommentSheet) {

                                    // Content of the comment sheet
                                    CommentSheetView(postsService: postsService, commentText: $commentText, postId: $postId, selectedPostIndex: $selectedPostIndex, token: $token)

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
                .padding(.all, 20)
            }
            .onAppear {
                token = authService.token
                postsService.getPosts(token: token)
            }
            
            // Logout button area
            HStack {
                Button(action: {
                    self.token = ""
                    self.isLoggedOut = true
                }, label:{
                    Text("Logout")
                        .foregroundColor(.red)
                })
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 15))
                .background(Color.white)
                .cornerRadius(30)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .fullScreenCover(isPresented: $isLoggedOut, content: {
                LoginPageView()
            })
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
        let mockAuthService = AuthenticationService()
        mockAuthService.token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNjVkNWU0Njg0ZjE0YTNhYmRkNTA3MjY1IiwiaWF0IjoxNzA4Njk2NzEyLCJleHAiOjE3MDg3MDAzMTJ9.INn6HHDSrt0OwKGfzmV6Z2Q6VoHsX8OyKGWsuU0LeVg"
        return FeedPageView(authService: mockAuthService)
    }
}

struct CommentSheetView: View {
    @ObservedObject var postsService: PostsService
    @ObservedObject var commentsService = CommentsService()
    @Binding var commentText: String
    @Binding var postId: String
    @Binding var selectedPostIndex: Int
    @Binding var token: String
    
    var body: some View {
        ZStack{
            Color(red: 242/255, green: 242/255, blue: 247/255)
                .edgesIgnoringSafeArea(.all)
            
            
            ScrollView{
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack{
                            if let avatarURLString = postsService.posts[selectedPostIndex].createdByAvatar, let avatarURL = URL(string: avatarURLString) {
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
                                Text("\(postsService.posts[selectedPostIndex].createdByUsername ?? "???")")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Text("\(postsService.posts[selectedPostIndex].createdAt.timeAgo())")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        if let imageURL = URL(string: postsService.posts[selectedPostIndex].image) {
                            AsyncImageView(imageUrl: imageURL)
                                .cornerRadius(10)
                                .frame(maxWidth: .infinity)
                               
                        } else {
                            // Fallback content if there's no image URL
                            Text("No image available")
                        }
                        
                        Text(postsService.posts[selectedPostIndex].message)
                            .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                            .font(.title3)
                        
                    }
                    .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(50)
                    
                    
                    ForEach(commentsService.comments) { comment in
                        HStack {
                            if let avatarURLString = comment.createdByAvatar, let avatarURL = URL(string: avatarURLString) {
                                AsyncImage(url: avatarURL) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .clipShape(Circle())
                                        .frame(width: 70, height: 70)
                                } placeholder: {
                                    Color.gray
                                        .frame(width: 70, height: 70)
                                        .clipShape(Circle())
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .resizable()
                                                .frame(width: 40, height: 40)
                                                .aspectRatio(contentMode: .fill)
                                                .foregroundColor(.white)
                                        )
                                }
                            } else {
                                Color.gray
                                    .frame(width: 70, height: 70)
                                    .clipShape(Circle())
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .aspectRatio(contentMode: .fill)
                                            .foregroundColor(.white)
                                    )
                            }
                            
                            VStack(alignment: .leading){
                                VStack(alignment: .leading) {
                                    Text("\(comment.createdByUsername ?? "???")")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.leading)
                                    
                                    Text(comment.message)
                                        .font(.headline)
                                        .fontWeight(.regular)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(nil) // Remove line limit to allow multiline text

                                }
                                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)) // Adjust padding as needed
                                .background(Color.white)
                                .cornerRadius(50)

                                
                                Text("\(comment.createdAt.timeAgo())")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.leading, 20)
                            }
                            
                        }
                        .padding(.vertical, 5) // Adjust vertical padding as needed
                    }
                    
                }
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 70, trailing: 20))
            }
            .padding(.bottom, 50)
            VStack{
                Spacer() // Spacer to push content to the top
                
                // Comment bar
                HStack {
                    TextField("Write a comment...", text: $commentText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: {
                        createComment()
                    }) {
                        Text("Send")
                    }
                    .padding(.trailing)
                    .disabled(commentText.isEmpty) // Disable the button if the text field is empty
                }
                .padding()
                .background(Color(red: 242/255, green: 242/255, blue: 247/255))
                .cornerRadius(10)
            }
        
        }
        .onAppear(){
            commentsService.getCommentsByPostId(token: token, postId: postId)
        }
    }
    func createComment() {
        commentsService.createComment(token: token, postId: postId, message: commentText) { success, error in
            if success {
                // Reset the form on success
                commentText = ""
                commentsService.getCommentsByPostId(token: token, postId: postId)
            } else {
                // Handle the error
                print(error?.localizedDescription ?? "Failed to create post")
            }
        }
    }
}
