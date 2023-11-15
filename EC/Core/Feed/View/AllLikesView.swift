//
//  AllLikesView.swift
//  EC
//
//  Created by Justin Zhang on 11/13/23.
//

import SwiftUI
import Kingfisher

struct AllLikesView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: AllLikesViewModel
    
    init(likedList: [String]) {
        self._viewModel = StateObject(wrappedValue: AllLikesViewModel(likedList: likedList))
    }
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false){
                VStack {
                    ForEach(viewModel.likedListUsers ?? []){ user in
                        HStack{
                            Button {
                                print("SearchResultUserView: other profile clicked")
                            } label: {
                                KFImage(URL(string: user.profileImageUrl ?? ""))
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    
                                VStack(alignment:.leading,spacing: 2){
                                    Text(user.username)
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
                .padding(.vertical)
            }
        }
    }
}

struct AllLikesView_Previews: PreviewProvider {
    static var previews: some View {
        AllLikesView(likedList: ["ddd"])
    }
}
