//
//  StoryView.swift
//  EC
//
//  Created by Justin Zhang on 11/29/23.
//

import SwiftUI
import Kingfisher

struct StoryView: View {
    var media: Story
    let user: User
    @ObservedObject var countTimer: CountTimer
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            // story view
            GeometryReader{geometry in
                ZStack(alignment: .top){
                    KFImage(URL(string: self.media.selectedMedia[Int(self.countTimer.progress)]))
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
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
                            }
                        Rectangle()
                            .foregroundColor(.clear)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.countTimer.advancePage(by: 1)
                            }
                    }
                }
            }
            .onAppear{
                self.countTimer.start()
            }
            
            // action buttons
            HStack(spacing: 30) {
                // create
                Button {
                    print("StoryView: Add new Story button clicked")
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: "square.grid.3x1.folder.fill.badge.plus")
                            .font(.system(size:20))
                        Text("Create")
                    }
                }
                
                // Send
                Button {
                    print("StoryView: Send Story button clicked")
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: "paperplane")
                            .font(.system(size:20))
                        Text("Send")
                    }
                }
                
                // Edit
                Button {
                    print("StoryView: Edit Story button clicked")
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: "pencil")
                            .font(.system(size:27))
                        Text("Edit")
                    }
                }
                
                // Clear
                Button {
                    dismiss()
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: "person")
                            .font(.system(size:27))
                        Text("dismiss")
                    }
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal)
            .frame(width:UIScreen.main.bounds.width, height: 70, alignment: .trailing)
        }
        .background(.black)
    }
}
