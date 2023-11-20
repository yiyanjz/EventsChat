//
//  SearchResultViewModel.swift
//  EC
//
//  Created by Justin Zhang on 11/19/23.
//

import SwiftUI
import Firebase

class SearchResultViewModel: ObservableObject {
    @Published var postsResult = [Post]()
    @Binding var searchText: String
    @Binding var searched: Bool
    @Published var showPostDetail: Bool = false
    @Published var selectedPost: Post?
    
    let service = SearchService()
    
    init(searchText:Binding<String>, searched: Binding<Bool>) {
        self._searchText = searchText
        self._searched = searched
        Task { try await searchFilterResults() }
    }
    
    // search and filter posts with search tag / title / capation
    // stores in a array of post
    @MainActor
    func searchFilterResults() async throws {
        self.postsResult = try await service.searchFilterResults(searchText: searchText)
    }
}
