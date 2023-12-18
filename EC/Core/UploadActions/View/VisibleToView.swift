//
//  VisibleToView.swift
//  EC
//
//  Created by Justin Zhang on 12/17/23.
//

import SwiftUI

struct VisibleToView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var shareWith: [User]
    @Binding var hideFrom: [User]
    @Binding var selectedVisibleTo: String
    @State var showShareWithView: Bool = false
    @State var dontShareWithView: Bool = false
    
    var body: some View {
        VStack {
            headerView
            
            HStack {
                VStack {
                    Text("All")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title2)
                    
                    Text("All Contact")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.footnote)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedVisibleTo = "All"
                    selectedVisibleTo = "All"
                    hideFrom = []
                    shareWith = []
                }
                
                if selectedVisibleTo == "All" {
                    Image(systemName: "checkmark")
                }
                
            }
            .padding()
            
            HStack {
                VStack {
                    Text("Private")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title2)

                    Text("Just Me")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.footnote)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedVisibleTo = "Private"
                    hideFrom = []
                    shareWith = []
                }
                
                if selectedVisibleTo == "Private" {
                    Image(systemName: "checkmark")
                }
                
            }
            .padding()
            
            HStack {
                HStack {
                    Text("Share With")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title2)
                    
                    Spacer()
                    
                    ForEach(shareWith) { user in
                        Text(user.username)
                            .font(.footnote)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedVisibleTo = "ShareWith"
                    showShareWithView.toggle()
                    hideFrom = []
                    
                }
                
                if selectedVisibleTo == "ShareWith" {
                    Image(systemName: "checkmark")
                }

            }
            .padding()
            
            
            HStack {
                HStack {
                    Text("Don't Share")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title2)
                    
                    Spacer()
                    
                    ForEach(hideFrom) { user in
                        Text(user.username)
                            .font(.footnote)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedVisibleTo = "DontShare"
                    dontShareWithView.toggle()
                    shareWith = []
                }
                
                if selectedVisibleTo == "DontShare" {
                    Image(systemName: "checkmark")
                }

            }
            .padding()

            Spacer()
        }
        .fullScreenCover(isPresented: $showShareWithView, content: {
            MentionView(selectedMentionUser: $shareWith)
        })
        .fullScreenCover(isPresented: $dontShareWithView, content: {
            MentionView(selectedMentionUser: $hideFrom)
        })
    }
}

#Preview {
    VisibleToView(shareWith: .constant([User.MOCK_USERS[0]]), hideFrom: .constant([User.MOCK_USERS[0]]), selectedVisibleTo: .constant(""))
}

extension VisibleToView {
    // headerView
    var headerView: some View {
        // ToolBar
        HStack {
            // cancel button
            Button("Cancel") {
                dismiss()
            }
            .font(.subheadline)
            .fontWeight(.bold)
            
            Spacer()
            
            // title
            Text("Visible To")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
        }
        .padding(.horizontal)
    }
}
