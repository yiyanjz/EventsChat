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
        VStack(spacing:0) {
            // comments
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
            
            // replies
            if viewModel.showMoreReplies {
                replyView
                    .padding(.leading, 45)
            } else {
                if viewModel.replyCount > 0 {
                    moreCommentView
                }
            }
        }
    }
}

struct CommentsCell_Previews: PreviewProvider {
    static var previews: some View {
        let c = Comment(id: UUID().uuidString, caption: "sd", likes: 0, comments: 0, timestamp: Timestamp(), ownerId: "df", replies: [])
        CommentsCell(comment: c, replies: .constant(false), replyTo: .constant(""), replyComment: .constant(c))
    }
}

extension CommentsCell {
    var replyView: some View {
        VStack {
            ForEach(viewModel.comment.replies?.sorted(by: {$0.timestamp.dateValue() > $1.timestamp.dateValue()}) ?? []) { reply in
                HStack {
                    if let user = reply.user {
                        CircularProfileImageView(user: user, size: .xsmall)
                        
                        VStack(alignment:.leading,spacing: 2){
                            HStack{
                                Text(reply.user?.username ?? "")
                                
                                let date = reply.timestamp.dateValue()
                                Text("\(date.calenderTimeSinceNow())")
                                    .fontWeight(.regular)
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(uiColor: .label))
                                
                            }
                            .font(.system(size: 15))
                            .fontWeight(.bold)
                            
                            Text(reply.caption)
                            
                            HStack {
                                Text("\(reply.likes) likes")
                            }
                            .padding(.top, 5)
                            .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        reply.didLike ?? false ? viewModel.unlikeReply(reply: reply) : viewModel.likeReply(reply: reply)
                    } label: {
                        Image(systemName: reply.didLike ?? false ? "heart.fill" : "heart")
                            .frame(width: 30, height: 30, alignment: .center)
                            .cornerRadius(15)
                            .foregroundColor(reply.didLike ?? false ? .red : colorScheme == .light ? .black : .white)
                    }
                    
                }
                .font(.system(size: 12))
                .padding()
            }
        }
    }
    
    var moreCommentView: some View {
        // Divider ----- View (count) Comment -------
        HStack {
            Rectangle()
                .frame(width: (UIScreen.main.bounds.width / 2) - 100, height: 0.5)
            
            Button {
                viewModel.showMoreReplies.toggle()
            } label: {
                Text("View \(viewModel.replyCount) More")
                    .font(.footnote)
                    .fontWeight(.semibold)
            }
            
            Rectangle()
                .frame(width: (UIScreen.main.bounds.width / 2) - 100, height: 0.5)
        }
        .foregroundColor(.gray)
    }
}
