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
    @State var groupName: String = ""
    @State var searchUser: String = ""
    @State var users: [String] = ["Justin", "Hannah", "Liqi"]
    @State var shareTo = [String]()
    
    func searchResults() -> [String]{
        if searchUser.isEmpty {
            return users
        } else {
            return users.filter { $0.contains(searchUser) }
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
                    Text("Done")
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
            TextField("Group Name", text: $groupName)
            
            Text("To")
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {

                        ForEach(shareTo, id:\.self) { user in
                            Text(user)
                                .frame(height: 25)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 15).fill(.gray.opacity(0.1))
                                )
                        }
                        
                        TextField("search user", text: $searchUser)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Button {
                    if shareTo.count > 0 {
                        shareTo.removeLast()
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
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                        .foregroundColor(Color(.systemGray4))
                    
                    VStack(alignment:.leading){
                        Text(user)
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 15))
                    
                    Spacer()
                    
                    Button {
                        if !shareTo.contains(user) {
                            shareTo.append(user)
                            searchUser = ""
                        }else{
                            shareTo.removeAll(where: {$0 == user})
                        }
                    } label: {
                        Image(systemName: "circle")
                            .resizable()
                            .frame(width: 30, height: 30, alignment: .center)
                            .foregroundColor(Color(uiColor: .gray))
                    }
                }
                .padding(.top)
            }
        }
        .searchable(text: $searchUser)
        .padding(.horizontal)
    }
}
