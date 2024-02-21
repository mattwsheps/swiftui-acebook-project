//
//  LoginPageView.swift
//  MobileAcebook
//
//  Created by James-Leigh Taylor on 21/02/2024.
//
import SwiftUI
import AuthenticationServices


//struct LoginPageView: View {
//    @ObservedObject var authService = AuthenticationService()
//    @State private var email = ""
//    @State private var password = ""
//    @State private var errorMessage = "Invalid username or password"
//    @State private var invalidLogin = false
//    
//    var body: some View {
//        NavigationView{
//            Form {
//                Section(header: Text("Login").multilineTextAlignment(.center).bold().font(.title)) {
//                    Section(header: Text("Email")) {
//                        TextField("Enter your email", text: $email)
//                    }
//                    Section(header: Text("Password")) {
//                        SecureField("Enter your password", text: $password)
//                    }
//                
//                Section {
//                    NavigationLink (destination:FeedPageView()){
//                        Button(action:authService.login(email:email,password:password)) {
//                            Text("Login")
//                            if invalidLogin {
//                                Text(errorMessage)
//                                    .foregroundColor(.red)
//                                    .padding(.top)
//                                
//                                
//                             
//                            }
//                            
//                        }
//                    }
//                    
//                    
//                }
//            }}}
//            
//            
//            
//            
//        }
//    
    

import SwiftUI

struct LoginPageView: View {
    @ObservedObject var authService = AuthenticationService()
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = "Invalid username or password"
    @State private var invalidLogin = false
    @State private var loggedIn = false
    
    var body: some View {
        
        Form {
            Section(header: Text("Login").multilineTextAlignment(.center).bold().font(.title)) {
                Section(header: Text("Email")) {
                    TextField("Enter your email", text: $email).autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                }
                Section(header: Text("Password")) {
                    SecureField("Enter your password", text: $password).autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                }
            }
            
            Section {
                Button(action: {
                    authService.login(email: email, password: password) { success in
                        if !success {
                            invalidLogin = true
                        } else {
                            loggedIn = true
                        }
                    }
                }) {
                    Text("Login")
                }
                .foregroundColor(.blue)
                
                if invalidLogin {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top)
                }
            }
        }
    }
}



struct LoginPageView_Previews: PreviewProvider {
        static var previews: some View {
            LoginPageView()
        }
    }

