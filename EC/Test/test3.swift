//
//  test3.swift
//  EC
//
//  Created by Justin Zhang on 11/19/23.
//

import SwiftUI

struct test4: View {
    @State var caption = ""
    @State var tags = [String]()
    
    var body: some View {
        VStack {
            // text field
            TextField("Add Text", text: $caption, axis: .vertical)
                .textInputAutocapitalization(.none)
                .font(.subheadline)
                .frame(minHeight: 70, alignment:.topLeading)
                .onSubmit {
                    tags.append("sdfdsf")
                }
        
            ForEach(tags, id: \.self) { tag in
                Text(tag)
            }
        }
        .padding()
        .background(.red)
        .foregroundColor(.white)

    }
}

struct test4_Previews: PreviewProvider {
    static var previews: some View {
        test4()
    }
}
