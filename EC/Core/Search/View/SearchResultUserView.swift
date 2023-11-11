//
//  SearchResultUserView.swift
//  EC
//
//  Created by Justin Zhang on 11/10/23.
//

import SwiftUI

struct SearchResultUserView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView(showsIndicators: false){
            VStack {
                ForEach(0..<10){ item in
                    HStack{
                        Button {
                            print("SearchResultUserView: other profile clicked")
                        } label: {
                            Image("shin")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                
                            VStack(alignment:.leading,spacing: 0){
                                Text("Username")
                                    .font(.system(size: 15))
                                    .foregroundColor(colorScheme == .light ? .black : .white)

                                HStack{
                                    Text("EC ID:")
                                    Text("1999286616")
                                }
                                
                                HStack{
                                    Text("Posts-18882")
                                    
                                    Divider()
                                        .frame(height:10)
                                    
                                    Text("Followers-8w")
                                }
                            }
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button{
                            print("SearchResultUserView: Follow button clicked")
                        }label: {
                            Text("Follow")
                                .foregroundColor(.red)
                                .padding(.vertical,5)
                                .padding(.horizontal,18)
                                .padding(1)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(uiColor: .red), lineWidth: 1)
                                )
                        }
                        .font(.system(size: 12))
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct SearchResultUserView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultUserView()
    }
}
