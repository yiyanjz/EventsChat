//
//  LikeAnimation.swift
//  EC
//
//  Created by Justin Zhang on 11/14/23.
//

import SwiftUI

struct LoveGeometryEffect : GeometryEffect {
    var time : Double
    var speed = Double.random(in: 100 ... 200)
    var xDirection = Double.random(in: -0.1 ... 0.1)
    var yDirection = Double.random(in: -Double.pi ... 0)
    var animatableData: Double {
        get { time }
        set { time = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let xTranslation = speed * xDirection
        let yTranslation = speed * sin(yDirection) * time
        let affineTranslation = CGAffineTransform(translationX: xTranslation, y: yTranslation)
        return ProjectionTransform(affineTranslation)
    }
}

struct LoveTapModifier: ViewModifier {
    @State var time = 0.0
    let duration = 1.0
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .foregroundColor(Color(uiColor: .red))
                .modifier(LoveGeometryEffect(time: time))
                .opacity(time == 1 ? 0 : 1)
        }
        .onAppear {
            withAnimation (.easeOut(duration: duration)) {
                self.time = duration
            }
        }
    }
}
