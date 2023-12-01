//
//  StoryView.swift
//  EC
//
//  Created by Justin Zhang on 11/29/23.
//

import SwiftUI

struct StoryView: View {
    var media: [Post]
    var images:[String] = ["shin","jian","background"]
    @ObservedObject var countTimer: CountTimer = CountTimer(items: 3,interval: 4.0)
    
    var body: some View {
        GeometryReader{geometry in
            ZStack(alignment: .top){
                Image(self.images[Int(self.countTimer.progress)])
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .scaledToFill()
                    .frame(width: geometry.size.width,height: nil,alignment: .center)
                
                // Loading Bar
                HStack(alignment: .center, spacing: 4){
                    ForEach(self.images.indices, id: \.self){ image in
                        LoadingBarView(progress: min( max( (CGFloat(self.countTimer.progress) - CGFloat(image)), 0.0) , 1.0) )
                            .frame(width:nil,height: 2, alignment:.leading)
                    }
                    
                }
                .padding()
                
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
    }
}

struct StoryView_Previews: PreviewProvider {
    static var previews: some View {
        StoryView(media: Post.MOCK_POST)
    }
}
