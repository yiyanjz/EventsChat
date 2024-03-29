//
//  OtherUserProfileView.swift
//  EC
//
//  Created by Justin Zhang on 11/28/23.
//

import SwiftUI
import Kingfisher

struct OtherUserProfileView: View {
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: OtherUserProfileViewModel
    @State private var selectedFilter: OtherProfileFilter = .posts

    // get posts
    func getEvenPosts() -> [Post]{
        let sortedPosts = viewModel.allPosts.sorted(by: {$0.timestamp.dateValue() > $1.timestamp.dateValue()})
        return stride(from: 0, to: sortedPosts.count, by: 2).map { sortedPosts[$0] }
    }
    
    func getOddPosts() -> [Post]{
        let sortedPosts = viewModel.allPosts.sorted(by: {$0.timestamp.dateValue() > $1.timestamp.dateValue()})
        return stride(from: 1, to: sortedPosts.count, by: 2).map { sortedPosts[$0] }
    }
    
    // get stared posts
    func getEvenStaredPosts() -> [Post]{
        let sortedPosts = viewModel.staredPosts.sorted(by: {$0.timestamp.dateValue() > $1.timestamp.dateValue()})
        return stride(from: 0, to: sortedPosts.count, by: 2).map { sortedPosts[$0] }
    }
    
    func getOddStaredPosts() -> [Post]{
        let sortedPosts = viewModel.staredPosts.sorted(by: {$0.timestamp.dateValue() > $1.timestamp.dateValue()})
        return stride(from: 1, to: sortedPosts.count, by: 2).map { sortedPosts[$0] }
    }
    
    init(user: User) {
        self._viewModel = StateObject(wrappedValue: OtherUserProfileViewModel(user: user))
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
                    ScrollView(showsIndicators: false) {
                        ZStack {
                            backgroundView
                                
                            profileView
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
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // Back Button
                    Button{
                        dismiss()
                    }label: {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 20))
                    }
                    .foregroundColor(colorScheme == .light ? .black : .white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showSharedView.toggle()
                    } label: {
                        Image(systemName: "arrow.up.forward.circle")
                            .frame(width: 30, height: 30, alignment: .center)
                            .cornerRadius(15)
                            .foregroundColor(colorScheme == .light ? .black : .white )
                    }
                }
            }
            .fullScreenCover(isPresented: $viewModel.showPostDetails) {
                if let selectedPost = viewModel.selectedPost {
                    PostDetailView(showPostDetail: $viewModel.showPostDetails, post: selectedPost)
                }
            }
            .sheet(isPresented: $viewModel.showSharedView) {
                SharedView(actionButtonClicked: $viewModel.actionButtonClicked)
                    .presentationDetents([.medium, .large])
            }
        }
    }
}

struct OtherUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        OtherUserProfileView(user: User.MOCK_USERS[0])
    }
}

extension OtherUserProfileView {
    // Background View
    var backgroundView: some View {
        VStack {
            GeometryReader { proxy in
                let size = proxy.size
                let minY = proxy.frame(in: .named("OTHERSCROLL")).minY
                
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
    
    // profile view
    var profileView: some View {
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
                HStack(alignment:.center, spacing: screenWidth / 12) {
                    ProfileViewUserStats(value: viewModel.user.posts ?? 0, title: "Posts")
                    ProfileViewUserStats(value: viewModel.user.followering ?? 0, title: "Following")
                    ProfileViewUserStats(value: viewModel.user.followers ?? 0, title: "Followers")
                    ProfileViewUserStats(value: viewModel.user.likes ?? 0, title: "Likes")
                }
                .padding(.top,10)

                // Follow Button
                Button {
                    viewModel.userFollow.contains(where: {$0.id == viewModel.user.id}) ? viewModel.unfollowUser(followUserId: viewModel.user.id) : viewModel.followUser(followUserId: viewModel.user.id)
                } label: {
                    Text(viewModel.userFollow.contains(where: {$0.id == viewModel.user.id}) ? "Unfollow" : "Follow")
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
                        ForEach(0 ... 2, id: \.self) { story in
                            VStack {
                                Image("shin")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 55, height: 55)
                                    .clipShape(Circle())
                                
                                Text("Description")
                                    .font(.footnote)
                                    .foregroundColor(colorScheme == .light ? .black : .white )
                                    .frame(width: 70)
                            }
                        }
                        
                        Button {
                            print("OtherUserProfileView: New Story Button Tapped")
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
        }
    }
    
    // footerTitleView
    var footerTitleView: some View {
        VStack {
            let height = screenHeight * 0.06

            GeometryReader { proxy in
                let minY = proxy.frame(in: .named("OTHERSCROLL")).minY
                
                VStack {
                    // filter header
                    HStack(spacing: screenWidth / 5) {
                        // filter switch
                        ForEach(OtherProfileFilter.allCases, id: \.rawValue) { item in
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
                    .tag(OtherProfileFilter.posts)
                allStaredView
                    .tag(OtherProfileFilter.stars)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .frame(minHeight: screenHeight, maxHeight: screenHeight*3)
    }
    
    // post view
    var allPostView: some View {
        VStack {
            ScrollView(showsIndicators: false) {
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
    
    // stared view
    var allStaredView: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                HStack(alignment:.top) {
                    LazyVStack {
                        ForEach(getEvenStaredPosts()) { post in
                            PostView(post: post, likeFilter: false)
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
                            PostView(post: post, likeFilter: false)
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
