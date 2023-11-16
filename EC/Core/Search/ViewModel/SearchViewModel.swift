//
//  SearchViewModel.swift
//  EC
//
//  Created by Justin Zhang on 11/16/23.
//

import SwiftUI
import Firebase

class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var searched: Bool = false
    @Published var showResultView: Bool = false
    @Published var allSearchText = [String]()
    
    let service = SearchService()
    
    init() {
        Task {try await fectchSearch()}
        observeUserSearches()
    }
    
    // upload search
    func uploadSearch() async throws {
        if allSearchText.isEmpty {
            let newAllSearchText: [String] = allSearchText + [searchText]
            try await service.uploadSearch(allSearchText: newAllSearchText)
        }else{
            let newAllSearchText: [String] = allSearchText + [searchText]
            try await service.updateSearch(allSearchText: newAllSearchText)
        }
    }
    
    // fectch search
    func fectchSearch() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let searchHistory = try await service.fetchUserSearch(withUid: uid)
        DispatchQueue.main.async {
            self.allSearchText = searchHistory.content
        }
    }
    
    // listener for user searchs
    func observeUserSearches() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        service.observeUserSearch(withUid: uid) { search in
            var searchResult = search.content
            if searchResult.count < 9 {
                self.allSearchText = searchResult
            }else{
                searchResult.remove(at: 0)
                self.allSearchText = searchResult
            }
        }
    }
    
    // delete all history
    func deleteHistory() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        try await service.deleteHistory(withUid: uid)
    }
}
