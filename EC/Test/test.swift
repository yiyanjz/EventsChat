//
//  test.swift
//  EC
//
//  Created by Justin Zhang on 11/4/23.
//

import SwiftUI

struct test: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                HStack(alignment:.top) {
                    LazyVStack {
                        ForEach(Array(Post.MOCK_POST.sorted(by: {$0.timestamp.dateValue() > $1.timestamp.dateValue()}).enumerated()), id: \.offset) { index,post in
                            if index & 2 == 0 {
                                PostView(post: post)
                            }
                        }
                    }
                    LazyVStack {
                        ForEach(Array(Post.MOCK_POST.sorted(by: {$0.timestamp.dateValue() > $1.timestamp.dateValue()}).enumerated()), id: \.offset) { index,post in
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

struct test_Previews: PreviewProvider {
    static var previews: some View {
        test()
    }
}
