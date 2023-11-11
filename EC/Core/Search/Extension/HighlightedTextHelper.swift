//
//  HighlightedTextHelper.swift
//  EC
//
//  Created by Justin Zhang on 11/10/23.
//

import SwiftUI

struct HighlightedText: View {
    var text: String
    var searchText: String
    var returnText = Text("")
    var body: some View {
        let textArray = text.map{String($0)}
        let searchArray = searchText.map{String($0)}
        let highlighted: [Bool] = textArray.map { element in
            searchArray.contains{ searchElemnet in
                element.caseInsensitiveCompare(searchElemnet) == .orderedSame
            }
        }
        return HStack(spacing:0){
            ForEach(0..<textArray.count, id: \.self) { index in
                Text(textArray[index])
                    .foregroundColor(highlighted[index] ? .gray : .primary)
            }
        }
    }
}
