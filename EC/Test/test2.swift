//
//  test2.swift
//  EC
//
//  Created by Justin Zhang on 11/4/23.
//

import SwiftUI

struct test2: View {
    @State var caption = ""
    @State var captionTitle = ""
    
    // grid Item Structure
    private let gridItem: [GridItem] = [
        .init(.flexible(), spacing: 2),
        .init(.flexible(), spacing: 2),
        .init(.flexible(), spacing: 2)
    ]
    
    @State var draggingItem: Image?
    
    var body: some View {
        NavigationStack {
            VStack {
                // header
                HStack {
                    Button {
                    } label: {
                        Text("Cancel")
                            .font(.footnote)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Spacer()
                    
                    Button {
                    } label: {
                        Text("Post")
                            .font(.footnote)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                            
                    ScrollView(showsIndicators: false) {
                        HStack {
                            LazyVGrid(columns: gridItem, spacing: 2) {
                                ForEach(0..<9) { int in
                                    GeometryReader {
                                        let size = $0.size
                                            
                                        Image("shin")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 120, height: 120)
                                            .clipShape(RoundedRectangle(cornerRadius: 5))
                                            .overlay(
                                                Text("2:09")
                                                    .font(.footnote)
                                                    .foregroundColor(.white)
                                                    .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .bottomTrailing)
                                                    .padding(8)
                                            )
                                            .draggable("SDFSDF") {
                                                Image("shin")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: size.width, height: size.height)
                                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                                    .overlay(
                                                        Text("2:09")
                                                            .font(.footnote)
                                                            .foregroundColor(.white)
                                                            .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .bottomTrailing)
                                                            .padding(8)
                                                    )
                                            }
                                            .dropDestination(for: String.self) { items, location in
                                                return false
                                            } isTargeted: { status in
                                                print("found")
                                            }
                                    }
                                    .frame(height: 120)
                                }
                            }
                        }
                        
                        Divider()
                            .padding(4)
                        
                        VStack {
                            
                            VStack {
                                // text field
                                TextField("Add Title", text: $captionTitle, axis: .vertical)
                                    .textInputAutocapitalization(.none)
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                    .lineLimit(1)
                            }
                            
                            Divider()
                                .padding(4)

                            VStack {
                                // text field
                                TextField("Add Text", text: $caption, axis: .vertical)
                                    .textInputAutocapitalization(.none)
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                            }
                            
                            Divider()
                                .padding(4)

                            HStack {
                                let icon = Image(systemName: "location")
                                Text("\(icon) Location")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Image(systemName: "chevron.right")
                                    .font(.footnote)
                                    .foregroundColor(.black)
                            }
                            
                            Divider()
                                .padding(4)

                            HStack{
                                let icon = Image(systemName: "at")
                                Text("\(icon) Mention")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Image(systemName: "chevron.right")
                                    .font(.footnote)
                                    .foregroundColor(.black)
                            }
                            
                            Divider()
                                .padding(4)

                            HStack{
                                let icon = Image(systemName: "person.fill.badge.plus")
                                Text("\(icon) Visible To")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("All")
                                    .font(.footnote)
                                    .foregroundColor(.black)
                                
                                Image(systemName: "chevron.right")
                                    .font(.footnote)
                                    .foregroundColor(.black)
                            }
                            
                            Divider()
                                .padding(4)
                            
                        }
                    }
                    .padding()
                
                Spacer()
            }
        }
    }
}

struct test2_Previews: PreviewProvider {
    static var previews: some View {
        test2()
    }
}
