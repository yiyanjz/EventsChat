//
//  AllLikesView.swift
//  EC
//
//  Created by Justin Zhang on 11/13/23.
//

import SwiftUI

struct AllLikesView: View {
    @State var likedList: [String]
    
    var body: some View {
        ForEach(likedList, id: \.self) { user in
            Text(user)
        }
    }
}

struct AllLikesView_Previews: PreviewProvider {
    static var previews: some View {
        AllLikesView(likedList: ["sdf"])
    }
}
