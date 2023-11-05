//
//  FeedView.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI

struct FeedView: View {
    @Environment(\.colorScheme) var colorScheme
    let screenHeight = UIScreen.main.bounds.height

    @State private var selectedFilter: FeedFilter = .follow

    var body: some View {
        NavigationStack {
            VStack {
                headerView
                
                bodyView
            }
            .background(
                Color(uiColor: colorScheme == .light ? .gray : .black)
                    .opacity(0.1)
            )
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}

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
                    print("FeedView: Search button pressed")
                }label: {
                    Image(systemName: "magnifyingglass")
                        .fontWeight(.semibold)
                        .foregroundColor(colorScheme == .light ? .black : .white)
                }
                
            }
            .padding(.horizontal)
            
            Divider()
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
            ScrollView {
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
                    }
                }
                .padding(.leading, 10)
                
                // posts
                LazyVStack {
                    ForEach(Post.MOCK_POST, id: \.self) { post in
                        FollowView(post: post)
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
                        ForEach(Array(Post.MOCK_POST.enumerated()), id: \.offset) { index,post in
                            if index & 2 == 0 {
                                PostView(post: post)
                            }
                        }
                    }
                    LazyVStack {
                        ForEach(Array(Post.MOCK_POST.enumerated()), id: \.offset) { index,post in
                            if index & 2 != 0 {
                                PostView(post: post)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 4)
    }
}
