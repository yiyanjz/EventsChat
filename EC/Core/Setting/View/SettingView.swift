//
//  SettingView.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI

struct SettingView: View {
    @Environment(\.colorScheme) var colorScheme
    // go back navigation link
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack {
            headerView
            
            List {
                // section 1
                Section {
                    ForEach(SettingFilter.allCases, id: \.self) { option in
                        HStack {
                            Image(systemName: option.imageName)
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(option.imageBackgroundColor)
                            
                            Text(option.title)
                                .font(.subheadline)
                                .foregroundColor(colorScheme == .light ? .black : .white )
                        }
                    }
                }
                
                // logout button
                LogoutView
            }
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}

extension SettingView {
    var headerView: some View {
        HStack {
            // > icon
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.footnote)
                    .foregroundColor(colorScheme == .light ? .black : .white )
            }
            
            Spacer()
            
            Text("Settings")
                .font(.title3)
                .foregroundColor(colorScheme == .light ? .black : .white )
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical)
    }
}

extension SettingView {
    var LogoutView: some View {
        Section {
            Button {
                AuthService.shared.signout()
            } label: {
                Text("Log Out")
            }
            
            Button {
                print("SettingView: Delete Account Button Pressed")
            } label: {
                Text("Delete Account")
            }
        }
    }
}
