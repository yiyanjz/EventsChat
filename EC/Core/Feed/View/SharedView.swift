 //
//  SharedView.swift
//  EC
//
//  Created by Justin Zhang on 11/14/23.
//

import SwiftUI

struct SharedView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var searchUser: String = ""

    var body: some View {
        ScrollView {
            VStack {
                HStack{
                    Image(systemName: "magnifyingglass")
                    TextField("Search...", text: $searchUser)
                }
                .padding(5)
                .background(.gray.opacity(0.2),in: RoundedRectangle(cornerRadius: 20))
                
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .foregroundColor(Color(.systemGray4))
                    
                    VStack(alignment:.leading){
                        Text("Full Name")
                            .fontWeight(.bold)
                        Text("username")
                    }
                    .font(.system(size: 15))
                    
                    Spacer()
                    
                    Button {
                        print("SharedView: Circle Button Clicked")
                    } label: {
                        Image(systemName: "circle")
                            .resizable()
                            .frame(width: 30, height: 30, alignment: .center)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top)
            }
            .padding()
        }
    }
}

struct SharedView_Previews: PreviewProvider {
    static var previews: some View {
        SharedView(searchUser: "")
    }
}
