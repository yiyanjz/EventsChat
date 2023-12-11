//
//  ProfileInfoView.swift
//  EC
//
//  Created by Justin Zhang on 12/10/23.
//

import SwiftUI
import Kingfisher

struct ProfileInfoView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedFilter: ProfileInfoFilter = .following
    @StateObject var viewModel: ProfileInfoViewModel
    
    func searchUserFollow() -> [User]{
        if viewModel.searchFollowing.isEmpty {
            return viewModel.userFollow
        } else {
            return viewModel.userFollow.filter { $0.username.contains(viewModel.searchFollowing) }
        }
    }
    
    func searchFollowingUser() -> [User] {
        if viewModel.searchFollow.isEmpty {
            return viewModel.followingUser
        } else {
            return viewModel.followingUser.filter { $0.username.contains(viewModel.searchFollow) }
        }
    }
    
    init(user: User){
        self._viewModel = StateObject(wrappedValue: ProfileInfoViewModel(user: user))
    }

    var body: some View {
        VStack {
            headerView
            
            bodyView
        }
    }
}

struct ProfileInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileInfoView(user: User.MOCK_USERS[0])
    }
}

extension ProfileInfoView {
    // headerView
    var headerView: some View {
        VStack {
            // ToolBar
            HStack {
                // cancel button
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrowshape.backward")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(colorScheme == .light ? .black : .white)
                }
            }
            .padding(.horizontal)
            
            // follow, explore, nearby buttons
            HStack(spacing: 15) {
                ForEach(ProfileInfoFilter.allCases, id: \.rawValue) { item in
                    VStack{
                        Text(item.title)
                            .font(.title3)
                            .fontWeight(selectedFilter == item ? .semibold : .regular)
                            .foregroundColor(colorScheme == .light ? .black : .white)
                            // .frame == underline's height .offset = underlines y's pos
                            .background( selectedFilter == item ? Color.red.frame(width: 60, height: 2).offset(y: 14)
                                         : Color.clear.frame(width: 30, height: 1).offset(y: 14)
                            )
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            selectedFilter = item
                        }
                    }
                }
            }
        }
    }
    
    var bodyView: some View {
        VStack {
            TabView(selection: $selectedFilter) {
                profileFollowingView
                    .tag(ProfileInfoFilter.following)
                
                profileFollowerView
                    .tag(ProfileInfoFilter.follower)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
    
    var profileFollowingView: some View {
        VStack {
            // search bar + icon
            HStack {
                Image(systemName: "magnifyingglass")
                    .fontWeight(.semibold)
                    .padding(.leading, 10)
                
                TextField("Search Following", text: $viewModel.searchFollowing)
                
            }
            .frame(height: 35)
            .background(.gray.opacity(0.2),in: RoundedRectangle(cornerRadius: 20))
            
            Text("Following")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            // users
            ForEach(searchUserFollow(), id: \.self) { user in
                HStack {
                    KFImage(URL(string: user.profileImageUrl ?? ""))
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    
                    Text(user.username)
                        .font(.system(size: 15))
                        .foregroundColor(colorScheme == .light ? .black : .white)
                    
                    Spacer()
                    
                    Button{
                        viewModel.userFollow.contains(where: {$0.id == user.id}) ? viewModel.unfollowUser(followUserId: user.id) : viewModel.followUser(followUserId: user.id)
                    }label: {
                        Text(viewModel.userFollow.contains(where: {$0.id == user.id}) ? "Unfollow" : "Follow")
                            .foregroundColor(.red)
                            .padding(.vertical,5)
                            .padding(.horizontal,18)
                            .padding(1)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(uiColor: .red), lineWidth: 1)
                            )
                    }
                    .font(.system(size: 12))
                }
            }
            
            Spacer()
        }
        .padding()
        .searchable(text: $viewModel.searchFollowing)
    }
    
    var profileFollowerView: some View {
        VStack {
            // search bar + icon
            HStack {
                Image(systemName: "magnifyingglass")
                    .fontWeight(.semibold)
                    .padding(.leading, 10)
                
                TextField("Search Follower", text: $viewModel.searchFollow)
                
            }
            .frame(height: 35)
            .background(.gray.opacity(0.2),in: RoundedRectangle(cornerRadius: 20))
            
            Text("Follower")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            // users
            ForEach(searchFollowingUser(), id: \.self) { user in
                HStack {
                    KFImage(URL(string: user.profileImageUrl ?? ""))
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    
                    Text(user.username)
                        .font(.system(size: 15))
                        .foregroundColor(colorScheme == .light ? .black : .white)
                    
                    Spacer()
                    
                    Button{
                        viewModel.userFollow.contains(where: {$0.id == user.id}) ? viewModel.unfollowUser(followUserId: user.id) : viewModel.followUser(followUserId: user.id)
                    }label: {
                        Text(viewModel.userFollow.contains(where: {$0.id == user.id}) ? "Unfollow" : "Follow")
                            .foregroundColor(.red)
                            .padding(.vertical,5)
                            .padding(.horizontal,18)
                            .padding(1)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(uiColor: .red), lineWidth: 1)
                            )
                    }
                    .font(.system(size: 12))
                }
            }
            
            Spacer()
            
        }
        .padding()
        .searchable(text: $viewModel.searchFollow)
    }
}
