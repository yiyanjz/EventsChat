//
//  CommentsView.swift
//  EC
//
//  Created by Justin Zhang on 11/14/23.
//

import SwiftUI

struct CommentsView: View {
    let user: User
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Comments")
            }
            .padding(.top, 20)
            
            Divider()
            
            CommentsCell()
            
            CommentsCell()
            
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
        }
    }
}

struct CommentsView_Previews: PreviewProvider {
    static var previews: some View {
        CommentsView(user: User.MOCK_USERS[0])
    }
}
