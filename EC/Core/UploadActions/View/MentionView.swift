//
//  MentionView.swift
//  EC
//
//  Created by Justin Zhang on 12/17/23.
//

import SwiftUI
import Kingfisher

struct MentionView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: MentionViewModel
    
    init(selectedMentionUser: Binding<[User]>) {
        self._viewModel = StateObject(wrappedValue: MentionViewModel(selectedMentionUser: selectedMentionUser))
    }
    
    func searchUserFollow() -> [User]{
        if viewModel.searchName.isEmpty {
            return viewModel.userFollow
        } else {
            return viewModel.userFollow.filter { $0.username.contains(viewModel.searchName) }
        }
    }
    
    var body: some View {
        VStack {
            headerView
            
            searchBarView
            
            ForEach(searchUserFollow(), id:\.self) { user in
                HStack {
                    KFImage(URL(string: user.profileImageUrl ?? ""))
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Text(user.username)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    Button {
                        viewModel.selectedUser.contains(user)
                        ? viewModel.selectedUser.removeAll(where: {$0.id == user.id})
                        : viewModel.selectedUser.append(user)
                    } label: {
                        Image(systemName: viewModel.selectedUser.contains(user) ? "circle.fill" : "circle")
                            .resizable()
                            .frame(width: 30, height: 30, alignment: .center)
                            .foregroundColor(viewModel.selectedUser.contains(user) ? Color(uiColor: .blue) : Color(uiColor: .gray))
                    }
                }
                .padding()
            }
            
            Spacer()
        }
    }
}

#Preview {
    MentionView(selectedMentionUser: .constant([User.MOCK_USERS[0]]))
}

extension MentionView {
    // headerView
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
            Text("Mention")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button {
                viewModel.selectedMentionUser = viewModel.selectedUser
                dismiss()
            } label: {
                Text("Done")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
        }
        .padding(.horizontal)
    }
    
    var searchBarView: some View {
        VStack {
            TextField("Search name", text: $viewModel.searchName)
                .font(.subheadline)
                .padding(12)
                .background(.white)
                .cornerRadius(25)
                .padding()
                .shadow(radius: 10)
            
        }
    }
}
