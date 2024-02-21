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
    
    @State var email = "";
    @State var username = "";
    @State var password = "";
    @State var confirmPassword = "";
    
        
    @State private var invalidEmailMessage = false;
    @State private var validUsername = true
    @State private var passwordValidation = 0;
    @State private var passwordMismatch = false;
    
    @StateObject private var authVM = AuthenticationViewModel()
    private let authentication = AuthenticationService();
    
    var body: some View {
        
        
        
        Section (header: Text("Sign up").multilineTextAlignment(.center).bold().fixedSize().font(/*@START_MENU_TOKEN@*/.largeTitle/*@END_MENU_TOKEN@*/)){
            Form {
                Section(header: Text("Email")){
                    TextField("Enter your email", text: $email)
                        
                    if invalidEmailMessage {
                        Text("Email is invalid")
                            .foregroundColor(Color.red)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .listRowBackground(Color(UIColor.systemGroupedBackground))
                    }
                }
                
                
                
                Section(header: Text("Username")){
                    TextField("Enter a username", text: $username)
                    
                    if !validUsername {
                        Text("Please enter a username")
                            .foregroundColor(Color.red)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .listRowBackground(Color(UIColor.systemGroupedBackground))
                    }
                }
                Section(header: Text("Password")){
                    SecureField("Enter a password", text: $password)
                    
                    if passwordValidation == 1 {
                        Text("Password must be longer than 8 chars")
                            .foregroundColor(Color.red)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .listRowBackground(Color(UIColor.systemGroupedBackground))
                    } else if passwordValidation == 2 {
                        Text("Please include a lower case character, uppercase character and number")
                            .foregroundColor(Color.red)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .listRowBackground(Color(UIColor.systemGroupedBackground))
                    }
                    
                }
                
                Section(header: Text("Confirm Password")){
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
                        
                    }
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    
                }
                
                Button("Sign up") {
                    
                    resetCheckers()
                    
                    if !isValidEmail(email: email) {
                        invalidEmailMessage = true;
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
                        passwordMismatch = true;
                        return
                    }
                    
                    let user = User(id: nil, username: username, avatar: "placeholder.png", email: email,  password: password)
                    authentication.signUp(user: user)
                    
                    
                    //replace with navigate to login
                    resetStates()
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
        email = "";
        username = "";
        password = "";
        confirmPassword = "";
    }
}

#Preview {
    SignUpView()
}
