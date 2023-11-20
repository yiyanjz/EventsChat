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
    @Published var searchText: String
    
    let service = SearchService()
    
    init(searchText:String) {
        self.searchText = searchText
        Task { try await searchFilterResults() }
    }
    
    // search and filter posts with search tag / title / capation
    // stores in a array of post
    @MainActor
    func searchFilterResults() async throws {
        self.postsResult = try await service.searchFilterResults(searchText: searchText)
    }
}
