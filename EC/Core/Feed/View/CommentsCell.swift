//
//  CommentsCell.swift
//  EC
//
//  Created by Justin Zhang on 11/14/23.
//

import SwiftUI

struct CommentsCell: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
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
    }
}

struct CommentsCell_Previews: PreviewProvider {
    static var previews: some View {
        CommentsCell()
    }
}
