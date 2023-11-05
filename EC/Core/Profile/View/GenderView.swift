//
//  GenderView.swift
//  EC
//
//  Created by Justin Zhang on 11/2/23.
//

import SwiftUI

struct GenderView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedItemText: String

    var body: some View {
        VStack {
            headerView
            
            bodyView
            
            Spacer()
        }
        .background(Color(uiColor: .systemBackground))
    }
}

struct GenderView_Previews: PreviewProvider {
    static var previews: some View {
        GenderView(selectedItemText: .constant(""))
    }
}

// headerView
extension GenderView {
    var headerView: some View {
        // ToolBar
        HStack {
            // cancel button
            Button("Cancel") {
                dismiss()
            }
            .font(.subheadline)
            .fontWeight(.bold)
            
            Spacer()
            
            // title
            Text("Select a gender")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(colorScheme == .light ? .black : .white)

            Spacer()
            
            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
        }
        .padding(.horizontal)
    }
}

extension GenderView {
    var bodyView: some View {
        VStack(alignment: .leading) {
            // info
            Text("This won't be part of your public profile")
                .font(.footnote)
                .fontWeight(.heavy)
                .foregroundColor(Color(uiColor: .systemGray4))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack {
                ForEach(GenderSelection.allCases, id:\.rawValue) { item in
                    HStack {
                        Text(item.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(colorScheme == .light ? .black : .white)
                        
                            Spacer()
                    
                        if selectedItemText == item.title {
                            Circle()
                                .strokeBorder(colorScheme == .light ? .black : .white, lineWidth: 2)
                                .foregroundColor(colorScheme == .light ? .black : .white)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Circle()
                                        .fill(Color.blue)
                                )
                        } else {
                            Circle()
                                .strokeBorder(colorScheme == .light ? .black : .white, lineWidth: 2)
                                .foregroundColor(colorScheme == .light ? .black : .white)
                                .frame(width: 20, height: 20)
                        }
                    }
                    .padding(.top, 10)
                    .onTapGesture {
                        selectedItemText = item.title
                    }
                }
            }
        }
        .font(.footnote)
        .padding()
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray4), lineWidth: 1)
        }
        .padding()
        .padding(.top)
    }
}
