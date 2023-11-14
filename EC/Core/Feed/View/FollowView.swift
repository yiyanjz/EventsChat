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
    @State private var selectedFilter: FeedFilter = .follow
    @StateObject var viewModel: FollowViewModel
    
    init(post: Post) {
        self._viewModel = StateObject(wrappedValue: FollowViewModel(post: post))
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
                CircularProfileImageView(user: postUser, size: .xsmall)
                
                VStack(alignment: .leading) {
                    Text(postUser.username)
                        .fontWeight(.bold)
                        .font(.system(size: 15))
                    
                    let date = viewModel.post.timestamp.dateValue()
                    Text("\(date.calenderTimeSinceNow())")
                        .fontWeight(.regular)
                        .font(.system(size: 10))
                        .foregroundColor(Color(uiColor: .label))
                }
                .padding(.leading, 10)
                
                Spacer()
                
                Button{
                    print("FollowView: shared button clicked")
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
            }
            .tabViewStyle(.page)
            .frame(height: 400)
        }
    }
    
    var actionButtonView: some View {
        HStack {
            // likes
            Button{
                print("FollowView: like button clicked")
            }label: {
                Image(systemName: "heart")
                    .frame(width: 30, height: 30, alignment: .center)
                    .cornerRadius(15)
            }
            
            Button {
                print("FollowView: Liked List button clicked")
            } label: {
                Text("\(viewModel.post.likes) likes")
                    .fontWeight(.semibold)
                    .font(.system(size: 13))
            }
            
            Spacer()
            
            // comment
            Button{
                print("FollowView: comment button clicked")
            }label: {
                Image(systemName: "ellipsis.bubble")
                    .frame(width: 30, height: 30, alignment: .center)
                    .cornerRadius(15)
            }

            // star
            Button{
                print("FollowView: secret button clicked")
            }label: {
                Image(systemName: "star")
                    .frame(width: 30, height: 30, alignment: .center)
                    .cornerRadius(15)
            }
        }
        .foregroundColor(colorScheme == .light ? .black : .white)
    }
    
    var bottomView: some View {
        // caption
        VStack(spacing: 8){
            HStack{
                let icon = Image(systemName: "text.bubble")
                Text("\(icon): \(viewModel.post.caption)")
                    .font(.system(size: 15))
                    .lineLimit(1)

            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

