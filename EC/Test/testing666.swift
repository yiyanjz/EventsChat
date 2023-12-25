//
//  testing666.swift
//  EC
//
//  Created by Justin Zhang on 12/24/23.
//

import SwiftUI

struct testing666: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        HStack(spacing: 30) {
            // create
            Button {
                print("StoryView: Add new Story button clicked")
            } label: {
                VStack(spacing: 5) {
                    Image(systemName: "square.grid.3x1.folder.fill.badge.plus")
                        .font(.system(size:20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 1)
                                .frame(width: 30, height: 30)
                        )
                    
                    Text("Add")
                        .font(.system(size:15))
                }
            }
            
            // Send
            Button {
                print("StoryView: Browse Story button clicked")
            } label: {
                VStack(spacing: 5) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size:20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 1)
                                .frame(width: 30, height: 30)
                        )
                    
                    Text("Browse")
                        .font(.system(size:15))
                }
            }
            
            // Edit
            Button {
                print("StoryView: Edit Story button clicked")
            } label: {
                VStack(spacing: 5) {
                    Spacer()
                    
                    Image(systemName: "ellipsis")
                        .font(.system(size:27))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 1)
                                .frame(width: 30, height: 30)
                        )
                    
                    Spacer()
                    
                    Text("More")
                        .font(.system(size:15))
                    
                    Spacer()
                }
            }
            
            // Clear
            Button {
                dismiss()
            } label: {
                VStack(spacing: 5) {
                    Image(systemName: "person")
                        .font(.system(size:27))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 1)
                                .frame(width: 30, height: 30)
                        )
                    
                    Text("dismiss")
                        .font(.system(size:15))
                }
            }
        }
        .padding(.horizontal)
        .frame(width:UIScreen.main.bounds.width, height: 70, alignment: .trailing)
    }
}

#Preview {
    testing666()
}
