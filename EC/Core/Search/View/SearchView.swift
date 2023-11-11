//
//  SearchView.swift
//  EC
//
//  Created by Justin Zhang on 11/9/23.
//

import SwiftUI

struct SearchView: View {
    @State var searchtext: String = ""
    @State var searched: Bool = false
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            VStack {
                headerView
                
                bodyView
            }
            .padding(.horizontal,15)
            .navigationBarHidden(true)
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
                
                TextField("Search", text: $searchtext)
                
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
                            
                            Image(systemName:"trash")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(0..<5) { _ in
                                    Text("Jay Chow baby my old baby")
                                        .ButtonStyleWhite()
                                }
                            }
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
                            
                            Divider()
                            HStack{
                                Circle()
                                    .frame(width: 5, height:5)
                                    .foregroundColor(.yellow.opacity(0.5))
                                Text("hannah is xiao ben dan")
                                Spacer()
                                Text("102.8w")
                                Image(systemName: "arrow.up")
                                    .font(.footnote)
                                    .foregroundColor(.red)
                            }
                            Divider()
                            HStack{
                                Circle()
                                    .frame(width: 5, height:5)
                                    .foregroundColor(.gray.opacity(0.5))
                                Text("hannah is xiao ben dan")
                                Spacer()
                                Text("102.8w")
                                Image(systemName: "arrow.up")
                                    .font(.footnote)
                                    .foregroundColor(.red)
                            }
                            
                        }
                    }
                }
            }else{
                VStack{
                    ForEach(0..<19){ item in
                        NavigationLink{
                            SearchResultView(searchtext: $searchtext, searched: $searched)
                                .NavigationHidden()
                        }label: {
                            HStack{
                                Text("Hannah Zhang")
                                Spacer()
                            }
                            .foregroundColor(Color(uiColor: colorScheme == .light ? .black : .white))
                        }
                        Divider()
                    }
                }
            }
        }
    }
}
