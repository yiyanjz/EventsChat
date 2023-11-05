//
//  EditProfileView.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: EditProfileViewModel
    @State var showGenderPreview: Bool = false
    @Environment(\.colorScheme) var colorScheme

    let user: User

    init(user: User) {
        self.user = user
        self._viewModel = StateObject(wrappedValue: EditProfileViewModel(user: user))
    }
    var body: some View {
        VStack {
            headerView
            
            bodyView
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(user: User.MOCK_USERS[0])
    }
}

// headerView
extension EditProfileView {
    var headerView: some View {
        // ToolBar
        HStack {
            // cancel button
            Button("Cancel") {
                dismiss()
            }
            .font(.subheadline)
            .fontWeight(.bold)
            
            Spacer()
            
            // title
            Text("Edit Profile")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button {
                Task { try await viewModel.updateUserData() }
                dismiss()
            } label: {
                Text("Done")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
        }
        .padding(.horizontal)
    }
}


// bodyView
extension EditProfileView {
    var bodyView: some View {
        VStack {
            VStack(spacing: 15) {
                // name and profile image
                HStack {
                    VStack(alignment: .leading) {
                        Text("Name")
                            .fontWeight(.semibold)
                            .foregroundColor(colorScheme == .light ? .black : .white )
                        
                        TextField("Enter your name", text: $viewModel.fullname, axis: .vertical)
                            .foregroundColor(colorScheme == .light ? .black : .white )
                    }
                    
                    Spacer()
                    
                    // if have an profile image then use that else use system image
                    PhotosPicker(selection: $viewModel.selectedImage) {
                        if let image = viewModel.profileImage {
                            image
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.white)
                                .background(.gray)
                                .clipShape(Circle())
                        } else {
                            CircularProfileImageView(user: user, size: .medium)
                        }
                    }
                }
                
                Divider()
                
                // bio field
                VStack(alignment: .leading) {
                    Text("BIO")
                        .fontWeight(.semibold)
                        .foregroundColor(colorScheme == .light ? .black : .white )
                    
                    TextField("Enter your bio", text: $viewModel.bio, axis: .vertical)
                        .lineLimit(4)
                        .foregroundColor(colorScheme == .light ? .black : .white )
                }
                
                Divider()
                
                // username field
                VStack(alignment: .leading) {
                    Text("Username")
                        .fontWeight(.semibold)
                        .foregroundColor(colorScheme == .light ? .black : .white )
                    
                    TextField("Enter your username", text: $viewModel.userName, axis: .vertical)
                        .foregroundColor(colorScheme == .light ? .black : .white )
                }
                
                Divider()
                
                // links
                VStack(alignment: .leading) {
                    Text("Link")
                        .fontWeight(.semibold)
                        .foregroundColor(colorScheme == .light ? .black : .white )
                    
                    TextField("Enter your bio", text: $viewModel.link, axis: .vertical)
                        .foregroundColor(colorScheme == .light ? .black : .white )
                }
                
                Divider()
                
                VStack {
                    genderView
                    
                    Divider()
                    
                    backgroundImageView
                }
            }
            // how to make the view
            .font(.footnote)
            .padding()
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            }
            .padding()
            .padding(.top)
            
            Spacer()
        }
    }
}

extension EditProfileView {
    var genderView: some View {
        // gender
        HStack() {
            Text("Gender")
                .fontWeight(.semibold)
                .foregroundColor(colorScheme == .light ? .black : .white )
            
            Spacer()
            
            Text(viewModel.selectedGender)
            
            // > icon
            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundColor(colorScheme == .light ? .black : .white )
        }
        .padding(.vertical)
        // make the whole cell clickable
        .contentShape(Rectangle())
        // show gender
        .onTapGesture {
            showGenderPreview.toggle()
        }
        .fullScreenCover(isPresented: $showGenderPreview) {
            GenderView(selectedItemText: $viewModel.selectedGender)
        }
    }
}


extension EditProfileView {
    var backgroundImageView: some View {
        // Background image
        HStack() {
            PhotosPicker(selection: $viewModel.selectedBackgroundImage) {
                Text("Background Image")
                    .fontWeight(.semibold)
                    .foregroundColor(colorScheme == .light ? .black : .white )

                Spacer()
                
                if let image = viewModel.backgroundImage {
                    image
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                // > icon
                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .foregroundColor(colorScheme == .light ? .black : .white )
            }
        }
        .padding(.vertical)
        .contentShape(Rectangle())
    }
}
