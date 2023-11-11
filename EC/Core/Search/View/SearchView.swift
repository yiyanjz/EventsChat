//
//  SearchView.swift
//  EC
//
//  Created by Justin Zhang on 11/9/23.
//

import SwiftUI

struct SearchView: View {
    @State var searchText: String = ""
    @State var searched: Bool = false
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State var showResultView: Bool = false
    
    let names = ["Holly", "Josh", "Rhonda", "Ted"]
    var searchResults: [String] {
        if searchText.isEmpty {
            return names
        } else {
            return names.filter { $0.contains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                headerView
                
                bodyView
            }
            .padding(.horizontal,15)
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showResultView) {
                SearchResultView(searchText: $searchText, searched: $searched)
                    .NavigationHidden()
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}

extension SearchView {
    // headerView
    var headerView: some View {
        // Header
        HStack {
            // search bar + icon
            HStack {
                Image(systemName: "magnifyingglass")
                    .fontWeight(.semibold)
                    .padding(.leading, 10)
                
                TextField("Search", text: $searchText)
                
            }
            .frame(height: 35)
            .background(.gray.opacity(0.2),in: RoundedRectangle(cornerRadius: 20))
            .onTapGesture {
                searched = true
            }
            
            // cancel button
            Button{
                withAnimation {
                    dismiss()
                }
                searched = false
            }label: {
                Text("Cancel")
            }
        }
        .padding(.bottom)
        .foregroundColor(.gray)
    }
    
    // bodyView
    var bodyView: some View {
        // body view
        ScrollView(showsIndicators: false){
            if searched == false {
                VStack{
                    VStack{
                        HStack{
                            Text("History")
                                .foregroundColor(.orange)
                                .font(.system(size: 18))
                            
                            Spacer()
                            
                            Button {
                                print("SearchView: trash button pressed")
                            } label: {
                                Image(systemName:"trash")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(0..<5) { _ in
                                    Button {
                                        searchText = "Holly"
                                        showResultView.toggle()
                                    } label: {
                                        Text("Jay Chow baby my old baby")
                                            .ButtonStyleWhite()
                                    }
                                }
                            }
                            .foregroundColor(Color(uiColor: colorScheme == .light ? .black : .white))
                        }
                    }
                    .padding(.vertical)
                    
                    VStack(spacing:15){
                        HStack{
                            Text("Trending")
                                .foregroundColor(.orange)
                                .font(.system(size: 18))
                            Spacer()
                        }
                        
                        VStack(spacing:15){
                            ForEach(0..<5) { _ in
                                Button {
                                    searchText = "hannah is xiao ben dan"
                                    showResultView.toggle()
                                } label: {
                                    HStack{
                                        Circle()
                                            .frame(width: 5, height:5)
                                            .foregroundColor(.yellow)
                                        Text("hannah is xiao ben dan")
                                        Spacer()
                                        Text("102.8w")
                                        Image(systemName: "arrow.up")
                                            .font(.footnote)
                                            .foregroundColor(.red)
                                    }
                                    .foregroundColor(Color(uiColor: colorScheme == .light ? .black : .white))
                                    
                                    Divider()
                                }
                            }
                        }
                    }
                }
            }else{
                VStack{
                    ForEach(searchResults, id: \.self) { name in
                        NavigationLink{
                            SearchResultView(searchText: $searchText, searched: $searched)
                                .NavigationHidden()
                        }label: {
                            HStack{
                                HighlightedText(text: name, searchText: searchText)
                                Spacer()
                            }
                            .foregroundColor(Color(uiColor: colorScheme == .light ? .black : .white))
                        }
                        Divider()
                    }
                }
                .searchable(text: $searchText)
            }
        }
    }
}
