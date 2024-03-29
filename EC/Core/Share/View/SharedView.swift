 //
//  SharedView.swift
//  EC
//
//  Created by Justin Zhang on 11/14/23.
//

import SwiftUI

struct SharedView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    @StateObject var viewModel = ShareViewModel()
    @State var post: Post?
    @Binding var actionButtonClicked: Bool
    
    func searchResults() -> [User]{
        if viewModel.searchUser.isEmpty {
            return viewModel.userFollowing
        } else {
            return viewModel.userFollowing.filter { $0.username.contains(viewModel.searchUser) }
        }
    }

    var body: some View {
        VStack {
            headerSearchView
            
            actionButtonView
        }
        .fullScreenCover(isPresented: $viewModel.showShareNewGoup) {
            ShareNewGroupView()
        }
    }
}

struct SharedView_Previews: PreviewProvider {
    static var previews: some View {
        SharedView(post: Post.MOCK_POST[0], actionButtonClicked: .constant(false))
    }
}

extension SharedView {
    var headerSearchView: some View {
        VStack {
            // search bar
            HStack{
                Image(systemName: "magnifyingglass")
                
                TextField("Search...", text: $viewModel.searchUser)
                
                Button {
                    viewModel.showShareNewGoup.toggle()
                } label: {
                    Image(systemName: "person.3")
                        .foregroundColor(colorScheme == .light ? .black : .white)

                }

            }
            .padding(10)
            .background(.gray.opacity(0.2),in: RoundedRectangle(cornerRadius: 20))
            
            // users
            ScrollView(showsIndicators: false) {
                ForEach(searchResults(), id: \.self) { user in
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
    }
    
    var actionButtonView: some View {
        HStack {
            if viewModel.selectedUsers.count == 0 {
                // action buttons
                HStack(spacing: 30) {
                    // Add to Story
                    Button {
                        print("StoryView: Add new Story button clicked")
                        actionButtonClicked.toggle()
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
                    
                    // Share
                    Button {
                        print("StoryView: Share button clicked")
                        actionButtonClicked.toggle()
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
                    
                    // Delete Post
                    if let post = post, viewModel.currentUser == post.user {
                        Button {
                            Task {
                                try await viewModel.deletePost(post: post)
                                actionButtonClicked.toggle()
                                dismiss()
                            }
                        } label: {
                            VStack(spacing: 5) {
                                Image(systemName: "trash.slash")
                                    .font(.system(size:30))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.black, lineWidth: 1)
                                            .frame(width: 50, height: 50)
                                    )
                                
                                Spacer()
                                
                                Text("Delete Post")
                                    .font(.system(size:15))
                            }
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
