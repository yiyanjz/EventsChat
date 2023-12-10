//
//  CommentsCell.swift
//  EC
//
//  Created by Justin Zhang on 11/14/23.
//

import SwiftUI
import Firebase

struct CommentsCell: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: CommentCellViewModel
    @Binding var replies: Bool
    @Binding var replyTo: String
    @Binding var replyComment: Comment?
    
    init(comment: Comment, replies: Binding<Bool>, replyTo: Binding<String>, replyComment: Binding<Comment?>) {
        self._replies = replies
        self._replyTo = replyTo
        self._replyComment = replyComment
        self._viewModel = StateObject(wrappedValue: CommentCellViewModel(comment: comment))
    }

    var body: some View {
        HStack {
            if let user = viewModel.comment.user {
                CircularProfileImageView(user: user, size: .xsmall)
                
                VStack(alignment:.leading,spacing: 2){
                    HStack{
                        Text(viewModel.comment.user?.username ?? "")
                        
                        let date = viewModel.comment.timestamp.dateValue()
                        Text("\(date.calenderTimeSinceNow())")
                            .fontWeight(.regular)
                            .font(.system(size: 10))
                            .foregroundColor(Color(uiColor: .label))
                        
                    }
                    .font(.system(size: 15))
                    .fontWeight(.bold)
                    
                    Text(viewModel.comment.caption)
                    
                    HStack {
                        Text("\(viewModel.comment.likes) likes")
                        
                        Button {
                            replies.toggle()
                            replyTo = "@ \(viewModel.comment.user?.username ?? "")"
                            replyComment = viewModel.comment
                        } label: {
                            Text("Reply")
                        }

                    }
                    .padding(.top, 5)
                    .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button {
                viewModel.comment.didLike ?? false ? viewModel.unlikeComment(comment: viewModel.comment) : viewModel.likeComment(comment: viewModel.comment)
            } label: {
                Image(systemName: viewModel.comment.didLike ?? false ? "heart.fill" : "heart")
                    .frame(width: 30, height: 30, alignment: .center)
                    .cornerRadius(15)
                    .foregroundColor(viewModel.comment.didLike ?? false ? .red : colorScheme == .light ? .black : .white)
            }
            
        }
        .font(.system(size: 12))
        .padding()
    }
}

struct CommentsCell_Previews: PreviewProvider {
    static var previews: some View {
        let c = Comment(id: UUID().uuidString, caption: "sd", likes: 0, comments: 0, timestamp: Timestamp(), ownerId: "df")
        CommentsCell(comment: c, replies: .constant(false), replyTo: .constant(""), replyComment: .constant(c))
    }
}
