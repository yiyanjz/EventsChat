//
//  SearchResultView.swift
//  EC
//
//  Created by Justin Zhang on 11/9/23.
//

import SwiftUI
import Kingfisher

struct SearchResultView: View {
    @State var scrollsize : CGFloat = 0
    
    @Environment(\.dismiss) var dismiss
    @State private var selectedFilter: SearchFilter = .all
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var viewModel: SearchResultViewModel
    
    init(searchText: Binding<String>, searched: Binding<Bool>, allSearchText: Binding<[String]>){
        self._viewModel = StateObject(wrappedValue: SearchResultViewModel(searchText: searchText, searched: searched, allSearchText: allSearchText))
    }
    
    func getEvenPosts() -> [Post]{
        let sortedPosts = viewModel.postsResult.sorted(by: {$0.timestamp.dateValue() > $1.timestamp.dateValue()})
        return stride(from: 0, to: sortedPosts.count, by: 2).map { sortedPosts[$0] }
    }
    
    func getOddPosts() -> [Post]{
        let sortedPosts = viewModel.postsResult.sorted(by: {$0.timestamp.dateValue() > $1.timestamp.dateValue()})
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
        }
    }
}

struct SearchResultView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultView(searchText: .constant(""), searched: .constant(false), allSearchText: .constant([""]))
    }
}

extension SearchResultView {
    var headerView: some View {
        VStack {
            // header
            HStack{
                // search
                Button{
                    withAnimation {
                        dismiss()
                    }
                    viewModel.searched = false
                    viewModel.searchText = ""
                }label: {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(colorScheme == .light ? .black : .white)
                }
                
                HStack{
                    Image(systemName: "magnifyingglass")
                    
                    TextField("\(viewModel.searchText)", text: $viewModel.newSearchText)
                        .onAppear {
                            viewModel.newSearchText = viewModel.searchText
                        }
                        .onSubmit {
                            viewModel.searchText = viewModel.newSearchText
                            Task {
                                try await viewModel.searchFilterResults()
                                try await viewModel.searchFilterUserResults()
                                try await viewModel.fetchFollowAndFollowing()
                                try await viewModel.grabUserPostsAndFollowingUser()
                                try await viewModel.uploadSearch()
                            }
                        }
                }
                .padding(5)
                .background(.gray.opacity(0.2),in: RoundedRectangle(cornerRadius: 20))
            }
            .padding(.horizontal)
            .padding(.top)
            
            HStack(spacing:40){
                // filter switch
                ForEach(SearchFilter.allCases, id: \.rawValue) { item in
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
            .padding(.horizontal)
        }
    }
    
    var bodyView: some View {
        VStack{
            TabView(selection: $selectedFilter){
                searchResultAllView
                    .tag(SearchFilter.all)
                searchResultUserView
                    .tag(SearchFilter.users)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
    
    var searchResultAllView: some View {
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
    
    var searchResultUserView: some View {
        VStack {
            ScrollView(showsIndicators: false){
                VStack {
                    ForEach(viewModel.usersResult){ user in
                        HStack{
                            NavigationLink {
                                OtherUserProfileView(user: user)
                                    .navigationBarBackButtonHidden()
                            } label: {
                                KFImage(URL(string: user.profileImageUrl ?? ""))
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    
                                VStack(alignment:.leading,spacing: 0){
                                    Text(user.username)
                                        .font(.system(size: 15))
                                        .foregroundColor(colorScheme == .light ? .black : .white)

                                    HStack{
                                        Text("EC ID:")
                                        Text(user.id)
                                    }
                                    
                                    HStack{
                                        Text("Posts-\(user.posts ?? 0)")

                                        Divider()
                                            .frame(height:10)
                                        
                                        Text("Followers-\(user.followering ?? 0)")
                                    }
                                }
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button{
                                viewModel.userFollow.contains(where: {$0.id == user.id}) ? viewModel.unfollowUser(followUserId: user.id) : viewModel.followUser(followUserId: user.id)
                                viewModel.fetchUpdateGrabUserPostsAndFollowingUser()
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
                }
                .padding(.horizontal)
            }
        }
    }
}
