//
//  StoryView.swift
//  EC
//
//  Created by Justin Zhang on 11/29/23.
//

import SwiftUI
import Kingfisher
import Firebase

struct StoryView: View {
    var media: Story
    let user: User
    @ObservedObject var countTimer: CountTimer
    @Environment(\.dismiss) var dismiss
    @State var browseButtonClicked: Bool = false
    
    var body: some View {
        VStack {
            // story view
            GeometryReader{geometry in
                ZStack(alignment: .top){
                    KFImage(URL(string: self.media.selectedMedia[Int(self.countTimer.progress)]))
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width,height: nil,alignment: .center)
                    
                    // Loading Bar
                    VStack {
                        HStack(alignment: .center, spacing: 4){
                            ForEach(self.media.selectedMedia.indices, id: \.self){ image in
                                LoadingBarView(progress: min( max( (CGFloat(self.countTimer.progress) - CGFloat(image)), 0.0) , 1.0) )
                                    .frame(width:nil,height: 2, alignment:.leading)
                            }
                            
                        }
                        .padding()
                        
                        // user profile
                        HStack {
                            CircularProfileImageView(user: user, size: .xxsmall)
                            
                            Text(user.username)
                            
                            let date = media.timestamp.dateValue()
                            Text("\(date.calenderTimeSinceNow())")
                                .opacity(0.4)
                        }
                        .font(.callout)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    }
                    
                    // next and prev click
                    HStack(alignment:.center,spacing:0){
                        Rectangle()
                            .foregroundColor(.clear)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.countTimer.advancePage(by: -1)
                                if browseButtonClicked {
                                    browseButtonClicked.toggle()
                                }
                            }
                        Rectangle()
                            .foregroundColor(.clear)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.countTimer.advancePage(by: 1)
                                if browseButtonClicked {
                                    browseButtonClicked.toggle()
                                }
                            }
                    }
                }
            }
            .onAppear{
                self.countTimer.start()
            }
            
            ZStack {
                actionButton
                    .opacity(browseButtonClicked ? 0 : 1)
                
                browseView
                    .opacity(browseButtonClicked ? 1 : 0)
            }
        }
        .background(.black)
    }
}

extension StoryView {
    var actionButton: some View {
        // action buttons
        HStack(spacing: 30) {
            // create
            Button {
                print("StoryView: Add new Story button clicked")
            } label: {
                VStack(spacing: 5) {
                    Image(systemName: "square.grid.3x1.folder.fill.badge.plus")
                        .font(.system(size:20))
                        .frame(width: 30, height: 30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 1)
                                .frame(width: 30, height: 30)
                        )
                    
                    Text("Add")
                        .font(.system(size:15))
                }
            }
            
            // Send
            Button {
                browseButtonClicked.toggle()
            } label: {
                VStack(spacing: 5) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size:20))
                        .frame(width: 30, height: 30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 1)
                                .frame(width: 30, height: 30)
                        )
                    
                    Text("Browse")
                        .font(.system(size:15))
                }
            }
            
            // Edit
            Button {
                print("StoryView: Edit Story button clicked")
            } label: {
                VStack(spacing: 5) {
                    Image(systemName: "ellipsis")
                        .font(.system(size:27))
                        .frame(width: 30, height: 30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 1)
                                .frame(width: 30, height: 30)
                        )
                    
                    Text("More")
                        .font(.system(size:15))
                }
            }
            
            // Clear
            Button {
                dismiss()
            } label: {
                VStack(spacing: 5) {
                    Image(systemName: "person")
                        .font(.system(size:27))
                        .frame(width: 30, height: 30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 1)
                                .frame(width: 30, height: 30)
                        )
                    
                    Text("Dismiss")
                        .font(.system(size:15))
                }
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal)
        .frame(width:UIScreen.main.bounds.width, height: 70, alignment: .trailing)
    }
    
    var browseView: some View {
        HStack {
            ForEach(media.selectedMedia, id: \.self) { image in
                KFImage(URL(string: image))
                    .resizable()
                    .frame(width: 40, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal)
        .frame(width:UIScreen.main.bounds.width, height: 70, alignment: .trailing)
    }
}

struct StoryView_Previews: PreviewProvider {
    static var previews: some View {
        let countTime = CountTimer(items: 1, interval: 4.0)
        StoryView(media: Story.MOCK_STORY[0], user: User.MOCK_USERS[0], countTimer: countTime)
    }
}
