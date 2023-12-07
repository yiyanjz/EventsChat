 //
//  SharedView.swift
//  EC
//
//  Created by Justin Zhang on 11/14/23.
//

import SwiftUI

struct SharedView: View {
    @Environment(\.colorScheme) var colorScheme
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    @StateObject var viewModel = ShareViewModel()

    var body: some View {
        VStack {
            VStack {
                // search bar
                HStack{
                    Image(systemName: "magnifyingglass")
                    
                    TextField("Search...", text: $viewModel.searchUser)
                    
                    Button {
                        print("StoryView: New Group Chat")
                    } label: {
                        Image(systemName: "person.3")
                            .foregroundColor(colorScheme == .light ? .black : .white)

                    }

                }
                .padding(10)
                .background(.gray.opacity(0.2),in: RoundedRectangle(cornerRadius: 20))
                
                // users
                ScrollView(showsIndicators: false) {
                    ForEach(viewModel.userFollowing, id: \.self) { user in
                        // users
                        HStack {
                            CircularProfileImageView(user: user, size: .small)
                            
                            VStack(alignment:.leading){
                                Text(user.fullname ?? "")
                                    .fontWeight(.bold)
                                Text(user.username)
                            }
                            .font(.system(size: 15))
                            
                            Spacer()
                            
                            Button {
                                viewModel.selectedUsers.contains(user)
                                ? viewModel.selectedUsers.removeAll(where: {$0 == user})
                                : viewModel.selectedUsers.append(user)
                            } label: {
                                Image(systemName: viewModel.selectedUsers.contains(user) ? "circle.fill" : "circle")
                                    .resizable()
                                    .frame(width: 30, height: 30, alignment: .center)
                                    .foregroundColor(viewModel.selectedUsers.contains(user) ? Color(uiColor: .blue) : Color(uiColor: .gray))
                            }
                        }
                        .padding(.top)
                    }
                }
                Divider()
            }
            .padding()
            .padding(.horizontal, 8)
            
            if viewModel.selectedUsers.count == 0 {
                // action buttons
                HStack(spacing: 30) {
                    // Add to Story
                    Button {
                        print("StoryView: Add new Story button clicked")
                    } label: {
                        VStack(spacing: 5) {
                            Image(systemName: "memories.badge.plus")
                                .font(.system(size:25))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 1)
                                        .frame(width: 50, height: 50)
                                )
                            
                            Spacer()
                            
                            Text("Add story")
                                .font(.system(size:15))
                        }
                    }
                    
                    // Copy Link
                    Button {
                        print("StoryView: Copy Link button clicked")
                    } label: {
                        VStack(spacing: 5) {
                            Image(systemName: "link.badge.plus")
                                .font(.system(size:25))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 1)
                                        .frame(width: 50, height: 50)
                                )
                            
                            Spacer()
                            
                            Text("Copy Link")
                                .font(.system(size:15))
                        }
                    }
                    
                    // Share
                    Button {
                        print("StoryView: Share button clicked")
                    } label: {
                        VStack(spacing: 5) {
                            Image(systemName: "square.and.arrow.up.circle")
                                .font(.system(size:30))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 1)
                                        .frame(width: 50, height: 50)
                                )
                            
                            Spacer()
                            
                            Text("Share To")
                                .font(.system(size:15))
                        }
                    }
                }
                .padding(.top)
                .foregroundColor(colorScheme == .light ? .black : .white)
                .frame(width:UIScreen.main.bounds.width, height: 50, alignment: .center)
            } else {
                // action buttons
                HStack{
                    // Add to Story
                    Button {
                        print("StoryView: Add new Story button clicked")
                    } label: {
                        Text("Send")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(width: screenWidth - 80, height: 44)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.top)
                .frame(width:UIScreen.main.bounds.width, height: 50, alignment: .center)
            }
        }
    }
}

struct SharedView_Previews: PreviewProvider {
    static var previews: some View {
        SharedView()
    }
}
