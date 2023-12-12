//
//  PostDetailView.swift
//  EC
//
//  Created by Justin Zhang on 11/15/23.
//

import SwiftUI
import Kingfisher
import AVFoundation
import _AVKit_SwiftUI

struct PostDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var showPostDetail: Bool
    @StateObject var viewModel: PostDetailViewModel
    
    // like animation
    @State var likeCount = 0
    @State var animationXCord = 0.0
    @State var animationYCord = 0.0
    func TapAction() {
        likeCount += 1
    }
    
    init(showPostDetail: Binding<Bool>, post: Post) {
        self._viewModel = StateObject(wrappedValue: PostDetailViewModel(post: post))
        self._showPostDetail = showPostDetail
    }
    
    var body: some View {
        VStack {
            headerView
            
            bodyView
        }
        .sheet(isPresented: $viewModel.showShared) {
            SharedView(post: viewModel.post)
                .presentationDetents([.medium, .large])
                .onDisappear {
                    showPostDetail.toggle()
                }
        }
        .fullScreenCover(isPresented: $viewModel.showUserProfile) {
            if let user = viewModel.post.user, let currentUser = viewModel.currentUser {
                if user.id == currentUser.id {
                    ProfileView(user: currentUser, withBackButton: true)
                }else {
                    OtherUserProfileView(user: user)
                }
            }
        }
    }
}

struct PostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PostDetailView(showPostDetail: .constant(false), post: Post.MOCK_POST[0])
    }
}

extension PostDetailView {
    // header view
    var headerView: some View {
        // header
        HStack{
            // Back Button
            Button{
                showPostDetail.toggle()
            }label: {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 20))
            }
            .foregroundColor(colorScheme == .light ? .black : .white)
            
            // Profile Image + Username
            if let user = viewModel.post.user {
                Button(action: {
                    viewModel.showUserProfile.toggle()
                }, label: {
                    CircularProfileImageView(user: user, size: .xsmall)
                    
                    Text(user.username)
                        .font(.system(size: 14))
                })
                .foregroundColor(colorScheme == .light ? .black : .white)
            }
            
            Spacer()
            
            // follow Button
            Button{
                viewModel.userFollow.contains(where: {$0 == viewModel.post.user}) ? viewModel.unfollowUser(followUserId: viewModel.post.user?.id ?? "") : viewModel.followUser(followUserId: viewModel.post.user?.id ?? "")
            }label: {
                Text(viewModel.userFollow.contains(where: {$0 == viewModel.post.user}) ? "Unfollow" : "Follow")
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
            
            // Shared Button
            Button{
                viewModel.showShared.toggle()
            }label: {
                Image(systemName: "square.and.arrow.up")
                    .frame(width: 30, height: 30, alignment: .center)
                    .cornerRadius(15)
                    .foregroundColor(colorScheme == .light ? .black : .white)
            }
        }
        .padding(.horizontal)
    }
    
    // body view
    var bodyView: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                // Image
                TabView {
                    ForEach(viewModel.post.imagesUrl, id: \.self){ image in
                        ZStack {
                            VStack {
                                if image.contains("post_images") {
                                    KFImage(URL(string: image))
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    VideoPlayer(player: AVPlayer(url: URL(string: image)!))
                                        .scaledToFill()
                                }
                            }
                            
                            ForEach(0 ..< likeCount, id: \.self) { _ in
                                Image(systemName: "heart.fill")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .padding()
                                    .modifier(LoveTapModifier())
                                    .position(x: animationXCord, y: animationYCord)
                            }
                        }
                        .onTapGesture(count: 2) { location in
                            if viewModel.post.didLike == false {
                                viewModel.likePost()
                            }
                            TapAction()
                            animationXCord = location.x
                            animationYCord = location.y
                        }
                    }
                }
                .tabViewStyle(.page)
                .frame(height: 500)
                
                // Title + action buttons
                HStack {
                    // title
                    VStack {
                        Text(viewModel.post.title)
                    }
                    .font(.system(size: 25))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // action button
                    // likes
                    Button{
                        withAnimation(.spring()) {
                            viewModel.post.didLike ?? false ? viewModel.unlikePost() : viewModel.likePost()
                        }
                    }label: {
                        HStack(spacing:0) {
                            Image(systemName: viewModel.post.didLike ?? false ? "heart.fill" : "heart")
                                .frame(width: 30, height: 30, alignment: .center)
                                .cornerRadius(15)
                                .foregroundColor(viewModel.post.didLike ?? false ? .red : colorScheme == .light ? .black : .white)
                            
                            Text("\(viewModel.post.likes)")
                        }
                        .foregroundColor(colorScheme == .light ? .black : .white)
                    }

                    // star
                    Button{
                        withAnimation(.spring()) {
                            viewModel.post.didStar ?? false ? viewModel.unstarPost() : viewModel.starPost()
                        }
                    }label: {
                        HStack(spacing:0) {
                            Image(systemName: viewModel.post.didStar ?? false ? "star.fill" : "star")
                                .frame(width: 30, height: 30, alignment: .center)
                                .cornerRadius(15)
                                .foregroundColor(viewModel.post.didStar ?? false ? .yellow : colorScheme == .light ? .black : .white)
                                .offset(y: -1)
                            
                            Text("\(viewModel.post.stars)")
                        }
                        .foregroundColor(colorScheme == .light ? .black : .white)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 5)
                            
                // Caption
                VStack{
                    let icon = Image(systemName: "text.bubble")
                    Text("\(icon): \(viewModel.post.caption)")
                }
                .font(.system(size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                Divider()
                
                if let user = viewModel.post.user {
                    CommentsView(user: user, post: viewModel.post)
                }
            }
        }
    }
}
