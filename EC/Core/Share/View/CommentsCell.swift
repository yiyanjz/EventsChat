//
//  CommentsCell.swift
//  EC
//
//  Created by Justin Zhang on 11/14/23.
//

import SwiftUI
import Firebase

struct CommentsCell: View {
    @State var comment: Comment
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            if let user = comment.user {
                CircularProfileImageView(user: user, size: .xsmall)
                
                VStack(alignment:.leading,spacing: 2){
                    HStack{
                        Text(comment.user?.username ?? "")
                        
                        let date = comment.timestamp.dateValue()
                        Text("\(date.calenderTimeSinceNow())")
                        
                    }
                    .font(.system(size: 15))
                    .fontWeight(.bold)
                    
                    Text(comment.caption)
                    
                    HStack {
                        Text("\(comment.likes) likes")
                        Text("Reply")
                    }
                    .padding(.top, 5)
                    .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button {
                print("CommentsView: Heart Button Clicked")
            } label: {
                Image(systemName: "heart")
                    .frame(width: 30, height: 30, alignment: .center)
                    .cornerRadius(15)
                    .foregroundColor(colorScheme == .light ? .black : .white)
            }
            
        }
        .font(.system(size: 12))
        .padding()
    }
}

struct CommentsCell_Previews: PreviewProvider {
    static var previews: some View {
        let c = Comment(id: UUID().uuidString, caption: "sd", likes: 0, comments: 0, timestamp: Timestamp(), ownerId: "df", replies: [])
        CommentsCell(comment: c)
    }
}
