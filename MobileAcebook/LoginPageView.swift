import SwiftUI

struct LoginPageView: View {
    @ObservedObject var authService = AuthenticationService()
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = "Invalid username or password"
    @State private var invalidLogin = false
    @State private var navigateToSignUp = false
    
    var body: some View {
        ZStack {
            Color(red: 242/255, green: 242/255, blue: 247/255)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Image("Acebook-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 100)
                VStack(spacing: 20){
                    Text("Welcome back!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Log in to your existing Acebook account.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .fontWeight(.light)
                        .padding(.bottom)
                    
                    HStack{
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)
                            .padding(.leading, 10)
                            .frame(width: 20, height: 20)
                        TextField("Enter your email", text: $email)
                            .autocapitalization(.none)
                            .padding(.leading, 10)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(30)
                    .padding(.horizontal, 30)
                    
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
                    
                    
                    Button(action: {
                        authService.login(email: email, password: password) { success in
                            if !success {
                                invalidLogin = true
                            }
                        }
                    }) {
                        Text("LOG IN")
                            .padding(EdgeInsets(top: 15, leading: 30, bottom: 15, trailing: 30))
                            .fontWeight(.semibold)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(30)
                            .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    if invalidLogin {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.top)
                    }
                    
                    HStack(spacing: 6){
                        Text("Don't have an account?")
                            .font(.headline)
                            .padding(.top)
                        Button(action:{
                            navigateToSignUp = true
                        }){
                            Text("Sign up here")
                                .font(.headline)
                                .padding(.top)
                        }
                    }
                }
                .padding(.bottom, 80)
            }
        }
        .navigate(to: SignUpView(), when: $navigateToSignUp)
        .navigate(to: FeedPageView(authService: authService).navigationBarBackButtonHidden(true), when: $authService.loggedIn)
    }
}
   




struct LoginPageView_Previews: PreviewProvider {
        static var previews: some View {
            LoginPageView()
        }
    }

extension View {
    /// Navigate to a new view.
    /// - Parameters:
    ///   - view: View to navigate to.
    ///   - binding: Only navigates when this condition is `true`.
    func navigate<NewView: View>(to view: NewView, when binding: Binding<Bool>) -> some View {
        NavigationView {
            ZStack {
                self
                    .navigationBarTitle("")
                    .navigationBarHidden(true)

                NavigationLink(
                    destination: view
                        .navigationBarTitle("")
                        .navigationBarHidden(true),
                    isActive: binding
                ) {
                    EmptyView()
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
