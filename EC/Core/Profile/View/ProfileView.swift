//
//  ProfileView.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI
import Kingfisher

struct ProfileView: View {
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    @State private var selectedFilter: ProfileFilter = .posts
    @State private var showEditProfile = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: ProfileViewModel
    
    init(user: User, withBackButton: Bool) {
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(user: user, withBackButton: withBackButton))
    }
    
    // get posts
    func getEvenPosts() -> [Post]{
        let sortedPosts = viewModel.allPosts.sorted(by: {$0.timestamp.dateValue() > $1.timestamp.dateValue()})
        return stride(from: 0, to: sortedPosts.count, by: 2).map { sortedPosts[$0] }
    }
    
    func getOddPosts() -> [Post]{
        let sortedPosts = viewModel.allPosts.sorted(by: {$0.timestamp.dateValue() > $1.timestamp.dateValue()})
        return stride(from: 1, to: sortedPosts.count, by: 2).map { sortedPosts[$0] }
    }
    
    // get liked posts
    func getEvenLikedPosts() -> [Post]{
        let sortedPosts = viewModel.likedPosts.sorted(by: {$0.timestamp.dateValue() > $1.timestamp.dateValue()})
        return stride(from: 0, to: sortedPosts.count, by: 2).map { sortedPosts[$0] }
    }
    
    func getOddLikedPosts() -> [Post]{
        let sortedPosts = viewModel.likedPosts.sorted(by: {$0.timestamp.dateValue() > $1.timestamp.dateValue()})
        return stride(from: 1, to: sortedPosts.count, by: 2).map { sortedPosts[$0] }
    }
    
    // get stared posts
    func getEvenStaredPosts() -> [Post]{
        let sortedPosts = viewModel.starPosts.sorted(by: {$0.timestamp.dateValue() > $1.timestamp.dateValue()})
        return stride(from: 0, to: sortedPosts.count, by: 2).map { sortedPosts[$0] }
    }
    
    func getOddStaredPosts() -> [Post]{
        let sortedPosts = viewModel.starPosts.sorted(by: {$0.timestamp.dateValue() > $1.timestamp.dateValue()})
        return stride(from: 1, to: sortedPosts.count, by: 2).map { sortedPosts[$0] }
    }
    
    func backgroundColor() -> Color{
        var color = Color(uiColor: .systemBackground)
        
        if colorScheme == .light {
            color = Color(uiColor: .white)
        } else if colorScheme == .dark {
            color = Color(uiColor: .black)
        }
        
        return color
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    ScrollView(showsIndicators: true) {
                        ZStack {
                            backgroundView
                            
                            headerView
                        }
                        VStack {
                            footerTitleView
                                .zIndex(2)
                            
                            Divider()
                                .padding(8)
                            
                            footerFilterView
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if viewModel.withBackButton {
                            // Back Button
                            Button{
                                dismiss()
                            }label: {
                                Image(systemName: "chevron.backward")
                                    .font(.system(size: 20))
                            }
                            .foregroundColor(colorScheme == .light ? .black : .white)
                        }else {
                            NavigationLink(destination: SettingView().navigationBarBackButtonHidden(true)) {
                                Image(systemName: "line.3.horizontal")
                                    .frame(width: 30, height: 30, alignment: .center)
                                    .cornerRadius(15)
                                    .foregroundColor(colorScheme == .light ? .black : .white)
                            }
                            .navigationBarBackButtonHidden(true)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            viewModel.showSharedCard.toggle()
                        } label: {
                            Image(systemName: "arrow.up.forward.circle")
                                .frame(width: 30, height: 30, alignment: .center)
                                .cornerRadius(15)
                                .foregroundColor(colorScheme == .light ? .black : .white )
                        }
                    }
                }
                .sheet(isPresented: $viewModel.showSharedCard) {
                    SharedView(actionButtonClicked: $viewModel.actionButtonClicked)
                        .presentationDetents([.medium, .large])
                }
                .fullScreenCover(isPresented: $viewModel.showPostDetails) {
                    if let selectedPost = viewModel.selectedPost {
                        PostDetailView(showPostDetail: $viewModel.showPostDetails, post: selectedPost)
                    }
                }
                .fullScreenCover(isPresented: $viewModel.showStoryView) {
                    StorySelectMediaView()
                }
                .fullScreenCover(isPresented: $viewModel.showProfileStory) {
                    if let selectedProfileStory = viewModel.selectedProfileStory {
                        let countTime = CountTimer(items: selectedProfileStory.selectedMedia.count, interval: 4.0)
                        StoryView(media: selectedProfileStory, user: viewModel.user, countTimer: countTime)
                    }
                }
                .fullScreenCover(isPresented: $viewModel.showProfileInfo) {
                    ProfileInfoView(user: viewModel.user)
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: User.MOCK_USERS[0], withBackButton: false)
    }
}

// extensions views
extension ProfileView {
    // Background View
    var backgroundView: some View {
        VStack {
            GeometryReader { proxy in
                let size = proxy.size
                let minY = proxy.frame(in: .named("SCROLL")).minY
                
                KFImage(URL(string: viewModel.user.backgroundImageUrl ?? "background"))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width, height: size.height + (minY > 0 ? minY : 0))
                    .blur(radius: 10)
                    .overlay(Color(uiColor: .gray).opacity(0.6))
                    .clipped()
                    .offset(y: minY > 0 ? -minY : 0)
            }
        }
    }
    
    // header view
    var headerView: some View {
        VStack {
            VStack(spacing: 10) {
                // ProfileImage + Name + InChatID
                VStack {
                    CircularProfileImageView(user: viewModel.user, size: .large)
                    
                    HStack {
                        VStack(spacing: 5) {
                            Text(viewModel.user.username)
                                .font(.title2).bold()
                                .foregroundColor(colorScheme == .light ? .black : .white )
                            
                            let icon = Image(systemName: "link")
                            
                            Text("\(icon): \(viewModel.user.link ?? "")")
                                .textInputAutocapitalization(.never)
                                .font(.footnote)
                                .accentColor(colorScheme == .light ? .black : .white)
                                .foregroundColor(colorScheme == .light ? .black : .white )
                                .fontWeight(.light).bold()
                        }
                    }
                }
                .padding(.trailing, 5)
                
                // Bio
                VStack {
                    Text(viewModel.user.bio ?? "Please Fill Out Your Information By Clicking Edit Profile Button")
                        .textInputAutocapitalization(.never)
                        .font(.footnote)
                        .foregroundColor(colorScheme == .light ? .black : .white )
                        .lineLimit(4)
                        .multilineTextAlignment(.leading)
                        .frame(width: screenWidth - 100, alignment: .top)
                }
                
                // Follower + Following + Likes
                Button {
                    viewModel.showProfileInfo.toggle()
                } label: {
                    HStack(alignment:.center, spacing: screenWidth / 12) {
                        ProfileViewUserStats(value: viewModel.user.posts ?? 0, title: "Posts")
                        ProfileViewUserStats(value: viewModel.user.followering ?? 0, title: "Following")
                        ProfileViewUserStats(value: viewModel.user.followers ?? 0, title: "Followers")
                        ProfileViewUserStats(value: viewModel.user.likes ?? 0, title: "Likes")
                    }
                    .padding(.top,10)
                }

                // Edit Profile Button
                Button {
                    showEditProfile.toggle()
                } label: {
                    Text("Edit Profile")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(width: screenWidth - 20, height: 30, alignment: .center)
                        .foregroundColor(colorScheme == .light ? .black : .white )
                        .background(colorScheme == .light ? Color.white.brightness(0) : Color.black.brightness(0))
                        .cornerRadius(10)
                }
                .padding(.top,10)
                
                // Story
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.profileStorys.sorted(by: {$0.timestamp.dateValue() > $1.timestamp.dateValue()})) { story in
                            VStack {
                                Button {
                                    viewModel.showProfileStory.toggle()
                                    viewModel.selectedProfileStory = story
                                } label: {
                                    VStack {
                                        KFImage(URL(string: story.selectedCover))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 55, height: 55)
                                            .clipShape(Circle())
                                        
                                        Text(story.caption)
                                            .font(.footnote)
                                            .foregroundColor(colorScheme == .light ? .black : .white )
                                            .frame(width: 70)
                                    }
                                }
                            }
                        }
                        
                        Button {
                            viewModel.showStoryView.toggle()
                        } label: {
                            Image(systemName: "plus.circle")
                                .resizable()
                                .scaledToFill()
                                .foregroundColor(colorScheme == .light ? .white : .black )
                                .frame(width: 55, height: 55)
                                .clipShape(Circle())
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 7)
                }
            }
            .frame(height: screenHeight / 2)
            .padding(.top, 15)
            .fullScreenCover(isPresented: $showEditProfile) {
                EditProfileView(user: viewModel.user)
            }
        }
    }
    
    // footerTitleView
    var footerTitleView: some View {
        VStack {
            let height = screenHeight * 0.06

            GeometryReader { proxy in
                let minY = proxy.frame(in: .named("SCROLL")).minY
                
                VStack {
                    // filter header
                    HStack(spacing: screenWidth / 5) {
                        // filter switch
                        ForEach(ProfileFilter.allCases, id: \.rawValue) { item in
                            VStack{
                                Text(item.title)
                                    .font(.subheadline)
                                    .fontWeight(selectedFilter == item ? .semibold : .regular)
                                    .foregroundColor(colorScheme == .light ? .black : .white)
                                    // .frame == underline's height .offset = underlines y's pos
                                    .background( selectedFilter == item ? Color.red.frame(width: 30, height: 2).offset(y: 14)
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
                    .frame(width:screenWidth, height: height + 5)
                    .background(
                        (minY < 130) ? backgroundColor().frame(width: screenWidth).clipShape(RoundedShape(corners: [])) : backgroundColor().frame(width: screenWidth).clipShape(RoundedShape(corners: [.topLeft, .topRight]))
                    )
                    .padding(.top, -40)
                }
                .offset(y: minY < 130 ? -(minY - 130) : 0)
                .navigationTitle( minY < 400 ? viewModel.user.username : "")
            }
        }
    }
    
    var footerFilterView: some View {
        VStack {
            TabView(selection: $selectedFilter) {
                allPostView
                    .tag(ProfileFilter.posts)
                allLikesView
                    .tag(ProfileFilter.likes)
                allStarsView
                    .tag(ProfileFilter.stars)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .frame(minHeight: screenHeight*3)
    }
    
    // post view
    var allPostView: some View {
        VStack {
            GeometryReader { proxy in
                
                HStack(alignment:.top) {
                    LazyVStack {
                        ForEach(getEvenPosts()) { post in
                            PostView(post: post, likeFilter: true)
                                .onTapGesture {
                                    withAnimation(.linear(duration: 0.5)) {
                                        viewModel.selectedPost = post
                                        viewModel.showPostDetails.toggle()
                                    }
                                }
                        }
                    }
                    LazyVStack {
                        ForEach(getOddPosts()) { post in
                            PostView(post: post, likeFilter: true)
                                .onTapGesture {
                                    withAnimation(.linear(duration: 0.5)) {
                                        viewModel.selectedPost = post
                                        viewModel.showPostDetails.toggle()
                                    }
                                }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 4)
    }
    
    // likes view
    var allLikesView: some View {
        VStack {
            GeometryReader { proxy in
                
                HStack(alignment:.top) {
                    LazyVStack {
                        ForEach(getEvenLikedPosts()) { post in
                            PostView(post: post, likeFilter: true)
                                .onTapGesture {
                                    withAnimation(.linear(duration: 0.5)) {
                                        viewModel.selectedPost = post
                                        viewModel.showPostDetails.toggle()
                                    }
                                }
                        }
                    }
                    LazyVStack {
                        ForEach(getOddLikedPosts()) { post in
                            PostView(post: post, likeFilter: true)
                                .onTapGesture {
                                    withAnimation(.linear(duration: 0.5)) {
                                        viewModel.selectedPost = post
                                        viewModel.showPostDetails.toggle()
                                    }
                                }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 4)
    }
    
    // stars view
    var allStarsView: some View {
        VStack {
            GeometryReader { proxy in

                HStack(alignment:.top) {
                    LazyVStack {
                        ForEach(getEvenStaredPosts()) { post in
                            PostView(post: post, likeFilter: true)
                                .onTapGesture {
                                    withAnimation(.linear(duration: 0.5)) {
                                        viewModel.selectedPost = post
                                        viewModel.showPostDetails.toggle()
                                    }
                                }
                        }
                    }
                    LazyVStack {
                        ForEach(getOddStaredPosts()) { post in
                            PostView(post: post, likeFilter: true)
                                .onTapGesture {
                                    withAnimation(.linear(duration: 0.5)) {
                                        viewModel.selectedPost = post
                                        viewModel.showPostDetails.toggle()
                                    }
                                }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 4)
    }
}
