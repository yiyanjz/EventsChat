//
//  LoginWithEmailView.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI

struct LoginWithEmailView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = LoginViewModel()
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack {
            // Background Color
            Color.black.brightness(0.1)
                .ignoresSafeArea()
            
            VStack(spacing: 15){
                headerView
                                
                Divider()
                    .background(Color(uiColor: .white).opacity(0.5))
                
                bodyView
                
                Spacer()

                logoImage
                
                Spacer()
            }
            .ignoresSafeArea(.keyboard)
            .padding(.top, 30)
        }
    }
}

struct LoginWithEmailView_Previews: PreviewProvider {
    static var previews: some View {
        LoginWithEmailView()
    }
}

extension LoginWithEmailView {
    var headerView: some View {
        // header
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.app")
                    .font(.title2)
                    .foregroundColor(.white)
            }

            Spacer()
            
            Text("Log In")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.trailing, 10)
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    var bodyView: some View {
        VStack {
            // info
            Text("Please Enter All Information Below")
                .font(.footnote)
                .foregroundColor(.gray)

            // email
            TextField("Enter Your Email", text: $viewModel.email)
                .textInputAutocapitalization(.none)
                .modifier(LoginRegisterTextFieldModifer())


            // password
            TextField("Enter Your Password", text: $viewModel.password)
                .modifier(LoginRegisterTextFieldModifer())

            // Login with email
            Button {
                Task { try await viewModel.logIn() }
            } label: {
                Text("Sigin")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: screenWidth - 50, height: 44)
                    .background(Color(uiColor: .systemGreen))
                    .cornerRadius(8)
            }
        }
    }
    
    var logoImage: some View {
        // Logo Image
        Image("logo")
            .resizable()
            .frame(width: 200, height: 200)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
    }
}
