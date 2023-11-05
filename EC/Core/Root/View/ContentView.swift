//
//  ContentView.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()

    var body: some View {
        Group {
            if viewModel.userSession == nil {
                LoginView()
            } else if let currentUser = viewModel.currentUser {
                TabBarView(user: currentUser)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
