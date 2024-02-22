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
    @State private var validUsername = true

    @State private var passwordValidation = 0
    @State private var passwordMismatch = false
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?

    @StateObject private var authVM = AuthenticationViewModel()
    private let authentication = AuthenticationService()
    
    var body: some View {
        Section(header: Text("Sign up").multilineTextAlignment(.center).bold().fixedSize().font(.largeTitle)) {
            Form {

                Section(header: Text("Email")){
                    TextField("Enter your email", text: $email).autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                        

                    if invalidEmailMessage {
                        Text("Email is invalid")
                            .foregroundColor(Color.red)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .listRowBackground(Color(UIColor.systemGroupedBackground))
                    }
                }
                
   
                
                Section(header: Text("Username")){
                    TextField("Enter a username", text: $username).autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)

                    
                    if !validUsername {
                        Text("Please enter a username")
                            .foregroundColor(Color.red)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .listRowBackground(Color(UIColor.systemGroupedBackground))
                    }
                }
                
                Section(header: Text("Password")) {
                    SecureField("Enter a password", text: $password)
                    
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
                }
                
                Section(header: Text("Confirm Password")) {
                    SecureField("Repeat password", text: $confirmPassword)
                    
                    if passwordMismatch {
                        Text("Passwords do not match")
                            .foregroundColor(Color.red)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .listRowBackground(Color(UIColor.systemGroupedBackground))
                    }
                }
                
                Section {
                    Button("Upload Profile Picture") {
                        showingImagePicker = true
                    }
                    .sheet(isPresented: $showingImagePicker) {
                        PhotoPicker(image: self.$inputImage)
                    }
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
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
                                // Proceed with signing up the user, using the imageUrl as the avatar
                                let user = User(id: nil, username: username, avatar: imageUrl, email: email, password: password)
                                let signUpSuccess = authentication.signUp(user: user)
                                // Handle signUpSuccess accordingly
                                if signUpSuccess {
                                    // Reset form or navigate to another view
                                    resetStates()
                                }
                            case .failure(let error):
                                print("Failed to upload image: \(error.localizedDescription)")
                                // Handle error accordingly
                            }
                        }
                    } else {
                        // Proceed with sign up without an image
                        let user = User(id: nil, username: username, avatar: nil, email: email, password: password)
                        let signUpSuccess = authentication.signUp(user: user)
                        // Handle signUpSuccess accordingly
                        if signUpSuccess {
                            // Reset form or navigate to another view
                            resetStates()
                        }
                    }

                }
            }
        }
    }
    
    func resetCheckers() {
        invalidEmailMessage = false
        validUsername = true
        passwordValidation = 0
        passwordMismatch = false
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

