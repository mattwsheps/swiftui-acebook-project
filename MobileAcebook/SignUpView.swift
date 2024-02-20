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
    @State var confirmPassword = ""
    let authentication = AuthenticationService();
    
    var body: some View {
        
        
        
        Section (header: Text("Sign up").multilineTextAlignment(.center).bold().fixedSize().font(/*@START_MENU_TOKEN@*/.largeTitle/*@END_MENU_TOKEN@*/)){
            Form {
                Section(header: Text("Email")){
                    TextField("Enter your email", text: $email)
                }
                Section(header: Text("Username")){
                    TextField("Enter a username", text: $username)
                }
                Section(header: Text("Password")){
                    TextField("Enter a password", text: $password)
                }
                Section(header: Text("Confirm Password")){
                    TextField("Re-enter your password", text: $confirmPassword)
                }
                
                Button("Sign up") {
                    let user = User(email: email, username: username, password: password, avatar: "test.png")
                    authentication.signUp(user: user)
                    email = "";
                    username = "";
                    password = "";
                    confirmPassword = "";
                }
            }
        }
    }
}

#Preview {
    SignUpView()
}
