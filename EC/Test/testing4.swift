//
//  testing4.swift
//  EC
//
//  Created by Justin Zhang on 12/21/23.
//

import SwiftUI
import UIKit

struct testing4: View {
    @State private var currentPosition: CGSize = .zero
    @State private var newPosition: CGSize = .zero
    @State private var clipped = false
    let screenWidth = UIScreen().bounds.width
    let screenHeight = UIScreen().bounds.height
    
    var body: some View {
        VStack {
//            GeometryReader { geometry in
//                
//                ZStack {
//                    Image("shin")
//                        .resizable()
//                        .scaledToFill()
//                        .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
//                        .offset(x: self.currentPosition.width, y: self.currentPosition.height)
//
//                    RoundedRectangle(cornerRadius: 25)
//                        .fill(Color.black.opacity(0.3))
//                        .frame(width: 200 , height: 200)
//                        .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.white, lineWidth: 3))
//                        .offset(x: screenWidth)
//                }
//                .clipShape(
//                    CropFrame(isActive:clipped)
//                )
//                .gesture(DragGesture()
//                    .onChanged { value in
//                        self.currentPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
//                }
//                .onEnded { value in
//                    self.currentPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
//
//                    self.newPosition = self.currentPosition
//                })
//            }
//            .ignoresSafeArea()
//            
//            Button (action : { self.clipped.toggle() }) {
//                Text("Crop Image")
//                    .padding(.all, 10)
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .shadow(color: .gray, radius: 1)
//                    .padding(.top, 50)
//            }
        }

    }
}

struct CropFrame: Shape {
    let isActive: Bool
    
    func path(in rect: CGRect) -> Path {
        guard isActive else { return Path(rect) } // full rect for non active

        let size = CGSize(width: 200, height: 200)
        let origin = CGPoint(x: rect.midX - size.width / 2, y: rect.midY - size.height / 2)
        return Path(CGRect(origin: origin, size: size).integral)
    }
}

#Preview {
    testing4()
}
