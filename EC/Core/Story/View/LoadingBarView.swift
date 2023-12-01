//
//  LoadingBarView.swift
//  EC
//
//  Created by Justin Zhang on 11/29/23.
//

import SwiftUI

struct LoadingBarView: View {
    var progress:CGFloat
    
    var body: some View {
        VStack {
            GeometryReader{ geometry in
                ZStack(alignment:.leading){
                    Rectangle()
                        .foregroundColor(Color.white.opacity(0.5))
                        .cornerRadius(5)
                    Rectangle().frame(width: geometry.size.width * self.progress,height: nil, alignment: .leading)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
            }
        }
    }
}

struct LoadingBarView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingBarView(progress: 0.1)
    }
}
