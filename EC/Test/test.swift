//
//  test.swift
//  EC
//
//  Created by Justin Zhang on 11/4/23.
//

import SwiftUI

struct test: View {
    @State var showDetails: Bool = false
    
    var body: some View {
        VStack {
            if showDetails {
                Text("Hello")
            }else {
                Button {
                    showDetails.toggle()
                } label: {
                    Text("show more")
                }
            }
        }
    }
}

struct test_Previews: PreviewProvider {
    static var previews: some View {
        test()
    }
}
