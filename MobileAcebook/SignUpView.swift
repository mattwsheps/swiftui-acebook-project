//
//  SignUpView.swift
//  MobileAcebook
//
//  Created by Andre George on 19/02/2024.
//

import Foundation
import SwiftUI
import AuthenticationServices

struct SignUpView: View {
    
    @State var email = ""
    @State var username = ""
    @State var password = ""
    @State var confirmPassword = ""
    
    @State private var invalidEmailMessage = false
    @State private var emailUsed = false
    @State private var validUsername = true
    @State private var passwordValidation = 0;
    @State private var passwordMismatch = false;
    @State private var imageSelected = false;
    @State private var signUpSuccessfull = false;
    
    @State private var inputImage: UIImage?
    @State private var showingImagePicker = false
    
    @State private var navigateToLogin = false
    
    @StateObject private var authVM = AuthenticationViewModel()
    private let authentication = AuthenticationService()
    
    var body: some View {
        ZStack {
            Color(red: 242/255, green: 242/255, blue: 247/255)
                .edgesIgnoringSafeArea(.all)
            
            
            VStack(spacing: 20) {
                Text("Sign Up").multilineTextAlignment(.center).bold().fixedSize().font(.largeTitle)
                    .padding(.bottom)
                
                HStack{
                    Image(systemName: "envelope")
                        .foregroundColor(.gray)
                        .padding(.leading, 10)
                        .frame(width: 20, height: 20)
                    TextField("Enter your email", text: $email)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                        .padding(.leading, 10)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(30)
                .padding(.horizontal, 30)
                
                
                if invalidEmailMessage {
                    Text("Email is invalid")
                        .foregroundColor(Color.red)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color(UIColor.systemGroupedBackground))
                }
                
                if emailUsed {
                    Text("Email is already used")
                        .foregroundColor(Color.red)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color(UIColor.systemGroupedBackground))
                }
                
                
                
                
                
                HStack{
                    Image(systemName: "person")
                        .foregroundColor(.gray)
                        .padding(.leading, 10)
                        .frame(width: 20, height: 20)
                    TextField("Enter a username", text: $username)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                        .padding(.leading, 10)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(30)
                .padding(.horizontal, 30)
                
                if !validUsername {
                    Text("Please enter a username")
                        .foregroundColor(Color.red)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color(UIColor.systemGroupedBackground))
                }
                
                
                HStack{
                    Image(systemName: "key")
                        .foregroundColor(.gray)
                        .padding(.leading, 10)
                        .frame(width: 20, height: 20)
                    SecureField("Enter your password", text: $password)
                        .autocapitalization(.none)
                        .padding(.leading, 10)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(30)
                .padding(.horizontal, 30)
                
                if passwordValidation == 1 {
                    Text("Password must be longer than 8 chars")
                        .foregroundColor(Color.red)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color(UIColor.systemGroupedBackground))
                } else if passwordValidation == 2 {
                    Text("Please include a lowercase character, uppercase character, and number")
                        .foregroundColor(Color.red)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color(UIColor.systemGroupedBackground))
                }
                
                
                HStack{
                    Image(systemName: "key")
                        .foregroundColor(.gray)
                        .padding(.leading, 10)
                        .frame(width: 20, height: 20)
                    SecureField("Repeat password", text: $confirmPassword)
                        .autocapitalization(.none)
                        .padding(.leading, 10)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(30)
                .padding(.horizontal, 30)
                
                if passwordMismatch {
                    Text("Passwords do not match")
                        .foregroundColor(Color.red)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color(UIColor.systemGroupedBackground))
                }
          
                Button(action: {showingImagePicker = true}) {
                    HStack {
                        Image(systemName: "photo.on.rectangle") // This assumes you are using SF Symbols
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                        Text("Upload Profile Picture")
                            .fontWeight(.semibold)
                    }
                }
                .sheet(isPresented: $showingImagePicker) {
                    PhotoPicker(image: self.$inputImage, imageSelected: self.$imageSelected)
                }
                .multilineTextAlignment(.center)
                .padding(EdgeInsets(top: 15, leading: 30, bottom: 15, trailing: 30))
                .fontWeight(.semibold)
                .background(Color.white)
                .cornerRadius(30)
                .padding(.horizontal)
                
                if imageSelected {
                    Text("Image uploaded")
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color(UIColor.systemGroupedBackground))
                }
                
                
                
                
                
                Button("Sign up") {
                    resetCheckers()
                    
                    if !isValidEmail(email: email) {
                        invalidEmailMessage = true
                        return
                    }
                    
                    if username == "" {
                        validUsername = false
                        return
                    }
                    
                    passwordValidation = isValidPassword(password: password)
                    if passwordValidation != 0 {
                        return
                    }
                    
                    if password != confirmPassword {
                        passwordMismatch = true
                        return
                    }
                    
                    if let imageData = inputImage?.jpegData(compressionQuality: 0.8) {
                        // Upload the image first
                        PostsService().uploadImageToCloudinary(imageData: imageData) { result in
                            switch result {
                            case .success(let imageUrl):
                                navigateToLogin = true
                                let user = User(id: nil, username: username, avatar: imageUrl, email: email,  password: password)
                                if !authenticating(user: user) {
                                    return
                                }
                                //
                            case .failure(let error):
                                // Handle the error
                                print("Image upload failed: \(error.localizedDescription)")
                            }
                            
                        }
                    } else {
                        navigateToLogin = true
                        let user = User(id: nil, username: username, avatar: nil, email: email,  password: password)
                        if !authenticating(user: user) {
                            return
                        }
                    }
                    
                    
                }
                .padding(EdgeInsets(top: 15, leading: 30, bottom: 15, trailing: 30))
                .fontWeight(.semibold)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(30)
                .padding(.horizontal)
                
                HStack(spacing: 6){
                    Text("Already have an account?")
                        .font(.headline)
                        .padding(.top)
                    Button(action:{
                        navigateToLogin = true
                    }){
                        Text("Login here")
                            .font(.headline)
                            .padding(.top)
                    }
                }
            }
        }
        .navigate(to: LoginPageView(), when: $navigateToLogin)
    }
        
    
    func authenticating(user: User) -> Bool {
        var status = true
        authentication.signUp(user: user) { success in
            if success {
                DispatchQueue.main.async {
                    
                    signUpSuccessfull = true
                    resetStates()
                }
            } else {
                emailUsed = true
                status = false
            }
            
        }
        return status
    }
    
    func resetCheckers() {
        invalidEmailMessage = false
        validUsername = true
        passwordValidation = 0
        passwordMismatch = false
        emailUsed = false
    }
    
    //delete once navigation to login is set
    func resetStates() {
        email = ""
        username = ""
        password = ""
        confirmPassword = ""
    }
}


struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}

