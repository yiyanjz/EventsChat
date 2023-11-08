//
//  LoginView.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI

struct LoginView: View {
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    @Environment(\.colorScheme) var colorScheme
    @State private var showBottomSheet: Bool = false
    
    var body: some View {
        ZStack{
            Image("background")
            
            GetStartedButtonView
        }
        .ignoresSafeArea()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

// extension views
extension LoginView {
    var GetStartedButtonView: some View{
        ZStack {
            Button {
                showBottomSheet.toggle()
            } label: {
                Text("Get Started")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(width: screenWidth / 1.2, height: 50, alignment: .center)
                    .foregroundColor(colorScheme == .light ? .black : .white )
                    .background(colorScheme == .light ? Color.white.brightness(0) : Color.black.brightness(0))
                    .cornerRadius(10)
            }
            .zIndex(1)
            .sheet(isPresented: $showBottomSheet) {
                BottomSheetView()
                    .presentationDetents([.height(300)])
            }
        }
        .padding(.top, 600)
    }
}
