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
    
    var images = [Image]()
    
    var body: some View {
        VStack{
            LazyVGrid(columns: gridItem, spacing: 2) {
                ForEach(0..<9) { _ in
                    Button {
                    } label: {
                        Image("shin")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width / 3 - 5,height: UIScreen.main.bounds.width / 3 - 5)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                }
            }
            
            VStack{
                Image(systemName: "person")
            }
        }
    }
}
struct test2_Previews: PreviewProvider {
    static var previews: some View {
        test2()
    }
}

