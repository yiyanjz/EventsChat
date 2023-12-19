//
//  test.swift
//  EC
//
//  Created by Justin Zhang on 11/4/23.
//

import SwiftUI

struct test: View {
    @State var showDetails: Bool = false
    var hashTagArray: [String] = ["#Lorem", "#Ipsum", "#dolor", "#consectetur", "#adipiscing", "#elit", "#Nam", "#semper", "#sit"]
    var hashTagArray22: [String] = ["#asdfasdf", "#c","#dsds", "#ccsc"]
    
    // grid Item Structure
    private let gridItem: [GridItem] = [
        .init(.flexible(), spacing: 4),
        .init(.flexible(), spacing: 4),
        .init(.flexible(), spacing: 4),
    ]
    
    var body: some View {
        ScrollView{
            LazyVGrid(columns: gridItem , alignment: .leading, spacing: 5)  {
                ForEach(hashTagArray, id:\.self) { tag in
                    Text(tag)
                }
                ForEach(hashTagArray22, id:\.self) { tag in
                    Text(tag)
                }
            }
            .padding()
            .border(Color.blue)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .disabled(true)
    }
}

struct test_Previews: PreviewProvider {
    static var previews: some View {
        test()
    }
}
