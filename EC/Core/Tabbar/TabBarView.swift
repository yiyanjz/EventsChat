//
//  TabBarView.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI

enum TabBarSelection {
    case feed
    case events
    case upload
    case message
    case profile
}

struct TabBarView: View {
    @State var selectedFilted: TabBarSelection = .feed
    @State var showTabBar: Bool = true
    @State var uploadButtonPressed: Bool = false
    @State var showCameraView: Bool = false
    let user: User
    
    init(user: User){
        self.user = user
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        VStack{
            TabView(selection: $selectedFilted) {
                FeedView(showTabBar: $showTabBar)
                    .tag(TabBarSelection.feed)
                
                Text("Events")
                    .tag(TabBarSelection.events)
                
                UploadView(mainTabBarSelected: $selectedFilted, showTabBar: $showTabBar)
                    .tag(TabBarSelection.upload)
                
                Text("Message")
                    .tag(TabBarSelection.message)
                
                ProfileView(user: user, withBackButton: false)
                    .tag(TabBarSelection.profile)
            }
            
            if showTabBar {
                TabBar
            }
        }
        .confirmationDialog("", isPresented: $uploadButtonPressed, titleVisibility: .hidden) {
            Button("Upload Story") {
                showCameraView.toggle()
            }

            Button("Upload Post") {
                selectedFilted = .upload
                showTabBar = false
            }
        }
        .fullScreenCover(isPresented: $showCameraView, content: {
            CameraHomeView()
        })
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView(user: User.MOCK_USERS[0])
    }
}


// TabBarView
extension TabBarView {
    var TabBar: some View {
        HStack {
            // Events + Feed
            HStack{
                Spacer()
                
                Button {
                    selectedFilted = .feed
                } label: {
                    Text("Feed")
                }
                
                Spacer()
                
                Button {
                    selectedFilted = .events
                } label: {
                    Text("Events")
                }
                
                Spacer()
            }
            
            // plus button
            Button {
                uploadButtonPressed.toggle()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.vertical,10)
                    .padding(.horizontal,18)
                    .background(.yellow,in: RoundedRectangle(cornerRadius: 8))
            }
            
            // Message + Profile
            HStack {
                Spacer()
                
                Button {
                    selectedFilted = .message
                } label: {
                    Text("Message")
                }
                
                Spacer()
                
                Button {
                    selectedFilted = .profile
                } label: {
                    Text("Profile")
                }
                
                Spacer()
            }
        }
        .frame(width: UIScreen.main.bounds.width, height:30)
    }
}
