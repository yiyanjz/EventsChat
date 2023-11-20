//
//  SearchResultAllView.swift
//  EC
//
//  Created by Justin Zhang on 11/10/23.
//

import SwiftUI

struct SearchResultAllView: View {
    @Binding var scrollsize : CGFloat
    @StateObject var viewModel: SearchResultViewModel
    
    init(scrollsize: Binding<CGFloat>, searchText: String){
        self._scrollsize = scrollsize
        self._viewModel = StateObject(wrappedValue: SearchResultViewModel(searchText: searchText))
    }

    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                HStack(alignment:.top) {
                    LazyVStack {
                        ForEach(Array(viewModel.postsResult.enumerated()), id: \.offset) { index,post in
                            if index & 2 == 0 {
                                PostView(post: post)
                            }
                        }
                    }
                    LazyVStack {
                        ForEach(Array(viewModel.postsResult.enumerated()), id: \.offset) { index,post in
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
        SearchResultAllView(scrollsize: .constant(CGFloat(1.0)), searchText: "s")
    }
}
