//
//  CommentsView.swift
//  EC
//
//  Created by Justin Zhang on 11/14/23.
//

import SwiftUI

struct CommentsView: View {
    @Environment(\.colorScheme) var colorScheme
    let user: User
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Comments")
            }
            .padding(.top, 20)
            
            Divider()
            
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .foregroundColor(Color(.systemGray4))
                
                VStack(alignment:.leading,spacing: 2){
                    HStack{
                        Text("username")
                        Text("2h")
                    }
                    .font(.system(size: 15))
                    .fontWeight(.bold)
                    
                    Text("SDFSDFSDFSDFSDF")

                    HStack {
                        Text("33 likes")
                        Text("Reply")
                    }
                    .padding(.top, 5)
                    .foregroundColor(.gray)
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
