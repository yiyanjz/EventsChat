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
        ScrollView {
            Text("All Media")
        }
    }
}

struct SearchResultAllView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultAllView(scrollsize: .constant(CGFloat(1.0)))
    }
}
