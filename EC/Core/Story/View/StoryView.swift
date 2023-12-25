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
    @ObservedObject var countTimer: CountTimer
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: StoryViewModel
    
    init(media: Story, user: User, countTimer: CountTimer) {
        self.countTimer = countTimer
        self._viewModel = StateObject(wrappedValue: StoryViewModel(media: media, user: user))
    }
    
    var body: some View {
        VStack {
            // story view
            GeometryReader{geometry in
                ZStack(alignment: .top){
                    KFImage(URL(string: viewModel.media.selectedMedia[Int(self.countTimer.progress)]))
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width,height: nil,alignment: .center)
                    
                    // Loading Bar
                    VStack {
                        HStack(alignment: .center, spacing: 4){
                            ForEach(viewModel.media.selectedMedia.indices, id: \.self){ image in
                                LoadingBarView(progress: min( max( (CGFloat(self.countTimer.progress) - CGFloat(image)), 0.0) , 1.0) )
                                    .frame(width:nil,height: 2, alignment:.leading)
                            }
                            
                        }
                        .padding()
                        
                        // user profile
                        HStack {
                            CircularProfileImageView(user: viewModel.user, size: .xxsmall)
                            
                            Text(viewModel.user.username)
                            
                            let date = viewModel.media.timestamp.dateValue()
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
                                if viewModel.browseButtonClicked {
                                    viewModel.browseButtonClicked.toggle()
                                } else {
                                    self.countTimer.advancePage(by: -1)
                                }
                            }
                        Rectangle()
                            .foregroundColor(.clear)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if viewModel.browseButtonClicked {
                                    viewModel.browseButtonClicked.toggle()
                                } else {
                                    self.countTimer.advancePage(by: 1)
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
                    .opacity(viewModel.browseButtonClicked ? 0 : 1)
                
                browseView
                    .opacity(viewModel.browseButtonClicked ? 1 : 0)
            }
        }
        .background(.black)
        .confirmationDialog("", isPresented: $viewModel.showMoreActionSheet, titleVisibility: .hidden) {
            Button("Remove Highlight") {
                viewModel.deleteProfileStory(withStory: viewModel.media, deleteStoryIndex: Int(self.countTimer.progress))
            }

            Button("Edit Highlight") {
            }
            
            Button("Dimiss") {
                dismiss()
            }
        }
        .onChange(of: viewModel.showMoreActionSheet, perform: { value in
            if viewModel.showMoreActionSheet == false {
                countTimer.start()
            }
        })

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
                viewModel.browseButtonClicked.toggle()
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
            
            // Send
            Button {
                print("StoryView: Send button clicked")
            } label: {
                VStack(spacing: 5) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size:23))
                        .frame(width: 30, height: 30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 1)
                                .frame(width: 30, height: 30)
                        )
                    
                    Text("Send")
                        .font(.system(size:15))
                }
            }
            
            // Edit
            Button {
                viewModel.showMoreActionSheet.toggle()
                countTimer.cancel()
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
        }
        .foregroundColor(.white)
        .padding(.horizontal)
        .frame(width:UIScreen.main.bounds.width, height: 70, alignment: .trailing)
    }
    
    var browseView: some View {
        HStack {
            ForEach(Array(viewModel.media.selectedMedia.enumerated()), id: \.element) { index, item in
                KFImage(URL(string: item))
                    .resizable()
                    .frame(width: 40, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onTapGesture {
                        self.countTimer.progress = CGFloat(index)
                    }
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
