//
//  WelcomePageView.swift
//  MobileAcebook
//
//  Created by Josué Estévez Fernández on 30/09/2023.
//

import SwiftUI

struct WelcomePageView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()



                Image("Acebook-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .accessibilityIdentifier("makers-logo")
                
                Spacer()
                NavigationLink(destination: SignUpView()){
                    Text("Login")
                        .fontWeight(.bold)
                        .padding(.bottom, 25)
                        .font(.largeTitle)
                }
                
                NavigationLink(destination: SignUpView()) {
                    Text("Sign Up")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                
                Spacer()
            }
        }
    }
}

struct WelcomePageView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomePageView()
    }
}
