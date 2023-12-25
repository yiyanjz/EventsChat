//
//  StoryEditView.swift
//  EC
//
//  Created by Justin Zhang on 12/25/23.
//

import SwiftUI

struct StoryEditView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedFilter: StoryFilter = .stories
    @StateObject var viewModel = StoryEditViewModel()
    
    // grid Item Structure
    private let gridItem: [GridItem] = [
        .init(.flexible(), spacing: 4),
        .init(.flexible(), spacing: 4),
        .init(.flexible(), spacing: 4),
    ]
    
    var body: some View {
        VStack {
            headerView
            
            bodyView
            
            Divider()
                .padding(4)
            
            coverNameView
            
            Divider()
                .padding(4)
            
            selectionView
            
            Spacer()
        }
        .onAppear {
            DispatchQueue.main.async{
                viewModel.getAlbum()
            }
        }
        .onChange(of: viewModel.selectAlbum) { newValue in
            DispatchQueue.main.async{
                viewModel.getImages()
            }
        }
    }
}

#Preview {
    StoryEditView()
}

extension StoryEditView {
    // header view
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
            Text("Edit Highlights")
                .font(.subheadline)
                .fontWeight(.semibold)
            
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
    
    var bodyView: some View {
        VStack {
            Button {
            } label: {
                VStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .foregroundColor(Color(.systemGray4))
                    
                    Text("Edit Cover")
                }
            }
        }
        .padding()
    }
    
    var coverNameView: some View {
        HStack {
            Text("Story Name: ")
                .font(.system(size: 15))
            
            TextField("Story Title", text: $viewModel.storyTitle)
                .font(.system(size: 15))
                .multilineTextAlignment(.leading)
        }
        .padding()
    }
    
    var selectionView: some View {
        VStack {
            // follow, explore, nearby buttons
            HStack(spacing: UIScreen.main.bounds.width/2) {
                ForEach(StoryFilter.allCases, id: \.rawValue) { item in
                    VStack{
                        Text(item.title)
                            .font(.system(size: 15))
                            .fontWeight(selectedFilter == item ? .semibold : .regular)
                            .foregroundColor(colorScheme == .light ? .black : .white)
                            // .frame == underline's height .offset = underlines y's pos
                            .background( selectedFilter == item ? Color.red.frame(width:UIScreen.main.bounds.width/2 + 50, height: 4).offset(y: 19)
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
            
            TabView(selection: $selectedFilter) {
                storiesView
                    .tag(StoryFilter.stories)
                
                libraryView
                    .tag(StoryFilter.library)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
    
    var storiesView: some View {
        ScrollView {
            LazyVGrid(columns: gridItem, spacing: 1)  {
                ForEach(Array(viewModel.selectedMedia.enumerated()), id: \.element) { index, item in
                    Button {
                    } label: {
                        Image(uiImage: item.uiImage)
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width/3, height: 200)
                            .overlay(
                                Button {
                                    if viewModel.allList[index].selected {
                                        viewModel.allList[index].selected.toggle()
                                        let media = viewModel.allList[index]
                                        if viewModel.selectedMedia.contains(where: { key in key.id == media.id }) {
                                            viewModel.selectedMedia.removeAll(where: { key in key.id == media.id })
                                        }
                                    }
                                } label: {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .padding(5)
                                        .background(.black.opacity(0.5),in: Circle())
                                        .frame(width: UIScreen.main.bounds.width/3, height: 200, alignment: .bottomTrailing)
                                        .padding(8)
                                }
                            )
                    }
                }
            }
        }
    }
    
    var libraryView: some View {
        ScrollView {
            LazyVGrid(columns: gridItem, spacing: 1)  {
                ForEach(Array(viewModel.allList.enumerated()), id: \.element) { index, item in
                    Button {
                    } label: {
                        Image(uiImage: item.uiImage)
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width/3, height: 200)
                            .overlay(
                                Button {
                                    if viewModel.allList[index].selected == false {
                                        viewModel.allList[index].selected.toggle()
                                        let media = viewModel.allList[index]
                                        viewModel.selectedMedia.append(media)
                                    } else if viewModel.allList[index].selected {
                                        viewModel.allList[index].selected.toggle()
                                        let media = viewModel.allList[index]
                                        if viewModel.selectedMedia.contains(where: { key in key.id == media.id }) {
                                            viewModel.selectedMedia.removeAll(where: { key in key.id == media.id })
                                        }
                                    }
                                } label: {
                                    Image(systemName: item.selected ? "checkmark.seal.fill" : "checkmark.seal")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .padding(5)
                                        .background(.black.opacity(0.5),in: Circle())
                                        .frame(width: UIScreen.main.bounds.width/3, height: 200, alignment: .bottomTrailing)
                                        .padding(8)
                                }
                            )
                    }
                }
            }
        }
    }
}
