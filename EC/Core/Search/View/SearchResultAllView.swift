//
//  SearchResultAllView.swift
//  EC
//
//  Created by Justin Zhang on 11/10/23.
//

import SwiftUI

struct SearchResultAllView: View {
    @Binding var scrollsize : CGFloat

    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                HStack(alignment:.top) {
                    LazyVStack {
                        ForEach(Array(Post.MOCK_POST.enumerated()), id: \.offset) { index,post in
                            if index & 2 == 0 {
                                PostView(post: post)
                            }
                        }
                    }
                    LazyVStack {
                        ForEach(Array(Post.MOCK_POST.enumerated()), id: \.offset) { index,post in
                            if index & 2 != 0 {
                                PostView(post: post)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 4)
    }
}

struct SearchResultAllView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultAllView(scrollsize: .constant(CGFloat(1.0)))
    }
}
