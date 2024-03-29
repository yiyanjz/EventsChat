//
//  FeedView.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI
import Kingfisher

struct FeedView: View {
    @Environment(\.colorScheme) var colorScheme
    let screenHeight = UIScreen.main.bounds.height
    @State private var selectedFilter: FeedFilter = .follow
    @StateObject var viewModel = FeedViewModel()
    @Binding var showTabBar: Bool
    
    func getEvenPosts() -> [Post]{
        let sortedPosts = viewModel.posts.sorted(by: {$0.timestamp.dateValue() > $1.timestamp.dateValue()})
        return stride(from: 0, to: sortedPosts.count, by: 2).map { sortedPosts[$0] }
    }
    
    func getOddPosts() -> [Post]{
        let sortedPosts = viewModel.posts.sorted(by: {$0.timestamp.dateValue() > $1.timestamp.dateValue()})
        return stride(from: 1, to: sortedPosts.count, by: 2).map { sortedPosts[$0] }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    headerView
                    
                    bodyView
                }
                .opacity(viewModel.showPostDetail ? 0 : 1)
                
                VStack {
                    if viewModel.showPostDetail {
                        if let selectedPost = viewModel.selectedPost {
                            PostDetailView(showPostDetail: $viewModel.showPostDetail, post: selectedPost)
                        }
                    }
                }
                .opacity(viewModel.showPostDetail ? 1 : 0)
            }
            .background(
                Color(uiColor: colorScheme == .light ? .gray : .black)
                    .opacity(0.1)
            )
            .fullScreenCover(isPresented: $viewModel.showSearchView) {
                SearchView()
            }
            .onChange(of: viewModel.showPostDetail) { _ in
                withAnimation(.easeInOut) {
                    showTabBar.toggle()
                }
            }
            .onAppear(perform: {
                Task {
                    try await viewModel.getCurrentUser()
                    try await viewModel.queryUserMainStory()
                }
            })
            .fullScreenCover(isPresented: $viewModel.previewStory, content: {
            })
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(showTabBar: .constant(false))
    }
}

// extension views
extension FeedView {
    var headerView: some View {
        VStack {
            HStack {
                // logo image
                Image("logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30)
                
                Spacer()
                
                // follow, explore, nearby buttons
                HStack(spacing: 15) {
                    ForEach(FeedFilter.allCases, id: \.rawValue) { item in
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
                
                Spacer()
                
                // search button
                Button{
                    viewModel.showSearchView.toggle()
                }label: {
                    Image(systemName: "magnifyingglass")
                        .fontWeight(.semibold)
                        .foregroundColor(colorScheme == .light ? .black : .white)
                }
                
            }
            .padding(.horizontal)
        }
    }
    
    var bodyView: some View {
        VStack {
            TabView(selection: $selectedFilter) {
                followView
                    .tag(FeedFilter.follow)
                
                exploreView
                    .tag(FeedFilter.explore)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
    
    var followView: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                // Story
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Button(action: {
                            viewModel.previewStory.toggle()
                        }, label: {
                            VStack {
                                KFImage(URL(string: viewModel.currentUser?.profileImageUrl ?? ""))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 55, height: 55)
                                    .clipShape(Circle())
                                
                                Text(viewModel.currentUser?.username ?? "")
                                    .font(.footnote)
                                    .foregroundColor(colorScheme == .light ? .black : .white )
                                    .frame(width: 70)
                            }
                        })
                        
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
                    }
                }
                .padding(.leading, 10)
                
                // posts
                LazyVStack {
                    ForEach(viewModel.followersPosts.sorted(by: {$0.timestamp.dateValue() > $1.timestamp.dateValue()}), id: \.self) { post in
                        // logic in post service therfore dont need to rewrite it in feed, explore, profile and other profile to filter visible to
                        FollowView(post: post)
                            .background(Color(uiColor: .systemBackground).brightness(0.1))
                            .cornerRadius(15)
                    }
                }
            }
        }
    }
    
    var exploreView: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                HStack(alignment:.top) {
                    LazyVStack {
                        ForEach(getEvenPosts()) { post in
                            PostView(post: post, likeFilter: true)
                                .onTapGesture {
                                    withAnimation(.linear(duration: 0.5)) {
                                        viewModel.selectedPost = post
                                        viewModel.showPostDetail.toggle()
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
                                        viewModel.showPostDetail.toggle()
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
