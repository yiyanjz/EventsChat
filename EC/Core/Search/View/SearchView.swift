//
//  SearchView.swift
//  EC
//
//  Created by Justin Zhang on 11/9/23.
//

import SwiftUI

struct SearchView: View {
    @State var searchtext: String = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            VStack {
                // Header
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .fontWeight(.semibold)
                            .padding(.leading, 10)
                            
                        TextField("Search", text: $searchtext)
                    }
                    .frame(height: 35)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 0.7)
                    )
                    
                    Button{
                        withAnimation {
                           dismiss()
                        }
                    }label: {
                        Text("Cancel")
                    }
                }
                .padding(.bottom)
                .foregroundColor(.gray)
                
                // body view
                ScrollView{
                    if searchtext == ""{
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
                                
                                HStack {
                                    ForEach(0..<2) { _ in
                                        Text("Jay Chow")
                                            .ButtonStyleWhite()
                                    }
                                }
                            }
                                                        
                            VStack(spacing:15){
                                HStack{
                                    Text("Discover")
                                        .foregroundColor(.orange)
                                        .font(.system(size: 18))
                                    
                                    Spacer()
                                    
                                    HStack{
                                        Image(systemName: "arrow.clockwise")
                                            .font(.footnote)
                                        Text("Shuffle")
                                    }
                                    .foregroundColor(.gray)
                                }
                               
                               
                                HStack{
                                    VStack(alignment:.leading,spacing:15){
                                        Text("top musicgfdgasdfasdf")
                                        Text("games")
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment:.leading,spacing:15){
                                        Text("911")
                                        Text("super car")
                                    }
                                    Spacer()
                                }
                            }
                            .padding(.vertical)
                                                        
                            VStack(spacing:15){
                                HStack{
                                    Text("Trends for You")
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
                                    
                                }label: {
                                    HStack{
                                        Text("Hannah Zhang")
                                        Spacer()
                                    }
                                    .foregroundColor(.black)
                                }
                                Divider()
                            }
                        }
                    }
                }
            }
            .padding(.horizontal,15)
            .background(.white)
            .navigationBarHidden(true)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
