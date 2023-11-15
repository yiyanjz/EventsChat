//
//  test2.swift
//  EC
//
//  Created by Justin Zhang on 11/4/23.
//

import SwiftUI

struct test2: View {
    @State var loveCount = 0
    @State var animationXCord = 0.0
    @State var animationYCord = 0.0
    
    func TapAction() {
        loveCount += 1
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 40) {
                ZStack {
                    Image(systemName: "heart.fill")
                        .resizable()
                        .foregroundColor(.white)

                        .padding()
                        .onTapGesture { location in
                            TapAction()
                            animationXCord = location.x
                            animationYCord = location.y
                        }
                    
                    ForEach(0 ..< loveCount, id: \.self) { _ in
                        Image(systemName: "heart.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .modifier(LoveTapModifier())
                            .position(x: animationXCord, y: animationYCord)
                    }
                }
                
                Text("\(loveCount)")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
        }
    }
}

struct test2_Previews: PreviewProvider {
    static var previews: some View {
        test2()
    }
}


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
