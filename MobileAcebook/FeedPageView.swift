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
    @State private var token: String = ""
   
    
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
                        ZStack{
                            VStack(alignment: .leading, spacing: 8) {
                                HStack{
                                    Image("profile-pic")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .clipShape(Circle())
                                        .frame(width: 50, height: 50)
                                    
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
                            }
                            .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(30)
                        }
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
}

struct FeedPageView_Previews: PreviewProvider {
    static var previews: some View {
        FeedPageView()
    }
}
