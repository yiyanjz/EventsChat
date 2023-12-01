//
//  test3.swift
//  EC
//
//  Created by Justin Zhang on 11/19/23.
//

import SwiftUI

struct test4: View {
    var images:[String] = ["shin","jian","background"]
    @ObservedObject var countTimer: CountTimer = CountTimer(items: 3,interval: 4.0)
    
    var body: some View {
        VStack {
            GeometryReader{geometry in
                ZStack(alignment: .top){
                    Image(self.images[Int(self.countTimer.progress)])
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .scaledToFill()
                        .frame(width: geometry.size.width,height: nil,alignment: .center)
                    
                    // Loading Bar
                    VStack {
                        HStack(alignment: .center, spacing: 4){
                            ForEach(self.images.indices, id: \.self){ image in
                                LoadingBarView(progress: min( max( (CGFloat(self.countTimer.progress) - CGFloat(image)), 0.0) , 1.0) )
                                    .frame(width:nil,height: 2, alignment:.leading)
                            }
                        }
                        .padding()
                        
                        // user profile
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .foregroundColor(Color(.systemGray4))
                            
                            Text("UserName")
                            
                            Text("Time")
                                .opacity(0.4)
                        }
                        .font(.callout)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.white)
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
            
            HStack(spacing: 30) {
                // create
                Button {
                    print("StoryView: Add new Story button clicked")
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: "square.grid.3x1.folder.fill.badge.plus")
                            .font(.system(size:25))
                        Text("Create")
                    }
                }
                
                // Send
                Button {
                    print("StoryView: Send Story button clicked")
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: "paperplane")
                            .font(.system(size:25))
                        Text("Send")
                    }
                }
                
                // Edit
                Button {
                    print("StoryView: Edit Story button clicked")
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: "pencil")
                            .font(.system(size:32))
                        Text("Edit")
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

struct test4_Previews: PreviewProvider {
    static var previews: some View {
        test4()
    }
}
