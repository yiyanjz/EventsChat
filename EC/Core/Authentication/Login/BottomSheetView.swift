//
//  BottomSheetView.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI

struct BottomSheetView: View {
    @State private var presentRegistration: Bool = false
    @State private var loginWithEmail: Bool = false
    
    var body: some View {
        ZStack {
            Color(uiColor: .black)
                .ignoresSafeArea()
                .brightness(0.1)
            
            VStack(spacing: 30) {
                actionButton
                
                registerButton
            }
            .sheet(isPresented: $presentRegistration) {
                RegisterView()
            }
            .sheet(isPresented: $loginWithEmail) {
                LoginWithEmailView()
            }
        }
    }
}

struct BottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        BottomSheetView()
    }
}

// extension views
extension BottomSheetView {
    var actionButton: some View {
        // action buttons
        VStack(spacing: 10) {
            // Login with email
            Button {
                loginWithEmail.toggle()
            } label: {
                let icon = Image(systemName: "envelope")
                
                Text("\(icon) Continue with Email")
                    .modifier(LoginButtonModifer(color: Color(.systemGreen)))
            }
            
            // Login with google
            Button {
                print("LoginView: Login with Google")
            } label: {
                let icon = Image(systemName: "g.circle.fill")

                Text("\(icon) Continue with Google")
                    .modifier(LoginButtonModifer(color: Color(.systemRed)))
            }
            
            // Login with facebook
            Button {
                print("LoginView: Login with Facebook")
            } label: {
                let icon = Image(systemName: "f.circle")

                Text("\(icon) Continue with Facebook")
                    .modifier(LoginButtonModifer(color: Color(.systemBlue)))
            }
            
            // login with apple
            Button {
                print("LoginView: Login with Apple")
            } label: {
                let icon = Image(systemName: "apple.logo")

                Text("\(icon) Continue with Apple")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(width: 320, height: 44)
                    .background(Color(.white))
                    .cornerRadius(8)
            }
        }
    }
    
    var registerButton: some View{
        // Register
        Button {
            presentRegistration.toggle()
        } label: {
            HStack(spacing: 3) {
                Text("Don't have an acount?")
                    .foregroundColor(.white)
                Text("Sign Up")
                    .foregroundColor(.blue)
            }
            .font(.subheadline)
            .foregroundColor(.black)
        }
    }
}
