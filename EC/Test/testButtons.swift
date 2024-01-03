//
//  testButtons.swift
//  EC
//
//  Created by Justin Zhang on 1/2/24.
//

import SwiftUI

struct testButtons: View {
    var body: some View {
        HStack {
            // save to library button
            Button {
                
            } label: {
                Image(systemName: "square.and.arrow.down")
                    .frame(width: 50, height: 40)
                    .background(.gray.opacity(0.2),in: RoundedRectangle(cornerRadius: 20))
            }
            
            // add to story button
            Button {
                
            } label: {
                let icon = Image(systemName: "plus")
                
                Text("\(icon) Story")
                    .frame(width: 200, height: 40)
                    .font(.system(size: 15))
                    .background(.gray.opacity(0.2),in: RoundedRectangle(cornerRadius: 20))
            }
        }
    }
}

#Preview {
    testButtons()
}
