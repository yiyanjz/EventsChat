//
//  ExtensionHelper.swift
//  EC
//
//  Created by Justin Zhang on 11/9/23.
//


import SwiftUI


extension View{
    func NavigationHidden() -> some View{
        self
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
    }
}

extension View{
    func ButtonStyleWhite() -> some View{
        self
            .frame(height: 25)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 15).fill(.gray.opacity(0.1))
            )
    }
}
