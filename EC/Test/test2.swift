//
//  test2.swift
//  EC
//
//  Created by Justin Zhang on 11/4/23.
//

import SwiftUI

struct test2: View {
    // grid Item Structure
    private let gridItem: [GridItem] = [
        .init(.flexible(), spacing: 2),
        .init(.flexible(), spacing: 2),
        .init(.flexible(), spacing: 2)
    ]
    
    @State var draggingItem: Image?
    
    var body: some View {
        VStack{
            Image("shin")
                .opacity(0.0)
        }
    }
}
struct test2_Previews: PreviewProvider {
    static var previews: some View {
        test2()
    }
}

