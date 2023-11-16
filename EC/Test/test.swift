//
//  test.swift
//  EC
//
//  Created by Justin Zhang on 11/4/23.
//

import SwiftUI

struct test: View {
    @Namespace var animation
    @State private var isFlipped = false

    var body: some View {
        ZStack {
            VStack{
                test2(animation: animation)
            }
            .opacity(isFlipped ? 0 : 1)

            VStack {
                if isFlipped{
                    test3(animation: animation)
                }
            }
            .opacity(isFlipped ? 1 : 0)
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                isFlipped.toggle()
            }
        }
    }
}

struct test_Previews: PreviewProvider {
    static var previews: some View {
        test()
    }
}


struct test2: View {
    let animation: Namespace.ID

    var body: some View {
        Image("shin")
            .resizable()
            .scaledToFit()
            .matchedGeometryEffect(id: "images", in: animation)
    }
}

struct test3: View {
    let animation: Namespace.ID

    var body: some View {
        Image("shin")
            .resizable()
            .frame(width: 150, height: 150)
            .scaledToFit()
            .matchedGeometryEffect(id: "images", in: animation)
    }
}

