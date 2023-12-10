//
//  CommentsView.swift
//  EC
//
//  Created by Justin Zhang on 11/14/23.
//

import SwiftUI

struct CommentsView: View {
    @StateObject var viewModel: CommentsViewModel
    
    init(user: User, post: Post) {
        self._viewModel = StateObject(wrappedValue: CommentsViewModel(user: user, post: post))
    }
    
    var body: some View {
        ScrollView {
            // Comments
            VStack {
                Text("Comments")
            }
            .font(.system(size: 15))
            .fontWeight(.bold)
            .foregroundColor(Color(uiColor: .darkGray))
            .padding(.vertical, 9)
            
            Divider()
            
            ForEach(viewModel.allComments, id: \.self) { comment in
                CommentsCell(comment: comment)
            }
            
            // Divider ----- View All Comment -------
            HStack {
                Rectangle()
                    .frame(width: (UIScreen.main.bounds.width / 2) - 100, height: 0.5)
                
                Button {
                    print("CommentsView: View More Comment Button Clicked")
                } label: {
                    Text("View More Comment")
                        .font(.footnote)
                        .fontWeight(.semibold)
                }

                Rectangle()
                    .frame(width: (UIScreen.main.bounds.width / 2) - 100, height: 0.5)
            }
            .foregroundColor(.gray)
            
            
            HStack {
                // Profile Image
                CircularProfileImageView(user: viewModel.user, size: .xsmall)
                
                // Comments
                TextField("Say Something", text: $viewModel.comment)
                    .textInputAutocapitalization(.none)
                    .font(.subheadline)
                    .padding(10)
                    .background(Color(uiColor: .systemGray4))
                    .cornerRadius(20)
                    .onSubmit {
                        Task {
                            try await viewModel.UploadComments(withPostId:viewModel.post.id, caption:viewModel.comment)
                            viewModel.comment = ""
                        }
                    }
            }
            .padding(.horizontal)
        }
    }
}

struct CommentsView_Previews: PreviewProvider {
    static var previews: some View {
        CommentsView(user: User.MOCK_USERS[0], post: Post.MOCK_POST[0])
    }
}
