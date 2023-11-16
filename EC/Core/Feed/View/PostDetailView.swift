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
    @State var comment = ""
    @State var post: Post
    
    var body: some View {
        VStack {
            headerView
            
            bodyView
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
            if let user = post.user {
                CircularProfileImageView(user: user, size: .xsmall)
                
                Text(user.username)
                    .font(.system(size: 14))
            }
            
            Spacer()
            
            // follow Button
            Button{
                print("PostDetailView: Follow button clicked")
            }label: {
                Text("Follow")
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
                print("PostDetailView: Shared button clicked")
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
                    ForEach(post.imagesUrl, id: \.self){ image in
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
                        }
                    }
                }
                .tabViewStyle(.page)
                .frame(height: 500)
                
                // Title + action buttons
                HStack {
                    // title
                    VStack {
                        Text(post.title)
                    }
                    .font(.system(size: 25))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // action button
                    // likes
                    Button{
                        withAnimation(.spring()) {
                        }
                    }label: {
                        Image(systemName: "heart")
                            .frame(width: 30, height: 30, alignment: .center)
                            .cornerRadius(15)
                            .foregroundColor(colorScheme == .light ? .black : .white)
                    }
                    
                    // comment
                    Button{
                    }label: {
                        Image(systemName: "ellipsis.bubble")
                            .frame(width: 30, height: 30, alignment: .center)
                            .cornerRadius(15)
                            .foregroundColor(colorScheme == .light ? .black : .white)
                    }

                    // star
                    Button{
                    }label: {
                        Image(systemName: "star")
                            .frame(width: 30, height: 30, alignment: .center)
                            .cornerRadius(15)
                            .offset(y: -1)
                            .foregroundColor(colorScheme == .light ? .black : .white)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 5)
                            
                // Caption
                VStack{
                    let icon = Image(systemName: "text.bubble")
                    Text("\(icon): \(post.caption)")
                }
                .font(.system(size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                Divider()
                
                // Comments
                VStack {
                    Text("\(post.comments) comments")
                }
                .font(.system(size: 15))
                .fontWeight(.bold)
                .foregroundColor(Color(uiColor: .darkGray))
                .padding(.vertical, 9)
                
                HStack {
                    // Profile Image
                    if let user = post.user {
                        CircularProfileImageView(user: user, size: .xsmall)
                    }
                    
                    // Comments
                    TextField("Say Something", text: $comment)
                        .textInputAutocapitalization(.none)
                        .font(.subheadline)
                        .padding(10)
                        .background(Color(uiColor: .systemGray4))
                        .cornerRadius(20)
                }
                .padding(.horizontal)
                
                ForEach(0..<3) { _ in
                    CommentsCell()
                }
            }
        }
    }
}
