//
//  PostView.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI
import Kingfisher

struct PostView: View {
    @Environment(\.colorScheme) var colorScheme
    var post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            KFImage(URL(string: post.imagesUrl.first ?? ""))
//            Image(post.imagesUrl.first ?? "")
                .resizable()
                .scaledToFit()
            
            // title
            VStack(alignment: .leading) {
                HStack {
                    Text(post.title)
                        .font(.title3).bold()
                        .foregroundColor(colorScheme == .light ? .black : .white)
                        .lineLimit(2)
                }
                
                // user + likes
                HStack {
                    if let postUser = post.user{
                        CircularProfileImageView(user: postUser, size: .xxxsmall)
                        
                        Text(postUser.username)
                            .font(.system(size: 12))
                            .foregroundColor(colorScheme == .light ? .black : .white)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Button {
                            print("PostView: Heart Button Clicked")
                        } label: {
                            Image(systemName:"heart")
                                .font(.system(size: 12))
                        }

                        Text("\(post.likes)")
                            .font(.system(size: 12))
                    }
                }
                .font(.footnote)
                .foregroundColor(colorScheme == .light ? .black : .white )
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
        }
        .background(
            colorScheme == .light ? Color(uiColor: .white).brightness(0.1) : Color(uiColor: .black).brightness(0.1)
        )
        .mask(
            RoundedRectangle(cornerRadius: 5)
        )
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(post: Post.MOCK_POST[1])
    }
}
