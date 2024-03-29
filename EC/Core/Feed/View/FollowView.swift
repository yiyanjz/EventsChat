//
//  FollowView.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI
import Kingfisher
import AVFoundation
import _AVKit_SwiftUI

struct FollowView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State private var selectedFilter: FeedFilter = .follow
    @StateObject var viewModel: FollowViewModel
    
    @State var likeCount = 0
    @State var animationXCord = 0.0
    @State var animationYCord = 0.0
    func TapAction() {
        likeCount += 1
    }
    
    init(post: Post) {
        self._viewModel = StateObject(wrappedValue: FollowViewModel(post: post))
    }
    
    func checkUserLikedPost() -> Bool {
        if let userLiked = viewModel.post.userLiked, let currentUser = viewModel.currentUser, userLiked.contains("\(currentUser.id)") {
            return true
        } else {
            return false
        }
    }
    
    func checkUserStarPost() -> Bool {
        if let userStared = viewModel.post.userStared, let currentUser = viewModel.currentUser, userStared.contains("\(currentUser.id)") {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        VStack {
            headerView
                .padding()
            imageView
            actionButtonView
                .padding(.horizontal, 10)
            bottomView
                .padding(.horizontal)
                .padding(.bottom)
        }
        .cornerRadius(15)
        .sheet(isPresented: $viewModel.showAllLikes) {
            if let userLiked = viewModel.post.userLiked {
                AllLikesView(likedList: userLiked)
            }
        }
        .sheet(isPresented: $viewModel.showComments) {
            if let user = viewModel.post.user {
                CommentsView(user: user, post: viewModel.post)
                    .presentationDetents([.medium, .large])
            }
        }
        .sheet(isPresented: $viewModel.showShared) {
            SharedView(post: viewModel.post, actionButtonClicked: $viewModel.actionButtonClicked)
                .presentationDetents([.medium, .large])
        }
    }
}

struct FollowView_Previews: PreviewProvider {
    static var previews: some View {
        FollowView(post: Post.MOCK_POST[1])
    }
}

extension FollowView {
    var headerView: some View {
        HStack {
            if let postUser = viewModel.post.user{
                NavigationLink {
                    if let user = viewModel.post.user, let currentUser = viewModel.currentUser {
                        if user.id == currentUser.id {
                            ProfileView(user: currentUser, withBackButton: true)
                                .navigationBarBackButtonHidden()
                        }else {
                            OtherUserProfileView(user: user)
                                .navigationBarBackButtonHidden()
                        }
                    }
                } label: {
                    CircularProfileImageView(user: postUser, size: .xsmall)
                    
                    VStack(alignment: .leading) {
                        Text(postUser.username)
                            .fontWeight(.bold)
                            .font(.system(size: 15))
                            .foregroundColor(colorScheme == .light ? .black : .white)
                        
                        let date = viewModel.post.timestamp.dateValue()
                        Text("\(date.calenderTimeSinceNow())")
                            .fontWeight(.regular)
                            .font(.system(size: 10))
                            .foregroundColor(Color(uiColor: .label))
                    }
                    
                    Spacer()
                }
                
                Button{
                    viewModel.showShared.toggle()
                }label: {
                    Image(systemName: "square.and.arrow.up")
                        .frame(width: 30, height: 30, alignment: .center)
                        .cornerRadius(15)
                        .foregroundColor(colorScheme == .light ? .black : .white)
                }
            }
        }
    }
    
    var imageView: some View {
        VStack {
            TabView {
                ForEach(viewModel.post.imagesUrl, id: \.self){ image in
                    ZStack {
                        VStack {
                            if image.contains("post_images") {
                                KFImage(URL(string: image))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.width - 20, height: 400, alignment: .center)
                                    .cornerRadius(15)
                            } else {
                                VideoPlayer(player: AVPlayer(url: URL(string: image)!))
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.width - 20, height: 400, alignment: .center)
                                    .cornerRadius(15)
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
                }
                .onTapGesture(count: 2) { location in
                    if checkUserLikedPost() == false{
                        viewModel.likePost()
                    }
                    TapAction()
                    animationXCord = location.x
                    animationYCord = location.y
                }
            }
            .tabViewStyle(.page)
            .frame(height: 400)
        }
    }
    
    var actionButtonView: some View {
        HStack {
            // likes
            Button{
                withAnimation(.spring()) {
                    checkUserLikedPost() ? viewModel.unlikePost() : viewModel.likePost()
                }
            }label: {
                Image(systemName: checkUserLikedPost() ? "heart.fill" : "heart")
                    .frame(width: 30, height: 30, alignment: .center)
                    .cornerRadius(15)
                    .foregroundColor(checkUserLikedPost() ? .red : colorScheme == .light ? .black : .white)
            }
            
            // all likes
            if let allLikesCount = viewModel.post.userLiked?.count, allLikesCount > 0 {
                Button {
                    viewModel.showAllLikes.toggle()
                } label: {
                    Text("\(viewModel.post.likes) likes")
                        .fontWeight(.semibold)
                        .font(.system(size: 13))
                }
            }
            
            Spacer()
            
            // comment
            Button{
                viewModel.showComments.toggle()
            }label: {
                Image(systemName: "ellipsis.bubble")
                    .frame(width: 30, height: 30, alignment: .center)
                    .cornerRadius(15)
            }

            // star
            Button{
                withAnimation(.spring()) {
                    checkUserStarPost() ? viewModel.unstarPost() : viewModel.starPost()
                }
            }label: {
                Image(systemName: checkUserStarPost() ? "star.fill" : "star")
                    .frame(width: 30, height: 30, alignment: .center)
                    .cornerRadius(15)
                    .foregroundColor(checkUserStarPost() ? .yellow : colorScheme == .light ? .black : .white)
                    .offset(y: -1)
            }
        }
        .foregroundColor(colorScheme == .light ? .black : .white)
    }
    
    var bottomView: some View {
        // caption
        VStack(spacing: 8){
            HStack{
                let icon = Image(systemName: "text.bubble")
                Text("\(icon): \(viewModel.post.title)")
                    .font(.system(size: 15))
                    .lineLimit(1)

            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

