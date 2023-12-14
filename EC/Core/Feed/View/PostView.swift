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
    @StateObject var viewModel: PostViewModel
    
    func checkUserLikedPost() -> Bool {
        if let userLiked = viewModel.post.userLiked, let currentUser = viewModel.currentUser, userLiked.contains("\(currentUser.id)") {
            return true
        } else {
            return false
        }
    }
    
    func checkUserStarPost() -> Bool {
        if let userStared = viewModel.post.userStared, let currentUser = viewModel.currentUser, userStared.contains("\(currentUser.id)") {
            return true
        } else {
            return false
        }
    }
    
    init(post: Post) {
        self._viewModel = StateObject(wrappedValue: PostViewModel(post: post))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            KFImage(URL(string: viewModel.post.imagesUrl.first ?? ""))
//            Image(viewModel.post.imagesUrl.first ?? "")
                .resizable()
                .scaledToFit()
            
            // title
            VStack(alignment: .leading) {
                HStack {
                    Text(viewModel.post.title)
                        .font(.title3).bold()
                        .foregroundColor(colorScheme == .light ? .black : .white)
                        .lineLimit(2)
                }
                
                // user + likes
                HStack {
                    if let postUser = viewModel.post.user{
                        CircularProfileImageView(user: postUser, size: .xxxsmall)
                        
                        Text(postUser.username)
                            .font(.system(size: 12))
                            .foregroundColor(colorScheme == .light ? .black : .white)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        // likes
                        Button{
                            withAnimation(.spring()) {
                                checkUserLikedPost() ? viewModel.unlikePost() : viewModel.likePost()
                            }
                        }label: {
                            Image(systemName: checkUserLikedPost() ? "heart.fill" : "heart")
                                .frame(width: 30, height: 30, alignment: .center)
                                .cornerRadius(15)
                                .foregroundColor(checkUserLikedPost() ? .red : colorScheme == .light ? .black : .white)
                        }

                        Text("\(viewModel.post.likes)")
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
