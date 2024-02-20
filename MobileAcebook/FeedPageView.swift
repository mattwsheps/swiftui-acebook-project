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
            return "\(years)y"
        } else if let months = components.month, months > 0 {
            return "\(months)mo"
        } else if let days = components.day, days > 0 {
            return "\(days)d"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours)h"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes)m"
        } else {
            return "now"
        }
    }
}

struct FeedPageView: View {
    @ObservedObject var postsService = PostsService()
    @State private var token: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNjVkMzc1NGRkZTkyOTg1NjZlYjJjOTFhIiwiaWF0IjoxNzA4NDIzMjYzLCJleHAiOjE3MDg0MjY4NjN9.sNEyO-UoeX0xE8T3S6WGCEVeAgI64oILv53rg2zxXFA"
    
    var body: some View {
        ZStack{
            Color(red: 242/255, green: 242/255, blue: 247/255)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView{
                VStack(alignment: .leading, spacing: 20){
                    
                    
                    Text("Recent")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                    ForEach(postsService.posts) { post in
                        ZStack{
                            VStack(alignment: .leading, spacing: 8) {
                                // Created by
                                HStack{
                                    
                                    Image("profile-pic")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .clipShape(Circle())
                                        .frame(width: 60, height: 60)
                                        
                                        
                                    VStack(alignment: .leading, spacing: 8){
                                        Text("Created by: \(post.createdBy ?? "Unknown")")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        
                                        // Created at
                                        Text("\(post.createdAt.timeAgo())")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                // Image (assuming image is a URL)
                                if let imageURL = URL(string: post.image) {
                                    // Conditionally render AsyncImage if imageURL is valid
                                    if let imageData = try? Data(contentsOf: imageURL), let uiImage = UIImage(data: imageData) {
                                        AsyncImage(url: imageURL) { image in
                                            image.resizable()
                                                .aspectRatio(contentMode: .fit)
                                        } placeholder: {
                                            // Placeholder view while loading
                                            ProgressView()
                                        }
                                        .frame(maxHeight: 200) // Limit the maximum height of the image
                                    }
                                }
                                
                                // Message
                                Text(post.message)
                                    .padding() // Add padding at the bottom
                                
                            }
                            .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                            .frame(maxWidth: .infinity)
                            .background(Color.white) // Set background color to white
                            .cornerRadius(25) // Apply corner radius
                        }
                    }
                    
                }
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 16))
            }
            .onAppear(){
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
