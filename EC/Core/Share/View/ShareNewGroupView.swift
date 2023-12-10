//
//  ShareNewGroupView.swift
//  EC
//
//  Created by Justin Zhang on 12/9/23.
//

import SwiftUI
import Combine

struct ShareNewGroupView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = ShareNewGroupViewModel()
    
    func searchResults() -> [User]{
        if viewModel.searchUser.isEmpty {
            return viewModel.userFollowing
        } else {
            return viewModel.userFollowing.filter { $0.username.contains(viewModel.searchUser) }
        }
    }

    var body: some View {
        VStack {
            headerView
            
            Divider()
            
            textFieldView
            
            allUserView
            
            Spacer()
        }
    }
}

struct ShareNewGroupView_Previews: PreviewProvider {
    static var previews: some View {
        ShareNewGroupView()
    }
}

extension ShareNewGroupView {
    // headerView
    var headerView: some View {
        // ToolBar
        VStack {
            HStack {
                // cancel button
                Button("Cancel") {
                    dismiss()
                }
                .font(.subheadline)
                .fontWeight(.bold)
                
                Spacer()
                
                // title
                Text("Edit Profile")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Text("Create")
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }
    
    var textFieldView: some View {
        VStack(spacing:20) {
            TextField("Group Name", text: $viewModel.groupName)
            
            Text("To")
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.shareTo, id:\.self) { user in
                            Text(user.username)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 15).fill(.gray.opacity(0.1))
                                )
                        }
                        
                        TextField("search user", text: $viewModel.searchUser)
                    }
                    .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
                }
                
                Button {
                    if viewModel.shareTo.count > 0 {
                        viewModel.shareTo.removeLast()
                    }
                } label: {
                    Image(systemName: "arrowshape.backward.fill")
                }
            }
        }
        .padding()
    }
    
    var allUserView: some View {
        VStack {
            Text("Recent")
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(searchResults(), id:\.self) { user in
                HStack {
                    CircularProfileImageView(user: user, size: .small)
                    
                    VStack(alignment:.leading){
                        Text(user.username)
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 15))
                    
                    Spacer()
                    
                    Button {
                        if !viewModel.shareTo.contains(user) {
                            viewModel.shareTo.append(user)
                            viewModel.searchUser = ""
                        }else{
                            viewModel.shareTo.removeAll(where: {$0 == user})
                        }
                    } label: {
                        Image(systemName: viewModel.shareTo.contains(user) ? "circle.fill" : "circle")
                            .resizable()
                            .frame(width: 30, height: 30, alignment: .center)
                            .foregroundColor(Color(uiColor: .gray))
                    }
                }
                .padding(.top)
            }
        }
        .searchable(text: $viewModel.searchUser)
        .padding(.horizontal)
    }
}
