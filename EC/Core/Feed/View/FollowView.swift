//
//  FollowView.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI

struct FollowView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedFilter: FeedFilter = .follow
    var post: Post

    var body: some View {
        VStack(spacing: 10) {
            // User + timestamp + ...(button
            HStack {
                if let postUser = post.user{
                    CircularProfileImageView(user: postUser, size: .xxsmall)
                    
                    Text(postUser.username)
                        .font(.subheadline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Button{
                        print("FollowView: 3 dot button clicked")
                    }label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
            .foregroundColor(colorScheme == .light ? .black : .white)
            .padding(.horizontal, 10)

            // image
            VStack {
                TabView {
                    ForEach(post.imagesUrl, id: \.self){ image in
                        Image(image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
                .tabViewStyle(.page)
                .frame(height: 400)
            }
            
            // action buttons
            HStack {
                // share
                Button{
                    print("FollowView: shared button clicked")
                }label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20))
                }
                
                Spacer()
                
                // likes
                Button{
                    print("FollowView: like button clicked")
                }label: {
                    HStack(spacing:0){
                        Image(systemName: "heart")
                            .font(.system(size: 20))
                        Text("\(post.likes)")
                    }
                }
                
                // star
                Button{
                    print("FollowView: secret button clicked")
                }label: {
                    HStack(spacing:0){
                    Image(systemName: "star")
                        .font(.system(size: 20))
                        Text("\(post.stars)")
                    }
                }
                
                // comment
                Button{
                    print("FollowView: comment button clicked")
                }label: {
                    HStack(spacing:0){
                    Image(systemName: "ellipsis.bubble")
                        .font(.system(size: 20))
                        Text("\(post.comments)")
                    }
                }
            }
            .foregroundColor(colorScheme == .light ? .black : .white)
            .padding(.horizontal, 10)

            // caption
            VStack(spacing: 8){
                HStack{
                    let icon = Image(systemName: "text.bubble")
                    Text("\(icon): \(post.caption)")
                        .font(.system(size: 15))
                        .lineLimit(1)

                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack{
                    Text("yesterday")
                        .font(.footnote)
                        .fontWeight(.light)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

            }
            .padding(.horizontal, 10)
        }
        .padding(.vertical)
    }
}

struct FollowView_Previews: PreviewProvider {
    static var previews: some View {
        FollowView(post: Post.MOCK_POST[1])
    }
}
