////
////  test2.swift
////  EC
////
////  Created by Justin Zhang on 11/4/23.
////
//
//import SwiftUI
//
//struct test2: View {
//    @State var loveCount = 0
//    @State var animationXCord = 0.0
//    @State var animationYCord = 0.0
//
//    func TapAction() {
//        loveCount += 1
//    }
//
//    var body: some View {
//        ZStack {
//            Color.black.ignoresSafeArea()
//
//            VStack(alignment: .center, spacing: 40) {
//                ZStack {
//                    Image(systemName: "heart.fill")
//                        .resizable()
//                        .foregroundColor(.white)
//
//                        .padding()
//                        .onTapGesture { location in
//                            TapAction()
//                            animationXCord = location.x
//                            animationYCord = location.y
//                        }
//
//                    ForEach(0 ..< loveCount, id: \.self) { _ in
//                        Image(systemName: "heart.fill")
//                            .resizable()
//                            .frame(width: 60, height: 60)
//                            .modifier(LoveTapModifier())
//                            .position(x: animationXCord, y: animationYCord)
//                    }
//                }
//
//                Text("\(loveCount)")
//                    .font(.largeTitle)
//                    .foregroundColor(.white)
//            }
//        }
//    }
//}
//
//struct test2_Previews: PreviewProvider {
//    static var previews: some View {
//        test2()
//    }
//}
