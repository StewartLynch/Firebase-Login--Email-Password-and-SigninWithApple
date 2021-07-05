//
//  HomeView.swift
//  Firebase Login
//
//  Created by Stewart Lynch on 2020-03-23.
//  Copyright © 2020 CreaTECH Solutions. All rights reserved.
//

import SwiftUI
import Firebase

struct HomeView: View {
    @EnvironmentObject var userInfo: UserInfo
    @State private var showProfile = false
    @State private var canDelete = false
    
    var body: some View {
        NavigationView {
            Text("Logged in as \(userInfo.user.name)")
            .navigationBarTitle("Firebase Login")
                .navigationBarItems(leading: Button {
                    showProfile = true
                } label: {
                    Image(systemName: "person.crop.circle.fill")
                }.frame(width: 44, height: 44),
                    trailing: Button("Log Out") {
                    FBAuth.logout { (result) in
                        print("Logged out")
                    }
                })
                .sheet(isPresented: $showProfile, onDismiss: {
                    if canDelete {
                        FBFirestore.deleteUserData(uid: userInfo.user.uid) { result in
                            switch result {
                            case .success:
                                FBAuth.deleteUser { result in
                                    if case let .failure(error) = result {
                                        print(error.localizedDescription)
                                    }
                                }
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    }
                }) {
                    ProfileView(canDelete: $canDelete)
                }
                .onAppear {
                    guard let uid = Auth.auth().currentUser?.uid else {
                        return
                    }
                    FBFirestore.retrieveFBUser(uid: uid) { (result) in
                        switch result {
                        case.failure(let error):
                            print(error.localizedDescription)
                            // Display some kind of alert to your user here.  (It shouldn't happen)
                        case .success(let user):
                            self.userInfo.user = user
                        }
                    }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(UserInfo())
    }
}
