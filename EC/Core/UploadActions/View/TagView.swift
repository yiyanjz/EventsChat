//
//  TagView.swift
//  EC
//
//  Created by Justin Zhang on 12/16/23.
//

import SwiftUI


struct TagView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var tagsInputText: String
    @State var tagText: String = ""
    
    var body: some View {
        VStack {
            headerView
            
            TextField("Enter Tags", text: $tagText, axis: .vertical)
                .frame(minHeight: 50, alignment: .topLeading)
                .padding()
                .onAppear {
                    tagText = tagsInputText
                }
            
            Divider()
            
            Button {
                self.tagText += "#"
            } label: {
                let icon = Image(systemName: "number")
                
                Text("\(icon) Add Tag")
                    .ButtonStyleWhite()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }

            Spacer()
        }
    }
}


struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        TagView(tagsInputText: .constant(""))
    }
}

extension TagView {
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
            Text("Edit Tags")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button {
                tagsInputText = tagText
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
