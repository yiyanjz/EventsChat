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
    @StateObject var viewModel: ProfileViewModel
    
    init(user: User) {
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(user: user))
    }
    
    // grid Item Structure
    private let gridItem: [GridItem] = [
        .init(.flexible(), spacing: 4),
        .init(.flexible(), spacing: 4),
    ]
    
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
                            
                            headerView
                        }
                        VStack {
                            footerTitleView
                                .zIndex(2)
                            
                            footerFilterView
                        }
                    }
                    .coordinateSpace(name: "SCROLL")
                    .ignoresSafeArea()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        NavigationLink(destination: SettingView().navigationBarBackButtonHidden(true)) {
                            Image(systemName: "line.3.horizontal")
                                .frame(width: 30, height: 30, alignment: .center)
                                .cornerRadius(15)
                                .foregroundColor(colorScheme == .light ? .black : .white)
                        }
                        .navigationBarBackButtonHidden(true)
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
                    SharedView()
                        .presentationDetents([.medium, .large])
                }
                .fullScreenCover(isPresented: $viewModel.showPostDetails) {
                    if let selectedPost = viewModel.selectedPost {
                        PostDetailView(showPostDetail: $viewModel.showPostDetails, post: selectedPost)
                    }
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: User.MOCK_USERS[0])
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
                HStack(alignment:.center, spacing: screenWidth / 12) {
                    ProfileViewUserStats(value: 1, title: "Posts")
                    ProfileViewUserStats(value: 10, title: "Following")
                    ProfileViewUserStats(value: 100, title: "Followers")
                    ProfileViewUserStats(value: 1000, title: "Likes")
                }
                .padding(.top,10)

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
                            print("ProfileView: New Story Button Tapped")
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
        .frame(minHeight: screenHeight, maxHeight: screenHeight*3)
    }
    
    // post view
    var allPostView: some View {
        VStack {
            GeometryReader { proxy2 in
                let _ = proxy2.frame(in: .named("SCROLL")).minY
                
                LazyVGrid(columns: gridItem, spacing: 16) {
                    ForEach(viewModel.allPosts.sorted(by: {$0.timestamp.dateValue() > $1.timestamp.dateValue()})) { post in
                        Button {
                            viewModel.selectedPost = post
                            viewModel.showPostDetails.toggle()
                        } label: {
                            PostView(post: post)
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
            GeometryReader { proxy2 in
                let _ = proxy2.frame(in: .named("SCROLL")).minY
                
                LazyVGrid(columns: gridItem, spacing: 16) {
                    ForEach(viewModel.likedPosts.sorted(by: {$0.timestamp.dateValue() > $1.timestamp.dateValue()})) { post in
                        Button {
                            viewModel.showPostDetails.toggle()
                            viewModel.selectedPost = post
                        } label: {
                            PostView(post: post)
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
            GeometryReader { proxy2 in
                let _ = proxy2.frame(in: .named("SCROLL")).minY
                
                LazyVGrid(columns: gridItem, spacing: 16) {
                    ForEach(viewModel.starPosts.sorted(by: {$0.timestamp.dateValue() > $1.timestamp.dateValue()})) { post in
                        Button {
                            viewModel.showPostDetails.toggle()
                            viewModel.selectedPost = post
                        } label: {
                            PostView(post: post)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 4)
    }
}
