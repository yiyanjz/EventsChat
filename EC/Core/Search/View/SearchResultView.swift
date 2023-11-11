//
//  SearchResultView.swift
//  EC
//
//  Created by Justin Zhang on 11/9/23.
//

import SwiftUI

struct SearchResultView: View {
    @State var scrollsize : CGFloat = 0
    
    @Environment(\.dismiss) var dismiss
    @Binding var searchtext: String
    @Binding var searched: Bool
    @State private var selectedFilter: SearchFilter = .all
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack{
            // header
            HStack{
                // search
                Button{
                    withAnimation {
                        dismiss()
                    }
                    searched = false
                    searchtext = ""
                }label: {
                    Image(systemName: "chevron.backward")
                }
                .foregroundColor(.black)
                
                HStack{
                    Image(systemName: "magnifyingglass")
                    TextField("\(searchtext)", text: $searchtext)
                }
                .padding(5)
                .background(.gray.opacity(0.2),in: RoundedRectangle(cornerRadius: 20))
            }
            .foregroundColor(.gray)
            .padding(.horizontal)
            .padding(.top)
            
            HStack(spacing:40){
                // filter switch
                ForEach(SearchFilter.allCases, id: \.rawValue) { item in
                    VStack{
                        Text(item.title)
                            .font(.subheadline)
                            .fontWeight(selectedFilter == item ? .semibold : .regular)
                            .foregroundColor(colorScheme == .light ? .black : .white)
                            // .frame == underline's height .offset = underlines y's pos
                            .background( selectedFilter == item ? Color.red.frame(width: 30, height: 2).offset(y: 14)
                                         : Color.clear.frame(width: 30, height: 1).offset(y: 14)
                            )
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            selectedFilter = item
                        }
                    }
                }
            }
            .padding(.vertical,5)
            .padding(.horizontal)
            
            if scrollsize > -100{
                Divider()
            }
            
            TabView(selection: $selectedFilter){
                SearchResultAllView(scrollsize: $scrollsize)
                    .tag(SearchFilter.all)
                SearchResultUserView()
                    .tag(SearchFilter.users)
            }
            .frame(minHeight:700,maxHeight: .infinity)
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .offset(y:scrollsize < 0 ? scrollsize:0)
        .offset(y:scrollsize < -115 ? -(scrollsize+115):0)
        .frame(width: UIScreen.main.bounds.width)
        .background(.white)
        
    }
}

struct SearchResultView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultView(searchtext: .constant(""), searched: .constant(false))
    }
}
