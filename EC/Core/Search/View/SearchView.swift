//
//  SearchView.swift
//  EC
//
//  Created by Justin Zhang on 11/9/23.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = SearchViewModel()
    
    let names = ["Holly", "Josh", "Rhonda", "Ted"]
    var searchResults: [String] {
        if viewModel.searchText.isEmpty {
            return names
        } else {
            return names.filter { $0.contains(viewModel.searchText) }
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
            .fullScreenCover(isPresented: $viewModel.showResultView) {
                SearchResultView(searchText: $viewModel.searchText, searched: $viewModel.searched)
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
                
                TextField("Search", text: $viewModel.searchText)
                    .onSubmit {
                        viewModel.searchText = "\(viewModel.searchText)"
                        viewModel.showResultView.toggle()
                        Task { try await viewModel.uploadSearch() }
                    }
                
            }
            .frame(height: 35)
            .background(.gray.opacity(0.2),in: RoundedRectangle(cornerRadius: 20))
            .onTapGesture {
                viewModel.searched = true
            }
            
            // cancel button
            Button{
                withAnimation {
                    dismiss()
                }
                viewModel.searched = false
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
            if viewModel.searched == false {
                VStack{
                    VStack{
                        HStack{
                            Text("History")
                                .foregroundColor(.orange)
                                .font(.system(size: 18))
                            
                            Spacer()
                            
                            Button {
                                viewModel.allSearchText = []
                                Task { try await viewModel.deleteHistory() }
                            } label: {
                                Image(systemName:"trash")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(viewModel.allSearchText, id: \.self) { text in
                                    Button {
                                        viewModel.searchText = "\(text)"
                                        viewModel.showResultView.toggle()
                                        Task { try await viewModel.uploadSearch() }
                                    } label: {
                                        Text("\(text)")
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
                                    viewModel.searchText = "hannah is xiao ben dan"
                                    viewModel.showResultView.toggle()
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
                            SearchResultView(searchText: $viewModel.searchText, searched: $viewModel.searched)
                                .NavigationHidden()
                        }label: {
                            HStack{
                                HighlightedText(text: name, searchText: viewModel.searchText)
                                Spacer()
                            }
                            .foregroundColor(Color(uiColor: colorScheme == .light ? .black : .white))
                        }
                        Divider()
                    }
                }
                .searchable(text: $viewModel.searchText)
            }
        }
    }
}
