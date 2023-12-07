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
        VStack {
            VStack {
                // search bar
                HStack{
                    Image(systemName: "magnifyingglass")
                    
                    TextField("Search...", text: $searchUser)
                    
                    Button {
                        print("StoryView: New Group Chat")
                    } label: {
                        Image(systemName: "person.3")
                            .foregroundColor(colorScheme == .light ? .black : .white)

                    }

                }
                .padding(10)
                .background(.gray.opacity(0.2),in: RoundedRectangle(cornerRadius: 20))
                
                // users
                ScrollView(showsIndicators: false) {
                    ForEach(0..<20) { _ in
                        // users
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
                }
                Divider()
            }
            .padding()
            .padding(.horizontal, 8)
            
            
            // action buttons
            HStack(spacing: 30) {
                // Add to Story
                Button {
                    print("StoryView: Add new Story button clicked")
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: "memories.badge.plus")
                            .font(.system(size:25))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 1)
                                    .frame(width: 50, height: 50)
                            )
                        
                        Spacer()
                        
                        Text("Add story")
                            .font(.system(size:15))
                    }
                }
                
                // Copy Link
                Button {
                    print("StoryView: Copy Link button clicked")
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: "link.badge.plus")
                            .font(.system(size:25))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 1)
                                    .frame(width: 50, height: 50)
                            )
                        
                        Spacer()
                        
                        Text("Copy Link")
                            .font(.system(size:15))
                    }
                }
                
                // Share
                Button {
                    print("StoryView: Share button clicked")
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: "square.and.arrow.up.circle")
                            .font(.system(size:30))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 1)
                                    .frame(width: 50, height: 50)
                            )
                        
                        Spacer()
                        
                        Text("Share To")
                            .font(.system(size:15))
                    }
                }
            }
            .padding(.top)
            .foregroundColor(colorScheme == .light ? .black : .white)
            .frame(width:UIScreen.main.bounds.width, height: 50, alignment: .center)
        }
    }
}

struct SharedView_Previews: PreviewProvider {
    static var previews: some View {
        SharedView(searchUser: "")
    }
}
